import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/voice_note_widgets.dart';

/// Interactive modal sheet that connects family members and caregivers
/// with the breast cancer patient's daily journey (medications, appointments,
/// emotional voice notes, and accompaniment).
class CaregiverCompanionSheet extends StatefulWidget {
  const CaregiverCompanionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CaregiverCompanionSheet(),
    );
  }

  @override
  State<CaregiverCompanionSheet> createState() => _CaregiverCompanionSheetState();
}

class _CaregiverCompanionSheetState extends State<CaregiverCompanionSheet> {
  final String _familyInviteCode = 'LUM-CARE-8842';
  bool _copied = false;

  final List<Map<String, dynamic>> _caregivers = [
    {
      'name': 'مريم أحمد',
      'nameEn': 'Mariam Ahmed',
      'relation': 'الابنة (المرافق الأساسي)',
      'relationEn': 'Daughter (Primary Caregiver)',
      'online': true,
      'avatar': '👩‍🦰',
    },
    {
      'name': 'د. خالد محمود',
      'nameEn': 'Dr. Khaled Mahmoud',
      'relation': 'الزوج (متابع الجرعات)',
      'relationEn': 'Spouse (Medication Follow-up)',
      'online': false,
      'avatar': '👨‍💼',
    },
  ];

  final List<Map<String, dynamic>> _voiceEncouragements = [
    {
      'sender': 'مريم (الابنة)',
      'senderEn': 'Mariam (Daughter)',
      'time': 'اليوم 08:30 ص',
      'timeEn': 'Today 08:30 AM',
      'text': 'صباح الورد يا ماما 🌸.. طمنيني أخدتي علاج الصباح؟ أنا جنبك ومستنياكي نتمشى مع بعض العصر.',
      'textEn': 'Good morning Mom 🌸.. Did you take your morning meds? I am by your side and looking forward to our afternoon walk.',
      'duration': 28,
      'audioPath': null,
    },
    {
      'sender': 'خالد (الزوج)',
      'senderEn': 'Khaled (Spouse)',
      'time': 'أمس 09:15 م',
      'timeEn': 'Yesterday 09:15 PM',
      'text': 'ألف سلامة عليكي يا غالية.. ميعاد د. نور الأربعاء حجزته ومرتب كل حاجة بإذن الله.',
      'textEn': 'Get well soon, dearest.. Dr. Noor appointment on Wednesday is confirmed and everything is arranged.',
      'duration': 22,
      'audioPath': null,
    },
  ];

  void _copyInviteCode(bool isAr) {
    Clipboard.setData(ClipboardData(text: 'https://lumyra.health/join?code=$_familyInviteCode'));
    HapticFeedback.lightImpact();
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text(
          isAr
              ? 'تم نسخ رابط دعوة العائلة بنجاح! شاركيه مع بنتكِ أو أسرتكِ عبر واتساب 🌸'
              : 'Family invite link copied! Share it with your daughter or loved ones via WhatsApp 🌸',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isArabic;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.whiteSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.warmNeutralSand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.powderBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.softDustyBlush),
                    ),
                    child: const Icon(Icons.family_restroom_rounded, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusBadge.blush(isAr ? 'رفيق العائلة • دائرة الأمان' : 'Care Circle • Family Companion'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr ? 'متابعة الأهل ورفيق الرحلة 👨‍👩‍👧' : 'Family Companion & Care Circle',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Explanation Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.powderBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.softDustyBlush),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.favorite_rounded, color: AppColors.primaryAction, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'لأنكِ لستِ وحدكِ في الرحلة؛ تتيح هذه الميزة لبنتكِ، زوجكِ، أو أختكِ متابعة مواعيد علاجكِ بلطف، تذكيركِ بالجرعات، وإرسال رسائل تشجيعية دافئة تدعم معنوياتكِ.'
                            : 'Because you never walk alone; your daughter, spouse, or family can follow your medication schedule, support appointments, and leave heartwarming voice notes.',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.mainText, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 1. Family Invite Code Card
              AppCard(
                padding: const EdgeInsets.all(18),
                border: Border.all(color: AppColors.primary.withAlpha(70), width: 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.qr_code_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          isAr ? 'رمز دعوة العائلة المشفر' : 'Secure Family Access Code',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAr
                          ? 'شاركي هذا الكود مع أفراد عائلتكِ لربط حسابهم كـ "رفيق رحلة" بدون مشاركة أسراركِ الخاصة:'
                          : 'Share this encrypted code with family members to connect their companion app securely:',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.powderBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.softDustyBlush),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _familyInviteCode,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded, size: 16),
                            label: Text(
                              _copied ? (isAr ? 'تم النسخ' : 'Copied') : (isAr ? 'نسخ الرابط' : 'Copy Link'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _copyInviteCode(isAr),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Active Connected Family Members
              Text(
                isAr ? 'رفقاء الرحلة المتصلون الآن (${_caregivers.length})' : 'Active Companions (${_caregivers.length})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.mainText),
              ),
              const SizedBox(height: 10),
              ..._caregivers.map((c) {
                final name = isAr ? c['name'] : c['nameEn'];
                final rel = isAr ? c['relation'] : c['relationEn'];
                final isOnline = c['online'] as bool;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.powderBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.softDustyBlush),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.whiteSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Text(c['avatar'], style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isOnline ? const Color(0xFF10B981) : Colors.grey.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(rel, style: const TextStyle(fontSize: 11.5, color: AppColors.secondaryText)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_outlined, color: AppColors.primary, size: 20),
                        tooltip: isAr ? 'إرسال رسالة' : 'Send message',
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.primary,
                              content: Text(
                                isAr ? 'جاري فتح المحادثة المباشرة مع $name' : 'Opening direct chat with $name',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // 3. Live Medication & Chemo Sync (What Caregivers See)
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medication_liquid_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isAr ? 'متابعة الجرعات والالتزام الحي' : 'Live Medication Adherence Tracker',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary),
                          ),
                        ),
                        StatusBadge.active(isAr ? 'جرعة اليوم مكتملة' : 'Today Done'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.powderBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'تاموكسيفين (Tamoxifen) - 20 مجم' : 'Tamoxifen - 20 mg',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  isAr ? 'جرعة الصباح: تم التناول في 09:12 ص بنجاح 🌸' : 'Morning dose logged at 09:12 AM 🌸',
                                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, color: Colors.amber.shade800, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'فحص المتابعة القادم: د. نور الخالدي' : 'Upcoming Visit: Dr. Noor Al-Khalidi',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  isAr ? 'الأربعاء القادم 10:30 ص • بهية الهرم' : 'Next Wednesday 10:30 AM • Baheya Haram',
                                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.primary,
                                  content: Text(
                                    isAr
                                        ? 'تم تأكيد مرافقة مريم في موعد المستشفى القادم 🚗'
                                        : 'Confirmed accompaniment for upcoming hospital appointment 🚗',
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              isAr ? 'أنا سأرافقها 🚗' : 'I will escort',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Voice Encouragement Notes (Family to Patient)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'رسائل الدعم والمحبة الصوتية 💖' : 'Caregiver Voice Love Notes 💖',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.mainText),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.mic_rounded, size: 16, color: AppColors.primary),
                    label: Text(
                      isAr ? 'تسجيل رسالة' : 'Record Note',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    onPressed: () {
                      _showRecordVoiceSheet(context, isAr);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._voiceEncouragements.map((v) {
                final sender = isAr ? v['sender'] : v['senderEn'];
                final time = isAr ? v['time'] : v['timeEn'];
                final text = isAr ? v['text'] : v['textEn'];
                final dur = v['duration'] as int;

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.record_voice_over_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(sender, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                            ],
                          ),
                          Text(time, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(text, style: const TextStyle(fontSize: 12, color: AppColors.mainText, height: 1.4)),
                      const SizedBox(height: 10),
                      VoiceNotePlayerWidget(
                        durationSeconds: dur,
                        isMe: false,
                        title: isAr ? 'رسالة صوتية من $sender' : 'Voice from $sender',
                        audioPath: v['audioPath'] as String?,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Close / Done
              PillButton(
                label: isAr ? 'حفظ وإغلاق اللوحة 🌸' : 'Done & Close Circle',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showRecordVoiceSheet(BuildContext context, bool isAr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.warmNeutralSand,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isAr ? 'تسجيل رسالة محبة ودعم صوتي 💖' : 'Record Love & Support Voice Note 💖',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                isAr
                    ? 'كلماتكِ الطيبة تصنع فارقاً حقيقياً في نفسية ومعنويات المريضة أثناء رحلة التعافي.'
                    : 'Your heartfelt words make a real difference in lifting spirits during healing.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 20),
              VoiceRecorderBarWidget(
                onSend: (duration, path) {
                  Navigator.pop(context);
                  setState(() {
                    _voiceEncouragements.insert(0, {
                      'sender': isAr ? 'أنا (رسالة جديدة)' : 'Me (New Note)',
                      'senderEn': 'Me (New Note)',
                      'time': isAr ? 'الآن' : 'Just now',
                      'text': isAr ? 'رسالة دعم وتشجيع تم تسجيلها بصوتكِ 🌸' : 'Encouragement voice note recorded 🌸',
                      'duration': duration,
                      'audioPath': path,
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.primary,
                      content: Text(
                        isAr
                            ? 'تم إرسال رسالتكِ الصوتية التشجيعية بنجاح 💖'
                            : 'Your voice note has been sent to the patient 💖',
                      ),
                    ),
                  );
                },
                onCancel: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
