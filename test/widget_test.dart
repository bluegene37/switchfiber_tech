import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/features/auth/signals/auth_signals.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_order_detail_screen.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_orders_screen.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/widgets/status_badge.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/reports/widgets/optical_power_gauge.dart';
import 'package:swithfiber_tech/main.dart';

void main() {
  testWidgets(
      'StatusBadge renders appropriate labels and colors for scheduled and workflow states',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusBadge(status: JobStatus.scheduled),
              StatusBadge(status: JobStatus.inProgress),
              StatusBadge(status: JobStatus.completed),
              StatusBadge(status: JobStatus.activated),
              // An unrecognised backend status shows verbatim rather than
              // being mislabelled: a technician seeing 'Cancelled' is better
              // served than one told the job is 'Scheduled'.
              StatusBadge(status: null, rawStatus: 'Cancelled'),
              // Nothing to show at all falls back to Scheduled.
              StatusBadge(status: null, rawStatus: ''),
              StatusBadge(
                status: null,
                rawStatus: 'Cancelled',
                siteException: SiteException.failed,
              ),
            ],
          ),
        ),
      ),
    );

    // One from JobStatus.scheduled, one from the empty-rawStatus fallback.
    expect(find.text('Scheduled'), findsNWidgets(2));
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Activated'), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
    // Twice: the plain badge, and the one that also carries the Failed chip.
    expect(find.text('Cancelled'), findsNWidgets(2),
        reason: 'a status the app does not model must reach the technician '
            'in the backend\'s own words');
  });

  testWidgets('OpticalPowerGauge displays dBm reading and PASS indicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OpticalPowerGauge(opticalPowerDbm: -18.5),
        ),
      ),
    );

    expect(find.text('-18.5 dBm'), findsOneWidget);
    expect(find.text('Optimal Signal (PASS)'), findsOneWidget);
  });

  testWidgets(
      'JobOrderDetailScreen renders properly in light and dark mode without RenderFlex crashes',
      (WidgetTester tester) async {
    // Everything touching the database must be built and awaited inside
    // runAsync. testWidgets installs a fake-async zone whose timers only
    // advance when the tester pumps, so a real `await` deadlocks - and a
    // stream subscription created in that zone never delivers, which would
    // leave allJobs empty even after seeding.
    late final AppDatabase db;
    late final JobRepository repository;
    late final JobsSignals jobsSignals;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = JobRepository(db.jobOrdersDao);
      jobsSignals = JobsSignals(repository);
      await repository.seedSampleJobs();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    final sampleJob = jobsSignals.allJobs.value.first;

    // Test in Light Theme
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: JobOrderDetailScreen(
          jobId: sampleJob.id,
          jobsSignals: jobsSignals,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(sampleJob.ticketNumber), findsOneWidget);
    expect(find.text(sampleJob.customerName), findsOneWidget);
    expect(find.text('Workflow Stage'), findsOneWidget);
    expect(find.text('Subscriber & Location'), findsOneWidget);
    expect(find.text('Plant & Hardware Allocation'), findsOneWidget);

    // The report button sits in the last section of a ListView, which only
    // mounts children near the viewport - so reach it the way a technician
    // does rather than asserting on an element that was never built.
    final reportButton = find.text('Fill / Update Completion Report');
    await tester.scrollUntilVisible(reportButton, 300,
        scrollable: find.byType(Scrollable).first);
    expect(reportButton, findsOneWidget);

    // Test in Dark Theme
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: JobOrderDetailScreen(
          jobId: sampleJob.id,
          jobsSignals: jobsSignals,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The list keeps the offset it was scrolled to above, so come back to the
    // top before asserting on the header.
    await tester.dragUntilVisible(
      find.text(sampleJob.customerName),
      find.byType(Scrollable).first,
      const Offset(0, 300),
    );

    expect(find.text(sampleJob.ticketNumber), findsOneWidget);
    expect(find.text(sampleJob.customerName), findsOneWidget);

    await tester.runAsync(() async {
      await jobsSignals.dispose();
      await db.close();
    });
  });

  testWidgets('JobOrdersScreen opens JobOrderDetailScreen when card is tapped',
      (WidgetTester tester) async {
    // See the note above: database work and its stream subscription must be
    // created and awaited outside the fake-async zone testWidgets installs.
    late final AppDatabase db;
    late final JobRepository repository;
    late final JobsSignals jobsSignals;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = JobRepository(db.jobOrdersDao);
      jobsSignals = JobsSignals(repository);
      await repository.seedSampleJobs();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    await tester.pumpWidget(
      MaterialApp(
        home: JobOrdersScreen(
          jobsSignals: jobsSignals,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstJob = jobsSignals.allJobs.value.first;
    expect(find.text(firstJob.customerName), findsOneWidget);

    // Tap on the job card
    await tester.tap(find.text(firstJob.customerName));
    await tester.pumpAndSettle();

    // Verify detailed screen opened
    expect(find.text('Subscriber & Location'), findsOneWidget);

    // Last section of a lazy ListView: scroll the detail route's own list,
    // not the job list still mounted underneath it.
    final reportButton = find.text('Fill / Update Completion Report');
    await tester.scrollUntilVisible(
      reportButton,
      300,
      scrollable: find
          .descendant(
            of: find.byType(JobOrderDetailScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(reportButton, findsOneWidget);

    await tester.runAsync(() async {
      await jobsSignals.dispose();
      await db.close();
    });
  });

  testWidgets('SplashScreen renders official logo branding and title',
      (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repository = JobRepository(db.jobOrdersDao);
    final jobsSignals = JobsSignals(repository);
    final lcpNapSignals =
        LcpNapSignals(LcpNapRepository(LcpNapLocationsDao(db)));
    final authSignals = AuthSignals.instance;
    authSignals.currentUser.value = null;

    await tester.pumpWidget(
      SwitchFiberTechApp(
        authSignals: authSignals,
        jobsSignals: jobsSignals,
        lcpNapSignals: lcpNapSignals,
        showSplash: true,
      ),
    );

    expect(find.text('Switch Fiber'), findsOneWidget);
    expect(find.text('Field Technician Terminal'), findsOneWidget);

    // Pump past the splash delay to complete navigation
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Technician Sign In'), findsOneWidget);

    await tester.runAsync(() async {
      await lcpNapSignals.dispose();
      await jobsSignals.dispose();
      await db.close();
    });
  });

  testWidgets(
      'SwitchFiberTechApp directly renders LoginScreen when showSplash is false',
      (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repository = JobRepository(db.jobOrdersDao);
    final jobsSignals = JobsSignals(repository);
    final lcpNapSignals =
        LcpNapSignals(LcpNapRepository(LcpNapLocationsDao(db)));
    final authSignals = AuthSignals.instance;
    authSignals.currentUser.value = null;

    await tester.pumpWidget(
      SwitchFiberTechApp(
        authSignals: authSignals,
        jobsSignals: jobsSignals,
        lcpNapSignals: lcpNapSignals,
        showSplash: false,
      ),
    );

    expect(find.text('Switch Fiber'), findsOneWidget);
    expect(find.text('Technician Sign In'), findsOneWidget);

    await tester.runAsync(() async {
      await lcpNapSignals.dispose();
      await jobsSignals.dispose();
      await db.close();
    });
  });
}
