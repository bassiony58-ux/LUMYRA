import { Injectable, NotFoundException, ForbiddenException, Logger } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { AuthenticatedUser, UserRole, UserStatus } from '../../common/interfaces/authenticated-user.interface';
import { AuditAction } from '@prisma/client';

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
  ) {}

  async findAll() {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return [
        {
          id: 'usr-pat-01',
          firebaseUid: 'uid-pat-01',
          email: 'sarah.ahmed@example.com',
          displayName: 'سارة أحمد محمد',
          role: UserRole.PATIENT,
          status: UserStatus.ACTIVE,
          createdAt: new Date(Date.now() - 30 * 86400000).toISOString(),
          patientProfile: { id: 'pat-01' },
          doctorProfile: null,
        },
        {
          id: 'usr-pat-02',
          firebaseUid: 'uid-pat-02',
          email: 'mariam.ali@example.com',
          displayName: 'مريم علي حسن',
          role: UserRole.PATIENT,
          status: UserStatus.ACTIVE,
          createdAt: new Date(Date.now() - 15 * 86400000).toISOString(),
          patientProfile: { id: 'pat-02' },
          doctorProfile: null,
        },
        {
          id: 'usr-doc-01',
          firebaseUid: 'uid-doc-01',
          email: 'dr.nour@lumyra.health',
          displayName: 'د. نور الخالدي',
          role: UserRole.DOCTOR,
          status: UserStatus.ACTIVE,
          createdAt: new Date(Date.now() - 60 * 86400000).toISOString(),
          patientProfile: null,
          doctorProfile: { id: 'doc-01', approvalStatus: 'APPROVED' },
        },
        {
          id: 'usr-doc-02',
          firebaseUid: 'uid-doc-02',
          email: 'dr.pending@lumyra.health',
          displayName: 'د. سارة المنشاوي',
          role: UserRole.DOCTOR,
          status: UserStatus.PENDING_APPROVAL,
          createdAt: new Date(Date.now() - 2 * 86400000).toISOString(),
          patientProfile: null,
          doctorProfile: { id: 'doc-02', approvalStatus: 'PENDING' },
        },
        {
          id: 'usr-adm-01',
          firebaseUid: 'uid-adm-01',
          email: 'admin@lumyra.health',
          displayName: 'مدير المنظمة الطبية',
          role: UserRole.ADMIN,
          status: UserStatus.ACTIVE,
          createdAt: new Date(Date.now() - 90 * 86400000).toISOString(),
          patientProfile: null,
          doctorProfile: null,
        },
      ];
    }

    return this.prisma.user.findMany({
      select: {
        id: true,
        firebaseUid: true,
        email: true,
        displayName: true,
        role: true,
        status: true,
        createdAt: true,
        patientProfile: { select: { id: true } },
        doctorProfile: { select: { id: true, approvalStatus: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string, currentUser: AuthenticatedUser) {
    if (currentUser.role !== UserRole.ADMIN && currentUser.id !== id) {
      throw new ForbiddenException('You can only view your own user account.');
    }

    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        patientProfile: true,
        doctorProfile: true,
      },
    });

    if (!user) {
      throw new NotFoundException(`User ${id} not found.`);
    }

    return user;
  }

  async updateUserActiveStatus(id: string, isActive: boolean, adminUser: AuthenticatedUser) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return { id, status: isActive ? UserStatus.ACTIVE : UserStatus.INACTIVE, updated: true };
    }

    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User ${id} not found.`);
    }

    const newStatus = isActive ? UserStatus.ACTIVE : UserStatus.INACTIVE;

    const updated = await this.prisma.user.update({
      where: { id },
      data: { status: newStatus },
    });

    await this.audit.logEvent({
      action: AuditAction.LOGIN,
      actorUserId: adminUser.id,
      actorRole: UserRole.ADMIN,
      targetEntity: 'User',
      targetEntityId: id,
      metadata: { action: 'UPDATE_USER_STATUS', newStatus },
    });

    return updated;
  }
}
