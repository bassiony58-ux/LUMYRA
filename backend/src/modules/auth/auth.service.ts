import {
  Injectable,
  BadRequestException,
  ForbiddenException,
  ConflictException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { FirebaseAdminService } from './firebase-admin.service';
import { RegisterUserDto } from './dto/register-user.dto';
import { UserRole, DoctorApprovalStatus, AuthenticatedUser, UserStatus } from '../../common/interfaces/authenticated-user.interface';
import { AuditAction } from '@prisma/client';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly firebaseAdmin: FirebaseAdminService,
  ) {}

  async registerUser(firebaseUid: string, email: string, dto: RegisterUserDto): Promise<any> {
    // SECURITY RULE: Users cannot register themselves as ADMIN via public registration endpoint.
    if (dto.role === UserRole.ADMIN) {
      throw new ForbiddenException('Administrator accounts cannot be self-registered via public endpoints.');
    }

    const existing = await this.prisma.user.findFirst({
      where: {
        OR: [{ firebaseUid }, { email }],
      },
    });

    if (existing) {
      throw new ConflictException('User with this email or Firebase UID already registered.');
    }

    return await this.prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          firebaseUid,
          email,
          displayName: dto.fullName,
          phoneNumber: dto.phoneNumber || null,
          role: dto.role,
          status: UserStatus.ACTIVE,
          preferredLanguage: dto.preferredLanguage || 'ar',
        },
      });

      if (dto.role === UserRole.PATIENT) {
        const patient = await tx.patientProfile.create({
          data: {
            userId: user.id,
            consentForCareTracking: true,
          },
        });

        await this.audit.logEvent({
          action: AuditAction.LOGIN,
          actorUserId: user.id,
          actorRole: UserRole.PATIENT,
          targetEntity: 'PatientProfile',
          targetEntityId: patient.id,
          metadata: { action: 'REGISTER' },
        });

        return { user, patientProfile: patient };
      }

      if (dto.role === UserRole.DOCTOR) {
        if (!dto.medicalLicenseNumber || !dto.specialty) {
          throw new BadRequestException(
            'Medical license number and clinical specialty are mandatory for doctor registration.',
          );
        }

        // Doctor accounts ALWAYS default to PENDING status
        const doctor = await tx.doctorProfile.create({
          data: {
            userId: user.id,
            licenseNumber: dto.medicalLicenseNumber,
            specialization: dto.specialty,
            hospitalAffiliation: dto.hospitalAffiliation || 'Unspecified Clinic / Hospital',
            clinicAddress: 'Cairo, Egypt',
            clinicPhoneNumber: dto.phoneNumber || '+20 2 0000 0000',
            approvalStatus: DoctorApprovalStatus.PENDING,
          },
        });

        await this.audit.logEvent({
          action: AuditAction.LOGIN,
          actorUserId: user.id,
          actorRole: UserRole.DOCTOR,
          targetEntity: 'DoctorProfile',
          targetEntityId: doctor.id,
          metadata: { license: dto.medicalLicenseNumber, specialty: dto.specialty, action: 'REGISTER_PENDING' },
        });

        return {
          user,
          doctorProfile: doctor,
          message:
            'Doctor registration submitted. Your account is pending review by Lumyra clinical administration.',
        };
      }

      return { user };
    });
  }

  async getMe(user: AuthenticatedUser) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return {
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        role: user.role,
        status: user.status,
        doctorStatus: user.doctorStatus,
        patientProfileId: user.patientProfileId,
        doctorProfileId: user.doctorProfileId,
      };
    }

    const dbUser = await this.prisma.user.findUnique({
      where: { id: user.id },
      include: {
        patientProfile: true,
        doctorProfile: true,
      },
    });

    return dbUser;
  }
}
