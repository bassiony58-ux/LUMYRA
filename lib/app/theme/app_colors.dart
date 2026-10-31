import 'package:flutter/material.dart';

/// Lumyra Blush & Sand Serenity Palette
/// Source of truth for brand, surface, and semantic colors.
class AppColors {
  AppColors._();

  // Core Brand Tokens
  static const Color primary = Color(0xFF9E3E4E);          // Deep Mulberry
  static const Color primaryAction = Color(0xFFF2808F);    // Coral Blush (Primary CTA)
  static const Color primaryContainer = Color(0xFFF2808F); // Prominent container accent
  static const Color secondary = Color(0xFF7B5459);        // Muted Plum
  static const Color softDustyBlush = Color(0xFFEEBCC2);   // Dusty Blush
  static const Color warmNeutralSand = Color(0xFFE8D6D0);  // Warm Sand
  static const Color powderBackground = Color(0xFFF9E9EF); // Soft Powder Global Background
  static const Color surface = Color(0xFFFFF8F9);          // Tinted Surface
  static const Color whiteSurface = Color(0xFFFFFFFF);     // Pure White Card Surface
  static const Color mainText = Color(0xFF21191E);         // Deep Espresso Text
  static const Color secondaryText = Color(0xFF554243);    // Warm Muted Gray
  static const Color outline = Color(0xFFDBC0C2);          // Outline / Subtle Border
  static const Color error = Color(0xFFBA1A1A);            // Warning & Critical Error

  // Healthcare & Status Semantics (Non-brand decorative)
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFE65100);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF0277BD);
  static const Color infoContainer = Color(0xFFE1F5FE);

  // Elevation & Shadows
  static const Color shadowTint = Color(0x1A9E3E4E);      // Subtle pink-tinted shadow (10% opacity)
  static const Color cardShadow = Color(0x12554243);      // Soft warm card elevation
}
