import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'sync_error_logs_dao.g.dart';

/// Reads and writes the on-phone record of pushes the server refused.
@DriftAccessor(tables: [SyncErrorLogs])
class SyncErrorLogsDao extends DatabaseAccessor<AppDatabase>
    with _$SyncErrorLogsDaoMixin {
  SyncErrorLogsDao(super.db);

  /// How many entries are kept. Old ones are dropped rather than growing
  /// without bound on a phone that has been offline for a week.
  static const int maxEntries = 200;

  /// Newest first, so the screen shows the most recent failure at the top.
  Stream<List<SyncErrorLog>> watchAll({bool onlyUnresolved = false}) {
    final q = select(syncErrorLogs)
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);
    if (onlyUnresolved) q.where((t) => t.resolved.equals(false));
    return q.watch();
  }

  Future<List<SyncErrorLog>> getAll({bool onlyUnresolved = false}) {
    final q = select(syncErrorLogs)
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);
    if (onlyUnresolved) q.where((t) => t.resolved.equals(false));
    return q.get();
  }

  /// Number of records still failing, which is what a badge should show.
  Future<int> countUnresolved() async {
    final rows = await (select(syncErrorLogs)
          ..where((t) => t.resolved.equals(false)))
        .get();
    return rows.length;
  }

  Future<void> log({
    required String entityType,
    required int entityId,
    required String reference,
    required String operation,
    int? statusCode,
    required String message,
    int payloadBytes = 0,
  }) async {
    await into(syncErrorLogs).insert(SyncErrorLogsCompanion.insert(
      entityType: entityType,
      entityId: entityId,
      reference: Value(reference),
      operation: operation,
      statusCode: Value(statusCode),
      // A server can return a whole HTML error page; keep it readable.
      message: message.length > 2000 ? message.substring(0, 2000) : message,
      payloadBytes: Value(payloadBytes),
    ));
    await _trim();
  }

  /// Called when a record finally syncs, so its past failures stop counting
  /// as outstanding. The history stays readable until it is cleared.
  Future<void> markResolved(String entityType, int entityId) {
    return (update(syncErrorLogs)
          ..where((t) =>
              t.entityType.equals(entityType) &
              t.entityId.equals(entityId) &
              t.resolved.equals(false)))
        .write(const SyncErrorLogsCompanion(resolved: Value(true)));
  }

  Future<void> clearAll() => delete(syncErrorLogs).go();

  Future<void> _trim() async {
    // Trimmed by id, not occurredAt: several failures in one sync pass share
    // the same second, and a timestamp cutoff then deletes nothing at all.
    final rows = await (select(syncErrorLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .get();
    if (rows.length <= maxEntries) return;
    final cutoff = rows[maxEntries - 1].id;
    await (delete(syncErrorLogs)..where((t) => t.id.isSmallerThanValue(cutoff)))
        .go();
  }
}
