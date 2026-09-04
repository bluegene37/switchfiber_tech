import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/core/utils/data_url.dart';
import 'package:swithfiber_tech/features/catalogs/models/catalog_model.dart';
import 'package:swithfiber_tech/features/catalogs/services/catalog_service.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/services/job_orders_api.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/reports/screens/create_report_screen.dart';
import 'package:swithfiber_tech/features/reports/signals/report_signals.dart';

class _QuietApi implements JobOrdersApi {
  @override
  Future<List<Map<String, dynamic>>> fetchByStatus(String status) async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchByStatusAssigned({
    required String status,
    String? assignedEmail,
  }) async =>
      [];

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

final _signature = DataUrl.encode(
  Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]),
  mimeType: 'image/png',
);

JobOrderDto _job(int id, {String? nap}) => JobOrderDto(
      id: id,
      ticketNumber: 'SF-$id',
      customerName: 'Subscriber $id',
      address: 'Lot $id',
      status: 'Scheduled',
      modemRouterSN: 'SN$id',
      nap: nap,
    );

void main() {
  group('NAP API Model & Catalog', () {
    test('NapDto parses API json with id, name, description', () {
      final json = {
        'id': 2,
        'name': 'NAP 001',
        'description': 'NAP 001 Description',
        'createdByUserId': 1,
        'createdDate': '2026-06-01T00:00:00',
      };
      final dto = NapDto.fromJson(json);
      expect(dto.id, 2);
      expect(dto.name, 'NAP 001');
      expect(dto.description, 'NAP 001 Description');
      expect(dto.createdByUserId, 1);
    });

    test('CatalogService provides fallback NAPs matching live API', () async {
      final catalog = CatalogService();
      final naps = await catalog.getNaps();
      expect(naps.isNotEmpty, true);
      expect(naps.any((n) => n.name == 'NAP 001'), true);
      expect(naps.any((n) => n.name == 'test nap 1'), true);
    });
  });

  group('JobOrderDto NAP serialization', () {
    test('JobOrderDto preserves nap in API json and Drift companion', () {
      final job = _job(1, nap: 'NAP 004');
      final companion = job.toCompanion();
      expect(companion.nap.value, 'NAP 004');

      final edits = job.toApiJson();
      expect(edits['nap'], 'NAP 004');
      expect(edits['napId'], 'NAP 004');
    });

    test('JobOrderDto parses nap and napId from API response', () {
      final json = {
        'id': 10,
        'ticketNumber': 'SF-10',
        'customerName': 'Test',
        'address': 'Address',
        'status': 'Scheduled',
        'nap': 'NAP 007',
        'napId': '0',
      };
      final dto = JobOrderDto.fromJson(json);
      expect(dto.nap, 'NAP 007');
    });
  });

  group('CreateReportScreen NAP Dropdown & Filtering', () {
    late AppDatabase db;
    late JobsSignals jobsSignals;
    late ReportSignals reportSignals;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      jobsSignals =
          JobsSignals(JobRepository(db.jobOrdersDao, api: _QuietApi()));
      await db.jobOrdersDao.insertAllJobs([_job(1).toCompanion()]);
      reportSignals = ReportSignals()
        ..setJobOrder(_job(1))
        ..setSignature(_signature);
    });

    tearDown(() async {
      await jobsSignals.dispose();
      await db.close();
    });

    testWidgets('shows NAP Box dropdown, opens filter list, and selects NAP',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: CreateReportScreen(
          jobsSignals: jobsSignals,
          reportSignals: reportSignals,
          pickImage: (_) async => null,
        ),
      ));
      await tester.pumpAndSettle();

      // Scroll to ensure NAP Box is in view
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('nap_dropdown_field')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const ValueKey('nap_dropdown_field')), findsOneWidget);

      // Tap on the NAP Box dropdown field to open the filter bottom sheet
      await tester.tap(find.byKey(const ValueKey('nap_dropdown_field')));
      await tester.pumpAndSettle();

      // Verify filter bottom sheet header and search input appear
      expect(find.text('Select NAP Box'), findsOneWidget);
      expect(find.text('Filter NAP list (e.g. 001, test)...'), findsOneWidget);

      // Verify NAPs from list are rendered
      expect(find.text('NAP 001'), findsOneWidget);
      expect(find.text('NAP 002'), findsOneWidget);

      // Type in the search input to filter for "005"
      await tester.enterText(
          find.widgetWithText(TextField, 'Filter NAP list (e.g. 001, test)...'),
          '005');
      await tester.pumpAndSettle();

      // Only NAP 005 should be visible in filtered list
      expect(find.text('NAP 005'), findsOneWidget);
      expect(find.text('NAP 001'), findsNothing);

      // Tap NAP 005 to select it
      await tester.tap(find.text('NAP 005'));
      await tester.pumpAndSettle();

      // Bottom sheet should be dismissed, and selected NAP displayed
      expect(find.text('Select NAP Box'), findsNothing);
      expect(reportSignals.nap.value, 'NAP 005');
      expect(find.text('NAP 005'), findsOneWidget);

      // Submitting report saves the selected NAP to Drift SQLite
      await tester.runAsync(() async {
        await reportSignals.submitReport(jobsSignals.repository);
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();

      // Verify in Drift database
      final savedJob = await db.jobOrdersDao.getJobById(1);
      expect(savedJob?.nap, 'NAP 005');
    });
  });
}
