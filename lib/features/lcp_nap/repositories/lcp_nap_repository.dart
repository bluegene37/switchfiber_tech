import 'dart:async';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/lcp_nap_dao.dart';
import '../../../core/network/api_client.dart';
import '../models/lcp_nap_model.dart';

/// Repository coordinating LCP NAP locations between API and Drift SQLite.
class LcpNapRepository {
  final LcpNapLocationsDao _dao;
  final ApiClient _api = ApiClient.instance;

  LcpNapRepository(this._dao);

  /// Watch reactive stream of all locations from Drift SQLite
  Stream<List<LcpNapDto>> watchLocations() {
    return _dao.watchAllLocations().map(
          (rows) => rows.map(LcpNapDto.fromDrift).toList(),
        );
  }

  /// Watch a specific location by ID
  Stream<LcpNapDto?> watchLocationById(int id) {
    return _dao.watchLocationById(id).map(
          (row) => row != null ? LcpNapDto.fromDrift(row) : null,
        );
  }

  /// Fetch remote records from API and cache in Drift
  Future<void> fetchRemoteLocations() async {
    try {
      final response = await _api.get('/LCPNapLocations');
      final data = response.data;

      if (data is List) {
        final companions = <LcpNapLocationsCompanion>[];
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            final dto = LcpNapDto.fromJson(item);
            companions.add(dto.toCompanion(synced: true));
          }
        }
        if (companions.isNotEmpty) {
          await _dao.insertAllLocations(companions);
        }
      }
    } catch (_) {
      // Offline fallback: seed sample network plant records if database is empty
      final count = (await _dao.getAllLocations()).length;
      if (count == 0) {
        await seedSampleLocations();
      }
    }
  }

  /// Update location status locally in Drift SQLite
  Future<void> updateLocationStatus(int id, String newStatus) async {
    await _dao.updateStatus(id, newStatus, isSynced: false);
  }

  /// Seed realistic fiber plant infrastructure data
  Future<void> seedSampleLocations() async {
    final now = DateTime.now();
    final sampleSites = [
      LcpNapDto(
        id: 1,
        lcp: 'LCP 01',
        nap: 'NAP 01',
        lcpNap: 'LCP 01 - NAP 01',
        portTotal: 8,
        portOccupied: 7,
        coordinates: '14.5862, 121.0618',
        barangay: 'San Antonio',
        city: 'Pasig',
        status: 'Active',
        description: 'Mounted on Meralco Pole #402. High density residential feeder.',
        isSynced: true,
        updatedAt: now,
      ),
      LcpNapDto(
        id: 2,
        lcp: 'LCP 01',
        nap: 'NAP 02',
        lcpNap: 'LCP 01 - NAP 02',
        portTotal: 8,
        portOccupied: 4,
        coordinates: '14.5875, 121.0632',
        barangay: 'San Antonio',
        city: 'Pasig',
        status: 'Active',
        description: 'Corner Emerald Ave & Jade St. Commercial hub.',
        isSynced: true,
        updatedAt: now,
      ),
      LcpNapDto(
        id: 3,
        lcp: 'LCP 02',
        nap: 'NAP 01',
        lcpNap: 'LCP 02 - NAP 01',
        portTotal: 16,
        portOccupied: 16,
        coordinates: '14.6288, 121.1274',
        barangay: 'San Roque',
        city: 'Antipolo',
        status: 'Full',
        description: 'Subdivision entrance distribution cabinet. Expansion planned.',
        isSynced: true,
        updatedAt: now,
      ),
      LcpNapDto(
        id: 4,
        lcp: 'LCP 02',
        nap: 'NAP 02',
        lcpNap: 'LCP 02 - NAP 02',
        portTotal: 8,
        portOccupied: 3,
        coordinates: '14.6295, 121.1290',
        barangay: 'San Roque',
        city: 'Antipolo',
        status: 'Active',
        description: 'Redwood St. junction box. Spare ports available.',
        isSynced: true,
        updatedAt: now,
      ),
      LcpNapDto(
        id: 5,
        lcp: 'LCP 03',
        nap: 'NAP 01',
        lcpNap: 'LCP 03 - NAP 01',
        portTotal: 8,
        portOccupied: 2,
        coordinates: '14.6433, 121.0712',
        barangay: 'Loyola Heights',
        city: 'Quezon City',
        status: 'Maintenance',
        description: 'Tray inspection scheduled. Splice cassette alignment.',
        isSynced: true,
        updatedAt: now,
      ),
    ];

    final companions = sampleSites.map((s) => s.toCompanion(synced: true)).toList();
    await _dao.insertAllLocations(companions);
  }
}
