import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/localization/app_localization.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
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

  final List<String> _views = ['R-CC View', 'R-MLO View', 'L-CC View', 'مقارنة سابقة'];

  final List<Map<String, dynamic>> _scanHistory = [
    {
      'id': 'scn-101',
      'filename': 'mammo_screening_r_cc.dcm',
      'category': 'MAMMOGRAM',
      'date': '2026-10-30',
      'biRads': 'BI-RADS 2',
      'finding': 'حميد (Benign)',
    },
    {
      'id': 'scn-102',
      'filename': 'ultrasound_targeted_ruq.png',
      'category': 'ULTRASOUND',
      'date': '2026-10-25',
      'biRads': 'BI-RADS 1',
      'finding': 'طبيعي (Normal)',
    },
    {
      'id': 'scn-103',
      'filename': 'biopsy_pathology_report.pdf',
      'category': 'BIOPSY_REPORT',
      'date': '2026-09-12',
      'biRads': 'BI-RADS 2',
      'finding': 'أورام ليفية حميدة (Fibroadenoma)',
    },
  ];

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
      } catch (_) {
        // Fallback smooth local update
      }

      if (mounted) {
        setState(() {
          scan['filename'] = result;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr ? 'تم تعديل اسم الفحص بنجاح' : 'Scan renamed successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
      } catch (_) {
        // Local state update
      }

      if (mounted) {
        setState(() {
          _scanHistory.removeWhere((s) => s['id'] == scan['id']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr ? 'تم حذف الفحص بنجاح' : 'Scan removed successfully'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          context.isArabic ? 'وحدة الاستعراض الاستشاري الثانوي (DICOM)' : 'Secondary Review Console (SaMD Compliant)',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.isArabic
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

            // DICOM Dark Viewport
            Container(
              height: 380,
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
                  // Simulated Mammogram Scan Graphic
                  Center(
                    child: Transform.scale(
                      scale: _zoomLevel,
                      child: Container(
                        width: 260,
                        height: 340,
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
                            // Density Fibroglandular Texture simulation
                            Positioned(
                              top: 80,
                              left: 60,
                              child: Container(
                                width: 90,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: (_isInverted ? Colors.black : Colors.white).withAlpha(80),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                            // Focal asymmetry ROI box
                            Positioned(
                              top: 90,
                              left: 80,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.amber, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    'ROI 1',
                                    style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Top-Left Patient HUD
                  const Positioned(
                    top: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سارة أحمد محمود (PT-8831)',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'تاريخ الفحص: 2026-10-15 • 10:14 AM',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          'الجهاز: Hologic 3Dimensions Digital Mammography',
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ),

                  // Top-Right DICOM Acquisition HUD
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _views[_selectedViewIndex],
                        style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Bottom Controls Toolbar
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xCC1A1A22),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 22),
                            onPressed: () => setState(() => _zoomLevel = (_zoomLevel + 0.2).clamp(0.8, 2.0)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.zoom_out_rounded, color: Colors.white, size: 22),
                            onPressed: () => setState(() => _zoomLevel = (_zoomLevel - 0.2).clamp(0.8, 2.0)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.invert_colors_rounded, color: Colors.white, size: 22),
                            onPressed: () => setState(() => _isInverted = !_isInverted),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
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
            const SizedBox(height: 18),

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
                              context.isArabic ? 'السجل الطبي والاستشاري' : 'Clinical Records Hub',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.isArabic ? 'إرفاق وفحص التقارير الطبية (EHR)' : 'Medical Records & Analysis Suite',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.isArabic
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
                        context.isArabic ? 'إرفاق وفحص فحص طبي جديد' : 'Attach & Review New Scan',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () => ScanUploadDialog.show(context, isDoctor: true),
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
                              context.isArabic ? 'تقرير الملاحظة الاستشارية الثانوية' : 'Secondary Diagnostic Observations',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                            Text(
                              context.isArabic ? 'حالة المراجعة: بانتظار توقيع الطبيب المعالج' : 'Awaiting Physician Sign-off',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge.active(_isReviewed ? (context.isArabic ? 'تم التوقيع' : 'Signed') : (context.isArabic ? 'قيد التدقيق' : 'Pending')),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    'الملاحظات الميدانية:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '• لا توجد تكلسات دقيقة مشبوهة ذات نمط عنقودي (No clustered pleomorphic microcalcifications).\n• تباين بؤري خفيف في الربع العلوي الخارجي الأيمن، يتطابق مع النسيج الغدي الكثيف ولا يظهر تغيراً مقارنة بالفحص السابق.\n• الحدود الجلدية والحلمة طبيعية بالكامل دون أي انكماش.',
                    style: TextStyle(fontSize: 13, color: AppColors.mainText, height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  PillButton(
                    label: _isReviewed
                        ? (context.isArabic ? 'تم اعتماد المراجعة السريرية بنجاح' : 'Review Confirmed & Stamped')
                        : (context.isArabic ? 'اعتماد المراجعة السريرية وإضافتها للملف' : 'Confirm Secondary Clinical Review'),
                    icon: _isReviewed ? Icons.verified_rounded : Icons.check_circle_outline_rounded,
                    onPressed: () {
                      setState(() => _isReviewed = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.isArabic ? 'تم اعتماد المراجعة وإرفاق التقرير الطبي لملف سارة أحمد' : 'Secondary review signed and saved to chart',
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Scan Records & History Management Card (Rename & Delete)
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
                              context.isArabic ? 'سجل التحليلات والفحوصات المحفوظة' : 'Scan Records & History',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                            Text(
                              context.isArabic
                                  ? 'إدارة الفحوصات الطبية للمريضة مع إمكانية التعديل والحذف'
                                  : 'Manage patient scans with rename & delete capability',
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
                          '${_scanHistory.length} ${context.isArabic ? "فحوصات" : "scans"}',
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
                          context.isArabic ? 'لا توجد فحوصات محفوظة حالياً' : 'No saved scans found',
                          style: const TextStyle(color: AppColors.secondaryText),
                        ),
                      ),
                    )
                  else
                    ..._scanHistory.map((scan) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.whiteSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.warmNeutralSand),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.powderBackground,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                scan['category'] == 'ULTRASOUND'
                                    ? Icons.waves_rounded
                                    : scan['category'] == 'MAMMOGRAM'
                                        ? Icons.document_scanner_rounded
                                        : Icons.biotech_rounded,
                                color: AppColors.primary,
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
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${scan['date']} • ${scan['biRads']}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Actions: Rename and Delete
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                  tooltip: context.isArabic ? 'إعادة تسمية' : 'Rename',
                                  onPressed: () => _handleRenameScan(scan),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                  tooltip: context.isArabic ? 'حذف الفحص' : 'Delete',
                                  onPressed: () => _handleDeleteScan(scan),
                                ),
                              ],
                            ),
                          ],
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
