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
  final String title;
  final String category;
  final String readTime;
  final String doctorReviewer;
  final String summary;
  final String fullContent;
  final IconData icon;
  final String illustrationType; // cyst, fibroadenoma, mastitis, calcification, suspicious, exam, general
  final bool isDoctorPublished;

  EducationArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.readTime,
    required this.doctorReviewer,
    required this.summary,
    required this.fullContent,
    required this.icon,
    this.illustrationType = 'general',
    this.isDoctorPublished = false,
  });
}

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  String _selectedCategory = 'الكل';
  final TextEditingController _searchController = TextEditingController();
  List<EducationArticle> _apiArticles = [];
  bool _isLoadingApi = true;

  final List<EducationArticle> _presetArticles = [
    EducationArticle(
      id: 'art-fibroadenoma',
      title: 'الورم الغدي الليفي (Fibroadenoma): أكثر كتل الثدي الحميدة شيوعاً',
      category: 'كتل حميدة',
      readTime: '٥ دقائق قراءة',
      doctorReviewer: 'إشراف: د. نور الخالدي (استشاري جراحة الأورام)',
      summary: 'كتلة صلبة ملساء ومتحركة تسمى "فأرة الثدي"، شائعة جداً بين سن ١٨ و٣٥ سنة، وهي حميدة ١٠٠٪ ولا تتحول لأورام خبيثة.',
      illustrationType: 'fibroadenoma',
      icon: Icons.bubble_chart_rounded,
      fullContent: '''
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
    ),
    EducationArticle(
      id: 'art-cysts',
      title: 'أكياس الثدي المائية (Breast Cysts): أسبابها وعلاقتها بالهرمونات',
      category: 'أكياس مائية',
      readTime: '٤ دقائق قراءة',
      doctorReviewer: 'إشراف: د. مريم القاضي (استشاري الأشعة التشخيصية)',
      summary: 'حويصلات ممتلئة بسائل ترتبط مباشرة باضطرابات الدورة الشهرية، تظهر في السونار كفراغ أسود نقي (Anechoic) ذو جدار رقيق.',
      illustrationType: 'cyst',
      icon: Icons.water_drop_rounded,
      fullContent: '''
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
    ),
    EducationArticle(
      id: 'art-mastitis',
      title: 'التهاب الثدي وتوسع القنوات اللبنية (Mastitis & Duct Ectasia)',
      category: 'التهابات الثدي',
      readTime: '٤ دقائق قراءة',
      doctorReviewer: 'إشراف: د. سارة عزمي (استشاري طب النساء وجراحة الثدي)',
      summary: 'احمرار موضعي، سخونة وألم نابض شائع أثناء الرضاعة أو قرب انقطاع الطمث. حالة التهابية تستجيب تماماً للمضادات دون جراحة.',
      illustrationType: 'mastitis',
      icon: Icons.local_fire_department_rounded,
      fullContent: '''
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
    ),
    EducationArticle(
      id: 'art-calcifications',
      title: 'التكلسات الدقيقة (Microcalcifications): قراءة نتائج الماموجرام',
      category: 'أشعة وفحوصات',
      readTime: '٥ دقائق قراءة',
      doctorReviewer: 'إشراف: الفريق الاستشاري للأشعة التداخلية',
      summary: 'ترسبات كالسيوم مجهرية تظهر كنقاط بيضاء في الماموجرام، معظمها حميد تماماً، والأنماط العنقودية تتطلب متابعة دقيقة.',
      illustrationType: 'calcification',
      icon: Icons.grain_rounded,
      fullContent: '''
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
    ),
    EducationArticle(
      id: 'art-suspicious',
      title: 'الكتل المشتبه بها وعلامات الإنذار السريري: متى تستشيرين الطبيب فوراً؟',
      category: 'علامات تحذيرية',
      readTime: '٥ دقائق قراءة',
      doctorReviewer: 'إشراف: المجلس الطبي الإكلينيكي لشبكة لوميرا',
      summary: 'كتلة صلبة غير متحركة، حواف غير منتظمة، انكماش في الجلد أو الحلمة، أو إفرازات دموية. علامات تستدعي الفحص السريري المباشر.',
      illustrationType: 'suspicious',
      icon: Icons.warning_amber_rounded,
      fullContent: '''
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
    ),
    EducationArticle(
      id: 'art-mastalgia',
      title: 'ألم الثدي الدوري (Cyclical Mastalgia): هل يرتبط بالأورام؟',
      category: 'صحة عامة',
      readTime: '٣ دقائق قراءة',
      doctorReviewer: 'إشراف: د. نور الخالدي',
      summary: 'ألم الثدي ظاهرة فسيولوجية طبيعية جداً لدى أكثر من ٧٠٪ من السيدات، وأكثر من ٩٠٪ من حالات الألم لا ترتبط إطلاقاً بالأورام الخبيثة.',
      illustrationType: 'general',
      icon: Icons.health_and_safety_rounded,
      fullContent: '''
حقيقة سريرية مطمئنة:
أكثر من ٩٠٪ من حالات ألم الثدي ليست ناتجة عن أورام خبيثة إطلاقاً. الأورام السرطانية نادراً ما تسبب ألماً في مراحلها المبكرة.

أسباب ألم الثدي الشائعة:
١. الألم الدوري المرتبط بالطمث: ثقل واحتقان يزداد قبل موعد الدورة الشهرية بأيام نتيجة استجابة أنسجة الغدد اللبنية لارتفاع هرموني الإستروجين والبروجسترون.
٢. المنبهات والكافيين: الإكثار من الشاي والقهوة والمشروبات الغازية والشوكولاتة يرفع حساسية الأنسجة للألم.
٣. ارتداء حمالات صدر غير ملائمة الحجم أو داعمة بشكل غير مريح.

نصائح عملية للتخفيف من الألم:
• تقليل الكافيين والسكريات المصنعة قبل موعد الدورة.
• ارتداء حمالة صدر رياضية مريحة وداعمة بدون أسلاك معدنية.
• استشارة الطبيب لوصف مكملات مثل زيت زهرة الربيع المسائية (Evening Primrose Oil) أو فيتامين E لدعم توازن الأنسجة.
''',
    ),
    EducationArticle(
      id: 'art-1',
      title: 'الفحص الذاتي الشهري للثدي: دليلكِ العملي خطوة بخطوة',
      category: 'فحص ذاتي',
      readTime: '٤ دقائق قراءة',
      doctorReviewer: 'إشراف: د. نور الخالدي',
      summary: 'تعلمي التوقيت المثالي بعد انتهاء الدورة الشهرية بأسبوع، والخطوات الثلاث: أمام المرآة، أثناء الاستحمام، وأثناء الاستلقاء.',
      illustrationType: 'exam',
      icon: Icons.accessibility_new_rounded,
      fullContent: '''
الخطوة الأولى: الفحص البصري أمام المرآة
قفي أمام المرآة وكتفاكِ مستقيمان ويداكِ على وركيكِ. لاحظي شكل الثديين وتماثلهما، وتأكدي من عدم وجود أي انبعاجات، احمرار، أو تغيرات في ملمس الجلد.

الخطوة الثانية: رفع الذراعين
ارفعي ذراعيكِ للأعلى وابحثي عن نفس التغيرات وتأكدي من عدم وجود أي إفرازات غير طبيعية من الحلمة.

الخطوة الثالثة: الفحص اليدوي
استخدمي باطن أصابع يدكِ الثلاثة بحركات دائرية خفيفة، ثم متوسطة، ثم عميقة لتغطية كامل منطقة الثدي والإبط.

ملاحظة هامة:
الفحص الذاتي يساعدكِ على معرفة طبيعة جسمكِ، ولا يغني عن فحص الماموجرام السنوي بعد سن الأربعين.
''',
    ),
    EducationArticle(
      id: 'art-2',
      title: 'الفرق بين الماموجرام والسونار: متى يوصي الطبيب بكل منهما؟',
      category: 'أشعة وفحوصات',
      readTime: '٥ دقائق قراءة',
      doctorReviewer: 'إشراف: د. مريم القاضي',
      summary: 'الماموجرام هو الفحص الذهبي المعتمد للكشف المبكر، بينما السونار (الموجات فوق الصوتية) مكمل مثالي لتقييم الأنسجة الكثيفة والكتل السائلة.',
      illustrationType: 'calcification',
      icon: Icons.biotech_rounded,
      fullContent: '''
يعد الماموجرام الفحص الأساسي للكشف عن التكلسات الدقيقة التي لا يمكن الشعور بها باليد، ويوصى به سنوياً للسيدات فوق سن الأربعين.

أما الموجات فوق الصوتية (السونار) فتستخدم كفحص مكمل لتحديد ما إذا كانت الكتلة صلبة أو كيسية ممتلئة بسائل، وتعتبر مناسبة جداً للسيدات الأصغر سناً ذوات الأنسجة الثديية الكثيفة.
''',
    ),
    EducationArticle(
      id: 'art-3',
      title: 'التغذية المضادة للالتهاب ونمط الحياة الداعم لصحة الثدي',
      category: 'صحة عامة',
      readTime: '٣ دقائق قراءة',
      doctorReviewer: 'إشراف: د. سارة عزمي',
      summary: 'أهمية الخضروات الصليبية، أوميجا ٣، تقليل السكريات المصنعة، وممارسة المشي المنتظم لتعزيز المناعة وتوازن الهرمونات.',
      illustrationType: 'general',
      icon: Icons.restaurant_menu_rounded,
      fullContent: '''
الدراسات الإكلينيكية تؤكد أن اتباع نمط غذائي غني بمضادات الأكسدة والخضروات مثل البروكلي والقرنبيط، بالإضافة إلى بذور الكتان والمصادر الطبيعية لأوميجا ٣، يساهم في دعم المناعة والتوازن الهرموني الطبيعي.
''',
    ),
    EducationArticle(
      id: 'art-4',
      title: 'التعامل مع التعب والإرهاق أثناء تناول العلاج الهرموني',
      category: 'علاج ودعم',
      readTime: '٤ دقائق قراءة',
      doctorReviewer: 'إشراف: فريق لوميرا السريري',
      summary: 'إرشادات عملية لتنظيم فترات الراحة، التمارين الخفيفة، والترطيب لتقليل الآثار الجانبية لعلاجات مثل التاموكسيفين ومثبطات الأروماتاز.',
      illustrationType: 'general',
      icon: Icons.spa_rounded,
      fullContent: '''
يعد الإرهاق عرضاً شائعاً ومؤقتاً. يساعد تنظيم مواعيد النوم، شرب كميات كافية من الماء (٢-٣ لتر يومياً)، وتوزيع المجهود البدني على فترات اليوم في تقليل الشعور بالتعب بشكل فعال.
''',
    ),
  ];

  final List<String> _categories = [
    'الكل',
    'كتل حميدة',
    'أكياس مائية',
    'التهابات الثدي',
    'علامات تحذيرية',
    'أشعة وفحوصات',
    'فحص ذاتي',
    'صحة عامة',
    'علاج ودعم',
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
            final titleAr = m['titleAr']?.toString();
            final titleEn = m['titleEn']?.toString();
            final summaryAr = m['summaryAr']?.toString() ?? m['summaryEn']?.toString() ?? '';
            final contentAr = m['contentMarkdownAr']?.toString() ?? m['contentMarkdownEn']?.toString() ?? summaryAr;

            // Avoid duplicating if matches one of the preset ids
            final id = m['id']?.toString() ?? 'api-${DateTime.now().millisecondsSinceEpoch}';
            if (_presetArticles.any((p) => p.id == id)) continue;

            fetched.add(
              EducationArticle(
                id: id,
                title: titleAr ?? titleEn ?? 'مقال طبي استشاري جديد',
                category: m['category']?['nameAr']?.toString() ?? 'مقالات استشارية',
                readTime: '${m['readTimeMinutes'] ?? 4} دقائق قراءة',
                doctorReviewer: 'نشر بواسطة: د. استشاري شبكة لوميرا',
                summary: summaryAr,
                fullContent: contentAr,
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

  Widget _buildArticleIllustration(EducationArticle article) {
    Color primaryColor = AppColors.primary;
    Color bgColor = AppColors.powderBackground;
    String badgeText = 'مخطط توضيحي سريري';
    Widget visualWidget;

    switch (article.illustrationType) {
      case 'cyst':
        primaryColor = const Color(0xFF0284C7);
        bgColor = const Color(0xFFE0F2FE);
        badgeText = 'كيس مائي • Anechoic Cyst';
        visualWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF38BDF8), width: 3),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0284C7).withValues(alpha: 0.3), blurRadius: 10),
                ],
              ),
              child: const Center(
                child: Icon(Icons.water_drop_rounded, color: Color(0xFF38BDF8), size: 36),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الموجات فوق الصوتية (السونار):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0369A1))),
                  SizedBox(height: 2),
                  Text('• فراغ أسود نقي (سائل بالكامل)\n• جدار أملس ورقيق منتظم\n• ارتداد صوتي خلفي نقي\n• تصنيف BI-RADS 2 (حميد 100%)', style: TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.4)),
                ],
              ),
            ),
          ],
        );
        break;

      case 'fibroadenoma':
        primaryColor = const Color(0xFFD946EF);
        bgColor = const Color(0xFFFDF4FF);
        badgeText = 'ورم غدي ليفي • Fibroadenoma';
        visualWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE7F3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFD946EF), width: 2.5),
              ),
              child: const Center(
                child: Icon(Icons.grain_rounded, color: Color(0xFFC026D3), size: 32),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الخصائص السريرية:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF86198F))),
                  SizedBox(height: 2),
                  Text('• كتلة كروية ملساء ومطاطية\n• تتحرك بحرية ("فأرة الثدي")\n• بيضاوية الشكل أفقية بالسونار\n• شائعة تحت سن 35 سنة وحميدة', style: TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.4)),
                ],
              ),
            ),
          ],
        );
        break;

      case 'mastitis':
        primaryColor = const Color(0xFFEA580C);
        bgColor = const Color(0xFFFFF7ED);
        badgeText = 'التهاب الأنسجة • Mastitis';
        visualWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEDD5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEA580C), width: 2.5),
              ),
              child: const Center(
                child: Icon(Icons.local_fire_department_rounded, color: Color(0xFFEA580C), size: 36),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('العلامات الالتهابية:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFC2410C))),
                  SizedBox(height: 2),
                  Text('• احمرار جلدي وسخونة موضعية\n• ألم وتورم ناتج عن انسداد القنوات\n• زيادة تدفق الدم الالتهابي بالسونار\n• تستجيب تماماً للمضادات الحيوية', style: TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.4)),
                ],
              ),
            ),
          ],
        );
        break;

      case 'calcification':
        primaryColor = const Color(0xFF475569);
        bgColor = const Color(0xFFF1F5F9);
        badgeText = 'تكلسات الثدي • Microcalcifications';
        visualWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF94A3B8), width: 2),
              ),
              child: const Center(
                child: Icon(Icons.blur_on_rounded, color: Colors.white, size: 38),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('أشعة الماموجرام الرقمية:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                  SizedBox(height: 2),
                  Text('• ترسبات كالسيوم دقيقة مجهرية\n• غير ملموسة ولا تسبب أي ألم\n• المتباعدة منها حميدة بالكامل\n• المجمعة تقيم بدقة بالماموجرام', style: TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.4)),
                ],
              ),
            ),
          ],
        );
        break;

      case 'suspicious':
        primaryColor = AppColors.error;
        bgColor = const Color(0xFFFEF2F2);
        badgeText = 'علامات الإنذار السريري • Warning Signs';
        visualWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.error, width: 2.5),
              ),
              child: const Center(
                child: Icon(Icons.priority_high_rounded, color: AppColors.error, size: 36),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المؤشرات التي تستدعي الفحص الفوري:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.error)),
                  SizedBox(height: 2),
                  Text('• كتلة صلبة غير متحركة وحواف غير منتظمة\n• انكماش أو تجعد بجلد الثدي أو الحلمة\n• إفرازات دموية تلقائية من جهة واحدة\n• تستلزم أشعة وخزعة نسيجية موجهة', style: TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.4)),
                ],
              ),
            ),
          ],
        );
        break;

      default:
        primaryColor = AppColors.primary;
        bgColor = AppColors.powderBackground;
        badgeText = article.isDoctorPublished ? 'مقال سريري منشور من الطبيب' : 'إرشاد سريري معتمد';
        visualWidget = Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.whiteSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(article.icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                article.summary,
                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.4),
              ),
            ),
          ],
        );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          visualWidget,
        ],
      ),
    );
  }

  void _openArticleDetails(EducationArticle article) {
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
                      StatusBadge.active(article.category),
                      if (article.isDoctorPublished) ...[
                        const SizedBox(width: 8),
                        StatusBadge.info(context.isArabic ? 'جديد من الطبيب' : 'New by Doctor'),
                      ],
                      const Spacer(),
                      Text(article.readTime, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.doctorReviewer,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 16),

                  // Visual Illustration Box
                  _buildArticleIllustration(article),

                  const Divider(height: 32),
                  Text(
                    article.fullContent,
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
                            context.isArabic
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
                    label: context.isArabic ? 'إغلاق المقال' : 'Close Article',
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
    final query = _searchController.text.trim().toLowerCase();
    final all = _allArticles;
    final filtered = all.where((art) {
      final matchesCategory = _selectedCategory == 'الكل' || art.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          art.title.toLowerCase().contains(query) ||
          art.summary.toLowerCase().contains(query) ||
          art.fullContent.toLowerCase().contains(query);
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
                  hintText: context.isArabic ? 'ابحثي في الحالات السريرية وأدلة الفحص...' : 'Search clinical cases and guides...',
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

              // Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
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
                        onSelected: (_) => setState(() => _selectedCategory = cat),
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
                              StatusBadge.active(context.isArabic ? 'دليل موجه تفاعلي' : 'Featured Guide'),
                              const SizedBox(height: 4),
                              Text(
                                context.isArabic ? 'الفحص الذاتي الشهري خطوة بخطوة' : 'Monthly Self-Exam Guide',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.isArabic
                          ? 'تعلمي الطريقة الصحيحة لاكتشاف أي تغيرات مبكرة في أنسجة الثدي بأسلوب إكلينيكي بسيط ومطمئن.'
                          : 'A step-by-step clinical guide to familiarizing yourself with your breast health.',
                      style: const TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    PillButton(
                      label: context.isArabic ? 'بدء قراءة الدليل الآن' : 'Read Interactive Guide',
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
                    context.isArabic ? 'المكتبة السريرية المعتمدة (${filtered.length})' : 'Clinical Library (${filtered.length})',
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
                                    art.category,
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
                                      child: const Text(
                                        'نشر حديثاً',
                                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  Text(art.readTime, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                art.title,
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.3),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                art.summary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                art.doctorReviewer,
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
