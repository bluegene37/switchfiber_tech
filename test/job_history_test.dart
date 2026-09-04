import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';

/// A job order as the live API returns it, trimmed to the fields that matter
/// for the technician's history.
Map<String, dynamic> liveRecord({
  required int id,
  required String assignedEmail,
  String status = 'Activated',
  String onsiteStatus = 'Done',
  String? city,
  String? dateInstalled,
  String? modifiedDate,
}) =>
    {
      'id': id,
      'accountNo': 'SF-$id',
      'firstName': 'Sub',
      'lastName': '$id',
      'address': 'Lot $id',
      'city': city,
      'status': status,
      'onsiteStatus': onsiteStatus,
      'assignedEmail': assignedEmail,
      'dateInstalled': dateInstalled,
      'modifiedDate': modifiedDate,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JobOrderDto assignment', () {
    test('reads assignedEmail and modifiedDate from the API record', () {
      final dto = JobOrderDto.fromJson(liveRecord(
        id: 1,
        assignedEmail: 'Tech@SwitchFiber.ph',
        modifiedDate: '2026-08-20T09:15:00',
      ));
      expect(dto.assignedEmail, 'Tech@SwitchFiber.ph');
      expect(dto.modifiedDate, DateTime(2026, 8, 20, 9, 15));
    });

    test('assignment match ignores case and surrounding whitespace', () {
      final dto = JobOrderDto.fromJson(
          liveRecord(id: 1, assignedEmail: '  Tech@SwitchFiber.ph '));
      expect(dto.isAssignedTo('tech@switchfiber.ph'), isTrue);
      expect(dto.isAssignedTo('other@switchfiber.ph'), isFalse);
    });

    test('an empty or missing email never matches an unassigned job', () {
      final unassigned =
          JobOrderDto.fromJson(liveRecord(id: 1, assignedEmail: ''));
      expect(unassigned.isAssignedTo(''), isFalse);
      expect(unassigned.isAssignedTo(null), isFalse);
      expect(unassigned.isAssignedTo('tech@switchfiber.ph'), isFalse);
    });

    test('assignedEmail survives the Drift round trip', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final dto = JobOrderDto.fromJson(liveRecord(
        id: 7,
        assignedEmail: 'tech@switchfiber.ph',
        modifiedDate: '2026-08-20T09:15:00',
      ));
      await db.jobOrdersDao.insertOrUpdateJob(dto.toCompanion());
      final row = await db.jobOrdersDao.getJobById(7);
      final back = JobOrderDto.fromDrift(row!);
      expect(back.assignedEmail, 'tech@switchfiber.ph');
      expect(back.modifiedDate, DateTime(2026, 8, 20, 9, 15));
    });

    test('historyDate prefers install date, then server modification', () {
      final installed = JobOrderDto.fromJson(liveRecord(
        id: 1,
        assignedEmail: 'a@b.c',
        dateInstalled: '2026-08-01T08:00:00',
        modifiedDate: '2026-08-25T08:00:00',
      ));
      expect(installed.historyDate, DateTime(2026, 8, 1, 8));

      final modifiedOnly = JobOrderDto.fromJson(liveRecord(
        id: 2,
        assignedEmail: 'a@b.c',
        modifiedDate: '2026-08-25T08:00:00',
      ));
      expect(modifiedOnly.historyDate, DateTime(2026, 8, 25, 8));
    });
  });

  group('JobsSignals technician history', () {
    late AppDatabase db;
    late JobRepository repository;
    late JobsSignals signals;

    // A fixed "today": Wednesday 2 September 2026.
    final now = DateTime(2026, 9, 2, 14, 30);

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = JobRepository(db.jobOrdersDao);
      signals = JobsSignals(repository, clock: () => now);

      final rows = [
        // Today.
        liveRecord(
          id: 1,
          assignedEmail: 'tech@switchfiber.ph',
          city: 'Antipolo',
          dateInstalled: '2026-09-02T09:00:00',
        ),
        // Earlier this week (Monday), case-insensitive email.
        liveRecord(
          id: 2,
          assignedEmail: 'TECH@switchfiber.ph',
          city: 'Pasig',
          dateInstalled: '2026-08-31T10:00:00',
        ),
        // Last month. Legacy 'Completed' counts as activated.
        liveRecord(
          id: 3,
          assignedEmail: 'tech@switchfiber.ph',
          status: 'Completed',
          city: 'Antipolo',
          dateInstalled: '2026-08-20T10:00:00',
        ),
        // Still scheduled: not history.
        liveRecord(
          id: 4,
          assignedEmail: 'tech@switchfiber.ph',
          status: 'Scheduled',
          onsiteStatus: '',
          modifiedDate: '2026-09-01T10:00:00',
        ),
        // Someone else's activated job.
        liveRecord(
          id: 5,
          assignedEmail: 'someone.else@switchfiber.ph',
          dateInstalled: '2026-09-01T10:00:00',
        ),
        // Activated but unassigned, and no date at all.
        liveRecord(id: 6, assignedEmail: ''),
        // Mine, activated, no date known.
        liveRecord(id: 7, assignedEmail: 'tech@switchfiber.ph'),
      ];
      await db.jobOrdersDao.insertAllJobs([
        for (final r in rows) JobOrderDto.fromJson(r).toCompanion(),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() async {
      await signals.dispose();
      await db.close();
    });

    test('contains all downloaded history jobs (Activated and Completed), excluding Scheduled', () {
      expect(signals.allJobs.value.length, 7);
      expect(signals.historyJobs.value.map((j) => j.id).toSet(),
          {1, 2, 3, 5, 6, 7});
      expect(signals.historyTotalCount.value, 6);
    });

    test('lists all history jobs (Activated and Completed), newest first, undated last', () {
      expect(signals.historyJobs.value.map((j) => j.id), [1, 5, 2, 3, 7, 6]);
      expect(signals.historyTotalCount.value, 6);
      expect(signals.historyActivatedCount.value, 5);
      expect(signals.historyCompletedCount.value, 1);
      // Wed 2 Sep: today (2 Sep), 1 Sep, and 31 Aug fall in this week
      expect(signals.historyThisWeekCount.value, 3);
      // Only today (2 Sep) and 1 Sep fall in this month (Sep 2026)
      expect(signals.historyThisMonthCount.value, 2);
    });

    test('status filter narrows history by Activated and Completed', () {
      signals.setHistoryStatus(HistoryStatusFilter.activated);
      expect(signals.historyJobs.value.map((j) => j.id), [1, 5, 2, 7, 6]);

      signals.setHistoryStatus(HistoryStatusFilter.completed);
      expect(signals.historyJobs.value.map((j) => j.id), [3]);

      signals.setHistoryStatus(HistoryStatusFilter.all);
      expect(signals.historyJobs.value.map((j) => j.id), [1, 5, 2, 3, 7, 6]);
    });

    test('a scheduled job never appears in the history', () {
      expect(signals.historyJobs.value.map((j) => j.id), isNot(contains(4)));
    });

    test('date window narrows the history', () {
      signals.setHistoryRange(HistoryRange.today);
      expect(signals.historyJobs.value.map((j) => j.id), [1]);

      signals.setHistoryRange(HistoryRange.week);
      expect(signals.historyJobs.value.map((j) => j.id), [1, 5, 2]);

      signals.setHistoryRange(HistoryRange.month);
      expect(signals.historyJobs.value.map((j) => j.id), [1, 5]);

      signals.setHistoryRange(HistoryRange.custom,
          start: DateTime(2026, 8, 15), end: DateTime(2026, 8, 31));
      expect(signals.historyJobs.value.map((j) => j.id), [2, 3],
          reason: 'the end date is inclusive');

      signals.setHistoryRange(HistoryRange.all);
      expect(signals.historyJobs.value.length, 6);
    });

    test('city filter is offered from the history and applied to it', () {
      expect(signals.historyCities.value, ['Antipolo', 'Pasig']);

      signals.setHistoryCity('Pasig');
      expect(signals.historyJobs.value.map((j) => j.id), [2]);

      signals.setHistoryCity('Antipolo');
      expect(signals.historyJobs.value.map((j) => j.id), [1, 3]);

      signals.setHistoryCity(null);
      expect(signals.historyJobs.value.length, 6);
    });

    test('search matches ticket, customer and address within the history', () {
      signals.setHistorySearch('SF-2');
      expect(signals.historyJobs.value.map((j) => j.id), [2]);

      signals.setHistorySearch('SF-3');
      expect(signals.historyJobs.value.map((j) => j.id), [3]);

      signals.setHistorySearch('');
      expect(signals.historyJobs.value.length, 6);
    });

    test('search query matches ticket, customer, address and city', () {
      signals.setHistorySearch('SF-3');
      expect(signals.historyJobs.value.map((j) => j.id), [3]);

      signals.setHistorySearch('Sub 2');
      expect(signals.historyJobs.value.map((j) => j.id), [2]);

      signals.setHistorySearch('Lot 1');
      expect(signals.historyJobs.value.map((j) => j.id), [1]);

      signals.setHistorySearch('pasig');
      expect(signals.historyJobs.value.map((j) => j.id), [2]);

      signals.setHistorySearch('');
      expect(signals.historyJobs.value.length, 6);
    });

    test('clearHistoryFilters resets every filter to default', () {
      signals.setHistoryStatus(HistoryStatusFilter.completed);
      signals.setHistoryRange(HistoryRange.today);
      signals.setHistoryCity('Antipolo');
      signals.setHistorySearch('SF-1');
      expect(signals.historyJobs.value, isEmpty);

      signals.clearHistoryFilters();
      expect(signals.historyStatus.value, HistoryStatusFilter.all);
      expect(signals.historyRange.value, HistoryRange.all);
      expect(signals.historyCity.value, isNull);
      expect(signals.historySearch.value, isEmpty);
      expect(signals.historyJobs.value.length, 6);
    });
  });
}
