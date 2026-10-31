import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { AuthenticatedUser, UserRole } from '../../common/interfaces/authenticated-user.interface';
import { CreateMedicationDto, LogAdherenceDto } from './dto/medication.dto';
import { MedicationFrequency, AuditAction } from '@prisma/client';

@Injectable()
export class MedicationsService {
  private readonly logger = new Logger(MedicationsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
  ) {}

  async listMyMedications(user: AuthenticatedUser) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can access their medication schedule.');
    }

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return [
        {
          id: 'mock-med-1',
          patientId: user.patientProfileId,
          name: 'Tamoxifen (تاموكسيفين)',
          dosage: '20 mg',
          instructions: 'Take one tablet daily with water after breakfast',
          frequency: MedicationFrequency.ONCE_DAILY,
          timeOfDay: ['09:00'],
          startDate: '2026-01-01T00:00:00.000Z',
          endDate: null,
          isActive: true,
          adherenceLogs: [
            {
              id: 'adh-1',
              scheduledTime: new Date().toISOString(),
              takenAt: new Date().toISOString(),
              status: 'TAKEN',
            },
          ],
        },
      ];
    }

    return this.prisma.medicationSchedule.findMany({
      where: { patientId: user.patientProfileId },
      include: {
        adherenceLogs: {
          orderBy: { scheduledTime: 'desc' },
          take: 7,
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createMedication(user: AuthenticatedUser, dto: CreateMedicationDto) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can add medications.');
    }

    let freq: MedicationFrequency = MedicationFrequency.ONCE_DAILY;
    if (dto.frequency === 'TWICE_DAILY') freq = MedicationFrequency.TWICE_DAILY;
    else if (dto.frequency === 'THREE_TIMES_DAILY') freq = MedicationFrequency.THREE_TIMES_DAILY;
    else if (dto.frequency === 'AS_NEEDED') freq = MedicationFrequency.AS_NEEDED;

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return {
        id: `mock-med-${Date.now()}`,
        patientId: user.patientProfileId,
        name: dto.medicationName,
        dosage: `${dto.dosage} ${dto.unit}`.trim(),
        instructions: dto.instructions || 'Take as directed',
        frequency: freq,
        timeOfDay: dto.timeOfDay,
        startDate: new Date(dto.startDate),
        endDate: dto.endDate ? new Date(dto.endDate) : null,
        isActive: true,
      };
    }

    const med = await this.prisma.medicationSchedule.create({
      data: {
        patientId: user.patientProfileId,
        name: dto.medicationName,
        dosage: `${dto.dosage} ${dto.unit}`.trim(),
        instructions: dto.instructions || 'Take as directed',
        frequency: freq,
        timeOfDay: dto.timeOfDay,
        startDate: new Date(dto.startDate),
        endDate: dto.endDate ? new Date(dto.endDate) : null,
        isActive: true,
      },
    });

    await this.audit.logEvent({
      action: AuditAction.UPDATE_MEDICATION,
      actorUserId: user.id,
      actorRole: user.role,
      targetEntity: 'MedicationSchedule',
      targetEntityId: med.id,
      metadata: { action: 'CREATE', name: dto.medicationName },
    });

    return med;
  }

  async logAdherence(scheduleId: string, user: AuthenticatedUser, dto: LogAdherenceDto) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can log adherence.');
    }

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return {
        id: `mock-adh-${Date.now()}`,
        medicationScheduleId: scheduleId,
        scheduledTime: new Date(dto.scheduledFor),
        takenAt: new Date(),
        status: dto.status,
      };
    }

    const schedule = await this.prisma.medicationSchedule.findUnique({
      where: { id: scheduleId },
    });

    if (!schedule) {
      throw new NotFoundException(`Medication schedule ${scheduleId} not found.`);
    }

    if (schedule.patientId !== user.patientProfileId) {
      throw new ForbiddenException('You cannot log adherence for another patient.');
    }

    const wasTaken = dto.status === 'TAKEN';

    const log = await this.prisma.medicationAdherenceLog.create({
      data: {
        medicationScheduleId: scheduleId,
        scheduledTime: new Date(dto.scheduledFor),
        takenAt: wasTaken ? new Date() : new Date(dto.scheduledFor),
        wasTaken,
        notes: dto.notes || null,
      },
    });

    return log;
  }
}
