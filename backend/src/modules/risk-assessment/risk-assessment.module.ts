import { Module } from '@nestjs/common';
import { RiskAssessmentService } from './risk-assessment.service';
import { RiskAssessmentController } from './risk-assessment.controller';
import { QuestionnaireService } from './questionnaire.service';
import { QuestionnaireController } from './questionnaire.controller';
import { AiModule } from '../ai/ai.module';

@Module({
  imports: [AiModule],
  controllers: [RiskAssessmentController, QuestionnaireController],
  providers: [RiskAssessmentService, QuestionnaireService],
  exports: [RiskAssessmentService, QuestionnaireService],
})
export class RiskAssessmentModule {}
