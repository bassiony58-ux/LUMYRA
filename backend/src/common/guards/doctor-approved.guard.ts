import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { UserRole, DoctorApprovalStatus, AuthenticatedUser } from '../interfaces/authenticated-user.interface';

@Injectable()
export class DoctorApprovedGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user: AuthenticatedUser = request.user;

    if (!user) {
      throw new ForbiddenException('User context missing.');
    }

    // Admins bypass doctor-approval check
    if (user.role === UserRole.ADMIN) {
      return true;
    }

    if (user.role === UserRole.DOCTOR) {
      if (user.doctorStatus !== DoctorApprovalStatus.APPROVED) {
        throw new ForbiddenException(
          `Doctor access restricted. Your medical verification status is currently '${user.doctorStatus || 'PENDING'}'. You cannot access patient clinical records until an administrator approves your license.`,
        );
      }
    }

    return true;
  }
}
