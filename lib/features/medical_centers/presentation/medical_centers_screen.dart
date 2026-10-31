import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class CenterTransitDetails {
  final String metroStation;
  final String metroLine;
  final String metroWalk;
  final String metroFare;
  final List<String> metroSteps;

  final String taxiCorridor;
  final String taxiEta;
  final String taxiFare;
  final String taxiTraffic;

  final bool isIntercityRail;
  final String busOrTrainTitle;
  final String busOrTrainSubtitle;
  final List<String> busOrTrainSteps;

  final String clinicEntranceGuide;

  const CenterTransitDetails({
    required this.metroStation,
    required this.metroLine,
    required this.metroWalk,
    required this.metroFare,
    required this.metroSteps,
    required this.taxiCorridor,
    required this.taxiEta,
    required this.taxiFare,
    required this.taxiTraffic,
    required this.isIntercityRail,
    required this.busOrTrainTitle,
    required this.busOrTrainSubtitle,
    required this.busOrTrainSteps,
    required this.clinicEntranceGuide,
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

  CenterTransitDetails _getTransitRoute(MedicalCenterItem center, double distanceKm, bool isAr) {
    if (center.id == 'center-1') {
      // Baheya Haram
      return CenterTransitDetails(
        metroStation: isAr ? 'محطة فيصل / محطة الجيزة (الخط الثاني) أو محطة العريش (الخط الرابع)' : 'Faisal / Giza Station (Line 2) or El-Arish',
        metroLine: isAr ? 'الخط الثاني للمترو (شبرا - المنيب) 🟡' : 'Cairo Metro Line 2 (Yellow Line) 🟡',
        metroWalk: isAr ? '7 دقائق سرفيس من محطة فيصل حتى باب المستشفى مباشرة' : '7 mins shuttle from Faisal station to hospital gate',
        metroFare: isAr ? '8 ج.م (تذكرة المترو) + 5 ج.م ميكروباص' : '8 EGP (Metro) + 5 EGP shuttle',
        metroSteps: [
          isAr ? '1. استقل الخط الثاني للمترو وانزل في محطة فيصل أو محطة الجيزة.' : '1. Ride Metro Line 2 and alight at Faisal or Giza station.',
          isAr ? '2. استقل سرفيس شارع الهرم الرئيسي باتجاه الأهرامات.' : '2. Take Haram St express shuttle towards Pyramids.',
          isAr ? '3. انزل في محطة العريش؛ صرح مستشفى بهية أمامك مباشرة على الناصية.' : '3. Alight at El-Arish stop; Baheya Hospital is directly opposite.',
        ],
        taxiCorridor: isAr ? 'شارع الهرم الرئيسي أو كوبري فيصل ومحور اللبيني' : 'Haram Main Street / Faisal Flyover',
        taxiEta: '${(10 + distanceKm * 2.2).round()} ${isAr ? "دقيقة" : "mins"}',
        taxiFare: '${(20 + distanceKm * 6.5).round()} - ${(30 + distanceKm * 8.5).round()} ${isAr ? "ج.م" : "EGP"}',
        taxiTraffic: isAr ? 'سيولة مرورية متوسطة إلى جيدة' : 'Moderate to steady traffic flow',
        isIntercityRail: false,
        busOrTrainTitle: isAr ? 'حافلات النقل العام ومواصلات مصر' : 'Public Buses & Cairo Transit',
        busOrTrainSubtitle: isAr ? 'خطوط هيئة النقل العام: 357، 1018، وباص M10' : 'CTA Bus lines: 357, 1018, and M10',
        busOrTrainSteps: [
          isAr ? '• اركب حافلة 357 من ميدان التحرير أو الجيزة باتجاه الهرم.' : '• Take Bus 357 towards Haram from Tahrir or Giza sq.',
          isAr ? '• انزل أمام محطة العريش أمام بوابة بهية مباشرة.' : '• Alight at El-Arish stop directly in front of Baheya gate.',
        ],
        clinicEntranceGuide: isAr
            ? 'الدخول من البوابة الرئيسية (بوابة الاستقبال) - التوجه لمكتب استقبال لوميرا وفحص الماموجرام بالدور الأرضي.'
            : 'Main entrance -> Lumyra check-in counter on ground floor.',
      );
    } else if (center.id == 'center-1-zyed') {
      // Baheya Sheikh Zayed
      return CenterTransitDetails(
        metroStation: isAr ? 'محطة الكيت كات أو محطة روض الفرج (الخط الثالث) + سرفيس زايد' : 'Kit Kat or Rod El-Farag (Line 3) + Zayed Shuttle',
        metroLine: isAr ? 'الخط الثالث للمترو (الخط الأخضر 🟢)' : 'Line 3 (Green Line 🟢)',
        metroWalk: isAr ? 'النزول على المحور أمام مدخل المستشفى (دقيقتين مشياً)' : 'Alight at 26 July Corridor, 2 min walk to gate',
        metroFare: isAr ? '10 ج.م مترو + 10 ج.م سرفيس زايد' : '10 EGP Metro + 10 EGP express bus',
        metroSteps: [
          isAr ? '1. استقل الخط الثالث للمترو حتى محطة الكيت كات أو التوفيقية.' : '1. Ride Green Line 3 to Kit Kat station.',
          isAr ? '2. استقل ميكروباص الشيخ زايد المباشر عبر محور 26 يوليو السريع.' : '2. Take express 26 July corridor shuttle to Zayed.',
          isAr ? '3. انزل بعد ميدان جهينة عند مجمع مستشفى بهية التخصصي الجديد.' : '3. Alight near Juhayna Sq at the new Baheya complex.',
        ],
        taxiCorridor: isAr ? 'محور 26 يوليو السريع باتجاه الشيخ زايد ومدينة 6 أكتوبر' : '26th of July Corridor towards Sheikh Zayed',
        taxiEta: '${(15 + distanceKm * 1.8).round()} ${isAr ? "دقيقة" : "mins"}',
        taxiFare: '${(35 + distanceKm * 7.0).round()} - ${(50 + distanceKm * 9.0).round()} ${isAr ? "ج.م" : "EGP"}',
        taxiTraffic: isAr ? 'سيولة مرورية عالية على المحور الحر' : 'Fast moving highway traffic',
        isIntercityRail: false,
        busOrTrainTitle: isAr ? 'حافلات مواصلات مصر المكيفة السريعة' : 'Mwasalat Misr Express Coach',
        busOrTrainSubtitle: isAr ? 'خط M12 وخط 1025 من عبد المنعم رياض وميدان لبنان' : 'Lines M12 & 1025 from Lebanon Sq',
        busOrTrainSteps: [
          isAr ? '• اركب حافلة M12 من موقف ميدان لبنان مباشرة إلى الشيخ زايد.' : '• Take Bus M12 from Lebanon Sq directly to Sheikh Zayed.',
          isAr ? '• محطة التوقف تقع أمام مدخل مستشفى بهية الشيخ زايد.' : '• Drops off right before the Baheya hospital entrance.',
        ],
        clinicEntranceGuide: isAr
            ? 'بوابة العيادات الخارجية (بوابة 1) - وحدة صحة المرأة والتصوير الماموجرافي ثلاثي الأبعاد بالدور الأول.'
            : 'Outpatient Gate 1 -> Women Health & 3D Tomo Unit, 1st floor.',
      );
    } else if (center.id == 'doc-1') {
      // Dr. Noor Al-Khalidi - Mohandessin
      return CenterTransitDetails(
        metroStation: isAr ? 'محطة التوفيقية أو محطة وادي النيل (الخط الثالث) 🟢' : 'Tawfikiya or Wadi El-Nile Station (Line 3) 🟢',
        metroLine: isAr ? 'الخط الثالث للمترو (الخط الأخضر)' : 'Cairo Metro Line 3 (Green Line)',
        metroWalk: isAr ? '450 متر سيراً على الأقدام (5 دقائق فقط)' : '450m walk (5 minutes on foot)',
        metroFare: isAr ? '8 ج.م (تذكرة المترو العادية)' : '8 EGP (Standard metro ticket)',
        metroSteps: [
          isAr ? '1. استقل الخط الثالث للمترو باتجاه محور روض الفرج.' : '1. Take Metro Line 3 towards Rod El-Farag.',
          isAr ? '2. انزل في محطة وادي النيل أو التوفيقية واخرج من مخرج شارع سوريا.' : '2. Exit at Wadi El-Nile station, Syria St exit.',
          isAr ? '3. امشِ 400 متر باتجاه شارع البطل أحمد عبد العزيز؛ عيادات الصفا أمامك.' : '3. Walk 400m towards El-Batal Ahmed Abdelaziz St to Al-Safa Clinics.',
        ],
        taxiCorridor: isAr ? 'كوبري 6 أكتوبر (مخرج الدقي/المهندسين) ثم شارع البطل أحمد عبد العزيز' : '6th October Bridge (Mohandessin exit) to Batal St',
        taxiEta: '${(8 + distanceKm * 2.0).round()} ${isAr ? "دقيقة" : "mins"}',
        taxiFare: '${(20 + distanceKm * 6.0).round()} - ${(30 + distanceKm * 8.0).round()} ${isAr ? "ج.م" : "EGP"}',
        taxiTraffic: isAr ? 'حركة سير جيدة وطريق مباشر' : 'Smooth direct corridor',
        isIntercityRail: false,
        busOrTrainTitle: isAr ? 'أتوبيسات النقل العام وميكروباصات ميدان لبنان' : 'Public Buses & Lebanon Sq Shuttles',
        busOrTrainSubtitle: isAr ? 'خطوط M7، 110، 948 وميني باص جامعة الدول' : 'Lines M7, 110, 948 & Gameat Dewal shuttles',
        busOrTrainSteps: [
          isAr ? '• اركب أي باص مار بشارع جامعة الدول أو البطل أحمد عبد العزيز.' : '• Take any bus running along Gameat Dowal or Batal St.',
          isAr ? '• انزل أمام عمارة الصفا التخصصية بجوار تقاطع نوال.' : '• Alight at Al-Safa Medical Building near Nawal intersection.',
        ],
        clinicEntranceGuide: isAr
            ? 'برج الصفا التخصصي الطبي - المصعد إلى الدور الثالث - عيادة استشاري جراحة أورام الثدي (د. نور الخالدي).'
            : 'Al-Safa Medical Tower -> Elevator to 3rd floor -> Dr. Noor Al-Khalidi clinic.',
      );
    } else if (center.id == 'center-2') {
      // National Cancer Institute - Qasr El-Aini
      return CenterTransitDetails(
        metroStation: isAr ? 'محطة السيدة زينب أو محطة سعد زغلول (الخط الأول) 🔴' : 'Sayeda Zeinab / Saad Zaghloul Station (Line 1) 🔴',
        metroLine: isAr ? 'الخط الأول (المرج - حلوان)' : 'Cairo Metro Line 1 (Red Line)',
        metroWalk: isAr ? '600 متر سيراً لميدان فم الخليج (7 دقائق)' : '600m walk to Fom El-Khalig Sq (7 mins)',
        metroFare: isAr ? '8 ج.م (تذكرة المترو العادية)' : '8 EGP (Standard ticket)',
        metroSteps: [
          isAr ? '1. استقل الخط الأول وانزل في محطة السيدة زينب.' : '1. Take Metro Line 1 to Sayeda Zeinab station.',
          isAr ? '2. اخرج باتجاه مجرى العيون وكورنيش قصر العيني.' : '2. Head towards Magra El-Oyoun & Corniche.',
          isAr ? '3. 6 دقائق سيراً لميدان فم الخليج حيث يقع المعهد القومي للأورام.' : '3. Walk 6 minutes to Fom El-Khalig Sq where NCI is located.',
        ],
        taxiCorridor: isAr ? 'كورنيش النيل مباشرة من المعادي أو التحرير باتجاه فم الخليج' : 'Nile Corniche directly towards Fom El-Khalig',
        taxiEta: '${(10 + distanceKm * 2.1).round()} ${isAr ? "دقيقة" : "mins"}',
        taxiFare: '${(22 + distanceKm * 6.5).round()} - ${(32 + distanceKm * 8.5).round()} ${isAr ? "ج.م" : "EGP"}',
        taxiTraffic: isAr ? 'سيولة مرورية على كورنيش النيل' : 'Steady flow on Nile Corniche',
        isIntercityRail: false,
        busOrTrainTitle: isAr ? 'حافلات قصر العيني وكورنيش النيل' : 'Qasr El-Aini & Corniche Buses',
        busOrTrainSubtitle: isAr ? 'خطوط هيئة النقل العام: 800، 1005، وميكروباصات أثر النبي' : 'CTA Lines: 800, 1005 & Athar El-Nabi shuttles',
        busOrTrainSteps: [
          isAr ? '• اركب حافلة كورنيش النيل المتجهة لمصر القديمة.' : '• Take Corniche bus towards Old Cairo.',
          isAr ? '• انزل أمام صرح المعهد القومي للأورام بميدان فم الخليج.' : '• Alight directly at the National Cancer Institute.',
        ],
        clinicEntranceGuide: isAr
            ? 'البوابة الرئيسية المطلة على الكورنيش - العيادات الخارجية التخصصية - صالة الاستقبال المركزية.'
            : 'Main Corniche Gate -> Outpatient Clinics -> Central Lumyra desk.',
      );
    } else if (center.id == 'doc-2') {
      // Dr. Sara Radwan - Abbas El-Akkad
      return CenterTransitDetails(
        metroStation: isAr ? 'محطة الاستاد أو أرض المعارض (الخط الثالث) 🟢' : 'Stadium / Fair Zone Station (Line 3) 🟢',
        metroLine: isAr ? 'الخط الثالث (الخط الأخضر)' : 'Cairo Metro Line 3 (Green Line)',
        metroWalk: isAr ? '8 دقائق سرفيس أو تاكسي لشارع عباس العقاد' : '8 mins shuttle/taxi to Abbas El-Akkad St',
        metroFare: isAr ? '8 ج.م مترو + 5 ج.م ميكروباص' : '8 EGP metro + 5 EGP shuttle',
        metroSteps: [
          isAr ? '1. اركب مترو الخط الثالث وانزل بمحطة الاستاد.' : '1. Ride Green Line 3 to Stadium station.',
          isAr ? '2. استقل سرفيس طريق النصر وشارع عباس العقاد.' : '2. Take Nasr Road shuttle into Abbas El-Akkad.',
          isAr ? '3. انزل عند تقاطع البطراوي أمام العيادة التخصصية.' : '3. Alight near El-Batrawy intersection.',
        ],
        taxiCorridor: isAr ? 'طريق النصر أو كوبري أكتوبر ومحور الشهيد' : '6th October Bridge & El-Nasr Road',
        taxiEta: '${(12 + distanceKm * 2.3).round()} ${isAr ? "دقيقة" : "mins"}',
        taxiFare: '${(25 + distanceKm * 7.0).round()} - ${(40 + distanceKm * 9.0).round()} ${isAr ? "ج.م" : "EGP"}',
        taxiTraffic: isAr ? 'حركة سير نشطة' : 'Active urban traffic',
        isIntercityRail: false,
        busOrTrainTitle: isAr ? 'حافلات مدينة نصر ومواصلات مصر' : 'Nasr City Buses & Mwasalat Misr',
        busOrTrainSubtitle: isAr ? 'خطوط M5 و 304 و 1030' : 'Lines M5, 304, and 1030',
        busOrTrainSteps: [
          isAr ? '• اركب حافلة M5 أو 304 المارة بشارع عباس العقاد.' : '• Board M5 or 304 running through Abbas El-Akkad.',
          isAr ? '• انزل أمام عمارة الأطباء التخصصية.' : '• Alight at Specialized Doctors Building.',
        ],
        clinicEntranceGuide: isAr
            ? 'عمارة الأطباء التخصصية - الدور الثاني - مركز د. سارة رضوان لتشخيص وأشعة الثدي.'
            : 'Specialized Medical Tower -> 2nd floor -> Dr. Sara Radwan Center.',
      );
    } else if (center.id == 'center-ainshams') {
      // Ain Shams Oncology - Abbasiya
      return CenterTransitDetails(
        metroStation: isAr ? 'محطة العباسية (الخط الثالث) على بعد 350 متر 🟢' : 'Abbasiya Station (Line 3) only 350m away 🟢',
        metroLine: isAr ? 'الخط الثالث الأخضر (محطة العباسية)' : 'Line 3 Green (Abbasiya station)',
        metroWalk: isAr ? '4 دقائق سيراً على الأقدام من مخرج مترو العباسية' : '4 minutes walk from Abbasiya metro exit',
        metroFare: isAr ? '8 ج.م (تذكرة المترو)' : '8 EGP (Standard ticket)',
        metroSteps: [
          isAr ? '1. اركب الخط الثالث وانزل في محطة العباسية.' : '1. Ride Line 3 to Abbasiya station.',
          isAr ? '2. اخرج من مخرج مستشفى الجامعة / شارع رمسيس.' : '2. Take University Hospital / Ramses St exit.',
          isAr ? '3. اعبر الشارع لتجد بوابة مركز أورام جامعة عين شمس أمامك.' : '3. Cross to Ain Shams Oncology Center gate.',
        ],
        taxiCorridor: isAr ? 'شارع رمسيس أو كوبري العباسية مباشرة' : 'Ramses St or Abbasiya Flyover',
        taxiEta: '${(10 + distanceKm * 2.0).round()} ${isAr ? "دقيقة" : "mins"}',
        taxiFare: '${(20 + distanceKm * 6.5).round()} - ${(30 + distanceKm * 8.5).round()} ${isAr ? "ج.م" : "EGP"}',
        taxiTraffic: isAr ? 'حركة سير سلسة ومباشرة' : 'Smooth flowing',
        isIntercityRail: false,
        busOrTrainTitle: isAr ? 'مجمع حافلات العباسية المركزي' : 'Abbasiya Central Bus Terminal',
        busOrTrainSubtitle: isAr ? 'موقف العباسية يضم أكثر من 25 خطاً لجميع أنحاء القاهرة' : 'Over 25 major bus routes connect here',
        busOrTrainSteps: [
          isAr ? '• اركب أي حافلة متجهة لميدان العباسية.' : '• Take any bus heading to Abbasiya Sq.',
          isAr ? '• المركز يبعد 3 دقائق مشياً من محطة الأتوبيس المركزية.' : '• 3 mins walk from the terminal to the center.',
        ],
        clinicEntranceGuide: isAr
            ? 'بوابة مستشفيات جامعة عين شمس (بوابة 2) - مبنى مركز الأورام - قسم صحة المرأة والماموجرام بالدور الأرضي.'
            : 'Gate 2 -> Oncology Building -> Breast Imaging Unit, Ground Floor.',
      );
    } else if (center.id == 'center-3') {
      // El-Salam Oncology Center
      return CenterTransitDetails(
        metroStation: isAr ? 'محطة عدلي منصور التبادلية (الخط الثالث + القطار الكهربائي LRT) 🟢' : 'Adly Mansour Interchange (Line 3 + LRT) 🟢',
        metroLine: isAr ? 'الخط الثالث (الخط الأخضر) + LRT' : 'Line 3 Green + LRT',
        metroWalk: isAr ? '10 دقائق سرفيس السلام من محطة عدلي منصور' : '10 mins shuttle from Adly Mansour',
        metroFare: isAr ? '10 ج.م مترو + 5 ج.م ميكروباص' : '10 EGP metro + 5 EGP shuttle',
        metroSteps: [
          isAr ? '1. استقل الخط الثالث حتى المحطة النهائية عدلي منصور.' : '1. Ride Line 3 to terminus Adly Mansour.',
          isAr ? '2. استقل سرفيس مدينة السلام الداخلي من موقف المحطة التبادلية.' : '2. Take local Salam shuttle from the terminal.',
          isAr ? '3. انزل أمام بوابة مركز أورام السلام التخصصي.' : '3. Alight at El-Salam Oncology Center.',
        ],
        taxiCorridor: isAr ? 'الطريق الدائري ومحور الفريق إبراهيم العرابي' : 'Ring Road & Gen. El-Oraby Axis',
        taxiEta: '${(15 + distanceKm * 1.9).round()} ${isAr ? "دقيقة" : "mins"}',
        taxiFare: '${(30 + distanceKm * 7.0).round()} - ${(45 + distanceKm * 9.0).round()} ${isAr ? "ج.م" : "EGP"}',
        taxiTraffic: isAr ? 'حركة سريعة ومفتوحة' : 'Fast moving expressway',
        isIntercityRail: false,
        busOrTrainTitle: isAr ? 'القطار الكهربائي الخفيف (LRT) وأتوبيسات السلام' : 'Light Rail Transit (LRT) & Buses',
        busOrTrainSubtitle: isAr ? 'خطوط هيئة النقل العام: 703، 825، ومواقف السلام الجديدة' : 'CTA Lines: 703, 825',
        busOrTrainSteps: [
          isAr ? '• اركب حافلة 703 المتجهة لموقف السلام.' : '• Take Bus 703 to Salam terminal.',
          isAr ? '• 5 دقائق من الموقف إلى المركز.' : '• 5 mins to the center.',
        ],
        clinicEntranceGuide: isAr
            ? 'البوابة الرئيسية - صالة الاستقبال الإداري - وحدة فحص الأورام والعلاج المتكامل.'
            : 'Main Gate -> Reception Hall -> Breast Oncology Unit.',
      );
    } else if (center.id == 'center-alex') {
      // Ayadi 4040 - Alexandria
      return CenterTransitDetails(
        metroStation: isAr ? 'محطة قطار سيدي جابر أو محطة مصر بالإسكندرية 🚆' : 'Sidi Gaber / Misr Railway Station (Alexandria) 🚆',
        metroLine: isAr ? 'خط قطارات سكك حديد مصر (القاهرة ➔ الإسكندرية) - قطار تالجو أو VIP' : 'Egypt National Railways (Cairo ➔ Alex) - Talgo / VIP Express',
        metroWalk: isAr ? '10 دقائق بالتاكسي أو الترام من محطة القطار إلى محرم بك' : '10 mins local taxi or tram to Moharam Bek',
        metroFare: isAr ? 'تذكرة قطار تالجو/VIP (80 - 150 ج.م) + 25 ج.م تاكسي إسكندرية' : 'Train ticket (80-150 EGP) + 25 EGP local taxi',
        metroSteps: [
          isAr ? '1. استقل قطار سكك حديد مصر السريع من محطة رمسيس إلى محطة سيدي جابر (ساعتان وربع).' : '1. Board Talgo express from Cairo Ramses to Alex Sidi Gaber (2h 15m).',
          isAr ? '2. استقل تاكسي الإسكندرية الأصفر أو ترام الرمل باتجاه محرم بك.' : '2. Take local taxi or tram towards Moharam Bek.',
          isAr ? '3. مستشفى أيادي 4040 لعلاج الأورام بالمجان تقع مباشرة في محرم بك.' : '3. Ayadi 4040 Charity Hospital is located on Moharam Bek main corridor.',
        ],
        taxiCorridor: isAr ? 'طريق القاهرة - الإسكندرية الصحراوي السريع' : 'Cairo-Alexandria Desert Highway',
        taxiEta: isAr ? 'ساعتان و 20 دقيقة' : '2h 20m driving time',
        taxiFare: isAr ? 'سفر محافظات (خدمات أوبر بين المحافظات أو ليموزين)' : 'Intercity travel / Limousine service',
        taxiTraffic: isAr ? 'طريق سريع مفتوح وممهد' : 'Clear open expressway',
        isIntercityRail: true,
        busOrTrainTitle: isAr ? 'حافلات السوبر جيت وجو باص (القاهرة ➔ الإسكندرية)' : 'SuperJet & GoBus Intercity Coaches',
        busOrTrainSubtitle: isAr ? 'رحلات مباشرة كل نصف ساعة من محطة الترجمان أو ألماظة' : 'Coaches leave every 30 mins from Torgoman / Almaza',
        busOrTrainSteps: [
          isAr ? '• احجز تذكرة حافلة سوبر جيت أو جو باص إلى الإسكندرية محرم بك مباشرة.' : '• Book SuperJet coach direct to Alex Moharam Bek station.',
          isAr ? '• محطة وصول الحافلات تقع على بعد 5 دقائق فقط من المستشفى.' : '• Coach terminal is located just 5 minutes from Ayadi 4040.',
        ],
        clinicEntranceGuide: isAr
            ? 'المدخل الرئيسي لمستشفى أيادي 4040 المجاني - مكتب الاستقبال والتسجيل الفوري - الدور الأرضي.'
            : 'Main Hospital Gate -> Registration Desk, Ground floor.',
      );
    } else if (center.id == 'center-4') {
      // Tanta Oncology Center
      return CenterTransitDetails(
        metroStation: isAr ? 'محطة سكك حديد طنطا المركزية (محافظة الغربية) 🚆' : 'Tanta Central Railway Station (Gharbia) 🚆',
        metroLine: isAr ? 'خط سكك حديد الدلتا (القاهرة ➔ طنطا) - قطار مباشر 65 دقيقة' : 'Delta Railway Line (Cairo ➔ Tanta) - 65 mins express',
        metroWalk: isAr ? '5 دقائق بسرفيس شارع الجيش من أمام محطة قطار طنطا' : '5 mins taxi / shuttle along El-Geish St from station',
        metroFare: isAr ? 'تذكرة قطار طنطا (35 - 70 ج.م) + 10 ج.م تاكسي داخلي' : 'Train ticket (35-70 EGP) + 10 EGP local taxi',
        metroSteps: [
          isAr ? '1. اركب قطار طنطا المباشر من محطة مصر (رمسيس) - الرحلة تستغرق حوالي ساعة.' : '1. Ride direct train from Cairo Ramses to Tanta (approx. 1 hour).',
          isAr ? '2. اخرج من محطة طنطا إلى شارع الجيش واستقل تاكسي أو سرفيس.' : '2. Exit to El-Geish Street and take a local taxi.',
          isAr ? '3. انزل أمام صرح مركز أورام طنطا التخصصي مباشرة.' : '3. Alight directly at Tanta Oncology Center.',
        ],
        taxiCorridor: isAr ? 'طريق القاهرة - الإسكندرية الزراعي أو طريق شبرا - بنها الحر' : 'Shubra-Banha Expressway to Tanta',
        taxiEta: isAr ? 'ساعة و 15 دقيقة' : '1h 15m driving time',
        taxiFare: isAr ? 'سفر الدلتا / تاكسي المحافظات' : 'Intercity travel rate',
        taxiTraffic: isAr ? 'طريق حر سريع' : 'Open expressway via Banha Free Axis',
        isIntercityRail: true,
        busOrTrainTitle: isAr ? 'أتوبيسات شرق الدلتا وميكروباصات موقف عبود' : 'East Delta Coaches & Aboud Shuttles',
        busOrTrainSubtitle: isAr ? 'رحلات دورية كل 15 دقيقة من موقف عبود إلى موقف طنطا' : 'Express vans every 15 mins from Aboud terminal',
        busOrTrainSteps: [
          isAr ? '• اركب ميكروباص طنطا من موقف عبود بالقاهرة.' : '• Take Tanta van from Aboud terminal.',
          isAr ? '• من موقف طنطا استقل سرفيس شارع الجيش لمركز الأورام.' : '• Take El-Geish St local van to the center.',
        ],
        clinicEntranceGuide: isAr
            ? 'البوابة الرئيسية بشارع الجيش - مبنى عيادات الكشف المبكر - قسم أشعة الماموجرام.'
            : 'Main Gate, El-Geish St -> Early Detection Clinic -> Mammography Unit.',
      );
    } else if (center.id == 'center-5') {
      // Mit Ghamr Oncology Center
      return CenterTransitDetails(
        metroStation: isAr ? 'محطة قطار بنها / ميت غمر 🚆' : 'Banha / Mit Ghamr Railway Station 🚆',
        metroLine: isAr ? 'خط قطارات الدلتا وأتوبيسات الدقهلية' : 'Delta Railway & Dakahlia Coaches',
        metroWalk: isAr ? '7 دقائق بتاكسي ميت غمر الداخلي' : '7 mins local taxi from station',
        metroFare: isAr ? '30 - 50 ج.م مواصلات عامة' : '30-50 EGP regional transit',
        metroSteps: [
          isAr ? '1. السفر عبر طريق بنها الزراعي إلى ميت غمر.' : '1. Travel via Banha route to Mit Ghamr.',
          isAr ? '2. استقل تاكسي ميت غمر الداخلي إلى مقر مركز صحة المرأة.' : '2. Take local taxi to the Breast Health Center.',
          isAr ? '3. المركز متخصص بالكامل في جراحات وأورام الثدي.' : '3. Specialized center dedicated to breast health.',
        ],
        taxiCorridor: isAr ? 'طريق شبرا بنها الحر ثم طريق بنها - المنصورة' : 'Shubra Banha Expressway to Mansoura road',
        taxiEta: isAr ? 'ساعة ونصف' : '1h 30m driving time',
        taxiFare: isAr ? 'حسب تعريفة الانتقال بين المحافظات' : 'Intercity rate',
        taxiTraffic: isAr ? 'حركة سير مقبولة' : 'Acceptable flow',
        isIntercityRail: true,
        busOrTrainTitle: isAr ? 'ميكروباصات ميت غمر من موقف العاشر وموقف عبود' : 'Direct vans from 10th of Ramadan / Aboud',
        busOrTrainSubtitle: isAr ? 'رحلات مباشرة مستمرة إلى وسط مدينة ميت غمر' : 'Direct regional vans to downtown Mit Ghamr',
        busOrTrainSteps: [
          isAr ? '• اركب سيارة ميت غمر من موقف العاشر أو عبود.' : '• Board Mit Ghamr van from Aboud terminal.',
          isAr ? '• انزل عند مدخل مركز الأورام التخصصي.' : '• Alight at specialized oncology center entrance.',
        ],
        clinicEntranceGuide: isAr
            ? 'الاستقبال الرئيسي لمركز أورام ميت غمر - مكتب فرز الحالات وتنسيق فحص السونار والماموجرام.'
            : 'Main Reception -> Lumyra triage & screening desk.',
      );
    } else {
      // Assiut or fallback
      return CenterTransitDetails(
        metroStation: isAr ? 'محطة قطارات سكك حديد أسيوط المركزية 🚆' : 'Assiut Central Railway Station 🚆',
        metroLine: isAr ? 'قطار تالجو الصعيد الفاخر أو قطار VIP المكيف (القاهرة/الجيزة ➔ أسيوط)' : 'Upper Egypt Talgo / VIP Express (Cairo/Giza ➔ Assiut)',
        metroWalk: isAr ? '7 دقائق بتاكسي أسيوط الداخلي لمجمع الكليات الطبية' : '7 mins local taxi to University Medical Campus',
        metroFare: isAr ? 'تذكرة قطار الصعيد تالجو/VIP (120 - 250 ج.م) + 20 ج.م تاكسي أسيوط' : 'Train ticket (120-250 EGP) + 20 EGP local taxi',
        metroSteps: [
          isAr ? '1. اركب قطار تالجو الصعيد السريع من محطة الجيزة أو مصر إلى أسيوط (4 ساعات ونصف).' : '1. Take Talgo Upper Egypt Express from Giza/Cairo to Assiut (4.5 hours).',
          isAr ? '2. استقل تاكسي أسيوط أو ميكروباص الجامعة من أمام محطة قطار أسيوط.' : '2. Take local taxi or university shuttle from Assiut station.',
          isAr ? '3. انزل داخل مجمع الكليات الطبية بجامعة أسيوط أمام معهد الأورام.' : '3. Alight inside Medical Campus in front of Oncology Institute.',
        ],
        taxiCorridor: isAr ? 'طريق الصعيد الصحراوي الشرقي الحر (طريق الجيش)' : 'Upper Egypt Eastern Desert Free Highway',
        taxiEta: isAr ? '4 ساعات بالسيارة' : '4 hours driving time',
        taxiFare: isAr ? 'رحلات سفر الصعيد' : 'Intercity travel',
        taxiTraffic: isAr ? 'طريق صحراوي سريع ومفتوح' : 'Open desert highway',
        isIntercityRail: true,
        busOrTrainTitle: isAr ? 'حافلات الصعيد سوبر جيت وجو باص' : 'SuperJet & Upper Egypt Express Coaches',
        busOrTrainSubtitle: isAr ? 'رحلات يومية مجدولة من محطة الترجمان والمنيب إلى أسيوط' : 'Daily scheduled coaches from Moneeb / Torgoman',
        busOrTrainSteps: [
          isAr ? '• احجز حافلة سوبر جيت من موقف المنيب إلى أسيوط.' : '• Book coach from Moneeb terminal to Assiut.',
          isAr ? '• النزول بموقف أسيوط ثم 8 دقائق بالتاكسي لمستشفى الأورام.' : '• 8 mins local taxi to University Oncology Institute.',
        ],
        clinicEntranceGuide: isAr
            ? 'مستشفى الأورام الجامعي بأسيوط - مجمع الكليات الطبية - عيادات صحة المرأة والماموجرام بالدور الأول.'
            : 'Assiut University Oncology Hospital -> Medical Campus -> Breast Unit 1st floor.',
      );
    }
  }

  void _showSmartTransitModal(BuildContext context, MedicalCenterItem center) {
    final isAr = context.isArabic;
    final distanceKm = _getDistanceKm(center);
    final transit = _getTransitRoute(center, distanceKm, isAr);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SmartTransitModalSheet(
        center: center,
        transit: transit,
        distanceKm: distanceKm,
        currentLocationName: _currentLocationName,
        onCallPhone: _callPhone,
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
                          onPressed: () => _showSmartTransitModal(context, center),
                          icon: const Icon(Icons.directions_transit_rounded, size: 16),
                          label: Text(context.isArabic ? 'المسار الذكي' : 'Smart Route'),
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

class _SmartTransitModalSheet extends StatefulWidget {
  final MedicalCenterItem center;
  final CenterTransitDetails transit;
  final double distanceKm;
  final String currentLocationName;
  final void Function(String phone) onCallPhone;

  const _SmartTransitModalSheet({
    required this.center,
    required this.transit,
    required this.distanceKm,
    required this.currentLocationName,
    required this.onCallPhone,
  });

  @override
  State<_SmartTransitModalSheet> createState() => _SmartTransitModalSheetState();
}

class _SmartTransitModalSheetState extends State<_SmartTransitModalSheet> {
  int _activeTab = 0; // 0 = Metro/Train, 1 = Taxi/Car, 2 = Bus/Coach, 3 = Clinic Guide

  Widget _buildTransitTabItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
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

  Widget _buildTransitTabContent({
    required int tabIndex,
    required CenterTransitDetails transit,
    required MedicalCenterItem center,
    required double distanceKm,
    required bool isAr,
  }) {
    if (tabIndex == 0) {
      // Metro / Intercity Train
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.softDustyBlush),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      transit.isIntercityRail ? Icons.train_rounded : Icons.subway_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transit.metroStation,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${isAr ? "الخط:" : "Line:"} ${transit.metroLine}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mainText),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.powderBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🚶 ${transit.metroWalk}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.softDustyBlush),
                      ),
                      child: Text(
                        '🎟️ ${transit.metroFare}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isAr ? 'خطوات التحرك خطوة بخطوة:' : 'Step-by-Step Directions:',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          ...transit.metroSteps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.mainText, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (tabIndex == 1) {
      // Taxi / Rideshare
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.softDustyBlush),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_taxi_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          isAr ? 'تقدير الرحلة بالتاكسي / أوبر' : 'Estimated Rideshare Trip',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primary),
                        ),
                      ],
                    ),
                    StatusBadge.active(isAr ? 'مباشر' : 'Direct'),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'المدة التقديرية:' : 'Est. Duration:',
                            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                          ),
                          Text(
                            transit.taxiEta,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'التكلفة التقريبية:' : 'Est. Fare:',
                            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                          ),
                          Text(
                            transit.taxiFare,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isAr ? 'أسرع مسار / محور رئيسي:' : 'Fastest Corridor:',
                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                ),
                Text(
                  transit.taxiCorridor,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.mainText),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.traffic_rounded, color: Colors.teal, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      transit.taxiTraffic,
                      style: const TextStyle(fontSize: 11.5, color: Colors.teal, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.powderBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAr
                        ? 'يمكنكِ نسخ العنوان بالأسفل ولصقه مباشرة في تطبيق أوبر أو إندرايف أو إعطائه لسائق التاكسي.'
                        : 'You can copy the address below and paste it into Uber/rideshare app.',
                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (tabIndex == 2) {
      // Buses / Public Transit
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.softDustyBlush),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_bus_filled_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transit.busOrTrainTitle,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  transit.busOrTrainSubtitle,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mainText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isAr ? 'محطات الركوب والتوقف:' : 'Boarding & Stops:',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          ...transit.busOrTrainSteps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_circle_right_rounded, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.mainText, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      // Clinic Arrival Guide
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.softDustyBlush),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.meeting_room_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAr ? 'إرشادات الوصول لداخل العيادة / المركز' : 'Clinic Arrival & Desk Navigation',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Text(
                  transit.clinicEntranceGuide,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText, height: 1.4),
                ),
                if (center.isDoctorClinic && center.doctorName != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.powderBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.medical_services_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${isAr ? "الطبيب المعالج:" : "Physician:"} ${center.doctorName} • ${center.specialty ?? ""}',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.powderBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAr
                        ? 'عند وصولكِ، أظهري تطبيق لوميرا لمكتب الاستقبال للحصول على مسار الأولوية والخدمة الاستشارية المعتمدة.'
                        : 'Present Lumyra app at the desk for verified appointment queue.',
                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isArabic;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(top: 14, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header with Destination & Distance
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.alt_route_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusBadge.blush(widget.center.governorate),
                          const SizedBox(width: 6),
                          Text(
                            isAr ? 'المسار الذكي المباشر' : 'Smart Transit Route',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.center.name,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.center.address,
                        style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Origin & Proximity Calculated Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.powderBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.softDustyBlush),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'نقطة الانطلاق (موقعكِ الحالي)' : 'Starting Location',
                          style: const TextStyle(fontSize: 10.5, color: AppColors.secondaryText),
                        ),
                        Text(
                          widget.currentLocationName,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${widget.distanceKm.toStringAsFixed(1)} ${isAr ? "كم" : "km"}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Multimodal Transit Selection Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.powderBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildTransitTabItem(
                    title: widget.transit.isIntercityRail ? (isAr ? '🚆 قطار السفر' : '🚆 Rail') : (isAr ? '🚇 المترو' : '🚇 Metro'),
                    isSelected: _activeTab == 0,
                    onTap: () => setState(() => _activeTab = 0),
                  ),
                  _buildTransitTabItem(
                    title: isAr ? '🚕 تاكسي / أوبر' : '🚕 Taxi',
                    isSelected: _activeTab == 1,
                    onTap: () => setState(() => _activeTab = 1),
                  ),
                  _buildTransitTabItem(
                    title: isAr ? '🚌 حافلات' : '🚌 Buses',
                    isSelected: _activeTab == 2,
                    onTap: () => setState(() => _activeTab = 2),
                  ),
                  _buildTransitTabItem(
                    title: isAr ? '🏥 الوصول' : '🏥 Guide',
                    isSelected: _activeTab == 3,
                    onTap: () => setState(() => _activeTab = 3),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tab Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _buildTransitTabContent(
                tabIndex: _activeTab,
                transit: widget.transit,
                center: widget.center,
                distanceKm: widget.distanceKm,
                isAr: isAr,
              ),
            ),
          ),

          // Bottom Action Buttons with Safe Area padding
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                      label: Text(
                        isAr ? 'اتصال بالمركز (${widget.center.phone})' : 'Call Center (${widget.center.phone})',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      onPressed: () => widget.onCallPhone(widget.center.phone),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text(
                      isAr ? 'نسخ العنوان' : 'Copy',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: '${widget.center.name} - ${widget.center.address}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isAr ? 'تم نسخ عنوان المركز بنجاح 📋' : 'Address copied to clipboard 📋'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
