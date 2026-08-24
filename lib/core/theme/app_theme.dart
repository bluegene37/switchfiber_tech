import 'package:flutter/material.dart';

/// Design tokens and Material 3 theme configurations for Switch Fiber Field Tech.
class AppTheme {
  // Brand Color Palette (Extracted from Switch Fiber Web Admin)
  static const Color primary = Color(0xFFE74C5A); // Warm Rose Red
  static const Color primaryDark = Color(0xFFD63A48);
  static const Color primaryActive = Color(0xFFC02E3C);
  static const Color primarySubtleBg = Color(0xFFFEF2F3);
  static const Color primarySubtleBorder = Color(0xFFFDCFD3);

  // Surface & Neutral Colors
  static const Color darkSlate = Color(0xFF212529);
  static const Color darkCard = Color(0xFF2B3035);
  static const Color darkInput = Color(0xFF25292E);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF6C757D);
  static const Color textSecondaryDark = Color(0xFFADBAC7);
  static const Color borderLight = Color(0xFFE9ECEF);
  static const Color borderDark = Color(0xFF383E45);

  // Status Colors
  static const Color success = Color(0xFF10B981); // Green (Active / Good / Pass)
  static const Color warning = Color(0xFFF59E0B); // Amber (In Progress / Marginal)
  static const Color danger = Color(0xFFEF4444);  // Red (Failed / Faulty / Out of spec)
  static const Color info = Color(0xFF0EA5E9);    // Sky Blue (Pending / Info)

  // Status subtle backgrounds
  static const Color successSubtle = Color(0xFFF0FDF4);
  static const Color warningSubtle = Color(0xFFFFFBEB);
  static const Color dangerSubtle = Color(0xFFFEF2F2);
  static const Color infoSubtle = Color(0xFFF0F9FF);

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: lightBg,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: white,
        primaryContainer: primarySubtleBg,
        onPrimaryContainer: primaryActive,
        secondary: darkSlate,
        onSecondary: white,
        surface: white,
        onSurface: darkSlate,
        error: danger,
        onError: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: darkSlate,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: darkSlate,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: darkSlate),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger),
        ),
        labelStyle: const TextStyle(color: textMuted, fontSize: 14),
        hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.7), fontSize: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: white,
        indicatorColor: primarySubtleBg,
        elevation: 2,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            color: textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary);
          }
          return const IconThemeData(color: textMuted);
        }),
      ),
    );
  }

  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkSlate,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: white,
        primaryContainer: Color(0xFF3F2327),
        onPrimaryContainer: Color(0xFFFF8591),
        secondary: Color(0xFFE9ECEF),
        onSecondary: darkSlate,
        surface: darkCard,
        onSurface: white,
        error: danger,
        onError: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
