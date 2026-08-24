import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/features/auth/models/user_model.dart';
import 'package:swithfiber_tech/features/auth/signals/auth_signals.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/reports/models/completion_report.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late JobRepository repository;
  late JobsSignals signals;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = JobRepository(db.jobOrdersDao);
    signals = JobsSignals(repository);
  });

  tearDown(() async {
    await signals.dispose();
    await db.close();
  });

  group('Drift SQLite & Signals Reactive State Tests', () {
    test('Seeding sample jobs inserts records and updates Signals stream', () async {
      await repository.seedSampleJobs();

      // Wait for Drift reactive stream to push to Signals
      await Future.delayed(const Duration(milliseconds: 100));

      expect(signals.allJobs.value.length, 4);
      expect(signals.totalCount.value, 4);
      // Seeded statuses: inprogress, pending, completed, activated.
      expect(signals.inProgressCount.value, 1);
      expect(signals.completedCount.value, 1);
      expect(signals.activatedCount.value, 1);
      expect(signals.unsyncedCount.value, 0);
    });

    test('Filter tab changes update filteredJobs computed signal', () async {
      await repository.seedSampleJobs();
      await Future.delayed(const Duration(milliseconds: 100));

      signals.setFilter('inprogress');
      expect(signals.filteredJobs.value.length, 1);
      expect(signals.filteredJobs.value.first.ticketNumber, 'SF-2026-0801');

      signals.setFilter('completed');
      expect(signals.filteredJobs.value.length, 1);
      expect(signals.filteredJobs.value.first.ticketNumber, 'SF-2026-0803');

      signals.setFilter('all');
      expect(signals.filteredJobs.value.length, 4);
    });

    test('Search query matches ticket number and customer name', () async {
      await repository.seedSampleJobs();
      await Future.delayed(const Duration(milliseconds: 100));

      signals.setSearch('Mendoza');
      expect(signals.filteredJobs.value.length, 1);
      expect(signals.filteredJobs.value.first.customerName, 'Rosario Mendoza');

      signals.setSearch('SF-2026-0804');
      expect(signals.filteredJobs.value.length, 1);
      expect(signals.filteredJobs.value.first.customerName, 'Eduardo Bautista');
    });

    test('Toggling job status updates Drift locally and sets isSynced = false', () async {
      await repository.seedSampleJobs();
      await Future.delayed(const Duration(milliseconds: 100));

      // Seeded as 'pending', which is not one of the three workflow statuses.
      final firstJob = signals.allJobs.value.firstWhere((j) => j.id == 102);
      expect(firstJob.jobStatus, isNull);

      await signals.advanceJobStatus(firstJob);
      await Future.delayed(const Duration(milliseconds: 100));

      final updatedJob = signals.allJobs.value.firstWhere((j) => j.id == 102);
      expect(updatedJob.jobStatus, JobStatus.inProgress);
      expect(updatedJob.status, 'In Progress');
      expect(updatedJob.isSynced, false);
      expect(signals.unsyncedCount.value, 1);
    });

    test('Optical quality threshold evaluation logic', () {
      final optimal = CompletionReportData(
        jobOrderId: 1,
        opticalPowerDbm: -19.5,
        modemRouterSN: 'HWTC123',
        routerModel: 'Huawei HG8145V5',
        napPort: 'Port 1',
        onsiteRemarks: 'Good',
      );
      expect(optimal.opticalQuality, OpticalReadingQuality.optimal);

      final marginal = CompletionReportData(
        jobOrderId: 2,
        opticalPowerDbm: -25.5,
        modemRouterSN: 'HWTC123',
        routerModel: 'Huawei HG8145V5',
        napPort: 'Port 1',
        onsiteRemarks: 'Marginal',
      );
      expect(marginal.opticalQuality, OpticalReadingQuality.marginal);

      final outOfSpec = CompletionReportData(
        jobOrderId: 3,
        opticalPowerDbm: -29.0,
        modemRouterSN: 'HWTC123',
        routerModel: 'Huawei HG8145V5',
        napPort: 'Port 1',
        onsiteRemarks: 'Out of spec',
      );
      expect(outOfSpec.opticalQuality, OpticalReadingQuality.outOfSpec);
    });

    test('AuthSignals reactive authentication lifecycle', () {
      final auth = AuthSignals.instance;
      expect(auth.isAuthenticated.value, false);

      auth.currentUser.value = UserModel(
        id: 101,
        username: 'tech_marcos',
        fname: 'Marcos',
        lname: 'Dela Cruz',
        email: 'marcos@switchfiber.ph',
      );

      expect(auth.isAuthenticated.value, true);
      expect(auth.currentUser.value?.fullName, 'Marcos Dela Cruz');

      auth.currentUser.value = null;
      expect(auth.isAuthenticated.value, false);
    });
  });
}
