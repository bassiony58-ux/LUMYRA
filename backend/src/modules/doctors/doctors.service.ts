import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { UpdateDoctorApprovalDto } from './dto/update-doctor-approval.dto';
import { DoctorApprovalStatus, UserRole } from '../../common/interfaces/authenticated-user.interface';
import { AuditAction } from '@prisma/client';

@Injectable()
export class DoctorsService {
  private readonly logger = new Logger(DoctorsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
  ) {}

  async listApprovedDoctors(specialty?: string) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return [
        {
          id: 'doc-mock-01',
          licenseNumber: 'EGY-MED-2024-8841',
          specialization: 'Oncoplastic Breast Surgery',
          hospitalAffiliation: 'National Cancer Institute (NCI) - Cairo University',
          clinicAddress: 'Kasr Al Ainy, Cairo',
          clinicPhoneNumber: '+20 2 2368 2030',
          approvalStatus: DoctorApprovalStatus.APPROVED,
          user: {
            id: 'usr-dr-01',
            email: 'dr.nour@lumyra.health',
            displayName: 'د. نور الخالدي (Dr. Nour Al-Khalidi)',
            phoneNumber: '+20 100 234 5678',
          },
        },
      ];
    }

    return this.prisma.doctorProfile.findMany({
      where: {
        approvalStatus: DoctorApprovalStatus.APPROVED,
        ...(specialty ? { specialization: { contains: specialty, mode: 'insensitive' } } : {}),
      },
      include: {
        user: { select: { id: true, email: true, displayName: true, phoneNumber: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async listPendingDoctors() {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return [
        {
          id: 'doc-pending-01',
          licenseNumber: 'EGY-MED-2025-1102',
          specialization: 'Diagnostic Radiology & Breast Imaging',
          hospitalAffiliation: 'Ain Shams University Hospital',
          clinicAddress: 'Abbassia, Cairo',
          clinicPhoneNumber: '+20 2 2482 1800',
          approvalStatus: DoctorApprovalStatus.PENDING,
          user: {
            id: 'usr-dr-pending-01',
            email: 'dr.pending@lumyra.health',
            displayName: 'د. سارة المنشاوي (Dr. Sara El-Minshawi)',
            createdAt: new Date().toISOString(),
          },
        },
      ];
    }

    return this.prisma.doctorProfile.findMany({
      where: { approvalStatus: DoctorApprovalStatus.PENDING },
      include: {
        user: { select: { id: true, email: true, displayName: true, createdAt: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getDoctorById(id: string) {
    const doctor = await this.prisma.doctorProfile.findUnique({
      where: { id },
      include: {
        user: { select: { id: true, email: true, displayName: true } },
      },
    });

    if (!doctor) {
      throw new NotFoundException(`Doctor with ID ${id} not found.`);
    }

    return doctor;
  }

  async updateDoctorApproval(id: string, dto: UpdateDoctorApprovalDto, adminUserId: string) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return {
        id,
        approvalStatus: dto.status,
        rejectionReason: dto.rejectionReason || null,
        updatedAt: new Date(),
      };
    }

    const doctor = await this.prisma.doctorProfile.findUnique({ where: { id } });
    if (!doctor) {
      throw new NotFoundException(`Doctor profile ${id} not found.`);
    }

    if (dto.status === DoctorApprovalStatus.REJECTED && !dto.rejectionReason) {
      throw new BadRequestException('A rejection reason must be provided when rejecting a doctor application.');
    }

    const updated = await this.prisma.doctorProfile.update({
      where: { id },
      data: {
        approvalStatus: dto.status,
        approvedAt: dto.status === DoctorApprovalStatus.APPROVED ? new Date() : null,
        approvedByAdminId: dto.status === DoctorApprovalStatus.APPROVED ? adminUserId : null,
        rejectionReason: dto.rejectionReason || null,
        bio: dto.adminNotes ? `${doctor.bio || ''}\n[Admin Notes]: ${dto.adminNotes}`.trim() : doctor.bio,
      },
    });

    await this.audit.logEvent({
      action: dto.status === DoctorApprovalStatus.APPROVED ? AuditAction.APPROVE_DOCTOR : AuditAction.REJECT_DOCTOR,
      actorUserId: adminUserId,
      actorRole: UserRole.ADMIN,
      targetEntity: 'DoctorProfile',
      targetEntityId: id,
      metadata: { newStatus: dto.status, rejectionReason: dto.rejectionReason },
    });

    this.logger.log(`Doctor profile ${id} status updated to ${dto.status} by Admin ${adminUserId}`);
    return updated;
  }

  async getSmartAlerts(doctorUser: any) {
    return [
      {
        id: 'alt-001',
        priority: 'CRITICAL',
        priorityLabel: 'حالة حرجة عاجلة',
        patientId: 'pat-01',
        patientName: 'سارة أحمد محمد',
        patientAge: 46,
        category: 'IMAGING_ANOMALY',
        title: 'اشتباه شعاعي يستلزم خزعة موجهة',
        description: 'أظهر تحليل الفحص الأخير مؤشرات نسيجية غير نمطية (BI-RADS 4B) بحاجة لتنسيق موعد عاجل لأخذ عينة نسيجية.',
        detectedAt: new Date(Date.now() - 7200000).toISOString(),
        isActionRequired: true,
        actionType: 'SCHEDULE_BIOPSY',
      },
      {
        id: 'alt-002',
        priority: 'HIGH',
        priorityLabel: 'أعراض تحذيرية',
        patientId: 'pat-02',
        patientName: 'مريم علي حسن',
        patientAge: 52,
        category: 'SYMPTOM_ALERT',
        title: 'تسجيل أعراض تحذيرية في الاستبيان',
        description: 'أبلغت المريضة عن ظهور كتلة صلبة غير متحركة حديثة في الثدي الأيسر مع إفرازات حلمية غير معتادة.',
        detectedAt: new Date(Date.now() - 18000000).toISOString(),
        isActionRequired: true,
        actionType: 'CLINICAL_CALL',
      },
      {
        id: 'alt-003',
        priority: 'MODERATE',
        priorityLabel: 'تنبيه التزام دوائي',
        patientId: 'pat-03',
        patientName: 'فاطمة حسن إبراهيم',
        patientAge: 49,
        category: 'MEDICATION_ADHERENCE',
        title: 'تراجع الالتزام بالعلاج الهرموني',
        description: 'لم تسجل المريضة تناول جرعة التاموكسيفين المقررة لمدة 3 أيام متتالية. يوصى بإرسال رسالة تذكيرية ومتابعة الأعراض الجانبية.',
        detectedAt: new Date(Date.now() - 86400000).toISOString(),
        isActionRequired: false,
        actionType: 'SEND_REMINDER',
      },
    ];
  }
}
