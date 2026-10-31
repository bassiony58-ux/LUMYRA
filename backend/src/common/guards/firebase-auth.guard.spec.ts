import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { FirebaseAuthGuard } from './firebase-auth.guard';
import { FirebaseAdminService } from '../../modules/auth/firebase-admin.service';
import { PrismaService } from '../prisma/prisma.service';

describe('FirebaseAuthGuard', () => {
  let guard: FirebaseAuthGuard;
  let mockFirebaseAdmin: Partial<FirebaseAdminService>;
  let mockPrisma: any;

  beforeEach(() => {
    process.env.ALLOW_MOCK_AUTH = 'true';
    process.env.SKIP_DB_CONNECT = 'true';

    mockFirebaseAdmin = {
      verifyIdToken: jest.fn(),
    };
    mockPrisma = {
      user: {
        findUnique: jest.fn(),
      },
    };

    guard = new FirebaseAuthGuard(
      mockFirebaseAdmin as FirebaseAdminService,
      mockPrisma as PrismaService,
    );
  });

  const createMockContext = (authHeader?: string): ExecutionContext => {
    const request: any = {
      headers: authHeader ? { authorization: authHeader } : {},
    };
    return {
      switchToHttp: () => ({
        getRequest: () => request,
      }),
    } as unknown as ExecutionContext;
  };

  it('should throw UnauthorizedException when Authorization header is missing', async () => {
    const context = createMockContext();
    await expect(guard.canActivate(context)).rejects.toThrow(UnauthorizedException);
  });

  it('should throw UnauthorizedException when Authorization header does not start with Bearer', async () => {
    const context = createMockContext('Basic 123456');
    await expect(guard.canActivate(context)).rejects.toThrow(UnauthorizedException);
  });

  it('should throw UnauthorizedException when Bearer token is empty', async () => {
    const context = createMockContext('Bearer ');
    await expect(guard.canActivate(context)).rejects.toThrow(UnauthorizedException);
  });

  it('should verify mock patient token and populate request.user', async () => {
    const context = createMockContext('Bearer mock-patient-token');
    const result = await guard.canActivate(context);

    expect(result).toBe(true);
    const req = context.switchToHttp().getRequest();
    expect(req.user).toBeDefined();
    expect(req.user.role).toBe('PATIENT');
    expect(req.user.email).toBe('mariam@lumyra.health');
  });

  it('should verify mock approved doctor token and populate request.user', async () => {
    const context = createMockContext('Bearer mock-doctor-approved-token');
    const result = await guard.canActivate(context);

    expect(result).toBe(true);
    const req = context.switchToHttp().getRequest();
    expect(req.user.role).toBe('DOCTOR');
    expect(req.user.doctorStatus).toBe('APPROVED');
  });

  it('should verify mock pending doctor token', async () => {
    const context = createMockContext('Bearer mock-doctor-pending-token');
    const result = await guard.canActivate(context);

    expect(result).toBe(true);
    const req = context.switchToHttp().getRequest();
    expect(req.user.role).toBe('DOCTOR');
    expect(req.user.doctorStatus).toBe('PENDING');
  });

  it('should verify mock admin token', async () => {
    const context = createMockContext('Bearer mock-admin-token');
    const result = await guard.canActivate(context);

    expect(result).toBe(true);
    const req = context.switchToHttp().getRequest();
    expect(req.user.role).toBe('ADMIN');
  });
});
