import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { AuthenticatedUser, UserRole } from '../../common/interfaces/authenticated-user.interface';
import {
  SaveQuestionnaireDraftDto,
  SubmitQuestionnaireDto,
  CorrectQuestionnaireDto,
} from './dto/questionnaire.dto';
import {
  CURRENT_QUESTIONNAIRE_VERSION,
  QUESTIONNAIRE_DEFINITION,
} from './data/questionnaire-definition';
import { QualitativeRiskCategory, AuditAction } from '@prisma/client';
import { GeminiService } from '../ai/gemini.service';

@Injectable()
export class QuestionnaireService {
  private readonly logger = new Logger(QuestionnaireService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly geminiService: GeminiService,
  ) {}

  getDefinition() {
    return {
      ...QUESTIONNAIRE_DEFINITION,
      sections: QUESTIONNAIRE_DEFINITION.sections.map((sec) => ({
        ...sec,
        questions: sec.questions.map((q) => ({
          ...q,
          titleAr: q.labelAr,
          titleEn: q.labelEn,
          helpTextAr: q.descriptionAr,
          helpTextEn: q.descriptionEn,
          isRequired: q.required,
          options: (q.options || []).map((opt) => ({
            ...opt,
            subtitleAr: opt.descriptionAr,
            subtitleEn: opt.descriptionEn,
          })),
        })),
      })),
    };
  }

  async getMyDraft(user: AuthenticatedUser) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can access their draft responses.');
    }

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return null;
    }

    const draft = await this.prisma.riskAssessmentRequest.findFirst({
      where: {
        patientId: user.patientProfileId,
        status: 'DRAFT',
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!draft) return null;

    const payload = draft.answersPayload as any;
    return {
      id: draft.id,
      version: draft.questionnaireVersion,
      status: draft.status,
      currentStep: payload?.currentStep ?? 0,
      answers: payload?.answers ?? {},
      createdAt: draft.createdAt,
    };
  }

  async saveDraft(user: AuthenticatedUser, dto: SaveQuestionnaireDraftDto) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can save draft responses.');
    }

    const payload = {
      currentStep: dto.currentStep,
      answers: dto.answers,
      savedAt: new Date().toISOString(),
    };

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return {
        id: 'mock-draft-id',
        status: 'DRAFT',
        currentStep: dto.currentStep,
        answers: dto.answers,
      };
    }

    // Look for existing draft to update, or create a new one
    const existingDraft = await this.prisma.riskAssessmentRequest.findFirst({
      where: {
        patientId: user.patientProfileId,
        status: 'DRAFT',
      },
      orderBy: { createdAt: 'desc' },
    });

    if (existingDraft) {
      const updated = await this.prisma.riskAssessmentRequest.update({
        where: { id: existingDraft.id },
        data: {
          answersPayload: payload,
          questionnaireVersion: CURRENT_QUESTIONNAIRE_VERSION,
        },
      });
      return { id: updated.id, status: updated.status, ...payload };
    }

    const created = await this.prisma.riskAssessmentRequest.create({
      data: {
        patientId: user.patientProfileId,
        questionnaireVersion: CURRENT_QUESTIONNAIRE_VERSION,
        status: 'DRAFT',
        answersPayload: payload,
      },
    });

    return { id: created.id, status: created.status, ...payload };
  }

  async submitQuestionnaire(user: AuthenticatedUser, dto: SubmitQuestionnaireDto) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can submit health questionnaires.');
    }

    if (!dto.patientConsentAcknowledged) {
      throw new BadRequestException(
        'Patient acknowledgment of the educational non-diagnostic disclaimer is required to submit.',
      );
    }

    // Validate mandatory required fields
    this.validateRequiredAnswers(dto.answers);

    let geminiRisk: any = null;
    try {
      geminiRisk = await this.geminiService.assessClinicalRisk(dto.answers, true);
    } catch (err: any) {
      this.logger.warn(`Gemini risk assessment fallback: ${err.message}`);
    }

    const guidanceRecommendations = geminiRisk?.recommendedActionPlanAr?.length
      ? geminiRisk.recommendedActionPlanAr
      : this.generateGuidancePoints(dto.answers);

    const clinicalNotice = geminiRisk
      ? `${geminiRisk.summaryAr} (${geminiRisk.disclaimer})`
      : 'CLINICAL NOTICE: This report summarizes patient-reported breast health history. Evaluated for educational clinical guidance.';

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return {
        request: {
          id: 'mock-submitted-id',
          patientId: user.patientProfileId,
          questionnaireVersion: CURRENT_QUESTIONNAIRE_VERSION,
          answersPayload: {
            answers: dto.answers,
            patientConsentAcknowledged: true,
            submittedAt: new Date().toISOString(),
          },
          status: 'SUBMITTED',
          createdAt: new Date(),
        },
        result: {
          id: 'mock-result-id',
          requestId: 'mock-submitted-id',
          calculatorModelName: 'lumyra-gemini-clinical-risk-v1',
          calculatorModelVersion: CURRENT_QUESTIONNAIRE_VERSION,
          isDemonstrationData: false,
          qualitativeRiskCategory: geminiRisk?.estimatedRiskCategory || QualitativeRiskCategory.AVERAGE,
          resultsPayload: {
            summaryNotice: geminiRisk?.summaryAr || 'Self-reported breast health history intake',
            caveat: geminiRisk?.disclaimer || 'Educational risk evaluation',
            estimatedRiskCategory: geminiRisk?.estimatedRiskCategory || 'AVERAGE',
            fiveYearRiskPerspectiveAr: geminiRisk?.fiveYearRiskPerspectiveAr || null,
            lifetimeRiskPerspectiveAr: geminiRisk?.lifetimeRiskPerspectiveAr || null,
            gailModelComparisonAr: geminiRisk?.gailModelComparisonAr || null,
            tyrerCuzickComparisonAr: geminiRisk?.tyrerCuzickComparisonAr || null,
            talkingPointsForDoctor: geminiRisk?.talkingPointsForDoctor || [],
            suggestedScreeningScheduleAr: geminiRisk?.suggestedScreeningScheduleAr || null,
            reportedAnswersSummary: dto.answers,
          },
          guidanceRecommendations,
          clinicalReviewNotice: clinicalNotice,
          numericalRiskPercent: null,
          tenYearRiskPercent: null,
          lifetimeRiskPercent: null,
        },
      };
    }

    return await this.prisma.$transaction(async (tx) => {
      // Mark any prior SUBMITTED response as SUPERSEDED
      await tx.riskAssessmentRequest.updateMany({
        where: {
          patientId: user.patientProfileId,
          status: 'SUBMITTED',
        },
        data: {
          status: 'SUPERSEDED',
        },
      });

      // Remove any pending DRAFT for this patient
      await tx.riskAssessmentRequest.deleteMany({
        where: {
          patientId: user.patientProfileId,
          status: 'DRAFT',
        },
      });

      const request = await tx.riskAssessmentRequest.create({
        data: {
          patientId: user.patientProfileId!,
          questionnaireVersion: CURRENT_QUESTIONNAIRE_VERSION,
          status: 'SUBMITTED',
          answersPayload: {
            answers: dto.answers,
            patientConsentAcknowledged: true,
            submittedAt: new Date().toISOString(),
            notes: dto.notes || null,
          },
        },
      });

      const result = await tx.riskAssessmentResult.create({
        data: {
          requestId: request.id,
          calculatorModelName: 'lumyra-patient-reported-intake-v1',
          calculatorModelVersion: CURRENT_QUESTIONNAIRE_VERSION,
          isDemonstrationData: true,
          qualitativeRiskCategory: QualitativeRiskCategory.AVERAGE,
          resultsPayload: {
            summaryNotice: 'Self-reported breast health history intake',
            caveat: 'No mathematical models or risk scores calculated',
            reportedAnswersSummary: dto.answers,
          },
          guidanceRecommendations,
          clinicalReviewNotice: clinicalNotice,
        },
      });

      await this.audit.logEvent({
        action: AuditAction.SUBMIT_RISK_ASSESSMENT,
        actorUserId: user.id,
        actorRole: user.role,
        targetEntity: 'RiskAssessmentRequest',
        targetEntityId: request.id,
        metadata: { version: CURRENT_QUESTIONNAIRE_VERSION, status: 'SUBMITTED' },
      });

      return {
        request,
        result,
      };
    });
  }

  async correctQuestionnaire(user: AuthenticatedUser, dto: CorrectQuestionnaireDto) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can correct questionnaire responses.');
    }

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return {
        request: {
          id: 'mock-corrected-id',
          patientId: user.patientProfileId,
          questionnaireVersion: CURRENT_QUESTIONNAIRE_VERSION,
          answersPayload: {
            answers: dto.answers,
            patientConsentAcknowledged: true,
            correctedFromId: dto.previousRequestId,
            correctionReason: dto.correctionReason,
            submittedAt: new Date().toISOString(),
          },
          status: 'SUBMITTED',
          createdAt: new Date(),
        },
        result: {
          id: 'mock-corrected-result-id',
          requestId: 'mock-corrected-id',
          calculatorModelName: 'lumyra-patient-reported-intake-v1',
          calculatorModelVersion: CURRENT_QUESTIONNAIRE_VERSION,
          isDemonstrationData: true,
          qualitativeRiskCategory: QualitativeRiskCategory.AVERAGE,
          resultsPayload: {
            correctedFromId: dto.previousRequestId,
            correctionReason: dto.correctionReason,
            reportedAnswersSummary: dto.answers,
          },
          guidanceRecommendations: this.generateGuidancePoints(dto.answers),
          clinicalReviewNotice:
            'CLINICAL NOTICE: This corrected record summarizes patient-reported history. Formal mathematical risk models (Gail, Tyrer-Cuzick, BRCAPRO) have not been executed.',
          numericalRiskPercent: null,
          tenYearRiskPercent: null,
          lifetimeRiskPercent: null,
        },
      };
    }

    // Verify existing record ownership
    const priorRecord = await this.prisma.riskAssessmentRequest.findUnique({
      where: { id: dto.previousRequestId },
    });

    if (!priorRecord) {
      throw new NotFoundException(`Prior response record ${dto.previousRequestId} not found.`);
    }

    if (priorRecord.patientId !== user.patientProfileId) {
      throw new ForbiddenException('You cannot correct another patient’s questionnaire.');
    }

    this.validateRequiredAnswers(dto.answers);

    return await this.prisma.$transaction(async (tx) => {
      // Mark old record as SUPERSEDED with reason
      const priorPayload = priorRecord.answersPayload as any;
      await tx.riskAssessmentRequest.update({
        where: { id: dto.previousRequestId },
        data: {
          status: 'SUPERSEDED',
          answersPayload: {
            ...priorPayload,
            supersededAt: new Date().toISOString(),
            correctionReason: dto.correctionReason,
          },
        },
      });

      const guidanceRecommendations = this.generateGuidancePoints(dto.answers);
      const clinicalNotice =
        'CLINICAL NOTICE: This corrected record summarizes patient-reported history. Formal mathematical risk models (Gail, Tyrer-Cuzick, BRCAPRO) have not been executed. No clinical cancer probability or diagnostic conclusion has been determined.';

      const newRecord = await tx.riskAssessmentRequest.create({
        data: {
          patientId: user.patientProfileId!,
          questionnaireVersion: CURRENT_QUESTIONNAIRE_VERSION,
          status: 'SUBMITTED',
          answersPayload: {
            answers: dto.answers,
            patientConsentAcknowledged: true,
            correctedFromId: dto.previousRequestId,
            correctionReason: dto.correctionReason,
            submittedAt: new Date().toISOString(),
          },
        },
      });

      const result = await tx.riskAssessmentResult.create({
        data: {
          requestId: newRecord.id,
          calculatorModelName: 'lumyra-patient-reported-intake-v1',
          calculatorModelVersion: CURRENT_QUESTIONNAIRE_VERSION,
          isDemonstrationData: true,
          qualitativeRiskCategory: QualitativeRiskCategory.AVERAGE,
          resultsPayload: {
            correctedFromId: dto.previousRequestId,
            correctionReason: dto.correctionReason,
            reportedAnswersSummary: dto.answers,
          },
          guidanceRecommendations,
          clinicalReviewNotice: clinicalNotice,
        },
      });

      await this.audit.logEvent({
        action: AuditAction.SUBMIT_RISK_ASSESSMENT,
        actorUserId: user.id,
        actorRole: user.role,
        targetEntity: 'RiskAssessmentRequest',
        targetEntityId: newRecord.id,
        metadata: {
          action: 'CORRECTION',
          correctedFromId: dto.previousRequestId,
          reason: dto.correctionReason,
        },
      });

      return {
        request: newRecord,
        result,
      };
    });
  }

  async listPatientResponses(user: AuthenticatedUser) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can view their questionnaire history.');
    }

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return [];
    }

    return this.prisma.riskAssessmentRequest.findMany({
      where: {
        patientId: user.patientProfileId,
        status: { in: ['SUBMITTED', 'SUPERSEDED'] },
      },
      include: {
        results: { select: { id: true, qualitativeRiskCategory: true, clinicalReviewNotice: true, calculatedAt: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getResponseById(id: string, user: AuthenticatedUser) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return { id, status: 'SUBMITTED' };
    }

    const record = await this.prisma.riskAssessmentRequest.findUnique({
      where: { id },
      include: {
        results: true,
      },
    });

    if (!record) {
      throw new NotFoundException(`Questionnaire response ${id} not found.`);
    }

    if (user.role === UserRole.PATIENT && record.patientId !== user.patientProfileId) {
      throw new ForbiddenException('Access denied: You cannot view another patient’s questionnaire.');
    }

    return record;
  }

  private validateRequiredAnswers(answers: Record<string, any>) {
    if (!answers) {
      throw new BadRequestException('Answers object cannot be empty.');
    }

    const requiredKeys = [
      'currentAge',
      'menopausalStatus',
      'ageAtMenarche',
      'hasGivenBirth',
      'hormoneReplacementTherapy',
      'firstDegreeBreastCancer',
      'familyOvarianCancer',
      'geneticTestingStatus',
      'priorBiopsyHistory',
      'denseBreastsReported',
      'currentSymptomsReported',
    ];

    for (const key of requiredKeys) {
      if (answers[key] === undefined || answers[key] === null || answers[key] === '') {
        throw new BadRequestException(`Missing mandatory answer for questionnaire field '${key}'.`);
      }
    }
  }

  private generateGuidancePoints(answers: Record<string, any>): string[] {
    const points: string[] = [
      'Discuss your documented self-reported answers with your doctor during your next clinical appointment.',
      'Maintain regular monthly breast self-awareness and note any subtle changes.',
    ];

    if (answers.currentSymptomsReported === 'CHANGES_PRESENT') {
      points.unshift(
        'IMPORTANT: Because you reported observing noticeable breast changes, we strongly advise scheduling an in-person clinical breast examination promptly.',
      );
    }

    if (answers.firstDegreeBreastCancer === 'ONE' || answers.firstDegreeBreastCancer === 'TWO_OR_MORE') {
      points.push(
        'Because you reported a first-degree family history, mention this to your doctor to evaluate whether earlier or supplemental screening (e.g. breast MRI or ultrasound) is appropriate.',
      );
    }

    if (answers.geneticTestingStatus === 'POSITIVE_BRCA') {
      points.push(
        'Bring any official genetic testing lab reports to your specialist for formal risk management consultation.',
      );
    }

    return points;
  }
}
