import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_badge.dart';

class DoctorApplicant {
  final String id;
  final String name;
  final String degrees;
  final String institution;
  final String syndicateNumber;
  final String applicationDate;
  bool isIdentityVerified;
  bool isLicenseVerified;
  bool isSpecialtyVerified;
  String status; // 'pending', 'approved', 'rejected'

  DoctorApplicant({
    required this.id,
    required this.name,
    required this.degrees,
    required this.institution,
    required this.syndicateNumber,
    required this.applicationDate,
    this.isIdentityVerified = true,
    this.isLicenseVerified = true,
    this.isSpecialtyVerified = false,
    this.status = 'pending',
  });
}

class DoctorApprovalsScreen extends ConsumerStatefulWidget {
  const DoctorApprovalsScreen({super.key});

  @override
  ConsumerState<DoctorApprovalsScreen> createState() => _DoctorApprovalsScreenState();
}

class _DoctorApprovalsScreenState extends ConsumerState<DoctorApprovalsScreen> {
  int _selectedTab = 0; // 0 = Pending, 1 = Approved, 2 = Rejected

  final List<DoctorApplicant> _doctors = [
    DoctorApplicant(
      id: 'doc-app-1',
      name: 'د. فريدة منصور',
      degrees: 'بكالوريوس الطب والجراحة، ماجستير جراحة الأورام — جامعة القاهرة',
      institution: 'مستشفى قصر العيني التعليمي الجديد ومعهد الأورام',
      syndicateNumber: '٤٨٢٩١ - نقابة أطباء مصر',
      applicationDate: '٢٣ أكتوبر ٢٠٢٦',
      isIdentityVerified: true,
      isLicenseVerified: true,
      isSpecialtyVerified: false,
      status: 'pending',
    ),
    DoctorApplicant(
      id: 'doc-app-2',
      name: 'د. طارق الجبالي',
      degrees: 'دكتوراه الأشعة التشخيصية والتداخلية للثدي — جامعة عين شمس',
      institution: 'مركز بهية لعلاج أورام الثدي',
      syndicateNumber: '٣١٩٠٤ - نقابة أطباء مصر',
      applicationDate: '٢٢ أكتوبر ٢٠٢٦',
      isIdentityVerified: true,
      isLicenseVerified: true,
      isSpecialtyVerified: false,
      status: 'pending',
    ),
    DoctorApplicant(
      id: 'doc-app-3',
      name: 'د. نور الخالدي',
      degrees: 'استشاري جراحة الأورام وأورام الثدي والترميم',
      institution: 'مستشفى بهية / المعهد القومي للأورام',
      syndicateNumber: '١٩٤٨٢ - نقابة أطباء مصر',
      applicationDate: '١٥ أكتوبر ٢٠٢٦',
      isIdentityVerified: true,
      isLicenseVerified: true,
      isSpecialtyVerified: true,
      status: 'approved',
    ),
  ];

  void _approveDoctor(DoctorApplicant doc) {
    setState(() {
      doc.status = 'approved';
      doc.isIdentityVerified = true;
      doc.isLicenseVerified = true;
      doc.isSpecialtyVerified = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.isArabic
              ? 'تم اعتماد ترخيص ${doc.name} وتفعيل حساب الطبيب على المنصة 🩺'
              : 'Doctor license approved and account activated 🩺',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _rejectDoctor(DoctorApplicant doc) {
    setState(() {
      doc.status = 'rejected';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.isArabic
              ? 'تم رفض الطلب وإرسال إشعار للمراجعة واستيفاء المستندات'
              : 'Doctor application flagged for document correction',
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusFilter = _selectedTab == 0 ? 'pending' : (_selectedTab == 1 ? 'approved' : 'rejected');
    final filtered = _doctors.where((d) => d.status == statusFilter).toList();

    return AdaptiveScaffold(
      selectedIndex: 1,
      titleKey: 'navApprovals',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.powderBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.isArabic ? 'مسار اعتماد تراخيص الأطباء' : 'Physician Credential Verification Pipeline',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.isArabic
                                  ? 'التدقيق الإلزامي لشهادات مزاولة المهنة، القيد بنقابة الأطباء، والمؤسسة العلاجية المعتمدة.'
                                  : 'Mandatory verification against Syndicate registry before cohort assignment.',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.whiteSurface,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AppColors.warmNeutralSand),
              ),
              child: Row(
                children: [
                  _buildTabButton(0, context.isArabic ? 'قيد المراجعة (٢)' : 'Pending (2)'),
                  _buildTabButton(1, context.isArabic ? 'تم الاعتماد (١)' : 'Approved (1)'),
                  _buildTabButton(2, context.isArabic ? 'المرفوضة (٠)' : 'Flagged (0)'),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Doctor Review Dossiers
            if (filtered.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    context.isArabic ? 'لا توجد طلبات في هذا القسم حالياً' : 'No applications found in this section',
                    style: const TextStyle(color: AppColors.secondaryText),
                  ),
                ),
              )
            else
              ...filtered.map((doc) {
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.powderBackground,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.softDustyBlush),
                            ),
                            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  doc.degrees,
                                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge.active(doc.status == 'approved' ? (context.isArabic ? 'معتمد' : 'Approved') : (context.isArabic ? 'بانتظار الفحص' : 'Pending Review')),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.badge_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            doc.syndicateNumber,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text(
                            'تاريخ التقديم: ${doc.applicationDate}',
                            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.business_rounded, size: 16, color: AppColors.secondaryText),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              doc.institution,
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Verification Checklist
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.powderBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            _buildCheckRow(
                              'التحقق من بطاقة الرقم القومي المصرية والهوية الشخصية',
                              doc.isIdentityVerified,
                              (val) => setState(() => doc.isIdentityVerified = val),
                            ),
                            _buildCheckRow(
                              'التحقق من رقم القيد وسريان كارنيه نقابة أطباء مصر',
                              doc.isLicenseVerified,
                              (val) => setState(() => doc.isLicenseVerified = val),
                            ),
                            _buildCheckRow(
                              'تأكيد التخصص السريري في جراحة/علاج أورام الثدي',
                              doc.isSpecialtyVerified,
                              (val) => setState(() => doc.isSpecialtyVerified = val),
                            ),
                          ],
                        ),
                      ),

                      if (doc.status == 'pending') ...[
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: PillButton(
                                label: context.isArabic ? 'اعتماد الترخيص وتفعيل الحساب' : 'Approve & Activate',
                                icon: Icons.check_circle_rounded,
                                onPressed: () => _approveDoctor(doc),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => _rejectDoctor(doc),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: Text(
                                context.isArabic ? 'طلب استيفاء' : 'Request Docs',
                                style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
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

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckRow(String text, bool isChecked, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.mainText),
            ),
          ),
        ],
      ),
    );
  }
}
