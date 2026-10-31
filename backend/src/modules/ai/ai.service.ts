import { Injectable, NotFoundException, ForbiddenException, Logger } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { MockAiAssistantProvider } from './providers/mock-ai-assistant.provider';
import { MockMedicalVisionProvider } from './providers/mock-medical-vision.provider';
import { GeminiService } from './gemini.service';
import { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { SendChatMessageDto } from './dto/chat.dto';
import { AuditAction } from '@prisma/client';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
    private readonly assistantProvider: MockAiAssistantProvider,
    private readonly visionProvider: MockMedicalVisionProvider,
    private readonly geminiService: GeminiService,
  ) {}

  async sendMessage(user: AuthenticatedUser, dto: SendChatMessageDto) {
    let conversationId = dto.conversationId;

    if (process.env.SKIP_DB_CONNECT === 'true') {
      let replyText = '';
      try {
        replyText = await this.geminiService.generateChatReply([], dto.message, dto.locale || 'ar');
      } catch (_) {
        const aiResponse = await this.assistantProvider.generateResponse([], dto.message, dto.locale);
        replyText = aiResponse.text;
      }
      return {
        conversationId: conversationId || 'mock-conv-id',
        userMessage: dto.message,
        assistantResponse: {
          text: replyText,
          providerName: 'Google Gemini 2.5 Flash',
          isDemoPlaceholder: false,
          disclaimer: 'تنبيه: نصائح توعوية إرشادية لا تغني عن الفحص الطبي.',
        },
      };
    }

    if (!conversationId) {
      const conv = await this.prisma.aiConversation.create({
        data: {
          userId: user.id,
          title: dto.message.slice(0, 40) + '...',
          isPrivate: true,
        },
      });
      conversationId = conv.id;
    } else {
      const conv = await this.prisma.aiConversation.findUnique({
        where: { id: conversationId },
      });
      if (!conv) throw new NotFoundException('Conversation not found.');
      if (conv.userId !== user.id) throw new ForbiddenException('Access denied to conversation.');
    }

    // Save user message
    await this.prisma.aiMessage.create({
      data: {
        conversationId,
        senderRole: 'user',
        content: dto.message,
      },
    });

    // Fetch conversation context
    const previousMessages = await this.prisma.aiMessage.findMany({
      where: { conversationId },
      orderBy: { sentAt: 'asc' },
      take: 10,
    });

    const history = previousMessages.map((m) => ({
      role: m.senderRole === 'user' ? ('user' as const) : ('assistant' as const),
      content: m.content,
    }));

    // Generate assistant response via Gemini
    let replyText = '';
    let isMock = false;
    let providerName = 'Google Gemini 2.5 Flash';
    try {
      replyText = await this.geminiService.generateChatReply(history, dto.message, dto.locale || 'ar');
    } catch (_) {
      const fallback = await this.assistantProvider.generateResponse(history, dto.message, dto.locale);
      replyText = fallback.text;
      isMock = true;
      providerName = fallback.providerName;
    }

    const aiResponse = {
      text: replyText,
      providerName,
      isDemoPlaceholder: isMock,
      disclaimer: 'تنبيه: نصائح توعوية إرشادية لا تغني عن الفحص الطبي.',
    };

    // Save assistant response
    const assistantMessage = await this.prisma.aiMessage.create({
      data: {
        conversationId,
        senderRole: 'assistant',
        content: replyText,
        providerName,
        modelVersion: 'gemini-flash',
        isMockResponse: isMock,
      },
    });

    await this.audit.logEvent({
      action: AuditAction.AI_CHAT_QUERY,
      actorUserId: user.id,
      actorRole: user.role,
      targetEntity: 'AiConversation',
      targetEntityId: conversationId,
      metadata: { isMock: aiResponse.isDemoPlaceholder },
    });

    return {
      conversationId,
      messageId: assistantMessage.id,
      assistantResponse: aiResponse,
    };
  }

  async listConversations(user: AuthenticatedUser) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return [{ id: 'mock-conv-id', title: 'Self-examination inquiries', createdAt: new Date() }];
    }

    return this.prisma.aiConversation.findMany({
      where: { userId: user.id },
      include: {
        messages: {
          orderBy: { sentAt: 'desc' },
          take: 1,
        },
      },
      orderBy: { updatedAt: 'desc' },
    });
  }

  async getConversationMessages(conversationId: string, user: AuthenticatedUser) {
    if (process.env.SKIP_DB_CONNECT === 'true') {
      return [];
    }

    const conv = await this.prisma.aiConversation.findUnique({
      where: { id: conversationId },
    });

    if (!conv) throw new NotFoundException('Conversation not found.');
    if (conv.userId !== user.id) throw new ForbiddenException('Access denied to conversation.');

    return this.prisma.aiMessage.findMany({
      where: { conversationId },
      orderBy: { sentAt: 'asc' },
    });
  }

  async analyzeScan(scanId: string, user: AuthenticatedUser) {
    let scan: any = null;

    if (process.env.SKIP_DB_CONNECT === 'true') {
      scan = {
        id: scanId,
        patientId: user.patientProfileId || 'pat-mock',
        storageKey: `patients/mock/scans/${scanId}.png`,
        category: 'MAMMOGRAM',
      };
    } else {
      scan = await this.prisma.medicalScan.findUnique({ where: { id: scanId } });
      if (!scan) throw new NotFoundException(`Medical scan ${scanId} not found.`);
      if (user.patientProfileId && scan.patientId !== user.patientProfileId && user.role !== 'ADMIN') {
        throw new ForbiddenException('You can only request automated review on your own scans.');
      }
    }

    const visionResult = await this.visionProvider.analyzeScan(
      scan.id,
      scan.storageKey,
      scan.category,
    );

    await this.audit.logEvent({
      action: AuditAction.SECONDARY_SCAN_REVIEW,
      actorUserId: user.id,
      actorRole: user.role,
      targetEntity: 'MedicalScan',
      targetEntityId: scan.id,
      metadata: { isDemo: visionResult.isDemoPlaceholder },
    });

    return visionResult;
  }
}
