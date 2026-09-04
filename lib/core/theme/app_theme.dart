import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Design tokens and iOS/Apple HIG theme configurations for Switch Fiber Field Tech.
///
/// Strictly preserves the client's requested Red brand color palette while delivering
/// a native, refined iOS experience with Cupertino page transitions, hairline borders,
/// inset grouped card styling, and high-contrast light and dark surfaces.
class AppTheme {
  // Brand Color Palette (Modern Electric Fiber Red - High-Energy Telecom Standard)
  static const Color primary = Color(0xFFE02424); // Bold, punchy Electric Fiber Red
  static const Color primaryDark = Color(0xFFC81E1E);
  static const Color primaryActive = Color(0xFF9B1C1C);
  static const Color primarySubtleBg = Color(0xFFFEF2F2); // Soft luminous rose-white
  static const Color primarySubtleBorder = Color(0xFFFECACA);
  static const Color primarySubtleBgDark = Color(0xFF2D1214); // Deep crimson-tinted dark
  static const Color primarySubtleBorderDark = Color(0xFF5C1D24);

  // Light Surface & Neutral Tokens (Crisp Modern Slate Canvas)
  static const Color lightBg =
      Color(0xFFF8FAFC); // Slate 50 - clean, luminous, modern canvas
  static const Color lightCard = Color(0xFFFFFFFF); // Pure white card surface
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkSlate =
      Color(0xFF0F172A); // Slate 900 - crisp, modern deep ink
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textSecondary = textMuted;
  static const Color textTertiary = Color(0xFFCBD5E1); // Slate 300
  static const Color borderLight =
      Color(0xFFE2E8F0); // Slate 200 - precision 0.5px hairline
  static const Color fillLight =
      Color(0xFFF1F5F9); // Slate 100 - modern fill for search / tags

  // Dark Surface & Neutral Tokens (Midnight Obsidian Tech Palette)
  static const Color darkBg =
      Color(0xFF0B0F19); // Midnight Obsidian - rich, deep space canvas
  static const Color darkCard =
      Color(0xFF161F30); // Midnight Navy Slate - elevated card surface
  static const Color darkCardElevated =
      Color(0xFF243048); // Tertiary / Modal elevated card
  static const Color darkElevatedCard = darkCardElevated;
  static const Color darkInput =
      Color(0xFF1B2538); // Modern Slate dark input fill
  static const Color textSecondaryDark =
      Color(0xFF94A3B8); // Slate 400
  static const Color textTertiaryDark =
      Color(0xFF64748B); // Slate 500
  static const Color borderDark =
      Color(0xFF283548); // Precision dark hairline border
  static const Color fillDark = Color(0xFF202B3F);

  // Status Colors (Calibrated for High Legibility & Modern Vibrancy)
  static const Color success =
      Color(0xFF10B981); // Modern Emerald (Active / Pass)
  static const Color warning =
      Color(0xFFF59E0B); // Modern Amber (Marginal / Syncing)
  static const Color danger =
      Color(0xFFEF4444); // Modern Crimson Red (Failed / Faulty)
  static const Color info =
      Color(0xFF0284C7); // Modern Sky Blue (Pending / Info)

  // Status subtle backgrounds
  static const Color successSubtle = Color(0xFFECFDF5);
  static const Color warningSubtle = Color(0xFFFFFBEB);
  static const Color dangerSubtle = Color(0xFFFEF2F2);
  static const Color infoSubtle = Color(0xFFF0F9FF);

  // Ink tokens: the only colours allowed on TEXT. Each passes WCAG 4.5:1 on
  // both surfaces of its theme (verified by test/app_theme_contrast_test.dart).
  // The bright tokens above stay for fills, badges, icons and borders.
  static const Color secondaryInk =
      Color(0xFF475569); // Slate 600 - 7.58:1 white, 7.24:1 page
  static const Color secondaryInkDark =
      Color(0xFF94A3B8); // Slate 400 - 6.43:1 card, 7.47:1 page
  static const Color brandInk =
      Color(0xFFB91C1C); // Red 700 - 6.47:1 white, 6.18:1 page
  static const Color brandInkDark =
      Color(0xFFFF6B7A); // Radiant Coral Red - 6.00:1 card, 6.96:1 page
  static const Color successInk =
      Color(0xFF15803D); // Emerald 700 - 5.02:1 white, 4.79:1 page
  static const Color successInkDark =
      Color(0xFF4ADE80); // Emerald 400 - 9.47:1 card, 10.99:1 page
  static const Color warningInk =
      Color(0xFFB45309); // Amber 700 - 5.02:1 white, 4.80:1 page
  static const Color warningInkDark =
      Color(0xFFFBBF24); // Amber 400 - 9.88:1 card, 11.47:1 page
  static const Color dangerInk =
      Color(0xFFB91C1C); // Red 700 - 6.47:1 white, 6.18:1 page
  static const Color dangerInkDark =
      Color(0xFFF87171); // Red 400 - 5.96:1 card, 6.92:1 page
  static const Color infoInk =
      Color(0xFF0369A1); // Sky 700 - 5.93:1 white, 5.67:1 page
  static const Color infoInkDark =
      Color(0xFF38BDF8); // Sky 400 - 7.70:1 card, 8.94:1 page
  static const Color violetInk =
      Color(0xFF6D28D9); // 7.10:1 white, 6.79:1 page
  static const Color violetInkDark =
      Color(0xFFC084FC); // 6.24:1 card, 7.25:1 page

  static bool _isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  /// Text colour for secondary information in the active theme.
  static Color secondaryInkOf(BuildContext c) =>
      _isDark(c) ? secondaryInkDark : secondaryInk;
  static Color brandInkOf(BuildContext c) =>
      _isDark(c) ? brandInkDark : brandInk;
  static Color successInkOf(BuildContext c) =>
      _isDark(c) ? successInkDark : successInk;
  static Color warningInkOf(BuildContext c) =>
      _isDark(c) ? warningInkDark : warningInk;
  static Color dangerInkOf(BuildContext c) =>
      _isDark(c) ? dangerInkDark : dangerInk;
  static Color infoInkOf(BuildContext c) => _isDark(c) ? infoInkDark : infoInk;
  static Color violetInkOf(BuildContext c) =>
      _isDark(c) ? violetInkDark : violetInk;

  /// Standard iOS Page Transitions Theme
  static const PageTransitionsTheme _pageTransitionsTheme =
      PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    },
  );

  /// The eight roles from the field UI standard. Built per brightness so
  /// secondary text carries the ink that passes contrast on that theme.
  static TextTheme _textTheme({
    required Color onSurface,
    required Color secondary,
  }) {
    return TextTheme(
      titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.3,
          color: onSurface),
      titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.25,
          letterSpacing: -0.2,
          color: onSurface),
      titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: onSurface),
      bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: onSurface),
      bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: onSurface),
      bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.35,
          color: secondary),
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: onSurface),
      labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: onSurface),
      labelSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.2,
          letterSpacing: 0.4,
          color: secondary),
      headlineSmall: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.15,
        fontFamily: 'monospace',
        fontFeatures: const [FontFeature.tabularFigures()],
        color: onSurface,
      ),
    );
  }

  /// Light Theme (Apple Human Interface Guidelines styled)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: lightBg,
      pageTransitionsTheme: _pageTransitionsTheme,
      splashFactory:
          NoSplash.splashFactory, // iOS style clean tap without Android ripples
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: _textTheme(onSurface: darkSlate, secondary: secondaryInk),
      listTileTheme: const ListTileThemeData(minTileHeight: 56),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandInk,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
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
        onPrimaryContainer: brandInk,
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
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
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
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.2),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
        labelStyle: const TextStyle(color: secondaryInk, fontSize: 16),
        hintStyle: const TextStyle(color: secondaryInk, fontSize: 16),
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
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: _textTheme(onSurface: white, secondary: secondaryInkDark),
      listTileTheme: const ListTileThemeData(minTileHeight: 56),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandInkDark,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: primary,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        barBackgroundColor: Color(0xEB161F30),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: white,
        primaryContainer: primarySubtleBgDark,
        onPrimaryContainer: brandInkDark,
        secondary: Color(0xFFE2E8F0),
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
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
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
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandInkDark,
          side: const BorderSide(color: brandInkDark, width: 1.2),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInput,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
        labelStyle: const TextStyle(color: secondaryInkDark, fontSize: 16),
        hintStyle: const TextStyle(color: secondaryInkDark, fontSize: 16),
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
    );
  }
}
