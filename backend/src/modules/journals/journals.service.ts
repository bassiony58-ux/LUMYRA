import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AccessControlService } from '../../common/services/access-control.service';
import { AuditService } from '../audit/audit.service';
import { AuthenticatedUser, UserRole } from '../../common/interfaces/authenticated-user.interface';
import { CreateJournalEntryDto, UpdateJournalEntryDto } from './dto/journal.dto';
import { AuditAction } from '@prisma/client';

@Injectable()
export class JournalsService {
  private readonly logger = new Logger(JournalsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly accessControl: AccessControlService,
    private readonly audit: AuditService,
  ) {}

  async listEntries(user: AuthenticatedUser, patientId?: string) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return [
        {
          id: 'mock-journal-1',
          patientId: user.patientProfileId || 'pat-mock-01',
          title: 'ملاحظات بعد الفحص الذاتي (Post Self-Exam Notes)',
          content: 'أجريت الفحص الذاتي الشهري اليوم. لم ألاحظ أي تكتلات جديدة أو تغيرات غير معتادة في ملمس الجلد.',
          symptoms: ['NO_ABNORMALITY'],
          entryDate: new Date().toISOString(),
          isSharedWithAssignedDoctor: true,
          createdAt: new Date().toISOString(),
        },
      ];
    }

    if (user.role === UserRole.PATIENT) {
      if (!user.patientProfileId) throw new ForbiddenException('Patient profile missing.');
      return this.prisma.journalEntry.findMany({
        where: { patientId: user.patientProfileId },
        orderBy: { entryDate: 'desc' },
      });
    }

    if (user.role === UserRole.DOCTOR) {
      if (!patientId) {
        throw new ForbiddenException('Patient ID parameter is required for doctor journal access.');
      }
      await this.accessControl.assertPatientAccess(user, patientId);

      // SECURITY RULE: Doctors can ONLY view entries explicitly marked as shared by the patient
      const entries = await this.prisma.journalEntry.findMany({
        where: {
          patientId,
          isSharedWithAssignedDoctor: true,
        },
        orderBy: { entryDate: 'desc' },
      });

      await this.audit.logEvent({
        action: AuditAction.VIEW_JOURNAL,
        actorUserId: user.id,
        actorRole: user.role,
        targetEntity: 'JournalEntry',
        targetEntityId: patientId,
        metadata: { count: entries.length },
      });

      return entries;
    }

    if (user.role === UserRole.ADMIN) {
      if (!patientId) return [];
      return this.prisma.journalEntry.findMany({
        where: { patientId },
        orderBy: { entryDate: 'desc' },
      });
    }

    return [];
  }

  async createEntry(user: AuthenticatedUser, dto: CreateJournalEntryDto) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can create private journal entries.');
    }

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return {
        id: `mock-journal-${Date.now()}`,
        patientId: user.patientProfileId,
        content: dto.content,
        mood: dto.mood || 'neutral',
        symptoms: dto.symptoms || [],
        isSharedWithAssignedDoctor: dto.isSharedWithDoctor ?? false,
        entryDate: new Date(),
        createdAt: new Date(),
      };
    }

    return this.prisma.journalEntry.create({
      data: {
        patientId: user.patientProfileId,
        content: dto.content,
        mood: dto.mood || 'neutral',
        symptoms: dto.symptoms || [],
        isSharedWithAssignedDoctor: dto.isSharedWithDoctor ?? false,
      },
    });
  }

  async updateEntry(id: string, user: AuthenticatedUser, dto: UpdateJournalEntryDto) {
    const entry = await this.prisma.journalEntry.findUnique({ where: { id } });
    if (!entry) throw new NotFoundException(`Journal entry ${id} not found.`);

    if (user.role !== UserRole.PATIENT || entry.patientId !== user.patientProfileId) {
      throw new ForbiddenException('You can only update your own journal entries.');
    }

    return this.prisma.journalEntry.update({
      where: { id },
      data: {
        content: dto.content,
        mood: dto.mood,
        symptoms: dto.symptoms,
        isSharedWithAssignedDoctor: dto.isSharedWithDoctor,
      },
    });
  }

  async deleteEntry(id: string, user: AuthenticatedUser) {
    const entry = await this.prisma.journalEntry.findUnique({ where: { id } });
    if (!entry) throw new NotFoundException(`Journal entry ${id} not found.`);

    if (user.role !== UserRole.PATIENT || entry.patientId !== user.patientProfileId) {
      throw new ForbiddenException('You can only delete your own journal entries.');
    }

    return this.prisma.journalEntry.delete({ where: { id } });
  }
}
