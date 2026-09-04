import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/reports/screens/create_report_screen.dart';
import 'package:swithfiber_tech/features/reports/signals/report_signals.dart';

/// Height of the simulated phone navigation bar, in logical pixels.
const double _navBar = 48;
const double _dpr = 3.0;
const double _screenHeight = 2400 / _dpr;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the submit button clears the phone navigation bar',
      (tester) async {
    tester.view.devicePixelRatio = _dpr;
    tester.view.physicalSize = const Size(1500, 2400);
    tester.view.padding = const FakeViewPadding(bottom: _navBar * _dpr);
    tester.view.viewPadding = const FakeViewPadding(bottom: _navBar * _dpr);
    addTearDown(tester.view.reset);

    late final AppDatabase db;
    late final JobsSignals jobsSignals;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      jobsSignals = JobsSignals(JobRepository(db.jobOrdersDao));
      await db.jobOrdersDao.insertOrUpdateJob(JobOrderDto(
        id: 1,
        ticketNumber: 'SF-2026-0001',
        customerName: 'Subscriber Santos',
        address: 'Lot 1, Fiber Street',
        status: 'Scheduled',
      ).toCompanion());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    final rep = ReportSignals()..setJobOrder(jobsSignals.allJobs.value.first);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: CreateReportScreen(
        jobsSignals: jobsSignals,
        reportSignals: rep,
        pickImage: (_) async => null,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    tester.takeException();

    // Scroll to the very end of the form, where the submit button lives.
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -6000));
    // Let the fling settle, so the form comes to rest at its true bottom.
    await tester.pumpAndSettle();

    final button = find.text('Save Completion Report');
    expect(button, findsOneWidget);

    final rect = tester.getRect(button);
    final sc = tester
        .widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
    // The scroll must reserve at least the navigation bar's height below its
    // last child. The form's own trailing gap used to cover most, but not
    // all, of a real bar, which is why only part of the button was hidden.
    expect(sc.padding!.resolve(TextDirection.ltr).bottom,
        greaterThanOrEqualTo(_navBar),
        reason: 'the form must pad past the phone navigation bar');

    expect(rect.bottom, lessThanOrEqualTo(_screenHeight - _navBar),
        reason: 'the submit button must come to rest above the navigation '
            'bar, not underneath it');

    await tester.runAsync(() async => db.close());
  });
}
