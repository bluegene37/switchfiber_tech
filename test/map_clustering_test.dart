import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/lcp_nap/models/lcp_nap_model.dart';
import 'package:swithfiber_tech/features/lcp_nap/services/map_clustering.dart';

LcpNapDto site(String coords, {int id = 1, String lcp = 'LCP 01'}) => LcpNapDto(
      id: id,
      lcpNap: '$lcp - NAP 0$id',
      lcp: lcp,
      nap: 'NAP 0$id',
      coordinates: coords,
    );

void main() {
  group('grouping pins so a dense plant stays readable', () {
    test('sites metres apart merge when zoomed out', () {
      final clusters = clusterSites(
        [
          site('14.469586, 121.195615', id: 1),
          site('14.469600, 121.195630', id: 2),
          site('14.469610, 121.195640', id: 3),
        ],
        zoom: 8,
      );
      expect(clusters, hasLength(1));
      expect(clusters.single.count, 3);
      expect(clusters.single.isCluster, isTrue);
    });

    test('the same sites separate when zoomed in', () {
      final sites = [
        site('14.469586, 121.195615', id: 1),
        site('14.480000, 121.205000', id: 2),
      ];
      expect(clusterSites(sites, zoom: 6), hasLength(1));
      expect(clusterSites(sites, zoom: 18), hasLength(2));
    });

    test('far apart sites never merge', () {
      final clusters = clusterSites(
        [
          site('14.469586, 121.195615', id: 1),
          site('-33.868800, 151.209300', id: 2),
        ],
        zoom: 10,
      );
      expect(clusters, hasLength(2));
      expect(clusters.every((c) => c.isCluster), isFalse);
    });

    test('a lone site is a plain pin, not a cluster of one', () {
      final clusters = clusterSites([site('14.469586, 121.195615')], zoom: 12);
      expect(clusters.single.isCluster, isFalse);
      expect(clusters.single.count, 1);
      expect(clusters.single.sites.single.id, 1);
    });

    test('a cluster sits at the average of its members', () {
      final clusters = clusterSites(
        [
          site('14.000000, 121.000000', id: 1),
          site('14.000020, 121.000020', id: 2),
        ],
        zoom: 8,
      );
      final c = clusters.single.center;
      expect(c.latitude, closeTo(14.00001, 0.000001));
      expect(c.longitude, closeTo(121.00001, 0.000001));
    });

    test('sites without a fix are left out entirely', () {
      final clusters = clusterSites(
        [site('14.469586, 121.195615', id: 1), site('0, 0', id: 2)],
        zoom: 12,
      );
      expect(clusters, hasLength(1));
      expect(clusters.single.sites.single.id, 1);
    });

    test('no sites means no clusters', () {
      expect(clusterSites(const [], zoom: 12), isEmpty);
    });
  });

  group('per-cabinet pin colour', () {
    test('every NAP on a cabinet shares its colour', () {
      expect(lcpColorSeed('LCP 002'), lcpColorSeed('LCP 002'));
    });

    test('different cabinets get different colours', () {
      expect(lcpColorSeed('LCP 002'), isNot(lcpColorSeed('LCP 003')));
    });

    test('a blank cabinet name still yields a stable colour', () {
      expect(lcpColorSeed(''), lcpColorSeed(''));
      expect(lcpColorSeed(null), isA<double>());
    });

    test('hue stays inside the colour wheel', () {
      for (final name in ['LCP 001', 'CAR LCP 002', '', 'Ungrouped', 'x']) {
        final hue = lcpColorSeed(name);
        expect(hue, greaterThanOrEqualTo(0));
        expect(hue, lessThan(360));
      }
    });
  });
}
