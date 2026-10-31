import { Controller, Get, Post, Param, Query, Body, UseGuards } from '@nestjs/common';
import { MedicalCentersService } from './medical-centers.service';
import { CreateClinicDto } from './dto/create-clinic.dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser, UserRole } from '../../common/interfaces/authenticated-user.interface';

@Controller('medical-centers')
export class MedicalCentersController {
  constructor(private readonly centersService: MedicalCentersService) {}

  @Post('my-clinic')
  @UseGuards(FirebaseAuthGuard, RolesGuard)
  @Roles(UserRole.DOCTOR, UserRole.ADMIN)
  async addMyClinic(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateClinicDto,
  ) {
    return this.centersService.addOrUpdateClinic(user, dto);
  }

  @Get()
  async list(
    @Query('governorate') governorate?: string,
    @Query('city') city?: string,
    @Query('search') search?: string,
    @Query('mammographyOnly') mammographyOnly?: string,
    @Query('oncologyOnly') oncologyOnly?: string,
  ) {
    return this.centersService.findAll({
      governorate,
      city,
      search,
      mammographyOnly: mammographyOnly === 'true',
      oncologyOnly: oncologyOnly === 'true',
    });
  }

  @Get('governorates')
  async getGovernorates() {
    return this.centersService.getGovernorates();
  }

  @Get(':id')
  async getOne(@Param('id') id: string) {
    return this.centersService.findOne(id);
  }
}
