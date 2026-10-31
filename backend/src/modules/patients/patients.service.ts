import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { AccessControlService } from '../../common/services/access-control.service';
import { AuthenticatedUser, DoctorApprovalStatus, UserRole } from '../../common/interfaces/authenticated-user.interface';
import { UpdatePatientConsentDto, AssignDoctorDto } from './dto/patient-requests.dto';
import { AuditAction } from '@prisma/client';

@Injectable()
export class PatientsService {
  private readonly logger = new Logger(PatientsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly accessControl: AccessControlService,
  ) {}

  async getMyPatientProfile(user: AuthenticatedUser) {
    if (!user.patientProfileId) {
      throw new NotFoundException('Patient profile does not exist for this account.');
    }

    const patient = await this.prisma.patientProfile.findUnique({
      where: { id: user.patientProfileId },
      include: {
        user: { select: { id: true, displayName: true, email: true, phoneNumber: true, preferredLanguage: true } },
        doctorAssignments: {
          where: { isActive: true },
          include: {
            doctor: {
              include: {
                user: { select: { displayName: true, email: true } },
              },
            },
          },
        },
        medications: { where: { isActive: true } },
        appointments: {
          orderBy: { scheduledAt: 'desc' },
          take: 5,
        },
      },
    });

    if (!patient) {
      throw new NotFoundException('Patient record not found.');
    }

    return patient;
  }

  async getMyDashboard(user: AuthenticatedUser) {
    if (!user.patientProfileId) {
      throw new NotFoundException('Patient profile does not exist for this account.');
    }

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return {
        profile: {
          id: user.patientProfileId,
          displayName: user.displayName,
          email: user.email,
          preferredLanguage: 'ar',
          consentForCareTracking: true,
        },
        upcomingAppointments: [],
        activeMedications: [],
        recommendedArticles: [
          {
            id: 'art-self-exam-01',
            slug: 'monthly-breast-self-exam-guide',
            titleAr: 'دليلك الشامل للفحص الذاتي الشهري للثدي',
            titleEn: 'Comprehensive Guide to Monthly Breast Self-Examination',
            summaryAr: 'دليل مبسط وواضح لخطوات الفحص الذاتي الشهري، أفضل الأوقات لإجرائه، والعلامات التي تستدعي استشارة الطبيب.',
            summaryEn: 'A clear guide to monthly self-examination steps, timing, and symptoms requiring clinical consultation.',
            categoryNameAr: 'الفحص الذاتي والتوعية',
            categoryNameEn: 'Self-Examination & Awareness',
            readTimeMinutes: 5,
          },
        ],
        careTeam: [],
      };
    }

    const patient = await this.prisma.patientProfile.findUnique({
      where: { id: user.patientProfileId },
      include: {
        user: { select: { displayName: true, email: true, preferredLanguage: true } },
        doctorAssignments: {
          where: { isActive: true },
          include: {
            doctor: {
              include: {
                user: { select: { displayName: true, email: true } },
              },
            },
          },
        },
        medications: {
          where: { isActive: true },
          orderBy: { createdAt: 'desc' },
          take: 5,
        },
        appointments: {
          where: {
            status: { in: ['SCHEDULED', 'CONFIRMED'] },
          },
          include: {
            doctor: {
              include: {
                user: { select: { displayName: true } },
              },
            },
          },
          orderBy: { scheduledAt: 'asc' },
          take: 5,
        },
      },
    });

    if (!patient) {
      throw new NotFoundException('Patient record not found.');
    }

    const articles = await this.prisma.educationalArticle.findMany({
      where: { isPublished: true },
      include: {
        category: { select: { nameAr: true, nameEn: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 3,
    });

    return {
      profile: {
        id: patient.id,
        displayName: patient.user.displayName,
        email: patient.user.email,
        preferredLanguage: patient.user.preferredLanguage,
        consentForCareTracking: patient.consentForCareTracking,
      },
      upcomingAppointments: patient.appointments.map((a) => ({
        id: a.id,
        doctorName: a.doctor?.user?.displayName || 'Dr. Specialist',
        specialty: a.doctor?.specialization || 'Oncology',
        scheduledAt: a.scheduledAt.toISOString(),
        estimatedDurationMinutes: a.estimatedDurationMinutes,
        status: a.status,
        reason: a.reason,
      })),
      activeMedications: patient.medications.map((m) => ({
        id: m.id,
        name: m.name,
        dosage: m.dosage,
        instructions: m.instructions,
        frequency: m.frequency,
        timeOfDay: m.timeOfDay,
        startDate: m.startDate.toISOString(),
        endDate: m.endDate ? m.endDate.toISOString() : null,
      })),
      recommendedArticles: articles.map((art) => ({
        id: art.id,
        slug: art.slug,
        titleAr: art.titleAr,
        titleEn: art.titleEn,
        summaryAr: art.summaryAr,
        summaryEn: art.summaryEn,
        categoryNameAr: art.category.nameAr,
        categoryNameEn: art.category.nameEn,
        readTimeMinutes: art.readTimeMinutes,
      })),
      careTeam: patient.doctorAssignments.map((da) => ({
        doctorId: da.doctorId,
        doctorName: da.doctor.user.displayName,
        specialization: da.doctor.specialization,
        hospitalAffiliation: da.doctor.hospitalAffiliation,
        clinicAddress: da.doctor.clinicAddress,
      })),
    };
  }

  async getPatientById(id: string, user: AuthenticatedUser) {
    // Enforce strict resource-level access check
    await this.accessControl.assertPatientAccess(user, id);

    const patient = await this.prisma.patientProfile.findUnique({
      where: { id },
      include: {
        user: { select: { id: true, displayName: true, email: true, phoneNumber: true } },
        doctorAssignments: {
          where: { isActive: true },
          include: {
            doctor: {
              include: {
                user: { select: { displayName: true } },
              },
            },
          },
        },
        medications: { where: { isActive: true } },
        medicalScans: {
          select: {
            id: true,
            category: true,
            scanDate: true,
            reviewStatus: true,
            createdAt: true,
          },
        },
      },
    });

    if (!patient) {
      throw new NotFoundException(`Patient with ID ${id} not found.`);
    }

    await this.audit.logEvent({
      action: AuditAction.VIEW_PATIENT_RECORD,
      actorUserId: user.id,
      actorRole: user.role,
      targetEntity: 'PatientProfile',
      targetEntityId: id,
      metadata: { requesterRole: user.role },
    });

    return patient;
  }

  async updateConsent(user: AuthenticatedUser, dto: UpdatePatientConsentDto) {
    if (!user.patientProfileId) {
      throw new NotFoundException('Patient profile missing.');
    }

    const updated = await this.prisma.patientProfile.update({
      where: { id: user.patientProfileId },
      data: {
        consentForCareTracking: dto.consentDataProcessing ?? true,
        consentTimestamp: new Date(),
      },
    });

    await this.audit.logEvent({
      action: AuditAction.VIEW_PATIENT_RECORD,
      actorUserId: user.id,
      actorRole: user.role,
      targetEntity: 'PatientProfile',
      targetEntityId: user.patientProfileId,
      metadata: { action: 'UPDATE_CONSENT', ...dto },
    });

    return updated;
  }

  async assignDoctor(user: AuthenticatedUser, dto: AssignDoctorDto) {
    if (!user.patientProfileId) {
      throw new NotFoundException('Patient profile missing.');
    }

    const doctor = await this.prisma.doctorProfile.findUnique({
      where: { id: dto.doctorId },
    });

    if (!doctor) {
      throw new NotFoundException(`Doctor ${dto.doctorId} not found.`);
    }

    if (doctor.approvalStatus !== DoctorApprovalStatus.APPROVED) {
      throw new BadRequestException('Cannot assign an unapproved doctor to your clinical care team.');
    }

    const assignment = await this.prisma.doctorPatientAssignment.upsert({
      where: {
        doctorId_patientId: {
          doctorId: dto.doctorId,
          patientId: user.patientProfileId,
        },
      },
      update: {
        isActive: true,
        notes: dto.notes || null,
        revokedAt: null,
      },
      create: {
        doctorId: dto.doctorId,
        patientId: user.patientProfileId,
        isActive: true,
        notes: dto.notes || null,
      },
      include: {
        doctor: {
          include: {
            user: { select: { displayName: true, email: true } },
          },
        },
      },
    });

    await this.audit.logEvent({
      action: AuditAction.VIEW_PATIENT_RECORD,
      actorUserId: user.id,
      actorRole: user.role,
      targetEntity: 'DoctorPatientAssignment',
      targetEntityId: dto.doctorId,
      metadata: { action: 'ASSIGN_DOCTOR' },
    });

    return assignment;
  }

  async revokeDoctor(user: AuthenticatedUser, doctorId: string) {
    if (!user.patientProfileId) {
      throw new NotFoundException('Patient profile missing.');
    }

    const assignment = await this.prisma.doctorPatientAssignment.findUnique({
      where: {
        doctorId_patientId: {
          doctorId,
          patientId: user.patientProfileId,
        },
      },
    });

    if (!assignment) {
      throw new NotFoundException('No care assignment found for this doctor.');
    }

    const updated = await this.prisma.doctorPatientAssignment.update({
      where: {
        doctorId_patientId: {
          doctorId,
          patientId: user.patientProfileId,
        },
      },
      data: {
        isActive: false,
        revokedAt: new Date(),
      },
    });

    await this.audit.logEvent({
      action: AuditAction.VIEW_PATIENT_RECORD,
      actorUserId: user.id,
      actorRole: user.role,
      targetEntity: 'DoctorPatientAssignment',
      targetEntityId: doctorId,
      metadata: { action: 'REVOKE_DOCTOR' },
    });

    return { message: 'Doctor assignment revoked successfully', assignment: updated };
  }
}
