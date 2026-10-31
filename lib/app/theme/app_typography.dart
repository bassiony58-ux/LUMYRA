import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  /// Set to true during widget/unit tests to avoid async network font calls
  static bool isTestMode = false;

  static TextTheme getTextTheme({bool isArabic = false}) {
    if (isTestMode) {
      return const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.mainText),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.mainText),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.mainText),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.mainText),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.mainText),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.mainText),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.secondaryText),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.secondaryText),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
      );
    }

    final baseFont = isArabic ? GoogleFonts.cairoTextTheme() : GoogleFonts.plusJakartaSansTextTheme();

    return baseFont.copyWith(
      displayLarge: (isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans()).copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.mainText,
        letterSpacing: -0.5,
        height: 1.25,
      ),
      displayMedium: (isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans()).copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.mainText,
        height: 1.3,
      ),
      headlineLarge: (isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans()).copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.mainText,
        height: 1.3,
      ),
      headlineMedium: (isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans()).copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.mainText,
        height: 1.35,
      ),
      titleLarge: (isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans()).copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.mainText,
        height: 1.4,
      ),
      titleMedium: (isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans()).copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.mainText,
        height: 1.4,
      ),
      bodyLarge: (isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans()).copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.mainText,
        height: 1.5,
      ),
      bodyMedium: (isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans()).copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.secondaryText,
        height: 1.5,
      ),
      bodySmall: (isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans()).copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.secondaryText,
        height: 1.4,
      ),
      labelLarge: (isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans()).copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.1,
      ),
    );
  }
}
