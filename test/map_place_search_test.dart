import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/jobs/widgets/jobs_map_view.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';
import 'package:swithfiber_tech/features/lcp_nap/widgets/lcp_nap_map_view.dart';

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

/// Where the fake geocoder sends every query.
const _target = LatLng(14.5850, 121.0560);

Future<LatLng?> _fakeLookup(String _) async => _target;

LatLng _cameraCenter(WidgetTester tester) =>
    tester.widget<FlutterMap>(find.byType(FlutterMap)).mapController!.camera.center;

Future<void> _searchFor(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField), query);
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('plant map', () {
    late AppDatabase db;
    late LcpNapSignals signals;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      signals = LcpNapSignals(LcpNapRepository(LcpNapLocationsDao(db)));
    });

    tearDown(() async {
      await signals.dispose();
      await db.close();
    });

    testWidgets('a search drops a pin, flies there, and a map tap clears it',
        (tester) async {
      await tester.runAsync(() async {
        await LcpNapRepository(LcpNapLocationsDao(db)).seedSampleLocations();
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: LcpNapMapView(
            signals: signals,
            tileProvider: _OfflineTileProvider(),
            placeLookup: _fakeLookup,
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      const pin = Key('lcpNapSearchPin');
      expect(find.byKey(pin), findsNothing);
      expect(find.text('Search a place or address'), findsOneWidget,
          reason: 'the search bar must sit on the map');

      await _searchFor(tester, 'SM Megamall');

      expect(find.byKey(pin), findsOneWidget,
          reason: 'the searched place must be pinned');
      expect(find.text('SM Megamall'), findsWidgets,
          reason: 'the pin carries what was typed');
      final centre = _cameraCenter(tester);
      expect(centre.latitude, closeTo(_target.latitude, 1e-6));
      expect(centre.longitude, closeTo(_target.longitude, 1e-6));

      // Tap bare map, away from the bar, the controls and the pin itself.
      final map = tester.getRect(find.byType(FlutterMap));
      await tester.tapAt(Offset(map.left + 20, map.bottom - 40));
      // flutter_map posts a single tap only after the double-tap window has
      // passed, so it can tell the two apart. One frame is not enough for
      // onTap to fire; pump past that window.
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(pin), findsNothing,
          reason: 'tapping the map dismisses the search pin');
      expect(tester.takeException(), isNull);
    });
  });

  group('jobs map', () {
    late AppDatabase db;
    late JobsSignals jobsSignals;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      jobsSignals = JobsSignals(JobRepository(db.jobOrdersDao));
    });

    tearDown(() async {
      await jobsSignals.dispose();
      await db.close();
    });

    testWidgets('a search drops a pin and flies there', (tester) async {
      await tester.runAsync(() async {
        await db.jobOrdersDao.insertOrUpdateJob(JobOrderDto(
          id: 801,
          ticketNumber: 'SF-2026-0801',
          customerName: 'Search Santos',
          address: 'Lot 8, Fiber Street',
          status: 'Scheduled',
          onsiteStatus: 'Scheduled',
          isSynced: true,
          updatedAt: DateTime.now(),
          rawJson: '{"coordinates": "14.469586, 121.195615"}',
        ).toCompanion());
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: JobsMapView(
            jobsSignals: jobsSignals,
            placeLookup: _fakeLookup,
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      const pin = Key('jobsSearchPin');
      expect(find.byKey(pin), findsNothing);

      await _searchFor(tester, 'Pasig City Hall');

      expect(find.byKey(pin), findsOneWidget);
      final centre = _cameraCenter(tester);
      expect(centre.latitude, closeTo(_target.latitude, 1e-6));
      expect(centre.longitude, closeTo(_target.longitude, 1e-6));
      expect(tester.takeException(), isNull);
    });
  });
}
