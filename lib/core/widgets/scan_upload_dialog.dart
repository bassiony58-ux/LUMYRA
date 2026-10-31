import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/localization/app_localization.dart';
import '../../app/theme/app_colors.dart';
import '../services/ultrasound_analyzer_service.dart';
import 'app_card.dart';
import 'pill_button.dart';
import 'status_badge.dart';

class ScanUploadDialog extends StatefulWidget {
  final bool isDoctor;
  final void Function(String fileName, Uint8List fileBytes, String biRads, String finding)? onScanProcessed;

  const ScanUploadDialog({
    super.key,
    this.isDoctor = false,
    this.onScanProcessed,
  });

  static Future<void> show(
    BuildContext context, {
    bool isDoctor = false,
    void Function(String fileName, Uint8List fileBytes, String biRads, String finding)? onScanProcessed,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScanUploadDialog(
        isDoctor: isDoctor,
        onScanProcessed: onScanProcessed,
      ),
    );
  }

  @override
  State<ScanUploadDialog> createState() => _ScanUploadDialogState();
}

class _ScanUploadDialogState extends State<ScanUploadDialog> {
  bool _isProcessing = false;
  ScanAnalysisResult? _analysisResult;
  String? _selectedFileName;
  List<int>? _selectedFileBytes;
  String _detectedFileType = 'أشعة الموجات فوق الصوتية (سونار / Ultrasound)';
  IconData _detectedFileIcon = Icons.document_scanner_rounded;

  @override
  void initState() {
    super.initState();
    _selectedFileName = null;
    _selectedFileBytes = null;
  }

  Future<void> _pickFromFiles() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final name = file.name;

        String detectedType = 'أشعة الموجات فوق الصوتية (سونار / Ultrasound)';
        IconData detectedIcon = Icons.image_search_rounded;

        List<int>? bytes = file.bytes;
        if ((bytes == null || bytes.isEmpty) && file.path != null) {
          bytes = await File(file.path!).readAsBytes();
        }

        if (bytes == null || bytes.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.isArabic ? 'تعذر قراءة بيانات الملف المختار' : 'Could not read file data'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        if (mounted) {
          setState(() {
            _selectedFileName = name;
            _selectedFileBytes = bytes;
            _detectedFileType = detectedType;
            _detectedFileIcon = detectedIcon;
          });
        }

        // Automatically upload and run real AI model analysis
        await _runAnalysis(fileName: name, fileBytes: bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.isArabic
                  ? 'يرجى التحقق من أذونات الوصول إلى الملفات'
                  : 'Please check file storage permissions',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 92,
      );

      if (photo != null) {
        final name = photo.name.isNotEmpty ? photo.name : 'camera_ultrasound_scan.jpg';
        final bytes = await photo.readAsBytes();

        if (mounted) {
          setState(() {
            _selectedFileName = name;
            _selectedFileBytes = bytes;
            _detectedFileType = 'أشعة سونار الثدي (التقاط فوري بالكاميرا)';
            _detectedFileIcon = Icons.camera_alt_rounded;
          });
        }

        // Automatically upload and run real AI model analysis
        await _runAnalysis(fileName: name, fileBytes: bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.isArabic
                  ? 'يرجى منح إذن استخدام الكاميرا لالتقاط صورة الفحص'
                  : 'Please grant camera permission to capture scan',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _runAnalysis({required String fileName, required List<int> fileBytes}) async {
    setState(() {
      _isProcessing = true;
      _analysisResult = null;
    });

    try {
      final result = await UltrasoundAnalyzerService.analyzeScan(
        fileName: fileName,
        fileBytes: fileBytes,
        isDoctor: widget.isDoctor,
      );

      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isProcessing = false;
        });

        widget.onScanProcessed?.call(
          fileName,
          Uint8List.fromList(fileBytes),
          result.doctorDetails.biRadsClass,
          result.doctorDetails.clinicalDiagnosis,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.isArabic
                  ? 'تعذر استكمال الفحص الآلي: $e'
                  : 'Failed to complete AI analysis: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleUploadAndProcess() async {
    if (_selectedFileName == null || _selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.isArabic
                ? 'يرجى اختيار ملف أو التقاط صورة أولاً'
                : 'Please select a file or snap a scan first',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    await _runAnalysis(
      fileName: _selectedFileName!,
      fileBytes: _selectedFileBytes!,
    );
  }

  void _reset() {
    setState(() {
      _analysisResult = null;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.whiteSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.outline.withAlpha(80),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Dialog Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.powderBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic
                              ? (widget.isDoctor
                                  ? 'فحص وتحليل التقارير الطبية (وحدة الاستشاري)'
                                  : 'فحص التقارير والأشعة بالذكاء الاصطناعي 🌸')
                              : (widget.isDoctor
                                  ? 'Clinical Document Analyzer (Clinician)'
                                  : 'AI Medical Document & Scan Reader 🌸'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isArabic
                              ? 'تعرف تلقائي فوري على نوع الملف ونموذج التحليل المناسب'
                              : 'Auto-detection of document type and clinical model',
                          style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),

            // Content Area
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _isProcessing
                    ? _buildProcessingState(isArabic)
                    : (_analysisResult != null
                        ? (widget.isDoctor
                            ? _buildDoctorResult(isArabic, _analysisResult!)
                            : _buildPatientResult(isArabic, _analysisResult!))
                        : _buildUploadZone(isArabic)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Direct Two Options: File / Document Picker OR Camera Snap
  Widget _buildUploadZone(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isArabic
              ? 'اختاري طريقة رفع الفحص الطبي 🌸'
              : 'Choose How to Upload Medical Scan 🌸',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isArabic
              ? 'يمكنكِ رفع ملف تقرير طبي أو صورة من جهازك، أو فتح الكاميرا وتصوير الفحص فوراً'
              : 'Upload a document/image from your device or snap a photo directly',
          style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 18),

        // 1. First Choice: File / Image / PDF Picker
        InkWell(
          onTap: _pickFromFiles,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.powderBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withAlpha(90),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.whiteSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.drive_folder_upload_rounded,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic
                            ? 'رفع ملف أو صورة أو تقرير طبي'
                            : 'Upload Document, Scan or Report',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isArabic
                            ? 'اختيار من الاستوديو أو الملفات (JPG, PNG, PDF)'
                            : 'Pick from device storage or gallery (PDF, PNG, JPG)',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 2. Second Choice: Camera Snap
        InkWell(
          onTap: _takePhotoWithCamera,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.whiteSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.softDustyBlush,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.powderBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic
                            ? 'فتح الكاميرا والتقاط صورة'
                            : 'Open Camera & Snap Scan',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mainText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isArabic
                            ? 'تصوير فحص السونار مباشرة ورفعه فور الانتهاء'
                            : 'Snap ultrasound directly and analyze upon DONE',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (_selectedFileName != null) ...[
          // Currently Selected / Ready File Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.powderBackground.withAlpha(80),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.warmNeutralSand),
            ),
            child: Row(
              children: [
                Icon(_detectedFileIcon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFileName!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mainText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isArabic ? 'تم التعرف: $_detectedFileType' : 'Detected: $_detectedFileType',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.whiteSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isArabic ? 'جاهز للفحص' : 'Ready',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Primary Analyze Button
          PillButton(
            label: isArabic
                ? 'بدء الفحص والتحليل الإكلينيكي الذكي 🌸'
                : 'Run Smart Clinical Analysis 🌸',
            icon: Icons.auto_awesome_rounded,
            onPressed: _handleUploadAndProcess,
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.powderBackground.withAlpha(60),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.softDustyBlush.withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isArabic
                        ? 'فحوصاتكِ وصوركِ الطبية مشفرة ومحمية بخصوصية سريرية تامة 🔒'
                        : 'Your medical scans are encrypted and confidential 🔒',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.secondaryText, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
        // Generous bottom spacing for physical devices
        const SizedBox(height: 48),
      ],
    );
  }

  // 2. Processing Animation
  Widget _buildProcessingState(bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              width: 55,
              height: 55,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic
                  ? 'جاري فحص المستند بالذكاء الاصطناعي...'
                  : 'Analyzing document via Clinical AI...',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'يتم تدقيق البيانات وقراءة المؤشرات الحيوية النسيجية بأعلى معايير الأمان'
                  : 'Evaluating lesion borders and clinical indicators safely',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  // 3. PATIENT RESULT VIEW (Empathetic, Reassuring, ZERO "خبيث", Instant Facilities)
  Widget _buildPatientResult(bool isArabic, ScanAnalysisResult result) {
    final advice = result.patientAdvice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Headline Badge & Reassuring Guidance
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: advice.badgeColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: advice.badgeTextColor.withAlpha(50), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    advice.requiresUrgentDoctorVisit
                        ? Icons.notifications_active_rounded
                        : Icons.health_and_safety_outlined,
                    color: advice.badgeTextColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      advice.badgeText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: advice.badgeTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                advice.headline,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: advice.badgeTextColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                advice.message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.mainText,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Clinical Facilities Recommendations (ALWAYS displayed for all findings)
        Text(
          isArabic
              ? (advice.requiresUrgentDoctorVisit
                  ? 'المراكز والمستشفيات الموصى بالتواصل معها فوراً للاستشارة العاجلة:'
                  : 'المراكز والعيادات المعتمدة للاستشارة السريرية والمتابعة:')
              : (advice.requiresUrgentDoctorVisit
                  ? 'Recommended Immediate Clinical Facilities (Urgent):'
                  : 'Verified Clinical Facilities for Consultation & Follow-up:'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),

        ...advice.recommendedFacilities.map((facility) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            border: Border.all(color: AppColors.warmNeutralSand),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.powderBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facility.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mainText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            facility.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            facility.location,
                            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                        label: Text(
                          isArabic ? 'الخط الساخن: ${facility.hotline}' : 'Hotline: ${facility.hotline}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: facility.hotline));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isArabic
                                    ? 'تم نسخ رقم الخط الساخن (${facility.hotline}) للاتصال الفوري'
                                    : 'Copied hotline ${facility.hotline} to clipboard',
                              ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/patient/appointments');
                      },
                      child: Text(
                        isArabic ? 'حجز موعد' : 'Book Visit',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 6),
        OutlinedButton.icon(
          icon: const Icon(Icons.map_rounded),
          label: Text(
            isArabic ? 'استعراض كل المراكز المعتمدة على الخريطة' : 'Explore All Verified Centers on Map',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/patient/centers');
          },
        ),

        // Clinical Safety Disclaimer
        Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.powderBackground.withAlpha(70),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.warmNeutralSand),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.secondaryText, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic
                      ? 'تنويه طبي: هذه القراءة استرشادية مبنية على الذكاء الاصطناعي للمساعدة في الفحص المبدئي، ولا تغني عن الاستشارة السريرية وفحص الطبيب المختص.'
                      : 'Clinical Disclaimer: This reading is an AI-assisted initial screening aid and does not substitute for clinical consultation with a specialist.',
                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, height: 1.4),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),
        PillButton(
          label: isArabic ? 'فحص تقرير آخر' : 'Test Another Report',
          icon: Icons.refresh_rounded,
          onPressed: _reset,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // 4. DOCTOR RESULT VIEW (Full Clinical Details, BI-RADS, Path Notes)
  Widget _buildDoctorResult(bool isArabic, ScanAnalysisResult result) {
    final details = result.doctorDetails;
    final isMalignant = result.finding == ScanFinding.malignant;
    final isInconclusive = result.finding == ScanFinding.inconclusive;

    final cardBg = isMalignant
        ? const Color(0xFFFFDAD6)
        : (isInconclusive ? const Color(0xFFFEF3C7) : const Color(0xFFE8F5E9));
    final cardBorder = isMalignant
        ? const Color(0xFFBA1A1A)
        : (isInconclusive ? const Color(0xFFD97706) : const Color(0xFF2E7D32));
    final textColor = isMalignant
        ? const Color(0xFFBA1A1A)
        : (isInconclusive ? const Color(0xFF92400E) : const Color(0xFF2E7D32));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cardBorder,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  StatusBadge.active(details.biRadsClass),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cardBorder.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      isArabic
                          ? 'ثقة النموذج: ${details.formattedConfidence}'
                          : 'Model Confidence: ${details.formattedConfidence}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                details.clinicalDiagnosis,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pathology Notes
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.biotech_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isArabic ? 'الملاحظات المورفولوجية والباثولوجية:' : 'Morphological & Sonographic Features:',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                details.pathologyNotes,
                style: const TextStyle(fontSize: 12.5, color: AppColors.mainText, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Recommended Clinical Protocol Checklist
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.checklist_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isArabic ? 'بروتوكول التدخل السريري المقترح:' : 'Recommended Clinical Management:',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...details.clinicalActions.map(
                (act) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_right_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          act,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.mainText, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        PillButton(
          label: isArabic ? 'تحليل تقرير آخر' : 'Analyze Another Record',
          icon: Icons.refresh_rounded,
          onPressed: _reset,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
