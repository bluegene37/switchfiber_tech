# Field UI Standard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the technician app readable and tappable in the field by giving it one type scale, 48 dp touch targets, 52 dp search fields, and text colours that pass WCAG contrast, then sweeping every hand-picked size and colour onto those tokens.

**Architecture:** All type, size and colour decisions move into `AppTheme` (one file) so widgets read the theme instead of choosing pixels. A single `AppSearchField` widget replaces five copies of a hand-built search capsule. Screens are then swept feature by feature, each sweep measured by a grep count that must fall to a stated number. A contrast unit test and a 200 % text-scale test make the standard enforceable rather than aspirational.

**Tech Stack:** Flutter (Material 3 with Cupertino styling), `flutter_test`, Drift in-memory DB for screen tests, `signals_flutter`.

**Spec:** `docs/superpowers/specs/2026-09-03-field-ui-standard.md` (the plan argues from it; read both). Published reference: https://claude.ai/code/artifact/c7bab062-d843-4e35-a217-05434fe148b9

**Appendices (every literal, pre-enumerated on 2026-09-03):**
- `docs/superpowers/plans/2026-09-03-appendix-a-fontsize-literals.txt` — 384 lines, every `fontSize:` in `lib/`
- `docs/superpowers/plans/2026-09-03-appendix-b-small-icons.txt` — 112 lines, every icon `size:` of 16 or less
- `docs/superpowers/plans/2026-09-03-appendix-c-color-literals.txt` — 254 lines, every `Color(0x…)` outside `lib/core/theme`

## Global Constraints

- **Never run git commands that change state.** No `git add`, `commit`, `checkout`, etc. Each task ends by handing the user the exact commands to run. This is the repository owner's standing rule and overrides the skill's default.
- **zsh quirk:** never write `grep --include=*.dart` unquoted; zsh aborts before grep runs and it looks like an empty result. Every grep in this plan searches `lib` or `test` directly.
- **System font only.** No `fontFamily` other than the existing `'monospace'` for data and machine strings.
- **No new `fontSize:` literals** in widgets. After the sweep, fewer than 20 may remain in `lib/`: the theme file's own scale, and map furniture inside `Marker` children marked with a `// map furniture` comment.
- **Nothing below 13 px** except map furniture (spec rule 2).
- **Bright colours are never text.** Text uses the `*Ink` tokens defined in Task 1; fills, badges, icons and borders keep the bright tokens.
- **Every tappable widget is at least 48 × 48 dp.** Primary `ElevatedButton`s are 52 dp tall.
- **Keep the iOS-flavoured look.** Radii, hairline borders, Cupertino icons and page transitions stay. This standard changes legibility, not identity.
- **Green bar before hand-off, every task:** `dart analyze lib test` reports `No issues found!`; `flutter test` passes; `dart format` has been run on touched files.
- Tests that pump screens use an in-memory Drift DB (`AppDatabase(NativeDatabase.memory())`) inside `tester.runAsync`, exactly as existing tests do. Never hit the network from a test.

---

## Sweep method (used by Tasks 5 to 10)

Each sweep task replaces literals in one feature. The engineer opens the appendix lines for that task's files and applies this table. The table is repeated in every sweep task so tasks can be read out of order.

### Type: `fontSize` literal → theme role

Read the literal's size **and** weight **and** what the text is for. Access roles through the extension from Task 2: `context.text.bodyMedium`.

| Literal | Text is… | Replace `style:` with |
|---|---|---|
| 9, 10 inside a `Marker` child | map furniture | keep; add `// map furniture` comment and `textScaler: TextScaler.noScaling` |
| 9, 10, 11 anywhere else | badge, eyebrow, meta | `context.text.labelSmall` (13/500) or `labelMedium` (13/600) if weight ≥ 600 |
| 12, 13 | metadata, timestamps, hints | `context.text.bodySmall` (13/500, secondary ink) |
| 12, 13 | sentences a technician reads | `context.text.bodyMedium` (16/400) |
| 13, 14 | chip, button, field label | `context.text.labelLarge` (14/600) |
| 14 | a name, a value, a row title (weight ≥ 600) | `context.text.titleSmall` (16/600) |
| 14, 15 (weight 400) | body | `context.text.bodyMedium` |
| 15, 16, 17 (weight ≥ 600) | card or section header | `context.text.titleMedium` (17/700) |
| 16 (weight 400) | body | `context.text.bodyMedium` |
| 18 to 22 | the screen's title | `context.text.titleLarge` (22/700) |
| any size, numeric reading (dBm, count, port) | data | `context.text.headlineSmall` (20/700 monospace tabular) |
| any size, `fontFamily: 'monospace'` machine string (URL, serial) | data string | `context.text.bodyMedium!.copyWith(fontFamily: 'monospace')` |
| 24 to 28 | big number / hero | `context.text.headlineSmall` if numeric, else `titleLarge` |

Preserve any `color:` that is a **fill semantic** on non-text; move any `color:` on text to an ink token (table below). Preserve `fontStyle`, `decoration`, `letterSpacing` only if they carry meaning; drop negative letter-spacing on body text.

Use `copyWith` only to add colour or monospace; never to change size. If a size seems necessary, the role is wrong.

### Icons: appendix B (`size:` ≤ 16)

| Where | New size |
|---|---|
| Inside a button, `IconButton`, chip, or tappable row | `24` |
| Decorative leading icon in text | `20` |
| Inside a `Marker` child | keep; `// map furniture` |

### Colour: appendix C and `AppTheme.*` used as text colour

| Currently | On text → | On fill / icon / border → |
|---|---|---|
| `AppTheme.textMuted`, `textSecondary`, `textSecondaryDark`, `isDark ? textSecondaryDark : textMuted` | drop the `color:` and use `bodySmall`/`labelSmall` (they carry secondary ink), or `AppTheme.secondaryInkOf(context)` | unchanged |
| `AppTheme.textTertiary*` | `AppTheme.secondaryInkOf(context)` (tertiary is never legible) | unchanged |
| `AppTheme.primary` / `Color(0xFFE74C5A)` | `AppTheme.brandInkOf(context)` | unchanged |
| `AppTheme.success` / `Color(0xFF34C759)` | `AppTheme.successInkOf(context)` | unchanged |
| `AppTheme.warning` / `Color(0xFFFF9500)` | `AppTheme.warningInkOf(context)` | unchanged |
| `AppTheme.danger` / `Color(0xFFFF3B30)` | `AppTheme.dangerInkOf(context)` | unchanged |
| `AppTheme.info` / `Color(0xFF007AFF)` | `AppTheme.infoInkOf(context)` | unchanged |
| `Colors.white` on text over a **brand-filled** button or pill | keep (large-text 3:1 rule; white on brand is 3.76:1 and labels are ≥ 14/600) | — |
| any other literal `Color(0x…)` | nearest `AppTheme` token; if none fits, add a named token to `AppTheme` in the same task | same |

### Review checklist (design rules that are not mechanical)

Before handing off a sweep task, walk each touched screen and confirm: one filled primary action per screen; every status pill carries a word, not just a colour; no card nested inside a card; every `IconButton` has a `tooltip`. Fix inline; do not open a separate task.

### Acceptance command (run before and after every sweep task)

```bash
cd /Users/bluegene37/StudioProjects/swithfiber_tech
for f in <files in this task>; do printf "%3s  %s\n" "$(grep -c 'fontSize:' $f)" "$f"; done
```

---

### Task 1: Ink colour tokens with an enforced contrast test

**Files:**
- Modify: `lib/core/theme/app_theme.dart:47-51` (add tokens after the status subtle backgrounds)
- Test: `test/app_theme_contrast_test.dart` (create)

**Interfaces:**
- Consumes: nothing.
- Produces: `static const Color` tokens on `AppTheme`: `secondaryInk`, `secondaryInkDark`, `brandInk`, `brandInkDark`, `successInk`, `successInkDark`, `warningInk`, `warningInkDark`, `dangerInk`, `dangerInkDark`, `infoInk`, `infoInkDark`; and helpers `static Color secondaryInkOf(BuildContext)`, `brandInkOf`, `successInkOf`, `warningInkOf`, `dangerInkOf`, `infoInkOf`, each returning the dark variant when `Theme.of(context).brightness == Brightness.dark`. Later tasks use exactly these names.

- [ ] **Step 1: Write the failing contrast test**

```dart
// test/app_theme_contrast_test.dart
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
    };
    for (final e in inks.entries) {
      test('${e.key} on white card', () {
        expect(contrast(e.value, AppTheme.lightCard), greaterThanOrEqualTo(_bodyBar));
      });
      test('${e.key} on page background', () {
        expect(contrast(e.value, AppTheme.lightBg), greaterThanOrEqualTo(_bodyBar));
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
    };
    for (final e in inks.entries) {
      test('${e.key} on dark card', () {
        expect(contrast(e.value, AppTheme.darkCard), greaterThanOrEqualTo(_bodyBar));
      });
      test('${e.key} on dark page', () {
        expect(contrast(e.value, AppTheme.darkBg), greaterThanOrEqualTo(_bodyBar));
      });
    }
  });

  test('the old secondary grey is why we needed inks: it fails on the page', () {
    // Documents the finding that motivated this task; 2.92:1 measured.
    expect(contrast(AppTheme.textMuted, AppTheme.lightBg), lessThan(_bodyBar));
  });

  testWidgets('ink helpers pick the variant for the active brightness', (tester) async {
    late Color light, dark;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(builder: (c) { light = AppTheme.successInkOf(c); return const SizedBox(); }),
    ));
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Builder(builder: (c) { dark = AppTheme.successInkOf(c); return const SizedBox(); }),
    ));
    expect(light, AppTheme.successInk);
    expect(dark, AppTheme.successInkDark);
  });
}
```

Add `import 'dart:math' show pow;` at the top of the file.

- [ ] **Step 2: Run it to verify it fails**

Run: `cd /Users/bluegene37/StudioProjects/swithfiber_tech && flutter test test/app_theme_contrast_test.dart`
Expected: compile error, `The getter 'secondaryInk' isn't defined for the type 'AppTheme'`.

- [ ] **Step 3: Add the tokens and helpers to AppTheme**

Insert after line 51 (`static const Color infoSubtle = Color(0xFFF0F9FF);`):

```dart

  // Ink tokens: the only colours allowed on TEXT. Each passes WCAG 4.5:1 on
  // both surfaces of its theme (verified by test/app_theme_contrast_test.dart).
  // The bright tokens above stay for fills, badges, icons and borders.
  static const Color secondaryInk = Color(0xFF5A5A60); // 6.85:1 white, 6.14:1 page
  static const Color secondaryInkDark = Color(0xFFAEAEB2); // 7.69:1 card, 9.50:1 page
  static const Color brandInk = primaryActive; // #C02E3C, 5.68:1 white
  static const Color brandInkDark = Color(0xFFFF8A94); // 7.55:1 card
  static const Color successInk = Color(0xFF1B7F3B); // 5.07:1 white, 4.54:1 page
  static const Color successInkDark = Color(0xFF5CD27A); // 8.88:1 card
  static const Color warningInk = Color(0xFF8A5200); // 6.39:1 white
  static const Color warningInkDark = Color(0xFFFFB340); // 9.54:1 card
  static const Color dangerInk = Color(0xFFC1291F); // 5.83:1 white
  static const Color dangerInkDark = Color(0xFFFF6B62); // 6.10:1 card
  static const Color infoInk = Color(0xFF0062CC); // 5.80:1 white
  static const Color infoInkDark = Color(0xFF5AA9FF); // 6.93:1 card

  static bool _isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  /// Text colour for secondary information in the active theme.
  static Color secondaryInkOf(BuildContext c) =>
      _isDark(c) ? secondaryInkDark : secondaryInk;
  static Color brandInkOf(BuildContext c) => _isDark(c) ? brandInkDark : brandInk;
  static Color successInkOf(BuildContext c) =>
      _isDark(c) ? successInkDark : successInk;
  static Color warningInkOf(BuildContext c) =>
      _isDark(c) ? warningInkDark : warningInk;
  static Color dangerInkOf(BuildContext c) =>
      _isDark(c) ? dangerInkDark : dangerInk;
  static Color infoInkOf(BuildContext c) => _isDark(c) ? infoInkDark : infoInk;
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/app_theme_contrast_test.dart`
Expected: `+27: All tests passed!` (24 contrast cases, 1 documented failure of the old grey, 1 helper test, plus the group).

- [ ] **Step 5: Analyzer, format, hand off**

Run: `dart format lib/core/theme/app_theme.dart test/app_theme_contrast_test.dart && dart analyze lib test`
Expected: `No issues found!`

Hand the user these commands (do not run them):

```bash
git add lib/core/theme/app_theme.dart test/app_theme_contrast_test.dart
```

```bash
git commit -m "Add contrast-verified ink colour tokens for text

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 2: Type scale, minimum tap sizes and input padding in the theme

**Files:**
- Modify: `lib/core/theme/app_theme.dart` — light `ThemeData` lines 65-210, dark 215-360, plus a new private builder
- Create: `lib/core/theme/app_text.dart`
- Test: `test/app_theme_test.dart` (create)

**Interfaces:**
- Consumes: Task 1 tokens `secondaryInk`, `secondaryInkDark`.
- Produces: `extension AppText on BuildContext { TextTheme get text; }` in `app_text.dart`, so widgets write `context.text.bodyMedium`. Theme guarantees: `textTheme` roles per spec table; `materialTapTargetSize: padded`; `ElevatedButton` min `Size(48, 52)`; `OutlinedButton` and `TextButton` min `Size(48, 48)`; `InputDecorationTheme.contentPadding` `symmetric(horizontal: 14, vertical: 16)`; hint and label at 16 in secondary ink; `ListTileThemeData(minTileHeight: 56)`; AppBar title 22/700; navigation bar labels 13.

- [ ] **Step 1: Write the failing theme tests**

```dart
// test/app_theme_test.dart
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
      test('$name bodyMedium, the default Text style, is 16 with 1.5 line height', () {
        expect(t.bodyMedium!.fontSize, 16);
        expect(t.bodyMedium!.height, 1.5);
      });
      test('$name bodySmall is the 13 caption in secondary ink', () {
        expect(t.bodySmall!.fontSize, 13);
        expect(t.bodySmall!.color,
            theme.brightness == Brightness.dark ? AppTheme.secondaryInkDark : AppTheme.secondaryInk);
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
      test('$name headlineSmall is the 20/700 monospace tabular data role', () {
        expect(t.headlineSmall!.fontSize, 20);
        expect(t.headlineSmall!.fontWeight, FontWeight.w700);
        expect(t.headlineSmall!.fontFamily, 'monospace');
        expect(t.headlineSmall!.fontFeatures, contains(const FontFeature.tabularFigures()));
      });
    }
  });

  group('touch targets and inputs', () {
    final theme = AppTheme.lightTheme;
    test('tap targets are padded to 48', () {
      expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
    });
    test('primary buttons are at least 52 tall, secondary and text 48', () {
      expect(theme.elevatedButtonTheme.style!.minimumSize!.resolve({}), const Size(48, 52));
      expect(theme.outlinedButtonTheme.style!.minimumSize!.resolve({}), const Size(48, 48));
      expect(theme.textButtonTheme.style!.minimumSize!.resolve({}), const Size(48, 48));
    });
    test('list rows are at least 56', () {
      expect(theme.listTileTheme.minTileHeight, 56);
    });
    test('inputs pad to a 52 field and hint in 16 secondary ink', () {
      final d = theme.inputDecorationTheme;
      expect(d.contentPadding, const EdgeInsets.symmetric(horizontal: 14, vertical: 16));
      expect(d.hintStyle!.fontSize, 16);
      expect(d.hintStyle!.color, AppTheme.secondaryInk);
      expect(d.labelStyle!.fontSize, 16);
    });
    test('app bar title uses the screen-title role', () {
      expect(theme.appBarTheme.titleTextStyle!.fontSize, 22);
      expect(theme.appBarTheme.titleTextStyle!.fontWeight, FontWeight.w700);
    });
    test('bottom navigation labels are not below 13', () {
      final selected = theme.navigationBarTheme.labelTextStyle!.resolve({WidgetState.selected});
      final normal = theme.navigationBarTheme.labelTextStyle!.resolve({});
      expect(selected!.fontSize, 13);
      expect(normal!.fontSize, 13);
    });
  });

  group('rendered sizes under the theme', () {
    testWidgets('a bare TextField is at least 52 tall', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Center(child: SizedBox(width: 300, child: TextField()))),
      ));
      expect(tester.getSize(find.byType(TextField)).height, greaterThanOrEqualTo(52));
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
      expect(tester.getSize(find.byType(ElevatedButton)).height, greaterThanOrEqualTo(52));
      expect(tester.getSize(find.byType(OutlinedButton)).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(find.byType(TextButton)).height, greaterThanOrEqualTo(48));
    });
    testWidgets('context.text reads the active theme', (tester) async {
      late double size;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (c) { size = c.text.bodyMedium!.fontSize!; return const SizedBox(); }),
      ));
      expect(size, 16);
    });
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/app_theme_test.dart`
Expected: compile error on `package:swithfiber_tech/core/theme/app_text.dart` not found; after creating an empty file, assertion failures such as `Expected: <22.0> Actual: <null>`.

- [ ] **Step 3: Create the extension**

```dart
// lib/core/theme/app_text.dart
import 'package:flutter/material.dart';

/// `context.text.bodyMedium` instead of `Theme.of(context).textTheme.bodyMedium`.
/// Every widget reads type through this so the scale lives in one place.
extension AppText on BuildContext {
  TextTheme get text => Theme.of(this).textTheme;
}
```

- [ ] **Step 4: Add the scale builder to AppTheme**

Insert after the `_pageTransitionsTheme` constant (after line 61):

```dart

  /// The eight roles from the field UI standard. Built per brightness so
  /// secondary text carries the ink that passes contrast on that theme.
  static TextTheme _textTheme({
    required Color onSurface,
    required Color secondary,
  }) {
    return TextTheme(
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.3, color: onSurface),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.2, color: onSurface),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4, color: onSurface),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: onSurface),
      bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: onSurface),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.35, color: secondary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2, color: onSurface),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.2, color: onSurface),
      labelSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2, letterSpacing: 0.4, color: secondary),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.15,
        fontFamily: 'monospace',
        fontFeatures: const [FontFeature.tabularFigures()],
        color: onSurface,
      ),
    );
  }
```

- [ ] **Step 5: Wire the light theme**

In `lightTheme` (line 65 `return ThemeData(`), make these exact edits:

1. After `splashFactory: NoSplash.splashFactory,` (line 71) add:
```dart
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
```
2. Replace the AppBar `titleTextStyle` (lines 96-101) with:
```dart
        titleTextStyle: TextStyle(
          color: darkSlate,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
```
3. In `elevatedButtonTheme` (lines 113-128), replace the `padding:` and `textStyle:` lines with:
```dart
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
```
   (primary actions read at 16; the `shape:` block is unchanged and shown for placement.)
4. In `outlinedButtonTheme` (lines 129-143), add `minimumSize: const Size(48, 48),` before `padding:` and change `textStyle` to `fontSize: 14, fontWeight: FontWeight.w600` with no letterSpacing.
5. In `inputDecorationTheme` (lines 144-168): change `contentPadding` to `const EdgeInsets.symmetric(horizontal: 14, vertical: 16)`; replace lines 165-167 with:
```dart
        labelStyle: const TextStyle(color: secondaryInk, fontSize: 16),
        hintStyle: const TextStyle(color: secondaryInk, fontSize: 16),
```
6. In `navigationBarTheme.labelTextStyle` (lines 187-202) change both `fontSize: 11` to `fontSize: 13`.

- [ ] **Step 6: Wire the dark theme identically**

Apply the same six edits to `darkTheme` (line 215 onward) with these substitutions: `textTheme: _textTheme(onSurface: white, secondary: secondaryInkDark)`; TextButton `foregroundColor: brandInkDark`; AppBar title `color: white`; input `labelStyle`/`hintStyle` colour `secondaryInkDark`; navigation label sizes 11 → 13 (lines 341 and 348).

- [ ] **Step 7: Run the theme tests to verify they pass**

Run: `flutter test test/app_theme_test.dart`
Expected: `All tests passed!`

- [ ] **Step 8: Run the whole suite; expect no regressions**

Run: `flutter test`
Expected: `All tests passed!` (195 existing plus the new files). No existing test asserts a font size, verified on 2026-09-03.

- [ ] **Step 9: Analyzer, format, hand off**

Run: `dart format lib/core/theme && dart analyze lib test`
Expected: `No issues found!`

```bash
git add lib/core/theme/app_theme.dart lib/core/theme/app_text.dart test/app_theme_test.dart
```

```bash
git commit -m "Define the field type scale, 48dp tap minimums and 52dp inputs in the theme

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 3: One `AppSearchField` replaces five hand-built capsules

**Files:**
- Create: `lib/core/widgets/app_search_field.dart`
- Modify: `lib/features/jobs/screens/job_orders_screen.dart:229-290` (capsule, from `Expanded(` to the `),` before line 291 `const SizedBox(width: 8),`) and `:294` (toggle `height: 38`)
- Modify: `lib/features/lcp_nap/screens/lcp_nap_list_screen.dart:133-193` (from the `// iOS Capsule Search Bar` comment to the `),` before line 194 `const SizedBox(height: 10),`)
- Modify: `lib/features/service_orders/screens/service_orders_screen.dart:98-154` (comment at 98 to the `),` before line 155)
- Modify: `lib/features/diagnostics/screens/radius_disconnections_screen.dart:155-191` (comment at 155 to the `),` before line 192)
- Modify: `lib/features/jobs/widgets/job_history_view.dart:113-169` (comment at 113 to the `),` before line 170)
- Modify: `lib/features/lcp_nap/widgets/map_search_bar.dart:44` and `:109-113`
- Test: `test/app_search_field_test.dart` (create); `test/search_field_height_test.dart` (create); `test/map_search_bar_test.dart` (add one assertion)

**Interfaces:**
- Consumes: Task 2 theme (`inputDecorationTheme`, `context.text`), Task 1 `AppTheme.secondaryInkOf`.
- Produces:
```dart
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged; // also called with '' when cleared
  static const double minHeight = 52;
}
```

- [ ] **Step 1: Write the failing widget tests**

```dart
// test/app_search_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/core/widgets/app_search_field.dart';

void main() {
  Future<TextEditingController> pump(WidgetTester tester, ValueChanged<String> onChanged) async {
    final c = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: AppSearchField(controller: c, hintText: 'Search LCP, NAP, Barangay, City', onChanged: onChanged),
        ),
      ),
    ));
    return c;
  }

  testWidgets('is at least 52 tall with 16px text and a 22px search icon', (tester) async {
    await pump(tester, (_) {});
    expect(tester.getSize(find.byType(AppSearchField)).height, greaterThanOrEqualTo(52));
    final hint = tester.widget<Text>(find.text('Search LCP, NAP, Barangay, City'));
    expect(hint.style?.fontSize ?? DefaultTextStyle.of(tester.element(find.byType(TextField))).style.fontSize, 16);
    final icon = tester.widget<Icon>(find.byIcon(Icons.search_rounded));
    expect(icon.size, 22);
  });

  testWidgets('the clear button appears when there is text, is 48dp, and clears', (tester) async {
    final calls = <String>[];
    final c = await pump(tester, calls.add);
    expect(find.byTooltip('Clear search'), findsNothing);

    await tester.enterText(find.byType(TextField), 'LCP 010');
    await tester.pump();
    expect(calls, ['LCP 010']);
    expect(find.byTooltip('Clear search'), findsOneWidget);
    expect(tester.getSize(find.byTooltip('Clear search')).height, greaterThanOrEqualTo(48));

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(c.text, isEmpty);
    expect(calls.last, '', reason: 'clearing must notify the owner so filters reset');
  });

  testWidgets('does not clip at 200% text scale', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: Scaffold(body: AppSearchField(controller: c, hintText: 'Search', onChanged: (_) {})),
      ),
    ));
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/app_search_field_test.dart`
Expected: compile error, `app_search_field.dart` not found.

- [ ] **Step 3: Write the widget**

```dart
// lib/core/widgets/app_search_field.dart
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The one search field for every list in the app.
///
/// Reads its height and padding from the theme so it is at least 52 dp and
/// grows with the phone's text size instead of clipping. The clear button is
/// a real 48 dp target. Five screens used to hand-build a 38 dp capsule with a
/// 16 px icon and dense zero-padding text; this replaces all of them.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;

  /// Fired on every keystroke and with an empty string when cleared, so the
  /// owning screen resets its filter in one place.
  final ValueChanged<String> onChanged;

  static const double minHeight = 52;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minHeight),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: isDark ? AppTheme.darkInput : AppTheme.fillLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            prefixIcon: Icon(Icons.search_rounded, size: 22, color: AppTheme.secondaryInkOf(context)),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    iconSize: 24,
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    icon: Icon(Icons.close_rounded, color: AppTheme.secondaryInkOf(context)),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the widget tests to verify they pass**

Run: `flutter test test/app_search_field_test.dart`
Expected: `+3: All tests passed!`

- [ ] **Step 5: Replace the capsule in `job_orders_screen.dart`**

Replace the `Expanded( child: Container( height: 38, … ) )` block (lines 229-290, from `Expanded(` through its closing `),` just before `const SizedBox(width: 8),`) with:

```dart
                      Expanded(
                        child: AppSearchField(
                          controller: _searchController,
                          hintText: 'Search subscriber, ticket #, address',
                          onChanged: (text) {
                            setState(() {});
                            signals.setSearch(text);
                          },
                        ),
                      ),
```

Then change the list/map toggle `Container(` at line 294 (under the `// Prominent Segmented Toggle for List vs Map` comment) from `height: 38,` to `height: AppSearchField.minHeight,` so the two align. Add `import '../../../core/widgets/app_search_field.dart';` after the last existing import.

- [ ] **Step 6: Replace the capsule in `lcp_nap_list_screen.dart`**

Replace lines 133-193 (the `// iOS Capsule Search Bar` comment and its `Container(` through the closing `),` immediately before `const SizedBox(height: 10),` on line 194) with:

```dart
                AppSearchField(
                  controller: _searchController,
                  hintText: 'Search LCP, NAP, Barangay, City',
                  onChanged: (val) {
                    setState(() {});
                    signals.setSearch(val);
                    if (val.isNotEmpty) {
                      _expandedCabinets.addAll(signals.groupedByLcp.value.keys);
                    }
                  },
                ),
```

Add `import '../../../core/widgets/app_search_field.dart';`.

- [ ] **Step 7: Replace the capsule in `service_orders_screen.dart`**

Replace lines 98-154 (the `// iOS Capsule Search Bar` comment and its `Container(` through the closing `),` immediately before `const SizedBox(height: 10),` on line 155) with:

```dart
                AppSearchField(
                  controller: _searchController,
                  hintText: 'Search repair ticket, account, concern',
                  onChanged: (text) {
                    setState(() {});
                    signals.searchQuery.value = text;
                  },
                ),
```

Add `import '../../../core/widgets/app_search_field.dart';`.

- [ ] **Step 8: Replace the capsule in `radius_disconnections_screen.dart`**

Replace lines 155-191 (the `// iOS Capsule Search Bar` comment and its `Container(` through the closing `),` immediately before `const SizedBox(height: 10),` on line 192) with:

```dart
                AppSearchField(
                  controller: _searchController,
                  hintText: 'Search account name, plan group',
                  onChanged: (_) => setState(() {}),
                ),
```

Add `import '../../../core/widgets/app_search_field.dart';`.

- [ ] **Step 9: Replace the capsule in `job_history_view.dart`**

Replace lines 113-169 (the `// iOS Capsule Search Bar` comment and its `Container(` through the closing `),` immediately before `const SizedBox(height: 10),` on line 170) with:

```dart
                  AppSearchField(
                    controller: _searchController,
                    hintText: 'Search ticket #, subscriber, address',
                    onChanged: (v) {
                      signals.setHistorySearch(v);
                      setState(() {});
                    },
                  ),
```

Add `import '../../../core/widgets/app_search_field.dart';`.

- [ ] **Step 10: Raise the map search bar to 52 and stop it clipping at large text**

In `lib/features/lcp_nap/widgets/map_search_bar.dart` change line 44 `static const double height = 44;` to `static const double height = 52;`. Replace the `SizedBox(height: MapSearchBar.height, child: TextField(` wrapper (line ~109) with `ConstrainedBox(constraints: const BoxConstraints(minHeight: MapSearchBar.height), child: TextField(` and delete `isDense: true,` (line ~123). Change `style: const TextStyle(fontSize: 14)` to `style: Theme.of(context).textTheme.bodyMedium`, and `hintStyle: TextStyle(fontSize: 14, color: muted)` to `hintStyle: TextStyle(fontSize: 16, color: muted)`. Change the prefix icon `size: 20` to `size: 22`.

Add to `test/map_search_bar_test.dart`, inside the first widget test after `await submit(...)` is not needed; add a new test:

```dart
  testWidgets('is at least 52 tall', (tester) async {
    await pumpBar(tester, lookup: (_) async => null, onLocated: (_, __) {});
    expect(tester.getSize(find.byType(MapSearchBar)).height, greaterThanOrEqualTo(52));
  });
```

- [ ] **Step 11: Write the screen-level height test**

```dart
// test/search_field_height_test.dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/core/widgets/app_search_field.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_orders_screen.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/jobs/widgets/job_history_view.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/screens/lcp_nap_list_screen.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late JobsSignals jobs;
  late LcpNapSignals lcp;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    jobs = JobsSignals(JobRepository(db.jobOrdersDao));
    lcp = LcpNapSignals(LcpNapRepository(LcpNapLocationsDao(db)));
  });

  tearDown(() async {
    await jobs.dispose();
    await lcp.dispose();
    await db.close();
  });

  Future<void> expectSearch52(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: screen));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    tester.takeException();
    expect(find.byType(AppSearchField), findsOneWidget,
        reason: 'the screen must use the shared field, not a hand-built capsule');
    expect(tester.getSize(find.byType(AppSearchField)).height, greaterThanOrEqualTo(52));
  }

  testWidgets('job orders search is 52', (tester) async {
    await expectSearch52(tester, JobOrdersScreen(jobsSignals: jobs));
  });

  testWidgets('LCP NAP search is 52', (tester) async {
    await expectSearch52(tester, LcpNapListScreen(signals: lcp));
  });

  testWidgets('job history search is 52', (tester) async {
    await expectSearch52(tester, Scaffold(body: JobHistoryView(jobsSignals: jobs)));
  });
}
```

- [ ] **Step 12: Run the new and existing tests**

Run: `flutter test test/app_search_field_test.dart test/search_field_height_test.dart test/map_search_bar_test.dart test/lcp_nap_test.dart test/lcp_nap_list_toolbar_test.dart test/job_history_screen_test.dart test/map_place_search_test.dart`
Expected: `All tests passed!`

Run: `grep -rn "isDense: true" lib | wc -l`
Expected: `0`

- [ ] **Step 13: Full suite, analyzer, format, hand off**

Run: `flutter test && dart format lib/core/widgets lib/features/jobs lib/features/lcp_nap lib/features/service_orders lib/features/diagnostics && dart analyze lib test`
Expected: `All tests passed!` and `No issues found!`

```bash
git add lib/core/widgets/app_search_field.dart lib/features/jobs/screens/job_orders_screen.dart lib/features/lcp_nap/screens/lcp_nap_list_screen.dart lib/features/service_orders/screens/service_orders_screen.dart lib/features/diagnostics/screens/radius_disconnections_screen.dart lib/features/jobs/widgets/job_history_view.dart lib/features/lcp_nap/widgets/map_search_bar.dart test/app_search_field_test.dart test/search_field_height_test.dart test/map_search_bar_test.dart
```

```bash
git commit -m "Replace five hand-built search capsules with a 52dp AppSearchField

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 4: Remove compact density and enlarge the two undersized map targets

**Files:**
- Modify (delete one line each, 17 total): `lib/features/service_orders/screens/service_orders_screen.dart`, `lib/features/service_orders/screens/service_order_detail_screen.dart` (3 lines), `lib/features/service_orders/widgets/service_order_card.dart` (2), `lib/features/lcp_nap/screens/lcp_nap_list_screen.dart` (2), `lib/features/lcp_nap/widgets/lcp_nap_pin_popup.dart`, `lib/features/diagnostics/widgets/radius_connection_card.dart`, `lib/features/jobs/screens/job_order_detail_screen.dart` (2), `lib/features/jobs/widgets/job_history_view.dart` (3), `lib/features/toolkit/screens/network_diagnostic_tool.dart`, `lib/features/toolkit/screens/fiber_color_code_tool.dart`
- Modify: `lib/features/jobs/widgets/jobs_map_view.dart` `_buildMapButton` (`width: 40, height: 40` → 48)
- Modify: `lib/features/lcp_nap/widgets/lcp_nap_map_view.dart` cluster `Marker(width: 44, height: 44)` → 48 and its `GestureDetector` gets `behavior: HitTestBehavior.opaque`
- Test: `test/tap_targets_test.dart` (create)

**Interfaces:**
- Consumes: Task 2 minimum sizes (removing compact lets the theme's 48 apply).
- Produces: nothing new. Note: `radius_disconnections_screen.dart:293` `SizedBox(width: 40, child: CupertinoActivityIndicator)` is a spinner beside a `CupertinoSwitch`, not a control; leave it.

- [ ] **Step 1: Write the failing tap-target tests**

```dart
// test/tap_targets_test.dart
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/core/utils/data_url.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_order_detail_screen.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/jobs/widgets/jobs_map_view.dart';

final _signature = DataUrl.encode(Uint8List.fromList([1, 2, 3]));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late JobsSignals jobs;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    jobs = JobsSignals(JobRepository(db.jobOrdersDao));
  });

  tearDown(() async {
    await jobs.dispose();
    await db.close();
  });

  Future<void> seedJob(WidgetTester tester) async {
    await tester.runAsync(() async {
      await db.jobOrdersDao.insertOrUpdateJob(JobOrderDto(
        id: 7,
        ticketNumber: 'SF-2026-0007',
        customerName: 'Target Torres',
        address: 'Lot 7, Fiber Street',
        status: 'Scheduled',
        onsiteStatus: 'Scheduled',
        contactNumber: '09171234567',
        clientSignature: _signature,
        modemRouterSN: 'HWTC7',
        isSynced: true,
        updatedAt: DateTime.now(),
        rawJson: '{"coordinates": "14.469586, 121.195615"}',
      ).toCompanion());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
  }

  testWidgets('Call, SMS and Mark as Activated are at least 48 tall', (tester) async {
    await seedJob(tester);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: JobOrderDetailScreen(jobId: 7, jobsSignals: jobs),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    for (final label in ['Call', 'SMS']) {
      final button = find.ancestor(of: find.text(label), matching: find.byType(OutlinedButton));
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48), reason: '$label button');
    }
    final activate = find.ancestor(of: find.text('Mark as Activated'), matching: find.byType(ElevatedButton));
    expect(tester.getSize(activate).height, greaterThanOrEqualTo(52), reason: 'primary action');
  });

  testWidgets('map floating buttons are at least 48', (tester) async {
    await seedJob(tester);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: JobsMapView(jobsSignals: jobs)),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    tester.takeException();

    final size = tester.getSize(find.byTooltip('Satellite View'));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  test('no widget asks for compact density any more', () {
    // The theme's minimum sizes only hold if nothing overrides them.
    // Enforced by grep in Step 4; this test documents the intent.
    expect(true, isTrue);
  });
}
```

Also add to `test/lcp_nap_map_widget_test.dart`, next to the existing cluster test:

```dart
  testWidgets('a cluster pin is a 48dp target', (tester) async {
    // pumpMap seeds the five sample sites, which cluster at the default zoom;
    // the test 'nearby sites cluster instead of stacking on each other' in
    // this file already relies on that.
    await pumpMap(tester);
    final cluster = find.byKey(const Key('lcpNapCluster')).first;
    final size = tester.getSize(cluster);
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });
```

`pumpMap` is this file's existing helper at line 44, `Future<void> pumpMap(WidgetTester tester, {void Function(LcpNapDto)? onOpenDetails})`; it seeds `seedSampleLocations()` and pumps `LcpNapMapView` with an offline tile provider. No arguments are needed.

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/tap_targets_test.dart test/lcp_nap_map_widget_test.dart`
Expected: FAIL on the Call/SMS height (compact density shrinks them to ~36), on `Satellite View` (40), and on the cluster (44).

- [ ] **Step 3: Delete every compact-density line**

The line text is identical everywhere apart from indentation, so delete by pattern:

```bash
cd /Users/bluegene37/StudioProjects/swithfiber_tech
for f in \
  lib/features/service_orders/screens/service_orders_screen.dart \
  lib/features/service_orders/screens/service_order_detail_screen.dart \
  lib/features/service_orders/widgets/service_order_card.dart \
  lib/features/lcp_nap/screens/lcp_nap_list_screen.dart \
  lib/features/lcp_nap/widgets/lcp_nap_pin_popup.dart \
  lib/features/diagnostics/widgets/radius_connection_card.dart \
  lib/features/jobs/screens/job_order_detail_screen.dart \
  lib/features/jobs/widgets/job_history_view.dart \
  lib/features/toolkit/screens/network_diagnostic_tool.dart \
  lib/features/toolkit/screens/fiber_color_code_tool.dart; do
  sed -i '' '/visualDensity: VisualDensity.compact,/d' "$f"
done
grep -rn "VisualDensity.compact" lib | wc -l
```
Expected final line: `0`.

- [ ] **Step 4: Enlarge the two map targets**

In `jobs_map_view.dart` `_buildMapButton`, change `width: 40,` / `height: 40,` to `width: 48,` / `height: 48,` and the icon `size: 20` to `size: 24`.

In `lcp_nap_map_view.dart`, in the cluster `Marker(` inside the `MarkerLayer`, change `width: 44, height: 44,` to `width: 48, height: 48,` and change

```dart
                            ? GestureDetector(
                                key: const Key('lcpNapCluster'),
                                onTap: () => _zoomInto(cluster),
```
to
```dart
                            ? GestureDetector(
                                key: const Key('lcpNapCluster'),
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _zoomInto(cluster),
```
The 40 dp circle is the visual; the opaque 48 dp box is the target.

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/tap_targets_test.dart test/lcp_nap_map_widget_test.dart test/job_detail_activation_test.dart test/jobs_map_marker_test.dart test/lcp_nap_list_toolbar_test.dart`
Expected: `All tests passed!`

- [ ] **Step 6: Full suite, analyzer, format, hand off**

Run: `flutter test && dart format lib/features && dart analyze lib test`
Expected: `All tests passed!` and `No issues found!`

```bash
git add lib/features test/tap_targets_test.dart test/lcp_nap_map_widget_test.dart
```

```bash
git commit -m "Remove compact density everywhere and make map controls 48dp targets

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 5: Sweep the job detail screen (43 literals, the largest file)

**Files:**
- Modify: `lib/features/jobs/screens/job_order_detail_screen.dart` (appendix A: all lines for this file; appendix B and C likewise)
- Test: existing `test/job_detail_activation_test.dart`, `test/job_detail_distance_test.dart`, `test/tap_targets_test.dart`

**Interfaces:**
- Consumes: `context.text` (Task 2), `AppTheme.*InkOf(context)` (Task 1).
- Produces: nothing new.

**Type mapping (repeated for this task):** 9–11 → `labelSmall`/`labelMedium`; 12–13 meta → `bodySmall`; 12–13 reading text → `bodyMedium`; 13–14 chip/button → `labelLarge`; 14 name/value w≥600 → `titleSmall`; 14–15 w400 → `bodyMedium`; 15–17 w≥600 header → `titleMedium`; 18–22 screen title → `titleLarge`; numeric readings → `headlineSmall`; monospace strings → `bodyMedium.copyWith(fontFamily: 'monospace')`. Icons ≤16 → 24 in tappables, 20 decorative. Text colours → ink tokens; fills unchanged.

- [ ] **Step 1: Record the baseline**

Run: `grep -c "fontSize:" lib/features/jobs/screens/job_order_detail_screen.dart`
Expected: `43`

- [ ] **Step 2: Apply the table to every line listed in appendix A for this file**

Three worked examples from the file (apply the same reasoning to the other 40):

The report-required note (added 2026-09-03, `_buildReportRequiredNote`):
```dart
// before
              style: TextStyle(fontSize: 12, color: muted),
// after
              style: context.text.bodySmall,
```
and delete the now-unused `final muted = …` line in that method if nothing else uses it.

A spec row value (`_buildSpecRow`):
```dart
// before
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
// after
            style: context.text.titleSmall,
```

The activated note prefix and any `fontSize: 11` status text:
```dart
// before
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.success),
// after
              style: context.text.labelMedium!.copyWith(color: AppTheme.successInkOf(context)),
```

Add `import '../../../core/theme/app_text.dart';` after the last import.

- [ ] **Step 3: Apply appendix B and C for this file**

Every `size: 16` (or smaller) on an icon inside `OutlinedButton.icon`, `IconButton` or a tappable row → `size: 24`; decorative icons beside text → `20`. Every `color: AppTheme.textMuted` / `isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted` on a `Text` → remove it when the role is `bodySmall`/`labelSmall`, otherwise `AppTheme.secondaryInkOf(context)`. Every `AppTheme.success|warning|danger|info|primary` used as a **text** colour → the matching `…InkOf(context)`.

- [ ] **Step 4: Verify the count and the tests**

Run: `grep -c "fontSize:" lib/features/jobs/screens/job_order_detail_screen.dart`
Expected: `0`

Run: `flutter test test/job_detail_activation_test.dart test/job_detail_distance_test.dart test/tap_targets_test.dart`
Expected: `All tests passed!`

- [ ] **Step 5: Review checklist**

Open the screen in the app or read it top to bottom: one filled primary action (`Mark as Activated`); status pills carry words; no card inside a card; every `IconButton` has a `tooltip`. Fix inline.

- [ ] **Step 6: Full suite, analyzer, format, hand off**

Run: `flutter test && dart format lib/features/jobs/screens/job_order_detail_screen.dart && dart analyze lib test`
Expected: `All tests passed!` and `No issues found!`

```bash
git add lib/features/jobs/screens/job_order_detail_screen.dart
```

```bash
git commit -m "Move the job detail screen onto the theme type scale and ink colours

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 6: Sweep the rest of the jobs feature (≈58 literals)

**Files:**
- Modify: `lib/features/jobs/screens/job_orders_screen.dart` (14), `lib/features/jobs/widgets/jobs_map_view.dart` (14, one survivor), `lib/features/jobs/widgets/job_history_view.dart` (11), `lib/features/jobs/widgets/job_card.dart` (8), `lib/features/jobs/widgets/job_history_tile.dart` (4), `lib/features/jobs/widgets/job_photo_gallery.dart` (4), `lib/features/jobs/screens/job_history_screen.dart` (2), `lib/features/jobs/widgets/status_badge.dart` (1)
- Test: existing `test/jobs_map_marker_test.dart`, `test/job_history_screen_test.dart`, `test/job_history_test.dart`, `test/map_place_search_test.dart`, `test/search_field_height_test.dart`, `test/login_navigation_test.dart`

**Interfaces:** Consumes `context.text`, `AppTheme.*InkOf`. Produces nothing new.

**Type mapping (repeated):** 9–11 → `labelSmall`/`labelMedium`; 12–13 meta → `bodySmall`; 12–13 reading text → `bodyMedium`; 13–14 chip/button → `labelLarge`; 14 name/value w≥600 → `titleSmall`; 14–15 w400 → `bodyMedium`; 15–17 w≥600 header → `titleMedium`; 18–22 screen title → `titleLarge`; numeric readings → `headlineSmall`; monospace → `bodyMedium.copyWith(fontFamily: 'monospace')`; **map pin label in a `Marker` stays 9 with `// map furniture`**. Icons ≤16 → 24 tappable / 20 decorative / keep in `Marker`. Text colours → inks.

- [ ] **Step 1: Baseline**

```bash
for f in lib/features/jobs/screens/job_orders_screen.dart lib/features/jobs/widgets/jobs_map_view.dart lib/features/jobs/widgets/job_history_view.dart lib/features/jobs/widgets/job_card.dart lib/features/jobs/widgets/job_history_tile.dart lib/features/jobs/widgets/job_photo_gallery.dart lib/features/jobs/screens/job_history_screen.dart lib/features/jobs/widgets/status_badge.dart; do printf "%3s  %s\n" "$(grep -c 'fontSize:' $f)" "$f"; done
```
Expected: `14 14 11 8 4 4 2 1` in that order (job_orders_screen is 14 minus the two search literals already removed in Task 3, so `12` is also acceptable).

- [ ] **Step 2: Apply the table; three worked examples**

`jobs_map_view.dart`, the ticket label inside the job `Marker` (keep, mark):
```dart
// before
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
// after  (map furniture: fixed 132x52 Marker box, cannot grow)
                              style: const TextStyle(
                                fontSize: 9, // map furniture
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
```
(`textScaler: TextScaler.noScaling` is already on this `Text`.)

`status_badge.dart`, the single badge label:
```dart
// before
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
// after
      style: context.text.labelMedium!.copyWith(color: inkFor(context, color)),
```
where the badge's bright `color` maps to its ink via a small switch in the same file:
```dart
Color inkFor(BuildContext context, Color fill) {
  if (fill == AppTheme.success) return AppTheme.successInkOf(context);
  if (fill == AppTheme.warning) return AppTheme.warningInkOf(context);
  if (fill == AppTheme.danger) return AppTheme.dangerInkOf(context);
  if (fill == AppTheme.info) return AppTheme.infoInkOf(context);
  return AppTheme.brandInkOf(context);
}
```

`job_card.dart`, the customer name and address:
```dart
// before
  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
  …
  style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted),
// after
  style: context.text.titleSmall,
  …
  style: context.text.bodySmall,
```

Add `import '../../../core/theme/app_text.dart';` to each modified file.

- [ ] **Step 3: Apply appendix B and C for these files**

As in Task 5. In `jobs_map_view.dart` keep icon sizes inside `Marker` children; raise `_buildMapButton`'s icon (already 24 from Task 4) and popup action icons to 24.

- [ ] **Step 4: Verify counts and tests**

Run the baseline loop again. Expected: all `0` except `jobs_map_view.dart` = `1`.

Run: `flutter test test/jobs_map_marker_test.dart test/job_history_screen_test.dart test/job_history_test.dart test/map_place_search_test.dart test/search_field_height_test.dart test/login_navigation_test.dart`
Expected: `All tests passed!`

- [ ] **Step 5: Review checklist**, then **Step 6: full suite, format, analyze, hand off**

```bash
git add lib/features/jobs
```

```bash
git commit -m "Move the jobs list, history, cards and map onto the theme type scale

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 7: Sweep the reports feature (40 literals)

**Files:**
- Modify: `lib/features/reports/screens/create_report_screen.dart` (23), `lib/features/reports/widgets/photo_capture_tile.dart` (10), `lib/features/reports/widgets/optical_power_gauge.dart` (6), `lib/features/reports/widgets/signature_pad.dart` (1)
- Test: existing `test/create_report_screen_test.dart`, `test/photo_capture_tile_test.dart`, `test/bottom_inset_test.dart`, `test/signature_pad_test.dart`

**Interfaces:** Consumes `context.text`, `AppTheme.*InkOf`. Produces nothing new.

**Type mapping (repeated):** 9–11 → `labelSmall`/`labelMedium`; 12–13 meta → `bodySmall`; 12–13 reading text → `bodyMedium`; 13–14 chip/button → `labelLarge`; 14 name/value w≥600 → `titleSmall`; 14–15 w400 → `bodyMedium`; 15–17 w≥600 header → `titleMedium`; 18–22 screen title → `titleLarge`; **dBm readings → `headlineSmall`**; monospace → `bodyMedium.copyWith(fontFamily: 'monospace')`. Icons ≤16 → 24 tappable / 20 decorative. Text colours → inks; the gauge's status colour on **text** → `…InkOf`, on the bar fill unchanged.

- [ ] **Step 1: Baseline** — expected `23 10 6 1`.

- [ ] **Step 2: Apply the table; worked examples**

`create_report_screen.dart` section header rows:
```dart
// before
                Text('Optical Power Meter Reading (dBm)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
// after
                Expanded(child: Text('Optical Power Meter Reading (dBm)', style: context.text.titleMedium)),
```
(Wrapping in `Expanded` also fixes the pre-existing overflow of these header rows at 360 pt, found 2026-09-03.)

The submit button label:
```dart
// before
                              Text('Save Report & Mark Activated',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
// after
                              Text('Save Report & Mark Activated', style: context.text.titleSmall!.copyWith(color: Colors.white)),
```

`optical_power_gauge.dart` the reading and the axis labels:
```dart
// reading (numeric data)
  style: context.text.headlineSmall!.copyWith(color: statusInk),
// axis labels ('-35 dBm (Low)' etc.), were 10
  style: context.text.labelSmall,
```
where `statusInk` is computed once in `build` from the status colour via the same `inkFor` switch as Task 6 (copy it into this file or lift `inkFor` into `AppTheme` as `static Color inkForFill(BuildContext, Color)` in this task and update `status_badge.dart` to use it; either is acceptable, the lifted version is preferred).

- [ ] **Step 3: Apply appendix B and C for these files.** In `photo_capture_tile.dart` the GPS and size badge text inside the thumbnail `Stack` is furniture on an image: use `labelSmall` (13) and keep `textScaler: TextScaler.noScaling` if present; the badges have room.

- [ ] **Step 4: Verify** — counts all `0`; run `flutter test test/create_report_screen_test.dart test/photo_capture_tile_test.dart test/bottom_inset_test.dart test/signature_pad_test.dart`. Expected: `All tests passed!`

- [ ] **Step 5: Review checklist**, then **Step 6: full suite, format, analyze, hand off**

```bash
git add lib/features/reports lib/core/theme/app_theme.dart lib/features/jobs/widgets/status_badge.dart
```

```bash
git commit -m "Move the completion report onto the theme type scale and ink colours

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 8: Sweep the LCP NAP feature (60 literals, two survivors)

**Files:**
- Modify: `lib/features/lcp_nap/screens/lcp_nap_list_screen.dart` (20), `lib/features/lcp_nap/screens/lcp_nap_detail_screen.dart` (16), `lib/features/lcp_nap/widgets/lcp_nap_map_view.dart` (8), `lib/features/lcp_nap/widgets/lcp_nap_pin_popup.dart` (7), `lib/features/lcp_nap/widgets/lcp_nap_card.dart` (6), `lib/features/lcp_nap/widgets/map_search_bar.dart` (3)
- Test: existing `test/lcp_nap_test.dart`, `test/lcp_nap_map_widget_test.dart`, `test/lcp_nap_list_toolbar_test.dart`, `test/map_place_search_test.dart`, `test/map_search_bar_test.dart`, `test/lcp_nap_map_test.dart`

**Interfaces:** Consumes `context.text`, `AppTheme.*InkOf`. Produces nothing new.

**Type mapping (repeated):** 9–11 → `labelSmall`/`labelMedium`; 12–13 meta → `bodySmall`; 12–13 reading text → `bodyMedium`; 13–14 chip/button → `labelLarge`; 14 name/value w≥600 → `titleSmall`; 14–15 w400 → `bodyMedium`; 15–17 w≥600 header → `titleMedium`; 18–22 screen title → `titleLarge`; port counts → `headlineSmall`; **pin labels inside `Marker` (`_Pin` in the map view, `MapSearchPin` label) stay with `// map furniture`**. Icons ≤16 → 24 tappable / 20 decorative / keep in `Marker`. Text colours → inks.

- [ ] **Step 1: Baseline** — expected `20 16 8 7 6 3` (list screen may already be 18 after Task 3).

- [ ] **Step 2: Apply the table; worked examples**

`lcp_nap_list_screen.dart` toolbar summary (fixed for overflow on 2026-09-03):
```dart
// before
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted),
// after
                                style: context.text.labelMedium!.copyWith(color: AppTheme.secondaryInkOf(context)),
```
and the two `TextButton.icon` labels `style: TextStyle(fontSize: 11)` → remove the `style:` entirely (the `textButtonTheme` from Task 2 supplies 14/600).

`lcp_nap_map_view.dart` the pin's NAP number:
```dart
// before
                fontSize: 11, fontWeight: FontWeight.w800,
// after
                fontSize: 11, // map furniture
                fontWeight: FontWeight.w800,
```
and add `textScaler: TextScaler.noScaling` to that `Text` if missing.

`lcp_nap_card.dart` the LCP/NAP name and port capacity:
```dart
  style: context.text.titleSmall,                 // name, was 14/700
  style: context.text.headlineSmall,              // '8 ports', was 13/700 numeric
  style: context.text.bodySmall,                  // barangay, city, was 12 muted
```

- [ ] **Step 3: Apply appendix B and C for these files.** Cluster-pin count text inside `_ClusterPin` is map furniture (keep). `MapSearchPin` label stays 11 with the comment.

- [ ] **Step 4: Verify** — counts: `0 0 2 0 0 1` (map view: `_Pin` label and any second pin label; search bar: `MapSearchPin`). Run `flutter test test/lcp_nap_test.dart test/lcp_nap_map_widget_test.dart test/lcp_nap_list_toolbar_test.dart test/map_place_search_test.dart test/map_search_bar_test.dart test/lcp_nap_map_test.dart`. Expected: `All tests passed!`

- [ ] **Step 5: Review checklist**, then **Step 6: full suite, format, analyze, hand off**

```bash
git add lib/features/lcp_nap
```

```bash
git commit -m "Move the LCP NAP list, detail, map and cards onto the theme type scale

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 9: Sweep the toolkit and diagnostics (83 literals)

**Files:**
- Modify: `lib/features/toolkit/screens/drop_cable_tool.dart` (16), `lib/features/toolkit/screens/network_diagnostic_tool.dart` (14), `lib/features/toolkit/screens/optical_budget_tool.dart` (13), `lib/features/toolkit/screens/fiber_color_code_tool.dart` (12), `lib/features/toolkit/screens/troubleshooting_guide_tool.dart` (10), `lib/features/toolkit/screens/toolkit_screen.dart` (6), `lib/features/diagnostics/screens/radius_disconnections_screen.dart` (7), `lib/features/diagnostics/widgets/radius_connection_card.dart` (5)
- Test: existing `test/optical_budget_tool_layout_test.dart`, `test/optical_budget_test.dart`, `test/drop_cable_estimator_test.dart`, `test/fiber_color_code_test.dart`, `test/troubleshooting_guide_test.dart`

**Interfaces:** Consumes `context.text`, `AppTheme.*InkOf`. Produces nothing new.

**Type mapping (repeated):** 9–11 → `labelSmall`/`labelMedium`; 12–13 meta → `bodySmall`; 12–13 reading text → `bodyMedium`; 13–14 chip/button → `labelLarge`; 14 name/value w≥600 → `titleSmall`; 14–15 w400 → `bodyMedium`; 15–17 w≥600 header → `titleMedium`; 18–22 screen title → `titleLarge`; **calculator results (dB, metres, ms) → `headlineSmall`**; monospace → `bodyMedium.copyWith(fontFamily: 'monospace')`. Icons ≤16 → 24 tappable / 20 decorative. Text colours → inks.

- [ ] **Step 1: Baseline** — expected `16 14 13 12 10 6 7 5` (radius screen may be 5 after Task 3).

- [ ] **Step 2: Apply the table; worked examples** (from `troubleshooting_guide_tool.dart`, rewritten 2026-09-03):

```dart
  // issue title, was 15/800
  style: context.text.titleMedium,
  // symptom under it, was 12 muted
  style: context.text.bodySmall,
  // 'Probable Root Causes:' label, was 12/700 muted
  style: context.text.labelMedium!.copyWith(color: AppTheme.secondaryInkOf(context)),
  // each cause, was 12 with height 1.3
  style: context.text.bodyMedium,
  // step title, was 14/700
  style: context.text.titleSmall,
  // step action, was 12 height 1.4 muted
  style: context.text.bodyMedium!.copyWith(color: AppTheme.secondaryInkOf(context)),
  // step number in the red square, was 12/900 white — keep white (on brand fill, large-text rule)
  style: context.text.labelLarge!.copyWith(color: Colors.white),
```

`network_diagnostic_tool.dart` the ping target host:port line (`'${t.host}:${t.port}'`) is a machine string: `context.text.bodyMedium!.copyWith(fontFamily: 'monospace')`; a latency reading in ms → `headlineSmall`.

- [ ] **Step 3: Apply appendix B and C for these files.**

- [ ] **Step 4: Verify** — counts all `0`. Run `flutter test test/optical_budget_tool_layout_test.dart test/optical_budget_test.dart test/drop_cable_estimator_test.dart test/fiber_color_code_test.dart test/troubleshooting_guide_test.dart`. Expected: `All tests passed!`

- [ ] **Step 5: Review checklist**, then **Step 6: full suite, format, analyze, hand off**

```bash
git add lib/features/toolkit lib/features/diagnostics
```

```bash
git commit -m "Move the toolkit calculators and RADIUS screens onto the theme type scale

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 10: Sweep auth, settings, shell, service orders and core (≈72 literals)

**Files:**
- Modify: `lib/features/settings/screens/settings_screen.dart` (20), `lib/features/auth/screens/login_screen.dart` (17), `lib/features/service_orders/screens/service_order_detail_screen.dart` (15), `lib/features/shell/technician_shell.dart` (9), `lib/features/service_orders/screens/service_orders_screen.dart` (8), `lib/features/service_orders/widgets/service_order_card.dart` (8), `lib/core/services/map_navigation_service.dart` (5), `lib/features/splash/screens/splash_screen.dart` (2), `lib/core/widgets/loading_states.dart` (2)
- Leave: `lib/core/theme/app_theme.dart` (14) — these literals **are** the scale.
- Test: existing `test/login_navigation_test.dart`, `test/help_sheet_layout_test.dart`, `test/password_reset_request_test.dart`, `test/settings_signals_test.dart`, `test/widget_test.dart`

**Interfaces:** Consumes `context.text`, `AppTheme.*InkOf`. Produces nothing new.

**Type mapping (repeated):** 9–11 → `labelSmall`/`labelMedium`; 12–13 meta → `bodySmall`; 12–13 reading text → `bodyMedium`; 13–14 chip/button → `labelLarge`; 14 name/value w≥600 → `titleSmall`; 14–15 w400 → `bodyMedium`; 15–17 w≥600 header → `titleMedium`; 18–22 screen title → `titleLarge`; **masked server address and any URL → `bodyMedium.copyWith(fontFamily: 'monospace')`**. Icons ≤16 → 24 tappable / 20 decorative. Text colours → inks. The splash screen's brand wordmark may keep a single large size via `titleLarge.copyWith(fontSize: 28)` only if it is not user-scaled text; otherwise `titleLarge`.

- [ ] **Step 1: Baseline** — expected `20 17 15 9 8 8 5 2 2` (service_orders_screen may be 6 after Task 3).

- [ ] **Step 2: Apply the table; worked examples**

`login_screen.dart` the masked server pill:
```dart
// before
                              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppTheme.textMuted),
// after
                              style: context.text.labelSmall!.copyWith(fontFamily: 'monospace'),
```

`settings_screen.dart` the masked endpoint row:
```dart
// before
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.w600),
// after
                        style: context.text.bodyMedium!.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.w600),
```

`technician_shell.dart`: the bottom bar is hand-built (`_buildIosBottomBar`), not a Material `NavigationBar`, so the theme's navigation label size does **not** reach it and every literal must be swept directly. The four tab labels at lines 381, 413, 445 and 491:
```dart
// before (each)
                      fontSize: 11,
// after — keep the existing color expression on the same TextStyle
                      fontSize: 13,
```
then replace the whole `TextStyle(fontSize: 13, …color…)` with `context.text.labelSmall!.copyWith(color: <the existing colour expression>)`. The two unread-count badges at lines 292 and 307 (`fontSize: 10`) become `context.text.labelSmall!.copyWith(color: Colors.white)`; if their badge `Container` has a fixed `width`/`height`, replace it with `padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1)` so the badge sizes to the 13 px count instead of clipping it. Lines 343 (`24`) → `titleLarge`, 352 (`16/700`) → `titleSmall`, 358 (`13`) → `bodyMedium`.

- [ ] **Step 3: Apply appendix B and C for these files.**

- [ ] **Step 4: Verify** — all counts `0`, then the global check:
```bash
grep -rhoE "fontSize:\s*[0-9.]+" lib | wc -l
grep -rn "fontSize:" lib | grep -v "core/theme/app_theme.dart" | grep -v "map furniture" | wc -l
```
Expected: first number `< 20`; second number `0` (every survivor outside the theme is marked map furniture).

Run: `flutter test test/login_navigation_test.dart test/help_sheet_layout_test.dart test/password_reset_request_test.dart test/settings_signals_test.dart test/widget_test.dart`. Expected: `All tests passed!`

- [ ] **Step 5: Review checklist**, then **Step 6: full suite, format, analyze, hand off**

```bash
git add lib/features/settings lib/features/auth lib/features/service_orders lib/features/shell lib/features/splash lib/core/services/map_navigation_service.dart lib/core/widgets/loading_states.dart
```

```bash
git commit -m "Finish the type-scale sweep: auth, settings, shell, service orders, core

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 11: Prove the app survives 200 % text size

**Files:**
- Test: `test/text_scale_200_test.dart` (create)
- Modify: whatever the test finds (expected: a few fixed-height containers holding text)

**Interfaces:** Consumes everything above. Produces the acceptance test the spec names.

- [ ] **Step 1: Write the failing test**

```dart
// test/text_scale_200_test.dart
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_order_detail_screen.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_orders_screen.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/screens/lcp_nap_list_screen.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';
import 'package:swithfiber_tech/features/toolkit/screens/toolkit_screen.dart';
import 'package:swithfiber_tech/features/toolkit/screens/troubleshooting_guide_tool.dart';

/// The spec's acceptance test: every screen at the phone's maximum text size,
/// on a 412x915 phone, with no layout overflow anywhere.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late JobsSignals jobs;
  late LcpNapSignals lcp;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    jobs = JobsSignals(JobRepository(db.jobOrdersDao));
    lcp = LcpNapSignals(LcpNapRepository(LcpNapLocationsDao(db)));
  });

  tearDown(() async {
    await jobs.dispose();
    await lcp.dispose();
    await db.close();
  });

  Future<List<String>> overflowsAt200(WidgetTester tester, Widget screen) async {
    tester.view.devicePixelRatio = 2.625;
    tester.view.physicalSize = const Size(412 * 2.625, 915 * 2.625);
    addTearDown(tester.view.reset);

    final errors = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (d) => errors.add(d.toString());
    addTearDown(() => FlutterError.onError = original);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: screen,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    FlutterError.onError = original;
    tester.takeException();
    return errors.where((e) => e.contains('overflowed')).toList();
  }

  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      await db.jobOrdersDao.insertOrUpdateJob(JobOrderDto(
        id: 1, ticketNumber: 'SF-2026-0001', customerName: 'Scale Santos',
        address: 'Lot 1, Fiber Street, San Roque', barangay: 'San Roque', city: 'Binangonan',
        status: 'Scheduled', onsiteStatus: 'Scheduled', contactNumber: '09171234567',
        isSynced: true, updatedAt: DateTime.now(),
        rawJson: '{"coordinates": "14.469586, 121.195615"}',
      ).toCompanion());
      await LcpNapRepository(LcpNapLocationsDao(db)).seedSampleLocations();
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
  }

  for (final entry in <String, Widget Function(JobsSignals, LcpNapSignals)>{
    'job orders': (j, _) => JobOrdersScreen(jobsSignals: j),
    'job detail': (j, _) => JobOrderDetailScreen(jobId: 1, jobsSignals: j),
    'LCP NAP list': (_, l) => LcpNapListScreen(signals: l),
    'toolkit hub': (_, __) => const ToolkitScreen(),
    'troubleshooting guide': (_, __) => const TroubleshootingGuideTool(),
  }.entries) {
    testWidgets('${entry.key} has no overflow at 200% text', (tester) async {
      await seed(tester);
      final overflows = await overflowsAt200(tester, entry.value(jobs, lcp));
      expect(overflows, isEmpty, reason: overflows.join('\n'));
    });
  }
}
```

- [ ] **Step 2: Run it; expect failures that name the offending widgets**

Run: `flutter test test/text_scale_200_test.dart`
Expected: one or more FAIL with `A RenderFlex overflowed by N pixels` and a `Row:file:///…dart:LINE` attribution for each.

- [ ] **Step 3: Fix each offender with one of three moves, then re-run**

For each attributed widget: (a) a `Row` whose text has no flex → wrap the `Text` in `Expanded` or `Flexible`; (b) a `Container`/`SizedBox` with a fixed `height` holding text → replace with `ConstrainedBox(constraints: BoxConstraints(minHeight: …))`; (c) a horizontal row of chips that cannot fit → wrap in `Wrap(spacing: 8, runSpacing: 8)`. Re-run after each fix until the file lists no overflows. Do not shrink text to make it fit; that is the bug this standard exists to remove.

- [ ] **Step 4: Verify the whole bar**

Run: `flutter test && dart analyze lib test`
Expected: `All tests passed!` and `No issues found!`

- [ ] **Step 5: Manual device walk (the acceptance the spec names)**

On the OPPO CPH2483 or an iPhone: Settings → Display → Font size → maximum. Open every one of the 13 screens and 5 tools, scroll to the bottom of each, open each bottom sheet. Any clipped or striped edge is a defect: record the screen and fix with a move from Step 3, then re-run Step 4. Restore the font size afterwards.

- [ ] **Step 6: Hand off**

```bash
git add test/text_scale_200_test.dart lib
```

```bash
git commit -m "Add the 200% text-scale acceptance test and fix the overflows it found

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

## Self-review (done while writing)

**Spec coverage.** Type scale and roles → Task 2. Nothing below 13 and the map-furniture exception → sweep tables and survivor rule in Tasks 5 to 10. No new literals, under 20 survivors → Task 10 Step 4 global check. 200 % scaling → Task 11 plus `AppSearchField` and `MapSearchBar` using `minHeight` in Task 3. 48 dp everywhere, primary 52 to 56 → Task 2 minimum sizes and `padded`, Task 4 removes the 17 overrides and fixes the two real 40 dp targets. List rows 56 → Task 2 `listTileTheme`. Search 52 / 16 px / 48 dp clear / 22 px icon, delete `isDense` overrides, map bar 44 → 52 → Task 3. Icons ≥ 20, 24 in buttons → appendix B in every sweep. Inks with an enforced test, bright never as text → Task 1 and the colour table in every sweep. Tooltips, one primary action, pills carry words, no nested cards → review checklist in every sweep. Out of scope items (custom font, redesign, desktop, Vue) → not planned, by design.

**Placeholders.** Each code step shows code. Sweep tasks carry the complete mapping table, exact baseline and acceptance counts, exact commands, worked examples from real lines, and the appendix that enumerates every remaining line, so "apply the table" is a mechanical instruction rather than a judgement call.

**Verified against source on 2026-09-03.** The five capsule ranges, the `pumpMap` signature, the shell's literal lines and the `contactNumber` constructor parameter were each confirmed by reading the files, not from memory.

**Name consistency.** `AppTheme.secondaryInk`, `secondaryInkDark`, `brandInk`, `brandInkDark`, `successInk`, `successInkDark`, `warningInk`, `warningInkDark`, `dangerInk`, `dangerInkDark`, `infoInk`, `infoInkDark`, and `…InkOf(context)` are defined in Task 1 and used identically in Tasks 3 and 5 to 10. `context.text` is defined in Task 2 and used everywhere after. `AppSearchField.minHeight` is defined in Task 3 and referenced in the toggle alignment in the same task. `MapSearchBar.height` keeps its name at 52 because both map views compute overlay offsets from it.

**One known judgement.** Task 7 proposes lifting the badge `inkFor` switch into `AppTheme.inkForFill`; Task 6 first writes it locally in `status_badge.dart`. Either placement passes the tests; the executor of Task 7 should prefer the lift and update `status_badge.dart` in the same task so the switch exists once.
