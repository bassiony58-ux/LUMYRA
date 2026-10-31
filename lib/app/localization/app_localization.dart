import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Language state provider (defaults to Arabic 'ar' with English fallback)
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() => LocaleNotifier());

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('ar');

  void setLocale(Locale newLocale) {
    state = newLocale;
  }

  void toggleLocale() {
    state = state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
  }
}

class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Lumyra',
      'tagline': 'Compassionate Breast Health Companion',
      'language': 'Language',
      'switchToArabic': 'العربية',
      'switchToEnglish': 'English',
      
      // Onboarding & Role Selection
      'welcomeTitle': 'Empowering Your Health Journey',
      'welcomeSubtitle': 'A trusted, calm companion supporting you with clinical guidance, care tracking, and personalized breast wellness.',
      'getStarted': 'Get Started',
      'chooseRoleTitle': 'Select Your Role',
      'chooseRoleSubtitle': 'Please choose how you will be using Lumyra to tailor your experience.',
      'rolePatient': 'Patient / Individual',
      'rolePatientDesc': 'Access personalized breast wellness, appointments, medication tracking, journal, and health resources.',
      'roleDoctor': 'Doctor / Clinician',
      'roleDoctorDesc': 'Manage authorized patients, review care timelines, inspect secondary scans, and triage alerts.',
      'roleAdmin': 'Administrator',
      'roleAdminDesc': 'Oversee clinical verification, platform directories, operational analytics, and system audit trails.',
      'continueAs': 'Continue as',

      // Auth
      'login': 'Sign In',
      'register': 'Create Account',
      'email': 'Email Address',
      'password': 'Password',
      'forgotPassword': 'Forgot Password?',
      'dontHaveAccount': 'Do not have an account?',
      'alreadyHaveAccount': 'Already have an account?',
      'orContinueWith': 'Or continue with',
      'logout': 'Sign Out',

      // Navigation
      'navHome': 'Home',
      'navRisk': 'Assessment',
      'navEducation': 'Library',
      'navJournal': 'Journal',
      'navCare': 'Meds',
      'navCenters': 'Centers',
      'navAssistant': 'AI Assistant',
      'navProfile': 'Profile',
      'navPatients': 'My Patients',
      'navImaging': 'Scan Review',
      'navApprovals': 'Approvals',
      'navAnalytics': 'Analytics',
      'navUsers': 'User Management',

      // Medications
      'medications': 'Active Medications',

      // Patient Dashboard
      'greeting': 'Welcome back',
      'upcomingAppointments': 'Upcoming Appointments',
      'noUpcomingAppointments': 'No upcoming appointments scheduled',
      'bookAppointment': 'Book Appointment',
      'medicationReminders': 'Medication Schedule',
      'noMedications': 'No active medications today',
      'quickActions': 'Quick Actions',
      'takeRiskAssessment': 'Guided Risk Check',
      'writeInJournal': 'Write in Journal',
      'exploreCenters': 'Find Medical Center',
      'askAssistant': 'Ask Health Companion',
      'healthArticles': 'Recommended Reading',
      'viewAll': 'View All',
      'recentActivity': 'Recent Activity',

      // Risk Assessment
      'riskAssessmentTitle': 'Guided Breast Health Questionnaire',
      'riskNotice': 'Educational Risk Evaluation Notice',
      'riskNoticeBody': 'This questionnaire collects lifestyle, reproductive, and family pedigree indicators. It is not an algorithmic replacement for clinical diagnosis or genetic testing. Consult your doctor for personal medical decisions.',

      // Secondary Image Analysis (Doctor)
      'imagingTitle': 'Secondary Medical Image Review',
      'imagingWarningTitle': 'Mandatory Clinical Review Warning',
      'imagingWarningBody': 'This interface provides automated secondary observations. It is not a certified diagnostic device. Final medical determinations must be made by the attending physician.',
      'uploadScan': 'Upload Scan',
      'selectPatient': 'Select Patient',
      'analysisHistory': 'Analysis History',

      // Status
      'statusActive': 'Active',
      'statusPending': 'Pending Review',
      'statusScheduled': 'Scheduled',
      'statusCompleted': 'Completed',
      'statusCancelled': 'Cancelled',
    },
    'ar': {
      'appName': 'لوميرا',
      'tagline': 'رفيقتك الموثوقة لصحة الثدي',
      'language': 'اللغة',
      'switchToArabic': 'العربية',
      'switchToEnglish': 'English',

      // Onboarding & Role Selection
      'welcomeTitle': 'معكِ في كل خطوة نحو الشفاء والاطمئنان',
      'welcomeSubtitle': 'منصة رقمية هادئة وموثوقة تجمع بين الرعاية الطبية، المتابعة اليومية، والدعم التوعوي لصحة الثدي.',
      'getStarted': 'ابدئي الآن',
      'chooseRoleTitle': 'اختيار نوع الحساب',
      'chooseRoleSubtitle': 'يرجى تحديد دورك في لوميرا لتخصيص التجربة الطبية المناسبة لك.',
      'rolePatient': 'مريضة / مستخدمة',
      'rolePatientDesc': 'متابعة صحتك، حجز المواعيد، تذكير الأدوية، اليوميات الخاصة، ومكتبة التوعية الصحية.',
      'roleDoctor': 'طبيب / أخصائي',
      'roleDoctorDesc': 'متابعة المريضات المصرح لهن، استعراض السجل الصحي، مراجعة الفحوصات الطبية، والتنبيهات.',
      'roleAdmin': 'مسؤول النظام',
      'roleAdminDesc': 'اعتماد تراخيص الأطباء، إدارة دليل المراكز الطبية والمحتوى، ومراقبة سجلات الأمان.',
      'continueAs': 'المتابعة بصفتي',

      // Auth
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب جديد',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'dontHaveAccount': 'ليس لديكِ حساب؟',
      'alreadyHaveAccount': 'لديكِ حساب بالفعل؟',
      'orContinueWith': 'أو المتابعة عبر',
      'logout': 'تسجيل الخروج',

      // Navigation
      'navHome': 'الرئيسية',
      'navRisk': 'تقييم صحي',
      'navEducation': 'التوعية',
      'navJournal': 'يومياتي',
      'navCare': 'أدويتي',
      'navCenters': 'المراكز',
      'navAssistant': 'المساعد الذكي',
      'navProfile': 'الملف الشخصي',
      'navPatients': 'مريضاتي',
      'navImaging': 'تحليل الصور',
      'navApprovals': 'طلبات الاعتماد',
      'navAnalytics': 'الإحصائيات',
      'navUsers': 'إدارة المستخدمين',

      // Medications
      'medications': 'الأدوية المقررة والنشطة',

      // Patient Dashboard
      'greeting': 'أهلاً بكِ',
      'upcomingAppointments': 'المواعيد القادمة',
      'noUpcomingAppointments': 'لا توجد مواعيد مجدولة حالياً',
      'bookAppointment': 'حجز موعد جديد',
      'medicationReminders': 'جدول الأدوية اليومي',
      'noMedications': 'لا توجد أدوية مسجلة لليوم',
      'quickActions': 'إجراءات سريعة',
      'takeRiskAssessment': 'استبيان تقييم المخاطر',
      'writeInJournal': 'تدوين في اليوميات',
      'exploreCenters': 'البحث عن مركز طبي',
      'askAssistant': 'استشارة المساعد الصحي',
      'healthArticles': 'مقالات وتوجيهات موثوقة',
      'viewAll': 'عرض الكل',
      'recentActivity': 'النشاط الأخير',

      // Risk Assessment
      'riskAssessmentTitle': 'استبيان تقييم مخاطر صحة الثدي',
      'riskNotice': 'إخلاء مسؤولية طبي وإرشادي',
      'riskNoticeBody': 'هذا الاستبيان يجمع معلومات حول نمط الحياة والتاريخ العائلي لأغراض التوعية والإرشاد العام فقط. لا يُعتبر بديلاً عن الفحص السريري أو الاستشارة الطبية المتخصصة.',

      // Secondary Image Analysis (Doctor)
      'imagingTitle': 'المراجعة الاسترشادية للصور الطبية',
      'imagingWarningTitle': 'تنبيه استشاري سريري إلزامي',
      'imagingWarningBody': 'توفر هذه الواجهة ملاحظات بصرية استرشادية ثانوية فقط. لا تمثل تشخيصاً طبياً معتمداً، ويجب أن يرتكز القرار العلاجي على التشخيص الإكلينيكي المباشر للطبيب المعالج.',
      'uploadScan': 'رفع صورة فحص (ماموجرام / سونار)',
      'selectPatient': 'تحديد المريضة',
      'analysisHistory': 'سجل المراجعات السابقة',

      // Status
      'statusActive': 'نشط',
      'statusPending': 'قيد المراجعة',
      'statusScheduled': 'مجدول',
      'statusCompleted': 'مكتمل',
      'statusCancelled': 'ملغي',
    },
  };

  static String of(BuildContext context, String key) {
    final locale = Localizations.localeOf(context);
    final langCode = _localizedValues.containsKey(locale.languageCode) ? locale.languageCode : 'ar';
    return _localizedValues[langCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}

extension AppStringsExtension on BuildContext {
  String tr(String key) => AppStrings.of(this, key);
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
}
