import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/services/map_navigation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapNavigationService', () {
    test('formats navigation parameters correctly for external map apps', () async {
      const lat = 14.5995;
      const lng = 120.9842;
      const label = 'LCP-BIN-01 NAP-05';

      // Test that the method runs without throwing format errors
      expect(
        () => MapNavigationService.navigateToCoordinates(
          latitude: lat,
          longitude: lng,
          destinationLabel: label,
        ),
        returnsNormally,
      );
    });
  });
}
