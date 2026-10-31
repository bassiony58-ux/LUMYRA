import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/patient_dashboard_repository.dart';
import '../../domain/models/patient_dashboard_data.dart';

final patientDashboardRepositoryProvider = Provider<PatientDashboardRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final session = ref.watch(authSessionProvider).asData?.value;
  // If session token starts with mock- or is null, demo mode is enabled
  final isDemo = session == null || session.token.startsWith('mock-');
  return ApiPatientDashboardRepository(
    apiClient,
    isDemoAccount: isDemo,
    userDisplayName: session?.displayName ?? 'مريم علي',
    userEmail: session?.email ?? 'mariam@lumyra.health',
  );
});

final patientDashboardProvider =
    AsyncNotifierProvider<PatientDashboardNotifier, PatientDashboardData>(
  () => PatientDashboardNotifier(),
);

class PatientDashboardNotifier extends AsyncNotifier<PatientDashboardData> {
  @override
  Future<PatientDashboardData> build() async {
    final repo = ref.watch(patientDashboardRepositoryProvider);
    return repo.fetchDashboardData();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(patientDashboardRepositoryProvider);
      return repo.fetchDashboardData();
    });
  }
}
