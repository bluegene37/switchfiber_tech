import 'dart:convert';

import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/database/daos/job_orders_dao.dart';
import '../../../core/database/daos/sync_error_logs_dao.dart';
import '../../../core/network/network_exceptions.dart';
import '../../../core/network/request_snapshot.dart';
import '../models/job_order_model.dart';
import 'job_orders_api.dart';

/// Background worker that synchronizes offline-edited jobs with the backend API.
class SyncWorker {
  final JobOrdersDao _dao;
  final JobOrdersApi _api;

  /// Where refused pushes are recorded. Optional so tests that only care
  /// about sync behaviour can leave it out.
  final SyncErrorLogsDao? _errorLog;

  SyncWorker(this._dao, {JobOrdersApi? api, SyncErrorLogsDao? errorLog})
      : _api = api ?? DioJobOrdersApi(),
        _errorLog = errorLog;

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
    // One line per job the server refused, carrying the status code and the
    // server's own message.
    final failures = <String>[];

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
        // Measured before the request so a refusal can be read against the
        // size that caused it: a completion inlines every photo as Base64
        // and is orders of magnitude larger than an activation.
        var payloadBytes = 0;
        // Kept outside the try so a refusal can be logged with the exact
        // body that was refused.
        Map<String, dynamic>? body;
        try {
          // Replay the full record with the technician's edits applied.
          body = await dto.toApiJsonAsync();
          payloadBytes = utf8.encode(json.encode(body)).length;
          await _api.update(dto.id, body);
          await _replaceWithServerCopy(dto.id);
          await _errorLog?.markResolved('JOB_ORDER', dto.id);
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
            // Keep what the server actually said. Swallowing it left jobs
            // stuck on "needs to sync" with no way, in the app or in a bug
            // report, to find out why.
            failures.add('${dto.ticketNumber}: '
                'HTTP ${err.statusCode ?? "?"} ${err.message}');
            await _record(dto, err.statusCode, err.message, payloadBytes,
                body: body,
                method: err.requestMethod,
                url: err.requestUrl,
                response: err.details);
          }
        } catch (e) {
          syncedFailed++;
          failures.add('${dto.ticketNumber}: $e');
          await _record(dto, null, e.toString(), payloadBytes, body: body);
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

      syncError.value = failures.isEmpty ? null : failures.join('\n');

      return SyncResult(
        success: syncedFailed == 0,
        syncedCount: syncedSuccess,
        failedCount: syncedFailed,
        removedCount: removed,
        message: parts.join(' '),
        failures: List.unmodifiable(failures),
      );
    } catch (e) {
      syncError.value = e.toString();
      return SyncResult(success: false, message: 'Sync failed: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  /// Writes one refused push to the on-phone log. Never lets a logging
  /// problem break the sync it is reporting on.
  ///
  /// The request is stored alongside so the log entry is something the
  /// backend team can replay, not just a status code. [method] and [url]
  /// fall back to the documented endpoint when the failure happened before
  /// Dio built the request.
  Future<void> _record(JobOrderDto dto, int? statusCode, String message,
      int payloadBytes,
      {Map<String, dynamic>? body,
      String? method,
      String? url,
      dynamic response}) async {
    try {
      await _errorLog?.log(
        entityType: 'JOB_ORDER',
        entityId: dto.id,
        reference: dto.ticketNumber,
        operation: dto.status.toLowerCase(),
        statusCode: statusCode,
        message: message,
        payloadBytes: payloadBytes,
        requestMethod: method ?? 'PUT',
        requestUrl: url ?? '/api/JobOrders/${dto.id}',
        requestBody: body == null ? null : RequestSnapshot.body(body),
        responseBody: RequestSnapshot.response(response),
      );
    } catch (_) {}
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

  /// One line per refused job: its ticket, the HTTP status and what the
  /// server said. Empty when nothing failed.
  final List<String> failures;

  SyncResult({
    required this.success,
    this.syncedCount = 0,
    this.failedCount = 0,
    this.removedCount = 0,
    required this.message,
    this.failures = const [],
  });
}
