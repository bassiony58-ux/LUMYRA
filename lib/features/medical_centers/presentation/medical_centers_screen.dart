import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/user_role.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_badge.dart';

class MedicalCenterItem {
  final String id;
  final String name;
  final String governorate;
  final String address;
  final String phone;
  final String type;
  final List<String> services;
  final double latitude;
  final double longitude;
  final bool isDoctorClinic;
  final String? doctorName;
  final String? specialty;

  MedicalCenterItem({
    required this.id,
    required this.name,
    required this.governorate,
    required this.address,
    required this.phone,
    required this.type,
    required this.services,
    required this.latitude,
    required this.longitude,
    this.isDoctorClinic = false,
    this.doctorName,
    this.specialty,
  });
}

class MedicalCentersScreen extends ConsumerStatefulWidget {
  const MedicalCentersScreen({super.key});

  @override
  ConsumerState<MedicalCentersScreen> createState() => _MedicalCentersScreenState();
}

class _MedicalCentersScreenState extends ConsumerState<MedicalCentersScreen> {
  String _selectedGovernorate = 'الكل';
  String _selectedCategory = 'الكل'; // 'الكل' | 'مراكز ومستشفيات' | 'عيادات أطباء'
  final TextEditingController _searchController = TextEditingController();

  // User location coordinates (defaults to Cairo/Giza center, updated via GPS simulation)
  double? _userLat = 30.0444;
  double? _userLng = 31.2357;
  bool _isGpsActive = false;
  String _currentLocationName = 'القاهرة الكبرى / الجيزة (افتراضي)';

  final List<MedicalCenterItem> _centers = [
    MedicalCenterItem(
      id: 'center-1',
      name: 'مستشفى بهية للكشف المبكر وعلاج سرطان الثدي (فرع الهرم)',
      governorate: 'الجيزة',
      address: 'شارع الهرم، محطة العريش، الجيزة',
      phone: '16602',
      type: 'مؤسسة غير ربحية مجانية متخصصة',
      services: ['ماموجرام رقمي', 'موجات فوق صوتية', 'فحص باثولوجي', 'علاج كيميائي', 'دعم نفسي'],
      latitude: 29.9972,
      longitude: 31.1856,
    ),
    MedicalCenterItem(
      id: 'center-1-zyed',
      name: 'مستشفى بهية الشيخ زايد التخصصي',
      governorate: 'الجيزة',
      address: 'محور 26 يوليو، مدينة الشيخ زايد، الجيزة',
      phone: '16602',
      type: 'مستشفى متكامل لجراحة وأورام الثدي',
      services: ['غرف عمليات جراحية', 'رنين مغناطيسي', 'علاج إشعاعي', 'صيدلية إكلينيكية'],
      latitude: 30.0382,
      longitude: 30.9857,
    ),
    MedicalCenterItem(
      id: 'doc-1',
      name: 'عيادة أ.د. نور الخالدي (استشاري جراحة أورام الثدي)',
      governorate: 'الجيزة',
      address: 'عيادات الصفا التخصصية، شارع البطل أحمد عبد العزيز، المهندسين',
      phone: '01099887766',
      type: 'عيادة استشاري معتمد بشبكة لوميرا',
      services: ['فحص سريري دقيق', 'خزعات موجهة بالأشعة', 'استشارات الجراحة التحفظية'],
      latitude: 30.0561,
      longitude: 31.2014,
      isDoctorClinic: true,
      doctorName: 'أ.د. نور الخالدي',
      specialty: 'استشاري جراحة وأورام الثدي',
    ),
    MedicalCenterItem(
      id: 'center-2',
      name: 'المعهد القومي للأورام — جامعة القاهرة',
      governorate: 'القاهرة',
      address: 'ميدان فم الخليج، قصر العيني، القاهرة',
      phone: '16198',
      type: 'مستشفى جامعي حكومي وأكاديمي',
      services: ['جراحة أورام', 'علاج إشعاعي', 'فحوصات وراثية وجينية', 'معامل مركزية'],
      latitude: 30.0275,
      longitude: 31.2336,
    ),
    MedicalCenterItem(
      id: 'doc-2',
      name: 'عيادة د. سارة رضوان (استشاري أشعة وماموجرام الثدي)',
      governorate: 'القاهرة',
      address: 'شارع عباس العقاد، مدينة نصر، القاهرة',
      phone: '01122334455',
      type: 'مركز استشاري تشخيصي معتمد',
      services: ['أشعة سونار ثلاثية الأبعاد', 'ماموجرام رقمي عالي الدقة', 'فحص عينات'],
      latitude: 30.0632,
      longitude: 31.3415,
      isDoctorClinic: true,
      doctorName: 'د. سارة رضوان',
      specialty: 'استشاري أشعة الثدي التداخلية',
    ),
    MedicalCenterItem(
      id: 'center-ainshams',
      name: 'مركز أورام جامعة عين شمس التخصصي',
      governorate: 'القاهرة',
      address: 'شارع رمسيس، العباسية، القاهرة',
      phone: '0224821815',
      type: 'صرح طبي جامعي متكامل',
      services: ['وحدة صحة المرأة', 'ماموجرام تداخلي', 'علاج مناعي وموجه'],
      latitude: 30.0768,
      longitude: 31.2854,
    ),
    MedicalCenterItem(
      id: 'center-3',
      name: 'مركز أورام السلام التخصصي',
      governorate: 'القاهرة',
      address: 'مدينة السلام، القاهرة',
      phone: '0222791823',
      type: 'أمانة المراكز الطبية المتخصصة',
      services: ['ماموجرام', 'عيادات فحص مبكر', 'صيدلية أورام'],
      latitude: 30.1742,
      longitude: 31.3975,
    ),
    MedicalCenterItem(
      id: 'center-alex',
      name: 'مركز أورام أيادي 4040 لسرطان الثدي بالإسكندرية',
      governorate: 'الإسكندرية',
      address: 'محرم بك، الإسكندرية',
      phone: '033924040',
      type: 'مستشفى غير ربحي مجاني متكامل',
      services: ['كشف مبكر مجاني', 'علاج كيميائي وإشعاعي', 'فحص أنسجة'],
      latitude: 31.2185,
      longitude: 29.9548,
    ),
    MedicalCenterItem(
      id: 'center-4',
      name: 'مركز أورام طنطا',
      governorate: 'الغربية',
      address: 'شارع الجيش، طنطا، محافظة الغربية',
      phone: '0403309991',
      type: 'أمانة المراكز الطبية المتخصصة',
      services: ['كشف مبكر', 'جراحة أورام الثدي', 'علاج هرموني'],
      latitude: 30.7967,
      longitude: 31.0024,
    ),
    MedicalCenterItem(
      id: 'center-5',
      name: 'مركز أورام ميت غمر لسرطان الثدي',
      governorate: 'الدقهلية',
      address: 'ميت غمر، محافظة الدقهلية',
      phone: '0506902188',
      type: 'مركز حكومي متخصص في صحة الثدي',
      services: ['فحص ماموجرام مجاني', 'جراحات تحفظية', 'متابعة دورية'],
      latitude: 30.7188,
      longitude: 31.2618,
    ),
    MedicalCenterItem(
      id: 'center-6',
      name: 'مركز أورام أسيوط — جامعة أسيوط',
      governorate: 'أسيوط',
      address: 'مجمع الكليات الطبية، جامعة أسيوط',
      phone: '0882413000',
      type: 'مستشفى جامعي تخصصي',
      services: ['فحص تشخيصي شامل', 'وحدة أشعة الثدي', 'علاج موجه'],
      latitude: 27.1895,
      longitude: 31.1718,
    ),
  ];

  final List<String> _governorates = [
    'الكل',
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الغربية',
    'الدقهلية',
    'أسيوط',
  ];

  double _getDistanceKm(MedicalCenterItem center) {
    if (_userLat == null || _userLng == null) return 0.0;
    const p = 0.017453292519943295; // Math.PI / 180
    final c = math.cos;
    final a = 0.5 -
        c((center.latitude - _userLat!) * p) / 2 +
        c(_userLat! * p) * c(center.latitude * p) * (1 - c((center.longitude - _userLng!) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  void _detectLocationViaGps() {
    setState(() {
      _isGpsActive = true;
      // Coordinates of user's active mobile location in Cairo / Giza
      _userLat = 30.0382;
      _userLng = 31.2014;
      _currentLocationName = 'موقعكِ الحالي عبر الـ GPS (الجيزة / المهندسين)';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.isArabic
              ? 'تم تحديد موقعكِ الجغرافي عبر الـ GPS بنجاح 📍 ورتبنا لكِ أقرب الأطباء والمراكز!'
              : 'Location acquired via GPS 📍 Closest providers sorted!',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _callPhone(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.isArabic ? 'جاري الاتصال بـ $phone عبر الهاتف 📞' : 'Calling $phone 📞',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    var filtered = _centers.where((c) {
      final matchesGov = _selectedGovernorate == 'الكل' || c.governorate == _selectedGovernorate;
      final matchesCat = _selectedCategory == 'الكل' ||
          (_selectedCategory == 'عيادات أطباء' && c.isDoctorClinic) ||
          (_selectedCategory == 'مراكز ومستشفيات' && !c.isDoctorClinic);
      final matchesQuery = query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          c.address.toLowerCase().contains(query) ||
          (c.doctorName?.toLowerCase().contains(query) ?? false);
      return matchesGov && matchesCat && matchesQuery;
    }).toList();

    // Sort by proximity to user
    filtered.sort((a, b) => _getDistanceKm(a).compareTo(_getDistanceKm(b)));

    final userRole = ref.watch(userRoleProvider);
    final navIndex = userRole == UserRole.admin ? 2 : 3;

    return AdaptiveScaffold(
      selectedIndex: navIndex,
      titleKey: 'navCenters',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // GPS Location Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.powderBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.softDustyBlush, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.whiteSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  context.isArabic ? 'الموقع الجغرافي للهاتف 📍' : 'Device Location 📍',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                                if (_isGpsActive)
                                  StatusBadge.active(context.isArabic ? 'GPS متصل' : 'GPS Active'),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currentLocationName,
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PillButton(
                    label: context.isArabic
                        ? 'تحديث موقعي التلقائي عبر الـ GPS 📍'
                        : 'Update GPS Location 📍',
                    icon: Icons.gps_fixed_rounded,
                    onPressed: _detectLocationViaGps,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search & Filters
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: context.isArabic ? 'ابحثي باسم المركز أو الطبيب...' : 'Search center or doctor...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondaryText),
                      fillColor: AppColors.whiteSurface,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9999),
                        borderSide: const BorderSide(color: AppColors.warmNeutralSand),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedGovernorate,
                    decoration: InputDecoration(
                      fillColor: AppColors.whiteSurface,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9999),
                        borderSide: const BorderSide(color: AppColors.warmNeutralSand),
                      ),
                    ),
                    items: _governorates.map((gov) {
                      return DropdownMenuItem(value: gov, child: Text(gov, style: const TextStyle(fontSize: 12.5)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedGovernorate = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Chips: All vs Hospitals vs Doctors
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(context.isArabic ? 'الكل (${_centers.length})' : 'All (${_centers.length})'),
                    selected: _selectedCategory == 'الكل',
                    onSelected: (_) => setState(() => _selectedCategory = 'الكل'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(context.isArabic ? '🏥 مستشفيات ومراكز أورام' : 'Hospitals & Centers'),
                    selected: _selectedCategory == 'مراكز ومستشفيات',
                    onSelected: (_) => setState(() => _selectedCategory = 'مراكز ومستشفيات'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(context.isArabic ? '👩‍⚕️ عيادات استشاريين معتمدين' : 'Doctor Clinics'),
                    selected: _selectedCategory == 'عيادات أطباء',
                    onSelected: (_) => setState(() => _selectedCategory = 'عيادات أطباء'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Centers & Doctors List Sorted by Proximity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    context.isArabic
                        ? 'النتائج المقترحة مرتبة حسب الأقرب لكِ (${filtered.length})'
                        : 'Nearest Providers (${filtered.length})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...filtered.asMap().entries.map((entry) {
              final idx = entry.key;
              final center = entry.value;
              final dist = _getDistanceKm(center);

              return AppCard(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: center.isDoctorClinic
                                ? AppColors.softDustyBlush.withAlpha(120)
                                : AppColors.powderBackground,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            center.isDoctorClinic ? Icons.person_rounded : Icons.local_hospital_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                center.name,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.powderBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      center.governorate,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      center.type,
                                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Distance Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: idx == 0
                            ? AppColors.primaryContainer
                            : AppColors.powderBackground.withAlpha(90),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            idx == 0 ? Icons.stars_rounded : Icons.near_me_rounded,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            idx == 0
                                ? (context.isArabic
                                    ? '📍 الأقرب لموقعكِ الحالي (يبعد ${dist.toStringAsFixed(1)} كم)'
                                    : '📍 Closest to you (${dist.toStringAsFixed(1)} km)')
                                : (context.isArabic
                                    ? 'يبعد عنكِ ${dist.toStringAsFixed(1)} كم'
                                    : '${dist.toStringAsFixed(1)} km away'),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.secondaryText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            center.address,
                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Services tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: center.services.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.powderBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(s, style: const TextStyle(fontSize: 10, color: AppColors.mainText)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Actions Row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () => _callPhone(center.phone),
                            icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                            label: Text(
                              context.isArabic ? 'اتصال (${center.phone})' : 'Call (${center.phone})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.softDustyBlush),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.isArabic
                                      ? 'جاري فتح المسار إلى ${center.name} في خرائط Google 🗺️'
                                      : 'Opening directions to ${center.name} 🗺️',
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.directions_rounded, size: 16),
                          label: Text(context.isArabic ? 'المسار' : 'Map'),
                        ),
                      ],
                    ),
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
