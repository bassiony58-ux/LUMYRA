import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import { AuthenticatedUser, UserRole } from '../../common/interfaces/authenticated-user.interface';
import { SendMessageDto } from './dto/send-message.dto';

export interface ChatMessage {
  id: string;
  conversationId: string;
  senderUserId: string;
  senderRole: string;
  senderName: string;
  content: string;
  attachmentUrl?: string;
  sentAt: string;
  isRead: boolean;
}

export interface ChatConversation {
  id: string;
  patientUserId: string;
  patientName: string;
  doctorUserId: string;
  doctorName: string;
  lastMessage: string;
  lastMessageAt: string;
  unreadCount: number;
  messages: ChatMessage[];
}

@Injectable()
export class MessagesService {
  private inMemoryConversations: ChatConversation[] = [
    {
      id: 'conv-001',
      patientUserId: 'user-pat-01',
      patientName: 'سارة أحمد محمد',
      doctorUserId: 'user-doc-01',
      doctorName: 'د. نور الخالدي (استشاري جراحة أورام)',
      lastMessage: 'أهلاً بكِ سارة، اطلعت على تقرير السونار الأخير، المؤشرات حميدة ومطمئنة تماماً ولا داعي للقلق.',
      lastMessageAt: new Date(Date.now() - 3600000).toISOString(),
      unreadCount: 0,
      messages: [
        {
          id: 'msg-001',
          conversationId: 'conv-001',
          senderUserId: 'user-pat-01',
          senderRole: 'PATIENT',
          senderName: 'سارة أحمد',
          content: 'مساء الخير يا دكتور، قمت برفع نتيجة فحص السونار اليوم في التطبيق، هل النتيجة مطمئنة؟',
          sentAt: new Date(Date.now() - 7200000).toISOString(),
          isRead: true,
        },
        {
          id: 'msg-002',
          conversationId: 'conv-001',
          senderUserId: 'user-doc-01',
          senderRole: 'DOCTOR',
          senderName: 'د. نور الخالدي',
          content: 'أهلاً بكِ سارة، اطلعت على تقرير السونار الأخير، المؤشرات حميدة ومطمئنة تماماً ولا داعي للقلق. سنكتفي بالمتابعة الدورية بعد 6 أشهر.',
          sentAt: new Date(Date.now() - 3600000).toISOString(),
          isRead: true,
        },
      ],
    },
    {
      id: 'conv-002',
      patientUserId: 'user-pat-02',
      patientName: 'مريم علي حسن',
      doctorUserId: 'user-doc-01',
      doctorName: 'د. نور الخالدي (استشاري جراحة أورام)',
      lastMessage: 'يرجى مراجعة العيادة يوم الأحد القادم لاستكمال الفحص السريري.',
      lastMessageAt: new Date(Date.now() - 86400000).toISOString(),
      unreadCount: 1,
      messages: [
        {
          id: 'msg-003',
          conversationId: 'conv-002',
          senderUserId: 'user-pat-02',
          senderRole: 'PATIENT',
          senderName: 'مريم علي',
          content: 'السلام عليكم دكتور، أشعر ببعض الألم الخفيف في الجانب الأيسر منذ 3 أيام.',
          sentAt: new Date(Date.now() - 90000000).toISOString(),
          isRead: true,
        },
        {
          id: 'msg-004',
          conversationId: 'conv-002',
          senderUserId: 'user-doc-01',
          senderRole: 'DOCTOR',
          senderName: 'د. نور الخالدي',
          content: 'يرجى مراجعة العيادة يوم الأحد القادم لاستكمال الفحص السريري.',
          sentAt: new Date(Date.now() - 86400000).toISOString(),
          isRead: true,
        },
      ],
    },
  ];

  constructor(
    private readonly prisma: PrismaService,
    private readonly audit: AuditService,
  ) {}

  async listConversations(user: AuthenticatedUser) {
    // Return all conversations relevant to user or all conversations if doctor/admin
    return this.inMemoryConversations.map((c) => ({
      id: c.id,
      patientUserId: c.patientUserId,
      patientName: c.patientName,
      doctorUserId: c.doctorUserId,
      doctorName: c.doctorName,
      lastMessage: c.lastMessage,
      lastMessageAt: c.lastMessageAt,
      unreadCount: c.unreadCount,
    }));
  }

  async getConversationMessages(conversationId: string, user: AuthenticatedUser) {
    const conv = this.inMemoryConversations.find((c) => c.id === conversationId);
    if (!conv) {
      throw new NotFoundException('المحادثة غير موجودة');
    }
    // Mark as read
    conv.unreadCount = 0;
    return conv.messages;
  }

  async sendMessage(user: AuthenticatedUser, dto: SendMessageDto) {
    let conv = this.inMemoryConversations.find(
      (c) => c.id === dto.conversationId || c.patientUserId === dto.recipientUserId || c.doctorUserId === dto.recipientUserId,
    );

    if (!conv) {
      conv = {
        id: `conv-${Date.now()}`,
        patientUserId: user.role === UserRole.PATIENT ? user.id : dto.recipientUserId,
        patientName: user.role === UserRole.PATIENT ? (user.displayName || 'المريضة') : 'المريضة التابعة',
        doctorUserId: user.role === UserRole.DOCTOR ? user.id : dto.recipientUserId,
        doctorName: user.role === UserRole.DOCTOR ? (user.displayName || 'الطبيب المعالج') : 'د. استشاري لوميرا',
        lastMessage: dto.content,
        lastMessageAt: new Date().toISOString(),
        unreadCount: 1,
        messages: [],
      };
      this.inMemoryConversations.unshift(conv);
    }

    const newMessage: ChatMessage = {
      id: `msg-${Date.now()}`,
      conversationId: conv.id,
      senderUserId: user.id,
      senderRole: user.role,
      senderName: user.displayName || (user.role === UserRole.DOCTOR ? 'الطبيب' : 'المريضة'),
      content: dto.content,
      attachmentUrl: dto.attachmentUrl,
      sentAt: new Date().toISOString(),
      isRead: false,
    };

    conv.messages.push(newMessage);
    conv.lastMessage = dto.content;
    conv.lastMessageAt = newMessage.sentAt;

    return newMessage;
  }
}
