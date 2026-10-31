import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole {
  patient,
  doctor,
  admin,
}

extension UserRoleExtension on UserRole {
  String get id {
    switch (this) {
      case UserRole.patient:
        return 'patient';
      case UserRole.doctor:
        return 'doctor';
      case UserRole.admin:
        return 'admin';
    }
  }

  String get displayNameAr {
    switch (this) {
      case UserRole.patient:
        return 'مريضة / مستخدمة';
      case UserRole.doctor:
        return 'طبيب / أخصائي';
      case UserRole.admin:
        return 'مسؤول النظام';
    }
  }

  String get displayNameEn {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}

/// Active user role state for the session
final userRoleProvider = NotifierProvider<UserRoleNotifier, UserRole>(() => UserRoleNotifier());

class UserRoleNotifier extends Notifier<UserRole> {
  @override
  UserRole build() => UserRole.patient;

  void selectRole(UserRole role) {
    state = role;
  }
}
