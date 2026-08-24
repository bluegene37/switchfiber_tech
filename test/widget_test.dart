import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/features/auth/signals/auth_signals.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/widgets/status_badge.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';
import 'package:swithfiber_tech/features/reports/widgets/optical_power_gauge.dart';
import 'package:swithfiber_tech/main.dart';

void main() {
  testWidgets('StatusBadge renders appropriate labels and colors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusBadge(status: JobStatus.inProgress),
              StatusBadge(status: JobStatus.completed),
              StatusBadge(status: JobStatus.activated),
              StatusBadge(status: null, rawStatus: 'Confirmed'),
              StatusBadge(
                status: null,
                rawStatus: 'Confirmed',
                siteException: SiteException.failed,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Activated'), findsOneWidget);
    // A status outside the three is shown as the backend words it.
    expect(find.text('Confirmed'), findsNWidgets(2));
    // A failed visit stays visible alongside it.
    expect(find.text('Failed'), findsOneWidget);
  });

  testWidgets('OpticalPowerGauge displays dBm reading and PASS indicator', (WidgetTester tester) async {
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

  testWidgets('SplashScreen renders official logo branding and title', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repository = JobRepository(db.jobOrdersDao);
    final jobsSignals = JobsSignals(repository);
    final lcpNapSignals = LcpNapSignals(LcpNapRepository(LcpNapLocationsDao(db)));
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

  testWidgets('SwitchFiberTechApp directly renders LoginScreen when showSplash is false', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repository = JobRepository(db.jobOrdersDao);
    final jobsSignals = JobsSignals(repository);
    final lcpNapSignals = LcpNapSignals(LcpNapRepository(LcpNapLocationsDao(db)));
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
