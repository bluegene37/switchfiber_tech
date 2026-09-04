import 'dart:async';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/database/daos/service_orders_dao.dart';
import '../../../core/network/network_exceptions.dart';
import '../models/service_order_model.dart';
import 'service_orders_api.dart';

/// Background worker that synchronizes offline-edited service orders with the backend API.
class ServiceOrdersSyncWorker {
  final ServiceOrdersDao _dao;
  final ServiceOrdersApi _api;

  ServiceOrdersSyncWorker(this._dao, {ServiceOrdersApi? api})
      : _api = api ?? ServiceOrdersApi();

  // Reactive state
  final isSyncing = signal<bool>(false);
  final pendingCount = signal<int>(0);
  final lastSyncTime = signal<DateTime?>(null);
  final syncError = signal<String?>(null);

  /// Refresh pending count from Drift
  Future<int> refreshPendingCount() async {
    final count = await _dao.countUnsynced();
    pendingCount.value = count;
    return count;
  }

  /// Run sync process for all pending unsynced records
  Future<ServiceOrdersSyncResult> syncPendingOrders() async {
    if (isSyncing.value) {
      return ServiceOrdersSyncResult(
        success: false,
        message: 'Sync already in progress',
      );
    }

    isSyncing.value = true;
    syncError.value = null;

    int syncedSuccess = 0;
    int syncedFailed = 0;
    int removed = 0;

    try {
      final unsynced = await _dao.getUnsyncedOrders();
      pendingCount.value = unsynced.length;

      if (unsynced.isEmpty) {
        lastSyncTime.value = DateTime.now();
        return ServiceOrdersSyncResult(
          success: true,
          syncedCount: 0,
          message: 'All service orders are up to date.',
        );
      }

      for (final rawOrder in unsynced) {
        final dto = ServiceOrderDto.fromDrift(rawOrder);
        try {
          final payload = await dto.toApiJsonAsync();
          final ok = await _api.updateServiceOrder(dto.id, payload);
          if (ok) {
            await _dao.markAsSynced(dto.id);
            syncedSuccess++;
          } else {
            syncedFailed++;
          }
        } on ApiException catch (err) {
          if (err.statusCode == 404) {
            await _dao.deleteOrder(dto.id);
            removed++;
          } else {
            syncedFailed++;
          }
        } catch (_) {
          syncedFailed++;
        }
      }

      final remaining = await _dao.countUnsynced();
      pendingCount.value = remaining;
      lastSyncTime.value = DateTime.now();

      final parts = <String>[
        if (syncedSuccess > 0) 'Synced $syncedSuccess service order(s).',
        if (removed > 0)
          '$removed service order(s) no longer exist on the server and were removed.',
        if (syncedFailed > 0) '$syncedFailed remaining offline.',
      ];

      return ServiceOrdersSyncResult(
        success: syncedFailed == 0,
        syncedCount: syncedSuccess,
        failedCount: syncedFailed,
        removedCount: removed,
        message: parts.join(' '),
      );
    } catch (e) {
      syncError.value = e.toString();
      return ServiceOrdersSyncResult(
        success: false,
        message: 'Sync failed: $e',
      );
    } finally {
      isSyncing.value = false;
    }
  }
}

class ServiceOrdersSyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final int removedCount;
  final String message;

  const ServiceOrdersSyncResult({
    required this.success,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.removedCount = 0,
    required this.message,
  });
}
