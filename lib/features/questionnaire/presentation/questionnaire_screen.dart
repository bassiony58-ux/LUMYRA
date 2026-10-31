import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/models/questionnaire_models.dart';
import 'providers/questionnaire_provider.dart';

class QuestionnaireScreen extends ConsumerWidget {
  final bool isGuest;

  const QuestionnaireScreen({
    super.key,
    this.isGuest = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionnaireNotifierProvider);
    final isAr = context.isArabic;

    final Widget content = state.definition.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                isAr ? 'تعذر تحميل استبيان صحة الثدي' : 'Failed to load breast health questionnaire',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
              ),
              const SizedBox(height: 20),
              PillButton(
                label: isAr ? 'إعادة المحاولة' : 'Retry',
                onPressed: () => ref.read(questionnaireNotifierProvider.notifier).init(),
              ),
            ],
          ),
        ),
      ),
      data: (definition) {
        if (state.currentStep == 5 && state.submissionResult != null) {
          return _QuestionnaireResultsView(
            result: state.submissionResult!,
            isGuest: isGuest,
          );
        }

        return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Educational & SaMD Guardrail Notice
                    _buildClinicalNoticeBanner(context, definition, isAr),
                    const SizedBox(height: 16),

                    // Status Message / Toast if any
                    if (state.statusMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.statusMessage!,
                                style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Multi-Step Progress Indicator
                    _buildStepperHeader(context, ref, state, definition, isAr),
                    const SizedBox(height: 24),

                    // Step Content Card
                    if (state.currentStep < definition.sections.length) ...[
                      _buildSectionQuestionsCard(context, ref, state, definition, isAr),
                    ] else ...[
                      _buildReviewCard(context, ref, state, definition, isAr),
                    ],

                    const SizedBox(height: 24),

                    // Bottom Navigation Buttons
                    _buildActionButtons(context, ref, state, definition, isAr),
                  ],
                ),
              ),
            ),
          );
        },
      );

    if (isGuest) {
      return Scaffold(
        backgroundColor: AppColors.powderBackground,
        appBar: AppBar(
          backgroundColor: AppColors.powderBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
            onPressed: () => context.go('/'),
          ),
          title: Text(
            isAr ? 'اطمن على نفسك 🌸' : 'Quick Health Check 🌸',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary),
          ),
          actions: [
            IconButton(
              onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
              icon: const Icon(Icons.language_rounded, color: AppColors.primary),
              tooltip: isAr ? 'English' : 'العربية',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(child: content),
      );
    }

    return AdaptiveScaffold(
      selectedIndex: 1,
      titleKey: 'navRisk',
      body: content,
    );
  }

  Widget _buildClinicalNoticeBanner(BuildContext context, QuestionnaireDefinition def, bool isAr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.powderBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softDustyBlush, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.whiteSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: AppColors.primaryAction, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr
                          ? 'التقييم الصحي الدوري لصحة الثدي 🌸 (إشعار توثيقي واستشاري)'
                          : 'Periodic Breast Health Assessment (Documentary Intake Notice)',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                    ),
                    Text(
                      isAr
                          ? 'يتجدد الاستبيان تلقائياً كل 30 يوماً لتحديث سجلكِ الصحي والمتابعة المستمرة'
                          : 'Renews automatically every 30 days for proactive wellness tracking',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAr ? 'دوري • ٣٠ يوماً' : '30-Day Cycle',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.softDustyBlush),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user_outlined, color: AppColors.secondaryText, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr ? def.disclaimerAr : def.disclaimerEn,
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperHeader(
    BuildContext context,
    WidgetRef ref,
    QuestionnaireState state,
    QuestionnaireDefinition def,
    bool isAr,
  ) {
    final stepLabels = [
      ...def.sections.map((s) => isAr ? s.titleAr : s.titleEn),
      isAr ? 'المراجعة والإقرار' : 'Review & Consent',
    ];
    final totalSteps = stepLabels.length;

    final statusWidget = state.correctedFromId != null
        ? StatusBadge.pending(isAr ? 'تعديل وتصحيح نسخة سابقة' : 'Correction Mode')
        : (state.activeDraftId != null
            ? StatusBadge.blush(isAr ? 'مسودة محفوظة' : 'Draft Active')
            : StatusBadge.info(isAr ? 'قيد الإدخال' : 'In Progress'));

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isAr ? 'الخطوة' : 'Step'} ${state.currentStep + 1} ${isAr ? 'من' : 'of'} $totalSteps',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
              ),
              statusWidget,
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (state.currentStep + 1) / totalSteps.toDouble(),
              backgroundColor: AppColors.warmNeutralSand.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(stepLabels.length, (index) {
                final isCurrent = index == state.currentStep;
                final isCompleted = index < state.currentStep;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: isCompleted ? () => ref.read(questionnaireNotifierProvider.notifier).jumpToStep(index) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primary
                            : (isCompleted ? AppColors.softDustyBlush.withValues(alpha: 0.4) : Colors.transparent),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCompleted)
                            const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary)
                          else
                            Text(
                              '${index + 1}.',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isCurrent ? Colors.white : AppColors.secondaryText,
                              ),
                            ),
                          const SizedBox(width: 4),
                          Text(
                            stepLabels[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                              color: isCurrent ? Colors.white : (isCompleted ? AppColors.primary : AppColors.secondaryText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionQuestionsCard(
    BuildContext context,
    WidgetRef ref,
    QuestionnaireState state,
    QuestionnaireDefinition def,
    bool isAr,
  ) {
    final section = def.sections[state.currentStep];

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? section.titleAr : section.titleEn,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            isAr ? section.descriptionAr : section.descriptionEn,
            style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
          ),
          const Divider(height: 32, thickness: 1, color: AppColors.warmNeutralSand),

          ...section.questions.map((question) {
            // Check dependencies
            if (question.dependsOn != null) {
              final parentVal = state.answers[question.dependsOn];
              if (parentVal != question.dependsOnValue) {
                return const SizedBox.shrink();
              }
            }

            final currentVal = state.answers[question.id];
            final error = state.validationErrors[question.id];

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isAr ? question.titleAr : question.titleEn,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.mainText),
                        ),
                      ),
                      if (question.isRequired)
                        const Text(
                          ' *',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  if (question.helpTextAr != null || question.helpTextEn != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      (isAr ? question.helpTextAr : question.helpTextEn) ?? '',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Render Question Input (Number or Options)
                  if (question.type.toLowerCase() == 'number' || question.options.isEmpty) ...[
                    Row(
                      children: [
                        SizedBox(
                          width: 140,
                          child: TextFormField(
                            key: ValueKey('input_${question.id}_${currentVal ?? ''}'),
                            initialValue: currentVal?.toString() ?? '',
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: isAr ? 'أدخلي العمر' : 'Enter age',
                              fillColor: AppColors.surface,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                            ),
                            onChanged: (val) {
                              final numVal = int.tryParse(val) ?? double.tryParse(val);
                              ref.read(questionnaireNotifierProvider.notifier).setAnswer(question.id, numVal ?? val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Quick selection chips for age
                        if (question.id.toLowerCase().contains('age')) ...[
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [25, 35, 45, 55, 65].map((presetAge) {
                                  final isSelected = currentVal == presetAge;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ActionChip(
                                      label: Text('$presetAge ${isAr ? "سنة" : "yrs"}'),
                                      backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
                                      labelStyle: TextStyle(
                                        color: isSelected ? Colors.white : AppColors.mainText,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.outline),
                                      ),
                                      onPressed: () {
                                        ref.read(questionnaireNotifierProvider.notifier).setAnswer(question.id, presetAge);
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ] else ...[
                    // Render Options
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: question.options.map((opt) {
                        final isSelected = currentVal == opt.value;
                        return InkWell(
                          onTap: () {
                            ref.read(questionnaireNotifierProvider.notifier).setAnswer(question.id, opt.value);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.softDustyBlush.withValues(alpha: 0.5) : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.outline,
                                width: isSelected ? 1.8 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isAr ? opt.labelAr : opt.labelEn,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.primary : AppColors.mainText,
                                  ),
                                ),
                                if (opt.subtitleAr != null || opt.subtitleEn != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    (isAr ? opt.subtitleAr : opt.subtitleEn) ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected ? AppColors.primary.withValues(alpha: 0.8) : AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.error_outline, size: 14, color: AppColors.error),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            error,
                            style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    WidgetRef ref,
    QuestionnaireState state,
    QuestionnaireDefinition def,
    bool isAr,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isAr ? 'مراجعة إجاباتك قبل الحفظ والتوثيق' : 'Review Answers Before Submission',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge.active(isAr ? 'جاهز للإرسال' : 'Ready'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isAr
                ? 'يرجى التأكد من دقة المعلومات المدخلة أدناه لمشاركتها مع طبيبك.'
                : 'Please verify the accuracy of your answers below to share with your clinician.',
            style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
          ),
          const Divider(height: 28, thickness: 1, color: AppColors.warmNeutralSand),

          // Render Sections summary
          ...def.sections.map((section) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.powderBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isAr ? section.titleAr : section.titleEn,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                        label: Text(
                          isAr ? 'تعديل' : 'Edit',
                          style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          ref.read(questionnaireNotifierProvider.notifier).jumpToStep(section.stepIndex);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...section.questions.map((q) {
                    final rawVal = state.answers[q.id];
                    if (rawVal == null) return const SizedBox.shrink();

                    String displayAnswer = rawVal.toString();
                    for (final o in q.options) {
                      if (o.value == rawVal) {
                        displayAnswer = isAr ? o.labelAr : o.labelEn;
                        break;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              isAr ? q.titleAr : q.titleEn,
                              style: const TextStyle(fontSize: 12.5, color: AppColors.secondaryText),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Text(
                              displayAnswer,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.mainText),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),

          // Explicit Consent & Disclaimer Checkbox
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: state.consentAcknowledged ? AppColors.primary : AppColors.softDustyBlush,
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: state.consentAcknowledged,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    ref.read(questionnaireNotifierProvider.notifier).toggleConsent(val ?? false);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr
                            ? 'إقرار الفهم والحدود السريرية (إلزامي للإرسال):'
                            : 'Clinical Understanding & Acknowledgment (Required):',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAr
                            ? 'أقر بأن إجاباتي تمثل تاريخي الصحي الذاتي بغرض التحضير لاستشارة طبية. أعلم تماماً أن التطبيق لا يقدم تشخيصاً سرطانياً أو نسبة رقمية لاحتمالية الإصابة، وأن النماذج الحسابية مؤجلة لحين استكمال التحقق الطبي.'
                            : 'I acknowledge that my responses represent self-reported health history to facilitate clinical consultation. I fully understand that Lumyra does NOT provide medical diagnoses or numerical cancer probabilities, and clinical models remain deferred.',
                        style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    QuestionnaireState state,
    QuestionnaireDefinition def,
    bool isAr,
  ) {
    final notifier = ref.read(questionnaireNotifierProvider.notifier);
    final isReviewStep = state.currentStep >= def.sections.length;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        // Back button
        if (state.currentStep > 0)
          PillButton(
            label: isAr ? 'السابق' : 'Back',
            variant: PillButtonVariant.outline,
            onPressed: notifier.previousStep,
          )
        else
          const SizedBox.shrink(),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Save Draft button
            if (!isReviewStep) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.softDustyBlush),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                icon: state.isSavingDraft
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : const Icon(Icons.bookmark_border_rounded, size: 16),
                label: Text(
                  isAr ? 'حفظ التقدم' : 'Save Draft',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: state.isSavingDraft ? null : notifier.saveDraft,
              ),
              const SizedBox(width: 12),
            ],

            // Continue / Submit button
            if (!isReviewStep)
              PillButton(
                label: isAr ? 'متابعة' : 'Continue',
                icon: isAr ? Icons.arrow_back : Icons.arrow_forward,
                onPressed: notifier.nextStep,
              )
            else
              PillButton(
                label: state.isSubmitting
                    ? (isAr ? 'جاري الإرسال...' : 'Submitting...')
                    : (state.correctedFromId != null
                        ? (isAr ? 'توثيق النسخة المصححة' : 'Submit Corrected Version')
                        : (isAr ? 'إرسال وتوثيق الإجابات' : 'Submit & Organize')),
                icon: Icons.check_circle_outline,
                isLoading: state.isSubmitting,
                onPressed: state.isSubmitting || !state.consentAcknowledged ? null : notifier.submit,
              ),
          ],
        ),
      ],
    );
  }
}

/// Results & Clinical Discussion Prep View
class _QuestionnaireResultsView extends ConsumerWidget {
  final QuestionnaireSubmissionResult result;
  final bool isGuest;

  const _QuestionnaireResultsView({
    required this.result,
    this.isGuest = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = context.isArabic;
    final notifier = ref.read(questionnaireNotifierProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.softDustyBlush),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.softDustyBlush.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAr ? 'تم استلام وتوثيق استبيان صحة الثدي' : 'Breast Health History Documented',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAr
                          ? 'تم تنظيم بياناتك الصحية كمرجع منظم للمناقشة في موعدك السريري القادم.'
                          : 'Your self-reported history is now structured for productive discussion at your next clinical consultation.',
                      style: const TextStyle(fontSize: 14, color: AppColors.secondaryText, height: 1.45),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    StatusBadge.blush('${isAr ? 'رمز التوثيق السريري:' : 'Reference ID:'} ${result.requestId}'),
                    const SizedBox(height: 14),

                    // Clinical Code Utility Explanation
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.powderBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.softDustyBlush),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_user_rounded, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isAr ? 'ما فائدة رمز التوثيق السريري؟' : 'Why this clinical reference code?',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isAr
                                ? '• يحفظ خصوصية بياناتكِ بتشفير كامل دون كشف هويتك الشخصية.\n• يمكنكِ إعطاء هذا الرمز لطبيبكِ في العيادة ليفتح تقريركِ السريري فوراً دون الحاجة لإعادة الإجابة على الأسئلة.\n• يوثق تاريخ الفحص لبدء المتابعة الدورية التلقائية كل 30 يوماً.'
                                : '• Secures private data through anonymized clinical encryption.\n• Share this ID with your physician to instantly open your intake record at the clinic.\n• Timestamps your evaluation for the 30-day routine periodic check-in.',
                            style: const TextStyle(fontSize: 12, color: AppColors.mainText, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Smart Clinical Risk Assessment (Gail & Tyrer-Cuzick Criteria)
              if (result.summaryNotice != null && result.summaryNotice!.isNotEmpty) ...[
                AppCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.powderBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'التقييم السريري الذكي ومؤشرات المخاطر' : 'Smart Clinical Risk Evaluation',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                                Text(
                                  isAr ? 'مستند لمعايير Gail Model و Tyrer-Cuzick' : 'Based on Gail & Tyrer-Cuzick criteria',
                                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (result.fiveYearPerspective != null || result.lifetimePerspective != null) ...[
                        Row(
                          children: [
                            if (result.fiveYearPerspective != null)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: EdgeInsets.only(left: isAr ? 6 : 0, right: isAr ? 0 : 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.powderBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.softDustyBlush),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        isAr ? 'مؤشر 5 سنوات' : '5-Yr Risk',
                                        style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        result.fiveYearPerspective!,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (result.lifetimePerspective != null)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: EdgeInsets.only(right: isAr ? 6 : 0, left: isAr ? 0 : 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.powderBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.softDustyBlush),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        isAr ? 'المؤشر التراكمي' : 'Lifetime Risk',
                                        style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        result.lifetimePerspective!,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                      Text(
                        result.summaryNotice!,
                        style: const TextStyle(fontSize: 13, color: AppColors.mainText, height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // SaMD Strict Disclaimer Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.powderBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softDustyBlush, width: 2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.primary, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'الحدود الطبية والأخلاقية للتقرير' : 'Clinical & Ethical Boundaries',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            result.clinicalReviewNotice,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.secondaryText, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Personalized Talking Points Card
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isAr ? 'محاور موصى بها للمناقشة مع طبيبك المعالج' : 'Recommended Talking Points for Your Clinician',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAr
                          ? 'بناءً على إجاباتك، هذه النقاط مقترحة لتسهيل حوارك مع طبيب الأورام أو جراحة الثدي:'
                          : 'Based on your reported responses, consider discussing these aspects during your doctor visit:',
                      style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                    ),
                    const Divider(height: 24, thickness: 1, color: AppColors.warmNeutralSand),

                    ...result.guidanceRecommendations.map((rec) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(Icons.arrow_right_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                rec,
                                style: const TextStyle(fontSize: 13.5, color: AppColors.mainText, height: 1.45),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Actions: Differentiated for Guest Mode vs. Logged-in User
              if (isGuest) ...[
                PillButton(
                  label: isAr
                      ? 'إنشاء حساب جديد لحفظ تقريركِ ومتابعته 🌸'
                      : 'Create Account to Save Report 🌸',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => context.go('/auth/register'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.softDustyBlush, width: 1.5),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(
                    isAr ? 'العودة للرئيسية / خروج' : 'Exit to Home',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () => context.go('/'),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.softDustyBlush),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                      label: Text(
                        isAr ? 'تصحيح أو تعديل الإجابات' : 'Correct / Revise Answers',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                      onPressed: notifier.startCorrection,
                    ),
                    PillButton(
                      label: isAr ? 'العودة للوحة المتابعة' : 'Return to Dashboard',
                      icon: Icons.home_rounded,
                      onPressed: () {
                        context.go('/patient');
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
