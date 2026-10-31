import { IsBoolean, IsOptional, IsString } from 'class-validator';

export class UpdatePatientConsentDto {
  @IsBoolean()
  @IsOptional()
  consentDataProcessing?: boolean;

  @IsBoolean()
  @IsOptional()
  consentDoctorSharing?: boolean;

  @IsBoolean()
  @IsOptional()
  consentAiAssistance?: boolean;
}

export class AssignDoctorDto {
  @IsString()
  doctorId: string;

  @IsString()
  @IsOptional()
  notes?: string;
}
