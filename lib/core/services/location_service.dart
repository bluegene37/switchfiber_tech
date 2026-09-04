import 'package:geolocator/geolocator.dart';

/// Service to query technician device GPS location and format coordinates.
class LocationService {
  /// The shared instance. Not `final` so tests can install a stand-in and
  /// keep the device GPS out of the widget suite.
  static LocationService instance = LocationService();

  /// Default fallback coordinates (Binangonan, Rizal plant center)
  static const double fallbackLat = 14.469586;
  static const double fallbackLng = 121.195615;

  /// Check whether location services are enabled and permissions are granted.
  Future<bool> checkPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }

      if (permission == LocationPermission.deniedForever) return false;

      return true;
    } catch (_) {
      return false;
    }
  }

  Position? _lastKnownPosition;
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Get the current position, falling back to the last known position or null.
  Future<Position?> getCurrentPosition({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    try {
      final hasPerm = await checkPermission();
      if (!hasPerm) {
        final pos = await Geolocator.getLastKnownPosition();
        if (pos != null) _lastKnownPosition = pos;
        return pos;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
      _lastKnownPosition = pos;
      return pos;
    } catch (_) {
      try {
        final pos = await Geolocator.getLastKnownPosition();
        if (pos != null) _lastKnownPosition = pos;
        return pos;
      } catch (_) {
        return null;
      }
    }
  }

  /// Calculate distance in meters between two lat/lng pairs.
  double distanceBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Format distance for human-friendly display (e.g. "85 m" or "1.4 km").
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Convert decimal degrees to DMS string (e.g. 14°28'10.5" N, 121°11'44.2" E).
  String formatDms(double lat, double lng) {
    final latRef = lat >= 0 ? 'N' : 'S';
    final lngRef = lng >= 0 ? 'E' : 'W';

    String toDms(double val) {
      final absVal = val.abs();
      final deg = absVal.floor();
      final minVal = (absVal - deg) * 60;
      final min = minVal.floor();
      final sec = (minVal - min) * 60;
      return '$deg°$min\'${sec.toStringAsFixed(1)}"';
    }

    return '${toDms(lat)} $latRef, ${toDms(lng)} $lngRef';
  }
}
