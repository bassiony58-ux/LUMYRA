import { ForbiddenException } from '@nestjs/common';
import { AccessControlService } from './access-control.service';
import { PrismaService } from '../prisma/prisma.service';
import { AuthenticatedUser, UserRole, DoctorApprovalStatus, UserStatus } from '../interfaces/authenticated-user.interface';

describe('AccessControlService', () => {
  let service: AccessControlService;
  let mockPrisma: any;

  beforeEach(() => {
    mockPrisma = {
      doctorPatientAssignment: {
        findUnique: jest.fn(),
      },
    };
    service = new AccessControlService(mockPrisma as PrismaService);
  });

  const patientA: AuthenticatedUser = {
    id: 'user-pat-a',
    firebaseUid: 'uid-pat-a',
    email: 'pat.a@lumyra.health',
    displayName: 'Patient A',
    role: UserRole.PATIENT,
    status: UserStatus.ACTIVE,
    isActive: true,
    patientProfileId: 'profile-pat-a',
  };

  const approvedDoctor: AuthenticatedUser = {
    id: 'user-doc-1',
    firebaseUid: 'uid-doc-1',
    email: 'doc.1@lumyra.health',
    displayName: 'Dr. Nour',
    role: UserRole.DOCTOR,
    status: UserStatus.ACTIVE,
    isActive: true,
    doctorStatus: DoctorApprovalStatus.APPROVED,
    doctorProfileId: 'doc-profile-1',
  };

  const pendingDoctor: AuthenticatedUser = {
    id: 'user-doc-pending',
    firebaseUid: 'uid-doc-pending',
    email: 'doc.pending@lumyra.health',
    displayName: 'Dr. Pending',
    role: UserRole.DOCTOR,
    status: UserStatus.ACTIVE,
    isActive: true,
    doctorStatus: DoctorApprovalStatus.PENDING,
    doctorProfileId: 'doc-profile-pending',
  };

  const admin: AuthenticatedUser = {
    id: 'user-admin',
    firebaseUid: 'uid-admin',
    email: 'admin@lumyra.health',
    displayName: 'Admin User',
    role: UserRole.ADMIN,
    status: UserStatus.ACTIVE,
    isActive: true,
  };

  describe('assertPatientAccess', () => {
    it('should allow a patient to access their own clinical records', async () => {
      await expect(
        service.assertPatientAccess(patientA, 'profile-pat-a'),
      ).resolves.toBeUndefined();
    });

    it('should throw ForbiddenException when a patient attempts to access another patient records', async () => {
      await expect(
        service.assertPatientAccess(patientA, 'profile-pat-b-other'),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw ForbiddenException when an unapproved doctor attempts access', async () => {
      await expect(
        service.assertPatientAccess(pendingDoctor, 'profile-pat-a'),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw ForbiddenException when an approved doctor has no active care assignment', async () => {
      process.env.SKIP_DB_CONNECT = 'false';
      mockPrisma.doctorPatientAssignment.findUnique.mockResolvedValue(null);

      await expect(
        service.assertPatientAccess(approvedDoctor, 'profile-pat-a'),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should allow access when an approved doctor has an active care assignment', async () => {
      process.env.SKIP_DB_CONNECT = 'false';
      mockPrisma.doctorPatientAssignment.findUnique.mockResolvedValue({
        isActive: true,
      });

      await expect(
        service.assertPatientAccess(approvedDoctor, 'profile-pat-a'),
      ).resolves.toBeUndefined();
    });

    it('should allow admin unconditional access', async () => {
      await expect(
        service.assertPatientAccess(admin, 'profile-pat-a'),
      ).resolves.toBeUndefined();
    });
  });

  describe('assertAppointmentAccess', () => {
    it('should allow patient to access their own appointment', () => {
      expect(() =>
        service.assertAppointmentAccess(patientA, { patientId: 'profile-pat-a' }),
      ).not.toThrow();
    });

    it('should forbid patient from accessing another patient appointment', () => {
      expect(() =>
        service.assertAppointmentAccess(patientA, { patientId: 'profile-pat-other' }),
      ).toThrow(ForbiddenException);
    });

    it('should allow assigned approved doctor to access appointment', () => {
      expect(() =>
        service.assertAppointmentAccess(approvedDoctor, {
          patientId: 'profile-pat-a',
          doctorId: 'doc-profile-1',
        }),
      ).not.toThrow();
    });

    it('should forbid non-assigned doctor from modifying appointment', () => {
      expect(() =>
        service.assertAppointmentAccess(approvedDoctor, {
          patientId: 'profile-pat-a',
          doctorId: 'doc-profile-other-doctor',
        }),
      ).toThrow(ForbiddenException);
    });
  });
});
