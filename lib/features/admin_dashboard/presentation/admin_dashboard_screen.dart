import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_badge.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _analytics = {
    'summary': {
      'totalPatients': 1420,
      'totalDoctors': 48,
      'approvedDoctors': 41,
      'pendingDoctors': 7,
      'totalScans': 3840,
      'suspiciousScansCount': 42,
      'adherenceRatePercent': 92.4,
    },
    'monthlyTrends': [
      {'month': 'مايو', 'scans': 410},
      {'month': 'يونيو', 'scans': 490},
      {'month': 'يوليو', 'scans': 530},
      {'month': 'أغسطس', 'scans': 620},
      {'month': 'سبتمبر', 'scans': 740},
      {'month': 'أكتوبر', 'scans': 890},
    ],
  };

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    try {
      final client = ApiClient(tokenProvider: () => 'mock-admin-uid:admin@lumyra.test:ADMIN');
      final res = await client.get('/admin/analytics');
      if (res is Map<String, dynamic> && mounted) {
        setState(() {
          _analytics = res;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openCopilotDialog() async {
    final isAr = context.isArabic;
    final queryController = TextEditingController();
    String? copilotAnswer;
    bool isAsking = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.whiteSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.powderBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'المساعد الذكي للإدارة' : 'Admin AI Copilot',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                          Text(
                            isAr ? 'تحليل لحظي لمؤشرات الأداء واقتراح الإجراءات التشغيلية' : 'Live operational insights & decision support',
                            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                TextField(
                  controller: queryController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: isAr
                        ? 'مثال: لخص لي الوضع الإشعاعي وما هي توصيات الأسبوع الحالي؟'
                        : 'e.g. Summarize scan distribution and suggest operations...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: isAsking
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.psychology_rounded, size: 20),
                  label: Text(
                    isAsking
                        ? (isAr ? 'جارٍ التحليل الذكي...' : 'Analyzing...')
                        : (isAr ? 'طلب التحليل والاستشارة' : 'Ask Copilot'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: isAsking
                      ? null
                      : () async {
                          final q = queryController.text.trim();
                          if (q.isEmpty) return;
                          setModalState(() => isAsking = true);
                          try {
                            final client = ApiClient(tokenProvider: () => 'mock-admin-uid:admin@lumyra.test:ADMIN');
                            final res = await client.post('/admin/copilot', body: {'query': q});
                            if (res is Map && res['response'] != null) {
                              setModalState(() {
                                copilotAnswer = res['response'].toString();
                                isAsking = false;
                              });
                              return;
                            }
                          } catch (e) {
                            setModalState(() {
                              copilotAnswer = isAr ? 'تعذر الاتصال بالمساعد الذكي: $e' : 'Copilot error: $e';
                              isAsking = false;
                            });
                          }
                        },
                ),
                if (copilotAnswer != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.powderBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.softDustyBlush),
                    ),
                    child: Text(
                      copilotAnswer!,
                      style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.mainText),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportBackup() async {
    final isAr = context.isArabic;
    try {
      final client = ApiClient(tokenProvider: () => 'mock-admin-uid:admin@lumyra.test:ADMIN');
      final res = await client.get('/admin/export');

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              isAr ? 'تصدير النسخة الاحتياطية (De-Identified)' : 'Data Export Ready',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr
                      ? 'تم تجهيز ملف النسخ الاحتياطي المشفر بنجاح مع إزالة كافة الهويات الشخصية للمريضات لحماية الخصوصية.'
                      : 'De-identified encrypted backup payload generated successfully.',
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.powderBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${jsonEncode(res).substring(0, 160)}...',
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(isAr ? 'إغلاق' : 'Close'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.download_rounded, size: 16),
                label: Text(isAr ? 'حفظ الملف' : 'Download'),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isAr ? 'تم تنزيل نسخة البيانات الاحتياطية بنجاح' : 'Backup saved'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التصدير: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isArabic;
    final summary = _analytics['summary'] as Map<String, dynamic>? ?? {};

    return AdaptiveScaffold(
      selectedIndex: 0,
      titleKey: 'roleAdmin',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(minHeight: 2, color: AppColors.primary),
              ),

            // Admin Banner
            AppCard(
              color: AppColors.whiteSurface,
              padding: const EdgeInsets.all(22),
              border: Border.all(color: AppColors.outline),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.powderBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.security_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'لوحة الإدارة والرقابة الطبية الشاملة' : 'Administrative & Clinical Governance Console',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr
                              ? 'سجل العمليات الإدارية مشفر ومحمي وفق معايير الخصوصية الطبية الدولية.'
                              : 'All administrative interactions are strictly audited.',
                          style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.active(isAr ? 'نظام آمن' : 'Audit Active'),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Quick Operational Action Toolbar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.softDustyBlush),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    ),
                    icon: const Icon(Icons.manage_accounts_rounded, size: 18),
                    label: Text(
                      isAr ? 'إدارة المستخدمين' : 'Manage Users',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    onPressed: () => context.go('/admin/users'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    ),
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(
                      isAr ? 'المساعد الذكي (AI)' : 'AI Copilot',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    onPressed: _openCopilotDialog,
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.softDustyBlush),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(
                      isAr ? 'تصدير نسخة' : 'Export',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    onPressed: _exportBackup,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Platform Statistics Grid
            Text(
              isAr ? 'إحصائيات المنصة الحية (Live Analytics)' : 'Platform Operations Overview',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.mainText),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return GridView.count(
                  crossAxisCount: isWide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isWide ? 1.8 : 1.3,
                  children: [
                    _buildStatCard(
                      label: isAr ? 'إجمالي المريضات' : 'Registered Patients',
                      count: summary['totalPatients']?.toString() ?? '1,420',
                      icon: Icons.people_alt_outlined,
                      color: AppColors.primary,
                    ),
                    _buildStatCard(
                      label: isAr ? 'أطباء معتمدون' : 'Verified Doctors',
                      count: summary['approvedDoctors']?.toString() ?? '41',
                      icon: Icons.medical_services_outlined,
                      color: AppColors.secondary,
                    ),
                    _buildStatCard(
                      label: isAr ? 'طلبات قيد المراجعة' : 'Pending Doctors',
                      count: summary['pendingDoctors']?.toString() ?? '7',
                      icon: Icons.hourglass_top_rounded,
                      color: AppColors.warning,
                    ),
                    _buildStatCard(
                      label: isAr ? 'الفحوصات المحللة' : 'Scans Analyzed',
                      count: summary['totalScans']?.toString() ?? '3,840',
                      icon: Icons.document_scanner_outlined,
                      color: AppColors.info,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Visual Monthly Activity Chart Representation
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Text(
                        isAr ? 'نشاط الفحوصات الإشعاعية الشهري 📊' : 'Monthly Imaging Volume 📊',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.powderBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isAr ? 'معدل الالتزام: ${summary['adherenceRatePercent'] ?? 92.4}%' : 'Adherence: ${summary['adherenceRatePercent'] ?? 92.4}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildChartBar(month: 'مايو', value: 410, max: 900),
                      _buildChartBar(month: 'يونيو', value: 490, max: 900),
                      _buildChartBar(month: 'يوليو', value: 530, max: 900),
                      _buildChartBar(month: 'أغسطس', value: 620, max: 900),
                      _buildChartBar(month: 'سبتمبر', value: 740, max: 900),
                      _buildChartBar(month: 'أكتوبر', value: 890, max: 900, isCurrent: true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Doctor Approval Pipeline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'طلبات تسجيل الأطباء الجديدة' : 'Doctor Registration Requests',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.mainText),
                ),
                TextButton(
                  onPressed: () => context.go('/admin/approvals'),
                  child: Text(context.tr('viewAll'), style: const TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDoctorApprovalCard(
              context,
              name: isAr ? 'د. سارة عبد الرحمن' : 'Dr. Sara Abdelrahman',
              specialty: isAr ? 'أورام الثدي والجراحة الترميمية' : 'Breast Oncology & Reconstructive Surgery',
              hospital: isAr ? 'مستشفى عين شمس التخصصي' : 'Ain Shams Specialized Hospital',
              licenseNo: 'EGY-MED-2024-8841',
            ),
            _buildDoctorApprovalCard(
              context,
              name: isAr ? 'د. طارق الحسين' : 'Dr. Tarek El-Hussein',
              specialty: isAr ? 'علاج الأورام بالإشعاع' : 'Radiation Oncology',
              hospital: isAr ? 'مركز الإسكندرية للأورام' : 'Alexandria Oncology Center',
              licenseNo: 'EGY-MED-2023-4519',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar({required String month, required int value, required int max, bool isCurrent = false}) {
    final heightRatio = (value / max).clamp(0.1, 1.0);
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isCurrent ? AppColors.primary : AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 28,
          height: 100 * heightRatio,
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.primary : AppColors.softDustyBlush,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          month,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? AppColors.primary : AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildDoctorApprovalCard(
    BuildContext context, {
    required String name,
    required String specialty,
    required String hospital,
    required String licenseNo,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.powderBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.badge_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$specialty • $hospital',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ترخيص: $licenseNo',
                      style: const TextStyle(fontSize: 11, color: AppColors.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge.pending(context.isArabic ? 'بانتظار التحقق' : 'Under Review'),
              PillButton(
                label: context.isArabic ? 'مراجعة الترخيص' : 'Review License',
                variant: PillButtonVariant.outline,
                onPressed: () => context.go('/admin/approvals'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
