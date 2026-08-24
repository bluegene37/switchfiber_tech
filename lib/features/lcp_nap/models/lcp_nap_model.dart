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
  double? get latitude {
    if (coordinates == null) return null;
    final parts = coordinates!.split(',');
    if (parts.length >= 2) return double.tryParse(parts[0].trim());
    return null;
  }

  /// Parsed GPS longitude
  double? get longitude {
    if (coordinates == null) return null;
    final parts = coordinates!.split(',');
    if (parts.length >= 2) return double.tryParse(parts[1].trim());
    return null;
  }

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
