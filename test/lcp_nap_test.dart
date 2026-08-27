import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/features/lcp_nap/models/lcp_nap_model.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/screens/lcp_nap_list_screen.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';
import 'package:swithfiber_tech/features/lcp_nap/widgets/lcp_nap_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('LCP NAP Locations - Drift to Signals Data Flow Tests', () {
    test('1. Seeding Drift SQLite automatically triggers Signals reactive update', () async {
      await repository.seedSampleLocations();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(signals.allLocations.value.length, 5);
      expect(signals.totalSitesCount.value, 5);
      expect(signals.totalPortsCount.value, 48); // 8 + 8 + 16 + 8 + 8
    });

    test('2. Changing cabinet filter updates computed filteredLocations', () async {
      await repository.seedSampleLocations();
      await Future.delayed(const Duration(milliseconds: 100));

      // Filter by LCP 01
      signals.setLcpFilter('LCP 01');
      expect(signals.filteredLocations.value.length, 2);

      // Filter by LCP 02
      signals.setLcpFilter('LCP 02');
      expect(signals.filteredLocations.value.length, 2);

      signals.setLcpFilter('All');
      expect(signals.filteredLocations.value.length, 5);
    });

    test('3. Search query filters locations across name, barangay, and city', () async {
      await repository.seedSampleLocations();
      await Future.delayed(const Duration(milliseconds: 100));

      signals.setSearch('Antipolo');
      expect(signals.filteredLocations.value.length, 2);

      signals.setSearch('Loyola');
      expect(signals.filteredLocations.value.length, 1);
      expect(signals.filteredLocations.value.first.city, 'Quezon City');
    });

    test('4. Street and region from the API are searchable', () async {
      await repository.seedSampleLocations();
      await Future.delayed(const Duration(milliseconds: 100));

      final site = signals.allLocations.value.first;
      expect(site.street, isNotNull);
      expect(site.region, isNotNull);

      signals.setSearch(site.region!);
      expect(signals.filteredLocations.value, isNotEmpty);
    });
  });

  group('LCP NAP UI Widget & Navigation Tests', () {
    testWidgets('LcpNapCard renders port capacity and triggers callbacks', (tester) async {
      final sample = LcpNapDto(
        id: 99,
        lcp: 'LCP 10',
        nap: 'NAP 05',
        lcpNap: 'LCP 10 - NAP 05',
        portTotal: 8,
        street: 'Mejorada Street',
        barangay: 'San Antonio',
        city: 'Pasig',
        region: 'Rizal',
      );

      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LcpNapCard(
              location: sample,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('LCP 10 - NAP 05'), findsOneWidget);
      // Capacity only: the API does not report how many ports are in use.
      expect(find.text('8 ports'), findsOneWidget);
      expect(find.textContaining('Occupancy'), findsNothing);

      await tester.tap(find.byType(LcpNapCard));
      expect(tapped, isTrue);
    });

    testWidgets('LcpNapListScreen navigates to LcpNapDetailScreen on tap', (tester) async {
      // Drift I/O and its watch stream need real async, which the fake clock
      // inside testWidgets never advances; runAsync gives them a real zone.
      await tester.runAsync(() async {
        await repository.seedSampleLocations();
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });

      await tester.pumpWidget(
        MaterialApp(
          home: LcpNapListScreen(signals: signals),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LCP NAP Plant Network'), findsOneWidget);
      expect(find.text('5 NAP Sites'), findsOneWidget);

      // Tap first card to open detail view
      await tester.tap(find.byType(LcpNapCard).first);
      await tester.pumpAndSettle();

      // Verify Detail Screen rendered
      expect(find.text('Port Matrix & Capacity'), findsOneWidget);

      // The detail screen body is a lazy ListView, so cards below the fold are
      // not built until scrolled into view.
      await tester.scrollUntilVisible(
        find.text('GPS Geolocation Coordinates'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('GPS Geolocation Coordinates'), findsOneWidget);
      expect(find.text('WGS84 Coordinates'), findsOneWidget);
    });
  });
}
