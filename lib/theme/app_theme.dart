import 'package:flutter/material.dart';

// ─── All SafeSense Colors ───────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color softBlue   = Color(0xFFADD8E6);
  static const Color sageGreen  = Color(0xFF9CAF88);
  static const Color pastelTeal = Color(0xFF7DD3C0);
  static const Color lavender   = Color(0xFFE6E6FA);
  static const Color warmBeige  = Color(0xFFF5E6D3);
  static const Color cream      = Color(0xFFF5F5DC);
  static const Color darkGray   = Color(0xFF333333);
  static const Color dustyGray  = Color(0xFFB0B0B0);
}

// ─── App Theme ──────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: const ColorScheme.light(
        primary:    AppColors.sageGreen,
        secondary:  AppColors.softBlue,
        surface:    AppColors.cream,
      ),

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.softBlue),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
        ),
      ),

      // ── Text ────────────────────────────────────────────────────────────
      textTheme: const TextTheme(
        // used for "SafeSense" title (28pt bold)
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
        ),
        // used for screen headers (24pt bold)
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
        ),
        // used for section titles (18pt)
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
        ),
        // used for card titles (16pt)
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGray,
        ),
        // used for labels (14pt)
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.darkGray,
        ),
        // used for input hints / small text (12pt)
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.dustyGray,
        ),
      ),

      // ── Buttons ─────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sageGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ── Text Fields ─────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cream,
        constraints: const BoxConstraints(minHeight: 50),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.darkGray,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.darkGray,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.sageGreen,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.darkGray,
        ),
        hintStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.dustyGray,
        ),
      ),
    );
  }
}