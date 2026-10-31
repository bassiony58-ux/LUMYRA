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
  ];

  static const List<Map<String, String>> _categoryTabs = [
    {'key': 'all', 'ar': 'الكل', 'en': 'All'},
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
    Color themeColor;
    switch (article.illustrationType) {
      case 'cyst':
        themeColor = const Color(0xFF0284C7);
        break;
      case 'fibroadenoma':
        themeColor = const Color(0xFFD946EF);
        break;
      case 'mastitis':
        themeColor = const Color(0xFFEA580C);
        break;
      case 'calcification':
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.powderBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeColor.withValues(alpha: 0.35), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.analytics_outlined, color: Colors.white, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      isAr ? 'مخطط تشريح الثدي والمشكلة الموضعية' : 'Breast Anatomy & Pathology Diagram',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                isAr ? 'رسم استرشادي' : 'Clinical Schematic',
                style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Breast Anatomy Custom Painter with Problem Zone & Pointer Arrow
          Center(
            child: SizedBox(
              width: 280,
              height: 170,
              child: CustomPaint(
                painter: _BreastAnatomyPainter(
                  type: article.illustrationType,
                  themeColor: themeColor,
                  isArabic: isAr,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Arrow Callout Badge Highlighting the Specific Problem Area
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
          ),
        ),
      ),
    );
  }
}

/// CustomPainter rendering an anatomical cross-section of the human breast
/// with the chest wall, pectoralis contour, areola, nipple, and the lesion
/// with a prominent arrow pointing directly at the problem area.
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
    final h = size.height;

    // 1. Chest Wall (Vertical border on left)
    final chestPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final chestFill = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;

    final chestPath = Path()
      ..moveTo(35, 10)
      ..lineTo(35, h - 10)
      ..lineTo(10, h - 10)
      ..lineTo(10, 10)
      ..close();
    canvas.drawPath(chestPath, chestFill);
    canvas.drawLine(const Offset(35, 10), Offset(35, h - 10), chestPaint);

    // Rib / Pectoralis Muscle Band
    final musclePaint = Paint()
      ..color = const Color(0xFFFDA4AF).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    final musclePath = Path()
      ..moveTo(35, 20)
      ..lineTo(50, 20)
      ..lineTo(50, h - 20)
      ..lineTo(35, h - 20)
      ..close();
    canvas.drawPath(musclePath, musclePaint);

    // 2. Breast Contour (Anatomical Sagittal Silhouette)
    final breastPath = Path();
    breastPath.moveTo(50, 25);
    // Upper gentle slope
    breastPath.cubicTo(100, 30, 160, 55, 195, 80);
    // Areola & Nipple protrusion
    breastPath.cubicTo(202, 82, 208, 85, 208, 88); // Nipple tip
    breastPath.cubicTo(208, 91, 202, 94, 195, 96);
    // Lower curve (inframammary fold)
    breastPath.cubicTo(160, 125, 110, 145, 50, 145);
    breastPath.close();

    // Fill Breast with Soft Warm Gradient
    final breastGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFFFFF1F2),
        const Color(0xFFFFF7ED),
        const Color(0xFFFDF2F8),
      ],
    );
    final breastFillPaint = Paint()
      ..shader = breastGradient.createShader(Rect.fromLTWH(50, 25, 160, 120))
      ..style = PaintingStyle.fill;
    canvas.drawPath(breastPath, breastFillPaint);

    // Breast Outline Stroke
    final breastOutlinePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(breastPath, breastOutlinePaint);

    // Areola shading
    final areolaPaint = Paint()
      ..color = const Color(0xFFF472B6).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(195, 88), width: 14, height: 26),
      areolaPaint,
    );

    // 3. Glandular Lobules & Milk Duct Network
    final ductPaint = Paint()
      ..color = const Color(0xFFFBCFE8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final lobulePaint = Paint()
      ..color = const Color(0xFFFCE7F3)
      ..style = PaintingStyle.fill;

    // Background healthy lobules
    canvas.drawCircle(const Offset(85, 65), 18, lobulePaint);
    canvas.drawCircle(const Offset(115, 60), 16, lobulePaint);
    canvas.drawCircle(const Offset(100, 95), 20, lobulePaint);
    canvas.drawCircle(const Offset(130, 90), 17, lobulePaint);

    // Ducts converging toward nipple (195, 88)
    canvas.drawLine(const Offset(85, 65), const Offset(140, 78), ductPaint);
    canvas.drawLine(const Offset(115, 60), const Offset(155, 82), ductPaint);
    canvas.drawLine(const Offset(100, 95), const Offset(145, 90), ductPaint);
    canvas.drawLine(const Offset(130, 90), const Offset(175, 88), ductPaint);
    canvas.drawLine(const Offset(175, 88), const Offset(195, 88), ductPaint..strokeWidth = 2);

    // 4. Lesion / Pathology Feature & Arrow Target
    Offset lesionCenter = const Offset(115, 65);
    Offset arrowStart = const Offset(170, 32);

    switch (type) {
      case 'cyst':
        lesionCenter = const Offset(115, 62);
        arrowStart = const Offset(165, 30);
        // Anechoic fluid cyst (Round blue bubble with highlight)
        final cystPaint = Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFF38BDF8), Color(0xFF0369A1), Color(0xFF0C4A6E)],
            stops: [0.2, 0.7, 1.0],
          ).createShader(Rect.fromCircle(center: lesionCenter, radius: 15))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(lesionCenter, 15, cystPaint);
        // Clean white thin capsule
        canvas.drawCircle(
          lesionCenter,
          15,
          Paint()
            ..color = const Color(0xFFBAE6FD)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
        // Fluid reflection arc
        canvas.drawArc(
          Rect.fromCircle(center: lesionCenter, radius: 10),
          math.pi * 1.1,
          math.pi * 0.5,
          false,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.85)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
        break;

      case 'fibroadenoma':
        lesionCenter = const Offset(110, 68);
        arrowStart = const Offset(165, 30);
        // Smooth oval rubbery mass (width > height)
        final fibroRect = Rect.fromCenter(center: lesionCenter, width: 34, height: 22);
        final fibroPaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFF472B6), Color(0xFFC026D3), Color(0xFF86198F)],
          ).createShader(fibroRect)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(fibroRect, const Radius.circular(12)), fibroPaint);
        // Defined regular border
        canvas.drawRRect(
          RRect.fromRectAndRadius(fibroRect, const Radius.circular(12)),
          Paint()
            ..color = const Color(0xFFFDF4FF)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
        break;

      case 'mastitis':
        lesionCenter = const Offset(155, 85);
        arrowStart = const Offset(135, 140);
        // Red-orange diffuse inflammation glow radiating from duct
        final mastitisGlow = Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFEF4444).withValues(alpha: 0.7),
              const Color(0xFFF97316).withValues(alpha: 0.4),
              Colors.transparent,
            ],
            stops: const [0.2, 0.6, 1.0],
          ).createShader(Rect.fromCircle(center: lesionCenter, radius: 26))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(lesionCenter, 26, mastitisGlow);
        // Swollen hyperemic duct
        canvas.drawLine(
          const Offset(130, 85),
          const Offset(185, 88),
          Paint()
            ..color = const Color(0xFFB91C1C)
            ..strokeWidth = 4.5
            ..strokeCap = StrokeCap.round,
        );
        break;

      case 'calcification':
        lesionCenter = const Offset(115, 65);
        arrowStart = const Offset(170, 32);
        // Dotted cluster boundary
        final clusterRect = Rect.fromCenter(center: lesionCenter, width: 32, height: 32);
        canvas.drawOval(
          clusterRect,
          Paint()
            ..color = const Color(0xFF64748B)
            ..strokeWidth = 1.2
            ..style = PaintingStyle.stroke,
        );
        // Bright white crystalline specks
        final speckPaint = Paint()..color = const Color(0xFFFFFFFF);
        final speckBorder = Paint()
          ..color = const Color(0xFF1E293B)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;
        final specks = [
          const Offset(112, 62),
          const Offset(118, 60),
          const Offset(115, 68),
          const Offset(108, 66),
          const Offset(122, 65),
          const Offset(110, 71),
          const Offset(117, 72),
          const Offset(123, 70),
        ];
        for (final s in specks) {
          canvas.drawCircle(s, 2.5, speckPaint);
          canvas.drawCircle(s, 2.5, speckBorder);
        }
        break;

      case 'suspicious':
        lesionCenter = const Offset(115, 65);
        arrowStart = const Offset(170, 30);
        // Spiculated irregular star mass (taller than wide)
        final path = Path();
        const pts = 8;
        const outerR = 17.0;
        const innerR = 8.0;
        for (int i = 0; i < pts * 2; i++) {
          final r = i.isEven ? outerR : innerR;
          final angle = (i * math.pi) / pts;
          final x = lesionCenter.dx + r * math.cos(angle);
          final y = lesionCenter.dy + (r * 1.3) * math.sin(angle); // taller than wide
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFF881337)
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFE11D48)
            ..strokeWidth = 1.8
            ..style = PaintingStyle.stroke,
        );
        break;

      case 'exam':
        lesionCenter = const Offset(115, 88);
        arrowStart = const Offset(170, 32);
        // 4 Quadrants dashed lines intersecting at (115, 88)
        final gridPaint = Paint()
          ..color = AppColors.primary.withValues(alpha: 0.5)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        canvas.drawLine(const Offset(60, 88), const Offset(185, 88), gridPaint);
        canvas.drawLine(const Offset(115, 35), const Offset(115, 140), gridPaint);

        // Circular palpation directional track
        final trackPaint = Paint()
          ..color = AppColors.primary
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawArc(
          Rect.fromCircle(center: lesionCenter, radius: 28),
          0.2,
          math.pi * 1.5,
          false,
          trackPaint,
        );
        break;

      default:
        // Healthy baseline
        lesionCenter = const Offset(115, 75);
        arrowStart = const Offset(170, 30);
        break;
    }

    // 5. Stylized Directional ARROW Pointing at the Problem Area
    final arrowPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Arrow line
    canvas.drawLine(arrowStart, lesionCenter, arrowPaint);

    // Arrowhead calculations
    final angle = math.atan2(lesionCenter.dy - arrowStart.dy, lesionCenter.dx - arrowStart.dx);
    const arrowHeadLen = 10.0;
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

    final arrowHeadFill = Paint()
      ..color = themeColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowHeadPath, arrowHeadFill);

    // Origin Pulse Pin on Arrow Start
    canvas.drawCircle(arrowStart, 4.5, arrowHeadFill);
    canvas.drawCircle(
      arrowStart,
      7,
      Paint()
        ..color = themeColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _BreastAnatomyPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.themeColor != themeColor ||
        oldDelegate.isArabic != isArabic;
  }
}
