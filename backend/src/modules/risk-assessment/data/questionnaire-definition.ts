export interface QuestionnaireOption {
  value: string;
  labelAr: string;
  labelEn: string;
  descriptionAr?: string;
  descriptionEn?: string;
}

export interface QuestionnaireQuestion {
  id: string;
  type: 'single_select' | 'multi_select' | 'number' | 'boolean' | 'date_range';
  labelAr: string;
  labelEn: string;
  descriptionAr?: string;
  descriptionEn?: string;
  required: boolean;
  options?: QuestionnaireOption[];
  min?: number;
  max?: number;
  conditionalOn?: {
    questionId: string;
    value: any;
  };
  clinicalRationaleAr?: string;
  clinicalRationaleEn?: string;
}

export interface QuestionnaireSection {
  id: string;
  stepIndex: number;
  titleAr: string;
  titleEn: string;
  descriptionAr: string;
  descriptionEn: string;
  questions: QuestionnaireQuestion[];
}

export interface QuestionnaireDefinition {
  version: string;
  lastUpdated: string;
  disclaimerAr: string;
  disclaimerEn: string;
  sections: QuestionnaireSection[];
}

export const CURRENT_QUESTIONNAIRE_VERSION = '1.1.0-guided';

export const QUESTIONNAIRE_DEFINITION: QuestionnaireDefinition = {
  version: CURRENT_QUESTIONNAIRE_VERSION,
  lastUpdated: '2026-10-25',
  disclaimerAr:
    'تنبيه طبي: هذا الاستبيان أداة توثيقية إرشادية لتنظيم معلوماتكِ الصحية وتسهيل مناقشتها مع طبيبكِ المختص. الاستبيان لا يحسب نسباً مئوية للإصابة، ولا يحدد درجة خطورة، ولا يمثل فحصاً تشخيصياً لسرطان الثدي.',
  disclaimerEn:
    'Clinical Disclaimer: This guided questionnaire is an informational intake tool to organize your self-reported health history for discussion with your doctor. It does NOT calculate statistical cancer probabilities, assert clinical risk tiers, or substitute for professional medical screening.',
  sections: [
    {
      id: 'demographics',
      stepIndex: 0,
      titleAr: 'المعلومات العامة والديموغرافية',
      titleEn: 'General & Demographic Information',
      descriptionAr: 'معلومات عامة حول المرحلة العمرية والحالة الهرمونية العامة.',
      descriptionEn: 'General information regarding age and hormonal milestones.',
      questions: [
        {
          id: 'currentAge',
          type: 'number',
          labelAr: 'العمر الحالي (بالسنوات)',
          labelEn: 'Current Age (in years)',
          descriptionAr: 'يساعد العمر في تحديد إرشادات الفحص السريري الدورية المناسبة.',
          descriptionEn: 'Age informs routine clinical examination schedules.',
          required: true,
          min: 18,
          max: 100,
        },
        {
          id: 'menopausalStatus',
          type: 'single_select',
          labelAr: 'حالة انقطاع الطمث (الدورة الشهرية)',
          labelEn: 'Menopausal Status',
          required: true,
          options: [
            {
              value: 'PRE_MENOPAUSAL',
              labelAr: 'دورة شهرية منتظمة (قبل انقطاع الطمث)',
              labelEn: 'Regular menstrual cycles (Premenopausal)',
            },
            {
              value: 'PERI_MENOPAUSAL',
              labelAr: 'مرحلة انتقالية أو دورة غير منتظمة',
              labelEn: 'Transitional or irregular cycles (Perimenopausal)',
            },
            {
              value: 'POST_MENOPAUSAL',
              labelAr: 'انقطاع تام للدورة الشهرية (أكثر من سنة)',
              labelEn: 'Natural menopause (no periods for > 1 year)',
            },
            {
              value: 'SURGICAL_MENOPAUSE',
              labelAr: 'انقطاع ناتج عن جراحة استئصال المبايض',
              labelEn: 'Surgical menopause (oophorectomy)',
            },
            {
              value: 'UNSURE',
              labelAr: 'غير متأكدة / غير محدد',
              labelEn: 'Unsure / Not determined',
            },
          ],
        },
      ],
    },
    {
      id: 'reproductive',
      stepIndex: 1,
      titleAr: 'التاريخ الإنجابي والهرموني',
      titleEn: 'Reproductive & Hormonal History',
      descriptionAr: 'معلومات تتعلق بعمر بداية الدورة الشهرية وتاريخ الإنجاب.',
      descriptionEn: 'Milestones related to menarche, parity, and hormone use.',
      questions: [
        {
          id: 'ageAtMenarche',
          type: 'single_select',
          labelAr: 'عمر بدء الدورة الشهرية لأول مرة',
          labelEn: 'Age at First Menstrual Period (Menarche)',
          required: true,
          options: [
            { value: 'UNDER_12', labelAr: 'أقل من ١٢ سنة', labelEn: 'Under 12 years' },
            { value: '12_TO_13', labelAr: 'بين ١٢ و ١٣ سنة', labelEn: '12 to 13 years' },
            { value: '14_OR_OLDER', labelAr: '١٤ سنة أو أكبر', labelEn: '14 years or older' },
            { value: 'NOT_SURE', labelAr: 'لا أتذكر بدقة', labelEn: 'Do not recall' },
          ],
        },
        {
          id: 'hasGivenBirth',
          type: 'single_select',
          labelAr: 'هل سبق لكِ الإنجاب والولادة؟',
          labelEn: 'Have you ever given birth?',
          required: true,
          options: [
            { value: 'YES', labelAr: 'نعم', labelEn: 'Yes' },
            { value: 'NO', labelAr: 'لا (لم يسبق الإنجاب)', labelEn: 'No (Nulliparous)' },
          ],
        },
        {
          id: 'ageAtFirstLiveBirth',
          type: 'single_select',
          labelAr: 'العمر عند أول ولادة لطفل حي',
          labelEn: 'Age at First Full-Term Live Birth',
          required: false,
          conditionalOn: { questionId: 'hasGivenBirth', value: 'YES' },
          options: [
            { value: 'UNDER_20', labelAr: 'أقل من ٢٠ سنة', labelEn: 'Under 20 years' },
            { value: '20_TO_24', labelAr: 'من ٢٠ إلى ٢٤ سنة', labelEn: '20 to 24 years' },
            { value: '25_TO_29', labelAr: 'من ٢٥ إلى ٢٩ سنة', labelEn: '25 to 29 years' },
            { value: '30_OR_OLDER', labelAr: '٣٠ سنة أو أكبر', labelEn: '30 years or older' },
          ],
        },
        {
          id: 'hormoneReplacementTherapy',
          type: 'single_select',
          labelAr: 'استخدام العلاج الهرموني البديل (HRT)',
          labelEn: 'Hormone Replacement Therapy (HRT) Use',
          descriptionAr: 'استخدام الهرمونات البديلة لتخفيف أعراض سن اليأس.',
          descriptionEn: 'Systemic estrogen or combined progestin therapy for menopause.',
          required: true,
          options: [
            { value: 'NEVER', labelAr: 'لم أستخدمه مطلقاً', labelEn: 'Never used' },
            { value: 'CURRENT', labelAr: 'أستخدمه حالياً', labelEn: 'Currently using' },
            { value: 'PAST', labelAr: 'استخدمته في السابق وتوقفت', labelEn: 'Used in the past (discontinued)' },
            { value: 'UNSURE', labelAr: 'غير متأكدة', labelEn: 'Unsure' },
          ],
        },
      ],
    },
    {
      id: 'family_history',
      stepIndex: 2,
      titleAr: 'التاريخ الصحي للعائلة',
      titleEn: 'Family Health History',
      descriptionAr: 'تشخيصات أورام الثدي أو المبيض لدى الأقارب من الدرجة الأولى.',
      descriptionEn: 'Documented history of breast or ovarian conditions in first-degree relatives.',
      questions: [
        {
          id: 'firstDegreeBreastCancer',
          type: 'single_select',
          labelAr: 'هل أصيبت والدتكِ، أختكِ، أو ابنتكِ بسرطان الثدي؟',
          labelEn: 'Has a mother, sister, or daughter had breast cancer?',
          required: true,
          options: [
            { value: 'NO', labelAr: 'لا، لم تسجل أي إصابة', labelEn: 'No recorded diagnoses' },
            { value: 'ONE', labelAr: 'نعم، قريبة واحدة من الدرجة الأولى', labelEn: 'Yes, 1 first-degree relative' },
            { value: 'TWO_OR_MORE', labelAr: 'نعم، قريبتان أو أكثر', labelEn: 'Yes, 2 or more first-degree relatives' },
            { value: 'UNKNOWN', labelAr: 'التاريخ العائلي غير معروف', labelEn: 'Unknown / Adopted' },
          ],
        },
        {
          id: 'diagnosedBeforeAge50',
          type: 'single_select',
          labelAr: 'هل تم تشخيص أي من القريبات قبل سن الخمسين؟',
          labelEn: 'Was any relative diagnosed before age 50?',
          required: false,
          conditionalOn: { questionId: 'firstDegreeBreastCancer', value: ['ONE', 'TWO_OR_MORE'] },
          options: [
            { value: 'YES', labelAr: 'نعم، قبل سن الخمسين', labelEn: 'Yes, before age 50' },
            { value: 'NO', labelAr: 'لا، جميع التشخيصات بعد سن الخمسين', labelEn: 'No, all diagnosed after age 50' },
            { value: 'UNSURE', labelAr: 'غير متأكدة من العمر الدقيق', labelEn: 'Unsure of diagnosis age' },
          ],
        },
        {
          id: 'familyOvarianCancer',
          type: 'single_select',
          labelAr: 'هل يوجد تاريخ عائلي لسرطان المبيض؟',
          labelEn: 'Is there a family history of ovarian cancer?',
          required: true,
          options: [
            { value: 'YES', labelAr: 'نعم', labelEn: 'Yes' },
            { value: 'NO', labelAr: 'لا', labelEn: 'No' },
            { value: 'UNKNOWN', labelAr: 'غير معلوم', labelEn: 'Unknown' },
          ],
        },
        {
          id: 'geneticTestingStatus',
          type: 'single_select',
          labelAr: 'الفحوصات الجينية الوراثية (مثل طفرات BRCA1 أو BRCA2)',
          labelEn: 'Genetic Mutation Testing Status (e.g. BRCA1 / BRCA2)',
          required: true,
          options: [
            { value: 'NOT_TESTED', labelAr: 'لم يسبق إجراء فحص جيني', labelEn: 'Never tested' },
            { value: 'NEGATIVE', labelAr: 'أجريت الفحص والنتيجة سالبة (طبيعية)', labelEn: 'Tested negative (normal)' },
            { value: 'POSITIVE_BRCA', labelAr: 'أجريت الفحص وتأكد وجود طفرة جينية', labelEn: 'Tested positive for mutation' },
            { value: 'VARIANT_UNCERTAIN', labelAr: 'طفرة غير محددة الأثر (VUS)', labelEn: 'Variant of uncertain significance' },
          ],
        },
      ],
    },
    {
      id: 'personal_history',
      stepIndex: 3,
      titleAr: 'التاريخ الشخصي لخزعات وفحوصات الثدي',
      titleEn: 'Personal Breast Health & Biopsy History',
      descriptionAr: 'معلومات الفحوصات السابقة والخزعات النسيجية، إن وجدت.',
      descriptionEn: 'Prior imaging, tissue biopsies, and current symptoms.',
      questions: [
        {
          id: 'priorBiopsyHistory',
          type: 'single_select',
          labelAr: 'هل سبق لكِ إجراء خزعة نسيجية من الثدي (Breast Biopsy)؟',
          labelEn: 'Have you ever had a previous breast biopsy?',
          required: true,
          options: [
            { value: 'NONE', labelAr: 'لا، لم يسبق لي إجراء خزعة', labelEn: 'Never had a biopsy' },
            { value: 'BENIGN', labelAr: 'نعم، وأظهرت نتيجة حميدة تماماً', labelEn: 'Yes, completely benign result' },
            { value: 'ATYPICAL_HYPERPLASIA', labelAr: 'نعم، مع وجود فرط تنسج لانمطي (Atypical Hyperplasia)', labelEn: 'Yes, atypical hyperplasia diagnosed' },
            { value: 'LCIS', labelAr: 'نعم، مع وجود خلايا فصيصية موضعية (LCIS)', labelEn: 'Yes, LCIS diagnosed' },
            { value: 'UNSURE', labelAr: 'أجريت خزعة ولا أعلم التفاصيل الدقيقة', labelEn: 'Had a biopsy but histology unknown' },
          ],
        },
        {
          id: 'denseBreastsReported',
          type: 'single_select',
          labelAr: 'هل تم إخباركِ بوجود كثافة في نسيج الثدي (Dense Breasts) في ماموجرام سابق؟',
          labelEn: 'Were you informed of dense breast tissue on prior mammograms?',
          required: true,
          options: [
            { value: 'NO_OR_NEVER_HAD_MAMMOGRAM', labelAr: 'لا / لم أجرِ فحص الماموجرام من قبل', labelEn: 'No / Never had a mammogram' },
            { value: 'NORMAL_DENSITY', labelAr: 'تم إخباري بأن الكثافة طبيعية أو منخفضة', labelEn: 'Informed tissue is normal / fatty' },
            { value: 'HIGH_DENSITY', labelAr: 'نعم، تم إخباري بأن النسيج كثيف', labelEn: 'Yes, informed tissue is dense' },
            { value: 'NOT_DISCUSSED', labelAr: 'أجريت فحصاً ولكن لم يناقش الطبيب الكثافة', labelEn: 'Had mammogram but density not discussed' },
          ],
        },
        {
          id: 'currentSymptomsReported',
          type: 'single_select',
          labelAr: 'هل تلاحظين حالياً أي تغيرات ملموسة بالثدي (مثل كتلة جديدة، تغير بشكل الحلمة، أو إفرازات)؟',
          labelEn: 'Are you currently noticing any palpable breast changes (e.g. lump, nipple changes, discharge)?',
          descriptionAr: 'تنبيه سريري: هذه المعلومات تساعد طبيبكِ. أي أعراض جديدة تستدعي فحصاً سريرياً مباشراً.',
          descriptionEn: 'Clinical notice: Any new or persistent breast changes warrant direct clinical evaluation.',
          required: true,
          options: [
            { value: 'NO_SYMPTOMS', labelAr: 'لا، لا توجد أي أعراض ملموسة حالياً', labelEn: 'No current changes observed' },
            { value: 'CHANGES_PRESENT', labelAr: 'نعم، ألاحظ تغيراً أو كتلة ملموسة تستدعي الفحص', labelEn: 'Yes, observing changes requiring examination' },
          ],
        },
      ],
    },
  ],
};
