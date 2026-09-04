import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_order_detail_screen.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_orders_screen.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/screens/lcp_nap_list_screen.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';
import 'package:swithfiber_tech/features/service_orders/models/service_order_model.dart';
import 'package:swithfiber_tech/features/service_orders/screens/service_orders_screen.dart';
import 'package:swithfiber_tech/features/service_orders/signals/service_orders_signals.dart';
import 'package:swithfiber_tech/features/toolkit/screens/drop_cable_tool.dart';
import 'package:swithfiber_tech/features/toolkit/screens/fiber_color_code_tool.dart';
import 'package:swithfiber_tech/features/toolkit/screens/network_diagnostic_tool.dart';
import 'package:swithfiber_tech/features/toolkit/screens/optical_budget_tool.dart';
import 'package:swithfiber_tech/features/toolkit/screens/toolkit_screen.dart';
import 'package:swithfiber_tech/features/toolkit/screens/troubleshooting_guide_tool.dart';

/// The spec's acceptance test: every screen at the phone's maximum text size,
/// on a 412x915 phone, with no layout overflow anywhere.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late JobsSignals jobs;
  late LcpNapSignals lcp;
  late ServiceOrdersSignals serviceOrders;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    jobs = JobsSignals(JobRepository(db.jobOrdersDao));
    lcp = LcpNapSignals(LcpNapRepository(LcpNapLocationsDao(db)));
    serviceOrders = ServiceOrdersSignals();
  });

  tearDown(() async {
    await jobs.dispose();
    await lcp.dispose();
    await db.close();
  });

  Future<List<String>> overflowsAt200(
      WidgetTester tester, Widget screen) async {
    tester.view.devicePixelRatio = 2.625;
    tester.view.physicalSize = const Size(412 * 2.625, 915 * 2.625);
    addTearDown(tester.view.reset);

    final errors = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (d) => errors.add(d.toString());
    addTearDown(() => FlutterError.onError = original);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: screen,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    FlutterError.onError = original;
    tester.takeException();
    return errors.where((e) => e.contains('overflowed')).toList();
  }

  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      await db.jobOrdersDao.insertOrUpdateJob(JobOrderDto(
        id: 1,
        ticketNumber: 'SF-2026-0001',
        customerName: 'Scale Santos',
        address: 'Lot 1, Fiber Street, San Roque',
        barangay: 'San Roque',
        city: 'Binangonan',
        status: 'Scheduled',
        onsiteStatus: 'Scheduled',
        contactNumber: '09171234567',
        isSynced: true,
        updatedAt: DateTime.now(),
        rawJson: '{"coordinates": "14.469586, 121.195615"}',
      ).toCompanion());
      await LcpNapRepository(LcpNapLocationsDao(db)).seedSampleLocations();
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    // The service orders screen renders nothing at all with an empty list, so
    // without this its test passed vacuously and missed a real 33 px overflow
    // in the card's action row. Coordinates and a contact number are both
    // required: they are what put the Call and Navigate buttons on the card.
    serviceOrders.allOrders.value = [
      const ServiceOrderDto(
        id: 1,
        accountNumber: 'SF-ACCT-0001',
        fullName: 'Scale Santos',
        contactNumber: '09171234567',
        emailAddress: 'scale.santos@example.com',
        address: 'Lot 1, Fiber Street, San Roque, Binangonan',
        barangay: 'San Roque',
        city: 'Binangonan',
        concern: 'No Internet Connection',
        priorityLevel: 'Urgent',
        lcp: 'LCP-001',
        nap: 'NAP-014',
        addressCoordinates: '14.469586, 121.195615',
      ),
    ];
  }

  for (final entry in <String,
      Widget Function(JobsSignals, LcpNapSignals, ServiceOrdersSignals)>{
    'job orders': (j, _, __) => JobOrdersScreen(jobsSignals: j),
    'job detail': (j, _, __) => JobOrderDetailScreen(jobId: 1, jobsSignals: j),
    'LCP NAP list': (_, l, __) => LcpNapListScreen(signals: l),
    'toolkit hub': (_, __, ___) => const ToolkitScreen(),
    'troubleshooting guide': (_, __, ___) => const TroubleshootingGuideTool(),
    'drop cable estimator': (_, __, ___) => const DropCableTool(),
    'optical link budget': (_, __, ___) => const OpticalBudgetTool(),
    'network diagnostics': (_, __, ___) => const NetworkDiagnosticTool(),
    'fiber color code': (_, __, ___) => const FiberColorCodeTool(),
    'service orders': (_, __, s) => ServiceOrdersScreen(signals: s),
  }.entries) {
    testWidgets('${entry.key} has no overflow at 200% text', (tester) async {
      await seed(tester);
      final overflows =
          await overflowsAt200(tester, entry.value(jobs, lcp, serviceOrders));
      expect(overflows, isEmpty, reason: overflows.join('\n'));
    });
  }
}
