import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Design tokens and iOS/Apple HIG theme configurations for Switch Fiber Field Tech.
///
/// Strictly preserves the client's requested Red brand color palette while delivering
/// a native, refined iOS experience with Cupertino page transitions, hairline borders,
/// inset grouped card styling, and high-contrast light and dark surfaces.
class AppTheme {
  // Brand Color Palette (Client's Desired Red Palette - Strictly Preserved)
  static const Color primary = Color(0xFFE74C5A); // Warm Rose Red
  static const Color primaryDark = Color(0xFFD63A48);
  static const Color primaryActive = Color(0xFFC02E3C);
  static const Color primarySubtleBg = Color(0xFFFEF2F3);
  static const Color primarySubtleBorder = Color(0xFFFDCFD3);
  static const Color primarySubtleBgDark = Color(0xFF2C1E20);
  static const Color primarySubtleBorderDark = Color(0xFF4D262A);

  // iOS Light Surface & Neutral Tokens
  static const Color lightBg = Color(0xFFF2F2F7); // iOS System Grouped Background
  static const Color lightCard = Color(0xFFFFFFFF); // Pure white card surface
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkSlate = Color(0xFF1C1C1E); // iOS Primary Label
  static const Color textMuted = Color(0xFF8E8E93); // iOS Secondary Label
  static const Color textSecondary = textMuted;
  static const Color textTertiary = Color(0xFFC7C7CC); // iOS Tertiary Label
  static const Color borderLight = Color(0xFFE5E5EA); // iOS System Separator (0.5px hairline)
  static const Color fillLight = Color(0xFFE5E5EA); // iOS Secondary System Fill

  // iOS Dark Surface & Neutral Tokens
  static const Color darkBg = Color(0xFF000000); // True iOS System Dark Background
  static const Color darkCard = Color(0xFF1C1C1E); // iOS Secondary System Grouped Card
  static const Color darkCardElevated = Color(0xFF2C2C2E); // iOS Tertiary / Modal Card
  static const Color darkElevatedCard = darkCardElevated;
  static const Color darkInput = Color(0xFF2C2C2E); // iOS System Input Fill
  static const Color textSecondaryDark = Color(0xFF8E8E93); // iOS Dark Secondary Label
  static const Color textTertiaryDark = Color(0xFF636366); // iOS Dark Tertiary Label
  static const Color borderDark = Color(0xFF38383A); // iOS Dark Separator (0.5px hairline)
  static const Color fillDark = Color(0xFF3A3A3C);

  // Status Colors (Calibrated for High Legibility)
  static const Color success = Color(0xFF34C759); // iOS System Green (Active / Pass)
  static const Color warning = Color(0xFFFF9500); // iOS System Orange (Marginal / Syncing)
  static const Color danger = Color(0xFFFF3B30); // iOS System Red (Failed / Faulty)
  static const Color info = Color(0xFF007AFF); // iOS System Blue (Pending / Info)

  // Status subtle backgrounds
  static const Color successSubtle = Color(0xFFF0FDF4);
  static const Color warningSubtle = Color(0xFFFFFBEB);
  static const Color dangerSubtle = Color(0xFFFEF2F2);
  static const Color infoSubtle = Color(0xFFF0F9FF);

  /// Standard iOS Page Transitions Theme
  static const PageTransitionsTheme _pageTransitionsTheme =
      PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    },
  );

  /// Light Theme (Apple Human Interface Guidelines styled)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: lightBg,
      pageTransitionsTheme: _pageTransitionsTheme,
      splashFactory: NoSplash.splashFactory, // iOS style clean tap without Android ripples
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: primary,
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBg,
        barBackgroundColor: Color(0xCCFFFFFF),
      ),
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: white,
        primaryContainer: primarySubtleBg,
        onPrimaryContainer: primaryActive,
        secondary: darkSlate,
        onSecondary: white,
        surface: lightCard,
        onSurface: darkSlate,
        error: danger,
        onError: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: darkSlate,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkSlate,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: primary),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderLight, width: 0.5),
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
            letterSpacing: -0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger, width: 1),
        ),
        labelStyle: const TextStyle(color: textMuted, fontSize: 14),
        hintStyle:
            TextStyle(color: textMuted.withValues(alpha: 0.8), fontSize: 14),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xF8FFFFFF),
        indicatorColor: primarySubtleBg,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            );
          }
          return const TextStyle(
            color: textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
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

  /// Dark Theme (Apple Human Interface Guidelines True Dark)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBg,
      pageTransitionsTheme: _pageTransitionsTheme,
      splashFactory: NoSplash.splashFactory,
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: primary,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        barBackgroundColor: Color(0xCC1C1C1E),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: white,
        primaryContainer: Color(0xFF3F2327),
        onPrimaryContainer: Color(0xFFFF8591),
        secondary: Color(0xFFE5E5EA),
        onSecondary: darkBg,
        surface: darkCard,
        onSurface: white,
        error: danger,
        onError: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: primary),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderDark, width: 0.5),
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
            letterSpacing: -0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF8591),
          side: const BorderSide(color: Color(0xFFFF8591), width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInput,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger, width: 1),
        ),
        labelStyle: const TextStyle(color: textSecondaryDark, fontSize: 14),
        hintStyle: TextStyle(
            color: textSecondaryDark.withValues(alpha: 0.8), fontSize: 14),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCardElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xF81C1C1E),
        indicatorColor: const Color(0xFF3F2327),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: Color(0xFFFF8591),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            );
          }
          return const TextStyle(
            color: textSecondaryDark,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFFFF8591));
          }
          return const IconThemeData(color: textSecondaryDark);
        }),
      ),
    );
  }
}
