import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/lcp_nap/widgets/map_search_bar.dart';

void main() {
  group('biasedQuery', () {
    test('appends the country to a bare place name', () {
      expect(MapSearchBar.biasedQuery('SM Megamall'),
          'SM Megamall, Philippines');
    });

    test('trims and passes through a query that already names the country',
        () {
      expect(MapSearchBar.biasedQuery('  Pasig City Hall, Philippines '),
          'Pasig City Hall, Philippines');
      expect(MapSearchBar.biasedQuery('Maynila, PILIPINAS'),
          'Maynila, PILIPINAS');
    });
  });

  Future<void> pumpBar(
    WidgetTester tester, {
    required PlaceLookup lookup,
    required void Function(LatLng target, String query) onLocated,
  }) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: MapSearchBar(lookup: lookup, onLocated: onLocated),
        ),
      ),
    ));
  }

  Future<void> submit(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
  }

  testWidgets('a found place is handed back with the raw query',
      (tester) async {
    String? asked;
    LatLng? located;
    String? label;
    await pumpBar(
      tester,
      lookup: (q) async {
        asked = q;
        return const LatLng(14.585, 121.056);
      },
      onLocated: (t, q) {
        located = t;
        label = q;
      },
    );

    await submit(tester, 'SM Megamall');

    expect(asked, 'SM Megamall, Philippines',
        reason: 'the geocoder must be asked the country-biased query');
    expect(located, const LatLng(14.585, 121.056));
    expect(label, 'SM Megamall',
        reason: 'the pin label is what the technician typed, not the bias');
  });

  testWidgets('no match shows a message and hands nothing back',
      (tester) async {
    var located = false;
    await pumpBar(
      tester,
      lookup: (_) async => null,
      onLocated: (_, __) => located = true,
    );

    await submit(tester, 'Nowhere Street');

    expect(find.textContaining('No place found'), findsOneWidget);
    expect(located, isFalse);
  });

  testWidgets('a broken geocoder is explained rather than thrown',
      (tester) async {
    var located = false;
    await pumpBar(
      tester,
      lookup: (_) async => throw StateError('Service not available'),
      onLocated: (_, __) => located = true,
    );

    await submit(tester, 'Pasig');

    expect(find.textContaining('not available'), findsOneWidget);
    expect(located, isFalse);
    expect(tester.takeException(), isNull,
        reason: 'a geocoder failure must never crash the map');
  });

  testWidgets('an empty query is ignored', (tester) async {
    var asked = false;
    await pumpBar(
      tester,
      lookup: (_) async {
        asked = true;
        return null;
      },
      onLocated: (_, __) {},
    );

    await submit(tester, '   ');

    expect(asked, isFalse);
  });
}
