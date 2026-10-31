import { IsBoolean, IsNotEmpty, IsOptional, IsString, IsInt } from 'class-validator';

export class SubmitRiskAssessmentDto {
  @IsInt()
  @IsNotEmpty()
  age: number;

  @IsInt()
  @IsOptional()
  ageAtMenarche?: number;

  @IsInt()
  @IsOptional()
  ageAtFirstLiveBirth?: number;

  @IsBoolean()
  @IsOptional()
  familyHistoryBreastCancer?: boolean;

  @IsInt()
  @IsOptional()
  firstDegreeRelativesCount?: number;

  @IsBoolean()
  @IsOptional()
  personalBreastBiopsy?: boolean;

  @IsString()
  @IsOptional()
  notes?: string;
}
