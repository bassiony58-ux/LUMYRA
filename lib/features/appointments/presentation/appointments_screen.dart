import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_badge.dart';

class AppointmentRecord {
  final String id;
  final String doctorName;
  final String doctorTitle;
  final String facility;
  final String date;
  final String time;
  final String type;
  final bool isUpcoming;

  AppointmentRecord({
    required this.id,
    required this.doctorName,
    required this.doctorTitle,
    required this.facility,
    required this.date,
    required this.time,
    required this.type,
    this.isUpcoming = true,
  });
}

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  int _selectedTabIndex = 0; // 0 = Upcoming, 1 = Past
  String _selectedConsultationType = 'متابعة دورية';
  String _selectedTimeSlot = '١٠:٣٠ ص';

  final List<AppointmentRecord> _appointments = [
    AppointmentRecord(
      id: 'apt-1',
      doctorName: 'د. نور الخالدي',
      doctorTitle: 'استشاري جراحة الأورام وصحة الثدي',
      facility: 'مستشفى بهية — فرع الشيخ زايد',
      date: 'الثلاثاء، ٢٨ أكتوبر ٢٠٢٦',
      time: '١٠:٣٠ ص',
      type: 'متابعة إكلينيكية دورية',
      isUpcoming: true,
    ),
    AppointmentRecord(
      id: 'apt-2',
      doctorName: 'د. مريم القاضي',
      doctorTitle: 'استشاري الأشعة التشخيصية للأورام',
      facility: 'المعهد القومي للأورام — القاهرة',
      date: 'الخميس، ١٥ أكتوبر ٢٠٢٦',
      time: '١١:٠٠ ص',
      type: 'مناقشة تقرير الماموجرام والموجات الصوتية',
      isUpcoming: false,
    ),
    AppointmentRecord(
      id: 'apt-3',
      doctorName: 'د. سارة عزمي',
      doctorTitle: 'أخصائية التغذية العلاجية والدعم السريري',
      facility: 'استشارة فيديو مرئية عبر لوميرا',
      date: 'الاثنين، ٠٥ أكتوبر ٢٠٢٦',
      time: '٠٦:٠٠ م',
      type: 'خطة تغذية وقائية أثناء العلاج',
      isUpcoming: false,
    ),
  ];

  final List<String> _consultationTypes = [
    'متابعة دورية',
    'رأي طبي ثانٍ',
    'مناقشة فحص أشعة',
    'استشارة فيديو عن بُعد',
  ];

  final List<String> _timeSlots = [
    '٠٩:٠٠ ص',
    '١٠:٣٠ ص',
    '٠١:٠٠ م',
    '٠٣:٣٠ م',
    '٠٥:٠٠ م',
  ];

  void _bookNewAppointment() {
    setState(() {
      _appointments.insert(
        0,
        AppointmentRecord(
          id: 'apt-${DateTime.now().millisecondsSinceEpoch}',
          doctorName: 'د. نور الخالدي',
          doctorTitle: 'استشاري جراحة الأورام وصحة الثدي',
          facility: 'مستشفى بهية — فرع الشيخ زايد',
          date: 'الأربعاء، ٢٩ أكتوبر ٢٠٢٦',
          time: _selectedTimeSlot,
          type: _selectedConsultationType,
          isUpcoming: true,
        ),
      );
      _selectedTabIndex = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.isArabic ? 'تم تأكيد حجز الموعد بنجاح وإرسال التفاصيل 🗓️' : 'Appointment confirmed successfully 🗓️',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAppointments = _appointments.where((a) => a.isUpcoming == (_selectedTabIndex == 0)).toList();

    return AdaptiveScaffold(
      selectedIndex: 4,
      titleKey: 'navCare',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tabs Ribbon
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.powderBackground,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AppColors.warmNeutralSand),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTabIndex = 0),
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 0 ? AppColors.whiteSurface : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: _selectedTabIndex == 0
                              ? [const BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          context.isArabic ? 'المواعيد القادمة (١)' : 'Upcoming (1)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _selectedTabIndex == 0 ? AppColors.primary : AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 1 ? AppColors.whiteSurface : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: _selectedTabIndex == 1
                              ? [const BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          context.isArabic ? 'المواعيد السابقة (٢)' : 'Past Consultations (2)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _selectedTabIndex == 1 ? AppColors.primary : AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Appointments List
            ...filteredAppointments.map((apt) {
              return AppCard(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
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
                                apt.doctorName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                apt.doctorTitle,
                                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge.active(apt.isUpcoming ? (context.isArabic ? 'مؤكد' : 'Confirmed') : (context.isArabic ? 'مكتمل' : 'Completed')),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          '${apt.date} • ${apt.time}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.mainText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.secondaryText),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            apt.facility,
                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                          ),
                        ),
                      ],
                    ),
                    if (apt.isUpcoming) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: PillButton(
                              label: context.isArabic ? 'تفاصيل العيادة والوصول' : 'Directions & Details',
                              icon: Icons.directions_rounded,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.outline),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: Text(
                              context.isArabic ? 'تأجيل الموعد' : 'Reschedule',
                              style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Booking Form Section
            AppCard(
              padding: const EdgeInsets.all(22),
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
                        child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.isArabic ? 'حجز استشارة أو فحص جديد' : 'Book a New Consultation',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                            Text(
                              context.isArabic
                                  ? 'اختاري نوع الزيارة والتوقيت المناسب لكِ'
                                  : 'Select consultation type and your preferred slot',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Consultation Type Chips
                  Text(
                    context.isArabic ? 'نوع الاستشارة:' : 'Consultation Type:',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _consultationTypes.map((t) {
                      final isSelected = _selectedConsultationType == t;
                      return ChoiceChip(
                        label: Text(t),
                        selected: isSelected,
                        selectedColor: AppColors.powderBackground,
                        backgroundColor: AppColors.whiteSurface,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? AppColors.primary : AppColors.mainText,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.warmNeutralSand,
                          width: isSelected ? 1.5 : 1,
                        ),
                        onSelected: (_) => setState(() => _selectedConsultationType = t),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  // Available Time Slots
                  Text(
                    context.isArabic ? 'المواعيد المتاحة (د. نور الخالدي):' : 'Available Time Slots:',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _timeSlots.map((slot) {
                      final isSelected = _selectedTimeSlot == slot;
                      return ChoiceChip(
                        label: Text(slot),
                        selected: isSelected,
                        selectedColor: AppColors.primaryAction.withAlpha(40),
                        backgroundColor: AppColors.whiteSurface,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? AppColors.primary : AppColors.mainText,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryAction : AppColors.warmNeutralSand,
                          width: isSelected ? 1.5 : 1,
                        ),
                        onSelected: (_) => setState(() => _selectedTimeSlot = slot),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  PillButton(
                    label: context.isArabic ? 'تأكيد حجز الموعد' : 'Confirm Appointment Booking',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: _bookNewAppointment,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Emergency Notice Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.powderBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.softDustyBlush),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.isArabic
                          ? 'حالات الطوارئ أو الاستفسار السريع؟ يمكنكِ الاتصال بالخط الساخن الموحد ١٦٨٧٠ مباشرة.'
                          : 'Emergency or urgent inquiry? Call the national oncology hotline 16870 directly.',
                      style: const TextStyle(fontSize: 12, color: AppColors.mainText, height: 1.4),
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
}
