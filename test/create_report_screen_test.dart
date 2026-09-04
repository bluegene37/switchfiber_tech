import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/core/utils/data_url.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/services/job_orders_api.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/reports/screens/create_report_screen.dart';
import 'package:swithfiber_tech/features/reports/signals/report_signals.dart';

/// Accepts every PUT so the background sync after submit completes quietly.
class _QuietApi implements JobOrdersApi {
  @override
  Future<List<Map<String, dynamic>>> fetchByStatus(String status) async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchByStatusDate({
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async =>
      [];

  @override
  Future<Map<String, dynamic>?> fetchById(int id) async => null;

  @override
  Future<void> update(int id, Map<String, dynamic> body) async {}
}

/// A real 1x1 PNG: the sign-off card renders an existing signature with
/// Image.memory, so the bytes have to decode.
final _signature = DataUrl.encode(
  Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, //
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, //
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, //
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]),
  mimeType: 'image/png',
);

JobOrderDto _job(int id) => JobOrderDto(
      id: id,
      ticketNumber: 'SF-$id',
      customerName: 'Subscriber $id',
      address: 'Lot $id',
      status: 'Scheduled',
      modemRouterSN: 'SN$id',
    );

void main() {
  late AppDatabase db;
  late JobsSignals jobsSignals;
  late ReportSignals reportSignals;

  tearDown(() async {
    await jobsSignals.dispose();
    await db.close();
  });

  testWidgets('submitting a report survives Drift re-emitting the job list',
      (tester) async {
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      jobsSignals =
          JobsSignals(JobRepository(db.jobOrdersDao, api: _QuietApi()));
      await db.jobOrdersDao
          .insertAllJobs([_job(1).toCompanion(), _job(2).toCompanion()]);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    reportSignals = ReportSignals()
      ..setJobOrder(jobsSignals.allJobs.value.firstWhere((j) => j.id == 1))
      ..setSignature(_signature);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: CreateReportScreen(
        jobsSignals: jobsSignals,
        reportSignals: reportSignals,
        pickImage: (_) async => null,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Save Completion Report'), findsOneWidget);

    // Submit through the signals in real async rather than tapping: the
    // form is long and the submit spinner animates forever, which makes a
    // scroll-and-tap flaky. What matters is what follows: the save makes
    // Drift re-emit the list while this screen is still mounted.
    await tester.runAsync(() async {
      await reportSignals.submitReport(jobsSignals.repository);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    // The dropdown used to assert here because the re-emitted list carried
    // new DTO instances that no longer equalled the selected one.
    expect(tester.takeException(), isNull);
    expect(reportSignals.submissionMessage.value, contains('saved'));

    final saved = jobsSignals.allJobs.value.firstWhere((j) => j.id == 1);
    expect(saved.isScheduled, isTrue,
        reason: 'report submit does not auto-update Job Order status');
    expect(saved.hasCompletedReport, isTrue);
    expect(saved.clientSignature, _signature);
  });

  testWidgets('the ONT model dropdown fits a narrow phone screen',
      (tester) async {
    // A 360pt-wide phone, the narrowest the crew carries.
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);

    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      jobsSignals =
          JobsSignals(JobRepository(db.jobOrdersDao, api: _QuietApi()));
      await db.jobOrdersDao.insertAllJobs([_job(1).toCompanion()]);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    reportSignals = ReportSignals()
      ..setJobOrder(jobsSignals.allJobs.value.first)
      // The widest option is what used to burst the row.
      ..routerModel.value = 'UT-KING UT-XP6486-S';

    // Overflow reports arrive as FlutterErrors during layout. Collect them
    // all, because takeException() only ever surfaces the first.
    final errors = <String>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) => errors.add(details.toString());
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: CreateReportScreen(
        jobsSignals: jobsSignals,
        reportSignals: reportSignals,
        pickImage: (_) async => null,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    FlutterError.onError = originalOnError;
    tester.takeException();

    // This screen has other long header rows that overflow at this width.
    // They predate this fix and are out of scope here, so look only at the
    // dropdown that was reported.
    final dropdownOverflows = errors
        .where((e) => e.contains('overflowed'))
        .where((e) => e.contains('DropdownButtonFormField'))
        .toList();

    expect(dropdownOverflows, isEmpty,
        reason: 'the ONT model dropdown sized itself to its widest menu item '
            'and burst the row it shares with the NAP port field');
  });
}
