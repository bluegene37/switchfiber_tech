import 'dart:async';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/job_orders_dao.dart';
import '../../../core/database/daos/sync_error_logs_dao.dart';
import '../../../core/services/photo_storage_service.dart';
import '../models/job_order_model.dart';
import '../services/job_orders_api.dart';
import '../services/sync_worker.dart';

/// Repository coordinating Drift local SQLite caching and remote API operations.
class JobRepository {
  final JobOrdersDao _dao;
  final JobOrdersApi _api;
  late final SyncWorker syncWorker;

  /// The on-phone record of refused pushes, so the Settings screen can show
  /// it without reaching for a database singleton that does not exist.
  final SyncErrorLogsDao? errorLog;

  JobRepository(this._dao, {JobOrdersApi? api, this.errorLog})
      : _api = api ?? DioJobOrdersApi() {
    syncWorker = SyncWorker(_dao, api: _api, errorLog: errorLog);
  }

  /// Watch reactive stream of all jobs directly from Drift SQLite
  Stream<List<JobOrderDto>> watchJobs() {
    return _dao.watchAllJobs().map(
          (rows) => rows.map(JobOrderDto.fromDrift).toList(),
        );
  }

  /// Pull the job orders the technician can act on or look back at, and
  /// bring the cache in line with them.
  ///
  /// Uses `GET /JobOrders/status-assigned` with `assignedEmail` when
  /// [technicianEmail] is provided so the server returns only the assigned
  /// jobs across `Scheduled`, `Activated`, and `Completed`.
  /// When [technicianEmail] is null or empty, `assignedEmail` is omitted
  /// to fetch all jobs in those statuses.
  ///
  /// After a successful pull, synced rows the server no longer returned (a job
  /// cancelled or reassigned by the office) are dropped. Rows with local edits
  /// still waiting to sync are never touched: neither overwritten by the
  /// server's older copy nor dropped. They are replaced by the server's
  /// version once the edit has been delivered (see [SyncWorker]).
  Future<void> fetchRemoteJobs({String? technicianEmail}) async {
    // Purge test/sample demo jobs (IDs 101-106) permanently
    await _dao.deleteSampleJobs();

    try {
      final email = technicianEmail?.trim();
      final assignedEmail = (email != null && email.isNotEmpty) ? email : null;

      final scheduled = await _api.fetchByStatusAssigned(
        status: JobStatus.scheduled.wireValue,
        assignedEmail: assignedEmail,
      );
      final activated = await _api.fetchByStatusAssigned(
        status: JobStatus.activated.wireValue,
        assignedEmail: assignedEmail,
      );
      final completed = await _api.fetchByStatusAssigned(
        status: JobStatus.completed.wireValue,
        assignedEmail: assignedEmail,
      );

      final pending = await _dao.getUnsyncedIds();
      final companions = <JobOrdersCompanion>[];
      final keep = <int>{};

      void take(JobOrderDto dto) {
        keep.add(dto.id);
        // A pending local edit is newer than anything the server has.
        if (pending.contains(dto.id)) return;
        companions.add(dto.toCompanion(synced: true));
      }

      for (final item in scheduled) {
        take(JobOrderDto.fromJson(item));
      }
      for (final item in activated) {
        take(JobOrderDto.fromJson(item));
      }
      for (final item in completed) {
        take(JobOrderDto.fromJson(item));
      }

      if (companions.isNotEmpty) {
        await _dao.insertAllJobs(companions);
      }
      await _dao.deleteSyncedJobsNotIn(keep);
    } catch (_) {
      // Offline fallback: do not re-seed test data
    }
  }

  /// Activate a job: Scheduled -> Activated, the only transition in the field.
  ///
  /// Complete a job: Scheduled -> Completed.
  ///
  /// The completing technician's email is stamped on the record so the job
  /// appears in their history, and the install date is set if it was not
  /// already. Queued for sync like every other edit.
  /// Returns the sync attempt's outcome so the caller can tell the technician
  /// whether the office actually has the completion, rather than reporting
  /// success off the local write alone.
  Future<SyncResult> completeJob(int id, {String? technicianEmail}) async {
    final existing = await _dao.getJobById(id);
    final email = technicianEmail?.trim();
    await _dao.completeJob(
      id,
      assignedEmail: (email == null || email.isEmpty) ? null : email,
      installedAt: existing?.dateInstalled ?? DateTime.now(),
      isSynced: false,
    );
    await syncWorker.refreshPendingCount();
    return syncWorker.syncPendingJobs();
  }

  /// Push whatever is pending, then throw the local cache away and take the
  /// server as the truth.
  ///
  /// This is the override behind Settings > Force Full Sync. A normal refresh
  /// protects unsynced edits; this one does not, which is why the screen asks
  /// for the technician's password first. Pending edits are pushed before the
  /// wipe so a completion that can go through does, and the returned result
  /// says whether any were refused and therefore lost.
  Future<SyncResult> forceRefreshFromServer({String? technicianEmail}) async {
    final pushed = await syncWorker.syncPendingJobs();
    await _dao.clearAllJobs();
    await fetchRemoteJobs(technicianEmail: technicianEmail);
    await syncWorker.refreshPendingCount();
    return pushed;
  }

  /// Activate a job: Scheduled -> Activated.
  Future<void> activateJob(int id, {String? technicianEmail}) async {
    final existing = await _dao.getJobById(id);
    final email = technicianEmail?.trim();
    await _dao.activateJob(
      id,
      assignedEmail: (email == null || email.isEmpty) ? null : email,
      installedAt: existing?.dateInstalled ?? DateTime.now(),
      isSynced: false,
    );
    await syncWorker.refreshPendingCount();
    unawaited(syncWorker.syncPendingJobs());
  }

  /// Update the technician's on-site status locally and queue it for sync.
  Future<void> updateFieldStatus(int id, String onsiteStatus) async {
    await _dao.updateFieldStatus(id, onsiteStatus, isSynced: false);
    await syncWorker.refreshPendingCount();
    unawaited(syncWorker.syncPendingJobs());
  }

  /// Update job status locally and trigger offline sync worker
  Future<void> updateJobStatus(int id, String newStatus) async {
    // 1. Instant local optimistic update in Drift DB (isSynced = false)
    await _dao.updateJobStatus(id, newStatus, isSynced: false);
    await syncWorker.refreshPendingCount();

    // 2. Proactively trigger background sync
    unawaited(syncWorker.syncPendingJobs());
  }

  /// Save completion report details locally and queue for sync.
  /// Does not change the job order status unless [status] is explicitly provided.
  Future<void> saveCompletionReport({
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
  }) async {
    final photoStorage = PhotoStorageService.instance;
    final savedBox = await photoStorage.savePhotoLocally(boxReadingImage,
        tag: 'box_reading', entityId: id);
    final savedRouter = await photoStorage.savePhotoLocally(routerReadingImage,
        tag: 'router_reading', entityId: id);
    final savedSig = await photoStorage.savePhotoLocally(clientSignature,
        tag: 'signature', entityId: id);
    final savedSetup = await photoStorage.savePhotoLocally(setupImage,
        tag: 'setup', entityId: id);
    final savedSpeed = await photoStorage.savePhotoLocally(speedtestImage,
        tag: 'speedtest', entityId: id);
    final savedPort = await photoStorage.savePhotoLocally(portLabelImage,
        tag: 'port_label', entityId: id);
    final savedContract = await photoStorage.savePhotoLocally(
        signedContractImage,
        tag: 'signed_contract',
        entityId: id);
    final savedHouse = await photoStorage.savePhotoLocally(houseFront,
        tag: 'house_front', entityId: id);

    await _dao.updateJobCompletion(
      id: id,
      status: status,
      onsiteStatus: onsiteStatus,
      onsiteRemarks: onsiteRemarks,
      opticalPower: opticalPower,
      modemRouterSN: modemRouterSN,
      routerModel: routerModel,
      nap: nap,
      boxReadingImage: savedBox,
      routerReadingImage: savedRouter,
      clientSignature: savedSig,
      setupImage: savedSetup,
      speedtestImage: savedSpeed,
      portLabelImage: savedPort,
      signedContractImage: savedContract,
      houseFront: savedHouse,
      assignedEmail: assignedEmail,
      isSynced: false,
    );

    await syncWorker.refreshPendingCount();
    unawaited(syncWorker.syncPendingJobs());
  }

  /// Seed realistic demo fiber installation and repair job orders
  Future<void> seedSampleJobs() async {
    final now = DateTime.now();
    final sampleJobs = [
      JobOrderDto(
        id: 101,
        ticketNumber: 'SF-2026-0801',
        customerName: 'Rosario Mendoza',
        contactNumber: '+63 917 555 1234',
        address: 'Blk 12 Lot 4, Redwood St., Villa Verde',
        barangay: 'San Roque',
        city: 'Antipolo',
        planName: 'Fiber Blast 100 Mbps',
        planId: 2,
        status: 'Scheduled',
        onsiteStatus: 'Scheduled',
        onsiteRemarks: 'Running drop cable from NAP 04 to subscriber home.',
        opticalPower: -19.5,
        modemRouterSN: 'HWTC8829104',
        routerModel: 'Huawei HG8145V5',
        lcpId: 1,
        napId: 4,
        portId: 'Port 2',
        isSynced: true,
        updatedAt: now,
      ),
      JobOrderDto(
        id: 102,
        ticketNumber: 'SF-2026-0802',
        customerName: 'Danilo Santos',
        contactNumber: '+63 928 444 8899',
        address: 'Unit 5B, Skyline Tower, Emerald Ave.',
        barangay: 'San Antonio',
        city: 'Pasig',
        planName: 'Fiber Giga 200 Mbps',
        planId: 3,
        status: 'Scheduled',
        onsiteStatus: 'Dispatched',
        onsiteRemarks: 'Scheduled morning installation dispatch.',
        lcpId: 2,
        napId: 8,
        portId: 'Port 6',
        isSynced: true,
        updatedAt: now,
      ),
      JobOrderDto(
        id: 103,
        ticketNumber: 'SF-2026-0803',
        customerName: 'Maria Elena Cruz',
        contactNumber: '+63 919 333 4567',
        address: '45 Jasmin St., Phase 2, Greenpark Village',
        barangay: 'Manggahan',
        city: 'Pasig',
        planName: 'Fiber Basic 50 Mbps',
        planId: 1,
        status: 'Activated',
        onsiteStatus: 'Done',
        onsiteRemarks: 'Fiber termination verified. Rx power: -18.2 dBm.',
        assignedEmail: 'technician@switchfiber.ph',
        opticalPower: -18.2,
        modemRouterSN: 'ZTE8839001',
        routerModel: 'ZTE F670L',
        lcpId: 1,
        napId: 3,
        portId: 'Port 1',
        dateInstalled: now.subtract(const Duration(days: 1)),
        isSynced: true,
        updatedAt: now,
      ),
      JobOrderDto(
        id: 104,
        ticketNumber: 'SF-2026-0804',
        customerName: 'Eduardo Bautista',
        contactNumber: '+63 908 222 1100',
        address: '77 Katipunan Ave., Loyola Heights',
        barangay: 'Loyola Heights',
        city: 'Quezon City',
        planName: 'Fiber Blast 100 Mbps',
        planId: 2,
        status: 'Activated',
        onsiteStatus: 'Done',
        onsiteRemarks: 'Subscriber online. RADIUS account active.',
        assignedEmail: 'technician@switchfiber.ph',
        opticalPower: -17.8,
        modemRouterSN: 'HWTC4490123',
        routerModel: 'Huawei EG8145V5',
        lcpId: 3,
        napId: 12,
        portId: 'Port 5',
        dateInstalled: now.subtract(const Duration(days: 2)),
        isSynced: true,
        updatedAt: now,
      ),
      JobOrderDto(
        id: 105,
        ticketNumber: 'SF-2026-0805',
        customerName: 'Jasmine Alcantara',
        contactNumber: '+63 918 777 3322',
        address: 'Blk 4 Lot 19, Camella Homes, Manila East Rd',
        barangay: 'San Juan',
        city: 'Taytay',
        planName: 'Fiber Blast 100 Mbps',
        planId: 2,
        status: 'Scheduled',
        onsiteStatus: 'Scheduled',
        onsiteRemarks: 'New installation scheduled. Near Guard House Gate 2.',
        lcpId: 1,
        napId: 2,
        portId: 'Port 3',
        isSynced: true,
        updatedAt: now,
      ),
      JobOrderDto(
        id: 106,
        ticketNumber: 'SF-2026-0806',
        customerName: 'Rafael De Silva',
        contactNumber: '+63 920 111 9988',
        address: 'Unit 1204, Mega Plaza, Ortigas Ave.',
        barangay: 'San Antonio',
        city: 'Pasig',
        planName: 'Fiber Giga 200 Mbps',
        planId: 3,
        status: 'Scheduled',
        onsiteStatus: 'Scheduled',
        onsiteRemarks:
            'Scheduled afternoon dispatch. Customer requested PM slot.',
        lcpId: 2,
        napId: 5,
        portId: 'Port 7',
        isSynced: true,
        updatedAt: now,
      ),
    ];

    final companions =
        sampleJobs.map((j) => j.toCompanion(synced: true)).toList();
    await _dao.insertAllJobs(companions);
  }
}
