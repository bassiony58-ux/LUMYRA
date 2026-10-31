import { UserRole, DoctorApprovalStatus, UserStatus } from '@prisma/client';

export { UserRole, DoctorApprovalStatus, UserStatus };

export interface AuthenticatedUser {
  id: string;
  firebaseUid: string;
  email: string;
  displayName: string;
  role: UserRole;
  status: UserStatus;
  isActive: boolean;
  doctorStatus?: DoctorApprovalStatus;
  patientProfileId?: string;
  doctorProfileId?: string;
}
