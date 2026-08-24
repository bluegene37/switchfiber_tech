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
      expect(signals.totalOccupiedPorts.value, 32); // 7 + 4 + 16 + 3 + 2
      expect(signals.activeCount.value, 3);
      expect(signals.fullCount.value, 1);
      expect(signals.maintenanceCount.value, 1);
    });

    test('2. Changing cabinet and status filter updates computed filteredLocations', () async {
      await repository.seedSampleLocations();
      await Future.delayed(const Duration(milliseconds: 100));

      // Filter by LCP 01
      signals.setLcpFilter('LCP 01');
      expect(signals.filteredLocations.value.length, 2);

      // Filter by LCP 02
      signals.setLcpFilter('LCP 02');
      expect(signals.filteredLocations.value.length, 2);

      // Filter by Status: Maintenance
      signals.setLcpFilter('All');
      signals.setStatusFilter('Maintenance');
      expect(signals.filteredLocations.value.length, 1);
      expect(signals.filteredLocations.value.first.lcpNap, 'LCP 03 - NAP 01');
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

    test('4. Modifying status in Drift updates Signals and preserves reactive consistency', () async {
      await repository.seedSampleLocations();
      await Future.delayed(const Duration(milliseconds: 100));

      final firstSite = signals.allLocations.value.first;
      expect(firstSite.status, 'Active');

      // Update in Drift SQLite
      await signals.updateSiteStatus(firstSite.id, 'Maintenance');
      await Future.delayed(const Duration(milliseconds: 100));

      final updated = signals.allLocations.value.firstWhere((l) => l.id == firstSite.id);
      expect(updated.status, 'Maintenance');
      expect(signals.maintenanceCount.value, 2);
    });
  });

  group('LCP NAP UI Widget & Navigation Tests', () {
    testWidgets('LcpNapCard renders port utilization and triggers callbacks', (tester) async {
      final sample = LcpNapDto(
        id: 99,
        lcp: 'LCP 10',
        nap: 'NAP 05',
        lcpNap: 'LCP 10 - NAP 05',
        portTotal: 8,
        portOccupied: 6,
        status: 'Active',
        barangay: 'San Antonio',
        city: 'Pasig',
      );

      var tapped = false;
      var cycled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LcpNapCard(
              location: sample,
              onTap: () => tapped = true,
              onCycleStatus: () => cycled = true,
            ),
          ),
        ),
      );

      expect(find.text('LCP 10'), findsOneWidget);
      expect(find.text('NAP 05'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Ports Occupancy (6/8)'), findsOneWidget);

      await tester.tap(find.text('Cycle Status'));
      expect(cycled, isTrue);

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

      expect(find.text('LCP NAP Locations'), findsOneWidget);
      expect(find.text('5 Sites'), findsOneWidget);

      // Tap first card to open detail view
      // The card renders `lcp` and `nap` as separate Text widgets, so the
      // combined "LCP 01 - NAP 01" label is never rendered; tap the card itself.
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
