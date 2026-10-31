import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { FirebaseAdminService } from '../../modules/auth/firebase-admin.service';
import { PrismaService } from '../prisma/prisma.service';
import { AuthenticatedUser, UserRole, DoctorApprovalStatus, UserStatus } from '../interfaces/authenticated-user.interface';

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  private readonly logger = new Logger(FirebaseAuthGuard.name);

  constructor(
    private readonly firebaseAdmin: FirebaseAdminService,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authHeader = request.headers['authorization'];

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing or invalid Authorization header. Expected Bearer token.');
    }

    const token = authHeader.substring(7).trim();
    if (!token) {
      throw new UnauthorizedException('Bearer token is empty.');
    }

    let firebaseUid: string | null = null;
    let email: string | null = null;

    if (process.env.ALLOW_MOCK_AUTH === 'true' && token.startsWith('mock-')) {
      const mockResult = this.parseMockToken(token);
      firebaseUid = mockResult.firebaseUid;
      email = mockResult.email;
    } else {
      const decodedToken = await this.firebaseAdmin.verifyIdToken(token);
      if (!decodedToken) {
        throw new UnauthorizedException('Invalid or expired Firebase ID token.');
      }
      firebaseUid = decodedToken.uid;
      email = decodedToken.email || null;
    }

    if (!firebaseUid) {
      throw new UnauthorizedException('Authentication token could not be verified.');
    }

    let user: any = null;
    try {
      user = await this.prisma.user.findUnique({
        where: { firebaseUid },
        include: {
          patientProfile: { select: { id: true } },
          doctorProfile: { select: { id: true, approvalStatus: true } },
        },
      });
    } catch (e: any) {
      if (process.env.SKIP_DB_CONNECT === 'true') {
        user = this.buildMockUserFromToken(token, firebaseUid, email);
      } else {
        throw e;
      }
    }

    if (!user) {
      if (process.env.SKIP_DB_CONNECT === 'true') {
        user = this.buildMockUserFromToken(token, firebaseUid, email);
      } else {
        throw new UnauthorizedException(`User not registered in Lumyra data layer for UID ${firebaseUid}. Complete onboarding first.`);
      }
    }

    if (user.status === UserStatus.SUSPENDED || user.status === UserStatus.INACTIVE) {
      throw new UnauthorizedException('User account has been deactivated or suspended. Contact support.');
    }

    const authUser: AuthenticatedUser = {
      id: user.id,
      firebaseUid: user.firebaseUid,
      email: user.email,
      displayName: user.displayName,
      role: user.role as UserRole,
      status: user.status as UserStatus,
      isActive: user.status === UserStatus.ACTIVE,
      doctorStatus: user.doctorProfile?.approvalStatus as DoctorApprovalStatus,
      patientProfileId: user.patientProfile?.id,
      doctorProfileId: user.doctorProfile?.id,
    };

    request.user = authUser;
    return true;
  }

  private parseMockToken(token: string): { firebaseUid: string; email: string } {
    switch (token) {
      case 'mock-admin-token':
        return { firebaseUid: 'firebase-admin-001', email: 'admin@lumyra.health' };
      case 'mock-doctor-approved-token':
      case 'mock-doctor-token':
        return { firebaseUid: 'firebase-dr-nour-001', email: 'dr.nour@lumyra.health' };
      case 'mock-doctor-pending-token':
        return { firebaseUid: 'firebase-dr-pending-001', email: 'dr.pending@lumyra.health' };
      case 'mock-patient-token':
      case 'mock-patient-1-token':
        return { firebaseUid: 'firebase-patient-001', email: 'mariam@lumyra.health' };
      case 'mock-patient-2-token':
        return { firebaseUid: 'firebase-patient-002', email: 'fatima@lumyra.health' };
      default:
        const parts = token.split(':');
        return {
          firebaseUid: parts[0] || 'mock-user-default',
          email: parts[2] || `${parts[0]}@example.com`,
        };
    }
  }

  private buildMockUserFromToken(token: string, uid: string, email: string | null): any {
    if (token.includes('admin')) {
      return {
        id: 'user-admin-001',
        firebaseUid: uid,
        email: email || 'admin@lumyra.health',
        displayName: 'System Administrator',
        role: UserRole.ADMIN,
        status: UserStatus.ACTIVE,
      };
    }
    if (token.includes('doctor-pending')) {
      return {
        id: 'user-dr-pending',
        firebaseUid: uid,
        email: email || 'dr.pending@lumyra.health',
        displayName: 'Dr. Pending Verification',
        role: UserRole.DOCTOR,
        status: UserStatus.ACTIVE,
        doctorProfile: { id: 'doc-pending-id', approvalStatus: DoctorApprovalStatus.PENDING },
      };
    }
    if (token.includes('doctor')) {
      return {
        id: 'user-dr-nour',
        firebaseUid: uid,
        email: email || 'dr.nour@lumyra.health',
        displayName: 'Dr. Nour El-Din',
        role: UserRole.DOCTOR,
        status: UserStatus.ACTIVE,
        doctorProfile: { id: 'doc-nour-id', approvalStatus: DoctorApprovalStatus.APPROVED },
      };
    }
    if (token.includes('patient-2')) {
      return {
        id: 'user-patient-002',
        firebaseUid: uid,
        email: email || 'fatima@lumyra.health',
        displayName: 'Fatima Hassan',
        role: UserRole.PATIENT,
        status: UserStatus.ACTIVE,
        patientProfile: { id: 'pat-fatima-id' },
      };
    }
    return {
      id: 'user-patient-001',
      firebaseUid: uid,
      email: email || 'mariam@lumyra.health',
      displayName: 'Mariam Ali',
      role: UserRole.PATIENT,
      status: UserStatus.ACTIVE,
      patientProfile: { id: 'pat-mariam-id' },
    };
  }
}
