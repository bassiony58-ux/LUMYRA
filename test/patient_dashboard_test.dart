import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumyra/app/theme/app_theme.dart';
import 'package:lumyra/app/theme/app_typography.dart';
import 'package:lumyra/features/patient_dashboard/data/patient_dashboard_repository.dart';
import 'package:lumyra/features/patient_dashboard/domain/models/patient_dashboard_data.dart';
import 'package:lumyra/features/patient_dashboard/presentation/patient_dashboard_screen.dart';
import 'package:lumyra/features/patient_dashboard/presentation/providers/patient_dashboard_provider.dart';

class MockPatientDashboardRepository implements PatientDashboardRepository {
  final PatientDashboardData Function() onFetch;
  MockPatientDashboardRepository(this.onFetch);

  @override
  Future<PatientDashboardData> fetchDashboardData() async {
    return onFetch();
  }
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    AppTypography.isTestMode = true;
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final sampleData = PatientDashboardData(
    profile: const PatientProfileSummary(
      id: 'pat-001',
      displayName: 'Mariam Ali',
      email: 'mariam@lumyra.health',
      preferredLanguage: 'ar',
      consentForCareTracking: true,
    ),
    upcomingAppointments: [
      UpcomingAppointment(
        id: 'appt-01',
        doctorName: 'Dr. Nour El-Din',
        specialty: 'Oncology',
        scheduledAt: DateTime(2026, 11, 15, 10, 30),
        estimatedDurationMinutes: 30,
        status: 'SCHEDULED',
        reason: 'Routine follow-up',
      ),
    ],
    activeMedications: [
      MedicationReminder(
        id: 'med-01',
        name: 'Tamoxifen',
        dosage: '20 mg',
        instructions: 'Take once daily after breakfast',
        frequency: 'ONCE_DAILY',
        timeOfDay: const ['09:00'],
        startDate: DateTime(2026, 10, 1),
      ),
    ],
    recommendedArticles: const [
      EducationalRecommendation(
        id: 'art-01',
        slug: 'self-exam-guide',
        titleAr: 'دليلك الشامل للفحص الذاتي',
        titleEn: 'Breast Self-Exam Guide',
        summaryAr: 'دليل الفحص',
        summaryEn: 'Guide',
        categoryNameAr: 'الفحص الذاتي والتوعية',
        categoryNameEn: 'Self-Examination',
        readTimeMinutes: 5,
      ),
    ],
    careTeam: const [],
  );

  final emptyDashboardData = PatientDashboardData(
    profile: const PatientProfileSummary(
      id: 'pat-002',
      displayName: 'Fatima',
      email: 'fatima@lumyra.health',
      preferredLanguage: 'ar',
      consentForCareTracking: true,
    ),
    upcomingAppointments: const [],
    activeMedications: const [],
    recommendedArticles: const [],
    careTeam: const [],
  );

  Widget createTestWidget({required PatientDashboardRepository repository}) {
    return ProviderScope(
      overrides: [
        patientDashboardRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme(isArabic: true),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(body: PatientDashboardScreen()),
      ),
    );
  }

  group('PatientDashboard Tests', () {
    test('PatientDashboardData parses JSON correctly', () {
      final json = {
        'profile': {
          'id': 'pat-1',
          'displayName': 'Sara Ahmed',
          'email': 'sara@test.com',
          'preferredLanguage': 'ar',
          'consentForCareTracking': true,
        },
        'upcomingAppointments': [
          {
            'id': 'app-1',
            'doctorName': 'Dr. Mariam',
            'specialty': 'Surgical Oncology',
            'scheduledAt': '2026-11-20T10:00:00.000Z',
            'estimatedDurationMinutes': 45,
            'status': 'CONFIRMED',
            'reason': 'Screening consult',
          }
        ],
        'activeMedications': [],
        'recommendedArticles': [],
        'careTeam': [],
      };

      final data = PatientDashboardData.fromJson(json);
      expect(data.profile.displayName, 'Sara Ahmed');
      expect(data.upcomingAppointments, hasLength(1));
      expect(data.upcomingAppointments.first.doctorName, 'Dr. Mariam');
      expect(data.activeMedications, isEmpty);
    });

    testWidgets('renders personalized greeting and real appointment & medication cards', (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockPatientDashboardRepository(() => sampleData);

      await tester.pumpWidget(createTestWidget(repository: mockRepo));
      await tester.pumpAndSettle();

      // Check personalized greeting with real user name
      expect(find.textContaining('Mariam Ali'), findsOneWidget);

      // Check real appointment card
      expect(find.text('Dr. Nour El-Din'), findsOneWidget);
      expect(find.text('Routine follow-up'), findsOneWidget);

      // Check real medication card
      expect(find.text('Tamoxifen'), findsOneWidget);
      expect(find.textContaining('20 mg'), findsOneWidget);

      // Check recommended article
      expect(find.text('دليلك الشامل للفحص الذاتي'), findsOneWidget);
    });

    testWidgets('renders honest compassionate empty states when appointments and medications are empty', (tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockPatientDashboardRepository(() => emptyDashboardData);

      await tester.pumpWidget(createTestWidget(repository: mockRepo));
      await tester.pumpAndSettle();

      // Check personalized greeting
      expect(find.textContaining('Fatima'), findsOneWidget);

      // Check honest appointment empty state (not fabricated appointments!)
      expect(find.text('لا توجد مواعيد قادمة مسجلة حالياً'), findsOneWidget);
      expect(find.text('حجز موعد'), findsOneWidget);

      // Check honest medication empty state
      expect(find.text('لا توجد أدوية مسجلة في جدولكِ'), findsOneWidget);
      expect(find.text('إضافة دواء'), findsOneWidget);
    });
  });
}
