import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme({bool isArabic = false}) {
    final textTheme = AppTypography.getTextTheme(isArabic: isArabic);

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.softDustyBlush,
      onSecondaryContainer: AppColors.mainText,
      surface: AppColors.surface,
      onSurface: AppColors.mainText,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.powderBackground,
      textTheme: textTheme,
      fontFamily: isArabic ? 'Cairo' : 'Plus Jakarta Sans',

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.powderBackground,
        foregroundColor: AppColors.mainText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),

      // Card Theme (Rounded with soft pink-tinted shadow)
      cardTheme: CardTheme(
        color: AppColors.whiteSurface,
        elevation: 2,
        shadowColor: AppColors.shadowTint,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFF3E4E8), width: 1),
        ),
      ),

      // Pill-Shaped Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAction,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.shadowTint,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(88, 50),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.primary),
          minimumSize: const Size(88, 48),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.primary),
        ),
      ),

      // Input Decoration (Pill-shaped with soft warm borders)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.whiteSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.primaryAction, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText.withAlpha(150)),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
      ),

      // Pill-Shaped Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.softDustyBlush,
        disabledColor: AppColors.warmNeutralSand.withAlpha(128),
        side: const BorderSide(color: AppColors.outline),
        shape: const StadiumBorder(),
        labelStyle: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // Navigation Bar (Mobile)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.whiteSurface,
        indicatorColor: AppColors.softDustyBlush,
        elevation: 6,
        shadowColor: AppColors.shadowTint,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.secondaryText, size: 24);
        }),
      ),

      // Navigation Rail (Tablet)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.whiteSurface,
        indicatorColor: AppColors.softDustyBlush,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: const IconThemeData(color: AppColors.secondaryText),
        selectedLabelTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.whiteSurface,
        elevation: 8,
        shadowColor: AppColors.shadowTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }
}
