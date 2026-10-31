import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user_role.dart';
import '../../features/auth/domain/user_session.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/patient_dashboard/presentation/patient_dashboard_screen.dart';
import '../../features/doctor_dashboard/presentation/doctor_dashboard_screen.dart';
import '../../features/admin_dashboard/presentation/admin_dashboard_screen.dart';
import '../../features/education/presentation/education_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/medications/presentation/medication_tracker_screen.dart';
import '../../features/appointments/presentation/appointments_screen.dart';
import '../../features/medical_centers/presentation/medical_centers_screen.dart';
import '../../features/ai_assistant/presentation/ai_assistant_screen.dart';
import '../../features/doctor_dashboard/presentation/patient_chart_screen.dart';
import '../../features/doctor_dashboard/presentation/imaging_viewer_screen.dart';
import '../../features/admin_dashboard/presentation/doctor_approvals_screen.dart';
import '../../features/admin_dashboard/presentation/audit_logs_screen.dart';
import '../../features/admin_dashboard/presentation/user_management_screen.dart';
import '../../features/questionnaire/presentation/questionnaire_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<UserSession?>>(
      authSessionProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authSessionProvider);
    final session = authState.asData?.value;
    final loc = state.matchedLocation;
    final isAuthRoute = loc == '/auth/login' || loc == '/auth/register';
    final isCheckRoute = loc == '/check';
    final isPublicRoute = loc == '/' || loc == '/choose-role' || isAuthRoute || isCheckRoute;
    final isAuthenticated = session != null;

    // 1. If not authenticated and attempting to visit a protected route
    if (!isAuthenticated && !isPublicRoute) {
      return '/auth/login';
    }

    // 2. If already authenticated and trying to visit login/register/onboarding
    if (isAuthenticated && (isAuthRoute || loc == '/' || loc == '/choose-role')) {
      switch (session.role) {
        case UserRole.patient:
          return '/patient';
        case UserRole.doctor:
          return '/doctor';
        case UserRole.admin:
          return '/admin';
      }
    }

    // 3. Strict server-side role enforcement: Patients cannot visit doctor or admin routes
    if (isAuthenticated && session.role == UserRole.patient) {
      if (loc.startsWith('/doctor') || loc.startsWith('/admin')) {
        return '/patient';
      }
    }

    // 4. Doctors cannot visit admin routes
    if (isAuthenticated && session.role == UserRole.doctor) {
      if (loc.startsWith('/admin')) {
        return '/doctor';
      }
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    debugLogDiagnostics: false,
    routes: [
      // Onboarding & Role Selection
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/choose-role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/check',
        builder: (context, state) => const QuestionnaireScreen(isGuest: true),
      ),

      // Auth
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Patient Routes
      GoRoute(
        path: '/patient',
        builder: (context, state) => const PatientDashboardScreen(),
        routes: [
          GoRoute(
            path: 'risk',
            builder: (context, state) => const QuestionnaireScreen(),
          ),
          GoRoute(
            path: 'education',
            builder: (context, state) => const EducationScreen(),
          ),
          GoRoute(
            path: 'journal',
            builder: (context, state) => const JournalScreen(),
          ),
          GoRoute(
            path: 'care',
            builder: (context, state) => const MedicationTrackerScreen(),
          ),
          GoRoute(
            path: 'medications',
            builder: (context, state) => const MedicationTrackerScreen(),
          ),
          GoRoute(
            path: 'appointments',
            builder: (context, state) => const AppointmentsScreen(),
          ),
          GoRoute(
            path: 'centers',
            builder: (context, state) => const MedicalCentersScreen(),
          ),
          GoRoute(
            path: 'assistant',
            builder: (context, state) => const AiAssistantScreen(),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const AppointmentsScreen(),
          ),
        ],
      ),

      // Doctor Routes
      GoRoute(
        path: '/doctor',
        builder: (context, state) => const DoctorDashboardScreen(),
        routes: [
          GoRoute(
            path: 'patients',
            builder: (context, state) => const PatientChartScreen(),
          ),
          GoRoute(
            path: 'imaging',
            builder: (context, state) => const ImagingViewerScreen(),
          ),
          GoRoute(
            path: 'education',
            builder: (context, state) => const EducationScreen(),
          ),
        ],
      ),

      // Admin Routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'approvals',
            builder: (context, state) => const DoctorApprovalsScreen(),
          ),
          GoRoute(
            path: 'users',
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: 'centers',
            builder: (context, state) => const MedicalCentersScreen(),
          ),
          GoRoute(
            path: 'audit',
            builder: (context, state) => const AuditLogsScreen(),
          ),
          GoRoute(
            path: 'analytics',
            builder: (context, state) => const AuditLogsScreen(),
          ),
        ],
      ),
    ],
  );
});
