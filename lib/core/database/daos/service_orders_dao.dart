import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'service_orders_dao.g.dart';

@DriftAccessor(tables: [ServiceOrders])
class ServiceOrdersDao extends DatabaseAccessor<AppDatabase>
    with _$ServiceOrdersDaoMixin {
  ServiceOrdersDao(super.db);

  /// Watch all cached service orders sorted by ID descending.
  Stream<List<ServiceOrder>> watchAllOrders() {
    return (select(serviceOrders)
          ..orderBy(
              [(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Get all service orders once.
  Future<List<ServiceOrder>> getAllOrders() {
    return (select(serviceOrders)
          ..orderBy(
              [(t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get a single service order by id.
  Future<ServiceOrder?> getOrderById(int id) {
    return (select(serviceOrders)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert or update a single service order.
  Future<void> insertOrUpdateOrder(ServiceOrdersCompanion entry) {
    return into(serviceOrders).insertOnConflictUpdate(entry);
  }

  /// Batch insert or cache service orders from API.
  Future<void> insertAllOrders(List<ServiceOrdersCompanion> entries) async {
    for (var i = 0; i < entries.length; i += 100) {
      final chunk = entries.sublist(
        i,
        (i + 100 > entries.length) ? entries.length : i + 100,
      );
      await batch((batch) {
        batch.insertAllOnConflictUpdate(serviceOrders, chunk);
      });
    }
  }

  /// Update an existing service order with a companion.
  Future<void> updateOrder(int id, ServiceOrdersCompanion entry) {
    return (update(serviceOrders)..where((t) => t.id.equals(id))).write(entry);
  }

  /// Get all unsynced service orders.
  Future<List<ServiceOrder>> getUnsyncedOrders() {
    return (select(serviceOrders)..where((t) => t.isSynced.equals(false)))
        .get();
  }

  /// IDs of rows with local edits not yet synced to the server.
  Future<Set<int>> getUnsyncedIds() async {
    final query = selectOnly(serviceOrders)
      ..addColumns([serviceOrders.id])
      ..where(serviceOrders.isSynced.equals(false));
    final rows = await query.map((r) => r.read(serviceOrders.id)!).get();
    return rows.toSet();
  }

  /// Count of unsynced items.
  Future<int> countUnsynced() async {
    final countExp = serviceOrders.id.count();
    final query = selectOnly(serviceOrders)
      ..addColumns([countExp])
      ..where(serviceOrders.isSynced.equals(false));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  /// Mark an order as synced.
  Future<void> markAsSynced(int id) {
    return (update(serviceOrders)..where((t) => t.id.equals(id))).write(
      ServiceOrdersCompanion(
        isSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete cached rows that no longer exist on the server, preserving any
  /// row with an unsynced local edit.
  Future<int> deleteSyncedOrdersNotIn(Set<int> keepIds) async {
    if (keepIds.isEmpty) {
      return (delete(serviceOrders)..where((t) => t.isSynced.equals(true)))
          .go();
    }
    final allSynced = await (selectOnly(serviceOrders)
          ..addColumns([serviceOrders.id])
          ..where(serviceOrders.isSynced.equals(true)))
        .map((r) => r.read(serviceOrders.id)!)
        .get();
    final toDelete = allSynced.where((id) => !keepIds.contains(id)).toList();
    var deleted = 0;
    for (var i = 0; i < toDelete.length; i += 200) {
      final chunk = toDelete.sublist(
        i,
        (i + 200 > toDelete.length) ? toDelete.length : i + 200,
      );
      deleted +=
          await (delete(serviceOrders)..where((t) => t.id.isIn(chunk))).go();
    }
    return deleted;
  }

  /// Delete a single service order.
  Future<void> deleteOrder(int id) {
    return (delete(serviceOrders)..where((t) => t.id.equals(id))).go();
  }

  /// Clear all service orders.
  Future<void> clearAllOrders() {
    return delete(serviceOrders).go();
  }
}
