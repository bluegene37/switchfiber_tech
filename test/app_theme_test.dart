import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/theme/app_text.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';

void main() {
  group('type scale (spec table)', () {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      final t = theme.textTheme;
      final name = theme.brightness.name;
      test('$name titleLarge is the 22/700 screen title', () {
        expect(t.titleLarge!.fontSize, 22);
        expect(t.titleLarge!.fontWeight, FontWeight.w700);
      });
      test('$name titleMedium is the 17/700 section heading', () {
        expect(t.titleMedium!.fontSize, 17);
        expect(t.titleMedium!.fontWeight, FontWeight.w700);
      });
      test('$name titleSmall is 16/600 body strong', () {
        expect(t.titleSmall!.fontSize, 16);
        expect(t.titleSmall!.fontWeight, FontWeight.w600);
      });
      test(
          '$name bodyMedium, the default Text style, is 16 with 1.5 line height',
          () {
        expect(t.bodyMedium!.fontSize, 16);
        expect(t.bodyMedium!.height, 1.5);
      });
      test('$name bodySmall is the 13 caption in secondary ink', () {
        expect(t.bodySmall!.fontSize, 13);
        expect(
            t.bodySmall!.color,
            theme.brightness == Brightness.dark
                ? AppTheme.secondaryInkDark
                : AppTheme.secondaryInk);
      });
      test('$name labelLarge is 14/600 for buttons and chips', () {
        expect(t.labelLarge!.fontSize, 14);
        expect(t.labelLarge!.fontWeight, FontWeight.w600);
      });
      test('$name nothing in the scale is below 13', () {
        for (final s in [t.labelSmall, t.labelMedium, t.bodySmall]) {
          expect(s!.fontSize, greaterThanOrEqualTo(13));
        }
      });
      test('$name headlineSmall is the 26/700 monospace tabular data role', () {
        expect(t.headlineSmall!.fontSize, 26);
        expect(t.headlineSmall!.fontWeight, FontWeight.w700);
        expect(t.headlineSmall!.fontFamily, 'monospace');
        expect(t.headlineSmall!.fontFeatures,
            contains(const FontFeature.tabularFigures()));
      });
    }
  });

  group('touch targets and inputs', () {
    final theme = AppTheme.lightTheme;
    test('tap targets are padded to 48', () {
      expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
    });
    test('primary buttons are at least 52 tall, secondary and text 48', () {
      expect(theme.elevatedButtonTheme.style!.minimumSize!.resolve({}),
          const Size(48, 52));
      expect(theme.outlinedButtonTheme.style!.minimumSize!.resolve({}),
          const Size(48, 48));
      expect(theme.textButtonTheme.style!.minimumSize!.resolve({}),
          const Size(48, 48));
    });
    test('list rows are at least 56', () {
      expect(theme.listTileTheme.minTileHeight, 56);
    });
    test('inputs pad to a 52 field and hint in 16 secondary ink', () {
      final d = theme.inputDecorationTheme;
      expect(d.contentPadding,
          const EdgeInsets.symmetric(horizontal: 14, vertical: 16));
      expect(d.hintStyle!.fontSize, 16);
      expect(d.hintStyle!.color, AppTheme.secondaryInk);
      expect(d.labelStyle!.fontSize, 16);
    });
    test('app bar title uses the screen-title role', () {
      expect(theme.appBarTheme.titleTextStyle!.fontSize, 22);
      expect(theme.appBarTheme.titleTextStyle!.fontWeight, FontWeight.w700);
    });
    // The old "bottom navigation labels are not below 13" test asserted on
    // ThemeData.navigationBarTheme, but nothing in lib instantiates a
    // Material NavigationBar — the only bottom bar is the hand-built one in
    // technician_shell.dart. That dead config (and its now-false promise of
    // textMuted as a label colour) was deleted per the field-UI-standard
    // final fix round item 7; tap_targets_test.dart's pumped TechnicianShell
    // test now covers the real bottom bar's tap target size, and its labels
    // are asserted not to shrink below 13 by the type-scale tests above.
  });

  group('rendered sizes under the theme', () {
    testWidgets('a bare TextField is at least 52 tall', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
            body: Center(child: SizedBox(width: 300, child: TextField()))),
      ));
      expect(tester.getSize(find.byType(TextField)).height,
          greaterThanOrEqualTo(52));
    });
    testWidgets('buttons are at least 48 tall', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Column(children: [
            ElevatedButton(onPressed: () {}, child: const Text('Go')),
            OutlinedButton(onPressed: () {}, child: const Text('Go')),
            TextButton(onPressed: () {}, child: const Text('Go')),
          ]),
        ),
      ));
      expect(tester.getSize(find.byType(ElevatedButton)).height,
          greaterThanOrEqualTo(52));
      expect(tester.getSize(find.byType(OutlinedButton)).height,
          greaterThanOrEqualTo(48));
      expect(tester.getSize(find.byType(TextButton)).height,
          greaterThanOrEqualTo(48));
    });
    testWidgets('context.text reads the active theme', (tester) async {
      late double size;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (c) {
          size = c.text.bodyMedium!.fontSize!;
          return const SizedBox();
        }),
      ));
      expect(size, 16);
    });
  });
}
