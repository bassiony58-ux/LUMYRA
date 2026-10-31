import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/adaptive_scaffold.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'أهلاً بكِ في لوميرا 🌸. أنا مساعدكِ الصحي الذكي الداعم، هنا للإجابة على استفساراتكِ التوعوية وشرح المصطلحات الطبية وتذكيركِ بخطوات الفحص الذاتي. كيف يمكنني مساندتكِ اليوم؟',
      isUser: false,
      time: '١٠:٠٠ ص',
    ),
  ];

  final List<String> _suggestedPrompts = [
    'كيف أستعد لفحص الماموجرام القادم؟',
    'ما هي الطريقة الصحيحة للفحص الذاتي؟',
    'كيف أتعامل مع الإرهاق أثناء العلاج الهرموني؟',
    'ما هي الأسئلة التي يجب طرحها على طبيبي؟',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isTyping = false;

  Future<void> _sendMessage([String? presetText]) async {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: timeStr));
      _isTyping = true;
      if (presetText == null) _textController.clear();
    });

    _scrollToBottom();

    final isAr = context.isArabic;
    String response = '';

    try {
      final client = ApiClient(tokenProvider: () => 'mock-patient-token');
      final res = await client.post('/ai/chat', body: {
        'message': text,
        'locale': isAr ? 'ar' : 'en',
      });

      if (res is Map && res['assistantResponse'] is Map) {
        response = res['assistantResponse']['text']?.toString() ?? '';
      }
    } catch (_) {}

    // Fallback if backend network request fails
    if (response.isEmpty) {
      final q = text.toLowerCase();
      final breastKeywords = [
        'ثدي', 'كتل', 'ورم', 'كيس', 'سونار', 'ماموجرام', 'مامو', 'فحص', 'عينة', 'خزعة',
        'حلمة', 'إفرازات', 'ألم', 'احمرار', 'التهاب', 'غدد', 'سرطان', 'أورام', 'هرمون',
        'تاموكسيفين', 'علاج', 'أشعة', 'أعراض', 'بي رادس', 'طمث', 'دورة', 'تغذية', 'رضاعة',
        'breast', 'lump', 'tumor', 'cyst', 'sonar', 'ultrasound', 'mammogram', 'biopsy',
        'nipple', 'discharge', 'pain', 'mastitis', 'cancer', 'fibroadenoma', 'tamoxifen', 'birads'
      ];
      final isBreastRelated = breastKeywords.any((k) => q.contains(k));

      if (!isBreastRelated) {
        response = isAr
            ? 'عذراً يا عزيزتي 🌸، أنا لوميرا المساعد الطبي المتخصص حصرياً في صحة وأمراض وأورام الثدي والفحوصات المتعلقة بها. لا يمكنني الإجابة إلا على الأسئلة الطبية والتوعوية المرتبطة بصحة الثدي وكيفية رعايتها ومتابعتها. يسعدني الإجابة على أي سؤال يخص صحة ثديكِ، الفحص الذاتي، أو الأشعة والتحاليل الطبية.'
            : 'I apologize 🌸, I am Lumyra, an AI companion dedicated exclusively to breast health, oncology, and related clinical care. I cannot answer queries outside breast wellness, diagnostics, and treatment. Please feel free to ask any question regarding breast lumps, mammography, clinical care, or breast health.';
      } else if (q.contains('كتل') || q.contains('شكيت') || q.contains('lump')) {
        response = isAr
            ? 'أهلاً بكِ، واطمئني تماماً يا عزيزتي 🌸:\n١. أكثر من ٨٠٪ من كتل الثدي حميدة تماماً (مثل الأكياس المائية البسيطة أو الأورام الغدية الليفية).\n٢. تجنبي الضغط المتكرر أو العنيف على المنطقة لتفادي تهيج الأنسجة.\n٣. يوصى بحجز موعد استشارة سريرية مع استشاري جراحة أورام الثدي للفحص السريري المباشر.\n٤. الفحص المتوقع: سيطلب الطبيب فحص سونار للثدي (إذا كان عمركِ أقل من ٤٠ سنة) أو ماموجرام رقمي لتحديد طبيعة الكتلة بدقة متناهية.\n٥. لاحظي ما إذا كانت الكتلة متحركة أو ثابتة، وتاريخ ظهورها بالنسبة للدورة الشهرية.'
            : 'Rest assured 🌸:\n1. Over 80% of breast lumps are completely benign (such as fluid-filled cysts or fibroadenomas).\n2. Avoid forcefully palpating or squeezing the area repeatedly.\n3. Schedule an in-person clinical evaluation with a specialized breast surgeon.\n4. Expected diagnostic steps: Breast ultrasound (for women under 40) or digital mammogram to evaluate tissue characteristics.\n5. Note whether the lump is mobile or tender, and its relation to your menstrual cycle.';
      } else if (q.contains('ماموجرام') || q.contains('mammogram')) {
        response = isAr
            ? 'للاستعداد الأمثل لفحص الماموجرام 🌸:\n• تجنبي استخدام مزيلات العرق أو البودرة أو العطور يوم الفحص لأنها قد تظهر كبقع بيضاء على صورة الأشعة.\n• يفضل ارتداء ملابس من قطعتين لسهولة الفحص.\n• أفضل وقت هو بعد انتهاء الدورة الشهرية بأسبوع حيث يكون الثدي أقل تحسساً للألم.'
            : 'Preparation for your mammogram 🌸:\n• Avoid deodorants, powders, or lotions on the day of the exam.\n• Wear a two-piece outfit for comfort.\n• The ideal timing is one week after your period when breast tissue is least sensitive.';
      } else if (q.contains('فحص ذاتي') || q.contains('self-exam')) {
        response = isAr
            ? 'دليل الفحص الذاتي الشهري 🌸:\n• التوقيت المثالي: بعد انتهاء الدورة الشهرية بـ ٥ إلى ٧ أيام.\n• الخطوة ١ (أمام المرآة): تأكدي من تماثل الثديين، وعدم وجود انبعاج بالجلد أو تغير بشكل الحلمة.\n• الخطوة ٢ (رفع الذراعين): تحققي من نفس العلامات مع رفع اليدين لأعلى.\n• الخطوة ٣ (الفحص باللمس): استخدمي باطن أصابع يدكِ الثلاث بحركات دائرية خفيفة ثم متوسطة لتغطية الثدي ومنطقة تحت الإبط بالكامل.'
            : 'Monthly self-exam guide 🌸:\n• Timing: 5-7 days after your period ends.\n• Step 1 (Visual): Inspect symmetry, skin texture, and nipple contour before a mirror.\n• Step 2 (Arms raised): Re-inspect with arms raised overhead.\n• Step 3 (Palpation): Use the pads of your three middle fingers in small circular motions covering the breast and underarm.';
      } else {
        response = isAr
            ? 'شكراً لاستفساركِ الهام حول صحة الثدي 🌸. نود تذكيركِ بأن هذه الإرشادات للتوعية والدعم العام ولا تغني عن استشارة طبيبكِ المعالج. يمكنكِ حفظ هذه النقطة في "يومياتكِ" أو إضافتها لجدول أسئلتكِ مع طبيبكِ في موعدكِ القادم.'
            : 'Thank you for your breast health question 🌸. Note that this is for general awareness and guidance and does not replace medical consultation with your doctor.';
      }
    }

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false, time: timeStr));
        _isTyping = false;
      });
      _scrollToBottom();
    }
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

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: 6,
      titleKey: 'navAssistant',
      body: Column(
        children: [
          // Notice Banner
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.powderBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.softDustyBlush),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.isArabic
                          ? 'المساعد الذكي يقدم دعماً توعوياً وتثقيفياً فقط، ولا يصدر تشخيصات طبية نهائية.'
                          : 'Educational companion. Does not provide medical diagnoses.',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Suggested Prompts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _suggestedPrompts.map((prompt) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(prompt, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
                      backgroundColor: AppColors.whiteSurface,
                      side: const BorderSide(color: AppColors.softDustyBlush),
                      onPressed: () => _sendMessage(prompt),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.isArabic ? 'لوميرا تفكر وتكتب الإجابة الطبية... 🌸' : 'Lumyra is typing clinical advice... 🌸',
                    style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.whiteSurface,
              border: Border(top: BorderSide(color: AppColors.warmNeutralSand)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: context.isArabic ? 'اكتبي سؤالكِ هنا بكل أمان...' : 'Ask your health question safely...',
                        fillColor: AppColors.powderBackground,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9999),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryAction,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(),
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

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.primaryAction : AppColors.whiteSurface,
          borderRadius: BorderRadius.circular(20),
          border: msg.isUser ? null : Border.all(color: AppColors.warmNeutralSand),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : AppColors.mainText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              msg.time,
              style: TextStyle(
                color: msg.isUser ? Colors.white.withAlpha(180) : AppColors.secondaryText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
