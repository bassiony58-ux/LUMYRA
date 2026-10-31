class QuestionOption {
  final String value;
  final String labelAr;
  final String labelEn;
  final String? subtitleAr;
  final String? subtitleEn;

  const QuestionOption({
    required this.value,
    required this.labelAr,
    required this.labelEn,
    this.subtitleAr,
    this.subtitleEn,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      value: json['value']?.toString() ?? '',
      labelAr: json['labelAr'] as String? ?? json['label'] as String? ?? json['value']?.toString() ?? '',
      labelEn: json['labelEn'] as String? ?? json['label'] as String? ?? json['value']?.toString() ?? '',
      subtitleAr: json['subtitleAr'] as String? ?? json['descriptionAr'] as String?,
      subtitleEn: json['subtitleEn'] as String? ?? json['descriptionEn'] as String?,
    );
  }
}

class QuestionItem {
  final String id;
  final String titleAr;
  final String titleEn;
  final String? helpTextAr;
  final String? helpTextEn;
  final String type; // 'SINGLE_SELECT', 'MULTI_SELECT', 'TEXT', 'number'
  final bool isRequired;
  final List<QuestionOption> options;
  final String? dependsOn;
  final dynamic dependsOnValue;

  const QuestionItem({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    this.helpTextAr,
    this.helpTextEn,
    required this.type,
    this.isRequired = true,
    required this.options,
    this.dependsOn,
    this.dependsOnValue,
  });

  factory QuestionItem.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>?)
            ?.map((o) => QuestionOption.fromJson(o as Map<String, dynamic>))
            .toList() ??
        [];

    final labelAr = json['labelAr'] as String?;
    final labelEn = json['labelEn'] as String?;
    final titleAr = json['titleAr'] as String? ?? labelAr ?? '';
    final titleEn = json['titleEn'] as String? ?? labelEn ?? '';

    final descAr = json['descriptionAr'] as String?;
    final descEn = json['descriptionEn'] as String?;
    final helpTextAr = json['helpTextAr'] as String? ?? descAr;
    final helpTextEn = json['helpTextEn'] as String? ?? descEn;

    final isReq = json['isRequired'] as bool? ?? json['required'] as bool? ?? true;

    return QuestionItem(
      id: json['id'] as String,
      titleAr: titleAr,
      titleEn: titleEn,
      helpTextAr: helpTextAr,
      helpTextEn: helpTextEn,
      type: json['type'] as String? ?? 'SINGLE_SELECT',
      isRequired: isReq,
      options: opts,
      dependsOn: (json['dependsOn'] ?? json['conditionalOn']?['questionId']) as String?,
      dependsOnValue: json['dependsOnValue'] ?? json['conditionalOn']?['value'],
    );
  }
}

class QuestionSection {
  final String id;
  final int stepIndex;
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final List<QuestionItem> questions;

  const QuestionSection({
    required this.id,
    required this.stepIndex,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.questions,
  });

  factory QuestionSection.fromJson(Map<String, dynamic> json) {
    final qList = (json['questions'] as List<dynamic>?)
            ?.map((q) => QuestionItem.fromJson(q as Map<String, dynamic>))
            .toList() ??
        [];

    return QuestionSection(
      id: json['id'] as String,
      stepIndex: json['stepIndex'] as int? ?? 0,
      titleAr: json['titleAr'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      descriptionAr: json['descriptionAr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      questions: qList,
    );
  }
}

class QuestionnaireDefinition {
  final String version;
  final String lastUpdated;
  final String disclaimerAr;
  final String disclaimerEn;
  final List<QuestionSection> sections;

  const QuestionnaireDefinition({
    required this.version,
    required this.lastUpdated,
    required this.disclaimerAr,
    required this.disclaimerEn,
    required this.sections,
  });

  factory QuestionnaireDefinition.fromJson(Map<String, dynamic> json) {
    final sList = (json['sections'] as List<dynamic>?)
            ?.map((s) => QuestionSection.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    return QuestionnaireDefinition(
      version: json['version'] as String? ?? '1.1.0-guided',
      lastUpdated: json['lastUpdated'] as String? ?? '',
      disclaimerAr: json['disclaimerAr'] as String? ?? '',
      disclaimerEn: json['disclaimerEn'] as String? ?? '',
      sections: sList,
    );
  }
}

class QuestionnaireSubmissionResult {
  final String requestId;
  final String status;
  final Map<String, dynamic> answers;
  final List<String> guidanceRecommendations;
  final String clinicalReviewNotice;
  final bool isDemonstrationData;
  final String? qualitativeRiskCategory;
  final String? summaryNotice;
  final String? fiveYearPerspective;
  final String? lifetimePerspective;
  final Map<String, dynamic>? geminiAnalysis;

  const QuestionnaireSubmissionResult({
    required this.requestId,
    required this.status,
    required this.answers,
    required this.guidanceRecommendations,
    required this.clinicalReviewNotice,
    required this.isDemonstrationData,
    this.qualitativeRiskCategory,
    this.summaryNotice,
    this.fiveYearPerspective,
    this.lifetimePerspective,
    this.geminiAnalysis,
  });

  factory QuestionnaireSubmissionResult.fromJson(Map<String, dynamic> json) {
    final req = json['request'] as Map<String, dynamic>? ?? json;
    final res = json['result'] as Map<String, dynamic>? ?? json;

    final recs = (res['guidanceRecommendations'] as List<dynamic>?)
            ?.map((r) => r.toString())
            .toList() ??
        [];

    final answers = (req['answersPayload'] as Map<String, dynamic>?)?['answers'] as Map<String, dynamic>? ??
        (json['answers'] as Map<String, dynamic>?) ??
        {};

    final payload = (res['resultsPayload'] is Map)
        ? Map<String, dynamic>.from(res['resultsPayload'])
        : <String, dynamic>{};

    final gemini = payload['geminiRiskAnalysis'] is Map
        ? Map<String, dynamic>.from(payload['geminiRiskAnalysis'])
        : null;

    return QuestionnaireSubmissionResult(
      requestId: req['id'] as String? ?? 'sub-01',
      status: req['status'] as String? ?? 'SUBMITTED',
      answers: answers,
      guidanceRecommendations: recs,
      clinicalReviewNotice: res['clinicalReviewNotice'] as String? ??
          'CLINICAL NOTICE: This report organizes patient-reported history for discussion with a doctor.',
      isDemonstrationData: res['isDemonstrationData'] as bool? ?? false,
      qualitativeRiskCategory: (res['qualitativeRiskCategory'] ?? payload['qualitativeRiskCategory'])?.toString(),
      summaryNotice: (payload['summaryNotice'] ?? gemini?['clinicalSummaryAr'])?.toString(),
      fiveYearPerspective: (payload['fiveYearPerspective'] ?? (gemini != null ? '${gemini['estimated5YearRiskPercent']}%' : null))?.toString(),
      lifetimePerspective: (payload['lifetimePerspective'] ?? (gemini != null ? '${gemini['estimatedLifetimeRiskPercent']}%' : null))?.toString(),
      geminiAnalysis: gemini,
    );
  }
}
