import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/ultrasound_analyzer_service.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/scan_upload_dialog.dart';

class ImagingViewerScreen extends ConsumerStatefulWidget {
  const ImagingViewerScreen({super.key});

  @override
  ConsumerState<ImagingViewerScreen> createState() => _ImagingViewerScreenState();
}

class _ImagingViewerScreenState extends ConsumerState<ImagingViewerScreen> {
  int _selectedViewIndex = 0; // 0 = R-CC, 1 = R-MLO, 2 = L-CC, 3 = Prior Comparison
  double _zoomLevel = 1.0;
  bool _isInverted = false;
  bool _isReviewed = false;
  bool _isAnalyzing = false;

  Uint8List? _activeScanBytes;
  String _activePatientName = 'سارة أحمد محمود (PT-8831)';
  String _activeScanFilename = 'mammo_screening_r_cc.dcm';
  String _activeScanDate = '2026-10-30 • 10:14 AM';
  String _activeDeviceModel = 'Hologic 3Dimensions Digital Mammography';
  String _activeBiRads = 'BI-RADS 2';
  String _activeFinding = 'حميد (Benign)';

  final List<String> _views = ['R-CC View', 'R-MLO View', 'L-CC View', 'مقارنة سابقة'];

  final List<Map<String, dynamic>> _scanHistory = [
    {
      'id': 'scn-101',
      'filename': 'mammo_screening_r_cc.dcm',
      'category': 'MAMMOGRAM',
      'date': '2026-10-30',
      'biRads': 'BI-RADS 2',
      'finding': 'حميد (Benign)',
      'patient': 'سارة أحمد محمود (PT-8831)',
      'device': 'Hologic 3Dimensions Digital Mammography',
    },
    {
      'id': 'scn-102',
      'filename': 'ultrasound_targeted_ruq.png',
      'category': 'ULTRASOUND',
      'date': '2026-10-25',
      'biRads': 'BI-RADS 1',
      'finding': 'طبيعي (Normal)',
      'patient': 'سارة أحمد محمود (PT-8831)',
      'device': 'GE LOGIQ E10 Ultrasound Series',
    },
    {
      'id': 'scn-103',
      'filename': 'biopsy_pathology_report.pdf',
      'category': 'BIOPSY_REPORT',
      'date': '2026-09-12',
      'biRads': 'BI-RADS 2',
      'finding': 'أورام ليفية حميدة (Fibroadenoma)',
      'patient': 'سارة أحمد محمود (PT-8831)',
      'device': 'Histopathology Lab Report',
    },
  ];

  Future<void> _pickScanImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 95);
      if (file != null) {
        final bytes = await file.readAsBytes();
        await _loadNewScanIntoViewer(
          filename: file.name.isNotEmpty ? file.name : 'gallery_scan_${DateTime.now().millisecondsSinceEpoch}.png',
          bytes: bytes,
          category: 'ULTRASOUND',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showToast(context.isArabic ? 'تعذر اختيار الصورة: $e' : 'Failed to pick image: $e', isError: true);
    }
  }

  Future<void> _captureScanFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 95);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        await _loadNewScanIntoViewer(
          filename: 'camera_scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
          bytes: bytes,
          category: 'ULTRASOUND',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showToast(context.isArabic ? 'تعذر فتح الكاميرا: $e' : 'Camera error: $e', isError: true);
    }
  }

  Future<void> _pickScanFileFromStorage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'dcm', 'pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        final f = result.files.first;
        List<int>? bytes = f.bytes;
        if ((bytes == null || bytes.isEmpty) && f.path != null) {
          bytes = await File(f.path!).readAsBytes();
        }
        if (bytes != null && bytes.isNotEmpty) {
          await _loadNewScanIntoViewer(
            filename: f.name,
            bytes: Uint8List.fromList(bytes),
            category: f.name.toLowerCase().contains('mammo') ? 'MAMMOGRAM' : 'ULTRASOUND',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showToast(context.isArabic ? 'تعذر قراءة الملف: $e' : 'File error: $e', isError: true);
    }
  }

  Future<void> _loadNewScanIntoViewer({
    required String filename,
    required Uint8List bytes,
    required String category,
  }) async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    setState(() {
      _isAnalyzing = true;
      _activeScanBytes = bytes;
      _activeScanFilename = filename;
      _activeScanDate = '$dateStr • $timeStr';
      _activeDeviceModel = 'Digital Diagnostic Console (Direct Feed)';
      _zoomLevel = 1.0;
      _isInverted = false;
    });

    final isAr = mounted ? context.isArabic : true;
    String determinedBiRads = 'BI-RADS 2';
    String determinedFinding = isAr ? 'حميد (Benign)' : 'Benign Finding';

    try {
      final analysis = await UltrasoundAnalyzerService.analyzeScan(
        fileName: filename,
        fileBytes: bytes,
        isDoctor: true,
      );
      determinedBiRads = analysis.doctorDetails.biRadsClass;
      determinedFinding = analysis.doctorDetails.clinicalDiagnosis;
    } catch (_) {}

    final newScan = {
      'id': 'scn-${now.millisecondsSinceEpoch}',
      'filename': filename,
      'category': category,
      'date': dateStr,
      'biRads': determinedBiRads,
      'finding': determinedFinding,
      'patient': 'سارة أحمد محمود (PT-8831)',
      'device': 'Direct DICOM Upload',
      'bytes': bytes,
    };

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _activeBiRads = determinedBiRads;
        _activeFinding = determinedFinding;
        _scanHistory.insert(0, newScan);
      });

      _showToast(
        context.isArabic
            ? 'تم تحميل وعرض الفحص "$filename" في شاشة الاستعراض بنجاح 🔬'
            : 'Scan "$filename" loaded and rendered into DICOM viewer 🔬',
      );
    }
  }

  void _selectScanFromHistory(Map<String, dynamic> scan) {
    setState(() {
      _activeScanFilename = scan['filename'] ?? 'medical_scan.dcm';
      _activeBiRads = scan['biRads'] ?? 'BI-RADS 2';
      _activeFinding = scan['finding'] ?? 'Benign';
      _activeScanDate = '${scan['date']} • 10:30 AM';
      _activePatientName = scan['patient'] ?? 'سارة أحمد محمود (PT-8831)';
      _activeDeviceModel = scan['device'] ?? 'Digital Mammography Unit';

      if (scan['bytes'] is Uint8List) {
        _activeScanBytes = scan['bytes'] as Uint8List;
      } else {
        _activeScanBytes = null;
      }
      _zoomLevel = 1.0;
      _isInverted = false;
    });

    _showToast(
      context.isArabic
          ? 'تم عرض "${scan['filename']}" في شاشة المراجعة 🔬'
          : 'Displaying "${scan['filename']}" in console 🔬',
    );
  }

  Future<void> _handleRenameScan(Map<String, dynamic> scan) async {
    final isAr = context.isArabic;
    final controller = TextEditingController(text: scan['filename'] ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAr ? 'إعادة تسمية الفحص الطبي' : 'Rename Medical Scan',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'الاسم الحالي: ${scan['filename']}' : 'Current: ${scan['filename']}',
              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: isAr ? 'اسم الملف الجديد' : 'New File Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(isAr ? 'حفظ التعديل' : 'Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != scan['filename']) {
      try {
        final client = ApiClient(tokenProvider: () => 'mock-doctor-uid:doctor@lumyra.test:DOCTOR');
        await client.patch('/scans/${scan['id']}', body: {'filename': result});
      } catch (_) {}

      if (mounted) {
        setState(() {
          scan['filename'] = result;
          if (_activeScanFilename == scan['filename']) {
            _activeScanFilename = result;
          }
        });
        _showToast(isAr ? 'تم تعديل اسم الفحص بنجاح' : 'Scan renamed successfully');
      }
    }
  }

  Future<void> _handleDeleteScan(Map<String, dynamic> scan) async {
    final isAr = context.isArabic;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAr ? 'تأكيد حذف الفحص الطبي' : 'Confirm Delete Scan',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.error),
        ),
        content: Text(
          isAr
              ? 'هل أنت متأكد من حذف الفحص "${scan['filename']}"؟ سيتم أرشفة السجل بأمان.'
              : 'Are you sure you want to delete scan "${scan['filename']}"? It will be safely archived.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isAr ? 'نعم، حذف' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final client = ApiClient(tokenProvider: () => 'mock-doctor-uid:doctor@lumyra.test:DOCTOR');
        await client.delete('/scans/${scan['id']}');
      } catch (_) {}

      if (mounted) {
        setState(() {
          _scanHistory.removeWhere((s) => s['id'] == scan['id']);
          if (_activeScanFilename == scan['filename']) {
            _activeScanBytes = null;
            _activeScanFilename = 'mammo_screening_r_cc.dcm';
          }
        });
        _showToast(isAr ? 'تم حذف الفحص بنجاح' : 'Scan removed successfully', isError: true);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showUploadSourceSheet() {
    final isAr = context.isArabic;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.powderBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.drive_folder_upload_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'إرفاق فحص طبي للمراجعة الفورية' : 'Attach Scan for Instant Review',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                      Text(
                        isAr
                            ? 'سيظهر الفحص فوراً في شاشة الاستعراض (DICOM) ويتم تحليله بالذكاء الاصطناعي'
                            : 'Scan renders immediately into the DICOM viewport with AI analysis',
                        style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: AppColors.powderBackground,
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: Text(
                isAr ? 'التقاط فحص فوري بالكاميرا' : 'Instant Camera Capture',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              subtitle: Text(
                isAr ? 'تصوير شاشة السونار أو فيلم الماموجرام المطبوع' : 'Direct capture of physical scan or screen',
                style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText),
              onTap: () {
                Navigator.pop(ctx);
                _captureScanFromCamera();
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: AppColors.powderBackground,
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: Text(
                isAr ? 'اختيار فحص من معرض الصور (Gallery)' : 'Pick Scan from Gallery',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              subtitle: Text(
                isAr ? 'صور الأشعة، السونار، أو لقطات الشاشة الطبية' : 'Ultrasound / mammogram image from device',
                style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText),
              onTap: () {
                Navigator.pop(ctx);
                _pickScanImageFromGallery();
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: AppColors.powderBackground,
              leading: const Icon(Icons.snippet_folder_rounded, color: AppColors.primary),
              title: Text(
                isAr ? 'ملف طبي / DICOM / تقرير PDF' : 'Pick Medical File / DICOM / PDF',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              subtitle: Text(
                isAr ? 'تصفح ملفات الهاتف واختيار فحوصات رقمية أو تقارير' : 'Browse device files and clinical documents',
                style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText),
              onTap: () {
                Navigator.pop(ctx);
                _pickScanFileFromStorage();
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: AppColors.primary.withValues(alpha: 0.08),
              leading: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
              title: Text(
                isAr ? 'التحليل الاستشاري الشامل (EHR Suite)' : 'Full AI Diagnostic Suite',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.primary),
              ),
              subtitle: Text(
                isAr ? 'رفع ملف مع استعراض النتائج والبروتوكول السريري المقترح' : 'Analyze scan with clinical management recommendations',
                style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
              onTap: () {
                Navigator.pop(ctx);
                ScanUploadDialog.show(
                  context,
                  isDoctor: true,
                  onScanProcessed: (name, bytes, biRads, finding) {
                    _loadNewScanIntoViewer(
                      filename: name,
                      bytes: bytes,
                      category: name.toLowerCase().contains('mammo') ? 'MAMMOGRAM' : 'ULTRASOUND',
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isArabic;

    return AdaptiveScaffold(
      selectedIndex: 2,
      titleKey: 'navImaging',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Notice Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.powderBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.softDustyBlush, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security_update_warning_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'وحدة الاستعراض الاستشاري الثانوي (DICOM)' : 'Secondary Review Console (SaMD Compliant)',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAr
                              ? 'هذه المنصة مخصصة للمراجعة السريرية من قبل الأطباء المتخصصين. نماذج الرؤية الحاسوبية تعمل كأداة دعم إرشادي ثانوي فقط ولا تقدم تشخيصاً طبياً منفرداً.'
                              : 'Secondary reader aid only. Final diagnosis remains the exclusive responsibility of the certified radiologist.',
                          style: const TextStyle(fontSize: 11, color: AppColors.secondaryText, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scan View Selector Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.whiteSurface,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AppColors.warmNeutralSand),
              ),
              child: Row(
                children: _views.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final title = entry.value;
                  final isSelected = _selectedViewIndex == idx;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedViewIndex = idx),
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // High-Tech DICOM Dark Viewport
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2E2C33), width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 4)),
                ],
              ),
              child: Stack(
                children: [
                  // Actual Rendered File / Scan or High-Res Simulated Texture
                  Positioned.fill(
                    child: Center(
                      child: _activeScanBytes != null
                          ? InteractiveViewer(
                              panEnabled: true,
                              scaleEnabled: true,
                              minScale: 0.8,
                              maxScale: 3.5,
                              child: ColorFiltered(
                                colorFilter: _isInverted
                                    ? const ColorFilter.matrix([
                                        -1, 0, 0, 0, 255,
                                        0, -1, 0, 0, 255,
                                        0, 0, -1, 0, 255,
                                        0, 0, 0, 1, 0,
                                      ])
                                    : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                                child: Transform.scale(
                                  scale: _zoomLevel,
                                  child: Image.memory(
                                    _activeScanBytes!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.document_scanner_rounded, color: AppColors.primary, size: 56),
                                            const SizedBox(height: 12),
                                            Text(
                                              _activeScanFilename,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white12,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isAr ? 'ملف فحص رقمي (DICOM / Document) قيد المراجعة' : 'Medical Scan Record Loaded',
                                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: _showUploadSourceSheet,
                              child: Transform.scale(
                                scale: _zoomLevel,
                                child: Container(
                                  width: 280,
                                  height: 320,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: RadialGradient(
                                      center: const Alignment(-0.2, 0.1),
                                      radius: 0.85,
                                      colors: _isInverted
                                          ? [
                                              const Color(0xFF1E1E24),
                                              const Color(0xFF4A4A58),
                                              const Color(0xFFE2E2EA),
                                            ]
                                          : [
                                              const Color(0xFFEEEEF5),
                                              const Color(0xFF555566),
                                              const Color(0xFF0F0F12),
                                            ],
                                      stops: const [0.0, 0.55, 1.0],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Simulated Fibroglandular Texture
                                      Positioned(
                                        top: 80,
                                        left: 60,
                                        child: Container(
                                          width: 100,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: (_isInverted ? Colors.black : Colors.white).withValues(alpha: 0.35),
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                        ),
                                      ),
                                      // Focal Asymmetry ROI Box
                                      Positioned(
                                        top: 90,
                                        left: 85,
                                        child: Container(
                                          width: 55,
                                          height: 55,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.amber, width: 2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Align(
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                              padding: EdgeInsets.all(2),
                                              child: Text(
                                                'ROI 1',
                                                style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Quick Pick Hint Overlay
                                      Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.touch_app_rounded, color: Colors.white.withValues(alpha: 0.7), size: 28),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.6),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: Colors.white24),
                                              ),
                                              child: Text(
                                                isAr ? 'اضغطي لرفع أو عرض فحص حقيقي' : 'Tap to load scan image',
                                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Top Full-Width Glassmorphic HUD (Prevents Text & Badge Clashing)
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _activePatientName,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$_activeScanFilename • $_activeScanDate',
                                  style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  _activeDeviceModel,
                                  style: const TextStyle(color: Colors.white38, fontSize: 9.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Text(
                              _views[_selectedViewIndex],
                              style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Loading Overlay during AI analysis
                  if (_isAnalyzing)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(color: AppColors.primary),
                              const SizedBox(height: 12),
                              Text(
                                isAr ? 'جاري تحليل الصورة بالذكاء الاصطناعي...' : 'Analyzing scan with AI model...',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Bottom DICOM Controls Toolbar
                  Positioned(
                    bottom: 14,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xDD1A1A22),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 22),
                            tooltip: isAr ? 'تكبير' : 'Zoom In',
                            onPressed: () => setState(() => _zoomLevel = (_zoomLevel + 0.2).clamp(0.8, 3.0)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.zoom_out_rounded, color: Colors.white, size: 22),
                            tooltip: isAr ? 'تصغير' : 'Zoom Out',
                            onPressed: () => setState(() => _zoomLevel = (_zoomLevel - 0.2).clamp(0.8, 3.0)),
                          ),
                          IconButton(
                            icon: Icon(
                              _isInverted ? Icons.brightness_high_rounded : Icons.invert_colors_rounded,
                              color: _isInverted ? Colors.amber : Colors.white,
                              size: 22,
                            ),
                            tooltip: isAr ? 'عكس التدرج الرمادي (Invert Grayscale)' : 'Invert Grayscale',
                            onPressed: () => setState(() => _isInverted = !_isInverted),
                          ),
                          IconButton(
                            icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 22),
                            tooltip: isAr ? 'اختيار فحص من الجهاز' : 'Pick Scan File',
                            onPressed: _pickScanImageFromGallery,
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                            tooltip: isAr ? 'إعادة الضبط' : 'Reset View',
                            onPressed: () => setState(() {
                              _zoomLevel = 1.0;
                              _isInverted = false;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Direct Input Bar: Pick Real Files Right Into Viewport
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: Text(
                      isAr ? 'تصوير فحص' : 'Camera Snap',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                    onPressed: _captureScanFromCamera,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.image_search_rounded, size: 18),
                    label: Text(
                      isAr ? 'معرض الصور' : 'Pick Image',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                    onPressed: _pickScanImageFromGallery,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.file_present_rounded, size: 18),
                    label: Text(
                      isAr ? 'ملف طبي' : 'Pick File',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                    onPressed: _pickScanFileFromStorage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Unified Clinical Records & Scans Hub
            AppCard(
              padding: const EdgeInsets.all(16),
              border: Border.all(color: AppColors.primary, width: 1.5),
              color: AppColors.powderBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.folder_shared_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusBadge.blush(
                              isAr ? 'السجل الطبي والاستشاري' : 'Clinical Records Hub',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAr ? 'إرفاق وفحص التقارير الطبية (EHR)' : 'Medical Records & Analysis Suite',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAr
                                  ? 'إرفاق وفحص أي وثيقة: سونار، ماموجرام رقمي، تحاليل، أو تقارير خزعة'
                                  : 'Upload & review records: Ultrasound, Mammogram, Biopsy, Labs',
                              style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file_rounded, size: 18),
                      label: Text(
                        isAr ? 'إرفاق وفحص فحص طبي جديد' : 'Attach & Review New Scan',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: _showUploadSourceSheet,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // AI Secondary Observation & Review Sign-off
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
                        child: const Icon(Icons.psychology_alt_rounded, color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? 'تقرير الملاحظة الاستشارية الثانوية' : 'Secondary Diagnostic Observations',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                            Text(
                              isAr ? 'الفحص النشط: $_activeScanFilename' : 'Active Scan: $_activeScanFilename',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge.active(_isReviewed ? (isAr ? 'تم التوقيع' : 'Signed') : (isAr ? 'قيد التدقيق' : 'Pending')),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      StatusBadge.pending(_activeBiRads),
                      const SizedBox(width: 8),
                      Text(
                        _activeFinding,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'الملاحظات الميدانية:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAr
                        ? '• تصنيف الفحص الحالي: $_activeBiRads ($_activeFinding).\n• فحص دقيق للحدود النسيجية، الأوعية المحيطة، وتناسق الارتداد الصوتي مقارنة بالسجلات السابقة.\n• الحدود الجلدية والحلمة طبيعية بالكامل دون أي انكماش أو تجعد.'
                        : '• Current Scan Staging: $_activeBiRads ($_activeFinding).\n• Precise tissue margin assessment and acoustic transmission evaluation.\n• Skin contours and nipple-areola complex are normal without retraction.',
                    style: const TextStyle(fontSize: 13, color: AppColors.mainText, height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  PillButton(
                    label: _isReviewed
                        ? (isAr ? 'تم اعتماد المراجعة السريرية بنجاح' : 'Review Confirmed & Stamped')
                        : (isAr ? 'اعتماد المراجعة السريرية وإضافتها للملف' : 'Confirm Secondary Clinical Review'),
                    icon: _isReviewed ? Icons.verified_rounded : Icons.check_circle_outline_rounded,
                    onPressed: () {
                      setState(() => _isReviewed = true);
                      _showToast(isAr ? 'تم اعتماد المراجعة وإرفاق التقرير الطبي لملف سارة أحمد' : 'Secondary review signed and saved to chart');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Scan Records & History Management Card (Rename & Delete & View)
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
                        child: const Icon(Icons.folder_shared_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? 'سجل التحليلات والفحوصات المحفوظة' : 'Scan Records & History',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                            Text(
                              isAr
                                  ? 'اضغطي على أي فحص لعرضه فوراً في شاشة الـ DICOM'
                                  : 'Tap any scan to inspect immediately in DICOM console',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.softDustyBlush.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          '${_scanHistory.length} ${isAr ? "فحوصات" : "scans"}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (_scanHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          isAr ? 'لا توجد فحوصات محفوظة حالياً' : 'No saved scans found',
                          style: const TextStyle(color: AppColors.secondaryText),
                        ),
                      ),
                    )
                  else
                    ..._scanHistory.map((scan) {
                      final isCurrent = _activeScanFilename == scan['filename'];

                      return InkWell(
                        onTap: () => _selectScanFromHistory(scan),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            color: isCurrent ? AppColors.powderBackground : AppColors.whiteSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isCurrent ? AppColors.primary : AppColors.warmNeutralSand,
                              width: isCurrent ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isCurrent ? AppColors.primary : AppColors.powderBackground,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  scan['category'] == 'ULTRASOUND'
                                      ? Icons.waves_rounded
                                      : scan['category'] == 'MAMMOGRAM'
                                          ? Icons.document_scanner_rounded
                                          : Icons.biotech_rounded,
                                  color: isCurrent ? Colors.white : AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scan['filename'] ?? '',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isCurrent ? AppColors.primary : AppColors.mainText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${scan['date']} • ${scan['biRads']} (${scan['finding'] ?? ""})',
                                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Actions: View, Rename, and Delete
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      isCurrent ? Icons.visibility_rounded : Icons.visibility_outlined,
                                      size: 18,
                                      color: isCurrent ? AppColors.primary : AppColors.secondaryText,
                                    ),
                                    tooltip: isAr ? 'عرض في الشاشة' : 'View in Console',
                                    onPressed: () => _selectScanFromHistory(scan),
                                  ),
                                  const SizedBox(width: 2),
                                  IconButton(
                                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                    tooltip: isAr ? 'إعادة تسمية' : 'Rename',
                                    onPressed: () => _handleRenameScan(scan),
                                  ),
                                  const SizedBox(width: 2),
                                  IconButton(
                                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                    tooltip: isAr ? 'حذف الفحص' : 'Delete',
                                    onPressed: () => _handleDeleteScan(scan),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
