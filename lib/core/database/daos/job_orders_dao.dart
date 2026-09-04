import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'job_orders_dao.g.dart';

@DriftAccessor(tables: [JobOrders])
class JobOrdersDao extends DatabaseAccessor<AppDatabase>
    with _$JobOrdersDaoMixin {
  JobOrdersDao(super.db);

  /// Watch all cached job orders sorted by ID descending
  Stream<List<JobOrder>> watchAllJobs() {
    return (select(jobOrders)
          ..orderBy(
              [(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Watch job orders filtered by status
  Stream<List<JobOrder>> watchJobsByStatus(String status) {
    if (status.isEmpty) {
      return watchAllJobs();
    }
    return (select(jobOrders)
          ..where((t) => t.status.equals(status.toLowerCase()))
          ..orderBy(
              [(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Get all job orders once
  Future<List<JobOrder>> getAllJobs() {
    return (select(jobOrders)
          ..orderBy(
              [(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get single job by id
  Future<JobOrder?> getJobById(int id) {
    return (select(jobOrders)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Insert or update single job
  Future<void> insertOrUpdateJob(JobOrdersCompanion entry) {
    return into(jobOrders).insertOnConflictUpdate(entry);
  }

  /// Batch insert / cache job list from API
  Future<void> insertAllJobs(List<JobOrdersCompanion> entries) async {
    for (var i = 0; i < entries.length; i += 100) {
      final chunk = entries.sublist(
        i,
        (i + 100 > entries.length) ? entries.length : i + 100,
      );
      await batch((batch) {
        batch.insertAllOnConflictUpdate(jobOrders, chunk);
      });
    }
  }

  /// Toggle or update job status with sync tracking
  /// Update the technician's on-site status, leaving the office-side `status`
  /// column untouched.
  Future<void> updateFieldStatus(int id, String onsiteStatus,
      {bool isSynced = false}) {
    return (update(jobOrders)..where((t) => t.id.equals(id))).write(
      JobOrdersCompanion(
        onsiteStatus: Value(onsiteStatus),
        isSynced: Value(isSynced),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateJobStatus(int id, String newStatus,
      {bool isSynced = false}) {
    return (update(jobOrders)..where((t) => t.id.equals(id))).write(
      JobOrdersCompanion(
        status: Value(newStatus),
        isSynced: Value(isSynced),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark a job Activated: the technician's terminal stage.
  ///
  /// Complete a job: sets status to 'Completed', onsiteStatus to 'Done',
  /// updates dateInstalled, and marks isSynced = false for sync.
  Future<void> completeJob(
    int id, {
    String? assignedEmail,
    required DateTime installedAt,
    bool isSynced = false,
  }) {
    return (update(jobOrders)..where((t) => t.id.equals(id))).write(
      JobOrdersCompanion(
        status: const Value('Completed'),
        onsiteStatus: const Value('Done'),
        assignedEmail:
            assignedEmail == null ? const Value.absent() : Value(assignedEmail),
        dateInstalled: Value(installedAt),
        isSynced: Value(isSynced),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Records who activated it in [assignedEmail] (kept as-is when null) and
  /// the install date, so the job lands in that technician's history.
  Future<void> activateJob(
    int id, {
    String? assignedEmail,
    required DateTime installedAt,
    bool isSynced = false,
  }) {
    return (update(jobOrders)..where((t) => t.id.equals(id))).write(
      JobOrdersCompanion(
        status: const Value('Activated'),
        onsiteStatus: const Value('Done'),
        assignedEmail:
            assignedEmail == null ? const Value.absent() : Value(assignedEmail),
        dateInstalled: Value(installedAt),
        isSynced: Value(isSynced),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update completion report details locally
  Future<void> updateJobCompletion({
    required int id,
    String? status,
    required String onsiteStatus,
    required String onsiteRemarks,
    double? opticalPower,
    String? modemRouterSN,
    String? routerModel,
    String? nap,
    String? boxReadingImage,
    String? routerReadingImage,
    String? clientSignature,
    String? setupImage,
    String? speedtestImage,
    String? portLabelImage,
    String? signedContractImage,
    String? houseFront,
    String? assignedEmail,
    bool isSynced = false,
  }) {
    return (update(jobOrders)..where((t) => t.id.equals(id))).write(
      JobOrdersCompanion(
        status: status == null ? const Value.absent() : Value(status),
        onsiteStatus: Value(onsiteStatus),
        assignedEmail:
            assignedEmail == null ? const Value.absent() : Value(assignedEmail),
        onsiteRemarks: Value(onsiteRemarks),
        opticalPower: Value(opticalPower),
        modemRouterSN: Value(modemRouterSN),
        routerModel: Value(routerModel),
        nap: nap == null ? const Value.absent() : Value(nap),
        dateInstalled: Value(DateTime.now()),
        boxReadingImage: Value(boxReadingImage),
        routerReadingImage: Value(routerReadingImage),
        clientSignature: Value(clientSignature),
        setupImage: Value(setupImage),
        speedtestImage: Value(speedtestImage),
        portLabelImage: Value(portLabelImage),
        signedContractImage: Value(signedContractImage),
        houseFront: Value(houseFront),
        isSynced: Value(isSynced),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get all pending unsynced records
  Future<List<JobOrder>> getUnsyncedJobs() {
    return (select(jobOrders)..where((t) => t.isSynced.equals(false))).get();
  }

  /// Ids of rows carrying a local edit that has not reached the server.
  Future<Set<int>> getUnsyncedIds() async {
    final query = selectOnly(jobOrders)
      ..addColumns([jobOrders.id])
      ..where(jobOrders.isSynced.equals(false));
    final rows = await query.map((r) => r.read(jobOrders.id)!).get();
    return rows.toSet();
  }

  /// Count unsynced items
  Future<int> countUnsynced() async {
    final countExp = jobOrders.id.count();
    final query = selectOnly(jobOrders)
      ..addColumns([countExp])
      ..where(jobOrders.isSynced.equals(false));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  /// Mark job as synced
  Future<void> markAsSynced(int id) {
    return (update(jobOrders)..where((t) => t.id.equals(id))).write(
      JobOrdersCompanion(
        isSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Drop cached rows the server no longer returns, keeping any row with a
  /// local edit still waiting to sync so nothing the technician did is lost.
  Future<int> deleteSyncedJobsNotIn(Set<int> keepIds) async {
    if (keepIds.isEmpty) {
      return (delete(jobOrders)..where((t) => t.isSynced.equals(true))).go();
    }
    final allSynced = await (selectOnly(jobOrders)
          ..addColumns([jobOrders.id])
          ..where(jobOrders.isSynced.equals(true)))
        .map((r) => r.read(jobOrders.id)!)
        .get();
    final toDelete = allSynced.where((id) => !keepIds.contains(id)).toList();
    var deleted = 0;
    for (var i = 0; i < toDelete.length; i += 200) {
      final chunk = toDelete.sublist(
        i,
        (i + 200 > toDelete.length) ? toDelete.length : i + 200,
      );
      deleted += await (delete(jobOrders)..where((t) => t.id.isIn(chunk))).go();
    }
    return deleted;
  }

  /// Delete a job
  Future<void> deleteJob(int id) {
    return (delete(jobOrders)..where((t) => t.id.equals(id))).go();
  }

  /// Clear table (e.g. on full resync or logout)
  Future<void> clearAllJobs() {
    return delete(jobOrders).go();
  }

  /// Delete test/sample demo jobs (IDs 101 to 106)
  Future<int> deleteSampleJobs() {
    return (delete(jobOrders)..where((t) => t.id.isBetweenValues(101, 106)))
        .go();
  }
}
