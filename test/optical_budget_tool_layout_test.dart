import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/toolkit/screens/optical_budget_tool.dart';

void main() {
  testWidgets('the splice and connector dropdowns fit a phone width',
      (WidgetTester tester) async {
    // The overflow reported on a gphone16k emulator: two Expanded dropdowns
    // share a Row, and each renders a long label plus the dropdown arrow into
    // half the screen width.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const OpticalBudgetTool()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fusion Splices'), findsOneWidget);
    expect(tester.takeException(), isNull,
        reason: 'a RenderFlex overflow means the technician sees a striped '
            'error bar instead of the splice loss field');
  });
}
