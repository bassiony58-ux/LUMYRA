import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_badge.dart';

class MedicationItem {
  final String id;
  final String name;
  final String dosage;
  final String instructions;
  final String timeOfDay;
  final String scheduledTime;
  bool isTaken;
  String? takenTime;
  final int dosesRemaining;

  MedicationItem({
    required this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.timeOfDay,
    required this.scheduledTime,
    this.isTaken = false,
    this.takenTime,
    required this.dosesRemaining,
  });
}

class MedicationTrackerScreen extends ConsumerStatefulWidget {
  const MedicationTrackerScreen({super.key});

  @override
  ConsumerState<MedicationTrackerScreen> createState() => _MedicationTrackerScreenState();
}

class _MedicationTrackerScreenState extends ConsumerState<MedicationTrackerScreen> {
  final List<MedicationItem> _medications = [
    MedicationItem(
      id: 'med-1',
      name: 'تاموكسيفين (Tamoxifen)',
      dosage: '٢٠ مجم',
      instructions: 'قرص واحد يومياً مع الطعام بعد الإفطار',
      timeOfDay: 'صباحاً',
      scheduledTime: '٠٨:٠٠ ص',
      isTaken: true,
      takenTime: '٠٨:١٥ ص',
      dosesRemaining: 4,
    ),
    MedicationItem(
      id: 'med-2',
      name: 'فيتامين د٣ (Vitamin D3)',
      dosage: '١٠٠٠ وحدة دولية',
      instructions: 'كبسولة جيلاتينية مع وجبة دسمة',
      timeOfDay: 'صباحاً',
      scheduledTime: '٠٩:٠٠ ص',
      isTaken: false,
      dosesRemaining: 22,
    ),
    MedicationItem(
      id: 'med-3',
      name: 'سترات الكالسيوم (Calcium Citrate)',
      dosage: '٥٠٠ مجم',
      instructions: 'قرص واحد بعد الغداء بساعتين',
      timeOfDay: 'ظهراً',
      scheduledTime: '٠٢:٠٠ م',
      isTaken: false,
      dosesRemaining: 18,
    ),
    MedicationItem(
      id: 'med-4',
      name: 'ميلاتونين (Melatonin)',
      dosage: '٣ مجم',
      instructions: 'قرص قبل النوم بنصف ساعة عند الحاجة',
      timeOfDay: 'مساءً',
      scheduledTime: '٠٩:٣٠ م',
      isTaken: false,
      dosesRemaining: 14,
    ),
  ];

  int get _takenCount => _medications.where((m) => m.isTaken).length;
  double get _adherenceRatio => _medications.isEmpty ? 0 : _takenCount / _medications.length;

  void _toggleMedication(MedicationItem med) {
    setState(() {
      med.isTaken = !med.isTaken;
      if (med.isTaken) {
        final now = DateTime.now();
        med.takenTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      } else {
        med.takenTime = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          med.isTaken
              ? (context.isArabic ? 'أحسنتِ! تم تسجيل تناول ${med.name} 💊' : 'Logged ${med.name} as taken 💊')
              : (context.isArabic ? 'تم إلغاء تسجيل الجرعة' : 'Dosage marked pending'),
        ),
        backgroundColor: med.isTaken ? AppColors.success : AppColors.secondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddMedicationModal() {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    String timeOfDay = 'صباحاً';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.whiteSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.isArabic ? 'إضافة دواء جديد إلى الجدول' : 'Add New Medication',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: context.isArabic ? 'اسم الدواء' : 'Medication Name',
                  hintText: 'e.g. Tamoxifen',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: doseCtrl,
                decoration: InputDecoration(
                  labelText: context.isArabic ? 'الجرعة المقررة' : 'Dosage',
                  hintText: 'e.g. 20 mg',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: timeOfDay,
                decoration: InputDecoration(
                  labelText: context.isArabic ? 'التوقيت اليومي' : 'Time of Day',
                ),
                items: ['صباحاً', 'ظهراً', 'مساءً'].map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (val) {
                  if (val != null) timeOfDay = val;
                },
              ),
              const SizedBox(height: 20),
              PillButton(
                label: context.isArabic ? 'تأكيد الإضافة' : 'Confirm & Save',
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _medications.add(
                        MedicationItem(
                          id: 'med-${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          dosage: doseCtrl.text.trim().isEmpty ? 'حسب الوصفة' : doseCtrl.text.trim(),
                          instructions: 'حسب إرشادات الطبيب المعالج',
                          timeOfDay: timeOfDay,
                          scheduledTime: timeOfDay == 'صباحاً' ? '٠٨:٣٠ ص' : (timeOfDay == 'ظهراً' ? '٠١:٣٠ م' : '٠٩:٠٠ م'),
                          isTaken: false,
                          dosesRemaining: 30,
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: 2,
      titleKey: 'navCare',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Date Ribbon & Refill Alert
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Circular Progress Indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: _adherenceRatio,
                          strokeWidth: 8,
                          backgroundColor: AppColors.warmNeutralSand.withAlpha(100),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAction),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(_adherenceRatio * 100).round()}%',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                          Text(
                            context.isArabic ? 'التزام' : 'Taken',
                            style: const TextStyle(fontSize: 9, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.isArabic ? 'جدول الأدوية — اليوم' : "Today's Medication Schedule",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.mainText),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.isArabic
                              ? 'تم تناول $_takenCount من أصل ${_medications.length} جرعات مقررة اليوم.'
                              : '$_takenCount of ${_medications.length} scheduled doses completed.',
                          style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 8),
                        StatusBadge.active(context.isArabic ? 'اليوم: ٢٥ أكتوبر ٢٠٢٦' : 'Oct 25, 2026'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Refill Warning Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.warning.withAlpha(100), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.isArabic ? 'تنبيه إعادة صرف الدواء' : 'Prescription Refill Reminder',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.warning),
                        ),
                        Text(
                          context.isArabic
                              ? 'دواء تاموكسيفين: متبقي ٤ جرعات فقط. يرجى طلب إعادة الصرف من د. نور.'
                              : 'Tamoxifen: Only 4 doses remaining. Request refill from Dr. Nour.',
                          style: const TextStyle(fontSize: 12, color: AppColors.mainText),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      context.isArabic ? 'طلب صرف' : 'Refill',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Header with Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    context.isArabic ? 'جرعات اليوم المقررة' : 'Scheduled Doses',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddMedicationModal,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(context.isArabic ? 'إضافة دواء' : 'Add Med'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Doses List
            ..._medications.map((med) {
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Checkbox or Status Icon
                        InkWell(
                          onTap: () => _toggleMedication(med),
                          borderRadius: BorderRadius.circular(9999),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: med.isTaken ? AppColors.successContainer : AppColors.powderBackground,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: med.isTaken ? AppColors.success : AppColors.outline,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              med.isTaken ? Icons.check_rounded : Icons.medication_rounded,
                              color: med.isTaken ? AppColors.success : AppColors.primary,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      med.name,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.powderBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      med.dosage,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                med.instructions,
                                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                med.isTaken
                                    ? (context.isArabic ? 'تم تناولها في: ${med.takenTime}' : 'Taken at: ${med.takenTime}')
                                    : (context.isArabic ? 'الموعد: ${med.scheduledTime}' : 'Scheduled: ${med.scheduledTime}'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: med.isTaken ? AppColors.success : AppColors.primaryAction,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!med.isTaken) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _toggleMedication(med),
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                          label: Text(
                            context.isArabic ? 'تسجيل تناول الجرعة الآن 💊' : 'Mark Dose as Taken 💊',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryAction,
                            side: const BorderSide(color: AppColors.primaryAction),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
