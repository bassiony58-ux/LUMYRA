import 'dart:math' as math;

/// The 15 distinct, anatomically accurate structures of the human female breast.
enum BreastTissueId {
  skin('skin', 'Breast Skin', 'جلد الثدي'),
  areola('areola', 'Areola', 'الهالة'),
  nipple('nipple', 'Nipple-Areola Complex', 'الحلمة'),
  adipose('adipose', 'Adipose Tissue', 'الأنسجة الدهنية'),
  glandular('glandular', 'Glandular Parenchyma', 'الأنسجة الغدية'),
  mammaryLobes('mammary_lobes', 'Mammary Lobes (15-20)', 'فصوص الغدة اللبنية'),
  lobules('lobules', 'Lobules & TDLUs', 'الفصيصات والوحدات القنوية'),
  lactiferousDucts('lactiferous_ducts', 'Lactiferous Ducts & Sinuses', 'القنوات والجيوب اللبنية'),
  coopersLigaments('coopers_ligaments', "Cooper's Suspensory Ligaments", 'أربطة كوبر المعلقة'),
  retromammarySpace('retromammary_space', 'Retromammary Space (Chassaignac)', 'المساحة خلف الثدي'),
  pectoralisMajor('pectoralis_major', 'Pectoralis Major Muscle', 'العضلة الصدرية الكبرى'),
  ribsIntercostal('ribs_intercostal', 'Ribs & Intercostal Muscles', 'الأضلاع والعضلات الوربية'),
  axillaryTail('axillary_tail', 'Axillary Tail of Spence', 'ذيل سبنس الإبطي'),
  axillaryLymphNodes('axillary_lymph_nodes', 'Axillary Lymph Nodes (Levels I-III)', 'العقد الليمفاوية الإبطية'),
  lymphaticVessels('lymphatic_vessels', 'Lymphatic Vessels & Drainage', 'الأوعية والمسارات الليمفاوية');

  final String key;
  final String nameEn;
  final String nameAr;
  const BreastTissueId(this.key, this.nameEn, this.nameAr);

  String name(bool isArabic) => isArabic ? nameAr : nameEn;
}

/// The 6 dedicated viewing and clinical analysis modes.
enum AnatomicalViewMode {
  normalAnatomy('normal', 'التشريح الطبيعي', 'Normal Anatomy'),
  tissueExploration('explore', 'استكشاف الأنسجة', 'Tissue Exploration'),
  tumorVisualization('tumor', 'إظهار الورم والكتلة', 'Tumor Visualization'),
  lymphNodes('lymph', 'العقد والمسارات الليمفاوية', 'Lymph Node Pathways'),
  patientScanOverlay('scan_overlay', 'ربط صور وفحوصات المريضة', 'Patient Scan Overlay'),
  comparisonMode('comparison', 'مقارنة الطبيعي بالمرضي', 'Comparison Mode');

  final String id;
  final String titleAr;
  final String titleEn;
  const AnatomicalViewMode(this.id, this.titleAr, this.titleEn);

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
}

/// Clinical classification of localized lesion findings.
enum LesionFindingType {
  confirmedMalignant('confirmed', 'ورم مؤكد', 'Confirmed Malignancy', 0xFFBE123C),
  suspicious('suspicious', 'منطقة مشتبه بها (BI-RADS 4/5)', 'Suspicious Area', 0xFFF97316),
  benign('benign', 'كتلة حميدة (BI-RADS 2/3)', 'Benign Lesion', 0xFF0284C7),
  unevaluated('unevaluated', 'منطقة لم تُقيّم بعد', 'Unevaluated Zone', 0xFF64748B);

  final String id;
  final String labelAr;
  final String labelEn;
  final int colorValue;
  const LesionFindingType(this.id, this.labelAr, this.labelEn, this.colorValue);

  String label(bool isArabic) => isArabic ? labelAr : labelEn;
}

/// Anatomical quadrant definition.
enum BreastQuadrant {
  upperOuter('UOQ', 'الربع العلوي الخارجي', 'Upper-Outer Quadrant (50% prevalence)'),
  upperInner('UIQ', 'الربع العلوي الداخلي', 'Upper-Inner Quadrant'),
  lowerOuter('LOQ', 'الربع السفلي الخارجي', 'Lower-Outer Quadrant'),
  lowerInner('LIQ', 'الربع السفلي الداخلي', 'Lower-Inner Quadrant'),
  centralSubareolar('Central', 'المنطقة المركزية خلف الهالة', 'Central / Retroareolar'),
  axillaryTail('AxillaryTail', 'ذيل سبنس الإبطي', 'Axillary Tail of Spence');

  final String code;
  final String labelAr;
  final String labelEn;
  const BreastQuadrant(this.code, this.labelAr, this.labelEn);

  String label(bool isArabic) => isArabic ? labelAr : labelEn;
}

/// Patient Scan Localization Data.
///
/// Strictly follows clinical guidelines:
/// If spatial coordinates / segmentation are insufficient,
/// [isSpatialLocationVerified] is false and the UI displays an explicit
/// non-localized alert, NEVER fabricating false coordinates.
class PatientLesionLocalization {
  final bool isSpatialLocationVerified;
  final String? patientId;
  final String? scanId;
  final String? scanModality; // Mammogram, Ultrasound, MRI, PET/CT
  final BreastQuadrant quadrant;
  final int clockPosition; // 1 to 12
  final double distanceFromNippleMm;
  final double depthFromSkinMm;
  final double sizeLengthMm;
  final double sizeWidthMm;
  final double sizeDepthMm;
  final LesionFindingType findingType;
  final String biRadsClass;
  final BreastTissueId originTissue;
  final bool lymphNodeAbnormalityDetected;
  final String? lymphNodeLevelDescription;
  final bool distantMetastasisEvidence;
  final String? distantMetastasisNotes;
  final String? clinicalPathologyNotes;

  const PatientLesionLocalization({
    required this.isSpatialLocationVerified,
    this.patientId,
    this.scanId,
    this.scanModality,
    this.quadrant = BreastQuadrant.upperOuter,
    this.clockPosition = 10,
    this.distanceFromNippleMm = 35.0,
    this.depthFromSkinMm = 18.0,
    this.sizeLengthMm = 18.5,
    this.sizeWidthMm = 14.0,
    this.sizeDepthMm = 12.0,
    this.findingType = LesionFindingType.confirmedMalignant,
    this.biRadsClass = 'BI-RADS 4C',
    this.originTissue = BreastTissueId.lobules,
    this.lymphNodeAbnormalityDetected = true,
    this.lymphNodeLevelDescription = 'عقدة ليمفاوية إبطية متضخمة في المستوى الأول (Level I) بسمك قشرة 4.2 مم',
    this.distantMetastasisEvidence = false,
    this.distantMetastasisNotes,
    this.clinicalPathologyNotes,
  });

  /// Factory creating an unlocalized safe finding (Rule: Never fabricate coordinates if data is insufficient).
  factory PatientLesionLocalization.unlocalized({
    required String reasonAr,
    required String reasonEn,
    String biRads = 'BI-RADS 0',
  }) {
    return PatientLesionLocalization(
      isSpatialLocationVerified: false,
      biRadsClass: biRads,
      findingType: LesionFindingType.unevaluated,
      clinicalPathologyNotes: reasonAr,
    );
  }

  /// Calculates normalized 3D coordinates (x, y, z) on the breast volume based on clock position, distance, and depth.
  ({double x, double y, double z}) compute3dCoordinates() {
    if (!isSpatialLocationVerified) {
      return (x: 0.0, y: 0.0, z: 0.0);
    }
    // Clock position in radians: 12 o'clock = -pi/2, 3 o'clock = 0, 6 o'clock = pi/2, 9 o'clock = pi
    final angle = (clockPosition - 3) * (math.pi / 6);
    final radius = (distanceFromNippleMm * 1.3).clamp(10.0, 75.0);
    final x = math.cos(angle) * radius;
    final y = math.sin(angle) * radius;
    // z is depth (negative goes inward toward chest wall)
    final z = -(depthFromSkinMm * 1.5).clamp(5.0, 60.0);
    return (x: x, y: y, z: z);
  }
}

/// Comprehensive Medical Information for a specific breast tissue.
class BreastTissueInfo {
  final BreastTissueId id;
  final String functionAr;
  final String functionEn;
  final String anatomyAr;
  final String anatomyEn;
  final String relativePositionAr;
  final String relativePositionEn;
  final String clinicalSignificanceAr;
  final String clinicalSignificanceEn;
  final List<String> commonPathologiesAr;
  final List<String> commonPathologiesEn;
  final String ultrasoundFindingsAr;
  final String ultrasoundFindingsEn;
  final String mriFindingsAr;
  final String mriFindingsEn;
  final String petCtFindingsAr;
  final String petCtFindingsEn;

  const BreastTissueInfo({
    required this.id,
    required this.functionAr,
    required this.functionEn,
    required this.anatomyAr,
    required this.anatomyEn,
    required this.relativePositionAr,
    required this.relativePositionEn,
    required this.clinicalSignificanceAr,
    required this.clinicalSignificanceEn,
    required this.commonPathologiesAr,
    required this.commonPathologiesEn,
    required this.ultrasoundFindingsAr,
    required this.ultrasoundFindingsEn,
    required this.mriFindingsAr,
    required this.mriFindingsEn,
    required this.petCtFindingsAr,
    required this.petCtFindingsEn,
  });
}

/// Master Medical Knowledge Base detailing all 15 breast anatomical tissues.
class BreastAnatomyKnowledgeBase {
  static const Map<BreastTissueId, BreastTissueInfo> tissues = {
    BreastTissueId.skin: BreastTissueInfo(
      id: BreastTissueId.skin,
      functionAr: 'حماية الأنسجة الداخلية، تنظيم الحرارة عبر الأوعية السطحية، واحتواء المستقبلات اللمسية والحسية الدقيقة.',
      functionEn: 'Protects internal parenchyma, provides thermoregulation via superficial cutaneous microvasculature, and houses sensory receptors.',
      anatomyAr: 'طبقة خارجية من النسيج الطلائي الحرشفي المتقرن (Epidermis) تعلو الأدمة الغنية بألياف الكولاجين والإيلاستين، بسماكة طبيعية تتراوح بين 0.8 إلى 2 مم.',
      anatomyEn: 'Keratinized stratified squamous epidermis overlying collagen- and elastin-rich dermis, measuring 0.8 to 2.0 mm under physiological conditions.',
      relativePositionAr: 'الغلاف الخارجي المحيط بالثدي بالكامل، يرتكز تحته مباشرة النسيج الدهني السطحي وترتبط به نهايات أربطة كوبر.',
      relativePositionEn: 'The outermost anatomical envelope directly anchored to subcutaneous adipose tissue and superficial insertions of Cooper ligaments.',
      clinicalSignificanceAr: 'انكماش الجلد (Dimpling) مؤشر لشد أربطة كوبر بورم كامن؛ وتثخن الجلد بمظهر قشرة البرتقال (Peau d’orange) يشير لانسداد ليمفاوي في السرطان الالتهابي.',
      clinicalSignificanceEn: 'Skin tethering/dimpling indicates tumor traction on Cooper ligaments; thickening with peau d’orange indicates subdermal lymphatic obstruction.',
      commonPathologiesAr: ['انكماش وتنقير الجلد الورمي', 'تغير قشرة البرتقال (Peau d’orange)', 'سرطان الثدي الالتهابي (IBC)', 'الأكزيما والتهاب الجلد'],
      commonPathologiesEn: ['Tumoral Skin Dimpling', 'Peau d’orange Pattern', 'Inflammatory Breast Cancer', 'Contact Dermatitis'],
      ultrasoundFindingsAr: 'شريط سطحي مفرط الصدى (Hyperechoic) منتظم بسماكة طبيعية أقل من 2 مم. زيادة السماكة لأكثر من 3 مم تعكس وذمة أو ارتشاحاً ليمفاوياً.',
      ultrasoundFindingsEn: 'Uniform hyperechoic continuous band <2 mm. Caliber exceeding 3 mm suggests dermal edema, mastitis, or lymphangitic carcinomatosis.',
      mriFindingsAr: 'خط رقيق منخفض الشدة في صور T1 و T2. يُظهر تعزيزاً سريعاً ومكثفاً في حالات السرطان الالتهابي المتقدم.',
      mriFindingsEn: 'Thin low-signal stripe on T1/T2. Demonstrates intense rapid contrast enhancement when neoplastic infiltration occurs.',
      petCtFindingsAr: 'امتصاص فسيولوجي منخفض للغاية لجزيئات 18F-FDG. زيادة الامتصاص الموضعي المنتشر دلالة قوية على ارتشاح ورمي جلدي.',
      petCtFindingsEn: 'Minimal physiological 18F-FDG uptake. Diffuse intense tracer uptake confirms active malignant cutaneous infiltration.',
    ),
    BreastTissueId.areola: BreastTissueInfo(
      id: BreastTissueId.areola,
      functionAr: 'حماية وتليين منطقة الحلمة أثناء الرضاعة عبر إفرازات غدد مونتغمري الدهنية، واحتواء عضلات ملساء لا إرادية تنقبض بالتنبيه.',
      functionEn: 'Lubricates and protects nipple-areolar complex via Montgomery gland secretions; houses smooth muscle fibers producing contractile response.',
      anatomyAr: 'قرص جلدي دائري ملون قطره 2.5 إلى 4.5 سم، يتميز بزيادة صبغة الميلانين وغدد مونتغمري السطحية (Areolar tubercles) وألياف عضلية ملساء دائرية وشعاعية.',
      anatomyEn: 'Circular pigmented zone (2.5–4.5 cm) enriched with melanin, superficial Montgomery sebaceous tubercles, and radial/circular smooth muscle fibers.',
      relativePositionAr: 'تحيط بالحلمة في قمة الثدي، وتقع فوق الجيوب اللبنية المتسعة مباشرة (Lactiferous ampullae).',
      relativePositionEn: 'Encircles the central nipple at the breast apex directly overlying the subareolar lactiferous sinuses.',
      clinicalSignificanceAr: 'تغيرات التقشر والاحمرار قد تعكس مرض باجيت؛ والكتل خلف الهالة تستدعي تقييماً دقيقاً لقنوات الحليب الرئيسية.',
      clinicalSignificanceEn: 'Eczematous scaling may represent Paget disease; subareolar nodules require targeted evaluation of the main lactiferous ducts.',
      commonPathologiesAr: ['مرض باجيت في الهالة (Paget Disease)', 'خراج خلف الهالة (Subareolar Abscess)', 'توسع القنوات اللبنية (Duct Ectasia)'],
      commonPathologiesEn: ['Paget Disease of the Areola', 'Subareolar Abscess', 'Mammary Duct Ectasia'],
      ultrasoundFindingsAr: 'طبقة سطحية رقيقة تعلو القنوات اللبنية المتوسعة؛ يظهر الخراج ككتلة مختلطة الصدى مع زيادة التروية الدموية بالدوبلر.',
      ultrasoundFindingsEn: 'Superficial skin layer overlying subareolar ducts; abscesses present as complex hypoechoic collections with peripheral Doppler hyperemia.',
      mriFindingsAr: 'تعزيز متماثل رقيق. في مرض باجيت، يظهر تعزيز غير متناظر مصحوباً بارتشاح في القنوات الكامنة خلف الهالة.',
      mriFindingsEn: 'Symmetrical thin enhancement. Paget disease produces prominent asymmetric enhancement extending to underlying ducts.',
      petCtFindingsAr: 'نشاط أيضي طبيعي منخفض، ويظهر نشاطاً بؤرياً مرتفعاً في الأورام الممتدة للهالة.',
      petCtFindingsEn: 'Low baseline metabolic activity; focal hypermetabolism reflects direct malignant extension.',
    ),
    BreastTissueId.nipple: BreastTissueInfo(
      id: BreastTissueId.nipple,
      functionAr: 'المخرج النهائي لخروج الحليب عبر 15-20 مساماً دقيقاً، مع وظيفة حسية واستجابية عالية عبر الألياف العصبية الحسية.',
      functionEn: 'Terminal conduit for milk delivery via 15–20 delicate duct orifices; highly innervated for tactile neuroendocrine reflex.',
      anatomyAr: 'نتوء أسطواني إسفنجي يتكون من ألياف عضلية ملساء، أوعية دموية مرنة، ونهايات القنوات اللبنية المبطنة بنسيج طلائي عمادي مطبق.',
      anatomyEn: 'Cylindrical papilla composed of smooth muscle, dense fibroelastic stroma, and terminal duct orifices lined by stratified columnar epithelium.',
      relativePositionAr: 'القمة التشريحية للثدي عند مستوى الحيز الوربي الرابع في الوضع الطبيعي، محاطة بالهالة.',
      relativePositionEn: 'The anatomical apex at the 4th intercostal space in nulliparous anatomy, centered within the areola.',
      clinicalSignificanceAr: 'الانقلاب أو الانكماش الحديث غير المبرر للحلمة يعد علامة إنذار لورم خلف الهالة؛ والإفرازات الدموية من مسام واحد تدل على ورم حليمي.',
      clinicalSignificanceEn: 'Recent spontaneous nipple inversion signals retroareolar malignancy; unilateral single-pore bloody discharge suggests intraductal papilloma.',
      commonPathologiesAr: ['انقلاب الحلمة المرضي (Nipple Retraction)', 'الورم الحليمي داخل القناة (Intraductal Papilloma)', 'مرض باجيت الحلمي', 'الناسور اللبني'],
      commonPathologiesEn: ['Pathological Nipple Retraction', 'Intraductal Papilloma', 'Paget Disease of the Nipple', 'Mammary Fistula'],
      ultrasoundFindingsAr: 'سونار عالي التردد بزاوية مائلة يوضح القنوات اللبنية ومساراتها؛ والورم الحليمي يظهر ككتلة مفرطة الصدى داخل لمعة القناة.',
      ultrasoundFindingsEn: 'High-frequency angled sonography resolves ductal arborization; papillomas appear as echogenic endoluminal mural lesions.',
      mriFindingsAr: 'انكماش الحلمة يظهر كالتواء في مسار القنوات مع تعزيز بؤري في النسيج المغذي.',
      mriFindingsEn: 'Nipple retraction shows architectural distortion of ductal convergence with localized pathological enhancement.',
      petCtFindingsAr: 'نشاط استقلابي منخفض؛ الامتصاص العالي يقتصر على الأورام الغازية لمجمع الحلمة والهالة.',
      petCtFindingsEn: 'Low baseline uptake; intense FDG concentration indicates invasive involvement of the nipple complex.',
    ),
    BreastTissueId.adipose: BreastTissueInfo(
      id: BreastTissueId.adipose,
      functionAr: 'توفير الحماية الميكانيكية وامتصاص الصدمات، تخزين الطاقة، وإفراز الهرمونات الموضعية مثل هرمون الإستروجين عبر إنزيم الأروماتاز.',
      functionEn: 'Mechanical cushioning, energy reserve, and local endocrine synthesis via aromatase conversion of androgens to estrogens.',
      anatomyAr: 'خلايا دهنية شحمية ناضجة (Adipocytes) تتجمع في فصيصات يفصل بينها حواجز ضامة من الكولاجين، تملأ المساحات تحت الجلد وخلف الثدي وبين الفصوص.',
      anatomyEn: 'Mature lobulated adipocytes compartmentalized by collagenous fibrous septa, distributed in subcutaneous, interlobar, and retromammary spaces.',
      relativePositionAr: 'يحيط بالأنسجة الغدية من الأمام (الدهن السطحي) ومن الخلف (الدهن العميق خلف الثدي).',
      relativePositionEn: 'Envelopes glandular parenchyma anteriorly (subcutaneous fat) and posteriorly (retromammary fat layer).',
      clinicalSignificanceAr: 'زيادة النسيج الدهني بعد انقطاع الطمث تزيد نشاط الأروماتاز ومخاطر الأورام الهرمونية؛ ويتعرض للنخر الدهني بعد الكدمات والعمليات.',
      clinicalSignificanceEn: 'Adipose expansion post-menopause elevates aromatase-derived estrogen; undergoes benign aseptic fat necrosis post-trauma/biopsy.',
      commonPathologiesAr: ['النخر الدهني (Fat Necrosis)', 'الأكياس الزيتية (Oil Cysts)', 'الورم الشحمي الحميد (Lipoma)'],
      commonPathologiesEn: ['Fat Necrosis', 'Oil Cysts', 'Lipoma'],
      ultrasoundFindingsAr: 'كتل بيضاوية منخفضة الصدى (Hypoechoic) نسبياً محاطة بحواجز مفرطة الصدى. الأكياس الزيتية تظهر كفراغات شفافة ذات تكلس قشري.',
      ultrasoundFindingsEn: 'Homogeneous mildly hypoechoic lobules enclosed by bright fibrous septa. Oil cysts present with hyperechoic calcified rims.',
      mriFindingsAr: 'إشارة مرتفعة في تسلسل T1 وإشارة منخفضة جداً عند تطبيق تسلسلات إخماد الدهون (Fat Saturation).',
      mriFindingsEn: 'High signal intensity on T1-weighted sequences, completely suppressed under Fat-Suppressed/STIR protocols.',
      petCtFindingsAr: 'امتصاص منخفض للـ FDG ما لم يكن هناك نخر دهني التهابي نشط قد يظهر امتصاصاً كاذباً خفيفاً.',
      petCtFindingsEn: 'Minimal background uptake, except during acute inflammatory fat necrosis which may show low-grade reactive avidity.',
    ),
    BreastTissueId.glandular: BreastTissueInfo(
      id: BreastTissueId.glandular,
      functionAr: 'النسيج المتخصص المسؤول عن تصنيع وإفراز وتعديل الحليب للاستجابة للتغيرات الهرمونية خلال الحمل والرضاعة ودورة الطمث.',
      functionEn: 'Specialized functional parenchyma responsible for synthesis and secretion of milk, cycling under reproductive hormonal control.',
      anatomyAr: 'مزيج مركب من خلايا طلائية إفرازية (Epithelial)، خلايا عضلية طلائية انقباضية (Myoepithelial)، وسدى متخصصة غنية بالأوعية والألياف.',
      anatomyEn: 'Epithelial secretory cells and contractile myoepithelial cells supported by hormonally responsive specialized intralobular stroma.',
      relativePositionAr: 'يقع في مركز الثدي بين النسيج الدهني السطحي والعميق، محاطاً بأربطة كوبر المعلقة.',
      relativePositionEn: 'Occupies central breast core sandwiched between subcutaneous and retromammary adipose layers, tethered by Cooper ligaments.',
      clinicalSignificanceAr: 'منشأ أكثر من 95% من أورام الثدي الحميدة والخبيثة (السرطان القنوي والفصيصي)؛ تزيد كثافته من صعوبة قراءة الماموجرام العادي.',
      clinicalSignificanceEn: 'Site of origin for >95% of benign and malignant breast neoplasms; high parenchymal density reduces screening mammography sensitivity.',
      commonPathologiesAr: ['الورم الغدي الليفي (Fibroadenoma)', 'سرطان القنوات الغازي (IDC)', 'السرطان الفصيصي الغازي (ILC)', 'التغير الكيسي الليفي'],
      commonPathologiesEn: ['Fibroadenoma', 'Invasive Ductal Carcinoma', 'Invasive Lobular Carcinoma', 'Fibrocystic Changes'],
      ultrasoundFindingsAr: 'منطقة مفرطة الصدى ومحببة بانتظام؛ الأورام الخبيثة تظهر ككتل صلبة غير متجانسة منخفضة الصدى ذات ظل صوتي خلفي.',
      ultrasoundFindingsEn: 'Homogeneously echogenic granular zone; malignancies manifest as non-homogeneous hypoechoic masses with posterior shadowing.',
      mriFindingsAr: 'إشارة متوسطة في T1 و T2؛ الأورام الخبيثة تُظهر تعزيزاً سريعاً يتبعه غسيل سريع للصبغة (Type III Washout Curve).',
      mriFindingsEn: 'Intermediate T1/T2 signal; malignant lesions show rapid early enhancement with subsequent washout (Type III kinetic curve).',
      petCtFindingsAr: 'الأورام الخبيثة النشطة تُظهر امتصاصاً بؤرياً مكثفاً لـ FDG (SUVmax مرتفع يعكس الشراسة الأيضية).',
      petCtFindingsEn: 'Active carcinomas exhibit intense focal FDG uptake (elevated SUVmax correlating with histological grade and proliferation).',
    ),
    BreastTissueId.mammaryLobes: BreastTissueInfo(
      id: BreastTissueId.mammaryLobes,
      functionAr: 'تقسيم الثدي إلى 15-20 وحدة تشريحية هرمية مستقلة ومترابطة، يمتلك كل فص قناته اللبنية الرئيسية المستقلة.',
      functionEn: 'Divides parenchyma into 15–20 independent pyramidal anatomical sectors, each drained by an individual collecting duct.',
      anatomyAr: 'فصوص مثلثة أو هرمية الشكل تتجه قمتها نحو الحلمة وقاعدتها نحو جدار الصدر، تفصل بينها حواجز ليفية من أربطة كوبر.',
      anatomyEn: 'Pyramidal segments radiating outward with apex directed toward nipple and base anchored near pectoral fascia, segregated by Cooper septa.',
      relativePositionAr: 'تتوزع شعاعياً كعجلات الدراجة حول المركز خلف الهالة والحلمة، وأكبرها حجماً يوجد في الربع العلوي الخارجي.',
      relativePositionEn: 'Radially arranged in spoke-wheel fashion around central nipple; largest lobe volume resides in the upper-outer quadrant.',
      clinicalSignificanceAr: 'أورام السرطان القنوي الموضعي (DCIS) قد تمتد على طول فص كامل (Lobar distribution)، مما يتطلب تقييم حدود الاستئصال الجراحي بدقة.',
      clinicalSignificanceEn: 'DCIS frequently propagates along an entire anatomical lobe; lobar mapping is essential for achieving negative surgical margins.',
      commonPathologiesAr: ['التكلسات الفصية القطاعية (Segmental Calcifications)', 'سرطان القنوات الموضعي الممتد', 'التهاب الفصوص الحبيبي'],
      commonPathologiesEn: ['Segmental Microcalcifications', 'Extensive Lobar DCIS', 'Granulomatous Lobular Mastitis'],
      ultrasoundFindingsAr: 'تقييم قطاعي شعاعي يوضح استمرارية القنوات اللبنية ومصادر التكيسات العنقودية.',
      ultrasoundFindingsEn: 'Radial and anti-radial scanning displays contiguous branching of ductal trees and clustered microcystic foci.',
      mriFindingsAr: 'تعزيز غير كتلي قطاعي أو مثلث (Segmental Non-Mass Enhancement) يعد علامة شديدة الاشتباه في سرطان القنوات الموضعي الممتد.',
      mriFindingsEn: 'Segmental or triangular non-mass enhancement is a recognized hallmark of extensive ductal carcinoma in situ.',
      petCtFindingsAr: 'امتصاص قطاعي مثلث الشكل يعكس نشاطاً ورمياً يملأ فصاً تشريحياً كاملاً.',
      petCtFindingsEn: 'Wedge-shaped segmental metabolic activity reflects neoplastic disease spanning an entire anatomical lobe.',
    ),
    BreastTissueId.lobules: BreastTissueInfo(
      id: BreastTissueId.lobules,
      functionAr: 'الوحدة الوظيفية المجهرية الأساسية لإنتاج الحليب (TDLU)؛ تستجيب مباشرة لهرمون البرولاكتين والإستروجين والبروجسترون.',
      functionEn: 'Microscopic functional unit (TDLU) responsible for milk synthesis, exquisitely sensitive to prolactin, estrogen, and progesterone.',
      anatomyAr: 'حويصلات إفرازية مجهرية (Acini) تفتح في قنية انتهائية ومحاطة بسدى داخلية خاصة غنية بالخلايا الليفية والأوعية الدموية الدقيقة.',
      anatomyEn: 'Grape-like clusters of secretory acini opening into intralobular terminal ductules, enclosed by specialized loose connective stroma.',
      relativePositionAr: 'الوحدات المجهرية الموزعة داخل فصوص الغدة الثديية في أطراف القنوات اللبنية الدقيقة.',
      relativePositionEn: 'Microscopic clusters distributed throughout the mammary lobes at the terminus of delicate intralobular ductules.',
      clinicalSignificanceAr: 'منشأ معظم تكيسات الثدي، الأورام الغدية الليفية، وسرطان الثدي الفصيصي (ILC) الذي يتميز بنموه المتخفي دون تكوين كتلة صلبة واضحة.',
      clinicalSignificanceEn: 'Origin of simple cysts, fibroadenomas, and invasive lobular carcinoma (ILC), which grows in single-file pattern without a discrete palpable mass.',
      commonPathologiesAr: ['الأكياس المائية البسيطة', 'الورم الغدي الليفي (Fibroadenoma)', 'السرطان الفصيصي الغازي (ILC)', 'التصلب الغدي (Sclerosing Adenosis)'],
      commonPathologiesEn: ['Simple Breast Cysts', 'Fibroadenoma', 'Invasive Lobular Carcinoma', 'Sclerosing Adenosis'],
      ultrasoundFindingsAr: 'تظهر التكيسات كفراغات دائرية خالية من الصدى (Anechoic) مع تعزيز خلفي نقي؛ بينما أورام ILC تظهر كتشوه معماري دون حدود واضحة.',
      ultrasoundFindingsEn: 'Cysts appear anechoic with posterior acoustic enhancement; ILC often presents as subtle architectural distortion without discrete margins.',
      mriFindingsAr: 'الرنين المغناطيسي هو الفحص الأكثر حساسية لكشف أورام الفصيصات (ILC) التي قد لا تظهر في الماموجرام العادي.',
      mriFindingsEn: 'Dynamic contrast MRI is the single most sensitive modality for identifying multi-centric invasive lobular carcinoma occult on mammography.',
      petCtFindingsAr: 'السرطان الفصيصي قد يظهر امتصاصاً منخفضاً للـ FDG مقارنة بالقنوي؛ وتُستخدم فحوصات F-FES البديلة لتقييم مستقبلات الإستروجين.',
      petCtFindingsEn: 'ILC frequently exhibits lower FDG avidity due to diffuse single-file infiltration; F-FES PET is superior for estrogen-receptor staging.',
    ),
    BreastTissueId.lactiferousDucts: BreastTissueInfo(
      id: BreastTissueId.lactiferousDucts,
      functionAr: 'نقل الحليب من الفصيصات إلى الحلمة وتخزينه مؤقتاً في الجيوب اللبنية تحت الهالة قبل خروجه.',
      functionEn: 'Transports milk from lobules to the nipple and provides temporary storage within subareolar lactiferous sinuses.',
      anatomyAr: 'شبكة شجرية متفرعة من الأنابيب المبطنة بخلايا طلائية مكعبة ثم عمادية، تتسع خلف الهالة لتشكل جيوباً لبنية (Sinuses) بقطر 2-8 مم.',
      anatomyEn: 'Branching tree of ducts lined by cuboidal/columnar epithelium, dilating subareolarly into ampullary sinuses measuring 2–8 mm in diameter.',
      relativePositionAr: 'تمتد من أطراف الفصيصات الغدية وتتقارب تدريجياً لتصب في 15-20 فتحة على سطح الحلمة.',
      relativePositionEn: 'Originates at terminal ductules, converging centripetally into 15–20 main ducts that open onto the nipple surface.',
      clinicalSignificanceAr: 'المسار الرئيسي لسرطان القنوات (DCIS و IDC) والورم الحليمي؛ انسدادها يسبب احتباس الحليب والتهاب الثدي.',
      clinicalSignificanceEn: 'Primary conduit for ductal carcinomas (DCIS and IDC) and papillomas; obstruction precipitates milk stasis and acute mastitis.',
      commonPathologiesAr: ['سرطان القنوات الموضعي (DCIS)', 'سرطان القنوات الغازي (IDC)', 'الورم الحليمي القنوي', 'توسع القنوات (Duct Ectasia)'],
      commonPathologiesEn: ['Ductal Carcinoma In Situ', 'Invasive Ductal Carcinoma', 'Intraductal Papilloma', 'Mammary Duct Ectasia'],
      ultrasoundFindingsAr: 'قنوات أنبوبية ممتلئة بسوائل تظهر سوداء؛ التكلسات الدقيقة بداخلها أو وجود نتوءات جدارية يثير الاشتباه بالورم.',
      ultrasoundFindingsEn: 'Anechoic tubular branched branching channels; endoluminal mural nodules or intraductal microcalcifications warrant targeted biopsy.',
      mriFindingsAr: 'تعزيز قنوي خطي متفرع (Linear Branching Ductal Enhancement) دلالة نموذجية على وجود سرطان قنوات غير غازي.',
      mriFindingsEn: 'Linear branching ductal enhancement is highly specific for in-situ neoplastic proliferation along the lactiferous tree.',
      petCtFindingsAr: 'نشاط أيضي خطي على امتداد مسار القنوات اللبنية الرئيسية في الأورام القنوية النشطة.',
      petCtFindingsEn: 'Linear metabolic hypermetabolism along main ductal tracks reflecting aggressive intraductal neoplastic disease.',
    ),
    BreastTissueId.coopersLigaments: BreastTissueInfo(
      id: BreastTissueId.coopersLigaments,
      functionAr: 'توفير الدعم الهيكلي الميكانيكي ورفع الثدي وشده وتثبيته فوق جدار الصدر والأنسجة العميقة.',
      functionEn: 'Provides structural suspension and mechanical fixation of breast parenchyma to the overlying skin and underlying deep fascia.',
      anatomyAr: 'حزم وأشرطة ليفية متينة من نسيج ضام كولاجيني كثيف تمتد من اللفافة الصدرية العميقة وتخترق النسيج الدهني لتنغرس في أدمة الجلد.',
      anatomyEn: 'Fibrous connective tissue fascial septa extending from deep pectoral fascia through parenchymal fat to insert into dermal collagen.',
      relativePositionAr: 'تمتد شعاعياً وعمودياً عبر كامل سمك الثدي، وتربط عضلات الصدر بجلد الثدي الخارجي.',
      relativePositionEn: 'Traverses the entire breast depth, anchoring deep muscular fascia to the superficial cutaneous envelope.',
      clinicalSignificanceAr: 'غزو الخلايا السرطانية لأربطة كوبر يؤدي إلى انكماشها وسحب الجلد للداخل مسبباً نقرة أو غمازة الجلد الشهيرة (Skin Dimpling).',
      clinicalSignificanceEn: 'Tumoral invasion and desmoplastic fibrosis shorten the ligaments, tethering the skin and producing classic localized dimpling.',
      commonPathologiesAr: ['انكماش الأربطة الورمي (Ligamentous Tethering)', 'التليف والتشوه المعماري بعد الإشعاع أو العمليات'],
      commonPathologiesEn: ['Tumoral Ligament Tethering', 'Post-Surgical Architectural Distortion'],
      ultrasoundFindingsAr: 'أشرطة رقيقة منحنية مفرطة الصدى (Hyperechoic) تخترق طبقة الدهن. التواء أو انقطاع استمراريتها يشير لتسلل ورمي.',
      ultrasoundFindingsEn: 'Thin echogenic curvilinear bands traversing hypoechoic fat; tethering, thickening, or distortion indicates adjacent desmoplasia.',
      mriFindingsAr: 'تظهر كحواجز خطية منخفضة الإشارة في كافة التسلسلات؛ ويثير ارتشاح الصبغة الموضعي فيها اشتباهاً بغزو ورمي للأربطة.',
      mriFindingsEn: 'Hypointense linear bands across T1/T2; focal enhancement along ligamentous tracks signifies malignant infiltration.',
      petCtFindingsAr: 'لا يمتلك نشاطاً أيضياً مستقلاً؛ يظهر نشاطاً فقط في حال انتشاره كجزء من كتلة ورمية غازية.',
      petCtFindingsEn: 'Avascular structural tissue without independent metabolic activity; avidity occurs solely via tumoral engulfment.',
    ),
    BreastTissueId.retromammarySpace: BreastTissueInfo(
      id: BreastTissueId.retromammarySpace,
      functionAr: 'السماح للثدي بالانزلاق والحركة الحرة والسلسة فوق عضلات جدار الصدر أثناء حركة الذراعين والتنفس.',
      functionEn: 'Enables physiological sliding mobility of the breast over the chest wall musculature during respiration and upper extremity motion.',
      anatomyAr: 'طبقة رخوة من النسيج الضام الهالي الرخو وأوعية ليمفاوية دقيقة، تفصل بين اللفافة السطحية الخلفية للثدي واللفافة الصدرية العميقة.',
      anatomyEn: 'Avascular plane of loose areolar connective tissue and fine lymphatic channels between posterior superficial fascia and deep pectoral fascia.',
      relativePositionAr: 'المساحة التشريحية الفاصلة بين قاعدة الثدي الخلفية والعضلة الصدرية الكبرى.',
      relativePositionEn: 'The anatomical plane separating the posterior base of breast parenchyma from the anterior pectoralis major fascia.',
      clinicalSignificanceAr: 'اختراق الورم لهذه المساحة وفقدان حركة الثدي فوق الصدر يدل على غزو العضلة الصدرية ويرفع تصنيف الورم إلى مرحلة متقدمة (T4).',
      clinicalSignificanceEn: 'Obliteration of this plane and chest wall fixation denotes deep muscle invasion, upgrading tumor stage to advanced T4.',
      commonPathologiesAr: ['غزو ورمي لقاعدة الثدي واللفافة العميقة', 'تجمع دموي أو مصلي بعد العمليات (Seroma/Hematoma)'],
      commonPathologiesEn: ['Deep Fascial Tumoral Infiltration', 'Postoperative Retromammary Seroma/Hematoma'],
      ultrasoundFindingsAr: 'شريط رقيق منخفض الصدى يفصل النسيج الغدي عن اللفافة العضلية؛ انقطاعه ووجود كتلة تخترقه يؤكد الغزو العميق.',
      ultrasoundFindingsEn: 'Continuous hypoechoic fat plane above the bright pectoral fascia; interruption by an infiltrative mass confirms deep invasion.',
      mriFindingsAr: 'تسلسل T1 يوضح طبقة الدهن الرخوة بوضوح؛ اختفاء هذه الطبقة وظهور تعزيز ورمي يمتد للعضلة يؤكد غزو جدار الصدر.',
      mriFindingsEn: 'Sagittal T1 clearly delineates the high-signal fat plane; obliteration and contrast extension into muscle confirms deep wall invasion.',
      petCtFindingsAr: 'امتداد الامتصاص الاستقلابي الورمي عبر الحيز إلى عضلات الصدر يثبت مرحلة T4b بالأدلة الوظيفية.',
      petCtFindingsEn: 'Continuous hypermetabolic FDG activity bridging across the space into the chest wall provides definitive metabolic proof of T4b disease.',
    ),
    BreastTissueId.pectoralisMajor: BreastTissueInfo(
      id: BreastTissueId.pectoralisMajor,
      functionAr: 'تقريب وثني وتدوير الذراع للداخل والمشاركة في تثبيت مفصل الكتف والتنفس العميق.',
      functionEn: 'Adduction, flexion, and internal rotation of the humerus, assisting in respiratory mechanics and shoulder girdle stability.',
      anatomyAr: 'عضلة مروحية سميكة مخططة تتكون من رأس ترقوي ورأس قصي ضلعي، تنغرس أليافها في عظم العضد ومغطاة بلفافة ليفية عميقة.',
      anatomyEn: 'Thick, fan-shaped striated muscle comprising clavicular and sternocostal heads, inserting into the lateral lip of bicipital groove of humerus.',
      relativePositionAr: 'تشكل السرير التشريحي العضلي الصلب الذي يرتكز فوقه الثدي في جدار الصدر الأمامي.',
      relativePositionEn: 'Forms the major anterior muscular bed upon which the posterior base of the breast resides.',
      clinicalSignificanceAr: 'غزو خلايا الورم للعضلة يستوجب استئصال اللفافة الصدرية أو أجزاء من العضلة (Mastectomy with Muscle Resection) واستخدام العلاج الكيماوي الاستباقي.',
      clinicalSignificanceEn: 'Tumor infiltration requires modified radical excision or partial muscle resection, qualifying the patient for neoadjuvant chemotherapy.',
      commonPathologiesAr: ['غزو ورمي عضلي مباشر (T4a)', 'ورم خبيث أولي نادر (ساركوما العضلات)', 'تمزق الألياف العضلية بعد الكدمات'],
      commonPathologiesEn: ['Direct Tumoral Muscle Invasion (T4a)', 'Primary Pectoral Sarcoma', 'Muscle Fiber Strain/Hematoma'],
      ultrasoundFindingsAr: 'ألياف عضلية متوازية منخفضة الصدى مفصولة بحواجز ليفية مفرطة الصدى؛ الورم الغازي يظهر ككتلة مشوهة للألياف.',
      ultrasoundFindingsEn: 'Parallel hypoechoic striated muscle fascicles bounded by hyperechoic fascial borders; invasion presents as focal muscular disruption.',
      mriFindingsAr: 'إشارة عضلية متجانسة في T1؛ الورم الغازي يُظهر ارتفاعاً في إشارة T2 وتعزيزاً حركياً صريحاً بالجادولينيوم داخل ألياف العضلة.',
      mriFindingsEn: 'Homogeneous baseline muscle signal; malignant invasion shows focal hyperintensity on T2 and dynamic contrast infiltration into fibers.',
      petCtFindingsAr: 'امتصاص بؤري مرتفع داخل حدود العضلة الصدرية يؤكد التسلل العضلي بدقة متناهية.',
      petCtFindingsEn: 'Discrete hypermetabolic activity embedded within the pectoral muscle confirms deep tumoral infiltration.',
    ),
    BreastTissueId.ribsIntercostal: BreastTissueInfo(
      id: BreastTissueId.ribsIntercostal,
      functionAr: 'حماية الرئتين والقلب، وتأمين حركات القفص الصدري أثناء الشهيق والزفير، وحمل الحزم الوعائية العصبية الوربية.',
      functionEn: 'Protects vital thoracic viscera, enables respiratory expansion, and shields the intercostal neurovascular bundles.',
      anatomyAr: 'أضلاع عظمية مقوسة (الضلع الثاني إلى السادس) محاطة بقشرة عظمية صلبة ونخاع عظمي داخلي، تفصل بينها عضلات وربية وأوعية دموية.',
      anatomyEn: 'Curved osseous ribs (2nd through 6th ribs) featuring dense cortical bone surrounding marrow, bridged by intercostal muscles.',
      relativePositionAr: 'الهيكل العظمي العميق الواقع مباشرة خلف العضلة الصدرية الكبرى وجدار الصدر.',
      relativePositionEn: 'The deep bony skeleton immediately posterior to the pectoralis major and chest wall musculature.',
      clinicalSignificanceAr: 'المرحلة الرابعة (Metastatic Disease) قد تشمل نقائل عظمية في الأضلاع؛ وغزو الورم المباشر للأضلاع يمثل المرحلة الموضعية المتقدمة T4a.',
      clinicalSignificanceEn: 'Frequent destination for osseous metastases in Stage IV; direct invasion represents locally advanced T4a disease.',
      commonPathologiesAr: ['نقائل عظمية في الأضلاع (Rib Metastases)', 'غزو جدار الصدر المباشر', 'كسور مرضية ناتجة عن هشاشة أو نقائل'],
      commonPathologiesEn: ['Osseous Rib Metastases', 'Direct Chest Wall Invasion', 'Pathological Rib Fractures'],
      ultrasoundFindingsAr: 'سطح قشري عظمي أملس مفرط الصدى يعكس الصوت كلياً مع ظل صوتي خلفي كامل (Acoustic Shadowing) يحجب ما تحته.',
      ultrasoundFindingsEn: 'Smooth, bright hyperechoic cortical bone surface causing total posterior acoustic attenuation and complete acoustic shadowing.',
      mriFindingsAr: 'النخاع العظمي الطبيعي يظهر إشارة عالية في T1؛ النقائل العظمية تظهر كنقص بؤري في إشارة T1 مع إشارة عالية في STIR وتعزيز بالصبغة.',
      mriFindingsEn: 'Normal marrow shows high T1 signal; osteolytic metastases manifest as focal low T1 signal with STIR hyperintensity and enhancement.',
      petCtFindingsAr: 'الفحص الأدق لكشف النقائل العظمية في القفص الصدري؛ النقائل تظهر كبؤر شديدة التوهج الأيضي (High SUVmax) قبل ظهورها بالأشعة العادية.',
      petCtFindingsEn: 'The gold standard for thoracic skeletal staging; osseous metastases show intensely hot metabolic lesions preceding plain radiograph findings.',
    ),
    BreastTissueId.axillaryTail: BreastTissueInfo(
      id: BreastTissueId.axillaryTail,
      functionAr: 'امتداد طبيعي للنسيج الغدي اللبني والدهني يصل إلى تجويف الإبط ويشارك في الاستجابة الهرمونية.',
      functionEn: 'Anatomical continuation of glandular breast parenchyma tracking toward the axilla, responding to systemic hormonal stimuli.',
      anatomyAr: 'لسان غدي ودهني يمتد من الربع العلوي الخارجي ويخترق اللفافة الإبطية العميقة عبر ثقب لانغر (Foramen of Langer).',
      anatomyEn: 'Tongue of glandular parenchyma and adipose tissue projecting superolaterally from the upper-outer quadrant through the foramen of Langer.',
      relativePositionAr: 'يمتد قطرياً من الجزء العلوي الخارجي للثدي إلى داخل الحفرة الإبطية بجوار الأوعية الإبطية.',
      relativePositionEn: 'Extends superolaterally from the upper-outer breast quadrant into the axillary fossa adjacent to axillary vessels.',
      clinicalSignificanceAr: 'أكثر من 50% من جميع حالات سرطان الثدي تنشأ في الربع العلوي الخارجي وذيل سبنس نظراً لتركز أكبر كمية من الأنسجة الغدية فيه.',
      clinicalSignificanceEn: 'Over 50% of all breast malignancies develop in the upper-outer quadrant and axillary tail due to highest parenchymal volume.',
      commonPathologiesAr: ['أورام الربع العلوي الخارجي (UOQ Carcinoma)', 'التغير الكيسي الغدي في الذيل الإبطي', 'النسيج الثديي الإبطي الإضافي'],
      commonPathologiesEn: ['Upper-Outer Quadrant Carcinoma', 'Axillary Tail Fibrocystic Disease', 'Accessory Ectopic Breast Tissue'],
      ultrasoundFindingsAr: 'يستلزم فحصاً مسحياً دقيقاً بزاوية مائلة يمتد للإبط لكشف الكتل العميقة الكامنة في ذيل سبنس.',
      ultrasoundFindingsEn: 'Requires dedicated angled sonographic sweeps extending into axilla to evaluate deep nodules in the axillary tail.',
      mriFindingsAr: 'يظهر بوضوح في المقاطع المحورية (Axial)؛ وتظهر الكتل السرطانية كتشوهات معمارية ذات تعزيز سريع مع ارتشاح في دهن الإبط.',
      mriFindingsEn: 'Well-visualized on axial views; tumors demonstrate irregular morphology, rapid contrast wash-in, and local invasion into axillary fat.',
      petCtFindingsAr: 'امتصاص بؤري مرتفع في الذيل الإبطي يسهل تمييزه عن العقد الليمفاوية المجاورة من خلال الصور المقطعية المدمجة.',
      petCtFindingsEn: 'Focal metabolic uptake in the tail distinguished from regional lymphadenopathy via co-registered CT anatomical slices.',
    ),
    BreastTissueId.axillaryLymphNodes: BreastTissueInfo(
      id: BreastTissueId.axillaryLymphNodes,
      functionAr: 'تصفية وترشيح السائل الليمفاوي القادم من الثدي، حبس الخلايا السرطانية والبكتيريا، وتفعيل الاستجابة المناعية عبر الخلايا التائية والبائية.',
      functionEn: 'Filters lymph draining from breast parenchyma, traps metastatic tumor emboli and microbes, and initiates humoral/cellular immune defense.',
      anatomyAr: 'مجموعات من العقد البيضاوية يبلغ عددها 20-40 عقدة، مقسمة تشريحياً إلى ثلاثة مستويات (Levels I, II, III) بالنسبة للعضلة الصدرية الصغرى.',
      anatomyEn: '20–40 encapsulated reniform nodes arranged in three surgical levels (Levels I, II, III) demarcated by the pectoralis minor muscle.',
      relativePositionAr: 'تتمركز في الحفرة الإبطية على طول الأوردة الإبطية ومسارات النزح الليمفاوي القادمة من الثدي.',
      relativePositionEn: 'Situated within the axillary adipose tissue along the axillary vein and primary breast lymphatic drainage channels.',
      clinicalSignificanceAr: 'أهم عامل إنذاري في سرطان الثدي؛ إصابة العقد تحدد مرحلة المرض (N1, N2, N3) ونوع الجراحة (خزعة العقدة الخافرة أو استئصال الإبط الكامل).',
      clinicalSignificanceEn: 'The single most critical prognostic staging factor; involvement dictates N-status, sentinel node biopsy, or axillary clearance.',
      commonPathologiesAr: ['نقائل العقد الليمفاوية الإبطية (Axillary Nodal Metastasis)', 'التهاب العقد التفاعلي (Reactive Lymphadenitis)', 'انسداد ليمفاوي ووذمة الذراع'],
      commonPathologiesEn: ['Axillary Lymph Node Metastasis', 'Reactive Lymphadenitis', 'Lymphedema'],
      ultrasoundFindingsAr: 'العقدة الطبيعية بيضاوية ذات نقير دهني مفرط الصدى وقشرة رقيقة (<3 مم). العقدة المصابة تصبح كروية مع فقدان النقير وتسمك قشري غير متناظر.',
      ultrasoundFindingsEn: 'Normal node is reniform with bright fatty hilum and thin cortex (<3 mm). Metastatic node becomes round with loss of fatty hilum and asymmetric cortex.',
      mriFindingsAr: 'عقد دائرية فاقدة للدهن الداخلي، تُظهر تعزيزاً سريعاً بالصبغة مع تقييد واضح في تسلسل انتشار الماء (DWI / ADC Restriction).',
      mriFindingsEn: 'Loss of central fatty notch, short-axis diameter >10 mm, rapid contrast enhancement, and restricted diffusion on DWI/ADC mapping.',
      petCtFindingsAr: 'نشاط أيضي مرتفع (High SUVmax) في العقد الليمفاوية المصابة يؤكد وجود نقائل خبيثة ويوجه الطبيب لاختيار العقدة المناسبة للخزعة.',
      petCtFindingsEn: 'Intense metabolic hypermetabolism (elevated SUVmax) pinpoints malignant involvement and guides ultrasound-guided needle biopsy.',
    ),
    BreastTissueId.lymphaticVessels: BreastTissueInfo(
      id: BreastTissueId.lymphaticVessels,
      functionAr: 'نزح وتصريف السائل الخلالي والبروتينات من أنسجة الثدي ونقلها نحو العقد الليمفاوية الإبطية والصدرية الداخلية.',
      functionEn: 'Drains interstitial fluid and macromolecules from parenchyma, routing >75% of breast lymph toward regional axillary basin.',
      anatomyAr: 'شبكة دقيقة من القنوات الشعرية الليمفاوية تبدأ بضفيرة سابي تحت الهالة (Sappey plexus) وتتجمع في أوعية نزح رئيسية ذات صمامات أحادية الاتجاه.',
      anatomyEn: 'Delicate endothelial channels originating in the subareolar plexus of Sappey, converging into valved trunks draining to regional basins.',
      relativePositionAr: 'تتخلل الأنسجة الغدية والدهنية وتمتد موازية للقنوات اللبنية والأوعية الدموية متجهة نحو الإبط.',
      relativePositionEn: 'Intertwines with interlobular stroma and periductal tracts, directing lymph drainage toward the axilla and internal mammary nodes.',
      clinicalSignificanceAr: 'الغزو الوعائي الليمفاوي (LVI) في فحص الخزعة يرفع مخاطر عودة الورم؛ وانسدادها بخلايا سرطانية يسبب تورم قشرة البرتقال والسرطان الالتهابي.',
      clinicalSignificanceEn: 'Lymphovascular invasion (LVI) on histology indicates elevated metastatic risk; intradermal embolization causes peau d’orange.',
      commonPathologiesAr: ['الغزو الوعائي الليمفاوي الورمي (LVI)', 'التهاب الأوعية الليمفاوية السرطاني', 'وذمة الثدي الليمفاوية'],
      commonPathologiesEn: ['Lymphovascular Invasion (LVI)', 'Lymphangitic Carcinomatosis', 'Breast Lymphedema'],
      ultrasoundFindingsAr: 'الأوعية الليمفاوية الطبيعية دقيقة جداً؛ عند انسدادها تظهر كقنوات متوسعة منخفضة الصدى في طبقة الأدمة وتحت الجلد.',
      ultrasoundFindingsEn: 'Physiological channels are invisible; lymphostasis produces dilated anechoic tubular spaces within thickened edematous dermis.',
      mriFindingsAr: 'وذمة شبكية وتوسع في الأوعية الليمفاوية السطحية مع تعزيز متباين في الجلد والأنسجة المحيطة.',
      mriFindingsEn: 'Reticular dermal edema and dilated lymphatic channels demonstrating diffuse abnormal interstitial contrast permeability.',
      petCtFindingsAr: 'مسار أيضي ممتد يعكس انتشار الخلايا السرطانية عبر الأوعية الليمفاوية نحو العقد الإبطية.',
      petCtFindingsEn: 'Continuous linear or beaded metabolic activity tracing lymphangitic tumor transit toward the axillary nodal basin.',
    ),
  };

  static BreastTissueInfo getInfo(BreastTissueId id) {
    return tissues[id] ?? tissues[BreastTissueId.skin]!;
  }
}
