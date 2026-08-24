import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/database/daos/job_orders_dao.dart';
import '../../../core/network/api_client.dart';
import '../models/job_order_model.dart';

/// Background worker that synchronizes offline-edited jobs with the backend API.
class SyncWorker {
  final JobOrdersDao _dao;
  final ApiClient _api = ApiClient.instance;

  SyncWorker(this._dao);

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
  Future<SyncResult> syncPendingJobs() async {
    if (isSyncing.value) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    isSyncing.value = true;
    syncError.value = null;

    int syncedSuccess = 0;
    int syncedFailed = 0;

    try {
      final unsynced = await _dao.getUnsyncedJobs();
      pendingCount.value = unsynced.length;

      if (unsynced.isEmpty) {
        lastSyncTime.value = DateTime.now();
        return SyncResult(success: true, syncedCount: 0, message: 'All jobs are up to date.');
      }

      for (final rawJob in unsynced) {
        final dto = JobOrderDto.fromDrift(rawJob);
        try {
          // Attempt API PUT update
          await _api.put(
            '/JobOrders/${dto.id}',
            data: dto.toApiJson(),
          );

          // Mark as successfully synced in local Drift SQLite
          await _dao.markAsSynced(dto.id);
          syncedSuccess++;
        } catch (err) {
          syncedFailed++;
          // Keep isSynced = false so it will retry on next sync cycle
        }
      }

      final remaining = await _dao.countUnsynced();
      pendingCount.value = remaining;
      lastSyncTime.value = DateTime.now();

      final message = syncedFailed == 0
          ? 'Successfully synced $syncedSuccess job order(s).'
          : 'Synced $syncedSuccess jobs. $syncedFailed remaining offline.';

      return SyncResult(
        success: syncedFailed == 0,
        syncedCount: syncedSuccess,
        failedCount: syncedFailed,
        message: message,
      );
    } catch (e) {
      syncError.value = e.toString();
      return SyncResult(success: false, message: 'Sync failed: $e');
    } finally {
      isSyncing.value = false;
    }
  }
}

class SyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;
  final String message;

  SyncResult({
    required this.success,
    this.syncedCount = 0,
    this.failedCount = 0,
    required this.message,
  });
}
