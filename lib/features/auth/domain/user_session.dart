import '../../../core/models/user_role.dart';

class UserSession {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String status;
  final String token;
  final String? patientProfileId;
  final String? doctorProfileId;
  final String? doctorApprovalStatus;

  const UserSession({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
    required this.token,
    this.patientProfileId,
    this.doctorProfileId,
    this.doctorApprovalStatus,
  });

  factory UserSession.fromServerUser({
    required Map<String, dynamic> json,
    required String token,
  }) {
    final rawRole = (json['role'] as String? ?? 'PATIENT').toUpperCase();
    UserRole role = UserRole.patient;
    if (rawRole == 'DOCTOR') {
      role = UserRole.doctor;
    } else if (rawRole == 'ADMIN') {
      role = UserRole.admin;
    }

    final patientProfile = json['patientProfile'] as Map<String, dynamic>?;
    final doctorProfile = json['doctorProfile'] as Map<String, dynamic>?;

    return UserSession(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'User',
      role: role,
      status: json['status'] as String? ?? 'ACTIVE',
      token: token,
      patientProfileId: patientProfile?['id'] as String? ?? json['patientProfileId'] as String?,
      doctorProfileId: doctorProfile?['id'] as String? ?? json['doctorProfileId'] as String?,
      doctorApprovalStatus: doctorProfile?['approvalStatus'] as String? ?? json['doctorStatus'] as String?,
    );
  }

  bool get isApprovedDoctor => role == UserRole.doctor && doctorApprovalStatus == 'APPROVED';
}
