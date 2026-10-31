import { Injectable, NotFoundException, ForbiddenException, Logger } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { MockRiskModelProvider } from '../ai/providers/mock-risk-model.provider';
import { AuthenticatedUser, UserRole } from '../../common/interfaces/authenticated-user.interface';
import { SubmitRiskAssessmentDto } from './dto/risk-assessment.dto';
import { QualitativeRiskCategory, AuditAction } from '@prisma/client';

@Injectable()
export class RiskAssessmentService {
  private readonly logger = new Logger(RiskAssessmentService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly riskProvider: MockRiskModelProvider,
  ) {}

  async submitAssessment(user: AuthenticatedUser, dto: SubmitRiskAssessmentDto) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can submit health risk assessments.');
    }

    // Run calculation via provider
    const result = await this.riskProvider.assessRisk(dto);

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return {
        id: 'mock-risk-assessment-id',
        status: 'COMPLETED',
        inputs: dto,
        result,
      };
    }

    const request = await this.prisma.riskAssessmentRequest.create({
      data: {
        patientId: user.patientProfileId,
        questionnaireVersion: '1.0.0-guided',
        answersPayload: dto as any,
        status: 'COMPLETED',
      },
    });

    const assessmentResult = await this.prisma.riskAssessmentResult.create({
      data: {
        requestId: request.id,
        calculatorModelName: result.providerName,
        calculatorModelVersion: result.modelVersion,
        isDemonstrationData: result.isDemoPlaceholder,
        qualitativeRiskCategory: QualitativeRiskCategory.AVERAGE,
        resultsPayload: {
          keyFactors: result.keyFactorsIdentified,
          caveats: result.caveats,
          tier: result.riskTier,
        },
        guidanceRecommendations: [
          'Maintain regular clinical breast examinations as directed by your physician.',
          'Discuss your documented family history during your next clinical appointment.',
        ],
        clinicalReviewNotice: result.disclaimer,
      },
    });

    await this.audit.logEvent({
      action: AuditAction.SUBMIT_RISK_ASSESSMENT,
      actorUserId: user.id,
      actorRole: user.role,
      targetEntity: 'RiskAssessmentRequest',
      targetEntityId: request.id,
      metadata: { isDemo: result.isDemoPlaceholder },
    });

    return {
      request,
      result: assessmentResult,
    };
  }

  async listHistory(user: AuthenticatedUser) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can view their assessment history.');
    }

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return [];
    }

    return this.prisma.riskAssessmentRequest.findMany({
      where: { patientId: user.patientProfileId },
      include: {
        results: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getById(id: string, user: AuthenticatedUser) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return { id, status: 'COMPLETED' };
    }

    const request = await this.prisma.riskAssessmentRequest.findUnique({
      where: { id },
      include: { results: true },
    });

    if (!request) {
      throw new NotFoundException(`Assessment request ${id} not found.`);
    }

    if (user.role === UserRole.PATIENT && request.patientId !== user.patientProfileId) {
      throw new ForbiddenException('Access denied to assessment.');
    }

    return request;
  }
}
