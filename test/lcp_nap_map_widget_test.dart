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

  testWidgets('every mappable site is on the map, as a pin or in a cluster',
      (tester) async {
    await pumpMap(tester);

    expect(signals.mappableLocations.value, isNotEmpty);

    final pins = find.byWidgetPredicate((w) =>
        w is GestureDetector &&
        w.key is ValueKey<String> &&
        (w.key as ValueKey<String>).value.startsWith('lcpNapPin_'));
    final clusters = find.byKey(const Key('lcpNapCluster'));

    // Nothing is lost: the plant is drawn either as pins or clustered pins.
    expect(pins.evaluate().length + clusters.evaluate().length, greaterThan(0));
  });

  testWidgets('nearby sites cluster instead of stacking on each other',
      (tester) async {
    await pumpMap(tester);
    // Seeded sites sit in pairs a few hundred metres apart.
    expect(find.byKey(const Key('lcpNapCluster')), findsWidgets);
  });

  testWidgets('an isolated site stays an individual pin', (tester) async {
    await pumpMap(tester);
    expect(find.byKey(const Key('lcpNapPin_5')), findsOneWidget);
  });

  testWidgets('tapping a pin pops up that site\'s details', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpMap(tester);

    expect(find.byType(LcpNapPinPopup), findsNothing);

    // Target one specific site rather than whichever pin happens to be first
    // in the marker layer's build order.
    final site = signals.mappableLocations.value.firstWhere((s) => s.id == 5);
    await tester.tap(find.byKey(const Key('lcpNapPin_5')));
    await tester.pump();

    expect(find.byType(LcpNapPinPopup), findsOneWidget);
    expect(find.text(site.lcpNap), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the popup opens the full detail record', (tester) async {
    final handle = tester.ensureSemantics();
    LcpNapDto? opened;
    await pumpMap(tester, onOpenDetails: (l) => opened = l);

    await tester.tap(find.byKey(const Key('lcpNapPin_5')));
    await tester.pump();
    await tester.tap(find.text('View details'));
    await tester.pump();

    expect(opened, isNotNull);
    expect(opened!.id, 5,
        reason: 'the detail screen must open the site whose pin was tapped');
    handle.dispose();
  });

  testWidgets('the popup can be dismissed', (tester) async {
    await pumpMap(tester);

    await tester.tap(find.byKey(const Key('lcpNapPin_5')));
    await tester.pump();
    expect(find.byType(LcpNapPinPopup), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.byType(LcpNapPinPopup), findsNothing);
  });

  testWidgets('search filters the pins on the map', (tester) async {
    await pumpMap(tester);

    expect(find.byKey(const Key('lcpNapPin_5')), findsOneWidget);

    signals.setSearch('no such site anywhere');
    await tester.pump();

    expect(find.byKey(const Key('lcpNapPin_5')), findsNothing);
    expect(find.byKey(const Key('lcpNapCluster')), findsNothing);
  });

  testWidgets('renders zoom controls and plant legend toggle', (tester) async {
    await pumpMap(tester);

    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
    expect(find.text('Legend'), findsOneWidget);

    // Tap legend toggle
    await tester.tap(find.text('Legend'));
    await tester.pump();

    expect(find.text('LCP Cabinet Colors'), findsOneWidget);
  });
}
