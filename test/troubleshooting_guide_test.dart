import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/toolkit/models/field_troubleshooting_guide.dart';
import 'package:swithfiber_tech/features/toolkit/screens/troubleshooting_guide_tool.dart';

void main() {
  const redLos = 'Red LOS Light (Loss of Signal)';
  const highLoss = 'High Optical Attenuation (< -27.0 dBm)';
  const redLosStep = 'Measure OPM at NAP Box';
  const highLossStep = 'Clean Connector End-Faces';

  Future<void> pump(WidgetTester tester) async {
    // Tall enough that an open issue and the one after it are both built.
    // The list is lazy, so a default-height viewport would leave the second
    // issue's steps unbuilt and the finders silently empty.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 3000);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: const TroubleshootingGuideTool(),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('every issue is listed at once and there is no chip strip',
      (tester) async {
    await pump(tester);

    expect(find.byType(FilterChip), findsNothing,
        reason: 'the horizontal chip selector is what made this hard to use');
    for (final guide in TroubleshootingGuideItem.fieldGuides) {
      expect(find.text(guide.title), findsOneWidget,
          reason: 'every issue must be scannable without picking one first');
    }

    // Collapsed by default: no step is showing yet.
    expect(find.text(redLosStep), findsNothing);
    expect(find.text('Probable Root Causes:'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping an issue opens its steps in place and again closes it',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text(redLos));
    await tester.pumpAndSettle();

    expect(find.text('Probable Root Causes:'), findsOneWidget);
    expect(find.text(redLosStep), findsOneWidget,
        reason: 'the resolution steps must unfold under the issue');
    expect(find.text(highLossStep), findsNothing,
        reason: 'opening one issue must not open the others');

    await tester.tap(find.text(redLos));
    await tester.pumpAndSettle();

    expect(find.text(redLosStep), findsNothing,
        reason: 'a second tap must collapse the issue again');
    expect(tester.takeException(), isNull);
  });

  testWidgets('two issues can stay open together for comparison',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text(redLos));
    await tester.pumpAndSettle();
    await tester.tap(find.text(highLoss));
    await tester.pumpAndSettle();

    expect(find.text(redLosStep), findsOneWidget);
    expect(find.text(highLossStep), findsOneWidget,
        reason: 'opening a second issue must not close the first');
    expect(tester.takeException(), isNull);
  });
}
