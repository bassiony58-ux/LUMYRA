import '../../../core/network/api_client.dart';
import '../domain/models/patient_dashboard_data.dart';

abstract class PatientDashboardRepository {
  Future<PatientDashboardData> fetchDashboardData();
}

class ApiPatientDashboardRepository implements PatientDashboardRepository {
  final ApiClient _apiClient;
  final bool isDemoAccount;
  final String userDisplayName;
  final String userEmail;

  ApiPatientDashboardRepository(
    this._apiClient, {
    this.isDemoAccount = true,
    this.userDisplayName = 'مريم علي',
    this.userEmail = 'mariam@lumyra.health',
  });

  @override
  Future<PatientDashboardData> fetchDashboardData() async {
    try {
      final response = await _apiClient.get('/patients/me/dashboard');

      if (response is Map<String, dynamic>) {
        return PatientDashboardData.fromJson(response);
      }
    } catch (_) {
      // Instant graceful fallback
      return _buildFallbackData();
    }

    return _buildFallbackData();
  }

  PatientDashboardData _buildFallbackData() {
    if (!isDemoAccount) {
      // Real Login / Signup Account: Clean slate, zero pre-filled demo appointments/meds
      return PatientDashboardData(
        profile: PatientProfileSummary(
          id: 'pat-user-id',
          displayName: userDisplayName.isNotEmpty ? userDisplayName : 'مستخدمة لوميرا',
          email: userEmail.isNotEmpty ? userEmail : 'patient@lumyra.health',
          preferredLanguage: 'ar',
          consentForCareTracking: true,
        ),
        upcomingAppointments: const [],
        activeMedications: const [],
        recommendedArticles: _sampleArticles,
        careTeam: const [],
      );
    }

    // Demo Account: Preset interactive sample data for clinical testing
    return PatientDashboardData(
      profile: PatientProfileSummary(
        id: 'pat-mariam-id',
        displayName: userDisplayName,
        email: userEmail,
        preferredLanguage: 'ar',
        consentForCareTracking: true,
      ),
      upcomingAppointments: [
        UpcomingAppointment(
          id: 'appt-01',
          doctorName: 'د. نور الخالدي',
          specialty: 'استشاري جراحة وأورام الثدي',
          scheduledAt: DateTime.now().add(const Duration(days: 3, hours: 2)),
          estimatedDurationMinutes: 30,
          status: 'SCHEDULED',
          reason: 'متابعة سريرية دورية للاطمئنان',
        ),
      ],
      activeMedications: [
        MedicationReminder(
          id: 'med-01',
          name: 'تاموكسيفين (Tamoxifen)',
          dosage: '20 مجم',
          instructions: 'حبة واحدة يومياً بعد الإفطار مع كوب ماء كامل',
          frequency: 'ONCE_DAILY',
          timeOfDay: const ['09:00'],
          startDate: DateTime.now().subtract(const Duration(days: 14)),
        ),
      ],
      recommendedArticles: _sampleArticles,
      careTeam: const [],
    );
  }

  static const List<EducationalRecommendation> _sampleArticles = [
    EducationalRecommendation(
      id: 'art-01',
      slug: 'self-exam-guide',
      titleAr: 'دليلك الشامل للفحص الذاتي الشهري في ٥ خطوات بسيطة 🌸',
      titleEn: 'Your 5-Step Breast Self-Exam Guide',
      summaryAr: 'خطوات الفحص السريري الذاتي المنزلي للاطمئنان الدوري.',
      summaryEn: 'Monthly at-home self-examination guide.',
      categoryNameAr: 'الكشف المبكر والتوعية',
      categoryNameEn: 'Early Detection',
      readTimeMinutes: 4,
    ),
    EducationalRecommendation(
      id: 'art-02',
      slug: 'nutrition-wellness',
      titleAr: 'التغذية المتوازنة ومضادات الأكسدة الداعمة لصحة الأنسجة',
      titleEn: 'Nutrition & Antioxidants for Tissue Wellness',
      summaryAr: 'أهم الأطعمة الغنية بمضادات الأكسدة لحماية الخلايا.',
      summaryEn: 'Key nutritional tips for breast health.',
      categoryNameAr: 'النمط الصحي والتعافي',
      categoryNameEn: 'Healthy Lifestyle',
      readTimeMinutes: 5,
    ),
  ];
}
