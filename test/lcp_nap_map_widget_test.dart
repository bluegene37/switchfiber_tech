import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/features/lcp_nap/models/lcp_nap_model.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';
import 'package:swithfiber_tech/features/lcp_nap/widgets/lcp_nap_map_view.dart';
import 'package:swithfiber_tech/features/lcp_nap/widgets/lcp_nap_pin_popup.dart';

/// A 1x1 transparent PNG, so tests never touch the network for tiles.
final _blankTile = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
  'YPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

class _OfflineTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(Uint8List.fromList(_blankTile));
}

void main() {
  late AppDatabase db;
  late LcpNapRepository repository;
  late LcpNapSignals signals;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = LcpNapRepository(LcpNapLocationsDao(db));
    signals = LcpNapSignals(repository);
  });

  tearDown(() async {
    await signals.dispose();
    await db.close();
  });

  Future<void> pumpMap(
    WidgetTester tester, {
    void Function(LcpNapDto)? onOpenDetails,
  }) async {
    await tester.runAsync(() async {
      await repository.seedSampleLocations();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 700,
            child: LcpNapMapView(
              signals: signals,
              tileProvider: _OfflineTileProvider(),
              onOpenDetails: onOpenDetails,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('drops a pin for every mappable site', (tester) async {
    await pumpMap(tester);

    final expected = signals.mappableLocations.value.length;
    expect(expected, greaterThan(0));
    expect(find.byIcon(Icons.location_on_rounded), findsNWidgets(expected));
  });

  testWidgets('tapping a pin pops up that site\'s details', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpMap(tester);

    expect(find.byType(LcpNapPinPopup), findsNothing);

    // Target one specific site rather than whichever pin happens to be first
    // in the marker layer's build order.
    final site = signals.mappableLocations.value.last;
    await tester.tap(find.bySemanticsLabel('Site ${site.lcpNap}'));
    await tester.pump();

    expect(find.byType(LcpNapPinPopup), findsOneWidget);
    expect(find.text(site.lcpNap), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the popup opens the full detail record', (tester) async {
    final handle = tester.ensureSemantics();
    LcpNapDto? opened;
    await pumpMap(tester, onOpenDetails: (l) => opened = l);

    final site = signals.mappableLocations.value.last;
    await tester.tap(find.bySemanticsLabel('Site ${site.lcpNap}'));
    await tester.pump();
    await tester.tap(find.text('View full details'));
    await tester.pump();

    expect(opened, isNotNull);
    expect(opened!.id, site.id,
        reason: 'the detail screen must open the site whose pin was tapped');
    handle.dispose();
  });

  testWidgets('the popup can be dismissed', (tester) async {
    await pumpMap(tester);

    await tester.tap(find.byIcon(Icons.location_on_rounded).first);
    await tester.pump();
    expect(find.byType(LcpNapPinPopup), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.byType(LcpNapPinPopup), findsNothing);
  });

  testWidgets('search filters the pins on the map', (tester) async {
    await pumpMap(tester);

    final before = find.byIcon(Icons.location_on_rounded).evaluate().length;
    signals.setSearch('no such site anywhere');
    await tester.pump();

    final after = find.byIcon(Icons.location_on_rounded).evaluate().length;
    expect(after, 0);
    expect(before, greaterThan(0));
  });
}
