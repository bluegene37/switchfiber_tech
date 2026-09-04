import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/sync_error_logs_dao.dart';
import 'package:swithfiber_tech/core/network/network_exceptions.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/services/job_orders_api.dart';
import 'package:swithfiber_tech/features/jobs/services/sync_worker.dart';

/// A refused push must leave a trace. The app keeps the edit and retries,
/// which is deliberate, but silence turned "needs to sync" into a dead end.
class _RefusingApi implements JobOrdersApi {
  final int? statusCode;
  final String message;
  int? lastPayloadBytes;

  _RefusingApi({this.statusCode, this.message = 'Payload too large'});

  @override
  Future<void> update(int id, Map<String, dynamic> body) async {
    if (statusCode == null) throw StateError(message);
    throw ApiException(message: message, statusCode: statusCode);
  }

  @override
  Future<Map<String, dynamic>?> fetchById(int id) async => null;

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late AppDatabase db;
  late SyncErrorLogsDao logs;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    logs = SyncErrorLogsDao(db);
  });

  tearDown(() => db.close());

  Future<void> seedPendingJob() => db.jobOrdersDao.insertOrUpdateJob(
        JobOrderDto(
          id: 1,
          ticketNumber: 'SF-2026-0001',
          customerName: 'Ana Reyes',
          address: 'Lot 1, Fiber Street',
          status: 'Completed',
          onsiteStatus: 'Done',
          isSynced: false,
          updatedAt: DateTime.now(),
        ).toCompanion(synced: false),
      );

  test('a refused push records the status code and the server message',
      () async {
    await seedPendingJob();
    final worker = SyncWorker(db.jobOrdersDao,
        api: _RefusingApi(statusCode: 413, message: 'Request body too large'),
        errorLog: logs);

    final result = await worker.syncPendingJobs();

    expect(result.success, isFalse);
    expect(result.failures, hasLength(1));
    expect(result.failures.single, contains('413'));

    final entries = await logs.getAll();
    expect(entries, hasLength(1),
        reason: 'the refusal must survive past the snackbar that showed it');
    expect(entries.single.statusCode, 413);
    expect(entries.single.message, contains('too large'));
    expect(entries.single.reference, 'SF-2026-0001',
        reason: 'a log line has to be readable without a database lookup');
    expect(entries.single.resolved, isFalse);
  });

  test('the payload size is recorded, since size is the usual suspect',
      () async {
    await seedPendingJob();
    final worker = SyncWorker(db.jobOrdersDao,
        api: _RefusingApi(statusCode: 413), errorLog: logs);

    await worker.syncPendingJobs();

    final entry = (await logs.getAll()).single;
    expect(entry.payloadBytes, greaterThan(0),
        reason: 'without the size, a 413 cannot be told from a validation bug');
  });

  test('a request that never got an answer is logged with no status code',
      () async {
    await seedPendingJob();
    final worker = SyncWorker(db.jobOrdersDao,
        api: _RefusingApi(message: 'Connection reset'), errorLog: logs);

    await worker.syncPendingJobs();

    final entry = (await logs.getAll()).single;
    expect(entry.statusCode, isNull,
        reason: 'no signal is a different failure from a server refusal');
    expect(entry.message, contains('Connection reset'));
  });

  test('the edit is kept and stays pending, not dropped', () async {
    await seedPendingJob();
    final worker = SyncWorker(db.jobOrdersDao,
        api: _RefusingApi(statusCode: 500), errorLog: logs);

    await worker.syncPendingJobs();

    final still = await db.jobOrdersDao.getJobById(1);
    expect(still, isNotNull,
        reason: 'a refused push must never lose the technician\'s work');
    expect(still!.isSynced, isFalse, reason: 'it has to retry');
  });

  test('a later success marks the record resolved', () async {
    await logs.log(
      entityType: 'JOB_ORDER',
      entityId: 1,
      reference: 'SF-2026-0001',
      operation: 'completed',
      statusCode: 500,
      message: 'Server error',
      payloadBytes: 1024,
    );

    await logs.markResolved('JOB_ORDER', 1);

    expect((await logs.getAll()).single.resolved, isTrue);
    expect(await logs.countUnresolved(), 0,
        reason: 'a badge must not keep counting a problem that went away');
  });

  test('sync errors do not accumulate without bound', () async {
    for (var i = 0; i < SyncErrorLogsDao.maxEntries + 25; i++) {
      await logs.log(
        entityType: 'JOB_ORDER',
        entityId: i,
        reference: 'SF-$i',
        operation: 'completed',
        statusCode: 500,
        message: 'Server error $i',
      );
    }
    expect((await logs.getAll()).length,
        lessThanOrEqualTo(SyncErrorLogsDao.maxEntries));
  });
}
