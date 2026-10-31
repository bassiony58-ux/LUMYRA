import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  UseGuards,
} from '@nestjs/common';
import { MedicationsService } from './medications.service';
import { CreateMedicationDto, LogAdherenceDto } from './dto/medication.dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';

@Controller('medications')
@UseGuards(FirebaseAuthGuard)
export class MedicationsController {
  constructor(private readonly medicationsService: MedicationsService) {}

  @Get()
  async list(@CurrentUser() user: AuthenticatedUser) {
    return this.medicationsService.listMyMedications(user);
  }

  @Post()
  async create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateMedicationDto,
  ) {
    return this.medicationsService.createMedication(user, dto);
  }

  @Post(':id/adherence')
  async logAdherence(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: LogAdherenceDto,
  ) {
    return this.medicationsService.logAdherence(id, user, dto);
  }
}
