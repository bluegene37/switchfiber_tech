import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/services/exif_service.dart';
import 'package:swithfiber_tech/core/services/location_service.dart';

void main() {
  group('ExifService & LocationService tests', () {
    test('LocationService coordinate formatting', () {
      final loc = LocationService.instance;
      final dms = loc.formatDms(14.469586, 121.195615);
      expect(dms, contains('14°28\''));
      expect(dms, contains('121°11\''));
      expect(dms, contains('N'));
      expect(dms, contains('E'));

      final dist = loc.distanceBetween(
        startLat: 14.469586,
        startLng: 121.195615,
        endLat: 14.470000,
        endLng: 121.196000,
      );
      expect(dist, greaterThan(0));
      expect(loc.formatDistance(85), '85 m');
      expect(loc.formatDistance(1500), '1.5 km');
    });

    test('ExifService injects and extracts valid GPS tags in JPEG', () async {
      final exif = ExifService.instance;

      // Create a valid minimal JPEG stream: SOI + SOF0 + EOI
      final dummyJpeg = Uint8List.fromList([
        0xFF, 0xD8, // SOI
        0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x0A, 0x00, 0x0A, 0x01, 0x01, 0x11, 0x00, // SOF0
        0xFF, 0xD9, // EOI
      ]);

      const testLat = 14.469586;
      const testLng = 121.195615;
      const testAlt = 22.5;
      final testTime = DateTime(2026, 9, 3, 14, 30, 0);

      final taggedJpeg = exif.injectGpsExif(
        dummyJpeg,
        latitude: testLat,
        longitude: testLng,
        altitude: testAlt,
        timestamp: testTime,
        technicianEmail: 'tech@switchfiber.ph',
      );

      expect(taggedJpeg.length, greaterThan(dummyJpeg.length));
      expect(taggedJpeg[0], 0xFF);
      expect(taggedJpeg[1], 0xD8);
      expect(taggedJpeg[2], 0xFF);
      expect(taggedJpeg[3], 0xE1); // APP1 Exif marker

      final meta = await exif.extractExif(taggedJpeg);
      expect(meta.hasGps, isTrue);
      expect(meta.latitude, closeTo(testLat, 0.001));
      expect(meta.longitude, closeTo(testLng, 0.001));
      expect(meta.altitude, closeTo(testAlt, 0.1));
      expect(meta.make, contains('Switch Fiber'));
      expect(meta.dmsCoordinates, contains('14°28\''));
      expect(meta.dmsCoordinates, contains('121°11\''));
      expect(meta.orientation, 1);
    });
  });
}
