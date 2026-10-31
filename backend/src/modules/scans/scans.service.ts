import { execFile } from 'child_process';
import * as path from 'path';
import * as fs from 'fs';
import * as os from 'os';
import { randomUUID } from 'crypto';
import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { StorageService } from '../../common/storage/storage.service';
import { AuditService } from '../audit/audit.service';
import { AccessControlService } from '../../common/services/access-control.service';
import { AuthenticatedUser, UserRole, DoctorApprovalStatus } from '../../common/interfaces/authenticated-user.interface';
import { RequestUploadGrantDto, RegisterScanDto, CreateDoctorReviewDto, ScanReviewStatus } from './dto/scan.dto';
import { AuditAction } from '@prisma/client';
import { GeminiService } from '../ai/gemini.service';

@Injectable()
export class ScansService {
  private readonly logger = new Logger(ScansService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
    private readonly audit: AuditService,
    private readonly accessControl: AccessControlService,
    private readonly geminiService: GeminiService,
  ) {}

  async requestUploadGrant(user: AuthenticatedUser, dto: RequestUploadGrantDto) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can request scan upload grants.');
    }

    const grant = await this.storage.getUploadSignedUrl(
      user.patientProfileId,
      dto.filename,
      dto.mimeType,
    );

    return {
      uploadUrl: grant.uploadUrl,
      storageKey: grant.storageKey,
      expiresAt: grant.expiresAt,
      instructions:
        'Upload your encrypted medical image binary directly via HTTP PUT to uploadUrl before expiresAt. Never transmit image files through open channels.',
    };
  }

  async registerScan(user: AuthenticatedUser, dto: RegisterScanDto) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can register their medical scans.');
    }

    const expectedPrefix = `patients/${user.patientProfileId}/`;
    if (!dto.storageKey.startsWith(expectedPrefix)) {
      throw new BadRequestException('Invalid storageKey prefix. Security violation.');
    }

    const scan = await this.prisma.medicalScan.create({
      data: {
        patientId: user.patientProfileId,
        uploadedByUserId: user.id,
        category: dto.category,
        originalFilename: dto.originalFilename,
        storageKey: dto.storageKey,
        mimeType: dto.mimeType,
        fileSizeBytes: dto.fileSizeBytes,
        scanDate: new Date(dto.scanDate),
        doctorNotes: dto.doctorNotes || null,
        reviewStatus: ScanReviewStatus.PENDING,
      },
    });

    await this.audit.logEvent({
      action: AuditAction.VIEW_SCAN,
      actorUserId: user.id,
      actorRole: user.role,
      targetEntity: 'MedicalScan',
      targetEntityId: scan.id,
      metadata: { action: 'REGISTER_SCAN', category: dto.category },
    });

    return scan;
  }

  async getSecureAccessUrl(id: string, user: AuthenticatedUser) {
    const scan = await this.prisma.medicalScan.findUnique({
      where: { id },
    });

    if (!scan) {
      throw new NotFoundException(`Medical scan ${id} not found.`);
    }

    await this.accessControl.assertPatientAccess(user, scan.patientId);

    const signed = await this.storage.getReadSignedUrl(scan.storageKey, 900);

    await this.audit.logEvent({
      action: AuditAction.DOWNLOAD_SCAN,
      actorUserId: user.id,
      actorRole: user.role,
      targetEntity: 'MedicalScan',
      targetEntityId: scan.id,
      metadata: { expiresAt: signed.expiresAt },
    });

    return {
      scanId: scan.id,
      category: scan.category,
      signedUrl: signed.url,
      expiresAt: signed.expiresAt,
      validDurationSeconds: 900,
      securityNotice:
        'This URL is strictly private, time-limited, and will expire in 15 minutes. It must not be cached, forwarded, or shared publicly.',
    };
  }

  async submitDoctorReview(id: string, user: AuthenticatedUser, dto: CreateDoctorReviewDto) {
    if (user.role !== UserRole.DOCTOR) {
      throw new ForbiddenException('Only doctors can submit clinical scan reviews.');
    }

    if (user.doctorStatus !== DoctorApprovalStatus.APPROVED || !user.doctorProfileId) {
      throw new ForbiddenException('Doctor license not approved.');
    }

    const scan = await this.prisma.medicalScan.findUnique({ where: { id } });
    if (!scan) {
      throw new NotFoundException(`Medical scan ${id} not found.`);
    }

    await this.accessControl.assertPatientAccess(user, scan.patientId);

    const review = await this.prisma.secondaryScanReview.create({
      data: {
        scanId: id,
        requestedByDoctorId: user.doctorProfileId,
        providerName: 'clinical-doctor-review',
        modelVersion: 'manual-signoff-v1',
        isDemonstrationData: false,
        observationsPayload: { notes: dto.clinicalObservations || 'Doctor manual signoff completed' },
        clinicalDisclaimer: 'Clinical sign-off recorded by licensed physician.',
        physicianSignOffNotes: dto.physicianSignOffNotes,
      },
    });

    await this.prisma.medicalScan.update({
      where: { id },
      data: { reviewStatus: ScanReviewStatus.CLINICIAN_REVIEWED },
    });

    await this.audit.logEvent({
      action: AuditAction.SECONDARY_SCAN_REVIEW,
      actorUserId: user.id,
      actorRole: user.role,
      targetEntity: 'SecondaryScanReview',
      targetEntityId: review.id,
      metadata: { scanId: id },
    });

    return review;
  }

  async analyzeScan(user: AuthenticatedUser, dto: { fileName?: string; modelId?: string }, file?: any) {
    // 1. Role Authorization: Strictly derived from the verified token, NEVER trusted from client DTO
    const isDoctor = user.role === UserRole.DOCTOR || user.role === UserRole.ADMIN;

    // 2. Mandatory Multipart File Validation
    if (!file || !file.buffer || file.buffer.length === 0) {
      throw new BadRequestException('يرجى رفع ملف صورة الفحص الطبي عبر النموذج (Multipart File)');
    }

    const buf: Buffer = file.buffer;

    // File size limit: 15MB
    if (buf.length > 15 * 1024 * 1024) {
      throw new BadRequestException('حجم ملف الصورة يتجاوز الحد الأقصى المسموح به (15 ميجابايت).');
    }

    // 3. Deep Magic Bytes Inspection (Strictly JPG or PNG, rejecting forged extensions)
    const isPng =
      buf.length >= 8 &&
      buf[0] === 0x89 &&
      buf[1] === 0x50 &&
      buf[2] === 0x4e &&
      buf[3] === 0x47 &&
      buf[4] === 0x0d &&
      buf[5] === 0x0a &&
      buf[6] === 0x1a &&
      buf[7] === 0x0a;

    const isJpg = buf.length >= 3 && buf[0] === 0xff && buf[1] === 0xd8 && buf[2] === 0xff;

    if (!isPng && !isJpg) {
      throw new BadRequestException(
        'محتوى الملف غير صالح أو تالف. يقبل النظام ملفات الصور الحقيقية بصيغة JPG أو PNG فقط.',
      );
    }

    // 4. Clinical Multimodal Analysis via Google Gemini Vision AI
    const mimeType = isPng ? 'image/png' : 'image/jpeg';
    const geminiResult = await this.geminiService.analyzeMedicalImage(buf, mimeType, isDoctor);

    const finding = geminiResult.finding;
    const confidence = geminiResult.confidence;
    const probabilities = geminiResult.probabilities;
    const modelDetails = {
      modelId: geminiResult.modelVersion,
      modelName: geminiResult.providerName,
      modality: geminiResult.detectedModality,
      architecture: 'Multimodal Generative Vision AI',
      biRadsCategory: geminiResult.biRadsCategory,
      isMedicalScan: geminiResult.isMedicalScan,
      classes: ['benign', 'malignant', 'normal'],
    };

    const facilities = [
      {
        name: 'مؤسسة بهية للاكتشاف المبكر وعلاج سرطان الثدي',
        category: 'مركز رائد مجاني معتمد',
        location: 'فرع الشيخ زايد / فرع الهرم، الجيزة',
        phone: '0235831900',
        hotline: '16602',
      },
      {
        name: 'المعهد القومي للأورام - جامعة القاهرة',
        category: 'مركز أكاديمي واستشاري حكومي',
        location: 'شارع القصر العيني، فم الخليج، القاهرة',
        phone: '0223654400',
        hotline: '16198',
      },
      {
        name: 'عيادة د. نور الخالدي (استشاري جراحة أورام الثدي)',
        category: 'استشاري معتمد في شبكة لوميرا',
        location: 'عيادات الصفا التخصصية، المهندسين',
        phone: '01099887766',
        hotline: '16870',
      },
    ];

    if (isDoctor) {
      const clinicalDiagnosis = geminiResult.clinicalDescriptionAr || `تصنيف النموذج: ${finding.toUpperCase()}`;
      const biRadsClass = geminiResult.biRadsCategory || 'يتطلب تقييم شعاعي سريري مستقل';
      const pathologyNotes = geminiResult.clinicalDescriptionEn || `توزيع الاحتمالات: ${JSON.stringify(probabilities)}`;
      const clinicalActions = geminiResult.recommendations.length > 0
        ? geminiResult.recommendations
        : ['مراجعة الصورة شعاعياً ومطابقتها سريرياً'];

      const clinicalDisclaimer =
        'تنويه طبي: هذه القراءة استرشادية مبنية على الذكاء الاصطناعي للمساعدة في الفحص المبدئي، ولا تغني عن الاستشارة السريرية وفحص الطبيب المختص.';

      return {
        role: 'DOCTOR',
        finding,
        confidencePercent: confidence,
        probabilities,
        modelDetails,
        clinicalDiagnosis,
        biRadsClass,
        pathologyNotes,
        clinicalActions,
        disclaimer: clinicalDisclaimer,
      };
    } else {
      const clinicalDisclaimer =
        'تنويه طبي: هذه القراءة استرشادية مبنية على الذكاء الاصطناعي للمساعدة في الفحص المبدئي، ولا تغني عن الاستشارة السريرية وفحص الطبيب المختص.';

      if (!geminiResult.isMedicalScan) {
        return {
          role: 'PATIENT',
          status: 'INCONCLUSIVE',
          finding: 'inconclusive',
          confidencePercent: confidence,
          probabilities,
          modelDetails,
          headline: 'الصورة المرفوعة ليست فحصاً طبياً معتمداً 🌸',
          badgeText: 'صورة غير طبية / غير مدعومة',
          requiresUrgentDoctorVisit: false,
          message: geminiResult.clinicalDescriptionAr,
          recommendedFacilities: facilities,
          disclaimer: clinicalDisclaimer,
        };
      }

      if (finding === 'malignant') {
        return {
          role: 'PATIENT',
          status: 'ACTION_REQUIRED',
          finding,
          confidencePercent: confidence,
          probabilities,
          modelDetails,
          headline: 'توجيه سريري عاجل • يوصى باستشارة طبية فورية 🌸',
          badgeText: 'أولوية تواصل عاجلة',
          requiresUrgentDoctorVisit: true,
          message: geminiResult.clinicalDescriptionAr ||
            'توضح قراءة الفحص وجود تغيرات نسيجية غير نمطية تستلزم فحصاً سريرياً دقيقاً واستكمال الفحوصات لدى استشاري أورام متخصص. الفحص الطبي المبكر هو خطوة الأمان الأساسية. ننصحكِ بالتواصل العاجل مع أحد المراكز أو الاستشاريين المعتمدين أدناه.',
          recommendedFacilities: facilities,
          disclaimer: clinicalDisclaimer,
        };
      } else if (finding === 'benign') {
        return {
          role: 'PATIENT',
          status: 'REASSURING',
          finding,
          confidencePercent: confidence,
          probabilities,
          modelDetails,
          headline: 'مؤشرات نمطية تتوافق مع التغيرات الحميدة الشائعة 🌸',
          badgeText: 'نمط نسيجي حميد (استرشادي)',
          requiresUrgentDoctorVisit: false,
          message: geminiResult.clinicalDescriptionAr ||
            'أظهر التحليل الآلي المبدئي مؤشرات نسيجية تتوافق مع التغيرات الحميدة الشائعة (مثل الأنسجة الليفية أو الأكياس البسيطة). هذه القراءة استرشادية مبنية على الصورة فقط ولا تغني عن التقييم السريري؛ يُنصح بمشاركة التقرير مع طبيبكِ المختص للمطابقة السريرية وتحديد خطة الرعاية المناسبة لحالتكِ.',
          recommendedFacilities: facilities,
          disclaimer: clinicalDisclaimer,
        };
      } else {
        return {
          role: 'PATIENT',
          status: 'CLEAR',
          finding,
          confidencePercent: confidence,
          probabilities,
          modelDetails,
          headline: 'نمط نسيجي متوافق مع الفحوصات الطبيعية مبدئياً 🌸',
          badgeText: 'نمط طبيعي (استرشادي)',
          requiresUrgentDoctorVisit: false,
          message: geminiResult.clinicalDescriptionAr ||
            'أظهر التحليل المبدئي نمطاً نسيجياً يتوافق مع الأنسجة الطبيعية في صورة السونار. هذه القراءة خوارزمية استرشادية، ويُنصح دائماً بمراجعة الطبيب المختص عند الشعور بأي تغيرات أو أعراض سريرية، واستشارته حول جدول المتابعة الملائم لكِ.',
          recommendedFacilities: facilities,
          disclaimer: clinicalDisclaimer,
        };
      }
    }
  }

  async renameScan(id: string, newFilename: string, user: AuthenticatedUser) {
    if (!newFilename || !newFilename.trim()) {
      throw new BadRequestException('اسم الملف الجديد مطلوب');
    }

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return { id, originalFilename: newFilename.trim(), updated: true };
    }

    const scan = await this.prisma.medicalScan.findUnique({ where: { id } });
    if (!scan) throw new NotFoundException('الفحص غير موجود');

    if (user.role === UserRole.PATIENT && scan.patientId !== user.patientProfileId) {
      throw new ForbiddenException('غير مصرح لك بتعديل هذا الفحص');
    }

    return this.prisma.medicalScan.update({
      where: { id },
      data: { originalFilename: newFilename.trim() },
    });
  }

  async deleteScan(id: string, user: AuthenticatedUser) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return { id, deleted: true };
    }

    const scan = await this.prisma.medicalScan.findUnique({ where: { id } });
    if (!scan) throw new NotFoundException('الفحص غير موجود');

    if (user.role === UserRole.PATIENT && scan.patientId !== user.patientProfileId) {
      throw new ForbiddenException('غير مصرح لك بحذف هذا الفحص');
    }

    await this.prisma.medicalScan.delete({ where: { id } });
    return { id, deleted: true, message: 'تم حذف الفحص بنجاح' };
  }
}
