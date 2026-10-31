import 'dart:async';
import 'package:flutter/material.dart';
import '../network/api_client.dart';
import '../network/api_exceptions.dart';

enum ScanFinding {
  normal,
  benign,
  malignant,
  inconclusive,
}

class RecommendedFacility {
  final String name;
  final String category;
  final String location;
  final String phone;
  final String hotline;

  const RecommendedFacility({
    required this.name,
    required this.category,
    required this.location,
    required this.phone,
    required this.hotline,
  });
}

class PatientScanAdvice {
  final String headline;
  final String message;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool requiresUrgentDoctorVisit;
  final List<RecommendedFacility> recommendedFacilities;

  const PatientScanAdvice({
    required this.headline,
    required this.message,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.requiresUrgentDoctorVisit,
    required this.recommendedFacilities,
  });
}

class DoctorScanDetails {
  final String clinicalDiagnosis;
  final String biRadsClass;
  final double confidencePercent;
  final String pathologyNotes;
  final List<String> clinicalActions;

  String get formattedConfidence {
    final val = confidencePercent <= 1.0 ? confidencePercent * 100 : confidencePercent;
    return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}%';
  }

  const DoctorScanDetails({
    required this.clinicalDiagnosis,
    required this.biRadsClass,
    required this.confidencePercent,
    required this.pathologyNotes,
    required this.clinicalActions,
  });
}

class ScanAnalysisResult {
  final String scanId;
  final String fileName;
  final DateTime analyzedAt;
  final ScanFinding finding;
  final double rawConfidence;
  final PatientScanAdvice patientAdvice;
  final DoctorScanDetails doctorDetails;
  final Map<String, double>? probabilities;
  final Map<String, dynamic>? modelDetails;

  const ScanAnalysisResult({
    required this.scanId,
    required this.fileName,
    required this.analyzedAt,
    required this.finding,
    required this.rawConfidence,
    required this.patientAdvice,
    required this.doctorDetails,
    this.probabilities,
    this.modelDetails,
  });
}

class UltrasoundAnalyzerService {
  static const List<RecommendedFacility> verifiedEmergencyFacilities = [
    RecommendedFacility(
      name: 'مؤسسة بهية للاكتشاف المبكر وعلاج سرطان الثدي',
      category: 'مركز رائد مجاني معتمد',
      location: 'فرع الشيخ زايد / فرع الهرم، الجيزة',
      phone: '0235831900',
      hotline: '16602',
    ),
    RecommendedFacility(
      name: 'المعهد القومي للأورام - جامعة القاهرة',
      category: 'مركز أكاديمي واستشاري حكومي',
      location: 'شارع القصر العيني، فم الخليج، القاهرة',
      phone: '0223654400',
      hotline: '16198',
    ),
    RecommendedFacility(
      name: 'عيادة د. نور الخالدي (استشاري جراحة أورام الثدي)',
      category: 'استشاري معتمد في شبكة لوميرا',
      location: 'عيادات الصفا التخصصية، المهندسين',
      phone: '01099887766',
      hotline: '16870',
    ),
  ];

  static ScanAnalysisResult fromBackendJson(Map<String, dynamic> json, String fileName) {
    final now = DateTime.now();
    final findingStr = (json['finding'] as String?)?.toLowerCase() ?? 'benign';
    ScanFinding finding = ScanFinding.benign;
    if (findingStr == 'malignant') {
      finding = ScanFinding.malignant;
    } else if (findingStr == 'normal') {
      finding = ScanFinding.normal;
    } else if (findingStr == 'inconclusive') {
      finding = ScanFinding.inconclusive;
    }

    final rawConfidence = (json['confidencePercent'] as num?)?.toDouble() ?? 0.0;
    final double confidence = rawConfidence <= 1.0 ? (rawConfidence * 100) : rawConfidence;
    final confFormatted = '${confidence.toStringAsFixed(confidence.truncateToDouble() == confidence ? 0 : 1)}%';

    // Facilities
    final facilitiesList = <RecommendedFacility>[];
    if (json['recommendedFacilities'] is List) {
      for (final f in json['recommendedFacilities']) {
        facilitiesList.add(RecommendedFacility(
          name: f['name'] ?? '',
          category: f['category'] ?? '',
          location: f['location'] ?? '',
          phone: f['phone'] ?? '',
          hotline: f['hotline'] ?? '',
        ));
      }
    }
    if (facilitiesList.isEmpty) {
      facilitiesList.addAll(verifiedEmergencyFacilities);
    }

    // Patient Advice
    final headline = json['headline'] ??
        (finding == ScanFinding.malignant
            ? 'توجيه طبي عاجل • يوصى باستشارة سريرية فورية 🌸'
            : finding == ScanFinding.inconclusive
                ? 'الصورة المرفوعة ليست فحصاً طبياً معتمداً 🌸'
                : 'نتيجة مطمئنة • تغيرات حميدة مستقرة 🌸');
    final message = json['message'] ?? '';
    final badgeText = json['badgeText'] ??
        (finding == ScanFinding.malignant
            ? 'استشارة سريرية مطلوبة'
            : finding == ScanFinding.inconclusive
                ? 'صورة غير طبية / غير مدعومة'
                : 'تغيرات حميدة مطمئنة');
    final requiresUrgent = json['requiresUrgentDoctorVisit'] == true;

    // Patient Advice: Neutral clinical colors - NO misleading green 'guarantee'
    Color badgeColor = const Color(0xFFE8EEF5);
    Color badgeTextColor = const Color(0xFF1B4965);
    if (requiresUrgent || finding == ScanFinding.malignant) {
      badgeColor = const Color(0xFFFFDAD6);
      badgeTextColor = const Color(0xFFBA1A1A);
    } else if (finding == ScanFinding.inconclusive) {
      badgeColor = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFF92400E);
    }

    final patientAdvice = PatientScanAdvice(
      headline: headline,
      message: message,
      badgeText: badgeText,
      badgeColor: badgeColor,
      badgeTextColor: badgeTextColor,
      requiresUrgentDoctorVisit: requiresUrgent,
      recommendedFacilities: facilitiesList,
    );

    // Doctor Details
    final doctorDetails = DoctorScanDetails(
      clinicalDiagnosis: json['clinicalDiagnosis'] ?? 'تصنيف النموذج: ${findingStr.toUpperCase()}',
      biRadsClass: json['biRadsClass'] ?? 'يتطلب تقييم شعاعي سريري مستقل',
      confidencePercent: confidence,
      pathologyNotes: json['pathologyNotes'] ?? 'احتمالية النموذج: $confFormatted',
      clinicalActions: (json['clinicalActions'] is List)
          ? List<String>.from(json['clinicalActions'])
          : ['مراجعة الصورة شعاعياً ومطابقتها سريرياً'],
    );

    Map<String, double>? probs;
    if (json['probabilities'] is Map) {
      probs = {};
      json['probabilities'].forEach((k, v) {
        if (v is num) probs![k.toString()] = v.toDouble();
      });
    }

    return ScanAnalysisResult(
      scanId: 'SCN-${now.millisecondsSinceEpoch.toString().substring(7)}',
      fileName: fileName,
      analyzedAt: now,
      finding: finding,
      rawConfidence: confidence,
      patientAdvice: patientAdvice,
      doctorDetails: doctorDetails,
      probabilities: probs,
      modelDetails: json['modelDetails'] is Map ? Map<String, dynamic>.from(json['modelDetails']) : null,
    );
  }

  static Future<ScanAnalysisResult> analyzeScan({
    required String fileName,
    required List<int> fileBytes,
    bool isDoctor = false,
    String? token,
  }) async {
    final client = ApiClient(
      tokenProvider: () => token ?? 'mock-patient-uid:patient@lumyra.test:PATIENT',
    );

    final response = await client.postMultipart(
      '/scans/analyze',
      fileBytes: fileBytes,
      fileName: fileName,
      fields: {'role': isDoctor ? 'DOCTOR' : 'PATIENT'},
    );

    if (response is Map<String, dynamic>) {
      return fromBackendJson(response, fileName);
    }

    throw const ApiException(message: 'استجابة غير متوقعة من خادم التحليل الطبي');
  }
}
