import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JournalsService } from './journals.service';
import { CreateJournalEntryDto, UpdateJournalEntryDto } from './dto/journal.dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { DoctorApprovedGuard } from '../../common/guards/doctor-approved.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';

@Controller('journals')
@UseGuards(FirebaseAuthGuard, DoctorApprovedGuard)
export class JournalsController {
  constructor(private readonly journalsService: JournalsService) {}

  @Get()
  async list(
    @CurrentUser() user: AuthenticatedUser,
    @Query('patientId') patientId?: string,
  ) {
    return this.journalsService.listEntries(user, patientId);
  }

  @Post()
  async create(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateJournalEntryDto,
  ) {
    return this.journalsService.createEntry(user, dto);
  }

  @Patch(':id')
  async update(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateJournalEntryDto,
  ) {
    return this.journalsService.updateEntry(id, user, dto);
  }

  @Delete(':id')
  async delete(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.journalsService.deleteEntry(id, user);
  }
}
