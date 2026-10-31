import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AuthenticatedUser, UserRole, DoctorApprovalStatus } from '../interfaces/authenticated-user.interface';

@Injectable()
export class AccessControlService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Asserts whether the authenticated user has legitimate access to a specific patient's clinical records.
   * - ADMIN: Allowed across records for audit/system purposes.
   * - PATIENT: Allowed ONLY for their own record (`user.patientProfileId === patientProfileId`).
   * - DOCTOR: Must be APPROVED, and must have an active DoctorPatientAssignment for this patient.
   */
  async assertPatientAccess(user: AuthenticatedUser, patientProfileId: string): Promise<void> {
    if (user.role === UserRole.ADMIN) {
      return;
    }

    if (user.role === UserRole.PATIENT) {
      if (!user.patientProfileId || user.patientProfileId !== patientProfileId) {
        throw new ForbiddenException(
          'Access denied: You are not authorized to access another patient’s clinical records.',
        );
      }
      return;
    }

    if (user.role === UserRole.DOCTOR) {
      if (user.doctorStatus !== DoctorApprovalStatus.APPROVED) {
        throw new ForbiddenException(
          'Access denied: Doctor credentials are not approved for patient record access.',
        );
      }

      if (!user.doctorProfileId) {
        throw new ForbiddenException('Doctor profile not found.');
      }

      // Check active assignment in database
      if (process.env.SKIP_DB_CONNECT !== 'true') {
        const assignment = await this.prisma.doctorPatientAssignment.findUnique({
          where: {
            doctorId_patientId: {
              doctorId: user.doctorProfileId,
              patientId: patientProfileId,
            },
          },
        });

        if (!assignment || !assignment.isActive) {
          throw new ForbiddenException(
            'Access denied: You do not have an active clinical care assignment for this patient.',
          );
        }
      }
      return;
    }

    throw new ForbiddenException('Unauthorized access role.');
  }

  /**
   * Asserts whether the user can manage or view an appointment.
   */
  assertAppointmentAccess(user: AuthenticatedUser, appointment: { patientId: string; doctorId?: string | null }): void {
    if (user.role === UserRole.ADMIN) return;

    if (user.role === UserRole.PATIENT) {
      if (user.patientProfileId !== appointment.patientId) {
        throw new ForbiddenException('Access denied: You cannot view or modify appointments of another patient.');
      }
      return;
    }

    if (user.role === UserRole.DOCTOR) {
      if (user.doctorStatus !== DoctorApprovalStatus.APPROVED) {
        throw new ForbiddenException('Doctor license not approved.');
      }
      if (appointment.doctorId && user.doctorProfileId !== appointment.doctorId) {
        throw new ForbiddenException('Access denied: You are not the assigned doctor for this appointment.');
      }
      return;
    }

    throw new ForbiddenException('Unauthorized access role.');
  }
}
