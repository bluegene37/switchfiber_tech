import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'lcp_nap_dao.g.dart';

@DriftAccessor(tables: [LcpNapLocations])
class LcpNapLocationsDao extends DatabaseAccessor<AppDatabase>
    with _$LcpNapLocationsDaoMixin {
  LcpNapLocationsDao(super.db);

  /// Watch all LCP NAP location records reactively
  Stream<List<LcpNapLocation>> watchAllLocations() {
    return (select(lcpNapLocations)
          ..orderBy(
              [(t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc)]))
        .watch();
  }

  /// Watch a single LCP NAP location by ID
  Stream<LcpNapLocation?> watchLocationById(int id) {
    return (select(lcpNapLocations)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Watch locations filtered by LCP cabinet name
  Stream<List<LcpNapLocation>> watchLocationsByLcp(String lcpName) {
    if (lcpName.isEmpty || lcpName.toLowerCase() == 'all') {
      return watchAllLocations();
    }
    return (select(lcpNapLocations)
          ..where((t) => t.lcp.equals(lcpName))
          ..orderBy(
              [(t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc)]))
        .watch();
  }

  /// Get all locations once
  Future<List<LcpNapLocation>> getAllLocations() {
    return (select(lcpNapLocations)
          ..orderBy(
              [(t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc)]))
        .get();
  }

  /// Insert or update single location
  Future<void> insertOrUpdateLocation(LcpNapLocationsCompanion entry) {
    return into(lcpNapLocations).insertOnConflictUpdate(entry);
  }

  /// Batch insert / cache locations from API
  Future<void> insertAllLocations(
      List<LcpNapLocationsCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(lcpNapLocations, entries);
    });
  }

  /// Delete a location
  Future<void> deleteLocation(int id) {
    return (delete(lcpNapLocations)..where((t) => t.id.equals(id))).go();
  }

  /// Clear all locations
  Future<void> clearAll() {
    return delete(lcpNapLocations).go();
  }

  /// Delete test/sample demo locations
  Future<int> deleteSampleLocations() {
    return (delete(lcpNapLocations)
          ..where((t) => t.street.equals('Sample Street')))
        .go();
  }
}
