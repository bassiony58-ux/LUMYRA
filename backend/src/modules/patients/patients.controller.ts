import {
  Controller,
  Get,
  Patch,
  Post,
  Delete,
  Param,
  Body,
  UseGuards,
} from '@nestjs/common';
import { PatientsService } from './patients.service';
import { UpdatePatientConsentDto, AssignDoctorDto } from './dto/patient-requests.dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';

@Controller('patients')
@UseGuards(FirebaseAuthGuard)
export class PatientsController {
  constructor(private readonly patientsService: PatientsService) {}

  @Get('me')
  async getMyProfile(@CurrentUser() user: AuthenticatedUser) {
    return this.patientsService.getMyPatientProfile(user);
  }

  @Get('me/dashboard')
  async getMyDashboard(@CurrentUser() user: AuthenticatedUser) {
    return this.patientsService.getMyDashboard(user);
  }

  @Patch('me/consent')
  async updateConsent(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdatePatientConsentDto,
  ) {
    return this.patientsService.updateConsent(user, dto);
  }

  @Post('assign-doctor')
  async assignDoctor(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: AssignDoctorDto,
  ) {
    return this.patientsService.assignDoctor(user, dto);
  }

  @Delete('revoke-doctor/:doctorId')
  async revokeDoctor(
    @CurrentUser() user: AuthenticatedUser,
    @Param('doctorId') doctorId: string,
  ) {
    return this.patientsService.revokeDoctor(user, doctorId);
  }

  @Get(':id')
  async getPatientById(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.patientsService.getPatientById(id, user);
  }
}
