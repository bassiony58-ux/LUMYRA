import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_badge.dart';

class AuditLogEntry {
  final String id;
  final String timestamp;
  final String eventType;
  final String actor;
  final String target;
  final String ipAddress;
  final String status;
  final bool isBlocked;

  AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.eventType,
    required this.actor,
    required this.target,
    required this.ipAddress,
    required this.status,
    this.isBlocked = false,
  });
}

class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  String _selectedFilter = 'ALL';

  final List<AuditLogEntry> _logs = [
    AuditLogEntry(
      id: 'LOG-9921',
      timestamp: '١٤:٢٢:٠٥',
      eventType: 'PATIENT_RECORD_VIEW',
      actor: 'د. نور الخالدي (DOC-102)',
      target: 'الملف السريري للمريضة #PT-8831',
      ipAddress: '197.38.12.94 (القاهرة)',
      status: 'AUTHORIZED (طبيب المتابعة المعتمد)',
      isBlocked: false,
    ),
    AuditLogEntry(
      id: 'LOG-9920',
      timestamp: '١٣:١٠:٤٨',
      eventType: 'DICOM_IMAGE_DOWNLOAD',
      actor: 'د. نور الخالدي (DOC-102)',
      target: 'Mammogram_Scan_0924.dcm',
      ipAddress: '197.38.12.94 (القاهرة)',
      status: 'AUTHORIZED (رابط مؤقت مشفر ١٥ دقيقة)',
      isBlocked: false,
    ),
    AuditLogEntry(
      id: 'LOG-9919',
      timestamp: '١١:٠٥:١٢',
      eventType: 'UNAUTHORIZED_ACCESS_ATTEMPT',
      actor: 'مستخدم مجهول (IP خارجي)',
      target: '/api/v1/admin/doctor-approvals',
      ipAddress: '41.233.88.19 (الجيزة)',
      status: 'BLOCKED (403 Forbidden - صلاحية مرفوضة)',
      isBlocked: true,
    ),
    AuditLogEntry(
      id: 'LOG-9918',
      timestamp: '٠٩:٤٠:٢٠',
      eventType: 'QUESTIONNAIRE_SUBMISSION',
      actor: 'سارة أحمد محمود (PT-8831)',
      target: 'استبيان تقييم المخاطر الموجه v2',
      ipAddress: '156.204.55.10 (الإسكندرية)',
      status: 'RECORDED (مشفر في قاعدة بيانات PostgreSQL)',
      isBlocked: false,
    ),
    AuditLogEntry(
      id: 'LOG-9917',
      timestamp: '٠٨:١٥:٣٣',
      eventType: 'MEDICATION_LOG_UPDATE',
      actor: 'سارة أحمد محمود (PT-8831)',
      target: 'تاموكسيفين ٢٠ مجم (جرعة الصباح)',
      ipAddress: '156.204.55.10 (الإسكندرية)',
      status: 'RECORDED (تحديث سجل الالتزام)',
      isBlocked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == 'BLOCKED'
        ? _logs.where((l) => l.isBlocked).toList()
        : _logs;

    return AdaptiveScaffold(
      selectedIndex: 3,
      titleKey: 'navAnalytics',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Compliance & Security Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.whiteSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.softDustyBlush, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.powderBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.isArabic ? 'سجلات التدقيق والأمان السريري' : 'Clinical Security & Audit Logs',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.isArabic
                                  ? 'متوافق مع قانون حماية البيانات المصري ١٥١/٢٠٢٠ ومعايير HIPAA و GDPR.'
                                  : 'Compliant with Egyptian Law 151/2020, HIPAA, and GDPR standards.',
                              style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge.active('سجل غير قابل للتعديل'),
                    ],
                  ),
                  const Divider(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildSecurityPill('تشفير البيانات في السكون: AES-256', Icons.lock_outline_rounded),
                      _buildSecurityPill('روابط الأشعة: مؤقتة ١٥ دقيقة فقط', Icons.timer_outlined),
                      _buildSecurityPill('عزل الملفات الطبية: هوية المستخدم المعزولة', Icons.group_work_outlined),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Controls & Filter Bar
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.isArabic ? 'سجل العمليات الأخير (${filtered.length})' : 'Access Events Log (${filtered.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.mainText),
                  ),
                ),
                ChoiceChip(
                  label: Text(context.isArabic ? 'الكل' : 'All'),
                  selected: _selectedFilter == 'ALL',
                  selectedColor: AppColors.powderBackground,
                  backgroundColor: AppColors.whiteSurface,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: _selectedFilter == 'ALL' ? FontWeight.w700 : FontWeight.normal,
                    color: _selectedFilter == 'ALL' ? AppColors.primary : AppColors.secondaryText,
                  ),
                  onSelected: (_) => setState(() => _selectedFilter = 'ALL'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(context.isArabic ? 'المحظورة فقط' : 'Blocked Only'),
                  selected: _selectedFilter == 'BLOCKED',
                  selectedColor: AppColors.warningContainer,
                  backgroundColor: AppColors.whiteSurface,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: _selectedFilter == 'BLOCKED' ? FontWeight.w700 : FontWeight.normal,
                    color: _selectedFilter == 'BLOCKED' ? AppColors.error : AppColors.secondaryText,
                  ),
                  onSelected: (_) => setState(() => _selectedFilter = 'BLOCKED'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Logs Table / Cards
            ...filtered.map((log) {
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: log.isBlocked ? AppColors.error.withAlpha(20) : AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            log.eventType,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: log.isBlocked ? AppColors.error : AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.schedule_rounded, size: 14, color: AppColors.secondaryText),
                        const SizedBox(width: 4),
                        Text(
                          log.timestamp,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, size: 16, color: AppColors.secondaryText),
                        const SizedBox(width: 6),
                        Text(
                          'المستخدم: ${log.actor}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.adjust_rounded, size: 16, color: AppColors.secondaryText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'الهدف: ${log.target}',
                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.lan_outlined, size: 16, color: AppColors.secondaryText),
                        const SizedBox(width: 6),
                        Text(
                          'عنوان IP: ${log.ipAddress}',
                          style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Icon(
                          log.isBlocked ? Icons.block_rounded : Icons.check_circle_rounded,
                          size: 16,
                          color: log.isBlocked ? AppColors.error : AppColors.success,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            log.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: log.isBlocked ? AppColors.error : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),
            PillButton(
              label: context.isArabic ? 'تصدير تقرير التدقيق المشفر (CSV/PDF)' : 'Export Encrypted Audit Report',
              icon: Icons.download_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.isArabic ? 'تم تجهيز تقرير التدقيق المشفر للتنزيل 📄' : 'Encrypted audit report ready 📄',
                    ),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityPill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.powderBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warmNeutralSand),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 11, color: AppColors.mainText)),
        ],
      ),
    );
  }
}
