import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/core/widgets/app_search_field.dart';

void main() {
  Future<TextEditingController> pump(
      WidgetTester tester, ValueChanged<String> onChanged) async {
    final c = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: AppSearchField(
              controller: c,
              hintText: 'Search LCP, NAP, Barangay, City',
              onChanged: onChanged),
        ),
      ),
    ));
    return c;
  }

  testWidgets('is at least 52 tall with 16px text and a 22px search icon',
      (tester) async {
    await pump(tester, (_) {});
    expect(tester.getSize(find.byType(AppSearchField)).height,
        greaterThanOrEqualTo(52));
    final hint =
        tester.widget<Text>(find.text('Search LCP, NAP, Barangay, City'));
    expect(hint.style!.fontSize, 16);
    final icon = tester.widget<Icon>(find.byIcon(Icons.search_rounded));
    expect(icon.size, 22);
  });

  testWidgets(
      'the clear button appears when there is text, is 48dp, and clears',
      (tester) async {
    final calls = <String>[];
    final c = await pump(tester, calls.add);
    expect(find.byTooltip('Clear search'), findsNothing);

    await tester.enterText(find.byType(TextField), 'LCP 010');
    await tester.pump();
    expect(calls, ['LCP 010']);
    expect(find.byTooltip('Clear search'), findsOneWidget);
    expect(tester.getSize(find.byTooltip('Clear search')).height,
        greaterThanOrEqualTo(48));

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(c.text, isEmpty);
    expect(calls.last, '',
        reason: 'clearing must notify the owner so filters reset');
  });

  testWidgets('does not clip at 200% text scale', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: Scaffold(
            body: AppSearchField(
                controller: c, hintText: 'Search', onChanged: (_) {})),
      ),
    ));
    expect(tester.takeException(), isNull);
  });
}
