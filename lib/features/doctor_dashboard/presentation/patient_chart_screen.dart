import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_badge.dart';

class PatientChartScreen extends ConsumerStatefulWidget {
  const PatientChartScreen({super.key});

  @override
  ConsumerState<PatientChartScreen> createState() => _PatientChartScreenState();
}

class _PatientChartScreenState extends ConsumerState<PatientChartScreen> {
  final TextEditingController _clinicalNotesController = TextEditingController();
  final List<String> _notesList = [
    'المريضة منتظمة على علاج التاموكسيفين بنسبة ٨٥٪. تشكو من وخز خفيف بالثدي الأيمن تم فحصه سريرياً ولا توجد أي كتل مجسوسة جديدة.',
    'تم التوصية بإجراء تصوير بالموجات فوق الصوتية مكمل للماموجرام لمتابعة التباين النسيجي في الربع العلوي الخارجي.',
  ];

  @override
  void dispose() {
    _clinicalNotesController.dispose();
    super.dispose();
  }

  void _addClinicalNote() {
    if (_clinicalNotesController.text.trim().isEmpty) return;
    setState(() {
      _notesList.insert(0, _clinicalNotesController.text.trim());
      _clinicalNotesController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.isArabic ? 'تم حفظ الملاحظة الإكلينيكية في سجل المريضة 📋' : 'Clinical note added to chart 📋',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: 1,
      titleKey: 'navPatients',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Bio Card
            AppCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.powderBackground,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                const Text(
                                  'سارة أحمد محمود',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                StatusBadge.active('مريضة متابعة'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'العمر: ٤٢ سنة • ملف طبي: #PT-8831 • فصيلة الدم: A+',
                              style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'التشخيص السريري: Stage I ER+/PR+ HER2- (تحت المتابعة والعلاج الهرموني)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBioMetricChip('نسبة الالتزام بالأدوية', '٨٥٪ (ممتاز)', Icons.medication_rounded),
                      _buildBioMetricChip('آخر تصوير ماموجرام', '١٥ أكتوبر ٢٠٢٦', Icons.document_scanner_rounded),
                      _buildBioMetricChip('تاريخ الاستبيان', 'مكتمل (٢٤ أكتوبر)', Icons.assignment_turned_in_rounded),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Clinical Timeline
            Text(
              context.isArabic ? 'المسار الإكلينيكي والفحوصات الأخيرة' : 'Clinical History & Assessments',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.mainText),
            ),
            const SizedBox(height: 12),

            _buildTimelineItem(
              title: 'فحص الماموجرام والموجات الصوتية الأخير',
              date: '١٥ أكتوبر ٢٠٢٦ • مركز بهية للأشعة',
              description: 'كثافة نسيجية Category C. لوحظ تباين بؤري خفيف في الربع العلوي الخارجي الأيمن (UOQ). يوصى بالمتابعة الدورية.',
              badgeText: 'أشعة حديثة',
              badgeColor: AppColors.info,
            ),
            _buildTimelineItem(
              title: 'ملخص استبيان عوامل الخطورة الإرشادي',
              date: '٢٤ أكتوبر ٢٠٢٦ • إجابات المريضة الموثقة',
              description: 'تاريخ عائلي من الدرجة الأولى (إصابة الوالدة في سن ٥٢). سن البلوغ ١٣. ولادة أول طفل في سن ٢٥. الرضاعة الطبيعية أكثر من ١٢ شهراً.',
              badgeText: 'استبيان معتمد',
              badgeColor: AppColors.success,
            ),
            _buildTimelineItem(
              title: 'ملاحظات يوميات الأعراض الخاصة بالمريضة',
              date: '٢٣ أكتوبر ٢٠٢٦ • المسجلة عبر التطبيق',
              description: 'سجلت المريضة شعوراً بإرهاق ووخز خفيف (مستوى الألم ٤/١٠). لا توجد إفرازات أو تغيرات جلدية ملحوظة.',
              badgeText: 'يوميات المريضة',
              badgeColor: AppColors.warning,
            ),

            const SizedBox(height: 18),

            // Clinical Notes Section
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.isArabic ? 'إضافة ملاحظة إكلينيكية جديدة للملف' : 'Add Physician Progress Note',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _clinicalNotesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: context.isArabic
                          ? 'أدخلي تقييم الزيارة الإكلينيكية، الخطة العلاجية، أو توصيات الفحص القادم...'
                          : 'Enter clinical assessment, plan, or follow-up recommendations...',
                      fillColor: AppColors.powderBackground,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.warmNeutralSand),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  PillButton(
                    label: context.isArabic ? 'حفظ الملاحظة في السجل الطبي' : 'Save Note to Patient Chart',
                    icon: Icons.save_rounded,
                    onPressed: _addClinicalNote,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.isArabic ? 'ملاحظات الطبيب السابقة:' : 'Physician Progress Notes History:',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ..._notesList.map((note) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.powderBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.warmNeutralSand),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes_rounded, size: 20, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(note, style: const TextStyle(fontSize: 13, height: 1.4)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioMetricChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.powderBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warmNeutralSand),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mainText),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String date,
    required String description,
    required String badgeText,
    required Color badgeColor,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor),
                ),
              ),
              const Spacer(),
              Text(date, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.4)),
        ],
      ),
    );
  }
}
