import { IsBoolean, IsNotEmpty, IsOptional, IsString, IsArray, IsDateString, IsEnum } from 'class-validator';

export enum AdherenceStatus {
  TAKEN = 'TAKEN',
  SKIPPED = 'SKIPPED',
  DELAYED = 'DELAYED',
}

export class CreateMedicationDto {
  @IsString()
  @IsNotEmpty()
  medicationName: string;

  @IsString()
  @IsNotEmpty()
  dosage: string;

  @IsString()
  @IsNotEmpty()
  unit: string;

  @IsString()
  @IsNotEmpty()
  frequency: string;

  @IsArray()
  @IsString({ each: true })
  timeOfDay: string[];

  @IsDateString()
  @IsNotEmpty()
  startDate: string;

  @IsDateString()
  @IsOptional()
  endDate?: string;

  @IsString()
  @IsOptional()
  instructions?: string;
}

export class LogAdherenceDto {
  @IsDateString()
  @IsNotEmpty()
  scheduledFor: string;

  @IsEnum(AdherenceStatus)
  @IsNotEmpty()
  status: AdherenceStatus;

  @IsString()
  @IsOptional()
  notes?: string;
}
