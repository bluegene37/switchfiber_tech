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
  final String? coordinates;
  final String? street;
  final String? barangay;
  final String? city;
  final String? region;
  final String? image;
  final String? image2;
  final String? readingImage;
  final String? modifiedBy;
  final String? userEmail;
  final DateTime? modifiedDate;
  final bool isSynced;
  final DateTime? updatedAt;

  LcpNapDto({
    required this.id,
    required this.lcp,
    required this.nap,
    required this.lcpNap,
    this.portTotal = 8,
    this.coordinates,
    this.street,
    this.barangay,
    this.city,
    this.region,
    this.image,
    this.image2,
    this.readingImage,
    this.modifiedBy,
    this.userEmail,
    this.modifiedDate,
    this.isSynced = true,
    this.updatedAt,
  });

  /// Available ports remaining

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
        .replaceAll(
            RegExp(r'lat:|latitude:|lng:|longitude:|lon:',
                caseSensitive: false),
            '')
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
    final lcpStr = json['lcp']?.toString().trim() ?? '';
    final napStr = json['nap']?.toString().trim() ?? '';
    final lcpNapRaw =
        (json['lcpNap'] ?? json['lcpnap'])?.toString().trim() ?? '';
    final lcpNapStr = lcpNapRaw.isNotEmpty
        ? lcpNapRaw
        : (lcpStr.isNotEmpty && napStr.isNotEmpty
            ? '$lcpStr - $napStr'
            : (lcpStr.isNotEmpty ? lcpStr : napStr));

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
      coordinates: json['coordinates']?.toString() ??
          json['addressCoordinates']?.toString(),
      street: json['street']?.toString(),
      barangay: json['barangay']?.toString(),
      city: json['city']?.toString(),
      region: json['region']?.toString(),
      image: json['image']?.toString(),
      image2: json['image2']?.toString(),
      readingImage: json['readingImage']?.toString(),
      modifiedBy: json['modifiedBy']?.toString(),
      userEmail: json['userEmail']?.toString(),
      modifiedDate: DateTime.tryParse(json['modifiedDate']?.toString() ?? ''),
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
      coordinates: row.coordinates,
      street: row.street,
      barangay: row.barangay,
      city: row.city,
      region: row.region,
      image: row.image,
      image2: row.image2,
      readingImage: row.readingImage,
      modifiedBy: row.modifiedBy,
      userEmail: row.userEmail,
      modifiedDate: row.modifiedDate,
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
      coordinates: Value(coordinates),
      street: Value(street),
      barangay: Value(barangay),
      city: Value(city),
      region: Value(region),
      image: Value(image),
      image2: Value(image2),
      readingImage: Value(readingImage),
      modifiedBy: Value(modifiedBy),
      userEmail: Value(userEmail),
      modifiedDate: Value(modifiedDate),
      isSynced: Value(synced),
      updatedAt: Value(updatedAt ?? DateTime.now()),
    );
  }
}
