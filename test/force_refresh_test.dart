import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/sync_error_logs_dao.dart';
import 'package:swithfiber_tech/core/network/network_exceptions.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/services/job_orders_api.dart';

/// Settings > Force Full Sync is the override: push what is pending, then
/// throw the local cache away and take the server's copy. These pin the
/// order of those steps, because the wrong order silently loses a
/// technician's completion.
///
/// The password prompt in front of it re-authenticates through the live
/// AuthSignals singleton and is exercised on the device, not here.
class _ServerApi implements JobOrdersApi {
  /// What the server holds, by id. A PUT replaces the entry.
  final Map<int, Map<String, dynamic>> records = {};
  final List<int> putIds = [];

  /// Ids the server refuses to update.
  final Set<int> refuse = {};

  _ServerApi(List<Map<String, dynamic>> initial) {
    for (final r in initial) {
      records[r['id'] as int] = r;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchByStatusAssigned({
    required String status,
    String? assignedEmail,
  }) async =>
      records.values.where((r) => r['status'] == status).toList();

  @override
  Future<Map<String, dynamic>?> fetchById(int id) async => records[id];

  @override
  Future<void> update(int id, Map<String, dynamic> body) async {
    putIds.add(id);
    if (refuse.contains(id)) {
      throw ApiException(message: 'Server error', statusCode: 500);
    }
    records[id] = {'id': id, ...body};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Map<String, dynamic> _record(int id, String status) => {
      'id': id,
      'accountNo': 'SF-$id',
      'firstName': 'Sub',
      'lastName': '$id',
      'address': 'Lot $id',
      'status': status,
      'onsiteStatus': '',
    };

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<JobRepository> repoWith(_ServerApi api) async {
    final repo = JobRepository(db.jobOrdersDao,
        api: api, errorLog: SyncErrorLogsDao(db));
    await repo.fetchRemoteJobs(technicianEmail: 'me@switchfiber.ph');
    return repo;
  }

  test('a pending completion is pushed before the cache is wiped', () async {
    final api = _ServerApi([_record(1, 'Scheduled')]);
    final repo = await repoWith(api);

    // Complete offline: local says Completed, server still says Scheduled.
    api.refuse.add(1);
    await repo.completeJob(1, technicianEmail: 'me@switchfiber.ph');
    api.refuse.remove(1);
    expect(api.records[1]!['status'], 'Scheduled',
        reason: 'precondition: the completion has not reached the server');

    final result = await repo.forceRefreshFromServer(technicianEmail: 'me@switchfiber.ph');

    expect(result.failedCount, 0);
    expect(api.putIds, contains(1), reason: 'the pending edit was pushed');
    expect(api.records[1]!['status'], 'Completed',
        reason: 'the server now holds the completion');
    final local = await db.jobOrdersDao.getJobById(1);
    expect(local!.status, 'Completed');
    expect(local.isSynced, isTrue, reason: 'nothing left pending');
  });

  test('the local cache is replaced by the server copy', () async {
    final api = _ServerApi([_record(1, 'Scheduled'), _record(2, 'Scheduled')]);
    final repo = await repoWith(api);
    expect((await db.jobOrdersDao.getAllJobs()).length, 2);

    // The office deletes job 2 and renames job 1 while the phone is away.
    api.records.remove(2);
    api.records[1] = {..._record(1, 'Scheduled'), 'firstName': 'Renamed'};

    await repo.forceRefreshFromServer(technicianEmail: 'me@switchfiber.ph');

    final all = await db.jobOrdersDao.getAllJobs();
    expect(all.map((j) => j.id).toList(), [1],
        reason: 'a job the server no longer has is gone locally too');
    expect(all.single.customerName, contains('Renamed'),
        reason: 'the server copy wins');
  });

  test('a refused pending edit is lost, and the result says so', () async {
    final api = _ServerApi([_record(1, 'Scheduled')]);
    final repo = await repoWith(api);

    api.refuse.add(1);
    await repo.completeJob(1, technicianEmail: 'me@switchfiber.ph');

    final result = await repo.forceRefreshFromServer(technicianEmail: 'me@switchfiber.ph');

    expect(result.failedCount, 1,
        reason: 'the caller must be able to warn that work was discarded');
    final local = await db.jobOrdersDao.getJobById(1);
    expect(local!.status, 'Scheduled',
        reason: 'the override took the server copy, as the technician was '
            'warned it would');
    expect(local.isSynced, isTrue);
    expect(await repo.syncWorker.refreshPendingCount(), 0);
    // Two attempts were refused: the one completeJob fired, and the push the
    // override made before wiping. Each is its own entry, and neither is
    // resolved, because the record never went through.
    expect(await repo.errorLog!.countUnresolved(), 2,
        reason: 'every refusal stays on record after the wipe');
  });
}
