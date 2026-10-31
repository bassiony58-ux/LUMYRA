import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/questionnaire_repository.dart';
import '../../domain/models/questionnaire_models.dart';

class QuestionnaireState {
  final AsyncValue<QuestionnaireDefinition> definition;
  final int currentStep; // 0..3: Sections, 4: Review, 5: Results
  final Map<String, dynamic> answers;
  final Map<String, String> validationErrors;
  final bool isSavingDraft;
  final bool isSubmitting;
  final bool consentAcknowledged;
  final QuestionnaireSubmissionResult? submissionResult;
  final String? activeDraftId;
  final String? correctedFromId;
  final String? statusMessage;

  const QuestionnaireState({
    required this.definition,
    this.currentStep = 0,
    this.answers = const {},
    this.validationErrors = const {},
    this.isSavingDraft = false,
    this.isSubmitting = false,
    this.consentAcknowledged = false,
    this.submissionResult,
    this.activeDraftId,
    this.correctedFromId,
    this.statusMessage,
  });

  QuestionnaireState copyWith({
    AsyncValue<QuestionnaireDefinition>? definition,
    int? currentStep,
    Map<String, dynamic>? answers,
    Map<String, String>? validationErrors,
    bool? isSavingDraft,
    bool? isSubmitting,
    bool? consentAcknowledged,
    QuestionnaireSubmissionResult? submissionResult,
    String? activeDraftId,
    String? correctedFromId,
    String? statusMessage,
    bool clearStatusMessage = false,
    bool clearSubmissionResult = false,
  }) {
    return QuestionnaireState(
      definition: definition ?? this.definition,
      currentStep: currentStep ?? this.currentStep,
      answers: answers ?? this.answers,
      validationErrors: validationErrors ?? this.validationErrors,
      isSavingDraft: isSavingDraft ?? this.isSavingDraft,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      consentAcknowledged: consentAcknowledged ?? this.consentAcknowledged,
      submissionResult: clearSubmissionResult ? null : (submissionResult ?? this.submissionResult),
      activeDraftId: activeDraftId ?? this.activeDraftId,
      correctedFromId: correctedFromId ?? this.correctedFromId,
      statusMessage: clearStatusMessage ? null : (statusMessage ?? this.statusMessage),
    );
  }
}

class QuestionnaireNotifier extends Notifier<QuestionnaireState> {
  @override
  QuestionnaireState build() {
    // Schedule async init after initial build
    Future.microtask(() => init());
    return const QuestionnaireState(definition: AsyncLoading());
  }

  QuestionnaireRepository get _repository => ref.read(questionnaireRepositoryProvider);

  Future<void> init() async {
    try {
      final def = await _repository.getDefinition();
      state = state.copyWith(definition: AsyncData(def));

      try {
        // Check if there is an existing draft to resume
        final draft = await _repository.getMyDraft();
        if (draft != null && draft['answers'] != null) {
          final draftAnswers = Map<String, dynamic>.from(draft['answers'] as Map);
          final step = (draft['currentStep'] as int? ?? 0).clamp(0, 4);
          state = state.copyWith(
            answers: draftAnswers,
            currentStep: step,
            activeDraftId: draft['id'] as String?,
            statusMessage: 'تم استرجاع مسودة الاستبيان السابقة تلقائياً (Resumed draft).',
          );
        }
      } catch (_) {
        // Non-fatal if draft check fails offline
      }
    } catch (_) {
      // Safe offline fallback: never block user with an error screen
      state = state.copyWith(
        definition: AsyncData(QuestionnaireRepository.fallbackDefinition),
      );
    }
  }

  void setAnswer(String questionId, dynamic value) {
    final updated = Map<String, dynamic>.from(state.answers);
    updated[questionId] = value;

    // Handle conditional clearing
    if (questionId == 'hasGivenBirth' && value == 'no') {
      updated.remove('ageAtFirstLiveBirth');
    }
    if (questionId == 'firstDegreeBreastCancer' && value == 'no') {
      updated.remove('diagnosedBeforeAge50');
    }

    final newErrors = Map<String, String>.from(state.validationErrors);
    newErrors.remove(questionId);

    state = state.copyWith(
      answers: updated,
      validationErrors: newErrors,
      clearStatusMessage: true,
    );
  }

  void toggleConsent(bool value) {
    state = state.copyWith(consentAcknowledged: value);
  }

  bool validateCurrentStep() {
    final def = state.definition.asData?.value;
    if (def == null || state.currentStep >= def.sections.length) {
      return true;
    }

    final section = def.sections[state.currentStep];
    final errors = <String, String>{};

    for (final question in section.questions) {
      // Check dependency
      if (question.dependsOn != null) {
        final parentVal = state.answers[question.dependsOn];
        if (parentVal != question.dependsOnValue) {
          continue; // Question is inactive
        }
      }

      if (question.isRequired) {
        final val = state.answers[question.id];
        if (val == null || (val is String && val.trim().isEmpty)) {
          errors[question.id] = 'يرجى الإجابة على هذا السؤال للمتابعة (Please answer this question)';
        }
      }
    }

    state = state.copyWith(validationErrors: errors);
    return errors.isEmpty;
  }

  void nextStep() {
    final def = state.definition.asData?.value;
    final totalSteps = (def?.sections.length ?? 4);
    if (validateCurrentStep()) {
      if (state.currentStep < totalSteps) {
        state = state.copyWith(
          currentStep: state.currentStep + 1,
          validationErrors: {},
          clearStatusMessage: true,
        );
      }
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        validationErrors: {},
        clearStatusMessage: true,
      );
    }
  }

  void jumpToStep(int step) {
    final def = state.definition.asData?.value;
    final maxStep = (def?.sections.length ?? 4);
    if (step >= 0 && step <= maxStep) {
      state = state.copyWith(
        currentStep: step,
        validationErrors: {},
        clearStatusMessage: true,
      );
    }
  }

  Future<void> saveDraft() async {
    state = state.copyWith(isSavingDraft: true, clearStatusMessage: true);
    try {
      final res = await _repository.saveDraft(
        currentStep: state.currentStep,
        answers: state.answers,
      );
      state = state.copyWith(
        isSavingDraft: false,
        activeDraftId: res['id'] as String?,
        statusMessage: 'تم حفظ التقدم بنجاح كمسودة (Progress saved).',
      );
    } catch (e) {
      state = state.copyWith(
        isSavingDraft: false,
        statusMessage: 'فشل حفظ المسودة، تحقق من الاتصال (Failed to save draft).',
      );
    }
  }

  Future<void> submit() async {
    if (!state.consentAcknowledged) {
      state = state.copyWith(
        statusMessage: 'يرجى تأكيد الاطلاع والموافقة على إشعار الخصوصية والحدود الطبية أولاً.',
      );
      return;
    }

    state = state.copyWith(isSubmitting: true, clearStatusMessage: true);
    try {
      QuestionnaireSubmissionResult res;
      if (state.correctedFromId != null) {
        res = await _repository.correct(
          previousRequestId: state.correctedFromId!,
          correctionReason: 'Patient correction from review interface',
          answers: state.answers,
          consentAcknowledged: true,
        );
      } else {
        res = await _repository.submit(
          answers: state.answers,
          consentAcknowledged: true,
        );
      }

      state = state.copyWith(
        isSubmitting: false,
        currentStep: 5, // Move to Results Screen
        submissionResult: res,
        statusMessage: 'تم إرسال الإجابات بنجاح وتنظيم ملخص التاريخ الصحي.',
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        statusMessage: 'حدث خطأ أثناء الإرسال: $e',
      );
    }
  }

  void startCorrection() {
    if (state.submissionResult != null) {
      state = state.copyWith(
        currentStep: 0,
        correctedFromId: state.submissionResult!.requestId,
        clearSubmissionResult: true,
        consentAcknowledged: false,
        statusMessage: 'وضع تصحيح الإجابات: يمكنك تعديل أي إجابة ثم إعادة الإرسال لتوثيق النسخة المحدثة.',
      );
    }
  }

  void reset() {
    state = state.copyWith(
      currentStep: 0,
      answers: {},
      validationErrors: {},
      clearSubmissionResult: true,
      consentAcknowledged: false,
      correctedFromId: null,
      clearStatusMessage: true,
    );
  }
}

final questionnaireNotifierProvider =
    NotifierProvider<QuestionnaireNotifier, QuestionnaireState>(() => QuestionnaireNotifier());
