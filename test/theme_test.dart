import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumyra/app/theme/app_colors.dart';
import 'package:lumyra/app/theme/app_theme.dart';
import 'package:lumyra/app/theme/app_typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppTypography.isTestMode = true;

  group('Lumyra Blush & Sand Serenity Theme Tests', () {
    test('Design Tokens match exact brand hex specification', () {
      expect(AppColors.primary, const Color(0xFF9E3E4E));
      expect(AppColors.primaryAction, const Color(0xFFF2808F));
      expect(AppColors.primaryContainer, const Color(0xFFF2808F));
      expect(AppColors.secondary, const Color(0xFF7B5459));
      expect(AppColors.softDustyBlush, const Color(0xFFEEBCC2));
      expect(AppColors.warmNeutralSand, const Color(0xFFE8D6D0));
      expect(AppColors.powderBackground, const Color(0xFFF9E9EF));
      expect(AppColors.surface, const Color(0xFFFFF8F9));
      expect(AppColors.whiteSurface, const Color(0xFFFFFFFF));
      expect(AppColors.mainText, const Color(0xFF21191E));
      expect(AppColors.secondaryText, const Color(0xFF554243));
      expect(AppColors.outline, const Color(0xFFDBC0C2));
      expect(AppColors.error, const Color(0xFFBA1A1A));
    });

    test('ThemeData sets light colorScheme and powderBackground correctly', () {
      final theme = AppTheme.lightTheme(isArabic: false);

      expect(theme.scaffoldBackgroundColor, AppColors.powderBackground);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.primaryContainer, AppColors.primaryContainer);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.error, AppColors.error);
    });

    test('ThemeData enforces pill-shaped button styles', () {
      final theme = AppTheme.lightTheme(isArabic: false);

      expect(theme.elevatedButtonTheme.style?.shape?.resolve({}), isA<StadiumBorder>());
      expect(theme.outlinedButtonTheme.style?.shape?.resolve({}), isA<StadiumBorder>());
      expect(theme.chipTheme.shape, isA<StadiumBorder>());
    });
  });
}
