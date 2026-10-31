import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumyra/features/questionnaire/data/questionnaire_repository.dart';
import 'package:lumyra/features/questionnaire/domain/models/questionnaire_models.dart';
import 'package:lumyra/features/questionnaire/presentation/questionnaire_screen.dart';

class MockQuestionnaireRepository implements QuestionnaireRepository {
  bool draftSaved = false;
  bool submitted = false;

  @override
  Future<QuestionnaireDefinition> getDefinition() async {
    return const QuestionnaireDefinition(
      version: '1.1.0-guided',
      lastUpdated: '2026-10-25',
      disclaimerAr: 'إشعار سريري: هذا الاستبيان أداة لجمع وتوثيق التاريخ الصحي لمناقشته مع الطبيب.',
      disclaimerEn: 'Clinical Disclaimer: This guided questionnaire is an informational intake tool. It does NOT calculate statistical cancer probabilities or assert clinical risk tiers.',
      sections: [
        QuestionSection(
          id: 'demographics',
          stepIndex: 0,
          titleAr: 'المعلومات العامة والديموغرافية',
          titleEn: 'General & Demographic Information',
          descriptionAr: 'معلومات عامة حول الفئة العمرية.',
          descriptionEn: 'General information regarding age.',
          questions: [
            QuestionItem(
              id: 'currentAge',
              titleAr: 'ما هي فئتك العمرية الحالية؟',
              titleEn: 'What is your current age category?',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'under_40', labelAr: 'أقل من ٤٠ سنة', labelEn: 'Under 40'),
                QuestionOption(value: '40_49', labelAr: '٤٠ - ٤٩ سنة', labelEn: '40 - 49 years'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<Map<String, dynamic>?> getMyDraft() async {
    return null;
  }

  @override
  Future<Map<String, dynamic>> saveDraft({
    required int currentStep,
    required Map<String, dynamic> answers,
  }) async {
    draftSaved = true;
    return {'id': 'mock-draft-123', 'status': 'DRAFT'};
  }

  @override
  Future<QuestionnaireSubmissionResult> submit({
    required Map<String, dynamic> answers,
    required bool consentAcknowledged,
    String? notes,
  }) async {
    submitted = true;
    return QuestionnaireSubmissionResult(
      requestId: 'req-sub-999',
      status: 'SUBMITTED',
      answers: answers,
      guidanceRecommendations: [
        'Discuss screening mammography schedule with your clinician.',
      ],
      clinicalReviewNotice: 'CLINICAL NOTICE: This report organizes patient-reported history. No mathematical models or risk scores calculated.',
      isDemonstrationData: true,
    );
  }

  @override
  Future<QuestionnaireSubmissionResult> correct({
    required String previousRequestId,
    required String correctionReason,
    required Map<String, dynamic> answers,
    required bool consentAcknowledged,
  }) async {
    return QuestionnaireSubmissionResult(
      requestId: 'req-corrected-888',
      status: 'SUBMITTED',
      answers: answers,
      guidanceRecommendations: ['Corrected recommendation'],
      clinicalReviewNotice: 'CLINICAL NOTICE: Corrected record without risk scores.',
      isDemonstrationData: true,
    );
  }
}

void main() {
  testWidgets('QuestionnaireScreen renders definition, validates answers, and submits without clinical risk scores',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = MockQuestionnaireRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionnaireRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: QuestionnaireScreen(),
        ),
      ),
    );

    // Let the async definition load
    await tester.pumpAndSettle();

    // Verify Disclaimer and Step 1 Questions are rendered
    expect(find.textContaining('Documentary Intake Notice'), findsOneWidget);
    expect(find.text('General & Demographic Information'), findsNWidgets(2));
    expect(find.text('What is your current age category?'), findsOneWidget);
    expect(find.text('40 - 49 years'), findsOneWidget);

    // Tap "Continue" without answering to verify validation error appears
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Please answer this question'), findsOneWidget);

    // Select age option
    await tester.tap(find.text('40 - 49 years'));
    await tester.pumpAndSettle();

    // Tap Save Draft
    await tester.tap(find.text('Save Draft'));
    await tester.pumpAndSettle();
    expect(mockRepo.draftSaved, isTrue);

    // Continue to Review Step
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify Review step is displayed
    expect(find.text('Review Answers Before Submission'), findsOneWidget);
    expect(find.text('40 - 49 years'), findsOneWidget);

    // Acknowledge consent checkbox
    final checkbox = find.byType(Checkbox);
    expect(checkbox, findsOneWidget);
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    // Tap Submit
    await tester.tap(find.text('Submit & Organize'));
    await tester.pumpAndSettle();
    expect(mockRepo.submitted, isTrue);

    // Verify Results Screen renders talking points and SaMD disclaimer
    expect(find.text('Breast Health History Documented'), findsOneWidget);
    expect(find.textContaining('req-sub-999'), findsOneWidget);
    expect(find.text('Clinical & Ethical Boundaries'), findsOneWidget);
    expect(find.textContaining('No mathematical models or risk scores calculated'), findsOneWidget);
    expect(find.textContaining('Discuss screening mammography schedule with your clinician.'), findsOneWidget);

    // STRICT SaMD VERIFICATION: No numerical percentage risk, BI-RADS, or high-risk claims
    expect(find.textContaining('% risk'), findsNothing);
    expect(find.textContaining('BI-RADS'), findsNothing);
    expect(find.textContaining('High Risk Tier'), findsNothing);
  });
}
