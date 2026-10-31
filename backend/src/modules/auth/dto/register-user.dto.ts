import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { UserRole } from '../../../common/interfaces/authenticated-user.interface';

export class RegisterUserDto {
  @IsEnum(UserRole, { message: 'Role must be PATIENT or DOCTOR' })
  @IsNotEmpty()
  role: UserRole;

  @IsString()
  @IsNotEmpty()
  fullName: string;

  @IsString()
  @IsOptional()
  phoneNumber?: string;

  @IsString()
  @IsOptional()
  preferredLanguage?: string = 'ar';

  // Doctor-specific onboarding fields
  @IsString()
  @IsOptional()
  medicalLicenseNumber?: string;

  @IsString()
  @IsOptional()
  specialty?: string;

  @IsString()
  @IsOptional()
  hospitalAffiliation?: string;
}
