import 'dart:async';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/job_orders_dao.dart';
import '../../../core/network/api_client.dart';
import '../models/job_order_model.dart';
import '../services/sync_worker.dart';

/// Repository coordinating Drift local SQLite caching and remote API operations.
class JobRepository {
  final JobOrdersDao _dao;
  final ApiClient _api = ApiClient.instance;
  late final SyncWorker syncWorker;

  JobRepository(this._dao) {
    syncWorker = SyncWorker(_dao);
  }

  /// Watch reactive stream of all jobs directly from Drift SQLite
  Stream<List<JobOrderDto>> watchJobs() {
    return _dao.watchAllJobs().map(
          (rows) => rows.map(JobOrderDto.fromDrift).toList(),
        );
  }

  /// Fetch remote job orders from backend and persist locally
  Future<void> fetchRemoteJobs({String? statusFilter}) async {
    try {
      final endpoint = statusFilter != null && statusFilter.isNotEmpty
          ? '/JobOrders/status/$statusFilter'
          : '/JobOrders';
      final response = await _api.get(endpoint);
      final rawList = response.data;

      if (rawList is List) {
        final companions = <JobOrdersCompanion>[];
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            final dto = JobOrderDto.fromJson(item);
            companions.add(dto.toCompanion(synced: true));
          }
        }

        if (companions.isNotEmpty) {
          await _dao.insertAllJobs(companions);
        }
      }
    } catch (_) {
      // Offline fallback: check if local database is empty, seed demo data if needed
      final count = (await _dao.getAllJobs()).length;
      if (count == 0) {
        await seedSampleJobs();
      }
    }
  }

  /// Grab a scheduled job: transitions status to In Progress for the technician.
  Future<void> grabScheduledJob(int id) async {
    await _dao.updateJobStatus(id, 'inprogress', isSynced: false);
    await _dao.updateFieldStatus(id, 'In-Progress', isSynced: false);
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

  /// Save completion report details locally and queue for sync
  Future<void> saveCompletionReport({
    required int id,
    required String status,
    required String onsiteStatus,
    required String onsiteRemarks,
    double? opticalPower,
    String? modemRouterSN,
    String? routerModel,
    String? boxReadingImage,
    String? routerReadingImage,
    String? clientSignature,
  }) async {
    await _dao.updateJobCompletion(
      id: id,
      status: status,
      onsiteStatus: onsiteStatus,
      onsiteRemarks: onsiteRemarks,
      opticalPower: opticalPower,
      modemRouterSN: modemRouterSN,
      routerModel: routerModel,
      boxReadingImage: boxReadingImage,
      routerReadingImage: routerReadingImage,
      clientSignature: clientSignature,
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
        status: 'inprogress',
        onsiteStatus: 'In-Progress',
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
        status: 'pending',
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
        status: 'completed',
        onsiteStatus: 'Completed',
        onsiteRemarks: 'Fiber termination verified. Rx power: -18.2 dBm.',
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
        status: 'activated',
        onsiteStatus: 'Completed',
        onsiteRemarks: 'Subscriber online. RADIUS account active.',
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
        status: 'scheduled',
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
        status: 'scheduled',
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
