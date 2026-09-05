import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';

/// A selected filter chip must read as a highlighted choice, not a dark
/// button. Material 3 falls back to `colorScheme.secondaryContainer` for the
/// selected fill, which this app's scheme left at near-black, so the chip
/// theme has to carry the brand tint explicitly.
void main() {
  Future<ChipThemeData> chipThemeOf(
      WidgetTester tester, ThemeData theme) async {
    late ChipThemeData data;
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: Builder(builder: (context) {
        data = ChipTheme.of(context);
        return const SizedBox();
      }),
    ));
    return data;
  }

  const selected = {WidgetState.selected};
  const rest = <WidgetState>{};

  testWidgets('light: selected chip is the brand tint, not the black secondary',
      (tester) async {
    final chips = await chipThemeOf(tester, AppTheme.lightTheme);
    expect(chips.selectedColor, AppTheme.primarySubtleBg);
    expect(chips.selectedColor, isNot(AppTheme.darkSlate));
    expect(chips.backgroundColor, AppTheme.fillLight,
        reason: 'unselected chips stay on the quiet fill');
    final ink = chips.labelStyle!.color as WidgetStateColor;
    expect(ink.resolve(selected), AppTheme.brandInk,
        reason: 'text on the tint must be an ink token, never a bright fill');
    expect(ink.resolve(rest), AppTheme.secondaryInk);
    final side = chips.side as WidgetStateBorderSide;
    expect(side.resolve(selected)!.color, AppTheme.primary,
        reason: 'the brand hairline is what marks the active filter outdoors');
  });

  testWidgets('dark: selected chip uses the dark brand tint and ink',
      (tester) async {
    final chips = await chipThemeOf(tester, AppTheme.darkTheme);
    expect(chips.selectedColor, AppTheme.primarySubtleBgDark);
    expect(chips.backgroundColor, AppTheme.darkInput);
    final ink = chips.labelStyle!.color as WidgetStateColor;
    expect(ink.resolve(selected), AppTheme.brandInkDark);
    expect(ink.resolve(rest), AppTheme.secondaryInkDark);
  });
}
