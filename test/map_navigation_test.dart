import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/services/map_navigation_service.dart';

/// Directions must open a map app, never the browser. On Android every
/// https map link lands in Chrome, so the service has to prefer the Google
/// Maps scheme, then whatever app handles `geo:`, and only fall back to
/// https when the phone has no map app at all.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Uri> launched;
  late Set<String> installedSchemes;

  setUp(() {
    launched = [];
    installedSchemes = {};
    MapNavigationService.canLaunch =
        (uri) async => installedSchemes.contains(uri.scheme);
    MapNavigationService.launch = (uri) async {
      launched.add(uri);
      return true;
    };
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  Future<bool> go() => MapNavigationService.navigateToCoordinates(
        latitude: 14.5995,
        longitude: 120.9842,
        destinationLabel: 'LCP-BIN-01 NAP-05',
      );

  group('Android', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);

    test('opens Google Maps turn-by-turn when it is installed', () async {
      installedSchemes = {'google.navigation', 'geo', 'https'};
      expect(await go(), isTrue);
      expect(launched.single.scheme, 'google.navigation');
      expect(launched.single.toString(), contains('14.5995,120.9842'));
    });

    test('falls back to the default map app, not the browser', () async {
      installedSchemes = {'geo', 'https'};
      expect(await go(), isTrue);
      expect(launched.single.scheme, 'geo',
          reason: 'https would open Chrome on a phone without Google Maps');
      expect(launched.single.toString(), contains('LCP-BIN-01'));
    });

    test('uses the browser only when nothing on the phone shows maps',
        () async {
      installedSchemes = {'https'};
      expect(await go(), isTrue);
      expect(launched.single.scheme, 'https');
    });

    test('an address without coordinates goes to the map app too', () async {
      installedSchemes = {'geo', 'https'};
      expect(
          await MapNavigationService.navigateToAddress(
              'Blk 1 Lot 2, Batingan, Binangonan, Rizal, Philippines'),
          isTrue);
      expect(launched.single.scheme, 'geo');
      expect(launched.single.toString(), contains('Binangonan'));
    });

    test('a blank address opens nothing', () async {
      installedSchemes = {'geo'};
      expect(await MapNavigationService.navigateToAddress('  '), isFalse);
      expect(launched, isEmpty);
    });

    test('Waze opens its own app when installed', () async {
      installedSchemes = {'waze', 'https'};
      await MapNavigationService.launchSpecificMap(
          appType: 'waze', latitude: 1, longitude: 2);
      expect(launched.single.scheme, 'waze');
    });

    test('a scheme the phone reports but then refuses is skipped', () async {
      installedSchemes = {'google.navigation', 'geo'};
      MapNavigationService.launch = (uri) async {
        launched.add(uri);
        return uri.scheme != 'google.navigation';
      };
      expect(await go(), isTrue);
      expect(launched.map((u) => u.scheme), ['google.navigation', 'geo']);
    });
  });

  group('iOS', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);

    test('prefers the Google Maps app when installed', () async {
      installedSchemes = {'comgooglemaps', 'maps', 'https'};
      expect(await go(), isTrue);
      expect(launched.single.scheme, 'comgooglemaps');
    });

    test('otherwise opens Apple Maps directly', () async {
      installedSchemes = {'maps', 'https'};
      expect(await go(), isTrue);
      expect(launched.single.scheme, 'maps');
      expect(launched.single.toString(), contains('daddr=14.5995,120.9842'));
    });
  });
}
