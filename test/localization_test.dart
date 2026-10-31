import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumyra/app/localization/app_localization.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Lumyra Localization & Directionality Tests', () {
    test('LocaleNotifier defaults to Arabic and toggles to English', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(localeProvider), const Locale('ar'));

      container.read(localeProvider.notifier).toggleLocale();
      expect(container.read(localeProvider), const Locale('en'));

      container.read(localeProvider.notifier).toggleLocale();
      expect(container.read(localeProvider), const Locale('ar'));
    });

    testWidgets('AppStrings delivers localized Arabic and English text', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(capturedContext.tr('appName'), 'لوميرا');
      expect(capturedContext.isArabic, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(capturedContext.tr('appName'), 'Lumyra');
      expect(capturedContext.isArabic, isFalse);
    });
  });
}
