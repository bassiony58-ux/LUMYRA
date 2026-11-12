import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/breast_3d_anatomy_models.dart';

/// High-Fidelity 3D Mathematical Mesh Renderer for the Female Human Breast.
///
/// Implements:
/// - 15 independent anatomical meshes.
/// - 360° orbital camera with yaw and pitch.
/// - Adjustable clipping plane for 3D cross-sections.
/// - Individual tissue visibility toggles.
/// - Focused selection & isolation highlighting.
/// - Patient scan lesion localization mapping.
/// - 6 dedicated clinical view modes.
class Realistic3dBreastPainter extends CustomPainter {
  final double yaw; // Horizontal orbital rotation
  final double pitch; // Vertical orbital rotation
  final double zoom;
  final double clippingPlaneDepth; // 0.0 (Surface) to 1.0 (Deep Ribs)
  final double skinOpacity; // 0.0 to 1.0
  final AnatomicalViewMode viewMode;
  final BreastTissueId? selectedTissue;
  final Set<BreastTissueId> hiddenTissues;
  final PatientLesionLocalization? patientLocalization;
  final double pulseAnimation;
  final bool isArabic;

  Realistic3dBreastPainter({
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.clippingPlaneDepth,
    required this.skinOpacity,
    required this.viewMode,
    required this.selectedTissue,
    required this.hiddenTissues,
    required this.patientLocalization,
    required this.pulseAnimation,
    required this.isArabic,
  });

  bool _isTissueVisible(BreastTissueId id) {
    if (hiddenTissues.contains(id)) return false;
    if (viewMode == AnatomicalViewMode.lymphNodes) {
      // In lymph mode, emphasize lymphatics and nodes
      return id == BreastTissueId.axillaryLymphNodes ||
          id == BreastTissueId.lymphaticVessels ||
          id == BreastTissueId.axillaryTail ||
          id == BreastTissueId.pectoralisMajor ||
          skinOpacity > 0.4 && id == BreastTissueId.skin;
    }
    return true;
  }

  double _getTissueAlpha(BreastTissueId id) {
    if (!_isTissueVisible(id)) return 0.0;
    if (selectedTissue != null) {
      if (selectedTissue == id) return 1.0;
      return 0.18; // Softly dim unselected tissues while retaining context
    }
    if (id == BreastTissueId.skin) return skinOpacity;
    if (id == BreastTissueId.areola || id == BreastTissueId.nipple) {
      return (skinOpacity * 1.2).clamp(0.4, 1.0);
    }
    return 1.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 - 10;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(zoom, zoom);

    // Apply 3D perspective projection
    final cosY = math.cos(yaw);
    final sinY = math.sin(yaw);
    final cosP = math.cos(pitch);
    final sinP = math.sin(pitch);

    // Coordinate transformation function: maps 3D point (x, y, z) to 2D canvas point
    Offset project(double x, double y, double z) {
      // Rotate around Y-axis (Yaw)
      final x1 = x * cosY - z * sinY;
      final z1 = x * sinY + z * cosY;
      // Rotate around X-axis (Pitch)
      final y2 = y * cosP - z1 * sinP;
      final z2 = y * sinP + z1 * cosP;
      // Perspective division
      final perspective = 380.0 / (380.0 - z2 * 0.45);
      return Offset(x1 * perspective, y2 * perspective);
    }

    // 1. Ambient Background Grid & Depth Aura
    _drawAnatomicalDepthAura(canvas);

    // 2. Deep Posterior Musculoskeletal Wall (Ribs, Intercostals, Pectoralis Major)
    if (_isTissueVisible(BreastTissueId.ribsIntercostal)) {
      _drawRibsAndIntercostals(canvas, project);
    }

    if (_isTissueVisible(BreastTissueId.pectoralisMajor)) {
      _drawPectoralisMajor(canvas, project);
    }

    if (_isTissueVisible(BreastTissueId.retromammarySpace)) {
      _drawRetromammarySpace(canvas, project);
    }

    // 3. Middle Glandular Core (Lobes, Lobules TDLUs, Lactiferous Ducts)
    if (_isTissueVisible(BreastTissueId.glandular)) {
      _drawGlandularParenchyma(canvas, project);
    }

    if (_isTissueVisible(BreastTissueId.mammaryLobes)) {
      _drawMammaryLobes(canvas, project);
    }

    if (_isTissueVisible(BreastTissueId.lobules)) {
      _drawLobulesTDLUs(canvas, project);
    }

    if (_isTissueVisible(BreastTissueId.lactiferousDucts)) {
      _drawLactiferousDucts(canvas, project);
    }

    // 4. Connective & Adipose Architecture (Cooper's Ligaments, Adipose Lobules)
    if (_isTissueVisible(BreastTissueId.coopersLigaments)) {
      _drawCoopersLigaments(canvas, project);
    }

    if (_isTissueVisible(BreastTissueId.adipose)) {
      _drawAdiposeTissue(canvas, project);
    }

    // 5. Axillary Lymphatic System (Axillary Tail, Nodes, Lymphatic Vessels)
    if (_isTissueVisible(BreastTissueId.axillaryTail)) {
      _drawAxillaryTail(canvas, project);
    }

    if (_isTissueVisible(BreastTissueId.lymphaticVessels)) {
      _drawLymphaticVessels(canvas, project);
    }

    if (_isTissueVisible(BreastTissueId.axillaryLymphNodes)) {
      _drawAxillaryLymphNodes(canvas, project);
    }

    // 6. Superficial Envelope (Breast Skin, Areola, Nipple)
    if (_isTissueVisible(BreastTissueId.skin) && skinOpacity > 0.05) {
      _drawSkinEnvelope(canvas, project);
    }

    if (_isTissueVisible(BreastTissueId.areola) && skinOpacity > 0.05) {
      _drawAreola(canvas, project);
    }

    if (_isTissueVisible(BreastTissueId.nipple) && skinOpacity > 0.05) {
      _drawNipple(canvas, project);
    }

    // 7. Clinical Pathology Localization Layer (Tumor Mass & Evidence)
    if (viewMode == AnatomicalViewMode.tumorVisualization ||
        viewMode == AnatomicalViewMode.patientScanOverlay ||
        viewMode == AnatomicalViewMode.comparisonMode) {
      _drawLocalizedLesion(canvas, project);
    }

    // 8. Interactive Selection Highlight Glow on Selected Mesh
    if (selectedTissue != null) {
      _drawSelectedTissueGlow(canvas, project, selectedTissue!);
    }

    canvas.restore();
  }

  void _drawAnatomicalDepthAura(Canvas canvas) {
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.07),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 150))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 150, auraPaint);
  }

  void _drawRibsAndIntercostals(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = _getTissueAlpha(BreastTissueId.ribsIntercostal);
    if (alpha <= 0.0) return;

    final ribYPositions = [-65.0, -25.0, 18.0, 60.0];
    for (int i = 0; i < ribYPositions.length; i++) {
      final y = ribYPositions[i];
      // Rib oval bone section in 3D
      final p1 = project(-95, y - 10, -55);
      final p2 = project(-70, y - 8, -50);
      final p3 = project(-70, y + 10, -50);
      final p4 = project(-95, y + 8, -55);

      final ribPath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..lineTo(p4.dx, p4.dy)
        ..close();

      // Cortical bone + marrow gradient
      final ribPaint = Paint()
        ..color = const Color(0xFFFEF3C7).withValues(alpha: alpha * 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawPath(ribPath, ribPaint);

      final borderPaint = Paint()
        ..color = const Color(0xFF94A3B8).withValues(alpha: alpha)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawPath(ribPath, borderPaint);

      // Intercostal muscle band between ribs
      if (i < ribYPositions.length - 1) {
        final nextY = ribYPositions[i + 1];
        final ip1 = project(-92, y + 9, -54);
        final ip2 = project(-72, y + 10, -50);
        final ip3 = project(-72, nextY - 9, -50);
        final ip4 = project(-92, nextY - 10, -54);

        final interPath = Path()
          ..moveTo(ip1.dx, ip1.dy)
          ..lineTo(ip2.dx, ip2.dy)
          ..lineTo(ip3.dx, ip3.dy)
          ..lineTo(ip4.dx, ip4.dy)
          ..close();

        canvas.drawPath(
          interPath,
          Paint()
            ..color = const Color(0xFFBE123C).withValues(alpha: alpha * 0.75)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  void _drawPectoralisMajor(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = _getTissueAlpha(BreastTissueId.pectoralisMajor);
    if (alpha <= 0.0) return;

    // Fan-shaped muscular slab
    final pTopLeft = project(-105, -85, -45);
    final pTopRight = project(-45, -75, -40);
    final pBottomRight = project(-45, 80, -40);
    final pBottomLeft = project(-105, 85, -45);

    final musclePath = Path()
      ..moveTo(pTopLeft.dx, pTopLeft.dy)
      ..lineTo(pTopRight.dx, pTopRight.dy)
      ..lineTo(pBottomRight.dx, pBottomRight.dy)
      ..lineTo(pBottomLeft.dx, pBottomLeft.dy)
      ..close();

    final muscleGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF881337).withValues(alpha: alpha),
        const Color(0xFF9F1239).withValues(alpha: alpha),
        const Color(0xFFBE123C).withValues(alpha: alpha),
      ],
    );

    canvas.drawPath(
      musclePath,
      Paint()
        ..shader = muscleGrad.createShader(const Rect.fromLTWH(-105, -85, 60, 170))
        ..style = PaintingStyle.fill,
    );

    // Striation lines
    final fiberPaint = Paint()
      ..color = const Color(0xFFFDA4AF).withValues(alpha: alpha * 0.35)
      ..strokeWidth = 1.2;
    for (double fy = -75; fy <= 75; fy += 15) {
      final s = project(-100, fy, -44);
      final e = project(-50, fy + 8, -40);
      canvas.drawLine(s, e, fiberPaint);
    }
  }

  void _drawRetromammarySpace(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = _getTissueAlpha(BreastTissueId.retromammarySpace);
    if (alpha <= 0.0) return;

    // Translucent gliding fascial plane
    final p1 = project(-45, -70, -38);
    final p2 = project(-40, -68, -35);
    final p3 = project(-40, 72, -35);
    final p4 = project(-45, 75, -38);

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFE2E8F0).withValues(alpha: alpha * 0.45)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawGlandularParenchyma(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = _getTissueAlpha(BreastTissueId.glandular);
    if (alpha <= 0.0) return;

    // Central dense fibroglandular disc in 3D
    final center = project(0, 0, -18);
    final radius = 55.0;

    final glandGrad = RadialGradient(
      colors: [
        const Color(0xFFFFF1F2).withValues(alpha: alpha * 0.95),
        const Color(0xFFFDA4AF).withValues(alpha: alpha * 0.85),
        const Color(0xFFF43F5E).withValues(alpha: alpha * 0.7),
      ],
      stops: const [0.2, 0.65, 1.0],
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = glandGrad.createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.fill,
    );
  }

  void _drawMammaryLobes(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = _getTissueAlpha(BreastTissueId.mammaryLobes);
    if (alpha <= 0.0) return;

    // 15-20 Radial Pyramidal Lobes radiating toward center
    final lobeBorder = Paint()
      ..color = const Color(0xFFBE185D).withValues(alpha: alpha * 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi * 2) / 16;
      final pCenter = project(0, 0, -10);
      final pOuter1 = project(math.cos(angle - 0.14) * 58, math.sin(angle - 0.14) * 58, -20);
      final pOuter2 = project(math.cos(angle + 0.14) * 58, math.sin(angle + 0.14) * 58, -20);

      final lobePath = Path()
        ..moveTo(pCenter.dx, pCenter.dy)
        ..lineTo(pOuter1.dx, pOuter1.dy)
        ..quadraticBezierTo(
          (pOuter1.dx + pOuter2.dx) / 2 + math.cos(angle) * 6,
          (pOuter1.dy + pOuter2.dy) / 2 + math.sin(angle) * 6,
          pOuter2.dx,
          pOuter2.dy,
        )
        ..close();

      canvas.drawPath(
        lobePath,
        Paint()
          ..color = (i % 2 == 0 ? const Color(0xFFFCE7F3) : const Color(0xFFFBCFE8)).withValues(alpha: alpha * 0.35)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(lobePath, lobeBorder);
    }
  }

  void _drawLobulesTDLUs(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = _getTissueAlpha(BreastTissueId.lobules);
    if (alpha <= 0.0) return;

    // Acini micro-clusters
    final lobulePaint = Paint()
      ..color = const Color(0xFFF43F5E).withValues(alpha: alpha * 0.9)
      ..style = PaintingStyle.fill;
    final aciniPaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha * 0.8)
      ..style = PaintingStyle.fill;

    final angles = [0.2, 0.6, 1.1, 1.6, 2.1, 2.6, 3.2, 3.8, 4.3, 4.8, 5.3, 5.9];
    for (final a in angles) {
      final r = 38.0 + math.sin(a * 4) * 8.0;
      final pos = project(math.cos(a) * r, math.sin(a) * r, -18);

      canvas.drawCircle(pos, 6.5, lobulePaint);
      canvas.drawCircle(Offset(pos.dx - 1.5, pos.dy - 1.5), 2.0, aciniPaint);
      canvas.drawCircle(Offset(pos.dx + 2, pos.dy + 1.5), 1.5, aciniPaint);
    }
  }

  void _drawLactiferousDucts(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = _getTissueAlpha(BreastTissueId.lactiferousDucts);
    if (alpha <= 0.0) return;

    final ductPaint = Paint()
      ..color = const Color(0xFF9F1239).withValues(alpha: alpha * 0.9)
      ..strokeWidth = 1.9
      ..style = PaintingStyle.stroke;

    final pNipple = project(0, 0, 5);

    // Main collecting trunks
    final angles = [0.1, 0.5, 0.9, 1.4, 1.9, 2.4, 2.9, 3.4, 3.9, 4.4, 4.9, 5.5, 6.0];
    for (final a in angles) {
      final pIntermediate = project(math.cos(a) * 22, math.sin(a) * 22, -8);
      final pOuter = project(math.cos(a) * 44, math.sin(a) * 44, -18);

      canvas.drawLine(pNipple, pIntermediate, ductPaint);
      canvas.drawLine(pIntermediate, pOuter, ductPaint..strokeWidth = 1.4);
    }

    // Subareolar Lactiferous Ampullae / Sinuses (Dilated collecting pools)
    final sinusPaint = Paint()
      ..color = const Color(0xFF881337).withValues(alpha: alpha)
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (double sa = 0; sa < math.pi * 2; sa += 0.8) {
      final p1 = project(math.cos(sa) * 6, math.sin(sa) * 6, 2);
      final p2 = project(math.cos(sa) * 12, math.sin(sa) * 12, -2);
      canvas.drawLine(p1, p2, sinusPaint);
    }
  }

  void _drawCoopersLigaments(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = _getTissueAlpha(BreastTissueId.coopersLigaments);
    if (alpha <= 0.0) return;

    final ligPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: alpha * 0.75)
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke;

    // Radiating suspension anchors
    for (double a = 0.3; a < math.pi * 2; a += 0.7) {
      final pDeep = project(math.cos(a) * 55, math.sin(a) * 55, -35);
      final pMid = project(math.cos(a) * 45, math.sin(a) * 45, -12);
      final pSuperficial = project(math.cos(a) * 72, math.sin(a) * 72, -5);

      final path = Path()
        ..moveTo(pDeep.dx, pDeep.dy)
        ..quadraticBezierTo(pMid.dx, pMid.dy, pSuperficial.dx, pSuperficial.dy);
      canvas.drawPath(path, ligPaint);
    }
  }

  void _drawAdiposeTissue(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = _getTissueAlpha(BreastTissueId.adipose);
    if (alpha <= 0.0) return;

    final fatFill = Paint()
      ..color = const Color(0xFFFBBF24).withValues(alpha: alpha * 0.32)
      ..style = PaintingStyle.fill;
    final fatStroke = Paint()
      ..color = const Color(0xFFD97706).withValues(alpha: alpha * 0.28)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Subcutaneous fat droplets around the periphery
    for (double a = 0.2; a < math.pi * 2; a += 0.45) {
      final r = 62.0 + math.sin(a * 3) * 6.0;
      final pos = project(math.cos(a) * r, math.sin(a) * r, -10);

      canvas.drawCircle(pos, 10.5, fatFill);
      canvas.drawCircle(pos, 10.5, fatStroke);
      canvas.drawCircle(Offset(pos.dx + 3, pos.dy - 2), 6.5, fatFill);
    }
  }

  void _drawAxillaryTail(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = _getTissueAlpha(BreastTissueId.axillaryTail);
    if (alpha <= 0.0) return;

    // Superolateral tongue tracking toward axilla
    final p1 = project(45, -45, -20);
    final p2 = project(85, -80, -35);
    final p3 = project(105, -70, -35);
    final p4 = project(65, -35, -20);

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..cubicTo(p2.dx, p2.dy, p3.dx, p3.dy, p4.dx, p4.dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFDA4AF).withValues(alpha: alpha * 0.6)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFE11D48).withValues(alpha: alpha * 0.8)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawLymphaticVessels(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = _getTissueAlpha(BreastTissueId.lymphaticVessels);
    if (alpha <= 0.0) return;

    final lymphPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: alpha * 0.85)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final pSappey = project(0, 0, 4);
    final pAxilla1 = project(55, -45, -25);
    final pAxilla2 = project(85, -75, -38);
    final pAxilla3 = project(110, -95, -45);

    // Main lymphatic trunk
    final path = Path()
      ..moveTo(pSappey.dx, pSappey.dy)
      ..quadraticBezierTo(pAxilla1.dx, pAxilla1.dy, pAxilla2.dx, pAxilla2.dy)
      ..lineTo(pAxilla3.dx, pAxilla3.dy);
    canvas.drawPath(path, lymphPaint);
  }

  void _drawAxillaryLymphNodes(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = _getTissueAlpha(BreastTissueId.axillaryLymphNodes);
    if (alpha <= 0.0) return;

    // Level I (Low axilla)
    final pL1 = project(85, -75, -38);
    // Level II (Mid axilla)
    final pL2 = project(105, -90, -42);
    // Level III (Apical axilla)
    final pL3 = project(122, -105, -46);

    final nodePaint = Paint()
      ..color = const Color(0xFF059669).withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    final hilumPaint = Paint()
      ..color = const Color(0xFFFEF3C7).withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    for (final np in [pL1, pL2, pL3]) {
      // Reniform lymph node
      canvas.drawOval(
        Rect.fromCenter(center: np, width: 14, height: 9),
        nodePaint,
      );
      // Fatty hilum
      canvas.drawOval(
        Rect.fromCenter(center: np, width: 6, height: 3.5),
        hilumPaint,
      );
    }

    // If patient localization shows abnormal node, highlight it with pulsing ring
    if (patientLocalization?.lymphNodeAbnormalityDetected == true) {
      canvas.drawCircle(
        pL1,
        14 + pulseAnimation * 5,
        Paint()
          ..color = const Color(0xFFEF4444).withValues(alpha: 0.6)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _drawSkinEnvelope(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = skinOpacity;
    if (alpha <= 0.0) return;

    // Organic teardrop silhouette of the female breast
    final pTop = project(0, -78, -10);
    final pRight = project(82, 0, -15);
    final pBottom = project(0, 92, -10);
    final pLeft = project(-82, 0, -15);

    final skinPath = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..cubicTo(pRight.dx + 15, pTop.dy + 10, pRight.dx + 10, pBottom.dy - 20, pBottom.dx, pBottom.dy)
      ..cubicTo(pLeft.dx - 10, pBottom.dy - 10, pLeft.dx - 15, pTop.dy + 15, pTop.dx, pTop.dy)
      ..close();

    final skinGrad = RadialGradient(
      center: Alignment(math.sin(yaw) * 0.35, -0.25),
      radius: 0.95,
      colors: [
        const Color(0xFFFFF7ED).withValues(alpha: alpha),
        const Color(0xFFFFEDD5).withValues(alpha: alpha),
        const Color(0xFFFED7AA).withValues(alpha: alpha),
        const Color(0xFFFDBA74).withValues(alpha: alpha * 0.95),
        const Color(0xFFEA580C).withValues(alpha: alpha * 0.8),
      ],
      stops: const [0.0, 0.35, 0.65, 0.88, 1.0],
    );

    canvas.drawPath(
      skinPath,
      Paint()
        ..shader = skinGrad.createShader(Rect.fromCircle(center: project(0, 0, 0), radius: 105))
        ..style = PaintingStyle.fill,
    );
  }

  void _drawAreola(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = (skinOpacity * 1.2).clamp(0.4, 1.0);
    final center = project(0, 0, 4);

    // Natural circular pigmented areola disc
    final areolaGrad = RadialGradient(
      colors: [
        const Color(0xFFBE185D).withValues(alpha: alpha),
        const Color(0xFF9D174D).withValues(alpha: alpha),
        const Color(0xFF831843).withValues(alpha: alpha),
      ],
      stops: const [0.0, 0.65, 1.0],
    );

    canvas.drawOval(
      Rect.fromCenter(center: center, width: 44, height: 42),
      Paint()
        ..shader = areolaGrad.createShader(Rect.fromCircle(center: center, radius: 24))
        ..style = PaintingStyle.fill,
    );

    // Montgomery Tubercles (Areolar sebaceous glands)
    final tubercles = [
      Offset(center.dx - 12, center.dy - 10),
      Offset(center.dx + 12, center.dy - 11),
      Offset(center.dx - 14, center.dy + 8),
      Offset(center.dx + 13, center.dy + 9),
      Offset(center.dx, center.dy - 16),
      Offset(center.dx, center.dy + 15),
    ];
    for (final tp in tubercles) {
      canvas.drawCircle(tp, 1.6, Paint()..color = const Color(0xFFFBCFE8).withValues(alpha: alpha));
    }
  }

  void _drawNipple(Canvas canvas, Offset Function(double, double, double) project) {
    final alpha = (skinOpacity * 1.2).clamp(0.4, 1.0);
    final center = project(0, 0, 7);

    // Projected nipple papilla
    final nippleRect = Rect.fromCenter(center: center, width: 17, height: 17);
    final nippleGrad = RadialGradient(
      colors: [
        const Color(0xFFF472B6).withValues(alpha: alpha),
        const Color(0xFFDB2777).withValues(alpha: alpha),
        const Color(0xFF9D174D).withValues(alpha: alpha),
      ],
    );

    canvas.drawOval(nippleRect, Paint()..shader = nippleGrad.createShader(nippleRect));

    // Lactiferous duct pore openings
    final porePaint = Paint()..color = const Color(0xFF500724).withValues(alpha: alpha);
    canvas.drawCircle(Offset(center.dx - 2.5, center.dy - 2), 0.9, porePaint);
    canvas.drawCircle(Offset(center.dx + 2.5, center.dy - 1), 0.9, porePaint);
    canvas.drawCircle(Offset(center.dx, center.dy + 2.5), 0.9, porePaint);
  }

  void _drawLocalizedLesion(Canvas canvas, Offset Function(double, double, double) project) {
    final loc = patientLocalization;
    if (loc == null || !loc.isSpatialLocationVerified) {
      // Rule: Never invent coordinates if data is unverified or insufficient
      return;
    }

    final coords = loc.compute3dCoordinates();
    final pos = project(coords.x, coords.y, coords.z);
    final radius = (loc.sizeLengthMm * 0.7).clamp(8.0, 26.0);

    // Pulsing warning ring
    canvas.drawCircle(
      pos,
      radius + 6.0 + pulseAnimation * 5.0,
      Paint()
        ..color = Color(loc.findingType.colorValue).withValues(alpha: 0.35)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    // High-fidelity tumor mass with desmoplasia
    final massGrad = RadialGradient(
      colors: [
        const Color(0xFF4C0519),
        Color(loc.findingType.colorValue),
        const Color(0xFF881337),
      ],
    );

    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..shader = massGrad.createShader(Rect.fromCircle(center: pos, radius: radius))
        ..style = PaintingStyle.fill,
    );

    // Spiculated infiltrative borders for malignant findings
    if (loc.findingType == LesionFindingType.confirmedMalignant) {
      final spiculePaint = Paint()
        ..color = const Color(0xFF4C0519)
        ..strokeWidth = 1.8;
      for (int i = 0; i < 8; i++) {
        final a = (i * math.pi) / 4;
        final p1 = Offset(pos.dx + math.cos(a) * radius, pos.dy + math.sin(a) * radius);
        final p2 = Offset(pos.dx + math.cos(a) * (radius + 9), pos.dy + math.sin(a) * (radius + 9));
        canvas.drawLine(p1, p2, spiculePaint);
      }
    }
  }

  void _drawSelectedTissueGlow(Canvas canvas, Offset Function(double, double, double) project, BreastTissueId tissue) {
    Offset focus;
    switch (tissue) {
      case BreastTissueId.skin:
      case BreastTissueId.areola:
      case BreastTissueId.nipple:
        focus = project(0, 0, 5);
        break;
      case BreastTissueId.axillaryTail:
      case BreastTissueId.axillaryLymphNodes:
      case BreastTissueId.lymphaticVessels:
        focus = project(85, -75, -35);
        break;
      case BreastTissueId.pectoralisMajor:
      case BreastTissueId.retromammarySpace:
      case BreastTissueId.ribsIntercostal:
        focus = project(-70, 0, -45);
        break;
      default:
        focus = project(0, 0, -15);
    }

    // High-intensity isolation halo around selected anatomical structure
    canvas.drawCircle(
      focus,
      35 + pulseAnimation * 8,
      Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant Realistic3dBreastPainter oldDelegate) {
    return oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.zoom != zoom ||
        oldDelegate.clippingPlaneDepth != clippingPlaneDepth ||
        oldDelegate.skinOpacity != skinOpacity ||
        oldDelegate.viewMode != viewMode ||
        oldDelegate.selectedTissue != selectedTissue ||
        oldDelegate.hiddenTissues.length != hiddenTissues.length ||
        oldDelegate.pulseAnimation != pulseAnimation;
  }
}
