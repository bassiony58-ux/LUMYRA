import { IsEnum, IsNotEmpty, IsOptional, IsString, IsInt, IsDateString } from 'class-validator';
import { ScanCategory, ScanReviewStatus } from '@prisma/client';

export { ScanCategory, ScanReviewStatus };

export class RequestUploadGrantDto {
  @IsString()
  @IsNotEmpty()
  filename: string;

  @IsString()
  @IsNotEmpty()
  mimeType: string;
}

export class RegisterScanDto {
  @IsEnum(ScanCategory)
  @IsNotEmpty()
  category: ScanCategory;

  @IsString()
  @IsNotEmpty()
  originalFilename: string;

  @IsString()
  @IsNotEmpty()
  storageKey: string;

  @IsString()
  @IsNotEmpty()
  mimeType: string;

  @IsInt()
  @IsNotEmpty()
  fileSizeBytes: number;

  @IsDateString()
  @IsNotEmpty()
  scanDate: string;

  @IsString()
  @IsOptional()
  doctorNotes?: string;
}

export class CreateDoctorReviewDto {
  @IsString()
  @IsNotEmpty()
  physicianSignOffNotes: string;

  @IsString()
  @IsOptional()
  clinicalObservations?: string;
}

export class AnalyzeScanDto {
  @IsString()
  @IsOptional()
  fileName?: string;

  @IsString()
  @IsOptional()
  modelId?: string;

  @IsString()
  @IsOptional()
  role?: string;
}
