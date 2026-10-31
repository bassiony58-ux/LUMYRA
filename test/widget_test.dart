import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumyra/app/app.dart';
import 'package:lumyra/app/theme/app_typography.dart';
import 'package:lumyra/core/models/user_role.dart';
import 'package:lumyra/core/widgets/adaptive_scaffold.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppTypography.isTestMode = true;

  group('Lumyra App Navigation & Responsive Tests', () {
    testWidgets('App launches with OnboardingScreen in Arabic', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: LumyraApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Brand emblem and titles
      expect(find.text('لوميرا'), findsOneWidget);
      expect(find.text('رفيقتك الموثوقة لصحة الثدي'), findsOneWidget);
      expect(find.text('ابدئي الآن'), findsOneWidget);
    });

    testWidgets('AdaptiveScaffold renders mobile NavigationBar on narrow screen', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('ar'),
            home: AdaptiveScaffold(
              titleKey: 'navHome',
              body: Center(child: Text('Patient Content')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Patient Content'), findsOneWidget);
    });

    testWidgets('AdaptiveScaffold renders NavigationRail on tablet screen', (tester) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('ar'),
            home: AdaptiveScaffold(
              titleKey: 'navHome',
              body: Center(child: Text('Tablet Content')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Tablet Content'), findsOneWidget);
    });

    test('UserRoleNotifier updates role properly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(userRoleProvider), UserRole.patient);

      container.read(userRoleProvider.notifier).selectRole(UserRole.doctor);
      expect(container.read(userRoleProvider), UserRole.doctor);

      container.read(userRoleProvider.notifier).selectRole(UserRole.admin);
      expect(container.read(userRoleProvider), UserRole.admin);
    });
  });
}
