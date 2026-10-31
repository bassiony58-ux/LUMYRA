import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/localization/app_localization.dart';
import '../../app/theme/app_colors.dart';
import '../network/api_client.dart';
import 'status_badge.dart';
import 'voice_note_widgets.dart';

class ClinicalChatSheet extends StatefulWidget {
  final bool isDoctor;
  final String otherPartyName;

  const ClinicalChatSheet({
    super.key,
    required this.isDoctor,
    required this.otherPartyName,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isDoctor,
    String? otherPartyName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClinicalChatSheet(
        isDoctor: isDoctor,
        otherPartyName: otherPartyName ??
            (isDoctor ? 'سارة أحمد محمد (ملف رقم #4412)' : 'أ.د. نور الخالدي (استشاري جراحة أورام الثدي)'),
      ),
    );
  }

  @override
  State<ClinicalChatSheet> createState() => _ClinicalChatSheetState();
}

class _ClinicalChatSheetState extends State<ClinicalChatSheet> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecordingVoice = false;

  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      {
        'id': 'msg-1',
        'senderName': 'سارة أحمد محمد',
        'isDoctor': false,
        'content': 'مساء الخير يا دكتور، قمت برفع نتيجة فحص السونار اليوم في التطبيق، هل النتيجة مطمئنة؟',
        'time': '٠٩:١٥ ص',
        'isVoice': false,
      },
      {
        'id': 'msg-2',
        'senderName': 'د. نور الخالدي',
        'isDoctor': true,
        'content': '',
        'time': '٠٩:٢٠ ص',
        'isVoice': true,
        'durationSeconds': 18,
        'voiceTitle': 'تسجيل صوتي استشاري من د. نور 🎙️',
      },
      {
        'id': 'msg-3',
        'senderName': 'د. نور الخالدي',
        'isDoctor': true,
        'content': 'اطلعت على صور الماموجرام والسونار، التصنيف BI-RADS 2 مطمئن وطبيعي ولا توجد أي مؤشرات مقلقة.',
        'time': '٠٩:٢١ ص',
        'isVoice': false,
      },
      {
        'id': 'msg-4',
        'senderName': 'سارة أحمد محمد',
        'isDoctor': false,
        'content': '',
        'time': '٠٩:٢٥ ص',
        'isVoice': true,
        'durationSeconds': 12,
        'voiceTitle': 'استفسار صوتي من المريضة 🎙️',
      },
    ];
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendTextMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final myName = widget.isDoctor ? 'د. نور الخالدي' : 'سارة أحمد محمد';
    final now = TimeOfDay.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'id': 'msg-${DateTime.now().millisecondsSinceEpoch}',
        'senderName': myName,
        'isDoctor': widget.isDoctor,
        'content': text,
        'time': timeStr,
        'isVoice': false,
      });
      _textController.clear();
    });

    _scrollToBottom();

    try {
      final token = widget.isDoctor
          ? 'mock-doctor-uid:doctor@lumyra.test:DOCTOR'
          : 'mock-patient-uid:patient@lumyra.test:PATIENT';
      final client = ApiClient(tokenProvider: () => token);
      await client.post('/messages/send', body: {
        'recipientUserId': widget.isDoctor ? 'user-pat-01' : 'user-doc-01',
        'content': text,
      });
    } catch (_) {}
  }

  void _sendVoiceNote(int durationSeconds) {
    final myName = widget.isDoctor ? 'د. نور الخالدي' : 'سارة أحمد محمد';
    final now = TimeOfDay.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _isRecordingVoice = false;
      _messages.add({
        'id': 'voice-${DateTime.now().millisecondsSinceEpoch}',
        'senderName': myName,
        'isDoctor': widget.isDoctor,
        'content': '',
        'time': timeStr,
        'isVoice': true,
        'durationSeconds': durationSeconds,
        'voiceTitle': widget.isDoctor
            ? 'فويس توجيهي من د. نور 🎙️'
            : 'فويس استفسار من المريضة 🎙️',
      });
    });

    _scrollToBottom();
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.isArabic
              ? 'تم إرسال التسجيل الصوتي ($durationSeconds ثانية) بنجاح 🎙️'
              : 'Voice note (${durationSeconds}s) sent successfully 🎙️',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isArabic;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.whiteSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(top: 14, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.powderBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.softDustyBlush),
                  ),
                  child: Icon(
                    widget.isDoctor ? Icons.person_rounded : Icons.medical_services_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusBadge.active(isAr ? 'محادثة مشفرة آمنة' : 'Encrypted'),
                          const SizedBox(width: 6),
                          Text(
                            isAr ? 'صوت ونصوص' : 'Voice & Text',
                            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.otherPartyName,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 16),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final msg = _messages[i];
                final msgIsDoctor = msg['isDoctor'] == true;
                // "isMe" is true when message author role matches current viewer
                final isMe = widget.isDoctor ? msgIsDoctor : !msgIsDoctor;
                final isVoice = msg['isVoice'] == true;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(ctx).size.width * 0.82,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.powderBackground
                          : const Color(0xFFF3F5F9),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                      border: Border.all(
                        color: isMe ? AppColors.softDustyBlush : Colors.black12,
                        width: 1.2,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg['senderName'] ?? '',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: msgIsDoctor ? const Color(0xFF8B263E) : const Color(0xFF1B4965),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (isVoice)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '🎙️ فويس',
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (isVoice)
                          VoiceNotePlayerWidget(
                            durationSeconds: (msg['durationSeconds'] as int?) ?? 15,
                            isDoctor: msgIsDoctor,
                            isMe: isMe,
                            title: msg['voiceTitle'] as String?,
                            compact: true,
                          )
                        else
                          Text(
                            msg['content'] ?? '',
                            style: const TextStyle(fontSize: 13.5, color: AppColors.mainText, height: 1.4),
                          ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            msg['time'] ?? '',
                            style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Input Bar with Safe Area
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: _isRecordingVoice
                  ? VoiceRecorderBarWidget(
                      isDoctor: widget.isDoctor,
                      onCancel: () => setState(() => _isRecordingVoice = false),
                      onSend: _sendVoiceNote,
                    )
                  : Row(
                      children: [
                        // Text Field
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintText: isAr ? 'اكتب رسالة سريرية...' : 'Type message...',
                              filled: true,
                              fillColor: AppColors.powderBackground,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: AppColors.softDustyBlush),
                              ),
                            ),
                            onSubmitted: (_) => _sendTextMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Voice Note Record Button (فويس)
                        InkWell(
                          onTap: () {
                            HapticFeedback.heavyImpact();
                            setState(() => _isRecordingVoice = true);
                          },
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.powderBackground,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 1.5),
                            ),
                            child: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 22),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Send Text Button
                        InkWell(
                          onTap: _sendTextMessage,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
