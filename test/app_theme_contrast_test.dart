import 'dart:math' show pow;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';

/// WCAG 2.1 relative luminance and contrast ratio, so every ink token is
/// checked against the surfaces it is actually drawn on.
double _channel(int c) {
  final s = c / 255;
  return s <= 0.03928 ? s / 12.92 : pow((s + 0.055) / 1.055, 2.4).toDouble();
}

double _luminance(Color c) =>
    0.2126 * _channel((c.r * 255).round()) +
    0.7152 * _channel((c.g * 255).round()) +
    0.0722 * _channel((c.b * 255).round());

double contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

const _bodyBar = 4.5;

void main() {
  group('light ink tokens pass body-text contrast on both light surfaces', () {
    final inks = <String, Color>{
      'secondaryInk': AppTheme.secondaryInk,
      'brandInk': AppTheme.brandInk,
      'successInk': AppTheme.successInk,
      'warningInk': AppTheme.warningInk,
      'dangerInk': AppTheme.dangerInk,
      'infoInk': AppTheme.infoInk,
      'violetInk': AppTheme.violetInk,
    };
    for (final e in inks.entries) {
      test('${e.key} on white card', () {
        expect(contrast(e.value, AppTheme.lightCard),
            greaterThanOrEqualTo(_bodyBar));
      });
      test('${e.key} on page background', () {
        expect(contrast(e.value, AppTheme.lightBg),
            greaterThanOrEqualTo(_bodyBar));
      });
    }
  });

  group('dark ink tokens pass body-text contrast on both dark surfaces', () {
    final inks = <String, Color>{
      'secondaryInkDark': AppTheme.secondaryInkDark,
      'brandInkDark': AppTheme.brandInkDark,
      'successInkDark': AppTheme.successInkDark,
      'warningInkDark': AppTheme.warningInkDark,
      'dangerInkDark': AppTheme.dangerInkDark,
      'infoInkDark': AppTheme.infoInkDark,
      'violetInkDark': AppTheme.violetInkDark,
    };
    for (final e in inks.entries) {
      test('${e.key} on dark card', () {
        expect(contrast(e.value, AppTheme.darkCard),
            greaterThanOrEqualTo(_bodyBar));
      });
      test('${e.key} on dark page', () {
        expect(
            contrast(e.value, AppTheme.darkBg), greaterThanOrEqualTo(_bodyBar));
      });
    }
  });

  test('the old secondary grey is why we needed inks: it fails on the page',
      () {
    // Documents the finding that motivated this task; 2.92:1 measured.
    expect(contrast(AppTheme.textMuted, AppTheme.lightBg), lessThan(_bodyBar));
  });

  testWidgets('ink helpers pick the variant for the active brightness',
      (tester) async {
    // Test secondaryInk helpers
    late Color secondaryLight, secondaryDark;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(builder: (c) {
        secondaryLight = AppTheme.secondaryInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: Builder(builder: (c) {
        secondaryDark = AppTheme.secondaryInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    expect(secondaryLight, AppTheme.secondaryInk);
    expect(secondaryDark, AppTheme.secondaryInkDark);

    // Test brandInk helpers
    late Color brandLight, brandDark;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(builder: (c) {
        brandLight = AppTheme.brandInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: Builder(builder: (c) {
        brandDark = AppTheme.brandInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    expect(brandLight, AppTheme.brandInk);
    expect(brandDark, AppTheme.brandInkDark);

    // Test successInk helpers
    late Color successLight, successDark;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(builder: (c) {
        successLight = AppTheme.successInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: Builder(builder: (c) {
        successDark = AppTheme.successInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    expect(successLight, AppTheme.successInk);
    expect(successDark, AppTheme.successInkDark);

    // Test warningInk helpers
    late Color warningLight, warningDark;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(builder: (c) {
        warningLight = AppTheme.warningInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: Builder(builder: (c) {
        warningDark = AppTheme.warningInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    expect(warningLight, AppTheme.warningInk);
    expect(warningDark, AppTheme.warningInkDark);

    // Test dangerInk helpers
    late Color dangerLight, dangerDark;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(builder: (c) {
        dangerLight = AppTheme.dangerInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: Builder(builder: (c) {
        dangerDark = AppTheme.dangerInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    expect(dangerLight, AppTheme.dangerInk);
    expect(dangerDark, AppTheme.dangerInkDark);

    // Test infoInk helpers
    late Color infoLight, infoDark;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(builder: (c) {
        infoLight = AppTheme.infoInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: Builder(builder: (c) {
        infoDark = AppTheme.infoInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    expect(infoLight, AppTheme.infoInk);
    expect(infoDark, AppTheme.infoInkDark);

    // Test violetInk helpers
    late Color violetLight, violetDark;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(builder: (c) {
        violetLight = AppTheme.violetInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: Builder(builder: (c) {
        violetDark = AppTheme.violetInkOf(c);
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();
    expect(violetLight, AppTheme.violetInk);
    expect(violetDark, AppTheme.violetInkDark);
  });
}
