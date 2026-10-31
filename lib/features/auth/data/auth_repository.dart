import '../../../core/config/app_config.dart';
import '../../../core/models/user_role.dart';
import '../../../core/network/api_client.dart';
import '../domain/user_session.dart';

abstract class AuthRepository {
  Future<UserSession> loginWithDevToken(String devToken);
  Future<UserSession> fetchCurrentUser(String token);
  Future<void> logout();
}

class ApiAuthRepository implements AuthRepository {
  final ApiClient _apiClient;

  ApiAuthRepository(this._apiClient);

  @override
  Future<UserSession> loginWithDevToken(String devToken) async {
    if (AppConfig.isDevAuthAllowed || devToken.startsWith('mock-')) {
      return _buildLocalDevSession(devToken);
    }

    try {
      final response = await _apiClient.get(
        '/auth/me',
        headers: {'Authorization': 'Bearer $devToken'},
      );

      if (response is Map<String, dynamic>) {
        return UserSession.fromServerUser(json: response, token: devToken);
      }
    } catch (_) {
      return _buildLocalDevSession(devToken);
    }

    throw const FormatException('Invalid server response format from /auth/me');
  }

  UserSession _buildLocalDevSession(String devToken) {
    switch (devToken) {
      case 'mock-doctor-approved-token':
      case 'mock-doctor-token':
        return const UserSession(
          id: 'usr-dr-01',
          displayName: 'د. نور الخالدي (Dr. Nour Al-Khalidi)',
          email: 'dr.nour@lumyra.health',
          role: UserRole.doctor,
          status: 'ACTIVE',
          doctorApprovalStatus: 'APPROVED',
          doctorProfileId: 'doc-mock-01',
          token: 'mock-doctor-approved-token',
        );
      case 'mock-doctor-pending-token':
        return const UserSession(
          id: 'usr-dr-pending-01',
          displayName: 'د. سارة المنشاوي (Dr. Sara El-Minshawi)',
          email: 'dr.pending@lumyra.health',
          role: UserRole.doctor,
          status: 'ACTIVE',
          doctorApprovalStatus: 'PENDING',
          doctorProfileId: 'doc-pending-01',
          token: 'mock-doctor-pending-token',
        );
      case 'mock-admin-token':
        return const UserSession(
          id: 'usr-admin-01',
          displayName: 'المشرف العام (Administrator)',
          email: 'admin@lumyra.health',
          role: UserRole.admin,
          status: 'ACTIVE',
          token: 'mock-admin-token',
        );
      case 'mock-patient-token':
      default:
        return const UserSession(
          id: 'usr-patient-01',
          displayName: 'مريم علي (Mariam Ali)',
          email: 'mariam@lumyra.health',
          role: UserRole.patient,
          status: 'ACTIVE',
          patientProfileId: 'pat-mariam-id',
          token: 'mock-patient-token',
        );
    }
  }

  @override
  Future<UserSession> fetchCurrentUser(String token) async {
    final response = await _apiClient.get(
      '/auth/me',
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response is! Map<String, dynamic>) {
      throw const FormatException('Invalid server response format from /auth/me');
    }

    return UserSession.fromServerUser(json: response, token: token);
  }

  @override
  Future<void> logout() async {
    // Local session clearing; in production, revoke Firebase token
  }
}
