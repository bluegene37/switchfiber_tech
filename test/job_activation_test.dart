import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/reports/signals/report_signals.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late JobRepository repository;
  late JobsSignals signals;

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 100));

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = JobRepository(db.jobOrdersDao);
    signals = JobsSignals(repository);
    await db.jobOrdersDao.insertAllJobs([
      JobOrderDto(
        id: 1,
        ticketNumber: 'SF-1',
        customerName: 'Juan',
        address: 'Lot 1',
        status: 'Scheduled',
        assignedEmail: 'office.assigned@switchfiber.ph',
      ).toCompanion(),
      JobOrderDto(
        id: 2,
        ticketNumber: 'SF-2',
        customerName: 'Maria',
        address: 'Lot 2',
        status: 'Confirmed',
        dateInstalled: DateTime(2026, 8, 1),
      ).toCompanion(),
    ]);
    await settle();
  });

  tearDown(() async {
    await signals.dispose();
    await db.close();
  });

  test('activating moves a job out of the queue and into the history',
      () async {
    signals.setTechnicianEmail('tech@switchfiber.ph');
    expect(signals.scheduledCount.value, 2);
    expect(signals.historyJobs.value, isEmpty);

    final job = signals.allJobs.value.firstWhere((j) => j.id == 1);
    await signals.activateJob(job);
    await settle();

    final updated = signals.allJobs.value.firstWhere((j) => j.id == 1);
    expect(updated.status, 'Activated');
    expect(updated.isActivated, isTrue);
    expect(updated.onsiteStatus, 'Done');
    expect(updated.isSynced, isFalse, reason: 'queued for sync');
    expect(updated.dateInstalled, isNotNull);

    expect(signals.scheduledCount.value, 1);
    expect(signals.filteredJobs.value.map((j) => j.id), [2]);
    expect(signals.historyJobs.value.map((j) => j.id), [1]);
  });

  test('activation records the technician who did it', () async {
    signals.setTechnicianEmail('tech@switchfiber.ph');
    await signals
        .activateJob(signals.allJobs.value.firstWhere((j) => j.id == 1));
    await settle();

    final updated = signals.allJobs.value.firstWhere((j) => j.id == 1);
    expect(updated.assignedEmail, 'tech@switchfiber.ph');
    expect(updated.toApiJson()['assignedEmail'], 'tech@switchfiber.ph',
        reason: 'the stamp must reach the server');
  });

  test('an existing install date is kept on activation', () async {
    signals.setTechnicianEmail('tech@switchfiber.ph');
    await signals
        .activateJob(signals.allJobs.value.firstWhere((j) => j.id == 2));
    await settle();

    final updated = signals.allJobs.value.firstWhere((j) => j.id == 2);
    expect(updated.dateInstalled, DateTime(2026, 8, 1));
  });

  test('without a technician email the assignment is left untouched', () async {
    await signals
        .activateJob(signals.allJobs.value.firstWhere((j) => j.id == 1));
    await settle();

    final updated = signals.allJobs.value.firstWhere((j) => j.id == 1);
    expect(updated.isActivated, isTrue);
    expect(updated.assignedEmail, 'office.assigned@switchfiber.ph');
  });

  test('activating an activated job is a no-op', () async {
    signals.setTechnicianEmail('tech@switchfiber.ph');
    final job = signals.allJobs.value.firstWhere((j) => j.id == 1);
    await signals.activateJob(job);
    await settle();
    final once = signals.allJobs.value.firstWhere((j) => j.id == 1);

    signals.setTechnicianEmail('someone.else@switchfiber.ph');
    await signals.activateJob(once);
    await settle();
    final twice = signals.allJobs.value.firstWhere((j) => j.id == 1);
    expect(twice.assignedEmail, 'tech@switchfiber.ph');
  });

  test('submitting a completion report activates the job too', () async {
    final report = ReportSignals();
    report.setJobOrder(signals.allJobs.value.firstWhere((j) => j.id == 1));
    final ok = await report.submitReport(repository,
        technicianEmail: 'tech@switchfiber.ph');
    await settle();

    expect(ok, isTrue);
    final updated = signals.allJobs.value.firstWhere((j) => j.id == 1);
    expect(updated.isActivated, isTrue);
    expect(updated.onsiteStatus, 'Done');
    expect(updated.assignedEmail, 'tech@switchfiber.ph');
  });
}
