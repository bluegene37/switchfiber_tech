import 'package:latlong2/latlong.dart';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

/// DTO for Local Convergence Point (LCP) and Network Access Point (NAP) location sites.
class LcpNapDto {
  final int id;
  final String lcp;
  final String nap;
  final String lcpNap;
  final int portTotal;
  final int portOccupied;
  final String? coordinates;
  final String? barangay;
  final String? city;
  final String status;
  final String? description;
  final bool isSynced;
  final DateTime? updatedAt;

  LcpNapDto({
    required this.id,
    required this.lcp,
    required this.nap,
    required this.lcpNap,
    this.portTotal = 8,
    this.portOccupied = 0,
    this.coordinates,
    this.barangay,
    this.city,
    this.status = 'Active',
    this.description,
    this.isSynced = true,
    this.updatedAt,
  });

  /// Available ports remaining
  int get portAvailable => (portTotal - portOccupied).clamp(0, portTotal);

  /// Port utilization percentage (0.0 to 1.0)
  double get utilizationRate =>
      portTotal > 0 ? (portOccupied / portTotal).clamp(0.0, 1.0) : 0.0;

  /// Parsed GPS latitude
  double? get latitude => latLng?.latitude;

  /// Parsed GPS longitude
  double? get longitude => latLng?.longitude;

  /// The site's position, or null when the record carries no usable fix.
  ///
  /// The API stores this as a single string such as `"14.469586, 121.195615"`.
  /// Anything that is not a real position - malformed text, out-of-range
  /// values, or the 0,0 placeholder the backend uses for "no fix recorded" -
  /// returns null so the site is left off the map rather than plotted somewhere
  /// misleading.
  LatLng? get latLng {
    final raw = coordinates;
    if (raw == null || raw.trim().isEmpty) return null;

    // Accepts the separators and labelled forms the web console accepts, so
    // both clients plot exactly the same rows.
    final clean = raw
        .replaceAll(RegExp(r'lat:|latitude:|lng:|longitude:|lon:',
            caseSensitive: false), '')
        .trim();
    if (clean.isEmpty) return null;

    final parts = clean
        .split(RegExp(r'[,;\s]+'))
        .map((p) => double.tryParse(p.trim()))
        .toList();
    if (parts.length != 2) return null;

    final lat = parts[0];
    final lng = parts[1];
    if (lat == null || lng == null) return null;
    if (lat.abs() > 90 || lng.abs() > 180) return null;
    if (lat == 0 && lng == 0) return null;

    return LatLng(lat, lng);
  }

  /// Whether this site can be shown as a pin on the map.
  bool get isMappable => latLng != null;

  factory LcpNapDto.fromJson(Map<String, dynamic> json) {
    final lcpStr = json['lcp']?.toString() ?? 'LCP 01';
    final napStr = json['nap']?.toString() ?? 'NAP 01';
    final lcpNapStr = json['lcpNap']?.toString() ??
        json['lcpnap']?.toString() ??
        '$lcpStr - $napStr';

    return LcpNapDto(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      lcp: lcpStr,
      nap: napStr,
      lcpNap: lcpNapStr,
      portTotal: json['portTotal'] is int
          ? json['portTotal']
          : int.tryParse(json['portTotal']?.toString() ?? '8') ?? 8,
      portOccupied: json['portOccupied'] is int
          ? json['portOccupied']
          : int.tryParse(json['portOccupied']?.toString() ?? '0') ?? 0,
      coordinates: json['coordinates']?.toString() ??
          json['addressCoordinates']?.toString(),
      barangay: json['barangay']?.toString(),
      city: json['city']?.toString(),
      status: json['status']?.toString() ?? 'Active',
      description: json['description']?.toString() ?? json['remarks']?.toString(),
      isSynced: true,
      updatedAt: DateTime.now(),
    );
  }

  factory LcpNapDto.fromDrift(LcpNapLocation row) {
    return LcpNapDto(
      id: row.id,
      lcp: row.lcp,
      nap: row.nap,
      lcpNap: row.lcpNap,
      portTotal: row.portTotal,
      portOccupied: row.portOccupied,
      coordinates: row.coordinates,
      barangay: row.barangay,
      city: row.city,
      status: row.status,
      description: row.description,
      isSynced: row.isSynced,
      updatedAt: row.updatedAt,
    );
  }

  LcpNapLocationsCompanion toCompanion({bool synced = true}) {
    return LcpNapLocationsCompanion(
      id: Value(id),
      lcp: Value(lcp),
      nap: Value(nap),
      lcpNap: Value(lcpNap),
      portTotal: Value(portTotal),
      portOccupied: Value(portOccupied),
      coordinates: Value(coordinates),
      barangay: Value(barangay),
      city: Value(city),
      status: Value(status),
      description: Value(description),
      isSynced: Value(synced),
      updatedAt: Value(updatedAt ?? DateTime.now()),
    );
  }
}
