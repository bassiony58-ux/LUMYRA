import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { AccessControlService } from '../../common/services/access-control.service';
import { AuthenticatedUser, UserRole, DoctorApprovalStatus } from '../../common/interfaces/authenticated-user.interface';
import { CreateAppointmentDto, UpdateAppointmentStatusDto, AppointmentStatus } from './dto/appointment.dto';
import { AuditAction } from '@prisma/client';

@Injectable()
export class AppointmentsService {
  private readonly logger = new Logger(AppointmentsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly accessControl: AccessControlService,
  ) {}

  async listMyAppointments(user: AuthenticatedUser) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return [
        {
          id: 'mock-appt-1',
          patientId: user.patientProfileId || 'pat-mock-01',
          doctorId: 'doc-mock-01',
          doctor: {
            user: { displayName: 'د. نور الخالدي (Dr. Nour Al-Khalidi)', email: 'dr.nour@lumyra.health' },
          },
          patient: {
            user: { displayName: user.displayName || 'مريم أحمد (Mariam Ahmed)', email: user.email },
          },
          scheduledAt: new Date(Date.now() + 86400000 * 2).toISOString(),
          estimatedDurationMinutes: 30,
          reason: 'استشارة متابعة روتينية وفحص سنوي (Annual Follow-up)',
          clinicalNotes: null,
          status: 'CONFIRMED',
          statusHistory: [
            {
              id: 'log-1',
              fromStatus: 'SCHEDULED',
              toStatus: 'CONFIRMED',
              changedAt: new Date().toISOString(),
              changeReason: 'Confirmed by clinic coordinator',
            },
          ],
        },
      ];
    }

    if (user.role === UserRole.PATIENT) {
      if (!user.patientProfileId) throw new BadRequestException('Patient profile missing');
      return this.prisma.appointment.findMany({
        where: { patientId: user.patientProfileId },
        include: {
          doctor: {
            include: {
              user: { select: { displayName: true, email: true } },
            },
          },
          statusHistory: { orderBy: { changedAt: 'desc' } },
        },
        orderBy: { scheduledAt: 'desc' },
      });
    }

    if (user.role === UserRole.DOCTOR) {
      if (user.doctorStatus !== DoctorApprovalStatus.APPROVED) {
        throw new ForbiddenException('Doctor license not approved.');
      }
      if (!user.doctorProfileId) throw new BadRequestException('Doctor profile missing');
      return this.prisma.appointment.findMany({
        where: { doctorId: user.doctorProfileId },
        include: {
          patient: {
            include: {
              user: { select: { displayName: true, email: true, phoneNumber: true, preferredLanguage: true } },
            },
          },
          statusHistory: { orderBy: { changedAt: 'desc' } },
        },
        orderBy: { scheduledAt: 'asc' },
      });
    }

    if (user.role === UserRole.ADMIN) {
      return this.prisma.appointment.findMany({
        include: {
          patient: {
            include: {
              user: { select: { displayName: true, email: true } },
            },
          },
          doctor: {
            include: {
              user: { select: { displayName: true, email: true } },
            },
          },
        },
        orderBy: { scheduledAt: 'desc' },
        take: 100,
      });
    }

    return [];
  }

  async createAppointment(user: AuthenticatedUser, dto: CreateAppointmentDto) {
    if (user.role !== UserRole.PATIENT || !user.patientProfileId) {
      throw new ForbiddenException('Only patients can book clinical appointments.');
    }

    if (process.env.SKIP_DB_CONNECT === 'true') {
      return {
        id: `mock-appt-${Date.now()}`,
        patientId: user.patientProfileId,
        doctorId: dto.doctorId,
        scheduledAt: new Date(dto.scheduledAt),
        estimatedDurationMinutes: dto.estimatedDurationMinutes || 30,
        reason: dto.reason,
        clinicalNotes: dto.clinicalNotes || null,
        status: AppointmentStatus.SCHEDULED,
      };
    }

    const scheduledDate = new Date(dto.scheduledAt);
    if (isNaN(scheduledDate.getTime()) || scheduledDate.getTime() < Date.now()) {
      throw new BadRequestException('Scheduled date must be a valid future timestamp.');
    }

    // Verify doctor exists and is approved
    const doctor = await this.prisma.doctorProfile.findUnique({
      where: { id: dto.doctorId },
    });
    if (!doctor || doctor.approvalStatus !== DoctorApprovalStatus.APPROVED) {
      throw new BadRequestException('Target doctor does not exist or is not approved.');
    }

    return this.prisma.$transaction(async (tx) => {
      const appointment = await tx.appointment.create({
        data: {
          patientId: user.patientProfileId!,
          doctorId: dto.doctorId,
          scheduledAt: scheduledDate,
          estimatedDurationMinutes: dto.estimatedDurationMinutes || 30,
          reason: dto.reason,
          clinicalNotes: dto.clinicalNotes || null,
          status: AppointmentStatus.SCHEDULED,
        },
      });

      await tx.appointmentStatusLog.create({
        data: {
          appointmentId: appointment.id,
          fromStatus: AppointmentStatus.SCHEDULED,
          toStatus: AppointmentStatus.SCHEDULED,
          changedById: user.id,
          changeReason: 'Initial appointment booking',
        },
      });

      await this.audit.logEvent({
        action: AuditAction.CREATE_APPOINTMENT,
        actorUserId: user.id,
        actorRole: user.role,
        targetEntity: 'Appointment',
        targetEntityId: appointment.id,
        metadata: { scheduledAt: dto.scheduledAt, doctorId: dto.doctorId },
      });

      return appointment;
    });
  }

  async updateStatus(id: string, user: AuthenticatedUser, dto: UpdateAppointmentStatusDto) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return {
        id,
        status: dto.status,
        changeReason: dto.reason || 'Status updated',
      };
    }

    const appointment = await this.prisma.appointment.findUnique({
      where: { id },
    });

    if (!appointment) {
      throw new NotFoundException(`Appointment ${id} not found.`);
    }

    this.accessControl.assertAppointmentAccess(user, {
      patientId: appointment.patientId,
      doctorId: appointment.doctorId,
    });

    const fromStatus = appointment.status;

    const updated = await this.prisma.$transaction(async (tx) => {
      const appt = await tx.appointment.update({
        where: { id },
        data: { status: dto.status },
      });

      await tx.appointmentStatusLog.create({
        data: {
          appointmentId: id,
          fromStatus,
          toStatus: dto.status,
          changedById: user.id,
          changeReason: dto.reason || null,
        },
      });

      return appt;
    });

    await this.audit.logEvent({
      action: AuditAction.CREATE_APPOINTMENT,
      actorUserId: user.id,
      actorRole: user.role,
      targetEntity: 'Appointment',
      targetEntityId: id,
      metadata: { fromStatus, toStatus: dto.status, reason: dto.reason },
    });

    return updated;
  }
}
