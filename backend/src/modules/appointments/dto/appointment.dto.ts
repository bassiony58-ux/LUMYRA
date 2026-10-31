import { IsEnum, IsNotEmpty, IsOptional, IsString, IsDateString, IsInt } from 'class-validator';
import { AppointmentStatus } from '@prisma/client';

export { AppointmentStatus };

export class CreateAppointmentDto {
  @IsString()
  @IsNotEmpty()
  doctorId: string;

  @IsDateString()
  @IsNotEmpty()
  scheduledAt: string;

  @IsInt()
  @IsOptional()
  estimatedDurationMinutes?: number = 30;

  @IsString()
  @IsNotEmpty()
  reason: string;

  @IsString()
  @IsOptional()
  clinicalNotes?: string;
}

export class UpdateAppointmentStatusDto {
  @IsEnum(AppointmentStatus)
  @IsNotEmpty()
  status: AppointmentStatus;

  @IsString()
  @IsOptional()
  reason?: string;
}
