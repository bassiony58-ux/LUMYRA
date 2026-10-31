import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumyra/core/services/ultrasound_analyzer_service.dart';

void main() {
  group('UltrasoundAnalyzerService Integration Tests', () {
    test('Correctly maps real benign backend output with neutral clinical colors and full facilities', () {
      final backendJson = {
        'role': 'PATIENT',
        'status': 'REASSURING',
        'finding': 'benign',
        'confidencePercent': 75.4,
        'probabilities': {
          'benign': 0.75404,
          'malignant': 0.22557,
          'normal': 0.02039,
        },
        'requiresUrgentDoctorVisit': false,
        'headline': 'مؤشرات نمطية تتوافق مع التغيرات الحميدة الشائعة 🌸',
        'badgeText': 'نمط نسيجي حميد (استرشادي)',
        'message': 'أظهر التحليل الآلي المبدئي مؤشرات نسيجية تتوافق مع التغيرات الحميدة الشائعة.',
        'disclaimer': 'تنويه طبي: هذه القراءة استرشادية مبنية على الذكاء الاصطناعي للمساعدة في الفحص المبدئي.',
      };

      final result = UltrasoundAnalyzerService.fromBackendJson(backendJson, 'test_scan.png');

      expect(result.finding, ScanFinding.benign);
      expect(result.rawConfidence, 75.4);
      expect(result.patientAdvice.requiresUrgentDoctorVisit, false);
      expect(result.patientAdvice.headline, contains('حميدة'));
      expect(result.patientAdvice.badgeColor, const Color(0xFFE8EEF5)); // Neutral clinical slate, NOT green!
      expect(result.patientAdvice.recommendedFacilities, isNotEmpty);
      expect(result.probabilities?['benign'], closeTo(0.754, 0.001));
    });

    test('Correctly maps real malignant backend output with urgent clinical triage', () {
      final backendJson = {
        'role': 'PATIENT',
        'status': 'ACTION_REQUIRED',
        'finding': 'malignant',
        'confidencePercent': 92.4,
        'probabilities': {
          'benign': 0.05,
          'malignant': 0.924,
          'normal': 0.026,
        },
        'requiresUrgentDoctorVisit': true,
        'headline': 'توجيه سريري عاجل • يوصى باستشارة طبية فورية 🌸',
        'badgeText': 'أولوية تواصل عاجلة',
        'message': 'توضح قراءة الفحص وجود تغيرات نسيجية غير نمطية تستلزم فحصاً سريرياً دقيقاً.',
      };

      final result = UltrasoundAnalyzerService.fromBackendJson(backendJson, 'test_malignant.png');

      expect(result.finding, ScanFinding.malignant);
      expect(result.rawConfidence, 92.4);
      expect(result.patientAdvice.requiresUrgentDoctorVisit, true);
      expect(result.patientAdvice.badgeColor, const Color(0xFFFFDAD6)); // Urgent alert color
      expect(result.patientAdvice.headline, contains('عاجل'));
      expect(result.patientAdvice.recommendedFacilities, isNotEmpty);
    });

    test('Correctly maps real normal backend output without false absolute guarantee', () {
      final backendJson = {
        'role': 'PATIENT',
        'status': 'CLEAR',
        'finding': 'normal',
        'confidencePercent': 98.2,
        'probabilities': {
          'benign': 0.01,
          'malignant': 0.008,
          'normal': 0.982,
        },
        'requiresUrgentDoctorVisit': false,
        'headline': 'نمط نسيجي متوافق مع الفحوصات الطبيعية مبدئياً 🌸',
        'badgeText': 'نمط طبيعي (استرشادي)',
        'message': 'أظهر التحليل المبدئي نمطاً نسيجياً يتوافق مع الأنسجة الطبيعية.',
      };

      final result = UltrasoundAnalyzerService.fromBackendJson(backendJson, 'test_normal.png');

      expect(result.finding, ScanFinding.normal);
      expect(result.rawConfidence, 98.2);
      expect(result.patientAdvice.requiresUrgentDoctorVisit, false);
      expect(result.patientAdvice.badgeColor, const Color(0xFFE8EEF5)); // Neutral clinical slate, NOT green!
      expect(result.patientAdvice.recommendedFacilities, isNotEmpty);
    });
  });
}
