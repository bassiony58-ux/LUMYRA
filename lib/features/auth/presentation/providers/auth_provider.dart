import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/network/api_client.dart';
import '../../data/auth_repository.dart';
import '../../domain/user_session.dart';

/// Notifier for raw token string
class AuthTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setToken(String? token) => state = token;
}

/// Provider for raw token string
final authTokenProvider =
    NotifierProvider<AuthTokenNotifier, String?>(() => AuthTokenNotifier());

/// Central ApiClient provider injecting current auth token
final apiClientProvider = Provider<ApiClient>((ref) {
  final token = ref.watch(authTokenProvider);
  return ApiClient(
    tokenProvider: () => token,
    onSessionExpired: () {
      ref.read(authSessionProvider.notifier).logout();
    },
  );
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiAuthRepository(apiClient);
});

/// Reactive session notifier managing login, role sync, and logout
final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AsyncValue<UserSession?>>(() => AuthSessionNotifier());

class AuthSessionNotifier extends Notifier<AsyncValue<UserSession?>> {
  @override
  AsyncValue<UserSession?> build() {
    return const AsyncData(null);
  }

  void setSession(UserSession session) {
    ref.read(authTokenProvider.notifier).setToken(session.token);
    ref.read(userRoleProvider.notifier).selectRole(session.role);
    state = AsyncData(session);
  }

  Future<void> loginWithDevRole(UserRole role) async {
    try {
      String token;
      switch (role) {
        case UserRole.patient:
          token = 'mock-patient-token';
          break;
        case UserRole.doctor:
          token = 'mock-doctor-approved-token';
          break;
        case UserRole.admin:
          token = 'mock-admin-token';
          break;
      }

      final repo = ref.read(authRepositoryProvider);
      final session = await repo.loginWithDevToken(token);

      // Persist token in state provider
      ref.read(authTokenProvider.notifier).setToken(session.token);

      // Sync role notifier with server-verified role
      ref.read(userRoleProvider.notifier).selectRole(session.role);

      state = AsyncData(session);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> loginWithToken(String token) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(authRepositoryProvider);
      final session = await repo.fetchCurrentUser(token);

      ref.read(authTokenProvider.notifier).setToken(session.token);
      ref.read(userRoleProvider.notifier).selectRole(session.role);

      state = AsyncData(session);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    ref.read(authTokenProvider.notifier).setToken(null);
    state = const AsyncData(null);
  }
}
