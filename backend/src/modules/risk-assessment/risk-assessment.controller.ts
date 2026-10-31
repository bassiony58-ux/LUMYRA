import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  UseGuards,
} from '@nestjs/common';
import { RiskAssessmentService } from './risk-assessment.service';
import { SubmitRiskAssessmentDto } from './dto/risk-assessment.dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';

@Controller('risk-assessment')
@UseGuards(FirebaseAuthGuard)
export class RiskAssessmentController {
  constructor(private readonly riskService: RiskAssessmentService) {}

  @Post()
  async submit(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: SubmitRiskAssessmentDto,
  ) {
    return this.riskService.submitAssessment(user, dto);
  }

  @Get('history')
  async getHistory(@CurrentUser() user: AuthenticatedUser) {
    return this.riskService.listHistory(user);
  }

  @Get(':id')
  async getOne(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.riskService.getById(id, user);
  }
}
