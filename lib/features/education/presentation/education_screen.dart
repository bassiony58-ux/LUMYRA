import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/voice_note_widgets.dart';
import 'widgets/interactive_3d_breast_viewer.dart';

class SurvivorStory {
  final String id;
  final String nameAr;
  final String nameEn;
  final String ageCityAr;
  final String ageCityEn;
  final String remissionYearsAr;
  final String remissionYearsEn;
  final String stageAr;
  final String stageEn;
  final String quoteAr;
  final String quoteEn;
  final String journeyAr;
  final String journeyEn;
  final String adviceAr;
  final String adviceEn;
  final int durationSeconds;
  final String? audioPath;

  const SurvivorStory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.ageCityAr,
    required this.ageCityEn,
    required this.remissionYearsAr,
    required this.remissionYearsEn,
    required this.stageAr,
    required this.stageEn,
    required this.quoteAr,
    required this.quoteEn,
    required this.journeyAr,
    required this.journeyEn,
    required this.adviceAr,
    required this.adviceEn,
    required this.durationSeconds,
    this.audioPath,
  });

  String name(bool isAr) => isAr ? nameAr : nameEn;
  String ageCity(bool isAr) => isAr ? ageCityAr : ageCityEn;
  String remission(bool isAr) => isAr ? remissionYearsAr : remissionYearsEn;
  String stage(bool isAr) => isAr ? stageAr : stageEn;
  String quote(bool isAr) => isAr ? quoteAr : quoteEn;
  String journey(bool isAr) => isAr ? journeyAr : journeyEn;
  String advice(bool isAr) => isAr ? adviceAr : adviceEn;
}

class EducationArticle {
  final String id;
  final String categoryKey;
  final String titleAr;
  final String titleEn;
  final String categoryAr;
  final String categoryEn;
  final String readTimeAr;
  final String readTimeEn;
  final String doctorReviewerAr;
  final String doctorReviewerEn;
  final String summaryAr;
  final String summaryEn;
  final String fullContentAr;
  final String fullContentEn;
  final String problemLabelAr;
  final String problemLabelEn;
  final String problemDetailAr;
  final String problemDetailEn;
  final IconData icon;
  final String illustrationType; // cyst, fibroadenoma, mastitis, calcification, suspicious, exam, general
  final bool isDoctorPublished;

  EducationArticle({
    required this.id,
    required this.categoryKey,
    required this.titleAr,
    required this.titleEn,
    required this.categoryAr,
    required this.categoryEn,
    required this.readTimeAr,
    required this.readTimeEn,
    required this.doctorReviewerAr,
    required this.doctorReviewerEn,
    required this.summaryAr,
    required this.summaryEn,
    required this.fullContentAr,
    required this.fullContentEn,
    required this.problemLabelAr,
    required this.problemLabelEn,
    required this.problemDetailAr,
    required this.problemDetailEn,
    required this.icon,
    this.illustrationType = 'general',
    this.isDoctorPublished = false,
  });

  String title(bool isAr) => isAr ? titleAr : titleEn;
  String category(bool isAr) => isAr ? categoryAr : categoryEn;
  String readTime(bool isAr) => isAr ? readTimeAr : readTimeEn;
  String doctorReviewer(bool isAr) => isAr ? doctorReviewerAr : doctorReviewerEn;
  String summary(bool isAr) => isAr ? summaryAr : summaryEn;
  String fullContent(bool isAr) => isAr ? fullContentAr : fullContentEn;
  String problemLabel(bool isAr) => isAr ? problemLabelAr : problemLabelEn;
  String problemDetail(bool isAr) => isAr ? problemDetailAr : problemDetailEn;
}

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  String _selectedCategoryKey = 'all';
  final TextEditingController _searchController = TextEditingController();
  List<EducationArticle> _apiArticles = [];
  bool _isLoadingApi = true;

  final List<EducationArticle> _presetArticles = [
    EducationArticle(
      id: 'art-fibroadenoma',
      categoryKey: 'benign',
      illustrationType: 'fibroadenoma',
      icon: Icons.bubble_chart_rounded,
      titleAr: 'الورم الغدي الليفي (Fibroadenoma): أكثر كتل الثدي الحميدة شيوعاً',
      titleEn: 'Fibroadenoma: The Most Common Benign Breast Lump',
      categoryAr: 'كتل حميدة',
      categoryEn: 'Benign Lumps',
      readTimeAr: '٥ دقائق قراءة',
      readTimeEn: '5 min read',
      doctorReviewerAr: 'إشراف: د. نور الخالدي (استشاري جراحة الأورام)',
      doctorReviewerEn: 'Supervised by Dr. Noor Al-Khalidi (Breast Surgical Oncologist)',
      summaryAr: 'كتلة صلبة ملساء ومتحركة تسمى "فأرة الثدي"، شائعة جداً بين سن ١٨ و٣٥ سنة، وهي حميدة ١٠٠٪ ولا تتحول لأورام خبيثة.',
      summaryEn: 'A smooth, rubbery, highly mobile lump called the "breast mouse". Common between ages 18-35, 100% benign with zero malignant potential.',
      problemLabelAr: 'المشكلة: ورم غدي ليفي حميد (Fibroadenoma)',
      problemLabelEn: 'Finding: Benign Fibroadenoma (Well-circumscribed)',
      problemDetailAr: '• كتلة بيضاوية ملساء ومطاطية أفقية التوجه\n• تتحرك بحرية عند الفحص اليدوي السريري\n• فحص السونار يؤكد حوافها الواضحة تماماً (BI-RADS 2/3)\n• المتابعة الدورية كافية دون جراحة إذا كانت صغيرة ومستقرة',
      problemDetailEn: '• Oval, well-circumscribed, wider-than-tall rubbery mass\n• Moves freely beneath the fingers during physical exam\n• Ultrasound confirms clean homogenous margins (BI-RADS 2/3)\n• Regular surveillance is sufficient without surgical intervention',
      fullContentAr: '''
ما هو الورم الغدي الليفي (Fibroadenoma)؟
الورم الغدي الليفي هو أكثر أنواع كتل الثدي الحميدة غير السرطانية شيوعاً على الإطلاق، خاصة لدى الفتيات والسيدات الشابات بين سن ١٨ و٣٥ عاماً.

كيف تصفينه عند الفحص اليدوي؟
• ملمس أملس ومطاطي محدد الحواف بدقة.
• غير مؤلم في معظم الحالات.
• يتحرك بحرية وانسيابية تحت الجلد عند الضغط عليه بالأصابع (ولذلك يطلق عليه الأطباء سريرياً لقب "فأرة الثدي" أو Breast Mouse).

كيف يظهر في فحص السونار (الموجات فوق الصوتية)؟
يظهر السونار شكل كتلة بيضاوية واضحة المعالم، أفقية التوجه (عرضها أكبر من طولها)، ذات حواف ملساء ومنتظمة (Well-circumscribed)، مع ارتداد صوتي متجانس يؤكد طبيعتها الليفية الحميدة.

ما هو بروتوكول التعامل الطبي؟
١. إذا كان حجم الكتلة صغيراً (أقل من ٢-٣ سم) ومستقراً، يكتفى بالمتابعة الدورية بالسونار كل ٦ إلى ١٢ شهراً دون أي حاجة لجراحة.
٢. التدخل الجراحي أو الاستئصال بالتجميد يُقترح فقط إذا تسببت في إزعاج جمالي أو إذا زاد حجمها بشكل متسارع.
٣. الورم الغدي الليفي حميد تماماً ولا يرفع احتمال الإصابة بالأورام الخبيثة.
''',
      fullContentEn: '''
What is a Fibroadenoma?
A fibroadenoma is the single most common benign (non-cancerous) breast tumor, predominantly diagnosed in women aged 18 to 35. It is composed of both glandular and stromal (connective) breast tissues.

Clinical Characteristics on Self-Exam & Palpation:
• Smooth, firm, and distinctly rubbery texture.
• Painless in the vast majority of cases.
• Extremely mobile beneath the skin when pressed, earning it the clinical nickname "breast mouse".

Classic Ultrasound Features:
On targeted breast sonography, a fibroadenoma appears as a well-circumscribed, oval mass with an axis parallel to the skin ("wider than tall") and uniform internal echoes, confirming its non-infiltrative nature.

Evidence-Based Clinical Protocol:
1. Conservative Observation: For lesions under 2–3 cm with classic benign morphology, routine ultrasound follow-up every 6–12 months is standard care.
2. Zero Malignant Risk: Simple fibroadenomas do not transform into breast cancer.
3. Excision Options: Surgical removal or cryoablation is considered only if rapid enlargement occurs or for patient symptomatic comfort.
''',
    ),
    EducationArticle(
      id: 'art-cysts',
      categoryKey: 'cysts',
      illustrationType: 'cyst',
      icon: Icons.water_drop_rounded,
      titleAr: 'أكياس الثدي المائية (Breast Cysts): أسبابها وعلاقتها بالهرمونات',
      titleEn: 'Breast Cysts: Hormonal Causes, Ultrasound & Management',
      categoryAr: 'أكياس مائية',
      categoryEn: 'Cysts',
      readTimeAr: '٤ دقائق قراءة',
      readTimeEn: '4 min read',
      doctorReviewerAr: 'إشراف: د. مريم القاضي (استشاري الأشعة التشخيصية)',
      doctorReviewerEn: 'Supervised by Dr. Mariam Al-Qadi (Consultant Diagnostic Radiologist)',
      summaryAr: 'حويصلات ممتلئة بسائل ترتبط مباشرة باضطرابات الدورة الشهرية، تظهر في السونار كفراغ أسود نقي (Anechoic) ذو جدار رقيق.',
      summaryEn: 'Fluid-filled sacs closely linked to hormonal cycle fluctuations. Sonography confirms thin-walled, purely anechoic appearance (BI-RADS 2).',
      problemLabelAr: 'المشكلة: كيس مائي حميد ممتلئ بسائل (Simple Cyst)',
      problemLabelEn: 'Finding: Simple Fluid-Filled Cyst (Anechoic)',
      problemDetailAr: '• حويصلة دائرية ممتلئة بسائل طبيعي بالكامل\n• تظهر كفراغ أسود نقي بالسونار (Anechoic)\n• جدار رقيق جداً وأملس مع تعزيز صوتي خلفي نقي\n• تصنيف BI-RADS 2 (حميدة بنسبة 100% ولا تحتاج جراحة)',
      problemDetailEn: '• Circular sac filled completely with benign fluid\n• Appears purely anechoic (black void) on ultrasound\n• Ultra-thin smooth capsule with posterior acoustic enhancement\n• Classified as BI-RADS 2 (100% benign, zero surgery required)',
      fullContentAr: '''
ما هي أكياس الثدي (Cysts)؟
أكياس الثدي هي حويصلات دائرية تتجمع بداخلها سوائل طبيعية نتيجة انسداد طفيف في القنوات الحليبية الدقيقة، وتتأثر بشكل مباشر بتقلبات هرموني الإستروجين والبروجسترون.

الأعراض والملاحظات السريرية:
• قد تلاحظين ظهورها فجأة أو زيادة حجمها وألمها في الأيام التي تسبق موعد الدورة الشهرية، ثم يقل حجمها ويهدأ الألم تلقائياً بعد انتهاء الطمث.
• تكون عادة ناعمة ومرنة الملمس مثل بالون ماء صغير.

المظهر الإشعاعي الذهبي بالسونار:
السونار هو الفحص القاطع لتشخيص الأكياس المائية؛ حيث تظهر كفراغ دائري أسود بالكامل (Anechoic) نظراً لمرور الموجات الصوتية بالماء دون أي ارتداد داخلي، مع جدار رقيق وأملس للغاية، وتصنف سريرياً كـ BI-RADS 2 (حميدة بنسبة ١٠٠٪).

كيف يتم علاجها؟
• الأكياس البسيطة لا تحتاج لأي علاج دوائي أو جراحي.
• إذا كان الكيس كبيراً ومشدوداً ويسبب ألماً، يقوم الطبيب بسحب السائل بإبرة دقيقة (Fine Needle Aspiration) في العيادة خلال ٦٠ ثانية، ويختفي الألم فوراً.
''',
      fullContentEn: '''
What are Breast Cysts?
Breast cysts are fluid-filled sacs that develop inside the lobules of the breast when delicate terminal ducts experience temporary obstruction. They fluctuate in response to circulating estrogen and progesterone.

Clinical Manifestations:
• Sudden onset or noticeable swelling and cyclic tenderness in the week preceding menstruation.
• Spontaneous softening and size reduction following the end of the period.
• Texture resembles a miniature water balloon beneath the surface.

Sonographic Confirmation:
Ultrasound is the definitive gold standard. A simple cyst demonstrates an imperceptible capsule, absent internal echoes (anechoic), and pronounced posterior acoustic enhancement (BI-RADS 2).

Clinical Management:
• Simple cysts require zero medication or surgical excision.
• If tense and causing discomfort, straightforward in-clinic fine-needle aspiration (FNA) relieves pressure immediately.
''',
    ),
    EducationArticle(
      id: 'art-mastitis',
      categoryKey: 'inflammation',
      illustrationType: 'mastitis',
      icon: Icons.local_fire_department_rounded,
      titleAr: 'التهاب الثدي وتوسع القنوات اللبنية (Mastitis & Duct Ectasia)',
      titleEn: 'Mastitis & Duct Ectasia: Symptoms, Causes & Antibiotic Protocol',
      categoryAr: 'التهابات الثدي',
      categoryEn: 'Inflammation',
      readTimeAr: '٤ دقائق قراءة',
      readTimeEn: '4 min read',
      doctorReviewerAr: 'إشراف: د. سارة عزمي (استشاري جراحة الثدي)',
      doctorReviewerEn: 'Supervised by Dr. Sara Azmy (Breast Surgical Specialist)',
      summaryAr: 'احمرار موضعي، سخونة وألم نابض شائع أثناء الرضاعة أو قرب انقطاع الطمث. حالة التهابية تستجيب تماماً للمضادات دون جراحة.',
      summaryEn: 'Localized erythema, warmth, and throbbing tenderness during lactation or perimenopause. Responds rapidly to targeted oral antibiotics.',
      problemLabelAr: 'المشكلة: التهاب القنوات اللبنية والأنسجة (Mastitis)',
      problemLabelEn: 'Finding: Inflamed Duct System & Hyperemic Tissue',
      problemDetailAr: '• احمرار موضعي مثلث أو قطاعي وسخونة ملموسة بالجلد\n• احتقان في القنوات اللبنية تحت الهالة والحلمة\n• السونار يظهر زيادة تدفق الدم الالتهابي (Hyperemia) وسماكة الجلد\n• علاج دوائي ناجح بالمضادات الحيوية دون أي تدخل جراحي',
      problemDetailEn: '• Wedge-shaped erythema and marked localized dermal warmth\n• Duct congestion and subareolar inflammatory hyperemia\n• Doppler sonography shows increased tissue vascularity and edema\n• Successfully managed with targeted outpatient antibiotic course',
      fullContentAr: '''
ما هو التهاب الثدي (Mastitis)؟
التهاب الأنسجة الثديية هو حالة التهابية شائعة جداً تحدث غالباً بسبب ركود الحليب في إحدى القنوات اللبنية أثناء الرضاعة ودخول بكتيريا سطحية، أو نتيجة توسع القنوات اللبنية تحت الحلمة (Mammary Duct Ectasia).

العلامات التي تشعرين بها:
• احمرار موضعي مثلث الشكل أو قطاعي على جلد الثدي.
• دفء وسخونة ملحوظة عند لمس المنطقة المصابة.
• ألم مستمر أو نابض مع تورم وثقل.
• قد تصاحبه أعراض عامة تشبه الإنفلونزا (حمى خفيفة، إرهاق).

الفحص والتفرقة السريرية:
الفحص السريري والسونار يوضحان زيادة سماكة الجلد وتدفق الدم الالتهابي (Hyperemia) دون وجود أي كتلة سرطانية صلبة.

خطة العلاج المعتمدة:
١. كورس كامل من المضادات الحيوية الآمنة يصفها الطبيب المعالج لمدة ٧-١٠ أيام.
٢. عمل كمادات دافئة قبل الرضاعة لتصريف القنوات، وكمادات باردة مهدئة بعدها.
٣. الاستمرار في تفريغ الثدي بانتظام، فالالتهاب يزول تماماً مع العلاج دون أي آثار سلبية.
''',
      fullContentEn: '''
What is Mastitis?
Mastitis is an inflammatory condition of the breast tissue that most commonly affects lactating mothers due to milk stasis and superficial skin flora entry, or perimenopausal individuals via subareolar duct ectasia.

Recognizable Signs:
• Wedge-shaped, localized redness (erythema) over the breast skin.
• Conspicuous radiant warmth to touch.
• Throbbing ache, breast enlargement, and occasional flu-like symptoms.

Diagnostic Differentiation:
Targeted Doppler ultrasound confirms tissue hyperemia and edema without discrete solid hypoechoic masses, differentiating acute inflammation from malignant involvement.

Clinical Treatment Strategy:
1. A 7-to-10-day course of appropriate oral antibiotics as prescribed by your clinician.
2. Warm compresses prior to feedings to assist drainage, with cool compresses post-feeding to reduce edema.
3. Continued, effective breast emptying to prevent abscess formation.
''',
    ),
    EducationArticle(
      id: 'art-calcifications',
      categoryKey: 'imaging',
      illustrationType: 'calcification',
      icon: Icons.grain_rounded,
      titleAr: 'التكلسات الدقيقة (Microcalcifications): قراءة نتائج الماموجرام',
      titleEn: 'Breast Microcalcifications: Mammography Reading & Evaluation',
      categoryAr: 'أشعة وفحوصات',
      categoryEn: 'Scans & Imaging',
      readTimeAr: '٥ دقائق قراءة',
      readTimeEn: '5 min read',
      doctorReviewerAr: 'إشراف: الفريق الاستشاري للأشعة التداخلية',
      doctorReviewerEn: 'Supervised by The Interventional Radiology Panel',
      summaryAr: 'ترسبات كالسيوم مجهرية تظهر كنقاط بيضاء في الماموجرام، معظمها حميد تماماً، والأنماط العنقودية تتطلب متابعة دقيقة.',
      summaryEn: 'Microscopic calcium deposits detected exclusively on digital mammography. Isolated specks are benign; clustered patterns require review.',
      problemLabelAr: 'المشكلة: تكلسات دقيقة مجمعة (Clustered Microcalcifications)',
      problemLabelEn: 'Finding: Clustered Microcalcifications on Mammogram',
      problemDetailAr: '• نقاط كالسيوم مجهرية بالغة الصغر تظهر كنقاط بيضاء دقيقة\n• غير ملموسة باليد إطلاقاً ولا تسبب أي ألم أو تغير بالجلد\n• الماموجرام الرقمي عالي الدقة هو الفحص الوحيد القادر على كشفها\n• المتباعدة منها حميدة ١٠٠٪، والمجمعة تستدعي تقييماً إشعاعياً دقيقاً',
      problemDetailEn: '• Tiny microscopic calcium specks appearing as bright white dots\n• Completely impalpable and entirely symptomless\n• Digital mammography is the sole modality possessing resolving power\n• Dispersed macrocalcifications are 100% benign; clusters warrant triage',
      fullContentAr: '''
ما هي تكلسات الثدي (Calcifications)؟
التكلسات هي ترسبات مجهرية صغيرة جداً من أملاح الكالسيوم داخل نسيج الثدي، لا يمكن الشعور بها باليد إطلاقاً ولا تسبب أي ألم، وتكتشف فقط أثناء إجراء أشعة الماموجرام الرقمية.

أنواع التكلسات في تقرير الأشعة:
١. التكلسات الكبيرة (Macrocalcifications):
نقاط بيضاء كبيرة مستديرة متباعدة، ناتجة عن تغيرات طبيعية بالعمر أو التهابات قديمة، وهي حميدة بنسبة ١٠٠٪ ولا تتطلب أي إجراء.

٢. التكلسات الدقيقة المجمعة (Clustered Microcalcifications):
نقاط بيضاء بالغة الصغر متقاربة كالعنقود. تحتاج لتقييم خبير الأشعة لتحديد ما إذا كانت تستدعي متابعة دورية بعد ٦ أشهر (BI-RADS 3) أو أخذ عينة نسيجية بسيطة موجهة بالأشعة (BI-RADS 4).

لماذا الماموجرام هو الفحص الوحيد القادر على كشفها؟
لأن أشعة الماموجرام الرقمية عالية التباين تمتلك قدرة تفريق ميكرومترية لا يستطيع السونار العادي التقاطها، ولذلك هو الفحص الأساسي المعياري للاطمئنان الدوري بعد سن الأربعين.
''',
      fullContentEn: '''
Understanding Breast Calcifications:
Breast calcifications are microscopic deposits of calcium salts within the breast parenchyma. They are completely painless, impalpable on manual exam, and identified solely through screening digital mammography.

Radiological Categories:
1. Macrocalcifications: Large, dispersed round specks associated with physiological aging or old arterial changes. 100% benign, requiring zero further testing.
2. Clustered Microcalcifications: Groups of tiny specks tightly situated along a terminal duct. Evaluated for morphology (amorphous, coarse, pleomorphic) to determine whether short-interval surveillance (BI-RADS 3) or stereotactic biopsy (BI-RADS 4) is appropriate.

Why Mammography is Mandatory:
Digital mammography provides micrometer-scale spatial resolution, resolving tiny calcifications that ultrasound cannot depict. This underpins why routine mammography remains the standard for women 40 and older.
''',
    ),
    EducationArticle(
      id: 'art-suspicious',
      categoryKey: 'warnings',
      illustrationType: 'suspicious',
      icon: Icons.warning_amber_rounded,
      titleAr: 'الكتل المشتبه بها وعلامات الإنذار السريري: متى تستشيرين الطبيب فوراً؟',
      titleEn: 'Suspicious Lumps & Clinical Warning Signs: When to Seek Immediate Care',
      categoryAr: 'علامات تحذيرية',
      categoryEn: 'Warning Signs',
      readTimeAr: '٥ دقائق قراءة',
      readTimeEn: '5 min read',
      doctorReviewerAr: 'إشراف: المجلس الطبي الإكلينيكي لشبكة لوميرا',
      doctorReviewerEn: 'Supervised by The Lumyra Clinical Advisory Council',
      summaryAr: 'كتلة صلبة غير متحركة، حواف غير منتظمة، انكماش في الجلد أو الحلمة، أو إفرازات دموية. علامات تستدعي الفحص السريري المباشر.',
      summaryEn: 'Firm fixed lump, irregular borders, skin tethering, nipple retraction, or spontaneous bloody discharge. Requires prompt in-person assessment.',
      problemLabelAr: 'المشكلة: كتلة صلبة غير منتظمة مشتبه بها (Spiculated Mass)',
      problemLabelEn: 'Finding: Irregular Spiculated Hypoechoic Mass',
      problemDetailAr: '• كتلة صلبة كالحجر غير متحركة بحرية تحت الجلد\n• حواف مسننة أو غير منتظمة (Spiculated / Microlobulated)\n• انكماش موضعي بالجلد أو انقلاب بالحلمة باتجاه الداخل\n• تستلزم تقييماً ثلاثياً فورياً (فحص سريري + أشعة مزدوجة + خزعة)',
      problemDetailEn: '• Hard, fixed, non-mobile mass tethered to surrounding tissue\n• Spiculated, angular, or microlobulated non-circumscribed margins\n• Localized skin dimpling or sudden nipple inversion\n• Requires immediate triple assessment (clinical exam, imaging, biopsy)',
      fullContentAr: '''
ما هي الخصائص السريرية للكتل المشتبه بها؟
الوعي بالعلامات التحذيرية يمنحكِ فرصة الكشف المبكر والشفاء التام بإذن الله. تشمل أهم المؤشرات التي تتطلب تقييماً سريرياً عاجلاً:

١. ملمس الكتلة وحركتها:
كتلة صلبة كالحجر، غير مؤلمة في الغالب، وملتصقة بالأنسجة المحيطة (غير متحركة بحرية تحت الجلد).

٢. حدود وشكل الكتلة:
في تقارير السونار والرنين، تظهر الكتلة بحواف مسننة أو متعرجة غير منتظمة (Spiculated / Microlobulated)، وتكون ذات محور رأسي (أطول من عرضها).

٣. تغيرات الجلد والحلمة:
• انغماس أو انقلاب حديث في الحلمة باتجاه الداخل.
• تنقير أو تجعد في جلد الثدي يشبه قشرة البرتقال (Peau d'orange).
• إفرازات حلمية دموية أو شفافة مائية تخرج تلقائياً من ثدي واحد ومن فتحة واحدة.

الإجراء الطبي الفوري المعتمد:
عند ملاحظة أي من هذه العلامات، يوصي بروتوكول لوميرا السريري بحجز استشارة فورية مع استشاري جراحة الأورام لإجراء تقييم ثلاثي متكامل (الفحص السريري، الأشعة المزدوجة، والخزعة النسيجية Core Biopsy).
''',
      fullContentEn: '''
Clinical Characteristics of Suspicious Lumps:
Early awareness provides the definitive advantage for prompt diagnosis and complete clinical resolution. Key high-priority warning signs include:

1. Consistency & Mobility:
A stony, hard lump that feels anchored or fixed to the chest wall or skin rather than gliding freely under palpation.

2. Sonographic Morphology:
Irregular, ill-defined, or spiculated margins with a "taller-than-wide" vertical orientation, marked hypoechogenicity, and posterior acoustic shadowing.

3. Epithelial & Nipple Changes:
• Recent, unexplained nipple retraction or inversion.
• Dermal dimpling or orange-peel texture (peau d'orange).
• Spontaneous, unilateral clear or bloody nipple discharge from a single orifice.

Actionable Medical Pathway:
If any of these findings are detected, Lumyra's clinical pathway directs immediate appointment scheduling with a breast surgical oncologist for the Gold Standard Triple Assessment: clinical examination, bilateral diagnostic imaging (mammogram + ultrasound), and ultrasound-guided core biopsy.
''',
    ),
    EducationArticle(
      id: 'art-1',
      categoryKey: 'self_exam',
      illustrationType: 'exam',
      icon: Icons.accessibility_new_rounded,
      titleAr: 'الفحص الذاتي الشهري للثدي: دليلكِ العملي خطوة بخطوة',
      titleEn: 'Monthly Breast Self-Exam: Your Step-by-Step Clinical Guide',
      categoryAr: 'فحص ذاتي',
      categoryEn: 'Self-Exam',
      readTimeAr: '٤ دقائق قراءة',
      readTimeEn: '4 min read',
      doctorReviewerAr: 'إشراف: د. نور الخالدي (استشاري جراحة الأورام)',
      doctorReviewerEn: 'Supervised by Dr. Noor Al-Khalidi',
      summaryAr: 'تعلمي التوقيت المثالي بعد انتهاء الدورة الشهرية بأسبوع، والخطوات الثلاث: أمام المرآة، أثناء الاستحمام، وأثناء الاستلقاء.',
      summaryEn: 'Learn the optimal timing (7 days post-menses) and the three phases: visual inspection, upright examination, and supine palpation.',
      problemLabelAr: 'خريطة الفحص الذاتي: تقسيم الأرباع ومسار اللمس الدائري',
      problemLabelEn: 'Self-Exam Grid: Quadrants & Systematic Palpation Circles',
      problemDetailAr: '• فحص بصري أمام المرآة مع رفع اليدين لملاحظة التماثل\n• تحسس كامل الأرباع الأربعة بواسطة بطون الأصابع الثلاثة\n• فحص منطقة الإبط وأعلى عظمة الترقوة لاكتشاف أي عقد ليمفاوية\n• إجراء الفحص شهرياً بانتظام يساعدكِ على معرفة طبيعة نسيجكِ المعتاد',
      problemDetailEn: '• Visual inspection before a mirror with arms raised for symmetry\n• Thorough coverage across all four quadrants with finger pads\n• Evaluation of the axillary tail and clavicle for lymph nodes\n• Monthly consistency establishes your baseline familiar texture',
      fullContentAr: '''
الخطوة الأولى: الفحص البصري أمام المرآة
قفي أمام المرآة وكتفاكِ مستقيمان ويداكِ على وركيكِ. لاحظي شكل الثديين وتماثلهما، وتأكدي من عدم وجود أي انبعاجات، احمرار، أو تغيرات في ملمس الجلد.

الخطوة الثانية: رفع الذراعين
ارفعي ذراعيكِ للأعلى وابحثي عن نفس التغيرات وتأكدي من عدم وجود أي إفرازات غير طبيعية من الحلمة.

الخطوة الثالثة: الفحص اليدوي
استخدمي باطن أصابع يدكِ الثلاثة بحركات دائرية خفيفة، ثم متوسطة، ثم عميقة لتغطية كامل منطقة الثدي والإبط.

ملاحظة هامة:
الفحص الذاتي يساعدكِ على معرفة طبيعة جسمكِ، ولا يغني عن فحص الماموجرام السنوي بعد سن الأربعين.
''',
      fullContentEn: '''
Phase 1: Mirror Visual Inspection
Stand facing the mirror with shoulders straight and hands firmly on hips. Inspect breast contour, bilateral symmetry, and check for dimpling, rash, or changes in skin contour.

Phase 2: Raised Arms Maneuver
Raise both arms overhead and inspect for symmetry shifts, skin tension, or any spontaneous nipple discharge.

Phase 3: Systematic Palpation
Using the pads of your three middle fingers, apply light, medium, and firm pressure in small concentric circular overlapping patterns across all quadrants and the underarm axillary area.

Important Reminder:
Self-examination builds vital bodily familiarity, complementing (never replacing) routine screening mammography after age 40.
''',
    ),
    EducationArticle(
      id: 'art-2',
      categoryKey: 'imaging',
      illustrationType: 'calcification',
      icon: Icons.biotech_rounded,
      titleAr: 'الفرق بين الماموجرام والسونار: متى يوصي الطبيب بكل منهما؟',
      titleEn: 'Mammography vs. Ultrasound: When Each Imaging Modality is Indicated',
      categoryAr: 'أشعة وفحوصات',
      categoryEn: 'Scans & Imaging',
      readTimeAr: '٥ دقائق قراءة',
      readTimeEn: '5 min read',
      doctorReviewerAr: 'إشراف: د. مريم القاضي (استشاري الأشعة التشخيصية)',
      doctorReviewerEn: 'Supervised by Dr. Mariam Al-Qadi',
      summaryAr: 'الماموجرام هو الفحص الذهبي المعتمد للكشف المبكر، بينما السونار (الموجات فوق الصوتية) مكمل مثالي لتقييم الأنسجة الكثيفة والكتل السائلة.',
      summaryEn: 'Digital mammogram is the gold standard for screening, while ultrasound excels at differentiating solid versus cystic masses in dense breasts.',
      problemLabelAr: 'المقارنة الإشعاعية: الماموجرام الرقمي مقابل الموجات الصوتية',
      problemLabelEn: 'Imaging Modalities: Digital Mammography vs. High-Res Ultrasound',
      problemDetailAr: '• الماموجرام يكشف التكلسات الدقيقة التي لا يراها السونار\n• السونار يحدد هل الكتلة مائية (كيس) أم صلبة ليفية دون أي إشعاع\n• الأنسجة الكثيفة لدى الشابات تستفيد قصوى من الدمج بينهما\n• كلاهما فحصان متكاملان يعززان دقة التشخيص السريري بنسبة تتجاوز 98%',
      problemDetailEn: '• Mammography identifies microcalcifications undetectable on ultrasound\n• Ultrasound determines fluid vs. solid architecture without radiation\n• Dense breast tissue in younger individuals benefits from joint review\n• Complementary modalities together elevate diagnostic precision above 98%',
      fullContentAr: '''
يعد الماموجرام الفحص الأساسي للكشف عن التكلسات الدقيقة التي لا يمكن الشعور بها باليد، ويوصى به سنوياً للسيدات فوق سن الأربعين.

أما الموجات فوق الصوتية (السونار) فتستخدم كفحص مكمل لتحديد ما إذا كانت الكتلة صلبة أو كيسية ممتلئة بسائل، وتعتبر مناسبة جداً للسيدات الأصغر سناً ذوات الأنسجة الثديية الكثيفة.
''',
      fullContentEn: '''
Digital Mammography is the proven primary screening modality capable of detecting subclinical microcalcifications years before they become palpable, recommended annually starting at age 40.

Breast Ultrasound utilizes high-frequency acoustic waves to characterize palpable lesions as cystic versus solid, serving as the essential companion modality for women with dense breast tissue.
''',
    ),
    EducationArticle(
      id: 'art-mastalgia',
      categoryKey: 'general',
      illustrationType: 'general',
      icon: Icons.health_and_safety_rounded,
      titleAr: 'ألم الثدي الدوري (Cyclical Mastalgia): هل يرتبط بالأورام؟',
      titleEn: 'Cyclical Breast Pain (Mastalgia): Causes, Reassurance & Relief',
      categoryAr: 'صحة عامة',
      categoryEn: 'General Health',
      readTimeAr: '٣ دقائق قراءة',
      readTimeEn: '3 min read',
      doctorReviewerAr: 'إشراف: د. نور الخالدي (استشاري جراحة الأورام)',
      doctorReviewerEn: 'Supervised by Dr. Noor Al-Khalidi',
      summaryAr: 'ألم الثدي ظاهرة فسيولوجية طبيعية جداً لدى أكثر من ٧٠٪ من السيدات، وأكثر من ٩٠٪ من حالات الألم لا ترتبط إطلاقاً بالأورام الخبيثة.',
      summaryEn: 'Breast pain is a normal physiological occurrence experienced by >70% of women. Over 90% of breast pain is completely unrelated to malignancy.',
      problemLabelAr: 'التشريح الفسيولوجي: التغيرات الهرمونية الدورية للأنسجة',
      problemLabelEn: 'Physiological Anatomy: Cyclic Hormonal Breast Tissue Response',
      problemDetailAr: '• احتقان نسيجي طبيعي يزداد قبل موعد الطمث بأيام\n• استجابة طبيعية للغدد الحليبية لارتفاع هرموني الإستروجين والبروجسترون\n• ألم الثدي المنفرد نادراً ما يكون علامة على ورم خبيث\n• ارتداء حمالة صدر داعمة ومريحة وتقليل الكافيين يهدئ الأعراض فوراً',
      problemDetailEn: '• Natural glandular swelling peaking 3-5 days before menstruation\n• Physiological lobular response to estrogen and progesterone shifts\n• Isolated breast pain is exceptionally rarely a sign of malignancy\n• Well-fitted supportive bras and caffeine moderation relieve discomfort',
      fullContentAr: '''
حقيقة سريرية مطمئنة:
أكثر من ٩٠٪ من حالات ألم الثدي ليست ناتجة عن أورام خبيثة إطلاقاً. الأورام السرطانية نادراً ما تسبب ألماً في مراحلها المبكرة.

أسباب ألم الثدي الشائعة:
١. الألم الدوري المرتبط بالطمث: ثقل واحتقان يزداد قبل موعد الدورة الشهرية بأيام نتيجة استجابة أنسجة الغدد اللبنية لارتفاع هرموني الإستروجين والبروجسترون.
٢. المنبهات والكافيين: الإكثار من الشاي والقهوة والمشروبات الغازية والشوكولاتة يرفع حساسية الأنسجة للألم.
٣. ارتداء حمالات صدر غير ملائمة الحجم أو داعمة بشكل غير مريح.
''',
      fullContentEn: '''
Reassuring Clinical Facts:
Over 90% of breast pain consultations represent benign, non-malignant conditions. Early breast malignancies exceptionally rarely manifest as localized pain.

Primary Underlying Causes:
1. Cyclic Mastalgia: Progesterone-driven tissue swelling and nodularity peaking in the late luteal phase prior to menstruation.
2. Dietary Factors: Elevated caffeine and sodium intake can increase glandular sensitivity.
3. Mechanical Stress: Improperly fitted or unsupportive underwire bras.
''',
    ),
    EducationArticle(
      id: 'art-nutrition',
      categoryKey: 'general',
      illustrationType: 'general',
      icon: Icons.restaurant_menu_rounded,
      titleAr: 'التغذية المضادة للالتهاب ونمط الحياة الداعم لصحة الثدي',
      titleEn: 'Anti-Inflammatory Nutrition & Lifestyle for Breast Wellness',
      categoryAr: 'صحة عامة',
      categoryEn: 'General Health',
      readTimeAr: '٣ دقائق قراءة',
      readTimeEn: '3 min read',
      doctorReviewerAr: 'إشراف: د. سارة عزمي (استشاري طب النساء)',
      doctorReviewerEn: 'Supervised by Dr. Sara Azmy',
      summaryAr: 'أهمية الخضروات الصليبية، أوميجا ٣، تقليل السكريات المصنعة، وممارسة المشي المنتظم لتعزيز المناعة وتوازن الهرمونات.',
      summaryEn: 'Cruciferous vegetables, omega-3 fatty acids, sugar moderation, and regular brisk walking to promote healthy hormonal balance.',
      problemLabelAr: 'التوازن الهرموني ونمط الحياة الوقائي',
      problemLabelEn: 'Hormonal Balance & Preventive Lifestyle Guidelines',
      problemDetailAr: '• تناول البروكلي والقرنبيط لدعم التخلص الطبيعي من الإستروجين الزائد\n• دهون أوميجا 3 الصحية في بذور الكتان والأسماك تقلل الالتهابات\n• المشي السريع 150 دقيقة أسبوعياً يحافظ على وزن مثالي وصحي\n• الحفاظ على فيتامين د ومستويات مضادات الأكسدة يدعم المناعة',
      problemDetailEn: '• Cruciferous greens support optimal physiological estrogen clearance\n• Omega-3 fatty acids reduce chronic systemic inflammation\n• 150 minutes of weekly aerobic activity maintains healthy body composition\n• Adequate Vitamin D and antioxidant intake bolster cellular health',
      fullContentAr: '''
الدراسات الإكلينيكية تؤكد أن اتباع نمط غذائي غني بمضادات الأكسدة والخضروات مثل البروكلي والقرنبيط، بالإضافة إلى بذور الكتان والمصادر الطبيعية لأوميجا ٣، يساهم في دعم المناعة والتوازن الهرموني الطبيعي.
''',
      fullContentEn: '''
Epidemiological evidence supports a nutrient-dense dietary pattern rich in cruciferous vegetables (broccoli, cauliflower), omega-3 fatty acids, and dietary fiber to encourage healthy estrogen metabolism and cellular health.
''',
    ),
    EducationArticle(
      id: 'art-fibrocystic',
      categoryKey: 'cysts',
      illustrationType: 'fibrocystic',
      icon: Icons.bubble_chart_rounded,
      titleAr: 'التغيرات الكيسية الليفية الشائعة (Fibrocystic Changes): طمأنة وفهم طبي',
      titleEn: 'Fibrocystic Breast Changes: Symptoms, Hormonal Links & Reassurance',
      categoryAr: 'أكياس وتغيرات حميدة',
      categoryEn: 'Benign Lumps & Changes',
      readTimeAr: '٥ دقائق قراءة',
      readTimeEn: '5 min read',
      doctorReviewerAr: 'إشراف: د. سارة عزمي (استشاري أمراض الثدي)',
      doctorReviewerEn: 'Supervised by Dr. Sara Azmy (Breast Health Specialist)',
      summaryAr: 'تغير فسيولوجي حميد يصيب أكثر من ٦٠٪ من السيدات في سن الإنجاب؛ عقد ليفية صغيرة وأكياس مائية دقيقة تتأثر بدورة الطمث.',
      summaryEn: 'A widespread physiological benign state affecting over 60% of reproductive-age women. Fibrous nodularity sensitive to hormonal cycles.',
      problemLabelAr: 'المشكلة: فرط تنسج ليفي وأكياس مائية دقيقة مجهرية',
      problemLabelEn: 'Finding: Fibrocystic Stroma with Microscopic Cysts',
      problemDetailAr: '• ملمس نسيجي متكتل ومحبب يشبه حبيبات البازلاء أو الحصى الصغير\n• ألم دوري وثقل يزداد وضوحاً في الأسبوع الذي يسبق الطمث\n• لا يمثل ورماً خبيثاً إطلاقاً ولا يرفع احتمال التحول الخبيث\n• يستجيب للكمادات الدافئة، تقليل الكافيين، وفيتامين E',
      problemDetailEn: '• Granular, cobblestone texture reminiscent of small peas\n• Cyclic mastalgia and fullness peaking before menstruation\n• Entirely benign with zero progression to malignant pathology\n• Relieved by warm compresses, caffeine reduction, and supportive bra',
      fullContentAr: '''
ما هي التغيرات الكيسية الليفية (Fibrocystic Breast Changes)؟
التغيرات الكيسية الليفية ليست مرضاً وإنما استجابة فسيولوجية طبيعية ومفرطة لأنسجة الثدي تجاه التغيرات الهرمونية الشهرية لهرموني الإستروجين والبروجسترون. تشير الدراسات إلى أن أكثر من ٦٠٪ إلى ٧٠٪ من النساء يمررن بهذه التغيرات في مرحلة ما بين سن العشرين والخمسين.

كيف تشعرين بها عند الفحص اليدوي؟
• ملمس محبب يشبه الحصى الصغير أو "رصف الحجارة" (Cobblestone) في الجزء العلوي الخارجي من الثديين معاً.
• ألم دوري واحتقان شديد يزداد في الأيام التي تسبق موعد الدورة الشهرية ويهدأ ملحوظاً بعد نزول الدم.
• تغير حجم وامتلاء التكتلات بين أسبوع وآخر وفق أيام الشهر.

كيف يؤكد الطبيب التشخيص؟
فحص السونار هو الفحص الأمثل، حيث يظهر تمازجاً متجانساً بين نسيج ليفي كثيف وأكياس مائية مجهرية دقيقة دون وجود كتل صلبة مريبة، ويصنف كـ BI-RADS 2 (حميد تماماً).

نصائح علاجية مثبتة علمياً لتخفيف الأعراض:
١. ارتداء حمالة صدر رياضية داعمة خالية من الأسلاك المعدنية (خصوصاً أثناء النوم وممارسة الرياضة).
٢. تقليل المنبهات والمشروبات الغازية والشوكولاتة المحتوية على الميثيل زانثين.
٣. مكملات فيتامين E وزيت زهرة الربيع المسائية (Evening Primrose Oil) بعد استشارة طبيبكِ.
''',
      fullContentEn: '''
Understanding Fibrocystic Breast Changes:
Fibrocystic changes are not a pathological disease, but a benign physiological exaggeration of normal breast tissue remodeling in response to fluctuating ovarian hormones (estrogen and progesterone). Over 60% of women encounter this phenomenon during reproductive years.

Clinical Presentation:
• Distinct bilateral "cobblestone" or nodular texture, commonly in the upper-outer quadrants.
• Cyclic mastalgia, soreness, and bilateral swelling in the luteal phase preceding menses.
• Spontaneous softening of lumps immediately following the menstrual period.

Diagnostic Confirmation:
Sonography confirms dense fibroglandular stroma peppered with microscopic simple cysts, devoid of focal invasive architecture (BI-RADS 2).

Evidence-Based Relief:
1. Well-fitted supportive bra without underwires.
2. Moderation of caffeine, sodium, and methylxanthine-rich foods.
3. Vitamin E and evening primrose oil supplementation under medical guidance.
''',
    ),
    EducationArticle(
      id: 'art-papilloma',
      categoryKey: 'warnings',
      illustrationType: 'papilloma',
      icon: Icons.water_damage_rounded,
      titleAr: 'الورم الحليمي داخل القنوات (Intraductal Papilloma) وإفرازات الحلمة',
      titleEn: 'Intraductal Papilloma: Causes, Nipple Discharge & Management',
      categoryAr: 'إفرازات الحلمة',
      categoryEn: 'Nipple Discharge',
      readTimeAr: '٤ دقائق قراءة',
      readTimeEn: '4 min read',
      doctorReviewerAr: 'إشراف: د. نور الخالدي (استشاري جراحة الأورام)',
      doctorReviewerEn: 'Supervised by Dr. Noor Al-Khalidi (Surgical Oncologist)',
      summaryAr: 'ورم لحمي حميد ينمو داخل مجرى القناة اللبنية قرب الحلمة، السبب الأشهر للإفرازات الدموية أو المائية النقية من ثدي واحد.',
      summaryEn: 'A benign polypoid lesion growing inside a main subareolar milk duct; the leading cause of unilateral bloody or clear serous nipple discharge.',
      problemLabelAr: 'المشكلة: زوائد حليمية لحمية داخل جدار القناة اللبنية',
      problemLabelEn: 'Finding: Intraductal Polyp in Subareolar Lactiferous Duct',
      problemDetailAr: '• إفرازات مائية نقية أو مشوبة بالدم تخرج تلقائياً من فتحة واحدة بالحلمة\n• ورم حميد ينمو داخل بطانة القناة اللبنية ولا يعتبر سرطاناً\n• السونار عالي الدقة يظهر تمدد القناة اللبنية مع وجود نتوء بداخلها\n• يُعالج باستئصال جراحي دقيق للقناة المصابة (Microdochectomy)',
      problemDetailEn: '• Spontaneous unilateral serous or serosanguinous nipple discharge\n• Benign epithelial polypoid arborization within duct lumen\n• High-resolution sonography demonstrates duct ectasia with endoluminal mass\n• Definitive cure achieved via targeted microdochectomy',
      fullContentAr: '''
ما هو الورم الحليمي داخل القناة (Intraductal Papilloma)؟
هو ورم حميد يشبه حبة التوت أو الثالول الصغير، ينمو على البطانة الداخلية للقنوات اللبنية الكبيرة الواقعة مباشرة خلف الحلمة والهالة (Subareolar ducts).

الأعراض المميزة:
• إفرازات حلمية تلقائية مستمرة من ثدي واحد ومن ثقب محدد (Single duct orifice).
• لون الإفرازات قد يكون شفافاً مائياً، أو وردياً، أو دموياً صريحاً (نتيجة هشاشة الأوعية الدموية المغذية للورم الحليمي).
• في أغلب الحالات لا توجد كتلة ملموسة باليد، ويكتشف الورم بسبب خروج الإفرازات على الملابس الداخلية.

الفحوصات المطلوبة:
١. السونار الموجه عالي التردد لمنطقة تحت الحلمة (Subareolar Ultrasound).
٢. فحص الخلايا للإفرازات (Discharge Cytology).
٣. أشعة قنوات الحليب التباينية أو الرنين المغناطيسي في الحالات الدقيقة.

طريقة العلاج:
العلاج الذهبي هو جراحة تجميلية صغرى تسمى استئصال القناة المصابة (Microdochectomy) من خلال شق نصف دائري دقيق على حافة الهالة؛ يتم استئصال القناة مع الورم الحليمي وتشفى المنطقة تماماً دون أي تشوه في شكل الثدي.
''',
      fullContentEn: '''
What is an Intraductal Papilloma?
A benign, wart-like growth of glandular tissue, fibrovascular tissue, and blood vessels inside the lumen of the main lactiferous ducts beneath the areola.

Clinical Hallmark:
• Spontaneous, persistent unilateral nipple discharge originating from a single duct orifice.
• Discharge is classically serous (clear watery) or bloody (serosanguinous) due to mechanical twisting of the delicate vascular stalk.
• Usually impalpable on routine breast examination.

Diagnostic Pathway:
1. High-frequency subareolar ultrasound to visualize the dilated duct and intraductal nodule.
2. Fluid cytology analysis.
3. Ductography or dynamic contrast-enhanced MRI if ultrasound is equivocal.

Definitive Treatment:
Microdochectomy (targeted surgical excision of the involved single duct via a circumareolar cosmetic incision) is curative and provides histological confirmation.
''',
    ),
    EducationArticle(
      id: 'art-fat-necrosis',
      categoryKey: 'cysts',
      illustrationType: 'fat_necrosis',
      icon: Icons.shield_rounded,
      titleAr: 'النخر الدهني والتكلسات الزيتية (Fat Necrosis & Oil Cysts): بعد الكدمات',
      titleEn: 'Fat Necrosis & Oil Cysts: Trauma, Biopsy & Healing Changes',
      categoryAr: 'كتل وتغيرات حميدة',
      categoryEn: 'Benign Lumps',
      readTimeAr: '٤ دقائق قراءة',
      readTimeEn: '4 min read',
      doctorReviewerAr: 'إشراف: د. مريم القاضي (استشاري الأشعة التشخيصية)',
      doctorReviewerEn: 'Supervised by Dr. Mariam Al-Qadi (Consultant Diagnostic Radiologist)',
      summaryAr: 'تغير حميد يحدث في الخلايا الدهنية بعد التعرض لخبطة، كدمة حزام الأمان، أو عملية جراحية سابقة؛ يتحول إلى كيس زيتي آمن تماماً.',
      summaryEn: 'Benign aseptic lipid degeneration following blunt trauma (e.g. seatbelt injury) or breast surgery, forming a safe lipid cavity.',
      problemLabelAr: 'المشكلة: تحلل دهني موضعي مع تكلس دائري (Eggshell Rim)',
      problemLabelEn: 'Finding: Benign Lipid Cavity with Eggshell Calcification',
      problemDetailAr: '• كتلة صلبة غير مؤلمة تظهر في موقع كدمة أو جراحة سابقة\n• تحلل سليم للخلايا الشحمية وتجمع خلايا البلعمة (Histiocytes)\n• الماموجرام يظهر تكلسات دائرية شبيهة بقشرة البيض (Eggshell rim)\n• حالة حميدة ١٠٠٪ ولا تتطلب استئصالاً جراحياً بمجرد تأكيد الأشعة',
      problemDetailEn: '• Firm, painless lump developing at the site of trauma or surgery\n• Non-enzymatic fat saponification with histiocytic lipid storage\n• Mammography reveals classic lucent oil cyst with eggshell peripheral calcification\n• 100% benign, requiring non-operative observation once verified',
      fullContentAr: '''
ما هو النخر الدهني (Fat Necrosis)؟
الثدي يحتوي على كميات كبيرة من الأنسجة الدهنية الحساسة. عند التعرض لصدمة مباشرة (مثل حزام الأمان في حادث سيارة)، أو كدمة قوية، أو إجراء خزعة نسيجية سابقة أو عملية جراحية، قد تموت بعض الخلايا الدهنية موضعياً ويقوم الجسم بهضمها وتحويلها إلى كيس زيتي (Oil Cyst).

كيف تظهر؟
• قد تشعر السيدة بوجود كتلة صلبة مستديرة غير مؤلمة في مكان الكدمة القديمة.
• أحياناً قد يحدث سحب خفيف في الجلد المحيط بسبب التليف، مما قد يقلق المريضة.

المظهر الإشعاعي الحاسم:
• في الماموجرام: يظهر الكيس الزيتي كفراغ شفاف محاط بجدار كلسي دائري رقيق جداً يشبه "قشرة البيضة" (Eggshell calcification). هذا المظهر قاطع ويؤكد بنسبة ١٠٠٪ أنه نخر دهني حميد تماماً (BI-RADS 2).
• في السونار: يظهر كيس ذو انعكاسات زيتية مميزة دون تدفق دموي.

هل يحتاج لعلاج؟
لا يحتاج النخر الدهني لأي علاج جراحي أو دوائي؛ فالجسم يقوم بامتصاصه وإحاطته بتكلس آمن مع مرور الوقت.
''',
      fullContentEn: '''
Understanding Fat Necrosis:
Breast parenchyma contains abundant adipose tissue. When exposed to blunt trauma (e.g., seatbelt impact), core needle biopsy, or prior breast surgery, injured adipocytes undergo aseptic lipid breakdown and saponification, forming a benign oil cyst.

Clinical Features:
• Discrete, firm, non-tender lump situated at the site of prior trauma.
• May occasionally produce localized skin tethering mimicking a neoplasm on palpation.

Radiological Confirmation:
• Mammography: Demonstrates classic fat-density radiolucent oil cyst with smooth peripheral "eggshell" calcification (BI-RADS 2).
• Ultrasound: Fluid-debris levels or complex cystic mass with zero internal vascularity.

Clinical Management:
Once benign radiological criteria are satisfied, observation is standard. Surgical excision is avoided to prevent further traumatic necrosis.
''',
    ),
    EducationArticle(
      id: 'art-phyllodes',
      categoryKey: 'warnings',
      illustrationType: 'phyllodes',
      icon: Icons.spa_rounded,
      titleAr: 'أورام فيلوديس الورقية (Phyllodes Tumors): الفروق والعلاج الجراحي',
      titleEn: 'Phyllodes Tumors of the Breast: Diagnosis, Margins & Surgery',
      categoryAr: 'أورام وأنسجة خاصة',
      categoryEn: 'Special Lesions',
      readTimeAr: '٥ دقائق قراءة',
      readTimeEn: '5 min read',
      doctorReviewerAr: 'إشراف: د. نور الخالدي (استشاري جراحة الأورام)',
      doctorReviewerEn: 'Supervised by Dr. Noor Al-Khalidi (Surgical Oncologist)',
      summaryAr: 'أورام ليفية سريعة النمو تتشابه في البداية مع الورم الليفي لكنها تتميز بنمو أسرع وتتطلب استئصالاً جراحياً بحواف أمان واسعة.',
      summaryEn: 'Fast-growing biphasic fibroepithelial lesions requiring wide local excision with clear surgical margins to prevent recurrence.',
      problemLabelAr: 'المشكلة: ورم ليفي سدوي ذو معمارية ورقية سريعة التمدد',
      problemLabelEn: 'Finding: Leaf-Like Biphasic Stromal Proliferation',
      problemDetailAr: '• زيادة ملحوظة وسريعة في حجم الكتلة خلال أسابيع أو شهور قليلة\n• مظهر ورقي مورّق مجهرياً (Leaf-like architecture)\n• تنقسم نسيجياً إلى حميدة (Benign)، بينية (Borderline)، وخبيثة\n• تستلزم جراحة استئصال بحافة أمان لا تقل عن ١ سم لتجنب عودتها',
      problemDetailEn: '• Rapid expansion in lump dimensions over a short timeframe\n• Microscopic leaf-like architecture with hypercellular stroma\n• Stratified as benign (most common), borderline, or malignant\n• Requires wide local excision with ≥1 cm negative surgical margins',
      fullContentAr: '''
ما هو ورم فيلوديس (Phyllodes Tumor)؟
ورم فيلوديس هو ورم ليفي غدي نادر ينشأ من النسيج الضام (السدى) للثدي. استمد اسمه اللاتيني من كلمة "ورقة شجر" لأن خلاياه تترتب تحت المجهر في طبقات تشبه أوراق الشجر.

كيف تفرقينه عن الورم الليفي العادي (Fibroadenoma)؟
• الورم الليفي العادي ينمو ببطء شديد أو يتوقف حجمه عند ٢-٣ سم.
• ورم فيلوديس يتميز بنمو متسارع؛ حيث قد يتضاعف حجمه خلال أسابيع أو شهور قليلة ليصل إلى ٤ أو ٦ سم أو أكثر.
• يصيب غالباً السيدات بعد سن الأربعين (على عكس الورم الليفي الذي يكثر في العشرينات).

التصنيف النسيجي:
معظم أورام فيلوديس (أكثر من ٧٠٪) حميدة تماماً (Benign)، ونسبة قليلة قد تكون بينية (Borderline) أو خبيثة موضعياً (Malignant).

بروتوكول العلاج المعتمد:
العلاج الأساسي هو الاستئصال الجراحي الموضعي الواسع (Wide Local Excision) مع أخذ حافة أمان صحية لا تقل عن ١ سم من الأنسجة السليمة المحيطة لمنع ارتداده الموضعي. نادراً جداً ما ينتشر إلى الغدد الليمفاوية، ولذلك لا يحتاج لاستئصال الغدد الإبطية.
''',
      fullContentEn: '''
What is a Phyllodes Tumor?
Phyllodes tumors are rare biphasic fibroepithelial neoplasms originating from periductal stromal tissue. The name derives from the Greek word for "leaf," referring to microscopic cleft-like papillary projections.

Distinction from Conventional Fibroadenoma:
• Fast, progressive enlargement spanning weeks to months, frequently reaching 4–8 cm.
• Peak incidence in perimenopausal women (aged 40–50), whereas fibroadenomas predominate under age 30.

Histological Stratification:
• Benign (approximately 60–70% of cases)
• Borderline
• Malignant

Definitive Surgical Management:
Wide local excision with an anatomical margin of at least 1 cm of surrounding normal tissue is mandatory. Axillary lymph node dissection is rarely indicated due to the predominant hematogenous rather than lymphatic metastatic pathway.
''',
    ),
    EducationArticle(
      id: 'art-dcis',
      categoryKey: 'warnings',
      illustrationType: 'dcis',
      icon: Icons.shield_outlined,
      titleAr: 'سرطان القنوات الموضعي (DCIS): المرحلة الصفرية ونسبة الشفاء التام',
      titleEn: 'Ductal Carcinoma In Situ (DCIS): Stage 0 Detection & Cure',
      categoryAr: 'المرحلة الصفرية',
      categoryEn: 'Stage 0 Care',
      readTimeAr: '٥ دقائق قراءة',
      readTimeEn: '5 min read',
      doctorReviewerAr: 'إشراف: المجلس الطبي للأورام - شبكة لوميرا',
      doctorReviewerEn: 'Supervised by The Lumyra Oncology Advisory Board',
      summaryAr: 'خلايا غير نمطية محصورة كلياً داخل القنوات اللبنية دون أي اختراق أو انتشار، نسبة الشفاء تتجاوز ٩٨٪ مع الجراحة التحفظية.',
      summaryEn: 'Stage 0 non-invasive lesion confined within milk ducts. Cure rates exceed 98% with modern breast-conserving surgery and radiotherapy.',
      problemLabelAr: 'المشكلة: خلايا قنوية غير نمطية محصورة كلياً داخل الغشاء القاعدي',
      problemLabelEn: 'Finding: Non-Invasive Malignant Proliferation within Duct Lumen',
      problemDetailAr: '• مرحلة صفرية غير غازية (Non-Invasive Stage 0)\n• تكلسات دقيقة متجمعة تكتشف بالماموجرام قبل وجود أي كتلة\n• الغشاء القاعدي للقناة سليم بنسبة 100% يمنع وصول الخلايا للأوعية\n• نسبة الشفاء التام تتجاوز 98-99% عند الالتزام بالخطة العلاجية',
      problemDetailEn: '• Non-invasive Stage 0 neoplasia with intact basement membrane\n• Asymptomatic microcalcification clusters picked up on screening\n• Inability to spread to lymph nodes or distant organs in in-situ phase\n• Exceptional long-term cure rates (>98%) following therapy',
      fullContentAr: '''
ما هو سرطان القنوات الموضعي (DCIS)؟
سرطان القنوات الموضعي (Ductal Carcinoma In Situ) يصنف كـ "المرحلة الصفرية" (Stage 0). وهو يعني وجود خلايا غير نمطية تكاثرت داخل القناة اللبنية، لكنها ظلت محبوسة كلياً داخل الغشاء القاعدي للقناة (Basement Membrane) ولم تخترق نسيج الثدي أو تصل للأوعية الدموية أو الليمفاوية.

لماذا يعتبر اكتشافه إنجازاً طبياً كبيراً؟
لأنه في هذه المرحلة المبكرة جداً، نسبة الشفاء التام تتجاوز ٩٨٪ إلى ٩٩٪ بإذن الله. وهو لا ينتشر خارج الثدي إطلاقاً طالما لم يخترق الغشاء.

كيف يُكتشف؟
في أكثر من ٩٠٪ من الحالات، لا تشعر السيدة بأي كتلة أو ألم، ويكتشف حصرياً أثناء فحص الماموجرام الروتيني كتكلسات دقيقة متجمعة (Clustered Pleomorphic Microcalcifications).

الخطة العلاجية المعتمدة عالمياً:
١. استئصال جراحي تحفظي للورم (Lumpectomy) مع حافة أمان نظيفة.
٢. جلسات علاج إشعاعي وقائي موضعي على الثدي لحماية باقي الأنسجة.
٣. علاج هرموني وقائي بالأقراص لمدة ٥ سنوات إذا كانت الخلايا إيجابية لمستقبلات الإستروجين (ER+).
''',
      fullContentEn: '''
Understanding Ductal Carcinoma In Situ (DCIS):
DCIS represents non-invasive Stage 0 breast disease. Neoplastic epithelial cells proliferate inside the mammary ducts without penetrating the surrounding basement membrane into surrounding stroma or vasculature.

Prognostic Significance:
Because cells cannot access lymphatic or hematogenous channels while confined, DCIS carries an outstanding overall survival rate exceeding 98–99%.

Screening Detection:
Over 90% of DCIS cases are clinically silent (no palpable mass) and are detected as fine pleomorphic microcalcifications on screening digital mammography.

Standard Clinical Guidelines:
1. Breast-conserving lumpectomy achieving clear microscopic margins.
2. Adjuvant whole-breast radiotherapy to minimize recurrence risk.
3. Adjuvant endocrine therapy (Tamoxifen or Aromatase Inhibitors) for estrogen receptor-positive disease.
''',
    ),
    EducationArticle(
      id: 'art-tnbc',
      categoryKey: 'warnings',
      illustrationType: 'suspicious',
      icon: Icons.biotech_rounded,
      titleAr: 'سرطان الثدي ثلاثي السلبية (TNBC): أحدث العلاجات المناعية',
      titleEn: 'Triple-Negative Breast Cancer (TNBC): Immunotherapy Breakthroughs',
      categoryAr: 'علاجات حديثة',
      categoryEn: 'Oncology Advances',
      readTimeAr: '٦ دقائق قراءة',
      readTimeEn: '6 min read',
      doctorReviewerAr: 'إشراف: استشاري علاج الأورام والطب الدقيق',
      doctorReviewerEn: 'Supervised by The Precision Oncology Clinical Board',
      summaryAr: 'نوع محدد لا يمتلك مستقبلات هرمونية ولا HER2، حقق الطب الحديث فيه طفرات علاجية هائلة باستخدام العلاج المناعي ومثبطات PARP.',
      summaryEn: 'Subtype lacking ER, PR, and HER2 receptors. Modern oncology has achieved paradigm shifts with immunotherapy (Pembrolizumab) and PARP inhibitors.',
      problemLabelAr: 'المشكلة: سرطان ثدي سلبي لمستقبلات الإستروجين والبروجسترون وHER2',
      problemLabelEn: 'Finding: Triple-Negative Receptor Profile (ER-, PR-, HER2-)',
      problemDetailAr: '• غياب مستقبلات ER و PR و HER2 في فحص الصبغات المناعية (IHC)\n• ارتباط وراثي محتمل بطفرات جين BRCA1 يستدعي الفحص الجيني\n• استجابة قوية جداً للعلاج الكيماوي المناعي الموجه قبل الجراحة\n• العلاجات المناعية الحديثة (مثل كيميرودا) رفعت نسب الشفاء بشكل غير مسبوق',
      problemDetailEn: '• Absence of Estrogen, Progesterone, and HER2 receptors on IHC\n• Frequent association with germline BRCA1 mutations\n• Exceptional tumor response to neoadjuvant chemo-immunotherapy\n• Modern checkpoint inhibitors (e.g., Keytruda) have transformed clinical outcomes',
      fullContentAr: '''
ما هو سرطان الثدي ثلاثي السلبية (TNBC)؟
عند فحص عينة الورم تحت المجهر مع الصبغات المناعية (Immunohistochemistry)، يقوم الطبيب بالبحث عن ٣ مستقبلات هامة:
١. مستقبلات هرمون الإستروجين (ER)
٢. مستقبلات هرمون البروجسترون (PR)
٣. بروتين مستقبل عامل نمو البشرة (HER2)

عندما تكون هذه المستقبلات الثلاثة سلبية، يسمى الورم "ثلاثي السلبية". ويمثل حوالي ١٠٪ إلى ١٥٪ من حالات سرطان الثدي.

الطفرة العلاجية الحديثة:
في السنوات القليلة الماضية، أحدثت أدوية العلاج المناعي (Immunotherapy) مثل بيمبروليزوماب (Keytruda) ثورة طبية حقيقية؛ حيث تقوم هذه الأدوية بتنشيط خلايا المناعة الذاتية للمريضة للتعرف على الخلايا الورمية وتدميرها بكفاءة عالية.

بروتوكول العلاج المعاصر:
• علاج كيماوي مناعي استباقي قبل الجراحة (Neoadjuvant Therapy): يؤدي في أغلب الحالات إلى ذوبان واختفاء الورم كلياً قبل موعد العملية الجراحية (Pathologic Complete Response).
• الفحص الجيني لجينات BRCA1 و BRCA2 لتحديد ما إذا كانت السيدة مرشحة لاستخدام مثبطات PARP الذكية مثل الأولاباريب.
''',
      fullContentEn: '''
Defining Triple-Negative Breast Cancer (TNBC):
Standard pathological immunohistochemistry tests for three biomarkers:
1. Estrogen Receptor (ER)
2. Progesterone Receptor (PR)
3. Human Epidermal Growth Factor Receptor 2 (HER2)

Tumors testing negative for all three markers are classified as Triple-Negative (TNBC), accounting for approximately 10–15% of breast malignancies.

Immunotherapy Revolution:
Checkpoint inhibitors targeting PD-1 (notably Pembrolizumab) have revolutionized systemic management by training the patient's own cytotoxic T-cells to identify and eliminate tumor cells.

Modern Standard of Care:
• Neoadjuvant chemo-immunotherapy: Administered prior to surgery to maximize pathologic complete response (pCR).
• Genetic sequencing for germline BRCA1/2 variants to evaluate eligibility for targeted PARP inhibitors (e.g., Olaparib).
''',
    ),
    EducationArticle(
      id: 'art-paget',
      categoryKey: 'warnings',
      illustrationType: 'suspicious',
      icon: Icons.warning_rounded,
      titleAr: 'مرض باجيت في الحلمة (Paget’s Disease): الفروق عن الإكزيما السطحية',
      titleEn: 'Paget’s Disease of the Nipple: Differentiating from Eczema',
      categoryAr: 'علامات تحذيرية',
      categoryEn: 'Warning Signs',
      readTimeAr: '٤ دقائق قراءة',
      readTimeEn: '4 min read',
      doctorReviewerAr: 'إشراف: استشاري جراحة الأورام والجلدية التخصصية',
      doctorReviewerEn: 'Supervised by The Cutaneous Oncology Surgical Panel',
      summaryAr: 'تغيرات جلدية تشبه الإكزيما (قشور، تقرح، احمرار) في حلمة واحدة لا تستجيب لكريمات الكورتيزون، تستوجب أخذ خزعة من جلد الحلمة.',
      summaryEn: 'Eczema-like crusted scaling and erosion localized to a single nipple unresponsive to topical creams; requires full-thickness punch biopsy.',
      problemLabelAr: 'المشكلة: تقشر وتآكل جلدي مستمر بالحلمة مع وجود خلايا باجيت',
      problemLabelEn: 'Finding: Persistent Nipple Erosion & Infiltration by Paget Cells',
      problemDetailAr: '• احمرار وتقشر سطحي يبدأ في الحلمة ثم يمتد لاحقاً إلى الهالة\n• يختلف عن إكزيما الجلد العادية بأنه يصيب ثدياً واحداً فقط ولا يزول بالكريمات\n• يرتبط بوجود ورم قنوي موضعي (DCIS) كامن في القنوات اللبنية تحته\n• الخزعة الجلدية السطحية (Punch Biopsy) تؤكد التشخيص بدقة متناهية',
      problemDetailEn: '• Erythematous scaling beginning on nipple and spreading to areola\n• Distinct from classic eczema: strictly unilateral and steroid-resistant\n• Strongly associated with underlying in-situ or invasive ductal lesion\n• Confirmed via straightforward full-thickness dermal punch biopsy',
      fullContentAr: '''
ما هو مرض باجيت في حلمة الثدي (Paget's Disease of the Nipple)؟
مرض باجيت هو حالة نادرة تنشأ فيها خلايا غير نمطية في بطانة القنوات اللبنية وتهاجر صعوداً عبر مجرى الحليب لتصل إلى الطبقة السطحية من جلد الحلمة.

كيف تفرقينه عن الإكزيما وحساسية الجلد العادية؟
١. التوزيع: إكزيما الجلد تصيب عادة الثديين معاً أو تكون مصحوبة بإكزيما في مناطق أخرى بالجسم؛ بينما مرض باجيت يصيب حلمة واحدة فقط (Unilateral).
٢. نقطة البداية: يبدأ مرض باجيت دائماً في الحلمة نفسها أولاً ثم قد ينتشر ببطء إلى الهالة المحيطة بها، بينما الإكزيما تبدأ غالباً في الهالة.
٣. الاستجابة للعلاج: الإكزيما تختفي بسرعة مع استخدام كريمات الترطيب أو الكورتيزون، أما مرض باجيت فلا يستجيب مطلقاً وتستمر القشور والتقرح.

ما هو الإجراء الطبي الواجب؟
إذا لاحظتِ وجود قشور أو نزيف خفيف أو تقرح في الحلمة استمر لأكثر من أسبوعين دون استجابة للكريمات، يجب زيارة استشاري جراحة الأورام فوراً لإجراء خزعة جلدية دقيقة (Punch Biopsy) وفحص بالماموجرام والسونار للتأكد من سلامة القنوات الكامنة تحت الحلمة.
''',
      fullContentEn: '''
What is Paget's Disease of the Nipple?
A rare cutaneous manifestation wherein ductal neoplastic cells migrate via lactiferous sinuses to infiltrate the epidermal layer of the nipple-areolar complex.

Key Diagnostic Distinctions from Benign Eczema:
1. Symmetry: Classic contact dermatitis is typically bilateral, whereas Paget's disease is strictly unilateral.
2. Anatomical Onset: Paget's originates on the nipple apex before extending outward to the areola; eczema predominantly affects the areola initially with nipple sparing.
3. Therapeutic Response: Paget's lesions are completely refractory to topical corticosteroid therapy.

Recommended Clinical Action:
Any unilateral nipple scaling or ulceration persisting beyond two weeks warrants immediate referral for full-thickness dermal punch biopsy alongside bilateral diagnostic mammography.
''',
    ),
  ];

  static const List<SurvivorStory> _presetSurvivorStories = [
    SurvivorStory(
      id: 'surv-mona',
      nameAr: 'أ. منى زكي',
      nameEn: 'Mona Zaki',
      ageCityAr: '٤٨ سنة • المعادي، القاهرة',
      ageCityEn: '48 years • Maadi, Cairo',
      remissionYearsAr: 'تعافٍ تام ومستمر منذ ٤ سنوات 🌸',
      remissionYearsEn: '4 Years Full Remission 🌸',
      stageAr: 'اكتشاف مبكر أثناء الماموجرام الروتيني (المرحلة الأولى T1N0M0)',
      stageEn: 'Early Detection via Routine Mammography (Stage 1)',
      quoteAr: '"الفحص المبكر كان طوق نجاتي.. ما تخافيش من الفحص، خافي من التأجيل!"',
      quoteEn: '"Early screening was my lifeline.. Don\'t fear the scan, fear delaying it!"',
      journeyAr: 'في عام ٢٠٢٢ قمت بعمل فحص الماموجرام السنوي بعد سن الأربعين بدون وجود أي أعراض أو ألم، وظهرت بؤرة متناهية الصغر (١.٢ سم). الطبيب طمأنني وأجرينا جراحة تحفظية بسيطة مع علاج هرموني وقائي. اليوم أعيش حياتي بكامل طاقتي مع أسرتي وأحفادي.',
      journeyEn: 'In 2022, I completed routine mammography after age 40 with zero symptoms or pain. A tiny 1.2 cm focus was caught. My surgical team was deeply reassuring; we completed breast-conserving surgery and adjuvant therapy. Today I enjoy full health with my family.',
      adviceAr: 'نصيحتي لكل سيدة: الماموجرام السنوي مش رفاهية، ده أمانك وسندك.. خدي خطوة وافحصي النهاردة.',
      adviceEn: 'My advice to every woman: Annual screening is peace of mind and protection. Take the initiative today.',
      durationSeconds: 38,
    ),
    SurvivorStory(
      id: 'surv-samar',
      nameAr: 'م. سمر عبد العزيز',
      nameEn: 'Samar Abdelaziz',
      ageCityAr: '٣٩ سنة • سموحة، الإسكندرية',
      ageCityEn: '39 years • Alexandria',
      remissionYearsAr: 'تعافٍ تام منذ سنتين ونصف 🌸',
      remissionYearsEn: '2.5 Years Cancer-Free 🌸',
      stageAr: 'ورم غدي في القنوات اللبنية (المرحلة الثانية - استجابة كاملة للعلاج)',
      stageEn: 'Invasive Ductal Carcinoma (Stage 2 - Full Response)',
      quoteAr: '"كنت مرعوبة من كلمة كيماوي.. لكن بفضل الله ودعم بنتي وفريقي الطبي عديت الصعب ورجعت أقوى."',
      quoteEn: '"I was terrified of the word chemotherapy.. but with faith, family support, and medical care, I overcame it."',
      journeyAr: 'اكتشفت كتلة صغيرة أثناء الاستحمام، وبنتي شجعتني أروح أكشف فوراً. مرحلة العلاج كانت محتاجة صبر ويقين، والدعم النفسي وفويسات بنتي اليومية خلتني أعدي التحدي وأرجع لشغلي وأولادي بروح جديدة.',
      journeyEn: 'I noticed a small palpable nodule during my shower, and my daughter urged me to consult a specialist right away. The journey taught me resilience; daily encouragement from my family was instrumental in crossing the finish line.',
      adviceAr: 'خلي في حياتك رفيق رحلة من عيلتك يشاركك مواعيدك ويسمعك، الدعم النفسي بيشفي نصف المرض.',
      adviceEn: 'Keep a family companion beside you to share clinic visits; psychological reassurance is half the cure.',
      durationSeconds: 44,
    ),
    SurvivorStory(
      id: 'surv-hala',
      nameAr: 'د. هالة منصور',
      nameEn: 'Dr. Hala Mansour',
      ageCityAr: '٥٢ سنة • طنطا، الغربية',
      ageCityEn: '52 years • Tanta, Gharbia',
      remissionYearsAr: 'تعافٍ واطمئنان مستمر منذ ٥ سنوات 🌸',
      remissionYearsEn: '5 Years Full Health 🌸',
      stageAr: 'تغيرات نسيجية عالية الحذر مع ورم ليفي نشط - علاج تحفظي وقائي',
      stageEn: 'Atypical Proliferation & Fibroadenoma - Preventive Management',
      quoteAr: '"السرطان اليوم مش نهاية الطريق.. ده مجرد محطة بنعديها بالعلم والوعي والإرادة."',
      quoteEn: '"Cancer is no longer the end of the road; it is a hurdle conquered with science and awareness."',
      journeyAr: 'المتابعة الدورية كانت رفيقتي. لما ظهرت تغيرات في السونار والماموجرام أخذنا القرار الصحيح في التوقيت المناسب. العلم تقدم جداً وتوفر العلاجات الحديثة جعل نسب الشفاء تتجاوز ٩٥٪ في الحالات المبكرة.',
      journeyEn: 'Routine follow-ups were my shield. When ultrasound showed architectural changes, we acted in the golden hour. Modern oncology advances now yield cure rates exceeding 95% for early presentations.',
      adviceAr: 'ما تسمعيش للخرافات ولا للخلطات.. ثقي في طبيبك المتخصص والتزمي بالأدوية والمتابعة.',
      adviceEn: 'Do not heed unverified myths; place trust in certified oncologists and adhere faithfully to medical guidance.',
      durationSeconds: 35,
    ),
  ];

  static const List<Map<String, String>> _categoryTabs = [
    {'key': 'all', 'ar': 'الكل', 'en': 'All'},
    {'key': 'survivors', 'ar': 'قصص الأمل والتعافي 🌸', 'en': 'Survivor Stories 🌸'},
    {'key': 'benign', 'ar': 'كتل حميدة', 'en': 'Benign Lumps'},
    {'key': 'cysts', 'ar': 'أكياس مائية', 'en': 'Cysts'},
    {'key': 'inflammation', 'ar': 'التهابات الثدي', 'en': 'Inflammation'},
    {'key': 'warnings', 'ar': 'علامات تحذيرية', 'en': 'Warning Signs'},
    {'key': 'imaging', 'ar': 'أشعة وفحوصات', 'en': 'Scans & Imaging'},
    {'key': 'self_exam', 'ar': 'فحص ذاتي', 'en': 'Self-Exam'},
    {'key': 'general', 'ar': 'صحة عامة', 'en': 'General Health'},
    {'key': 'care', 'ar': 'علاج ودعم', 'en': 'Care & Support'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchArticlesFromBackend();
  }

  Future<void> _fetchArticlesFromBackend() async {
    try {
      final client = ApiClient(tokenProvider: () => 'mock-patient-token');
      final res = await client.get('/educational/articles');
      if (res is List && mounted) {
        final List<EducationArticle> fetched = [];
        for (final item in res) {
          if (item is Map) {
            final m = Map<String, dynamic>.from(item);
            final titleAr = m['titleAr']?.toString() ?? 'مقال طبي جديد';
            final titleEn = m['titleEn']?.toString() ?? 'New Clinical Article';
            final summaryAr = m['summaryAr']?.toString() ?? titleAr;
            final summaryEn = m['summaryEn']?.toString() ?? titleEn;
            final contentAr = m['contentMarkdownAr']?.toString() ?? summaryAr;
            final contentEn = m['contentMarkdownEn']?.toString() ?? summaryEn;

            final id = m['id']?.toString() ?? 'api-${DateTime.now().millisecondsSinceEpoch}';
            if (_presetArticles.any((p) => p.id == id)) continue;

            fetched.add(
              EducationArticle(
                id: id,
                categoryKey: 'general',
                titleAr: titleAr,
                titleEn: titleEn,
                categoryAr: m['category']?['nameAr']?.toString() ?? 'مقالات استشارية',
                categoryEn: m['category']?['nameEn']?.toString() ?? 'Clinical Articles',
                readTimeAr: '${m['readTimeMinutes'] ?? 4} دقائق قراءة',
                readTimeEn: '${m['readTimeMinutes'] ?? 4} min read',
                doctorReviewerAr: 'نشر بواسطة: د. استشاري شبكة لوميرا',
                doctorReviewerEn: 'Published by: Lumyra Consultant Clinician',
                summaryAr: summaryAr,
                summaryEn: summaryEn,
                fullContentAr: contentAr,
                fullContentEn: contentEn,
                problemLabelAr: 'مقال سريري وتوعوي معتمد',
                problemLabelEn: 'Verified Clinical Reference',
                problemDetailAr: summaryAr,
                problemDetailEn: summaryEn,
                icon: Icons.verified_user_rounded,
                illustrationType: 'general',
                isDoctorPublished: true,
              ),
            );
          }
        }

        if (mounted) {
          setState(() {
            _apiArticles = fetched;
            _isLoadingApi = false;
          });
        }
        return;
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoadingApi = false);
  }

  List<EducationArticle> get _allArticles {
    return [..._apiArticles, ..._presetArticles];
  }

  Widget _buildArticleIllustration(EducationArticle article, bool isAr) {
    return _ArticleIllustrationCard(
      article: article,
      isArabic: isAr,
    );
  }

  Widget _buildSurvivorStoriesView(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDA4AF)),
              ),
              child: const Icon(Icons.favorite_rounded, color: Color(0xFFE11D48), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'أصوات الشفاء والانتصار على المرض 🌸' : 'Voices of Remission & Hope 🌸',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF9F1239)),
                  ),
                  Text(
                    isAr
                        ? 'شهادات وفويسات حقيقية لسيدات خضن الرحلة وعبرن إلى بر الأمان'
                        : 'Real audio journeys of courageous women who overcame breast cancer',
                    style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._presetSurvivorStories.map((story) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            border: Border.all(color: const Color(0xFFFDA4AF).withAlpha(120), width: 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF1F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🌸', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                story.name(isAr),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF10B981)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            story.ageCity(isAr),
                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                          ),
                          const SizedBox(height: 6),
                          StatusBadge.active(story.remission(isAr)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2).withAlpha(150),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.format_quote_rounded, color: Color(0xFFE11D48), size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          story.quote(isAr),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF881337),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                VoiceNotePlayerWidget(
                  durationSeconds: story.durationSeconds,
                  isMe: false,
                  title: isAr ? 'شهادة صوتية: ${story.name(isAr)}' : 'Audio Story: ${story.name(isAr)}',
                  audioPath: story.audioPath,
                ),
                const SizedBox(height: 12),
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    title: Text(
                      isAr ? 'اقرئي قصة الرحلة الكاملة ونصيحة المتعافية 📖' : 'Read Full Journey & Survivor Advice 📖',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.powderBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.softDustyBlush),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.medical_services_outlined, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    story.stage(isAr),
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Text(
                              story.journey(isAr),
                              style: const TextStyle(fontSize: 12.5, color: AppColors.mainText, height: 1.6),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF10B981).withAlpha(100)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.tips_and_updates_rounded, color: Color(0xFF10B981), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${isAr ? "نصيحة المتعافية: " : "Key Advice: "}${story.advice(isAr)}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF065F46), height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
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
        }),
      ],
    );
  }

  void _openArticleDetails(EducationArticle article) {
    final isAr = context.isArabic;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.whiteSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.warmNeutralSand,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      StatusBadge.active(article.category(isAr)),
                      if (article.isDoctorPublished) ...[
                        const SizedBox(width: 8),
                        StatusBadge.info(isAr ? 'جديد من الطبيب' : 'New by Doctor'),
                      ],
                      const Spacer(),
                      Text(article.readTime(isAr), style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title(isAr),
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.doctorReviewer(isAr),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 16),

                  // Anatomical Breast Illustration Box
                  _buildArticleIllustration(article, isAr),

                  const Divider(height: 32),
                  Text(
                    article.fullContent(isAr),
                    style: const TextStyle(fontSize: 14.5, color: AppColors.mainText, height: 1.7),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.powderBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.softDustyBlush),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bookmark_add_outlined, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isAr
                                ? 'هل لديكِ استفسار حول هذه الحالة؟ يمكنكِ إضافته لنقاط نقاشكِ مع الطبيب المعالج.'
                                : 'Have a clinical question? Save it to discuss during your doctor appointment.',
                            style: const TextStyle(fontSize: 12, color: AppColors.mainText),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  PillButton(
                    label: isAr ? 'إغلاق المقال' : 'Close Article',
                    icon: Icons.check_rounded,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isArabic;
    final query = _searchController.text.trim().toLowerCase();
    final all = _allArticles;

    final filtered = all.where((art) {
      final matchesCategory = _selectedCategoryKey == 'all' || art.categoryKey == _selectedCategoryKey;
      final matchesQuery = query.isEmpty ||
          art.title(isAr).toLowerCase().contains(query) ||
          art.summary(isAr).toLowerCase().contains(query) ||
          art.fullContent(isAr).toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return AdaptiveScaffold(
      selectedIndex: 3,
      titleKey: 'navEducation',
      body: RefreshIndicator(
        onRefresh: _fetchArticlesFromBackend,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: isAr ? 'ابحثي في الحالات السريرية وأدلة الفحص...' : 'Search clinical cases and guides...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondaryText),
                  fillColor: AppColors.whiteSurface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9999),
                    borderSide: const BorderSide(color: AppColors.warmNeutralSand),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Chips (Fully Dynamic Language Support)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categoryTabs.map((cat) {
                    final key = cat['key']!;
                    final label = isAr ? cat['ar']! : cat['en']!;
                    final isSelected = _selectedCategoryKey == key;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: AppColors.powderBackground,
                        backgroundColor: AppColors.whiteSurface,
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          color: isSelected ? AppColors.primary : AppColors.mainText,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.warmNeutralSand,
                          width: isSelected ? 1.5 : 1,
                        ),
                        onSelected: (_) => setState(() => _selectedCategoryKey = key),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Featured Hero Card (Self-Exam Guide)
              AppCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.powderBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.favorite_rounded, color: AppColors.primaryAction, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StatusBadge.active(isAr ? 'دليل موجه تفاعلي' : 'Featured Guide'),
                              const SizedBox(height: 4),
                              Text(
                                isAr ? 'الفحص الذاتي الشهري خطوة بخطوة' : 'Monthly Self-Exam Guide',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isAr
                          ? 'تعلمي الطريقة الصحيحة لاكتشاف أي تغيرات مبكرة في أنسجة الثدي بأسلوب إكلينيكي بسيط ومطمئن.'
                          : 'A step-by-step clinical guide to familiarizing yourself with your breast health.',
                      style: const TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    PillButton(
                      label: isAr ? 'بدء قراءة الدليل الآن' : 'Read Interactive Guide',
                      icon: Icons.menu_book_rounded,
                      onPressed: () => _openArticleDetails(
                        _presetArticles.firstWhere((a) => a.id == 'art-1', orElse: () => _presetArticles.first),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (_selectedCategoryKey == 'survivors') ...[
                _buildSurvivorStoriesView(isAr),
              ] else ...[
                // Survivor Voices Inspiration Banner (Accessible from all categories)
                AppCard(
                  padding: const EdgeInsets.all(18),
                  color: AppColors.powderBackground,
                  border: Border.all(color: AppColors.softDustyBlush, width: 1.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.whiteSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.softDustyBlush),
                            ),
                            child: const Icon(Icons.record_voice_over_rounded, color: AppColors.primary, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'تجارب ملهمة لمتعافيات من سرطان الثدي 🌸' : 'Inspiring Breast Cancer Survivor Stories 🌸',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isAr
                                      ? 'استمعي لشهادات وفويسات واقعية لسيدات تغلّبن على المرض واستعدن عافيتهن بالكامل.'
                                      : 'Listen to real voice journeys of women who overcame breast cancer and fully healed.',
                                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.35),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StatusBadge.active(isAr ? 'أصوات الأمل والشفاء' : 'Voices of Hope'),
                          InkWell(
                            onTap: () => setState(() => _selectedCategoryKey = 'survivors'),
                            borderRadius: BorderRadius.circular(9999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF9E3E4E), Color(0xFF7E2A38)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(9999),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF9E3E4E).withValues(alpha: 0.28),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.play_circle_fill_rounded, size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    isAr ? 'استماع للقصص' : 'Listen Now',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Article Grid / List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? 'المكتبة السريرية المعتمدة (${filtered.length})' : 'Clinical Library (${filtered.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    ),
                    if (_isLoadingApi)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                ...filtered.map((art) {
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: () => _openArticleDetails(art),
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: art.isDoctorPublished
                                  ? const Color(0xFFEFF6FF)
                                  : AppColors.powderBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: art.isDoctorPublished
                                  ? Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.4))
                                  : null,
                            ),
                            child: Icon(
                              art.icon,
                              color: art.isDoctorPublished ? const Color(0xFF2563EB) : AppColors.primary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      art.category(isAr),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: art.isDoctorPublished ? const Color(0xFF2563EB) : AppColors.primaryAction,
                                      ),
                                    ),
                                    if (art.isDoctorPublished) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDBEAFE),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isAr ? 'نشر حديثاً' : 'Newly Published',
                                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)),
                                        ),
                                      ),
                                    ],
                                    const Spacer(),
                                    Text(art.readTime(isAr), style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  art.title(isAr),
                                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.3),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  art.summary(isAr),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.4),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  art.doctorReviewer(isAr),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Interactive 3D / 2D Multi-modal Breast Anatomy Card
/// Embedded in every article, allowing full 360° rotation,
/// zoom, and 4-layer depth peeling ("ادخل جواه").
class _ArticleIllustrationCard extends StatefulWidget {
  final EducationArticle article;
  final bool isArabic;

  const _ArticleIllustrationCard({
    required this.article,
    required this.isArabic,
  });

  @override
  State<_ArticleIllustrationCard> createState() => _ArticleIllustrationCardState();
}

class _ArticleIllustrationCardState extends State<_ArticleIllustrationCard> {
  bool _is3dMode = true; // Default to 3D interactive model

  void _openFullscreen3d() {
    final isAr = widget.isArabic;
    showDialog(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        child: Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              isAr ? 'المختبر التشريحي ثلاثي الأبعاد • ${widget.article.title(isAr)}' : '3D Breast Anatomy Lab • ${widget.article.title(isAr)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
          body: SafeArea(
            child: Interactive3dBreastViewer(
              pathologyType: widget.article.illustrationType,
              isArabic: isAr,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final article = widget.article;

    Color themeColor;
    switch (article.illustrationType) {
      case 'cyst':
      case 'fibrocystic':
        themeColor = const Color(0xFF0284C7);
        break;
      case 'fibroadenoma':
        themeColor = const Color(0xFFD946EF);
        break;
      case 'mastitis':
        themeColor = const Color(0xFFEA580C);
        break;
      case 'calcification':
      case 'dcis':
        themeColor = const Color(0xFF475569);
        break;
      case 'suspicious':
        themeColor = AppColors.error;
        break;
      case 'exam':
        themeColor = AppColors.primary;
        break;
      default:
        themeColor = AppColors.primaryAction;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.powderBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.softDustyBlush, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode Switcher Header: 3D Model vs 2D Schematic
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.softDustyBlush),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _is3dMode = true),
                    borderRadius: BorderRadius.circular(11),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        gradient: _is3dMode
                            ? const LinearGradient(colors: [Color(0xFF9E3E4E), Color(0xFF7E2A38)])
                            : null,
                        color: _is3dMode ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: _is3dMode
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF9E3E4E).withValues(alpha: 0.28),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.view_in_ar_rounded,
                            size: 15,
                            color: _is3dMode ? Colors.white : AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              isAr ? 'مجسم 3D واقعي (ادخل جواه)' : 'Realistic 3D (Inside View)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: _is3dMode ? FontWeight.w800 : FontWeight.w600,
                                color: _is3dMode ? Colors.white : AppColors.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _is3dMode = false),
                    borderRadius: BorderRadius.circular(11),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        gradient: !_is3dMode
                            ? const LinearGradient(colors: [Color(0xFF9E3E4E), Color(0xFF7E2A38)])
                            : null,
                        color: !_is3dMode ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: !_is3dMode
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF9E3E4E).withValues(alpha: 0.28),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schema_rounded,
                            size: 15,
                            color: !_is3dMode ? Colors.white : AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              isAr ? 'مخطط 2D توضيحي' : '2D Schematic',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: !_is3dMode ? FontWeight.w800 : FontWeight.w600,
                                color: !_is3dMode ? Colors.white : AppColors.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Main View: 3D Interactive Model or 2D Schematic
          if (_is3dMode)
            Interactive3dBreastViewer(
              pathologyType: article.illustrationType,
              isArabic: isAr,
              height: 420,
              onExpand: _openFullscreen3d,
            )
          else
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SizedBox(
                  width: 310,
                  height: 195,
                  child: CustomPaint(
                    painter: _BreastAnatomyPainter(
                      type: article.illustrationType,
                      themeColor: themeColor,
                      isArabic: isAr,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Anatomical Structure Label Tags
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnatomyTag(isAr ? 'عضلة الصدر' : 'Pectoralis', const Color(0xFFE11D48)),
                const SizedBox(width: 6),
                _buildAnatomyTag(isAr ? 'أربطة كوبر' : 'Cooper Lig.', const Color(0xFF64748B)),
                const SizedBox(width: 6),
                _buildAnatomyTag(isAr ? 'النسيج الدهني' : 'Adipose', const Color(0xFFD97706)),
                const SizedBox(width: 6),
                _buildAnatomyTag(isAr ? 'الفصوص والقنوات' : 'Lobules & Ducts', const Color(0xFFBE185D)),
                const SizedBox(width: 6),
                _buildAnatomyTag(isAr ? 'الحلمة والقرص' : 'Areola & Nipple', const Color(0xFFDB2777)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Problem Detail Callout Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: themeColor.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.arrow_forward_rounded, color: themeColor, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        article.problemLabel(isAr),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: themeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  article.problemDetail(isAr),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mainText,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnatomyTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

/// CustomPainter rendering an ultra-realistic anatomical cross-section of the human breast
/// with rib bones, pectoralis major muscle, retromammary space, Cooper's suspensory ligaments,
/// clustered adipose fat lobules, glandular lobules (TDLUs), lactiferous ducts & sinuses,
/// pigmented areola with Montgomery tubercles, anatomical nipple, and high-fidelity lesion pathology.
class _BreastAnatomyPainter extends CustomPainter {
  final String type;
  final Color themeColor;
  final bool isArabic;

  _BreastAnatomyPainter({
    required this.type,
    required this.themeColor,
    required this.isArabic,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background subtle clinical medical grid
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9).withValues(alpha: 0.6)
      ..strokeWidth = 0.8;
    for (double x = 20; x < w; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 20; y < h; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 1. Thoracic Chest Wall & Ribs
    final ribYPositions = [26.0, 68.0, 112.0, 156.0];
    for (int i = 0; i < ribYPositions.length; i++) {
      final ry = ribYPositions[i];
      // Rib outer cortical bone (Oval section)
      final ribRect = Rect.fromCenter(center: Offset(26, ry), width: 14, height: 22);
      final ribCortex = Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final ribMarrow = Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFED7AA), Color(0xFFFECDD3)],
          stops: [0.2, 0.6, 1.0],
        ).createShader(ribRect)
        ..style = PaintingStyle.fill;
      canvas.drawOval(ribRect, ribMarrow);
      canvas.drawOval(ribRect, ribCortex);

      // Trabecular cancellous marrow stippling
      canvas.drawCircle(Offset(25, ry - 3), 1.5, Paint()..color = const Color(0xFFE11D48).withValues(alpha: 0.4));
      canvas.drawCircle(Offset(27, ry + 3), 1.8, Paint()..color = const Color(0xFFE11D48).withValues(alpha: 0.4));

      // Intercostal muscles between ribs
      if (i < ribYPositions.length - 1) {
        final nextRy = ribYPositions[i + 1];
        final interRect = Rect.fromLTRB(18, ry + 12, 34, nextRy - 12);
        final interPaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDA4AF), Color(0xFFE11D48), Color(0xFFFDA4AF)],
          ).createShader(interRect)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(interRect, const Radius.circular(3)), interPaint);
        // Striation lines
        canvas.drawLine(Offset(20, ry + 16), Offset(32, ry + 22), Paint()..color = const Color(0xFF9F1239).withValues(alpha: 0.5)..strokeWidth = 1);
        canvas.drawLine(Offset(20, ry + 24), Offset(32, ry + 30), Paint()..color = const Color(0xFF9F1239).withValues(alpha: 0.5)..strokeWidth = 1);
      }
    }

    // 2. Pectoralis Major & Minor Muscle (Anatomical Striated Band)
    final pectPath = Path();
    pectPath.moveTo(34, 10);
    pectPath.lineTo(54, 10);
    pectPath.cubicTo(56, 70, 56, 130, 54, h - 10);
    pectPath.lineTo(34, h - 10);
    pectPath.close();

    final pectGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFF9F1239),
        const Color(0xFFBE123C),
        const Color(0xFFE11D48),
        const Color(0xFFFDA4AF).withValues(alpha: 0.8),
      ],
    );
    canvas.drawPath(pectPath, Paint()..shader = pectGradient.createShader(Rect.fromLTWH(34, 10, 22, h - 20)));

    // Bipennate muscle striation lines
    final fiberPaint = Paint()
      ..color = const Color(0xFF881337).withValues(alpha: 0.4)
      ..strokeWidth = 1.2;
    for (double my = 20; my < h - 15; my += 12) {
      canvas.drawLine(Offset(36, my), Offset(52, my + 8), fiberPaint);
      canvas.drawLine(Offset(36, my + 6), Offset(52, my + 14), fiberPaint);
    }

    // Deep Pectoral Fascia Membrane
    final fasciaPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(54, 10), Offset(54, h - 10), fasciaPaint);

    // 3. Breast Contour (Natural Sagittal Anatomical Silhouette)
    final breastPath = Path();
    breastPath.moveTo(54, 20);
    breastPath.cubicTo(105, 26, 170, 55, 205, 82);
    breastPath.cubicTo(212, 84, 218, 88, 220, 92);
    breastPath.cubicTo(218, 96, 212, 100, 205, 102);
    breastPath.cubicTo(175, 135, 115, 160, 54, 160);
    breastPath.close();

    // Fill Breast Volume with Multi-tone Adipose & Glandular Gradient
    final breastGrad = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFFFEF3C7).withValues(alpha: 0.7),
        const Color(0xFFFFF1F2),
        const Color(0xFFFFF7ED),
        const Color(0xFFFCE7F3),
      ],
      stops: const [0.0, 0.45, 0.85, 1.0],
    );
    canvas.drawPath(breastPath, Paint()..shader = breastGrad.createShader(Rect.fromLTWH(54, 20, 170, 145)));

    // 4. Subcutaneous & Retromammary Adipose Fat Lobules
    final fatFill = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFEF9C3), Color(0xFFFDE68A)],
      ).createShader(Rect.fromCircle(center: const Offset(100, 80), radius: 50))
      ..style = PaintingStyle.fill;
    final fatStroke = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: 0.35)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    final fatCenters = [
      const Offset(62, 38), const Offset(64, 62), const Offset(63, 88), const Offset(64, 116), const Offset(62, 142),
      const Offset(110, 36), const Offset(136, 46), const Offset(164, 60), const Offset(185, 72),
      const Offset(115, 146), const Offset(142, 138), const Offset(168, 120), const Offset(185, 108),
    ];
    for (final fc in fatCenters) {
      canvas.drawCircle(fc, 7.5, fatFill);
      canvas.drawCircle(fc, 7.5, fatStroke);
      canvas.drawCircle(Offset(fc.dx + 4, fc.dy - 3), 5.5, fatFill);
      canvas.drawCircle(Offset(fc.dx + 4, fc.dy - 3), 5.5, fatStroke);
    }

    // 5. Cooper's Suspensory Ligaments
    final isSuspicious = type == 'suspicious';
    final ligamentPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.75)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final lig1 = Path()..moveTo(54, 40)..quadraticBezierTo(95, 38, 136, 46);
    final lig2 = Path()..moveTo(54, 70)..quadraticBezierTo(100, isSuspicious ? 68 : 60, 168, 62);
    final lig3 = Path();
    if (isSuspicious) {
      lig3.moveTo(54, 95);
      lig3.lineTo(118, 70);
      lig3.lineTo(195, 84);
    } else {
      lig3.moveTo(54, 95);
      lig3.quadraticBezierTo(115, 92, 185, 88);
    }
    final lig4 = Path()..moveTo(54, 125)..quadraticBezierTo(105, 132, 165, 122);
    final lig5 = Path()..moveTo(54, 148)..quadraticBezierTo(90, 155, 135, 144);

    canvas.drawPath(lig1, ligamentPaint);
    canvas.drawPath(lig2, ligamentPaint);
    canvas.drawPath(lig3, ligamentPaint..strokeWidth = isSuspicious ? 2.4 : 1.6);
    canvas.drawPath(lig4, ligamentPaint);
    canvas.drawPath(lig5, ligamentPaint);

    // 6. Glandular Lobules (TDLUs)
    final lobulePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFDF2F8), Color(0xFFFCE7F3), Color(0xFFF472B6)],
        stops: [0.2, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: const Offset(120, 90), radius: 45))
      ..style = PaintingStyle.fill;
    final lobuleStroke = Paint()
      ..color = const Color(0xFFDB2777).withValues(alpha: 0.45)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final lobuleOffsets = [
      const Offset(88, 55), const Offset(112, 52), const Offset(134, 58),
      const Offset(86, 82), const Offset(110, 84), const Offset(138, 80),
      const Offset(92, 114), const Offset(118, 118), const Offset(142, 110),
      const Offset(158, 92), const Offset(164, 82),
    ];
    for (final lo in lobuleOffsets) {
      canvas.drawCircle(lo, 11, lobulePaint);
      canvas.drawCircle(lo, 11, lobuleStroke);
      canvas.drawCircle(Offset(lo.dx - 3, lo.dy - 3), 4, Paint()..color = Colors.white.withValues(alpha: 0.7));
    }

    // 7. Lactiferous Ducts & Sinuses
    final ductPaint = Paint()
      ..color = const Color(0xFFBE185D).withValues(alpha: 0.85)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(90, 55), const Offset(145, 78), ductPaint);
    canvas.drawLine(const Offset(112, 52), const Offset(160, 84), ductPaint);
    canvas.drawLine(const Offset(92, 114), const Offset(155, 96), ductPaint);
    canvas.drawLine(const Offset(118, 118), const Offset(165, 94), ductPaint);
    canvas.drawLine(const Offset(138, 80), const Offset(178, 90), ductPaint);

    // Lactiferous Sinuses (Ampullae)
    final ampullaPaint = Paint()
      ..color = const Color(0xFF9D174D)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(175, 87), const Offset(195, 89), ampullaPaint);
    canvas.drawLine(const Offset(176, 92), const Offset(196, 92), ampullaPaint);
    canvas.drawLine(const Offset(175, 97), const Offset(195, 94), ampullaPaint);
    canvas.drawLine(const Offset(195, 89), const Offset(218, 91), ampullaPaint..strokeWidth = 2);
    canvas.drawLine(const Offset(195, 94), const Offset(218, 93), ampullaPaint..strokeWidth = 2);

    // 8. Areola & Nipple Complex
    final areolaRect = Rect.fromCenter(center: const Offset(204, 92), width: 14, height: 34);
    final areolaPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF9D174D), Color(0xFF831843), Color(0xFFBE185D)],
      ).createShader(areolaRect)
      ..style = PaintingStyle.fill;
    canvas.drawOval(areolaRect, areolaPaint);

    // Montgomery Tubercles
    final tuberclePaint = Paint()..color = const Color(0xFFF472B6);
    canvas.drawCircle(const Offset(203, 79), 1.8, tuberclePaint);
    canvas.drawCircle(const Offset(205, 85), 1.8, tuberclePaint);
    canvas.drawCircle(const Offset(205, 99), 1.8, tuberclePaint);
    canvas.drawCircle(const Offset(203, 105), 1.8, tuberclePaint);

    // Projecting Nipple Papilla
    final nipplePath = Path();
    nipplePath.moveTo(206, 85);
    nipplePath.cubicTo(216, 86, 221, 88, 222, 92);
    nipplePath.cubicTo(221, 96, 216, 98, 206, 99);
    nipplePath.close();
    canvas.drawPath(
      nipplePath,
      Paint()
        ..color = const Color(0xFF701A75)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(const Offset(221, 90), 0.9, Paint()..color = Colors.black87);
    canvas.drawCircle(const Offset(222, 92), 0.9, Paint()..color = Colors.black87);
    canvas.drawCircle(const Offset(221, 94), 0.9, Paint()..color = Colors.black87);

    // 9. Dermis & Epidermis Skin Contour with Dimpling if Malignant
    final skinPath = Path();
    skinPath.moveTo(54, 20);
    if (isSuspicious) {
      skinPath.cubicTo(105, 26, 150, 48, 172, 66);
      skinPath.cubicTo(176, 70, 172, 76, 178, 80);
      skinPath.cubicTo(192, 82, 205, 88, 220, 92);
    } else {
      skinPath.cubicTo(105, 26, 170, 55, 205, 82);
      skinPath.cubicTo(212, 84, 218, 88, 220, 92);
    }
    skinPath.cubicTo(218, 96, 212, 100, 205, 102);
    skinPath.cubicTo(175, 135, 115, 160, 54, 160);

    canvas.drawPath(
      skinPath,
      Paint()
        ..color = const Color(0xFFFDA4AF)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );

    // 10. REALISTIC PATHOLOGY RENDERING
    Offset lesionCenter = const Offset(118, 68);
    Offset arrowStart = const Offset(180, 28);
    String caliberText = '';

    switch (type) {
      case 'cyst':
        lesionCenter = const Offset(118, 64);
        arrowStart = const Offset(175, 26);
        caliberText = '16 mm';

        // Posterior Acoustic Enhancement
        final acousticRect = Rect.fromLTRB(104, 76, 132, 135);
        final acousticPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF38BDF8).withValues(alpha: 0.4),
              const Color(0xFF38BDF8).withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ).createShader(acousticRect)
          ..style = PaintingStyle.fill;
        canvas.drawRect(acousticRect, acousticPaint);

        // Fluid-filled Anechoic Cavity
        final cystRect = Rect.fromCircle(center: lesionCenter, radius: 14);
        final cystPaint = Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFF0369A1), Color(0xFF0C4A6E), Color(0xFF082F49)],
            stops: [0.2, 0.7, 1.0],
          ).createShader(cystRect)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(lesionCenter, 14, cystPaint);

        // Thin capsule wall
        canvas.drawCircle(
          lesionCenter,
          14,
          Paint()
            ..color = const Color(0xFFE0F2FE)
            ..strokeWidth = 1.8
            ..style = PaintingStyle.stroke,
        );

        // Specular anterior fluid reflection glint
        canvas.drawArc(
          Rect.fromCircle(center: lesionCenter, radius: 10),
          math.pi * 1.15,
          math.pi * 0.45,
          false,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.9)
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
        break;

      case 'fibroadenoma':
        lesionCenter = const Offset(116, 72);
        arrowStart = const Offset(175, 28);
        caliberText = '22 × 13 mm';

        // Smooth oval rubbery mass (width > height)
        final fibroRect = Rect.fromCenter(center: lesionCenter, width: 36, height: 22);
        final fibroPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFF472B6), Color(0xFFC026D3), Color(0xFF701A75)],
          ).createShader(fibroRect)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(fibroRect, const Radius.circular(12)), fibroPaint);

        // Compressed pseudocapsule
        canvas.drawRRect(
          RRect.fromRectAndRadius(fibroRect, const Radius.circular(12)),
          Paint()
            ..color = const Color(0xFFFDF4FF)
            ..strokeWidth = 2.2
            ..style = PaintingStyle.stroke,
        );
        canvas.drawLine(
          Offset(lesionCenter.dx - 10, lesionCenter.dy - 2),
          Offset(lesionCenter.dx + 10, lesionCenter.dy - 1),
          Paint()..color = Colors.white.withValues(alpha: 0.4)..strokeWidth = 1.5,
        );
        break;

      case 'mastitis':
        lesionCenter = const Offset(160, 88);
        arrowStart = const Offset(140, 145);
        caliberText = isArabic ? 'احتقان نسيجي' : 'Tissue Edema';

        // Inflammatory Hyperemic Erythema Glow
        final mastitisGlow = Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFDC2626).withValues(alpha: 0.75),
              const Color(0xFFF97316).withValues(alpha: 0.45),
              Colors.transparent,
            ],
            stops: const [0.2, 0.65, 1.0],
          ).createShader(Rect.fromCircle(center: lesionCenter, radius: 30))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(lesionCenter, 30, mastitisGlow);

        // Swollen engorged duct
        canvas.drawLine(
          const Offset(132, 88),
          const Offset(195, 91),
          Paint()
            ..color = const Color(0xFF991B1B)
            ..strokeWidth = 5.0
            ..strokeCap = StrokeCap.round,
        );
        break;

      case 'calcification':
        lesionCenter = const Offset(118, 66);
        arrowStart = const Offset(175, 28);
        caliberText = isArabic ? 'تكلسات عنقودية' : 'Clustered Specks';

        final clusterRect = Rect.fromCenter(center: lesionCenter, width: 34, height: 34);
        canvas.drawOval(
          clusterRect,
          Paint()
            ..color = const Color(0xFF64748B)
            ..strokeWidth = 1.2
            ..style = PaintingStyle.stroke,
        );
        final specks = [
          const Offset(112, 60), const Offset(118, 58), const Offset(124, 62),
          const Offset(109, 66), const Offset(116, 67), const Offset(122, 69),
          const Offset(114, 73), const Offset(120, 74), const Offset(127, 72),
        ];
        for (final s in specks) {
          canvas.drawCircle(s, 2.8, Paint()..color = Colors.white);
          canvas.drawCircle(s, 2.8, Paint()..color = const Color(0xFF0F172A)..strokeWidth = 0.9..style = PaintingStyle.stroke);
        }
        break;

      case 'suspicious':
        lesionCenter = const Offset(118, 70);
        arrowStart = const Offset(180, 26);
        caliberText = '18 × 24 mm';

        final starPath = Path();
        const pts = 12;
        const outerR = 19.0;
        const innerR = 9.0;
        for (int i = 0; i < pts * 2; i++) {
          final r = i.isEven ? outerR : innerR;
          final angle = (i * math.pi) / pts;
          final x = lesionCenter.dx + r * math.cos(angle);
          final y = lesionCenter.dy + (r * 1.35) * math.sin(angle);
          if (i == 0) {
            starPath.moveTo(x, y);
          } else {
            starPath.lineTo(x, y);
          }
        }
        starPath.close();

        canvas.drawPath(
          starPath,
          Paint()
            ..color = const Color(0xFF4C0519)
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          starPath,
          Paint()
            ..color = const Color(0xFFBE123C)
            ..strokeWidth = 2.4
            ..style = PaintingStyle.stroke,
        );
        canvas.drawLine(
          lesionCenter,
          Offset(lesionCenter.dx + 26, lesionCenter.dy - 6),
          Paint()..color = const Color(0xFFE11D48)..strokeWidth = 2.4..strokeCap = StrokeCap.round,
        );
        break;

      case 'exam':
        lesionCenter = const Offset(118, 90);
        arrowStart = const Offset(175, 30);
        caliberText = isArabic ? 'مسار الفحص' : 'Palpation Track';

        final qPaint = Paint()
          ..color = AppColors.primary.withValues(alpha: 0.5)
          ..strokeWidth = 1.3
          ..style = PaintingStyle.stroke;
        canvas.drawLine(const Offset(60, 90), const Offset(195, 90), qPaint);
        canvas.drawLine(const Offset(118, 30), const Offset(118, 150), qPaint);

        final trackPaint = Paint()
          ..color = AppColors.primary
          ..strokeWidth = 2.2
          ..style = PaintingStyle.stroke;
        canvas.drawArc(
          Rect.fromCircle(center: lesionCenter, radius: 30),
          0.2,
          math.pi * 1.55,
          false,
          trackPaint,
        );
        break;

      default:
        lesionCenter = const Offset(118, 75);
        arrowStart = const Offset(175, 30);
        break;
    }

    // 11. SURGICAL CLINICAL ARROW WITH TARGET RETICLE & CALIBER
    final arrowPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(arrowStart, lesionCenter, arrowPaint);

    final angle = math.atan2(lesionCenter.dy - arrowStart.dy, lesionCenter.dx - arrowStart.dx);
    const arrowHeadLen = 11.0;
    const arrowHeadAngle = 0.5;

    final arrowHeadPath = Path();
    arrowHeadPath.moveTo(lesionCenter.dx, lesionCenter.dy);
    arrowHeadPath.lineTo(
      lesionCenter.dx - arrowHeadLen * math.cos(angle - arrowHeadAngle),
      lesionCenter.dy - arrowHeadLen * math.sin(angle - arrowHeadAngle),
    );
    arrowHeadPath.lineTo(
      lesionCenter.dx - arrowHeadLen * math.cos(angle + arrowHeadAngle),
      lesionCenter.dy - arrowHeadLen * math.sin(angle + arrowHeadAngle),
    );
    arrowHeadPath.close();
    canvas.drawPath(arrowHeadPath, Paint()..color = themeColor..style = PaintingStyle.fill);

    canvas.drawCircle(
      lesionCenter,
      22,
      Paint()
        ..color = themeColor.withValues(alpha: 0.5)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    canvas.drawCircle(arrowStart, 5.0, Paint()..color = themeColor..style = PaintingStyle.fill);
    canvas.drawCircle(
      arrowStart,
      8.0,
      Paint()
        ..color = themeColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    if (caliberText.isNotEmpty) {
      final textSpan = TextSpan(
        text: caliberText,
        style: TextStyle(
          color: themeColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      )..layout();

      final pillRect = Rect.fromCenter(
        center: Offset(arrowStart.dx + (isArabic ? -25 : 25), arrowStart.dy - 12),
        width: textPainter.width + 12,
        height: 18,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(pillRect, const Radius.circular(6)),
        Paint()..color = Colors.white..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(pillRect, const Radius.circular(6)),
        Paint()..color = themeColor.withValues(alpha: 0.5)..strokeWidth = 1..style = PaintingStyle.stroke,
      );
      textPainter.paint(
        canvas,
        Offset(pillRect.left + 6, pillRect.top + 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BreastAnatomyPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.themeColor != themeColor ||
        oldDelegate.isArabic != isArabic;
  }
}
