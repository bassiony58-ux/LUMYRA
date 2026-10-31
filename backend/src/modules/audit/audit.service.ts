import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuditAction, AuditStatus, UserRole } from '@prisma/client';

export interface RecordAuditParams {
  action: AuditAction;
  actorUserId?: string;
  actorRole?: UserRole;
  targetEntity: string;
  targetEntityId: string;
  status?: AuditStatus;
  ipAddress?: string;
  userAgent?: string;
  metadata?: Record<string, any>;
}

@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);

  constructor(private readonly prisma: PrismaService) {}

  async logEvent(params: RecordAuditParams): Promise<void> {
    try {
      this.logger.log(
        `[AUDIT] Action: ${params.action} | Actor: ${params.actorUserId || 'system'} (${params.actorRole || 'SYSTEM'}) | Target: ${params.targetEntity}:${params.targetEntityId}`,
      );

      if (process.env.SKIP_DB_CONNECT !== 'true') {
        await this.prisma.auditEvent.create({
          data: {
            action: params.action,
            actorUserId: params.actorUserId || null,
            actorRole: params.actorRole || UserRole.ADMIN,
            targetEntity: params.targetEntity,
            targetEntityId: params.targetEntityId,
            status: params.status || AuditStatus.SUCCESS,
            ipAddress: params.ipAddress || '127.0.0.1',
            userAgent: params.userAgent || 'internal/api',
            metadata: params.metadata || {},
          },
        });
      }
    } catch (err: any) {
      this.logger.error(`Failed to record audit event: ${err.message}`, err.stack);
    }
  }
}
