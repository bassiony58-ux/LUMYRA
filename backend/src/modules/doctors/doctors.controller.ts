import {
  Controller,
  Get,
  Patch,
  Param,
  Body,
  Query,
  UseGuards,
} from '@nestjs/common';
import { DoctorsService } from './doctors.service';
import { UpdateDoctorApprovalDto } from './dto/update-doctor-approval.dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser, UserRole } from '../../common/interfaces/authenticated-user.interface';

@Controller('doctors')
@UseGuards(FirebaseAuthGuard, RolesGuard)
export class DoctorsController {
  constructor(private readonly doctorsService: DoctorsService) {}

  @Get('me/smart-alerts')
  @Roles(UserRole.DOCTOR, UserRole.ADMIN)
  async getSmartAlerts(@CurrentUser() doctorUser: AuthenticatedUser) {
    return this.doctorsService.getSmartAlerts(doctorUser);
  }

  @Get()
  async listApproved(@Query('specialty') specialty?: string) {
    return this.doctorsService.listApprovedDoctors(specialty);
  }

  @Get('pending')
  @Roles(UserRole.ADMIN)
  async listPending() {
    return this.doctorsService.listPendingDoctors();
  }

  @Get(':id')
  async getById(@Param('id') id: string) {
    return this.doctorsService.getDoctorById(id);
  }

  @Patch(':id/approval')
  @Roles(UserRole.ADMIN)
  async updateApproval(
    @Param('id') id: string,
    @Body() dto: UpdateDoctorApprovalDto,
    @CurrentUser() adminUser: AuthenticatedUser,
  ) {
    return this.doctorsService.updateDoctorApproval(id, dto, adminUser.id);
  }
}
