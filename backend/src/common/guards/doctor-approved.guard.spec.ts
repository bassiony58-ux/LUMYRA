import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { DoctorApprovedGuard } from './doctor-approved.guard';
import { UserRole, DoctorApprovalStatus, UserStatus } from '../interfaces/authenticated-user.interface';

describe('DoctorApprovedGuard', () => {
  let guard: DoctorApprovedGuard;

  beforeEach(() => {
    guard = new DoctorApprovedGuard();
  });

  const createMockContext = (user?: any): ExecutionContext => {
    const request: any = { user };
    return {
      switchToHttp: () => ({
        getRequest: () => request,
      }),
    } as unknown as ExecutionContext;
  };

  it('should allow access to ADMIN unconditionally', () => {
    const context = createMockContext({ role: UserRole.ADMIN, status: UserStatus.ACTIVE });
    expect(guard.canActivate(context)).toBe(true);
  });

  it('should allow access to non-doctor users (e.g. PATIENT)', () => {
    const context = createMockContext({ role: UserRole.PATIENT, status: UserStatus.ACTIVE });
    expect(guard.canActivate(context)).toBe(true);
  });

  it('should allow access to an APPROVED doctor', () => {
    const context = createMockContext({
      role: UserRole.DOCTOR,
      doctorStatus: DoctorApprovalStatus.APPROVED,
      status: UserStatus.ACTIVE,
    });
    expect(guard.canActivate(context)).toBe(true);
  });

  it('should throw ForbiddenException for a PENDING doctor', () => {
    const context = createMockContext({
      role: UserRole.DOCTOR,
      doctorStatus: DoctorApprovalStatus.PENDING,
      status: UserStatus.ACTIVE,
    });
    expect(() => guard.canActivate(context)).toThrow(ForbiddenException);
    expect(() => guard.canActivate(context)).toThrow(/administrator approves your license/);
  });

  it('should throw ForbiddenException for a REJECTED doctor', () => {
    const context = createMockContext({
      role: UserRole.DOCTOR,
      doctorStatus: DoctorApprovalStatus.REJECTED,
      status: UserStatus.ACTIVE,
    });
    expect(() => guard.canActivate(context)).toThrow(ForbiddenException);
  });
});
