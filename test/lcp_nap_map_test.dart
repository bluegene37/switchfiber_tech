import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';
import 'package:latlong2/latlong.dart';
import 'package:swithfiber_tech/features/lcp_nap/models/lcp_nap_model.dart';

LcpNapDto site(String? coordinates, {int id = 1}) => LcpNapDto(
      id: id,
      lcpNap: 'CAR LCP 002 NAP 004',
      lcp: 'CAR LCP 002',
      nap: 'NAP 004',
      coordinates: coordinates,
    );

void main() {
  group('mapping a location to a pin', () {
    test('reads the live API coordinate format', () {
      final s = site('14.469586, 121.195615');
      expect(s.latLng, const LatLng(14.469586, 121.195615));
      expect(s.isMappable, isTrue);
    });

    test('tolerates missing space after the comma', () {
      expect(site('14.469586,121.195615').latLng,
          const LatLng(14.469586, 121.195615));
    });

    test('handles negative coordinates', () {
      expect(
          site('-33.8688, 151.2093').latLng, const LatLng(-33.8688, 151.2093));
    });

    test('accepts the same separators the web console accepts', () {
      expect(site('14.469586; 121.195615').latLng,
          const LatLng(14.469586, 121.195615));
      expect(site('14.469586 121.195615').latLng,
          const LatLng(14.469586, 121.195615));
      expect(site('lat: 14.469586, lng: 121.195615').latLng,
          const LatLng(14.469586, 121.195615));
      expect(site('latitude:14.469586 longitude:121.195615').latLng,
          const LatLng(14.469586, 121.195615));
    });

    test('rejects a value with more than two numbers', () {
      expect(site('14.4, 121.1, 55').isMappable, isFalse);
    });

    test('a location with no coordinates is not mappable', () {
      expect(site(null).latLng, isNull);
      expect(site(null).isMappable, isFalse);
      expect(site('').isMappable, isFalse);
    });

    test('malformed coordinates are not mappable rather than crashing', () {
      expect(site('not a coordinate').isMappable, isFalse);
      expect(site('14.469586').isMappable, isFalse);
      expect(site('14.469586, ').isMappable, isFalse);
      expect(site(',').isMappable, isFalse);
    });

    test('out-of-range values are rejected, not plotted in the ocean', () {
      expect(site('91.0, 121.0').isMappable, isFalse,
          reason: 'latitude above 90 is not a real position');
      expect(site('14.0, 181.0').isMappable, isFalse,
          reason: 'longitude above 180 is not a real position');
      expect(site('-91.0, 0.0').isMappable, isFalse);
    });

    test('0,0 is treated as a missing fix, not the Gulf of Guinea', () {
      expect(site('0, 0').isMappable, isFalse);
      expect(site('0.0, 0.0').isMappable, isFalse);
    });
  });

  group('map view state driven by the same filters as the list', () {
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

    test('only mappable sites become pins, and the rest are counted', () async {
      await repository.seedSampleLocations();
      await Future.delayed(const Duration(milliseconds: 100));

      final total = signals.filteredLocations.value.length;
      expect(total, greaterThan(0));

      final mappable = signals.mappableLocations.value;
      expect(mappable.every((l) => l.isMappable), isTrue);
      expect(
        signals.unmappedCount.value,
        total - mappable.length,
        reason: 'every filtered site is either a pin or counted as unmapped',
      );
    });

    test('searching narrows the pins, not just the list', () async {
      await repository.seedSampleLocations();
      await Future.delayed(const Duration(milliseconds: 100));

      final before = signals.mappableLocations.value.length;
      signals.setSearch('LCP 01');
      final after = signals.mappableLocations.value.length;

      expect(after, lessThanOrEqualTo(before));
      expect(
        signals.mappableLocations.value
            .every((l) => l.lcpNap.toLowerCase().contains('lcp 01')),
        isTrue,
      );
    });
  });
}
