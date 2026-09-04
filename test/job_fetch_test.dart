import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/network/network_exceptions.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/services/job_orders_api.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';

/// Canned server: answers `GET /JobOrders/status/{status}` from a map and
/// records every PUT.
class FakeJobOrdersApi implements JobOrdersApi {
  final Map<String, List<Map<String, dynamic>>> byStatus;
  final List<String> requestedStatuses = [];
  final List<(String, String?)> requestedAssigned = [];
  final List<(int, Map<String, dynamic>)> updates = [];
  bool filterByAssignedEmail = false;
  Object? failWith;

  /// Ids the server answers 404 for.
  final Set<int> deletedIds = {};

  /// What a GET by id returns after an update, keyed by id. Absent ids fall
  /// back to the last PUT body stamped with a server modified date.
  final Map<int, Map<String, dynamic>> serverCopies = {};

  FakeJobOrdersApi(this.byStatus);

  @override
  Future<List<Map<String, dynamic>>> fetchByStatus(String status) async {
    requestedStatuses.add(status);
    if (failWith != null) throw failWith!;
    return byStatus[status] ?? const [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchByStatusAssigned({
    required String status,
    String? assignedEmail,
  }) async {
    requestedStatuses.add(status);
    requestedAssigned.add((status, assignedEmail));
    if (failWith != null) throw failWith!;
    final list = byStatus[status] ?? const [];
    if (filterByAssignedEmail &&
        assignedEmail != null &&
        assignedEmail.isNotEmpty) {
      return list.where((item) {
        final email = item['assignedEmail']?.toString() ?? '';
        return email.toLowerCase() == assignedEmail.toLowerCase();
      }).toList();
    }
    return list;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchByStatusDate({
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    if (status != null) return fetchByStatus(status);
    if (failWith != null) throw failWith!;
    return [
      for (final list in byStatus.values) ...list,
    ];
  }

  @override
  Future<Map<String, dynamic>?> fetchById(int id) async {
    if (failWith != null) throw failWith!;
    if (deletedIds.contains(id)) return null;
    if (serverCopies.containsKey(id)) return serverCopies[id];
    final last = updates.lastWhere((u) => u.$1 == id,
        orElse: () => (id, <String, dynamic>{}));
    if (last.$2.isEmpty) return null;
    return {...last.$2, 'modifiedDate': '2026-09-02T12:00:00'};
  }

  @override
  Future<void> update(int id, Map<String, dynamic> body) async {
    if (failWith != null) throw failWith!;
    if (deletedIds.contains(id)) {
      throw ApiException(message: 'Not Found', statusCode: 404);
    }
    updates.add((id, body));
  }
}

Map<String, dynamic> _record(int id, String status, {String email = ''}) => {
      'id': id,
      'accountNo': 'SF-$id',
      'firstName': 'Sub',
      'lastName': '$id',
      'address': 'Lot $id',
      'status': status,
      'assignedEmail': email,
      'createdBy': null,
      'createdDate': null,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeJobOrdersApi api;
  late JobRepository repository;
  late JobsSignals signals;

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 100));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeJobOrdersApi({
      'Scheduled': [
        _record(1, 'Scheduled', email: 'me@switchfiber.ph'),
        _record(2, 'Scheduled'),
      ],
      'Activated': [
        _record(10, 'Activated', email: 'ME@switchfiber.ph'),
        _record(11, 'Activated', email: 'someone.else@switchfiber.ph'),
        _record(12, 'Activated'),
      ],
      'Completed': [
        _record(20, 'Completed', email: 'me@switchfiber.ph'),
        _record(21, 'Completed', email: 'other@switchfiber.ph'),
      ],
    });
    repository = JobRepository(db.jobOrdersDao, api: api);
    signals = JobsSignals(repository);
  });

  tearDown(() async {
    await signals.dispose();
    await db.close();
  });

  test('pulls through the status endpoint, never the whole table', () async {
    await repository.fetchRemoteJobs(technicianEmail: 'me@switchfiber.ph');
    expect(api.requestedStatuses, ['Scheduled', 'Activated', 'Completed']);
  });

  test('pulls through status-assigned passing assigned technician email',
      () async {
    await repository.fetchRemoteJobs(technicianEmail: 'me@switchfiber.ph');
    expect(api.requestedAssigned, [
      ('Scheduled', 'me@switchfiber.ph'),
      ('Activated', 'me@switchfiber.ph'),
      ('Completed', 'me@switchfiber.ph'),
    ]);
  });

  test('omits assignedEmail when technician email is not set or empty',
      () async {
    await repository.fetchRemoteJobs(technicianEmail: null);
    expect(api.requestedAssigned, [
      ('Scheduled', null),
      ('Activated', null),
      ('Completed', null),
    ]);

    api.requestedAssigned.clear();
    await repository.fetchRemoteJobs(technicianEmail: '  ');
    expect(api.requestedAssigned, [
      ('Scheduled', null),
      ('Activated', null),
      ('Completed', null),
    ]);
  });

  test(
      'server filtering by assigned email caches only technician assigned jobs',
      () async {
    api.filterByAssignedEmail = true;
    signals.setTechnicianEmail('me@switchfiber.ph');
    await signals.fetchRemote();
    await settle();

    // 1 (Scheduled), 10 (Activated), 20 (Completed) are assigned to me@switchfiber.ph
    expect(signals.allJobs.value.map((j) => j.id).toSet(), {1, 10, 20});
    expect(signals.scheduledCount.value, 1);
    expect(signals.historyJobs.value.map((j) => j.id).toSet(), {10, 20});
  });

  test(
      'caches every scheduled, activated, and completed job from status endpoints',
      () async {
    signals.setTechnicianEmail('me@switchfiber.ph');
    await signals.fetchRemote();
    await settle();

    expect(signals.allJobs.value.map((j) => j.id).toSet(),
        {1, 2, 10, 11, 12, 20, 21});
    expect(signals.scheduledCount.value, 2);
    expect(signals.historyJobs.value.map((j) => j.id).toSet(),
        {10, 11, 12, 20, 21});
  });

  test('caches all history jobs even without a known email', () async {
    await signals.fetchRemote();
    await settle();
    expect(signals.allJobs.value.map((j) => j.id).toSet(),
        {1, 2, 10, 11, 12, 20, 21});
  });

  test('drops synced rows the server stopped returning', () async {
    signals.setTechnicianEmail('me@switchfiber.ph');
    await signals.fetchRemote();
    await settle();
    expect(signals.allJobs.value.length, 7);

    // The office cancels job 2 and reassigns job 10 to someone else, and removes job 20.
    api.byStatus['Scheduled'] = [
      _record(1, 'Scheduled', email: 'me@switchfiber.ph'),
    ];
    api.byStatus['Activated'] = [
      _record(10, 'Activated', email: 'other@switchfiber.ph'),
    ];
    api.byStatus['Completed'] = [];
    await signals.fetchRemote();
    await settle();
    expect(signals.allJobs.value.map((j) => j.id).toSet(), {1, 10});
  });

  test('keeps a local edit that has not synced yet', () async {
    signals.setTechnicianEmail('me@switchfiber.ph');
    await signals.fetchRemote();
    await settle();

    // Activate job 2 while the PUT cannot get through.
    api.failWith = Exception('offline');
    await signals
        .activateJob(signals.allJobs.value.firstWhere((j) => j.id == 2));
    await settle();
    expect(signals.unsyncedCount.value, 1);

    // Server comes back but has already moved job 2 out of Scheduled.
    api.failWith = null;
    api.byStatus['Scheduled'] = [
      _record(1, 'Scheduled', email: 'me@switchfiber.ph'),
    ];
    await signals.fetchRemote();
    await settle();

    final job2 = signals.allJobs.value.firstWhere((j) => j.id == 2);
    expect(job2.isActivated, isTrue);
    expect(job2.isSynced, isFalse, reason: 'still waiting to be replayed');
  });

  test('a failed pull leaves the cache alone', () async {
    signals.setTechnicianEmail('me@switchfiber.ph');
    await signals.fetchRemote();
    await settle();

    api.failWith = Exception('offline');
    await signals.fetchRemote();
    await settle();
    expect(signals.allJobs.value.length, 7);
  });

  test('a refresh never overwrites an edit still waiting to sync', () async {
    signals.setTechnicianEmail('me@switchfiber.ph');
    await signals.fetchRemote();
    await settle();

    api.failWith = Exception('offline');
    await signals
        .activateJob(signals.allJobs.value.firstWhere((j) => j.id == 2));
    await settle();

    // Server reachable again for reads but still lists job 2 as Scheduled,
    // because the PUT has not gone through yet.
    api.failWith = null;
    await signals.fetchRemote();
    await settle();

    final job2 = signals.allJobs.value.firstWhere((j) => j.id == 2);
    expect(job2.isActivated, isTrue,
        reason: 'the older server copy must not clobber the local edit');
    expect(job2.isSynced, isFalse);
  });

  test('after a successful sync the row is replaced by the server copy',
      () async {
    signals.setTechnicianEmail('me@switchfiber.ph');
    await signals.fetchRemote();
    await settle();

    await signals
        .activateJob(signals.allJobs.value.firstWhere((j) => j.id == 2));
    await settle();

    final job2 = signals.allJobs.value.firstWhere((j) => j.id == 2);
    expect(job2.isSynced, isTrue);
    expect(job2.isActivated, isTrue);
    expect(job2.modifiedDate, DateTime(2026, 9, 2, 12),
        reason: 'the server\'s own copy, not the local guess, is cached');
  });

  test('an edit to a job the server deleted is dropped instead of retried',
      () async {
    signals.setTechnicianEmail('me@switchfiber.ph');
    await signals.fetchRemote();
    await settle();

    api.failWith = Exception('offline');
    await signals
        .activateJob(signals.allJobs.value.firstWhere((j) => j.id == 2));
    await settle();
    expect(signals.unsyncedCount.value, 1);

    api.failWith = null;
    api.deletedIds.add(2);
    final result = await repository.syncWorker.syncPendingJobs();
    await settle();

    expect(result.success, isTrue);
    expect(result.removedCount, 1);
    expect(result.message, contains('no longer exist'));
    expect(signals.allJobs.value.map((j) => j.id), isNot(contains(2)));
    expect(signals.unsyncedCount.value, 0);
    expect(repository.syncWorker.pendingCount.value, 0);
  });

  test('offline pull leaves the cache empty and does not seed test data',
      () async {
    api.failWith = Exception('offline');
    await signals.fetchRemote();
    await settle();
    expect(signals.allJobs.value.length, 0, reason: 'no demo seed');

    api.failWith = null;
    signals.setTechnicianEmail('me@switchfiber.ph');
    await signals.fetchRemote();
    await settle();
    expect(signals.allJobs.value.map((j) => j.id).toSet(),
        {1, 2, 10, 11, 12, 20, 21});
  });

  test('sync replays the whole record with the two-status wording', () async {
    signals.setTechnicianEmail('me@switchfiber.ph');
    await signals.fetchRemote();
    await settle();

    await signals
        .activateJob(signals.allJobs.value.firstWhere((j) => j.id == 2));
    await settle();

    final (id, body) = api.updates.single;
    expect(id, 2);
    expect(body['status'], JobStatus.activated.wireValue);
    expect(body['status'], 'Activated');
    expect(body['onsiteStatus'], 'Done');
    expect(body['assignedEmail'], 'me@switchfiber.ph');
    expect(body.containsKey('createdBy'), isTrue,
        reason: 'fields the app does not model still round-trip');
    expect(signals.allJobs.value.firstWhere((j) => j.id == 2).isSynced, isTrue);
  });
}
