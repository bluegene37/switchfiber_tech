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

    test('is empty until the technician email is known', () {
      expect(signals.allJobs.value.length, 7);
      expect(signals.historyJobs.value, isEmpty);
      expect(signals.historyTotalCount.value, 0);
    });

    test('lists only my activated jobs, newest first, undated last', () {
      signals.setTechnicianEmail('tech@switchfiber.ph');
      expect(signals.historyJobs.value.map((j) => j.id), [1, 2, 3, 7]);
      expect(signals.historyTotalCount.value, 4);
      // Wed 2 Sep: today and Mon 31 Aug fall in this week, but only today
      // falls in this month.
      expect(signals.historyThisWeekCount.value, 2);
      expect(signals.historyThisMonthCount.value, 1);
    });

    test('a scheduled job never appears in the history', () {
      signals.setTechnicianEmail('tech@switchfiber.ph');
      expect(signals.historyJobs.value.map((j) => j.id), isNot(contains(4)));
    });

    test('date window narrows the history', () {
      signals.setTechnicianEmail('tech@switchfiber.ph');

      signals.setHistoryRange(HistoryRange.today);
      expect(signals.historyJobs.value.map((j) => j.id), [1]);

      signals.setHistoryRange(HistoryRange.week);
      expect(signals.historyJobs.value.map((j) => j.id), [1, 2]);

      signals.setHistoryRange(HistoryRange.month);
      expect(signals.historyJobs.value.map((j) => j.id), [1]);

      signals.setHistoryRange(HistoryRange.custom,
          start: DateTime(2026, 8, 15), end: DateTime(2026, 8, 31));
      expect(signals.historyJobs.value.map((j) => j.id), [2, 3],
          reason: 'the end date is inclusive');

      signals.setHistoryRange(HistoryRange.all);
      expect(signals.historyJobs.value.length, 4);
    });

    test('city filter is offered from the history and applied to it', () {
      signals.setTechnicianEmail('tech@switchfiber.ph');
      expect(signals.historyCities.value, ['Antipolo', 'Pasig']);

      signals.setHistoryCity('Pasig');
      expect(signals.historyJobs.value.map((j) => j.id), [2]);

      signals.setHistoryCity('Antipolo');
      expect(signals.historyJobs.value.map((j) => j.id), [1, 3]);

      signals.setHistoryCity(null);
      expect(signals.historyJobs.value.length, 4);
    });

    test('search matches ticket, customer and address within the history', () {
      signals.setTechnicianEmail('tech@switchfiber.ph');

      signals.setHistorySearch('SF-2');
      expect(signals.historyJobs.value.map((j) => j.id), [2]);

      signals.setHistorySearch('Sub 3');
      expect(signals.historyJobs.value.map((j) => j.id), [3]);

      // Another technician's job never leaks in through search.
      signals.setHistorySearch('SF-5');
      expect(signals.historyJobs.value, isEmpty);
    });

    test('filters combine and clear together', () {
      signals.setTechnicianEmail('tech@switchfiber.ph');
      signals.setHistoryRange(HistoryRange.week);
      signals.setHistoryCity('Antipolo');
      signals.setHistorySearch('SF-1');
      expect(signals.historyJobs.value.map((j) => j.id), [1]);

      signals.clearHistoryFilters();
      expect(signals.historyRange.value, HistoryRange.all);
      expect(signals.historyCity.value, isNull);
      expect(signals.historySearch.value, isEmpty);
      expect(signals.historyJobs.value.length, 4);
    });

    test('switching technician swaps the history', () {
      signals.setTechnicianEmail('tech@switchfiber.ph');
      expect(signals.historyJobs.value.length, 4);

      signals.setTechnicianEmail('someone.else@switchfiber.ph');
      expect(signals.historyJobs.value.map((j) => j.id), [5]);

      signals.setTechnicianEmail(null);
      expect(signals.historyJobs.value, isEmpty);
    });
  });
}
