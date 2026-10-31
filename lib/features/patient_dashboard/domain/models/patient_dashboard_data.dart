class PatientProfileSummary {
  final String id;
  final String displayName;
  final String email;
  final String preferredLanguage;
  final bool consentForCareTracking;

  const PatientProfileSummary({
    required this.id,
    required this.displayName,
    required this.email,
    required this.preferredLanguage,
    required this.consentForCareTracking,
  });

  factory PatientProfileSummary.fromJson(Map<String, dynamic> json) {
    return PatientProfileSummary(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Patient',
      email: json['email'] as String? ?? '',
      preferredLanguage: json['preferredLanguage'] as String? ?? 'ar',
      consentForCareTracking: json['consentForCareTracking'] as bool? ?? true,
    );
  }
}

class UpcomingAppointment {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime scheduledAt;
  final int estimatedDurationMinutes;
  final String status;
  final String reason;

  const UpcomingAppointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.scheduledAt,
    required this.estimatedDurationMinutes,
    required this.status,
    required this.reason,
  });

  factory UpcomingAppointment.fromJson(Map<String, dynamic> json) {
    return UpcomingAppointment(
      id: json['id'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? 'Doctor',
      specialty: json['specialty'] as String? ?? 'Specialist',
      scheduledAt: DateTime.tryParse(json['scheduledAt'] as String? ?? '') ?? DateTime.now(),
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int? ?? 30,
      status: json['status'] as String? ?? 'SCHEDULED',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class MedicationReminder {
  final String id;
  final String name;
  final String dosage;
  final String instructions;
  final String frequency;
  final List<String> timeOfDay;
  final DateTime startDate;
  final DateTime? endDate;

  const MedicationReminder({
    required this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.frequency,
    required this.timeOfDay,
    required this.startDate,
    this.endDate,
  });

  factory MedicationReminder.fromJson(Map<String, dynamic> json) {
    final rawTimes = json['timeOfDay'] as List<dynamic>? ?? [];
    return MedicationReminder(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      frequency: json['frequency'] as String? ?? 'ONCE_DAILY',
      timeOfDay: rawTimes.map((e) => e.toString()).toList(),
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
    );
  }
}

class EducationalRecommendation {
  final String id;
  final String slug;
  final String titleAr;
  final String titleEn;
  final String summaryAr;
  final String summaryEn;
  final String categoryNameAr;
  final String categoryNameEn;
  final int readTimeMinutes;

  const EducationalRecommendation({
    required this.id,
    required this.slug,
    required this.titleAr,
    required this.titleEn,
    required this.summaryAr,
    required this.summaryEn,
    required this.categoryNameAr,
    required this.categoryNameEn,
    required this.readTimeMinutes,
  });

  factory EducationalRecommendation.fromJson(Map<String, dynamic> json) {
    return EducationalRecommendation(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      titleAr: json['titleAr'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      summaryAr: json['summaryAr'] as String? ?? '',
      summaryEn: json['summaryEn'] as String? ?? '',
      categoryNameAr: json['categoryNameAr'] as String? ?? '',
      categoryNameEn: json['categoryNameEn'] as String? ?? '',
      readTimeMinutes: json['readTimeMinutes'] as int? ?? 5,
    );
  }
}

class AssignedDoctorSummary {
  final String doctorId;
  final String doctorName;
  final String specialization;
  final String hospitalAffiliation;
  final String clinicAddress;

  const AssignedDoctorSummary({
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.hospitalAffiliation,
    required this.clinicAddress,
  });

  factory AssignedDoctorSummary.fromJson(Map<String, dynamic> json) {
    return AssignedDoctorSummary(
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      hospitalAffiliation: json['hospitalAffiliation'] as String? ?? '',
      clinicAddress: json['clinicAddress'] as String? ?? '',
    );
  }
}

class PatientDashboardData {
  final PatientProfileSummary profile;
  final List<UpcomingAppointment> upcomingAppointments;
  final List<MedicationReminder> activeMedications;
  final List<EducationalRecommendation> recommendedArticles;
  final List<AssignedDoctorSummary> careTeam;

  const PatientDashboardData({
    required this.profile,
    required this.upcomingAppointments,
    required this.activeMedications,
    required this.recommendedArticles,
    required this.careTeam,
  });

  factory PatientDashboardData.fromJson(Map<String, dynamic> json) {
    final rawAppts = json['upcomingAppointments'] as List<dynamic>? ?? [];
    final rawMeds = json['activeMedications'] as List<dynamic>? ?? [];
    final rawArticles = json['recommendedArticles'] as List<dynamic>? ?? [];
    final rawCare = json['careTeam'] as List<dynamic>? ?? [];

    return PatientDashboardData(
      profile: PatientProfileSummary.fromJson(
        json['profile'] as Map<String, dynamic>? ?? {},
      ),
      upcomingAppointments: rawAppts
          .map((a) => UpcomingAppointment.fromJson(a as Map<String, dynamic>))
          .toList(),
      activeMedications: rawMeds
          .map((m) => MedicationReminder.fromJson(m as Map<String, dynamic>))
          .toList(),
      recommendedArticles: rawArticles
          .map((art) => EducationalRecommendation.fromJson(art as Map<String, dynamic>))
          .toList(),
      careTeam: rawCare
          .map((c) => AssignedDoctorSummary.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
