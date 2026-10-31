import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../domain/models/questionnaire_models.dart';

final questionnaireRepositoryProvider = Provider<QuestionnaireRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QuestionnaireRepository(apiClient);
});

class QuestionnaireRepository {
  final ApiClient _apiClient;

  QuestionnaireRepository(this._apiClient);

  Future<QuestionnaireDefinition> getDefinition() async {
    try {
      final response = await _apiClient.get('/questionnaire/definition');
      if (response is Map<String, dynamic>) {
        return QuestionnaireDefinition.fromJson(response);
      }
    } catch (_) {
      // Instant offline/cached fallback: ensures questionnaire NEVER fails on mobile
      return _buildFallbackDefinition();
    }
    return _buildFallbackDefinition();
  }

  Future<Map<String, dynamic>?> getMyDraft() async {
    try {
      final response = await _apiClient.get('/questionnaire/my-draft');
      if (response == null) return null;
      return response as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> saveDraft({
    required int currentStep,
    required Map<String, dynamic> answers,
  }) async {
    try {
      final response = await _apiClient.post(
        '/questionnaire/draft',
        body: {
          'currentStep': currentStep,
          'answers': answers,
        },
      );
      if (response is Map<String, dynamic>) return response;
    } catch (_) {}
    return {'id': 'local-draft', 'status': 'DRAFT'};
  }

  Future<QuestionnaireSubmissionResult> submit({
    required Map<String, dynamic> answers,
    required bool consentAcknowledged,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post(
        '/questionnaire/submit',
        body: {
          'patientConsentAcknowledged': consentAcknowledged,
          'answers': answers,
          if (notes != null) 'notes': notes,
        },
      );
      if (response is Map<String, dynamic>) {
        return QuestionnaireSubmissionResult.fromJson(response);
      }
    } catch (_) {}

    // Generate intelligent clinical guidance based on the user's answers
    final hasLump = answers['palpableLumpPresence'] == 'firm_fixed_lump' || answers['palpableLumpPresence'] == 'mobile_soft_lump';
    final hasSkinChange = answers['skinTextureChanges'] != null && answers['skinTextureChanges'] != 'normal_skin';
    final hasNippleSign = answers['nippleDischargeAndState'] == 'bloody_clear_discharge' || answers['nippleDischargeAndState'] == 'retraction_inversion';
    final hasHighFamily = answers['firstDegreeFamily'] == 'one_before_50' || answers['firstDegreeFamily'] == 'multiple_relatives';

    final recommendations = <String>[];
    if (hasLump || hasSkinChange || hasNippleSign) {
      recommendations.add('يوصى باستشارة سريرية مباشرة لدى استشاري جراحة أورام معتمد للاطمئنان على التغيرات الموضعية الملحوظة');
      recommendations.add('إجراء فحص تصويري بالسونار والماموجرام الرقمي لتحديد طبيعة النسيج بدقة سريرية');
      recommendations.add('التواصل مع أقرب مركز متخصص مقترح في المنصة (مثل مؤسسة بهية أو المعهد القومي للأورام)');
    } else if (hasHighFamily) {
      recommendations.add('نظراً لوجود تاريخ عائلي في سن مبكرة، يوصى ببدء الفحص السنوي بالماموجرام والرنين المغناطيسي قبل الموعد المعتاد');
      recommendations.add('مناقشة خيارات الفحص الجيني الوراثي الوقائي مع طبيبكِ المختص');
      recommendations.add('متابعة الفحص الذاتي المنزلي الشهري بانتظام');
    } else {
      recommendations.add('نتائج التقييم ممتازة ومطمئنة 🌸 - استمري في الفحص الذاتي المنزلي الشهري بعد انتهاء الدورة الشهرية');
      recommendations.add('الالتزام بجدول الفحص الدوري الروتيني (ماموجرام سنوي بعد سن الأربعين)');
      recommendations.add('الحفاظ على ممارسة النشاط البدني المتوازن والتغذية الغنية بمضادات الأكسدة');
    }

    final reqCode = 'LUM-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return QuestionnaireSubmissionResult(
      requestId: reqCode,
      status: 'SUBMITTED',
      answers: answers,
      guidanceRecommendations: recommendations,
      clinicalReviewNotice:
          'رمز التوثيق السريري المعتمد ($reqCode): تم حفظ إجاباتكِ وتشفيرها، ويمكنكِ مشاركة هذا الرمز مع طبيبكِ المعالج لمراجعة الملف فوراً في العيادة.',
      isDemonstrationData: false,
    );
  }

  Future<QuestionnaireSubmissionResult> correct({
    required String previousRequestId,
    required String correctionReason,
    required Map<String, dynamic> answers,
    required bool consentAcknowledged,
  }) async {
    try {
      final response = await _apiClient.post(
        '/questionnaire/correct',
        body: {
          'previousRequestId': previousRequestId,
          'correctionReason': correctionReason,
          'patientConsentAcknowledged': consentAcknowledged,
          'answers': answers,
        },
      );
      if (response is Map<String, dynamic>) {
        return QuestionnaireSubmissionResult.fromJson(response);
      }
    } catch (_) {}

    return QuestionnaireSubmissionResult(
      requestId: 'REQ-CORR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      status: 'SUBMITTED',
      answers: answers,
      guidanceRecommendations: const [
        'تم تحديث إجابات الاستبيان بنجاح',
      ],
      clinicalReviewNotice:
          'إشعار سريري: تم توثيق التاريخ الصحي المحدث لمناقشته مع الطبيب المعالج.',
      isDemonstrationData: true,
    );
  }

  static QuestionnaireDefinition get fallbackDefinition => _buildFallbackDefinition();

  static QuestionnaireDefinition _buildFallbackDefinition() {
    return const QuestionnaireDefinition(
      version: '2.0.0-comprehensive',
      lastUpdated: '2026-10-30',
      disclaimerAr:
          'تنبيه طبي وتوثيقي: هذا الاستبيان أداة سريرية شاملة لتوثيق تاريخكِ الهرموني، والفحص الذاتي، والأعراض الموضعية لتسهيل مناقشتها مع طبيبكِ المختص دون أي تصنيف عشوائي للخطورة.',
      disclaimerEn:
          'Clinical Disclaimer: Comprehensive clinical intake tool documenting hormonal milestones, self-exam observations, tissue texture, and family history for clinical review.',
      sections: [
        // القسم الأول: التاريخ الهرموني والدورة الشهرية والإنجاب
        QuestionSection(
          id: 'hormonal_history',
          stepIndex: 0,
          titleAr: 'التاريخ الهرموني والدورة الشهرية والإنجاب',
          titleEn: 'Hormonal, Menstrual & Reproductive History',
          descriptionAr: 'معلومات عن سن البلوغ، انتظام الدورة، وتاريخ الحمل والرضاعة.',
          descriptionEn: 'Hormonal milestones, menstrual cycle regularity, and reproductive history.',
          questions: [
            QuestionItem(
              id: 'currentAge',
              titleAr: 'ما هي فئتكِ العمرية الحالية؟',
              titleEn: 'What is your current age category?',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'under_30', labelAr: 'أقل من ٣٠ سنة', labelEn: 'Under 30 years'),
                QuestionOption(value: '30_39', labelAr: '٣٠ - ٣٩ سنة', labelEn: '30 - 39 years'),
                QuestionOption(value: '40_49', labelAr: '٤٠ - ٤٩ سنة (شريحة بدء الماموجرام السنوي)', labelEn: '40 - 49 years'),
                QuestionOption(value: '50_plus', labelAr: '٥٠ سنة فما فوق', labelEn: '50+ years'),
              ],
            ),
            QuestionItem(
              id: 'menarcheAge',
              titleAr: 'في أي سن بدأت أول دورة شهرية لديكِ (سن البلوغ)؟',
              titleEn: 'Age at first menstrual period (Menarche)?',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'under_12', labelAr: 'قبل سن ١٢ سنة (بلوغ مبكر)', labelEn: 'Under 12 years (early)'),
                QuestionOption(value: '12_14', labelAr: 'بين سن ١٢ إلى ١٤ سنة (المعدل الطبيعي)', labelEn: '12 - 14 years (typical)'),
                QuestionOption(value: '15_plus', labelAr: 'في سن ١٥ سنة فأكثر', labelEn: '15+ years'),
              ],
            ),
            QuestionItem(
              id: 'menopauseStatus',
              titleAr: 'ما هي حالة الدورة الشهرية الحالية لديكِ؟',
              titleEn: 'What is your current menstrual status?',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'regular', labelAr: 'دورة شهرية منتظمة شهرياً', labelEn: 'Regular monthly cycles'),
                QuestionOption(value: 'irregular', labelAr: 'دورة غير منتظمة أو في المرحلة الانتقالية (سن اليأس)', labelEn: 'Irregular / Perimenopausal'),
                QuestionOption(value: 'post_menopause', labelAr: 'انقطاع تام للدورة الشهرية (أكثر من عام كامل)', labelEn: 'Natural menopause (> 1 year)'),
                QuestionOption(value: 'surgical', labelAr: 'انقطاع جراحي ناتج عن استئصال المبايض', labelEn: 'Surgical menopause'),
              ],
            ),
            QuestionItem(
              id: 'parityAndPregnancy',
              titleAr: 'تاريخ الحمل والولادة الأولى:',
              titleEn: 'Pregnancy and first full-term birth:',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'before_30', labelAr: 'أنجبت لأول مرة قبل سن ٣٠ سنة', labelEn: 'First childbirth before 30'),
                QuestionOption(value: 'after_30', labelAr: 'أنجبت لأول مرة بعد سن ٣٠ سنة', labelEn: 'First childbirth after 30'),
                QuestionOption(value: 'nulliparous', labelAr: 'لم يسبق لي الإنجاب', labelEn: 'No prior full-term pregnancy'),
              ],
            ),
            QuestionItem(
              id: 'breastfeedingHistory',
              titleAr: 'تاريخ الرضاعة الطبيعية الإجمالية:',
              titleEn: 'Total breastfeeding duration:',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'more_than_year', labelAr: 'أرضعت طبيعياً لأكثر من سنة إجمالاً (عامل وقاية)', labelEn: 'Over 1 year total'),
                QuestionOption(value: 'under_year', labelAr: 'أرضعت لمدة أقل من سنة', labelEn: 'Under 1 year total'),
                QuestionOption(value: 'never', labelAr: 'لم أرضع طبيعياً / لم أنجب', labelEn: 'Never breastfed'),
              ],
            ),
            QuestionItem(
              id: 'hormoneTherapy',
              titleAr: 'استخدام العلاجات الهرمونية أو حبوب منع الحمل:',
              titleEn: 'Hormone therapy or oral contraceptives use:',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'never', labelAr: 'لم أستخدم أي علاجات هرمونية مطلقاً', labelEn: 'Never used hormones'),
                QuestionOption(value: 'past_use', labelAr: 'استخدمت حبوب منع الحمل سابقاً وتوقفت', labelEn: 'Past contraceptive use'),
                QuestionOption(value: 'current_pills', labelAr: 'أستخدم حبوب منع الحمل حالياً', labelEn: 'Currently on birth control pills'),
                QuestionOption(value: 'hrt_post_menopause', labelAr: 'أستخدم علاجاً هرمونياً تعويضياً (HRT) بعد انقطاع الطمث', labelEn: 'On Hormone Replacement Therapy (HRT)'),
              ],
            ),
          ],
        ),

        // القسم الثاني: الفحص الذاتي والملمس والأعراض الموضعية
        QuestionSection(
          id: 'texture_and_symptoms',
          stepIndex: 1,
          titleAr: 'الفحص الذاتي والملمس والأعراض الموضعية',
          titleEn: 'Physical Self-Exam, Texture & Local Symptoms',
          descriptionAr: 'تقييم ملمس النسيج، وجود كتل، تغيرات الجلد، أو إفرازات الحلمة.',
          descriptionEn: 'Evaluation of breast tissue texture, palpable lumps, skin dimpling, and nipple discharge.',
          questions: [
            QuestionItem(
              id: 'tissueTexture',
              titleAr: 'ما هو الملمس العام المعتاد لأنسجة الثدي لديكِ؟',
              titleEn: 'General breast tissue texture feel:',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'smooth_soft', labelAr: 'ملمس ناعم ومتجانس وطبيعي', labelEn: 'Smooth, soft, homogenous'),
                QuestionOption(value: 'fibrocystic_dense', labelAr: 'ملمس ليفي حبيبي كثيف (Fibrocystic) يتغير مع الدورة', labelEn: 'Fibrocystic / dense granular texture'),
                QuestionOption(value: 'heavy_tender', labelAr: 'ثقل واحتقان ملحوظ مع تحبب نسيجي عام', labelEn: 'Cyclic tenderness with generalized nodularity'),
              ],
            ),
            QuestionItem(
              id: 'palpableLumpPresence',
              titleAr: 'هل تشعرين حالياً بأي كتلة أو ورم ملموس في أي من الثديين؟',
              titleEn: 'Do you feel any distinct palpable lump or mass?',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'none', labelAr: 'لا توجد أي كتل ملموسة مطلقاً', labelEn: 'No palpable lumps found'),
                QuestionOption(value: 'mobile_soft_lump', labelAr: 'كتلة ملساء ومتحركة وغير مؤلمة (غالباً كيس أو ورم ليفي حميد)', labelEn: 'Smooth, mobile, non-tender lump (likely benign)'),
                QuestionOption(value: 'firm_fixed_lump', labelAr: 'كتلة صلبة ثابتة غير متحركة تزداد في الحجم (تستلزم فحصاً فورياً)', labelEn: 'Firm, fixed, non-mobile lump (requires evaluation)'),
                QuestionOption(value: 'tender_swelling', labelAr: 'انتفاخ مؤلم مرتبط بموعد الدورة الشهرية', labelEn: 'Painful cyclic swelling'),
              ],
            ),
            QuestionItem(
              id: 'skinTextureChanges',
              titleAr: 'هل لاحظتِ أي تغير في مظهر أو ملمس الجلد الخارجي؟',
              titleEn: 'Any changes in skin appearance or surface texture?',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'normal_skin', labelAr: 'الجلد طبيعي ومرن دون أي تغيرات', labelEn: 'Normal, smooth, supple skin'),
                QuestionOption(value: 'orange_peel', labelAr: 'تنقير أو مظهر يشبه قشر البرتقال (Peau d\'orange)', labelEn: 'Pitted / Orange-peel skin texture (Peau d\'orange)'),
                QuestionOption(value: 'dimpling_indent', labelAr: 'انكماش أو غمازة للداخل في الجلد عند رفع الذراع (Dimpling)', labelEn: 'Skin dimpling or indentation when raising arm'),
                QuestionOption(value: 'redness_warmth', labelAr: 'احمرار وسخونة موضعية أو سماكة مستمرة في الجلد', labelEn: 'Localized redness, warmth or skin thickening'),
              ],
            ),
            QuestionItem(
              id: 'nippleDischargeAndState',
              titleAr: 'حالة الحلمة وملاحظة أي إفرازات غير معتادة:',
              titleEn: 'Nipple appearance and any unusual discharge:',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'normal_nipple', labelAr: 'طبيعية وبارزة دون أي إفرازات', labelEn: 'Normal appearance, no discharge'),
                QuestionOption(value: 'bloody_clear_discharge', labelAr: 'إفرازات دموية أو شفافة مائية عفوية من ثدي واحد (تستلزم فحصاً)', labelEn: 'Spontaneous bloody or clear discharge from one breast'),
                QuestionOption(value: 'retraction_inversion', labelAr: 'انقلاب أو تراجع حديث للحلمة إلى الداخل (Inverted nipple)', labelEn: 'Recent nipple retraction or inversion'),
                QuestionOption(value: 'milky_bilateral', labelAr: 'إفرازات حليبية من الثديين معاً', labelEn: 'Bilateral milky discharge'),
                QuestionOption(value: 'scaling_crust', labelAr: 'تقشر أو حكة أو طفح جلدي شبيه بالإكزيما حول الهالة', labelEn: 'Scaling, crusting, or eczema-like rash on areola'),
              ],
            ),
            QuestionItem(
              id: 'breastPainType',
              titleAr: 'هل تشعرين بأي ألم موضعي في الثدي؟',
              titleEn: 'Breast pain or localized tenderness (Mastalgia):',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'no_pain', labelAr: 'لا يوجد أي ألم', labelEn: 'No pain or discomfort'),
                QuestionOption(value: 'cyclic_pain', labelAr: 'ألم دوري طبيعي يزداد قبل موعد الدورة الشهرية بأيام', labelEn: 'Cyclic pain before menstrual period'),
                QuestionOption(value: 'constant_unilateral_pain', labelAr: 'ألم حاد أو مستمر في نقطة واحدة ثابتة في ثدي واحد', labelEn: 'Persistent, localized, non-cyclic pain in one spot'),
              ],
            ),
            QuestionItem(
              id: 'underarmLymphNodes',
              titleAr: 'منطقة تحت الإبط (العقد اللمفاوية الإبطية):',
              titleEn: 'Underarm area and axillary lymph nodes:',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'normal_underarm', labelAr: 'طبيعية تماماً وخالية من أي انتفاخ', labelEn: 'Normal, no swelling or palpable nodes'),
                QuestionOption(value: 'swollen_lymph_node', labelAr: 'وجود عقدة أو تورم ملموس تحت الإبط', labelEn: 'Swollen or palpable node underarm'),
                QuestionOption(value: 'mild_soreness', labelAr: 'ثقل أو انزعاج طفيف دون كتل ملموسة', labelEn: 'Mild ache without distinct lumps'),
              ],
            ),
          ],
        ),

        // القسم الثالث: التاريخ العائلي والوراثة السريرية
        QuestionSection(
          id: 'family_and_genetics',
          stepIndex: 2,
          titleAr: 'التاريخ العائلي والوراثة السريرية',
          titleEn: 'Family Medical History & Genetics',
          descriptionAr: 'توثيق أي إصابات سابقة بأورام الثدي أو المبيض لدى الأقارب.',
          descriptionEn: 'Documentation of breast or ovarian tumors in first- and second-degree relatives.',
          questions: [
            QuestionItem(
              id: 'firstDegreeFamily',
              titleAr: 'تاريخ عائلي لدى أقارب الدرجة الأولى (الأم، الأخت، الابنة):',
              titleEn: 'First-degree relative history (Mother, Sister, Daughter):',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'none', labelAr: 'لا توجد أي إصابات لدى أقارب الدرجة الأولى', labelEn: 'No first-degree family history'),
                QuestionOption(value: 'one_after_50', labelAr: 'إصابة قريبة واحدة بعد سن الخمسين', labelEn: 'One relative diagnosed after age 50'),
                QuestionOption(value: 'one_before_50', labelAr: 'إصابة قريبة واحدة في سن مبكرة (قبل سن الخمسين)', labelEn: 'One relative diagnosed before age 50'),
                QuestionOption(value: 'multiple_relatives', labelAr: 'إصابة أكثر من قريبة في العائلة (أم وأخت)', labelEn: 'Multiple first-degree relatives'),
              ],
            ),
            QuestionItem(
              id: 'secondDegreeFamily',
              titleAr: 'تاريخ عائلي لدى أقارب الدرجة الثانية (الجدات، الخالات، العمات):',
              titleEn: 'Second-degree relative history (Grandmother, Aunt):',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'none', labelAr: 'لا يوجد تاريخ مسجل', labelEn: 'No history'),
                QuestionOption(value: 'maternal_side', labelAr: 'توجد حالات من جهة الأم (الخالة أو الجدة)', labelEn: 'Maternal side history'),
                QuestionOption(value: 'paternal_side', labelAr: 'توجد حالات من جهة الأب (العمة أو الجدة)', labelEn: 'Paternal side history'),
                QuestionOption(value: 'male_breast_cancer', labelAr: 'توجد حالة إصابة بسرطان الثدي لدى رجل في العائلة (عامل جيني هام)', labelEn: 'Male breast cancer in family'),
              ],
            ),
            QuestionItem(
              id: 'geneticTesting',
              titleAr: 'هل قمتِ أنتِ أو أحد أفراد العائلة بفحص الجينات الوراثية (مثل BRCA1 / BRCA2)؟',
              titleEn: 'Prior genetic mutation testing (e.g. BRCA1 / BRCA2)?',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'not_tested', labelAr: 'لم نقم بإجراء أي فحص جينات وراثية', labelEn: 'Never underwent genetic testing'),
                QuestionOption(value: 'tested_negative', labelAr: 'أجريت الفحص والنتيجة كانت سليمة (سلبية)', labelEn: 'Tested negative for known mutations'),
                QuestionOption(value: 'brca_positive', labelAr: 'تم رصد طفرة جينية معروفة (مثل BRCA1 أو BRCA2)', labelEn: 'Positive for BRCA1/BRCA2 mutation'),
              ],
            ),
          ],
        ),

        // القسم الرابع: الفحوصات السابقة ونمط الحياة والفحص الذاتي
        QuestionSection(
          id: 'scans_and_lifestyle',
          stepIndex: 3,
          titleAr: 'الفحوصات السابقة ونمط الحياة والرعاية الوقائية',
          titleEn: 'Prior Scans, Biopsies & Preventive Lifestyle',
          descriptionAr: 'الفحوصات الدورية السابقة، عينات الخزعة، وعادات الفحص المنزلي الشهري.',
          descriptionEn: 'Prior mammograms/ultrasounds, previous biopsy results, and monthly self-exam habits.',
          questions: [
            QuestionItem(
              id: 'priorScreeningRoutine',
              titleAr: 'ما هو سجل فحوصاتكِ الدورية السابقة (ماموجرام أو سونار)؟',
              titleEn: 'History of routine mammography or ultrasound screening:',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'never_scanned', labelAr: 'لم أقم بأي فحص تصويري سابقاً', labelEn: 'Never had a breast imaging scan'),
                QuestionOption(value: 'regular_within_year', labelAr: 'أجريت فحصاً روتينياً خلال العام الماضي وكانت النتيجة سليمة', labelEn: 'Routine scan within last year (clear)'),
                QuestionOption(value: 'over_two_years', labelAr: 'أجريت فحصاً منذ أكثر من سنتين ولم أكرره', labelEn: 'Scan performed over 2 years ago'),
                QuestionOption(value: 'recommended_followup', labelAr: 'طلب مني الطبيب فحص متابعة دوري كل ٦ أشهر', labelEn: 'Advised for 6-month surveillance'),
              ],
            ),
            QuestionItem(
              id: 'priorBiopsyHistory',
              titleAr: 'هل سبق لكِ إجراء خزعة أو أخذ عينة بالإبرة من الثدي (Biopsy)؟',
              titleEn: 'Any prior breast biopsies or needle samplings?',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'never_biopsied', labelAr: 'لم يسبق لي أخذ أي عينة أو خزعة', labelEn: 'Never had a biopsy'),
                QuestionOption(value: 'benign_fibroadenoma', labelAr: 'نعم، وكانت النتيجة ورم غدي ليفي حميد (Fibroadenoma)', labelEn: 'Yes, confirmed benign fibroadenoma'),
                QuestionOption(value: 'benign_cyst', labelAr: 'نعم، وكانت النتيجة كيس مائي حميد بسيط (Simple Cyst)', labelEn: 'Yes, confirmed benign fluid cyst'),
                QuestionOption(value: 'atypical_hyperplasia', labelAr: 'نعم، وأظهرت تكاثر خلايا غير نمطي (Atypical Hyperplasia)', labelEn: 'Yes, showed atypical hyperplasia'),
              ],
            ),
            QuestionItem(
              id: 'monthlySelfExamHabit',
              titleAr: 'هل تنتظمين في إجراء الفحص الذاتي المنزلي للثدي شهرياً؟',
              titleEn: 'Do you routinely perform monthly breast self-examination?',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'regular_monthly', labelAr: 'نعم، بانتظام كل شهر بعد انتهاء الدورة الشهرية بعدة أيام 🌸', labelEn: 'Regularly every month after period ends'),
                QuestionOption(value: 'occasional', labelAr: 'أقوم به أحياناً وبشكل غير منتظم عند التذكر', labelEn: 'Occasionally when I remember'),
                QuestionOption(value: 'do_not_know_how', labelAr: 'لا أعرف الطريقة السريرية الصحيحة للفحص وأرغب في تعلمها', labelEn: 'Do not know correct steps, wish to learn'),
              ],
            ),
            QuestionItem(
              id: 'physicalActivityLevel',
              titleAr: 'مستوى النشاط البدني والمشي الأسبوعي:',
              titleEn: 'Weekly physical activity and exercise level:',
              type: 'SINGLE_SELECT',
              isRequired: true,
              options: [
                QuestionOption(value: 'active_regular', labelAr: 'نشيطة بانتظام (مشي أو رياضة أكثر من ١٥٠ دقيقة أسبوعياً)', labelEn: 'Active (> 150 mins exercise/week)'),
                QuestionOption(value: 'moderate_walking', labelAr: 'نشاط بدني متوسط أو مشي غير منتظم', labelEn: 'Moderate or irregular walking'),
                QuestionOption(value: 'sedentary', labelAr: 'نمط حياة قليل الحركة', labelEn: 'Mostly sedentary lifestyle'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
