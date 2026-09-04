import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/database/daos/job_orders_dao.dart';
import '../../../core/network/network_exceptions.dart';
import '../models/job_order_model.dart';
import 'job_orders_api.dart';

/// Background worker that synchronizes offline-edited jobs with the backend API.
class SyncWorker {
  final JobOrdersDao _dao;
  final JobOrdersApi _api;

  SyncWorker(this._dao, {JobOrdersApi? api}) : _api = api ?? DioJobOrdersApi();

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
    int removed = 0;

    try {
      final unsynced = await _dao.getUnsyncedJobs();
      pendingCount.value = unsynced.length;

      if (unsynced.isEmpty) {
        lastSyncTime.value = DateTime.now();
        return SyncResult(
            success: true, syncedCount: 0, message: 'All jobs are up to date.');
      }

      for (final rawJob in unsynced) {
        final dto = JobOrderDto.fromDrift(rawJob);
        try {
          // Replay the full record with the technician's edits applied.
          await _api.update(dto.id, await dto.toApiJsonAsync());
          await _replaceWithServerCopy(dto.id);
          syncedSuccess++;
        } on ApiException catch (err) {
          if (err.statusCode == 404) {
            // The office deleted this job while the edit was pending. There
            // is nothing on the server to update and nothing to replace it
            // with, so the local copy goes too rather than retrying forever.
            await _dao.deleteJob(dto.id);
            removed++;
          } else {
            syncedFailed++;
          }
        } catch (_) {
          syncedFailed++;
          // Keep isSynced = false so it will retry on next sync cycle
        }
      }

      final remaining = await _dao.countUnsynced();
      pendingCount.value = remaining;
      lastSyncTime.value = DateTime.now();

      final parts = <String>[
        if (syncedSuccess > 0) 'Synced $syncedSuccess job order(s).',
        if (removed > 0)
          '$removed job order(s) no longer exist on the server and were removed.',
        if (syncedFailed > 0) '$syncedFailed remaining offline.',
      ];

      return SyncResult(
        success: syncedFailed == 0,
        syncedCount: syncedSuccess,
        failedCount: syncedFailed,
        removedCount: removed,
        message: parts.join(' '),
      );
    } catch (e) {
      syncError.value = e.toString();
      return SyncResult(success: false, message: 'Sync failed: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  /// After the server accepted an edit, swap the local row for the server's
  /// own copy (its modified date, anything the office changed meanwhile) so
  /// the cache holds what actually exists. If that read fails the row is
  /// simply marked synced and the next full pull replaces it.
  Future<void> _replaceWithServerCopy(int id) async {
    try {
      final fresh = await _api.fetchById(id);
      if (fresh != null) {
        await _dao.insertOrUpdateJob(
            JobOrderDto.fromJson(fresh).toCompanion(synced: true));
        return;
      }
    } catch (_) {
      // Fall through: the update itself succeeded.
    }
    await _dao.markAsSynced(id);
  }
}

class SyncResult {
  final bool success;
  final int syncedCount;
  final int failedCount;

  /// Pending edits whose job the server no longer has; dropped locally.
  final int removedCount;
  final String message;

  SyncResult({
    required this.success,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.removedCount = 0,
    required this.message,
  });
}
