import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumyra/features/education/domain/models/breast_3d_anatomy_models.dart';
import 'package:lumyra/features/education/presentation/widgets/interactive_3d_breast_viewer.dart';
import 'package:lumyra/features/education/presentation/widgets/realistic_3d_breast_painter.dart';

void main() {
  group('Breast 3D Anatomy Domain Models & KnowledgeBase', () {
    test('all 15 anatomical tissues are defined with bilingual clinical details', () {
      expect(BreastTissueId.values.length, 15);

      for (final tissue in BreastTissueId.values) {
        expect(tissue.nameAr.isNotEmpty, isTrue);
        expect(tissue.nameEn.isNotEmpty, isTrue);

        final info = BreastAnatomyKnowledgeBase.getInfo(tissue);
        expect(info.functionAr.isNotEmpty, isTrue);
        expect(info.functionEn.isNotEmpty, isTrue);
        expect(info.anatomyAr.isNotEmpty, isTrue);
        expect(info.anatomyEn.isNotEmpty, isTrue);
        expect(info.relativePositionAr.isNotEmpty, isTrue);
        expect(info.relativePositionEn.isNotEmpty, isTrue);
        expect(info.clinicalSignificanceAr.isNotEmpty, isTrue);
        expect(info.commonPathologiesAr.isNotEmpty, isTrue);
        expect(info.ultrasoundFindingsAr.isNotEmpty, isTrue);
        expect(info.mriFindingsAr.isNotEmpty, isTrue);
        expect(info.petCtFindingsAr.isNotEmpty, isTrue);
      }
    });

    test('PatientLesionLocalization never fabricates coordinates when unverified', () {
      final unverified = PatientLesionLocalization.unlocalized(
        reasonAr: 'لا تتوفر إحداثيات ثلاثية الأبعاد',
        reasonEn: 'No 3D spatial coordinates available',
      );

      expect(unverified.isSpatialLocationVerified, isFalse);
      final coords = unverified.compute3dCoordinates();
      expect(coords.x, 0.0);
      expect(coords.y, 0.0);
      expect(coords.z, 0.0);
    });

    test('PatientLesionLocalization correctly maps clock position to 3D space', () {
      const verified = PatientLesionLocalization(
        isSpatialLocationVerified: true,
        quadrant: BreastQuadrant.upperOuter,
        clockPosition: 10,
        distanceFromNippleMm: 35.0,
        depthFromSkinMm: 15.0,
        sizeLengthMm: 18.0,
        sizeWidthMm: 14.0,
        sizeDepthMm: 12.0,
        findingType: LesionFindingType.confirmedMalignant,
      );

      expect(verified.isSpatialLocationVerified, isTrue);
      final coords = verified.compute3dCoordinates();
      expect(coords.z < 0, isTrue); // Depth is negative inward into parenchyma
    });

    test('6 AnatomicalViewModes are all present and bilingual', () {
      expect(AnatomicalViewMode.values.length, 6);
      for (final mode in AnatomicalViewMode.values) {
        expect(mode.titleAr.isNotEmpty, isTrue);
        expect(mode.titleEn.isNotEmpty, isTrue);
      }
    });
  });

  group('Interactive3dBreastViewer & Realistic3dBreastPainter Widget Tests', () {
    testWidgets('Realistic3dBreastPainter renders without exceptions across all modes', (tester) async {
      for (final mode in AnatomicalViewMode.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                size: const Size(400, 400),
                painter: Realistic3dBreastPainter(
                  yaw: 0.45,
                  pitch: 0.12,
                  zoom: 1.0,
                  clippingPlaneDepth: 0.0,
                  skinOpacity: 0.5,
                  viewMode: mode,
                  selectedTissue: null,
                  hiddenTissues: {},
                  patientLocalization: null,
                  pulseAnimation: 0.5,
                  isArabic: true,
                ),
              ),
            ),
          ),
        );
        expect(find.byType(CustomPaint), findsWidgets);
      }
    });

    testWidgets('Interactive3dBreastViewer mounts and displays 3D canvas and control buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: 500,
                child: Interactive3dBreastViewer(
                  pathologyType: 'suspicious',
                  isArabic: true,
                  height: 480,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Expect CustomPaint canvas and mode badge to be mounted
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);

      // Switch to 3D Orbit mode
      await tester.tap(find.byIcon(Icons.threed_rotation_rounded));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.layers_rounded), findsOneWidget);
    });
  });
}
