import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/scan_upload_dialog.dart';
import '../../../core/widgets/clinical_chat_sheet.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../domain/models/patient_dashboard_data.dart';
import 'providers/patient_dashboard_provider.dart';

class PatientDashboardScreen extends ConsumerWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompact = MediaQuery.of(context).size.width < 750;
    final dashboardAsync = ref.watch(patientDashboardProvider);

    return AdaptiveScaffold(
      selectedIndex: 0,
      titleKey: 'navHome',
      actions: [
        IconButton(
          onPressed: () => ref.read(patientDashboardProvider.notifier).refresh(),
          icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          tooltip: context.isArabic ? 'تحديث البيانات' : 'Refresh',
        ),
        IconButton(
          onPressed: () async {
            await ref.read(authSessionProvider.notifier).logout();
            if (context.mounted) context.go('/auth/login');
          },
          icon: const Icon(Icons.logout_rounded, color: AppColors.secondaryText),
          tooltip: context.isArabic ? 'تسجيل الخروج' : 'Logout',
        ),
      ],
      body: dashboardAsync.when(
        loading: () => _buildLoadingState(context),
        error: (err, _) => _buildErrorState(context, ref, err),
        data: (data) => _buildDashboardContent(context, ref, data, isCompact),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            context.isArabic
                ? 'جاري تحميل بياناتكِ الصحية بأمان...'
                : 'Loading your health dashboard securely...',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AppCard(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                context.isArabic ? 'تعذر تحميل بيانات اللوحة' : 'Unable to load dashboard data',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.mainText),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 20),
              PillButton(
                label: context.isArabic ? 'إعادة المحاولة' : 'Retry',
                icon: Icons.refresh_rounded,
                onPressed: () => ref.read(patientDashboardProvider.notifier).refresh(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    PatientDashboardData data,
    bool isCompact,
  ) {
    final patientName = data.profile.displayName.isNotEmpty
        ? data.profile.displayName
        : (context.isArabic ? 'صديقتنا' : 'Friend');

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(patientDashboardProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Personalized Greeting Hero Card
            AppCard(
              color: AppColors.powderBackground,
              border: Border.all(color: AppColors.softDustyBlush, width: 1.5),
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusBadge.blush(
                              context.isArabic ? 'رحلة الرعاية والتعافي' : 'Care & Wellness Journey',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${context.tr('greeting')}، $patientName 🌸',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.isArabic
                              ? 'نتمنى لكِ يوماً هادئاً ومطمئناً. تذكري أنكِ لستِ وحدكِ في هذه الرحلة.'
                              : 'Wishing you a calm, restful day. Remember, you are never alone on this path.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.secondaryText,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isCompact) ...[
                    const SizedBox(width: 20),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.whiteSurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded, color: AppColors.primaryAction, size: 40),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Unified Medical Records & Scans Upload Card (Uncluttered & Responsive)
            AppCard(
              padding: const EdgeInsets.all(20),
              border: Border.all(color: AppColors.primary.withAlpha(70), width: 1.5),
              color: AppColors.powderBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.folder_shared_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusBadge.blush(
                              context.isArabic ? 'السجل الطبي • فحص ذكي' : 'Health Records • AI Scan',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.isArabic
                                  ? 'سجل الفحوصات والتقارير الطبية 🌸'
                                  : 'Medical Records & Scans Hub',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.isArabic
                        ? 'ارفعي أي فحص أو تقرير (صورة، PDF، سونار، ماموجرام، تحاليل، أو خزعة) وسيتعرف عليه النظام ويفحصه فوراً.'
                        : 'Upload any file (image, PDF, ultrasound, mammogram, biopsy, labs) for automated AI reading.',
                    style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  PillButton(
                    label: context.isArabic ? 'رفع وفحص تقرير الآن' : 'Upload & Analyze Document',
                    icon: Icons.cloud_upload_rounded,
                    onPressed: () => ScanUploadDialog.show(context, isDoctor: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 30-Day Periodic Health Assessment Reminder Card
            AppCard(
              padding: const EdgeInsets.all(16),
              color: AppColors.powderBackground,
              border: Border.all(color: AppColors.softDustyBlush),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.whiteSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.health_and_safety_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.isArabic
                              ? 'التقييم الدوري لصحة الثدي (كل 30 يوماً) 🌸'
                              : 'Periodic Assessment (Every 30 Days)',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.primary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.isArabic
                              ? 'متابعة دورية لحالتكِ الصحية وتحديث المؤشرات'
                              : 'Routine follow-up on your indicators and wellness',
                          style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => context.go('/patient/risk'),
                    child: Text(
                      context.isArabic ? 'بدء التقييم' : 'Start Check',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Quick Actions
            Text(
              context.tr('quickActions'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.mainText),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: constraints.maxWidth < 600 ? 1.25 : 1.1,
                  children: [
                    _QuickActionTile(
                      icon: Icons.shield_outlined,
                      labelKey: 'takeRiskAssessment',
                      onTap: () => context.go('/patient/risk'),
                    ),
                    _QuickActionTile(
                      icon: Icons.edit_note_rounded,
                      labelKey: 'writeInJournal',
                      onTap: () => context.go('/patient/journal'),
                    ),
                    _QuickActionTile(
                      icon: Icons.location_on_outlined,
                      labelKey: 'exploreCenters',
                      onTap: () => context.go('/patient/centers'),
                    ),
                    _QuickActionTile(
                      icon: Icons.spa_outlined,
                      labelKey: 'askAssistant',
                      onTap: () => context.go('/patient/assistant'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Doctor Direct Chat & Voice Notes Card
            _buildDoctorChatCard(context),
            const SizedBox(height: 24),

            // 3. Upcoming Appointments & Medication Cards (Adaptive Grid / Row)
            if (!isCompact)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildAppointmentSection(context, data.upcomingAppointments)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMedicationSection(context, data.activeMedications)),
                ],
              )
            else ...[
              _buildAppointmentSection(context, data.upcomingAppointments),
              const SizedBox(height: 16),
              _buildMedicationSection(context, data.activeMedications),
            ],

            const SizedBox(height: 24),

            // 4. Health Education Recommendations (Real from Backend)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    context.tr('healthArticles'),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.mainText),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/patient/education'),
                  child: Text(
                    context.tr('viewAll'),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (data.recommendedArticles.isEmpty)
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    context.isArabic
                        ? 'لا توجد مقالات مقترحة في الوقت الحالي.'
                        : 'No article recommendations available at the moment.',
                    style: const TextStyle(color: AppColors.secondaryText),
                  ),
                ),
              )
            else
              ...data.recommendedArticles.map(
                (art) => _buildEducationalCard(
                  title: context.isArabic ? art.titleAr : art.titleEn,
                  category: context.isArabic ? art.categoryNameAr : art.categoryNameEn,
                  readTime: context.isArabic
                      ? '${art.readTimeMinutes} دقائق قراءة'
                      : '${art.readTimeMinutes} min read',
                  onTap: () => context.go('/patient/education'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorChatCard(BuildContext context) {
    final isAr = context.isArabic;
    return AppCard(
      padding: const EdgeInsets.all(18),
      color: AppColors.powderBackground,
      border: Border.all(color: AppColors.primary.withAlpha(80), width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusBadge.blush(
                      isAr ? 'مراسلة الطبيب • محادثة وفويسات' : 'Doctor Chat • Voice & Text',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAr
                          ? 'مراسلة أ.د. نور الخالدي 🩺'
                          : 'Message Dr. Nour El-Khaledy 🩺',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr
                          ? 'استشاري جراحة أورام الثدي - تواصل سريري واستشارات صوتية'
                          : 'Breast Oncology Consultant - Direct voice notes & chat',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PillButton(
            label: isAr ? 'فتح المحادثة وإرسال فويس' : 'Open Chat & Send Voice Note',
            icon: Icons.mic_rounded,
            onPressed: () {
              ClinicalChatSheet.show(
                context,
                isDoctor: false,
                otherPartyName: isAr ? 'أ.د. نور الخالدي' : 'Dr. Nour El-Khaledy',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentSection(BuildContext context, List<UpcomingAppointment> appointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                context.tr('upcomingAppointments'),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.mainText),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/patient/care'),
              child: Text(context.tr('viewAll'), style: const TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (appointments.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.event_busy_rounded, color: AppColors.outline, size: 40),
                const SizedBox(height: 12),
                Text(
                  context.isArabic
                      ? 'لا توجد مواعيد قادمة مسجلة حالياً'
                      : 'No upcoming appointments scheduled',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.isArabic
                      ? 'احجزي موعداً مع طبيبكِ المعتمد للمتابعة الدورية.'
                      : 'Schedule a visit with your physician for routine follow-up.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 16),
                PillButton(
                  label: context.isArabic ? 'حجز موعد' : 'Book Appointment',
                  icon: Icons.calendar_today_rounded,
                  onPressed: () => context.go('/patient/care'),
                ),
              ],
            ),
          )
        else
          ...appointments.map((appt) {
            final formattedDate = DateFormat('EEEE d MMMM, hh:mm a', context.isArabic ? 'ar' : 'en')
                .format(appt.scheduledAt);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
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
                          child: const Icon(Icons.event_available, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appt.doctorName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                appt.reason.isNotEmpty ? appt.reason : appt.specialty,
                                style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge.active(appt.status),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFF3E4E8)),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 16, color: AppColors.secondaryText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            formattedDate,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mainText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMedicationSection(BuildContext context, List<MedicationReminder> medications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                context.isArabic ? 'الأدوية المقررة والنشطة' : 'Active Medications',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.mainText),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/patient/care'),
              child: Text(context.tr('viewAll'), style: const TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (medications.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.medication_outlined, color: AppColors.outline, size: 40),
                const SizedBox(height: 12),
                Text(
                  context.isArabic
                      ? 'لا توجد أدوية مسجلة في جدولكِ'
                      : 'No medications in your schedule',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.isArabic
                      ? 'أضيفي أدويتكِ لتلقي تذكيرات يومية منتظمة.'
                      : 'Add your prescribed medications to receive regular reminders.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 16),
                PillButton(
                  label: context.isArabic ? 'إضافة دواء' : 'Add Medication',
                  icon: Icons.add_rounded,
                  onPressed: () => context.go('/patient/care'),
                ),
              ],
            ),
          )
        else
          ...medications.map((med) {
            final times = med.timeOfDay.isNotEmpty ? med.timeOfDay.join(' • ') : med.frequency;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBECEF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.medication_rounded, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${med.dosage} — $times',
                            style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.softDustyBlush, size: 28),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildEducationalCard({
    required String title,
    required String category,
    required String readTime,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge.blush(category),
                      const SizedBox(width: 8),
                      Text(
                        readTime,
                        style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mainText,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.softDustyBlush),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String labelKey;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.labelKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.powderBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              context.tr(labelKey),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.mainText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
