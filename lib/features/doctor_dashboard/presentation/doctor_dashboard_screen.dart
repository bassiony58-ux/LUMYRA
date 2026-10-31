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
import '../../../core/widgets/scan_upload_dialog.dart';
import '../../../core/widgets/clinical_chat_sheet.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  bool _isLoadingAlerts = true;
  List<Map<String, dynamic>> _alerts = [
    {
      'id': 'alt-001',
      'priority': 'CRITICAL',
      'priorityLabel': 'حالة حرجة عاجلة',
      'priorityLabelEn': 'Critical Urgent',
      'patientName': 'سارة أحمد محمد',
      'patientNameEn': 'Sara Ahmed Mohamed',
      'title': 'اشتباه شعاعي يستلزم خزعة موجهة',
      'titleEn': 'Radiological suspicion requires targeted biopsy',
      'description': 'أظهر تحليل الفحص الأخير مؤشرات نسيجية غير نمطية (BI-RADS 4B) بحاجة لتنسيق موعد عاجل لأخذ عينة نسيجية.',
      'descriptionEn': 'Latest imaging analysis revealed atypical tissue indicators (BI-RADS 4B) requiring urgent coordination for a core needle biopsy.',
      'detectedAt': 'منذ ساعتين',
      'detectedAtEn': '2 hours ago',
    },
    {
      'id': 'alt-002',
      'priority': 'HIGH',
      'priorityLabel': 'أعراض تحذيرية',
      'priorityLabelEn': 'Warning Symptoms',
      'patientName': 'مريم علي حسن',
      'patientNameEn': 'Mariam Ali Hassan',
      'title': 'تسجيل أعراض تحذيرية في الاستبيان',
      'titleEn': 'Warning symptoms recorded in risk assessment',
      'description': 'أبلغت المريضة عن ظهور كتلة صلبة غير متحركة حديثة في الثدي الأيسر مع إفرازات حلمية غير معتادة.',
      'descriptionEn': 'Patient reported a new firm non-mobile breast lump in the left breast with unusual nipple discharge.',
      'detectedAt': 'منذ ٥ ساعات',
      'detectedAtEn': '5 hours ago',
    },
    {
      'id': 'alt-003',
      'priority': 'MODERATE',
      'priorityLabel': 'تنبيه التزام دوائي',
      'priorityLabelEn': 'Adherence Alert',
      'patientName': 'فاطمة حسن إبراهيم',
      'patientNameEn': 'Fatima Hassan Ibrahim',
      'title': 'تراجع الالتزام بالعلاج الهرموني',
      'titleEn': 'Declining adherence to endocrine therapy',
      'description': 'لم تسجل المريضة تناول جرعة التاموكسيفين المقررة لمدة 3 أيام متتالية. يوصى بإرسال رسالة تذكيرية.',
      'descriptionEn': 'Patient has not logged prescribed Tamoxifen intake for 3 consecutive days. A clinical reminder is recommended.',
      'detectedAt': 'منذ يوم',
      'detectedAtEn': '1 day ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchSmartAlerts();
  }

  Future<void> _fetchSmartAlerts() async {
    try {
      final client = ApiClient(tokenProvider: () => 'mock-doctor-uid:doctor@lumyra.test:DOCTOR');
      final res = await client.get('/doctors/me/smart-alerts');
      if (res is List && res.isNotEmpty && mounted) {
        setState(() {
          _alerts = List<Map<String, dynamic>>.from(res.map((a) => Map<String, dynamic>.from(a)));
          _isLoadingAlerts = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoadingAlerts = false);
  }

  Future<void> _openMessagingDialog({String? targetPatient}) async {
    await ClinicalChatSheet.show(
      context,
      isDoctor: true,
      otherPartyName: targetPatient,
    );
  }

  Future<void> _openAddClinicDialog() async {
    final isAr = context.isArabic;
    final nameController = TextEditingController(text: 'عيادة د. نور الخالدي لجراحة الأورام');
    final govController = TextEditingController(text: 'الجيزة');
    final cityController = TextEditingController(text: 'الشيخ زايد');
    final addressController = TextEditingController(text: 'مجمع تريفيوم الطبي، المحور المركزي، الشيخ زايد');
    final phoneController = TextEditingController(text: '01011223344');
    double lat = 30.0125;
    double lng = 30.9854;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAr ? 'إضافة / تعديل عيادتي على الخريطة' : 'Add My Clinic to Map',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: isAr ? 'اسم العيادة أو المركز' : 'Clinic Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: govController,
                      decoration: InputDecoration(
                        labelText: isAr ? 'المحافظة' : 'Governorate',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: isAr ? 'المدينة / الحي' : 'City',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: isAr ? 'العنوان التفصيلي' : 'Detailed Address',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: isAr ? 'رقم الهاتف / الحجز' : 'Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.powderBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAr ? 'الإحداثيات الجغرافية (GPS): $lat, $lng' : 'GPS Coordinates: $lat, $lng',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final client = ApiClient(tokenProvider: () => 'mock-doctor-uid:doctor@lumyra.test:DOCTOR');
                await client.post('/medical-centers/my-clinic', body: {
                  'nameAr': nameController.text.trim(),
                  'governorate': govController.text.trim(),
                  'city': cityController.text.trim(),
                  'address': addressController.text.trim(),
                  'phoneNumber': phoneController.text.trim(),
                  'latitude': lat,
                  'longitude': lng,
                  'specialties': ['Surgical Oncology', 'Early Detection', 'Biopsy'],
                });
              } catch (_) {}

              if (!mounted) return;
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(isAr ? 'تمت إضافة عيادتك على خريطة المراكز بنجاح' : 'Clinic published to map'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(isAr ? 'حفظ ونشر على الخريطة' : 'Save & Publish'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPublishArticleDialog() async {
    final isAr = context.isArabic;
    final titleController = TextEditingController();
    final summaryController = TextEditingController();
    final contentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAr ? 'إضافة مقال توعوي جديد (CMS)' : 'Publish Educational Article',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: isAr ? 'عنوان المقال الطبي' : 'Article Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: summaryController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: isAr ? 'ملخص المقال' : 'Summary',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: isAr ? 'المحتوى الطبي بالتفصيل' : 'Content Markdown',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final client = ApiClient(tokenProvider: () => 'mock-doctor-uid:doctor@lumyra.test:DOCTOR');
                await client.post('/educational/articles', body: {
                  'titleAr': titleController.text.trim(),
                  'summaryAr': summaryController.text.trim(),
                  'contentMarkdownAr': contentController.text.trim(),
                  'readTimeMinutes': 5,
                });
              } catch (_) {}

              if (!mounted) return;
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(isAr ? 'تم نشر المقال التوعوي بنجاح' : 'Article published'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(isAr ? 'نشر المقال' : 'Publish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 750;
    final isAr = context.isArabic;

    return AdaptiveScaffold(
      selectedIndex: 0,
      titleKey: 'roleDoctor',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoadingAlerts)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(minHeight: 2, color: AppColors.primary),
              ),

            // Welcome Header
            AppCard(
              color: AppColors.powderBackground,
              border: Border.all(color: AppColors.softDustyBlush),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.whiteSurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.medical_services_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? 'د. نور الخالدي' : 'Dr. Nour Al-Khalidi',
                              style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAr ? 'استشاري جراحة وأورام الثدي' : 'Breast Surgical Oncology',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusBadge.active(isAr ? 'طبيب معتمد' : 'Verified Doctor'),
                          const SizedBox(height: 2),
                          IconButton(
                            tooltip: isAr ? 'تسجيل الخروج' : 'Log out',
                            icon: const Icon(Icons.logout_rounded, color: AppColors.primary, size: 18),
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Text(isAr ? 'تسجيل الخروج' : 'Log Out', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  content: Text(isAr ? 'هل ترغب في تسجيل الخروج والعودة لشاشة الدخول؟' : 'Are you sure you want to log out?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isAr ? 'إلغاء' : 'Cancel')),
                                    FilledButton(
                                      style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(isAr ? 'خروج' : 'Log out'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                await ref.read(authSessionProvider.notifier).logout();
                                if (context.mounted) context.go('/auth/login');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'المعهد القومي للأورام • جامعة القاهرة' : 'National Cancer Institute • Cairo University',
                    style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Doctor Quick Actions Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.document_scanner_rounded, size: 18),
                    label: Text(
                      isAr ? 'تحليل الأشعة' : 'Scan Analysis',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    onPressed: () => ScanUploadDialog.show(context, isDoctor: true),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.softDustyBlush),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.chat_outlined, size: 18),
                    label: Text(
                      isAr ? 'الرسائل مع المريضات' : 'Patient Chat',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    onPressed: () => _openMessagingDialog(),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.softDustyBlush),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                    label: Text(
                      isAr ? 'إضافة عيادتي على الخريطة' : 'Add My Clinic',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    onPressed: _openAddClinicDialog,
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.softDustyBlush),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.post_add_rounded, size: 18),
                    label: Text(
                      isAr ? 'نشر مقال توعوي' : 'Publish Article',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    onPressed: _openPublishArticleDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Clinical Cohort Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: isAr ? 'المريضات المعينات' : 'My Patients',
                    value: isAr ? '٢٤' : '24',
                    subtitle: isAr ? 'مريضات نشطات' : 'Active patients',
                    icon: Icons.people_outline,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: isAr ? 'تنبيهات ذكية عاجلة' : 'Smart Alerts',
                    value: isAr ? '٣' : '3',
                    subtitle: isAr ? 'حالات تستلزم المتابعة' : 'Requires review',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.error,
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: isAr ? 'الفحوصات السريرية' : 'Pending Scans',
                      value: isAr ? '٥' : '5',
                      subtitle: isAr ? 'فحوصات ثانوية بانتظار التوقيع' : 'Awaiting sign-off',
                      icon: Icons.image_search_rounded,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // Live Smart Alerts Engine Section
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  isAr ? 'التنبيهات السريرية الذكية 🚨' : 'Clinical Smart Alerts 🚨',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.mainText),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${_alerts.length} ${isAr ? "حالات حرجة" : "urgent"}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.error),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._alerts.map((alert) {
              final priority = alert['priority'] as String? ?? 'MODERATE';
              final isCritical = priority == 'CRITICAL';
              final isHigh = priority == 'HIGH';

              final patientName = isAr ? (alert['patientName'] ?? '') : (alert['patientNameEn'] ?? alert['patientName'] ?? '');
              final priorityLabel = isAr ? (alert['priorityLabel'] ?? '') : (alert['priorityLabelEn'] ?? alert['priorityLabel'] ?? '');
              final title = isAr ? (alert['title'] ?? '') : (alert['titleEn'] ?? alert['title'] ?? '');
              final desc = isAr ? (alert['description'] ?? '') : (alert['descriptionEn'] ?? alert['description'] ?? '');

              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                border: Border.all(
                  color: isCritical
                      ? AppColors.error.withValues(alpha: 0.5)
                      : isHigh
                          ? AppColors.warning.withValues(alpha: 0.5)
                          : AppColors.softDustyBlush,
                  width: isCritical ? 1.5 : 1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCritical
                              ? Icons.dangerous_rounded
                              : isHigh
                                  ? Icons.warning_rounded
                                  : Icons.notifications_active_rounded,
                          color: isCritical
                              ? AppColors.error
                              : isHigh
                                  ? AppColors.warning
                                  : AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            patientName,
                            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isCritical)
                          StatusBadge.pending(priorityLabel)
                        else if (isHigh)
                          StatusBadge.info(priorityLabel)
                        else
                          StatusBadge.blush(priorityLabel),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                          label: Text(isAr ? 'مراسلة المريضة' : 'Message'),
                          onPressed: () => _openMessagingDialog(targetPatient: patientName),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCritical ? AppColors.error : AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          icon: const Icon(Icons.folder_open_rounded, size: 16),
                          label: Text(
                            isAr ? 'فتح الملف السريري' : 'Open Chart',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () => context.go('/doctor/patients'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // Secondary Scan Review Console Entry
            AppCard(
              padding: const EdgeInsets.all(16),
              color: AppColors.whiteSurface,
              border: Border.all(color: AppColors.softDustyBlush),
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
                        child: const Icon(Icons.image_search_outlined, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? 'وحدة المراجعة الإشعاعية الثانوية (DICOM / AI)' : 'Secondary Review Console',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAr
                                  ? 'استعراض صور السونار والماموجرام وإدارة سجل الفحوصات الطبية.'
                                  : 'Review ultrasound and mammography scans with full history management.',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: PillButton(
                      label: isAr ? 'فتح وحدة الأشعة والفحوصات' : 'Open Console',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => context.go('/doctor/imaging'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
