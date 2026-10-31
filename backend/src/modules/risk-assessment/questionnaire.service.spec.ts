import { BadRequestException, ForbiddenException, NotFoundException } from '@nestjs/common';
import { QuestionnaireService } from './questionnaire.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { AuthenticatedUser, UserRole, UserStatus } from '../../common/interfaces/authenticated-user.interface';
import { GeminiService } from '../ai/gemini.service';

describe('QuestionnaireService', () => {
  let service: QuestionnaireService;
  let mockPrisma: any;
  let mockAudit: any;
  let mockGemini: any;

  const samplePatient: AuthenticatedUser = {
    id: 'user-pat-01',
    firebaseUid: 'uid-pat-01',
    email: 'mariam@lumyra.health',
    displayName: 'Mariam Ali',
    role: UserRole.PATIENT,
    status: UserStatus.ACTIVE,
    isActive: true,
    patientProfileId: 'profile-pat-01',
  };

  const validAnswers = {
    currentAge: 45,
    menopausalStatus: 'PRE_MENOPAUSAL',
    ageAtMenarche: '12_TO_13',
    hasGivenBirth: 'YES',
    ageAtFirstLiveBirth: '25_TO_29',
    hormoneReplacementTherapy: 'NEVER',
    firstDegreeBreastCancer: 'ONE',
    diagnosedBeforeAge50: 'NO',
    familyOvarianCancer: 'NO',
    geneticTestingStatus: 'NOT_TESTED',
    priorBiopsyHistory: 'NONE',
    denseBreastsReported: 'NORMAL_DENSITY',
    currentSymptomsReported: 'NO_SYMPTOMS',
  };

  beforeEach(() => {
    process.env.SKIP_DB_CONNECT = 'false';

    mockPrisma = {
      $transaction: jest.fn((callback) => callback(mockPrisma)),
      riskAssessmentRequest: {
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        findMany: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        updateMany: jest.fn(),
        deleteMany: jest.fn(),
      },
      riskAssessmentResult: {
        create: jest.fn(),
      },
    };

    mockAudit = {
      logEvent: jest.fn(),
    };

    mockGemini = {
      assessClinicalRisk: jest.fn().mockResolvedValue(null),
    };

    service = new QuestionnaireService(
      mockPrisma as PrismaService,
      mockAudit as AuditService,
      mockGemini as unknown as GeminiService,
    );
  });

  describe('getDefinition', () => {
    it('should return version 1.1.0-guided with clinical disclaimer and sections', () => {
      const def = service.getDefinition();
      expect(def.version).toBe('1.1.0-guided');
      expect(def.sections.length).toBe(4);
      expect(def.disclaimerAr).toContain('تنبيه طبي');
      expect(def.disclaimerEn).toContain('Clinical Disclaimer');
    });
  });

  describe('saveDraft & getMyDraft', () => {
    it('should save in-progress draft answers with currentStep', async () => {
      mockPrisma.riskAssessmentRequest.findFirst.mockResolvedValue(null);
      mockPrisma.riskAssessmentRequest.create.mockResolvedValue({
        id: 'draft-01',
        status: 'DRAFT',
      });

      const result = await service.saveDraft(samplePatient, {
        currentStep: 2,
        answers: { currentAge: 42 },
      });

      expect(result.status).toBe('DRAFT');
      expect(result.currentStep).toBe(2);
      expect(mockPrisma.riskAssessmentRequest.create).toHaveBeenCalled();
    });

    it('should retrieve existing draft for authenticated patient', async () => {
      mockPrisma.riskAssessmentRequest.findFirst.mockResolvedValue({
        id: 'draft-01',
        questionnaireVersion: '1.1.0-guided',
        status: 'DRAFT',
        answersPayload: { currentStep: 1, answers: { currentAge: 40 } },
        createdAt: new Date(),
      });

      const draft = await service.getMyDraft(samplePatient);
      expect(draft).not.toBeNull();
      expect(draft!.currentStep).toBe(1);
      expect(draft!.answers).toEqual({ currentAge: 40 });
    });
  });

  describe('submitQuestionnaire', () => {
    it('should throw BadRequestException if patientConsentAcknowledged is false', async () => {
      await expect(
        service.submitQuestionnaire(samplePatient, {
          answers: validAnswers,
          patientConsentAcknowledged: false,
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException if mandatory questions are missing', async () => {
      const incomplete = { ...validAnswers, currentAge: undefined };
      await expect(
        service.submitQuestionnaire(samplePatient, {
          answers: incomplete as any,
          patientConsentAcknowledged: true,
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should successfully submit questionnaire and generate guidance points without numerical risk scores', async () => {
      mockPrisma.riskAssessmentRequest.create.mockResolvedValue({
        id: 'req-sub-01',
        status: 'SUBMITTED',
      });
      mockPrisma.riskAssessmentResult.create.mockResolvedValue({
        id: 'res-sub-01',
        isDemonstrationData: true,
        qualitativeRiskCategory: 'AVERAGE',
      });

      const response = await service.submitQuestionnaire(samplePatient, {
        answers: validAnswers,
        patientConsentAcknowledged: true,
      });

      expect(response.request.status).toBe('SUBMITTED');
      expect(response.result.isDemonstrationData).toBe(true);

      // Verify that previously submitted records were marked SUPERSEDED
      expect(mockPrisma.riskAssessmentRequest.updateMany).toHaveBeenCalledWith({
        where: {
          patientId: samplePatient.patientProfileId,
          status: 'SUBMITTED',
        },
        data: {
          status: 'SUPERSEDED',
        },
      });

      // Verify that audit log was created
      expect(mockAudit.logEvent).toHaveBeenCalled();
    });
  });

  describe('correctQuestionnaire & Data Isolation', () => {
    it('should throw ForbiddenException if trying to correct another patient questionnaire', async () => {
      mockPrisma.riskAssessmentRequest.findUnique.mockResolvedValue({
        id: 'other-req',
        patientId: 'profile-other-patient',
        status: 'SUBMITTED',
      });

      await expect(
        service.correctQuestionnaire(samplePatient, {
          previousRequestId: 'other-req',
          answers: validAnswers,
          correctionReason: 'Corrected age at menarche',
          patientConsentAcknowledged: true,
        }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw ForbiddenException in getResponseById if attempting cross-patient access', async () => {
      mockPrisma.riskAssessmentRequest.findUnique.mockResolvedValue({
        id: 'other-req',
        patientId: 'profile-other-patient',
        status: 'SUBMITTED',
      });

      await expect(
        service.getResponseById('other-req', samplePatient),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
