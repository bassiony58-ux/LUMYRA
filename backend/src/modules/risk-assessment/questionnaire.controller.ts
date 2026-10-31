import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { QuestionnaireService } from './questionnaire.service';
import {
  SaveQuestionnaireDraftDto,
  SubmitQuestionnaireDto,
  CorrectQuestionnaireDto,
} from './dto/questionnaire.dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';

@Controller('questionnaire')
export class QuestionnaireController {
  constructor(private readonly questionnaireService: QuestionnaireService) {}

  @Get('definition')
  getDefinition() {
    return this.questionnaireService.getDefinition();
  }

  @Get('my-draft')
  @UseGuards(FirebaseAuthGuard)
  async getMyDraft(@CurrentUser() user: AuthenticatedUser) {
    return this.questionnaireService.getMyDraft(user);
  }

  @Post('draft')
  @UseGuards(FirebaseAuthGuard)
  async saveDraft(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: SaveQuestionnaireDraftDto,
  ) {
    return this.questionnaireService.saveDraft(user, dto);
  }

  @Post('submit')
  @UseGuards(FirebaseAuthGuard)
  async submit(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: SubmitQuestionnaireDto,
  ) {
    return this.questionnaireService.submitQuestionnaire(user, dto);
  }

  @Post('correct')
  @UseGuards(FirebaseAuthGuard)
  async correct(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CorrectQuestionnaireDto,
  ) {
    return this.questionnaireService.correctQuestionnaire(user, dto);
  }

  @Get('history')
  @UseGuards(FirebaseAuthGuard)
  async getHistory(@CurrentUser() user: AuthenticatedUser) {
    return this.questionnaireService.listPatientResponses(user);
  }

  @Get(':id')
  @UseGuards(FirebaseAuthGuard)
  async getOne(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.questionnaireService.getResponseById(id, user);
  }
}
