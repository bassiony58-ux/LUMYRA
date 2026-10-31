import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  UseGuards,
} from '@nestjs/common';
import { AiService } from './ai.service';
import { SendChatMessageDto } from './dto/chat.dto';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';

@Controller('ai')
@UseGuards(FirebaseAuthGuard)
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('chat')
  async sendMessage(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: SendChatMessageDto,
  ) {
    return this.aiService.sendMessage(user, dto);
  }

  @Get('conversations')
  async listConversations(@CurrentUser() user: AuthenticatedUser) {
    return this.aiService.listConversations(user);
  }

  @Get('conversations/:id/messages')
  async getMessages(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.aiService.getConversationMessages(id, user);
  }

  @Post('scans/:id/analyze')
  async analyzeScan(
    @Param('id') scanId: string,
    @CurrentUser() user: AuthenticatedUser,
  ) {
    return this.aiService.analyzeScan(scanId, user);
  }
}
