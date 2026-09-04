import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/core/utils/data_url.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_order_detail_screen.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';

final _signature = DataUrl.encode(Uint8List.fromList([1, 2, 3]));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late JobsSignals jobsSignals;

  Future<void> pumpDetail(
    WidgetTester tester, {
    required JobOrderDto job,
    void Function(JobOrderDto job)? onOpenReport,
  }) async {
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      jobsSignals = JobsSignals(JobRepository(db.jobOrdersDao));
      await db.jobOrdersDao.insertOrUpdateJob(job.toCompanion());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: JobOrderDetailScreen(
        jobId: job.id,
        jobsSignals: jobsSignals,
        onOpenReport: onOpenReport,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  tearDown(() async {
    await jobsSignals.dispose();
    await db.close();
  });

  JobOrderDto job({String? signature, String? serial}) => JobOrderDto(
        id: 42,
        ticketNumber: 'SF-2026-0042',
        customerName: 'Subscriber Santos',
        address: 'Lot 42, Fiber Street',
        status: 'Scheduled',
        onsiteStatus: 'Scheduled',
        clientSignature: signature,
        modemRouterSN: serial,
      );

  ElevatedButton ctaButton(WidgetTester tester, String label) =>
      tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(ElevatedButton),
        ),
      );

  testWidgets(
      'primary CTA dynamically prompts to fill report when report is pending',
      (tester) async {
    var reportOpened = false;
    await pumpDetail(
      tester,
      job: job(),
      onOpenReport: (_) => reportOpened = true,
    );

    // Dynamic CTA progression: button is interactive and guides user to fill report
    expect(find.text('Fill Completion Report'), findsOneWidget);
    expect(find.text('Mark as Completed'), findsNothing);
    expect(ctaButton(tester, 'Fill Completion Report').onPressed, isNotNull,
        reason: 'a pending report must provide an active CTA to fill report');
    expect(find.textContaining('Completion report required'), findsOneWidget);

    await tester.tap(find.text('Fill Completion Report'));
    await tester.pump();
    expect(reportOpened, isTrue, reason: 'tapping CTA must open the report');
  });

  testWidgets('a signature without a serial still requires completing report',
      (tester) async {
    await pumpDetail(tester, job: job(signature: _signature));
    expect(find.text('Fill Completion Report'), findsOneWidget);
    expect(find.text('Mark as Completed'), findsNothing);
  });

  testWidgets('primary CTA switches to Mark as Completed once report is filed',
      (tester) async {
    await pumpDetail(
        tester, job: job(signature: _signature, serial: 'HWTC8829104'));

    expect(find.text('Mark as Completed'), findsOneWidget);
    expect(ctaButton(tester, 'Mark as Completed').onPressed, isNotNull,
        reason: 'a filed report must unlock Mark as Completed');
    expect(find.textContaining('Completion report filed'), findsOneWidget);
  });

  testWidgets('opening the report leaves this screen on the stack',
      (tester) async {
    // Regression: the detail screen used to pop itself before handing off to
    // the report, so backing out of the report landed on the job list.
    // It must be pushed, not the root route, or there is nothing to pop.
    final target = job();
    var opened = 0;

    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      jobsSignals = JobsSignals(JobRepository(db.jobOrdersDao));
      await db.jobOrdersDao.insertOrUpdateJob(target.toCompanion());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => JobOrderDetailScreen(
                    jobId: target.id,
                    jobsSignals: jobsSignals,
                    onOpenReport: (_) => opened++,
                  ),
                ),
              ),
              child: const Text('open job'),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    // Stand on the job list, then open the job: the real route stack.
    await tester.tap(find.text('open job'));
    await tester.pumpAndSettle();
    expect(find.byType(JobOrderDetailScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Field Completion Report'));
    await tester.pumpAndSettle();

    expect(opened, 1, reason: 'the report was requested');
    expect(find.byType(JobOrderDetailScreen), findsOneWidget,
        reason: 'the job detail screen must stay on the stack, so that '
            'backing out of the report returns here rather than to the '
            'job list');
  });
}
