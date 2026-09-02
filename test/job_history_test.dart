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
  String status = 'Confirmed',
  String onsiteStatus = 'Done',
  String? dateInstalled,
  String? modifiedDate,
}) =>
    {
      'id': id,
      'accountNo': 'SF-$id',
      'firstName': 'Sub',
      'lastName': '$id',
      'address': 'Lot $id',
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

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = JobRepository(db.jobOrdersDao);
      signals = JobsSignals(repository);

      final rows = [
        liveRecord(
          id: 1,
          assignedEmail: 'tech@switchfiber.ph',
          status: 'Completed',
          dateInstalled: '2026-08-10T10:00:00',
        ),
        liveRecord(
          id: 2,
          assignedEmail: 'TECH@switchfiber.ph',
          status: 'Activated',
          dateInstalled: '2026-08-20T10:00:00',
        ),
        liveRecord(
          id: 3,
          assignedEmail: 'tech@switchfiber.ph',
          status: 'In Progress',
          onsiteStatus: 'In Progress',
          modifiedDate: '2026-08-30T10:00:00',
        ),
        liveRecord(
          id: 4,
          assignedEmail: 'tech@switchfiber.ph',
          status: 'Confirmed',
          onsiteStatus: 'Failed',
          modifiedDate: '2026-08-05T10:00:00',
        ),
        liveRecord(
          id: 5,
          assignedEmail: 'someone.else@switchfiber.ph',
          status: 'Completed',
          dateInstalled: '2026-08-29T10:00:00',
        ),
        liveRecord(id: 6, assignedEmail: '', status: 'Completed'),
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
      expect(signals.allJobs.value.length, 6);
      expect(signals.historyJobs.value, isEmpty);
      expect(signals.historyTotalCount.value, 0);
    });

    test('lists only jobs assigned to the technician, newest first', () {
      signals.setTechnicianEmail('tech@switchfiber.ph');
      final ids = signals.historyJobs.value.map((j) => j.id).toList();
      expect(ids, [3, 2, 1, 4]);
      expect(signals.historyTotalCount.value, 4);
      expect(signals.historyCompletedCount.value, 1);
      expect(signals.historyActivatedCount.value, 1);
      expect(signals.historyInProgressCount.value, 1);
      expect(signals.historyExceptionCount.value, 1);
    });

    test('status filter narrows the history', () {
      signals.setTechnicianEmail('tech@switchfiber.ph');

      signals.setHistoryFilter(HistoryFilter.completed);
      expect(signals.historyJobs.value.map((j) => j.id), [1]);

      signals.setHistoryFilter(HistoryFilter.activated);
      expect(signals.historyJobs.value.map((j) => j.id), [2]);

      signals.setHistoryFilter(HistoryFilter.inProgress);
      expect(signals.historyJobs.value.map((j) => j.id), [3]);

      signals.setHistoryFilter(HistoryFilter.needsAttention);
      expect(signals.historyJobs.value.map((j) => j.id), [4]);

      signals.setHistoryFilter(HistoryFilter.all);
      expect(signals.historyJobs.value.length, 4);
    });

    test('search matches ticket, customer and address within the history', () {
      signals.setTechnicianEmail('tech@switchfiber.ph');

      signals.setHistorySearch('SF-2');
      expect(signals.historyJobs.value.map((j) => j.id), [2]);

      signals.setHistorySearch('Sub 4');
      expect(signals.historyJobs.value.map((j) => j.id), [4]);

      // Another technician's job never leaks in through search.
      signals.setHistorySearch('SF-5');
      expect(signals.historyJobs.value, isEmpty);
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
