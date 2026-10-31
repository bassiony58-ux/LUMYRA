import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { DoctorApprovalStatus } from '../../../common/interfaces/authenticated-user.interface';

export class UpdateDoctorApprovalDto {
  @IsEnum(DoctorApprovalStatus)
  @IsNotEmpty()
  status: DoctorApprovalStatus;

  @IsString()
  @IsOptional()
  rejectionReason?: string;

  @IsString()
  @IsOptional()
  adminNotes?: string;
}
