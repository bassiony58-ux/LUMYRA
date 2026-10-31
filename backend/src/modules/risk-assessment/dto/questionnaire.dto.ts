import { IsBoolean, IsInt, IsNotEmpty, IsObject, IsOptional, IsString } from 'class-validator';

export class SaveQuestionnaireDraftDto {
  @IsObject()
  @IsNotEmpty()
  answers: Record<string, any>;

  @IsInt()
  @IsNotEmpty()
  currentStep: number;
}

export class SubmitQuestionnaireDto {
  @IsObject()
  @IsNotEmpty()
  answers: Record<string, any>;

  @IsBoolean()
  @IsNotEmpty()
  patientConsentAcknowledged: boolean;

  @IsString()
  @IsOptional()
  notes?: string;
}

export class CorrectQuestionnaireDto {
  @IsString()
  @IsNotEmpty()
  previousRequestId: string;

  @IsObject()
  @IsNotEmpty()
  answers: Record<string, any>;

  @IsString()
  @IsNotEmpty()
  correctionReason: string;

  @IsBoolean()
  @IsNotEmpty()
  patientConsentAcknowledged: boolean;
}
