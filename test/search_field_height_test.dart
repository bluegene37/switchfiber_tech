import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/core/widgets/app_search_field.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_orders_screen.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/jobs/widgets/job_history_view.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/screens/lcp_nap_list_screen.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late JobsSignals jobs;
  late LcpNapSignals lcp;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    jobs = JobsSignals(JobRepository(db.jobOrdersDao));
    lcp = LcpNapSignals(LcpNapRepository(LcpNapLocationsDao(db)));
  });

  tearDown(() async {
    await jobs.dispose();
    await lcp.dispose();
    await db.close();
  });

  Future<void> expectSearch52(WidgetTester tester, Widget screen) async {
    await tester
        .pumpWidget(MaterialApp(theme: AppTheme.lightTheme, home: screen));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    tester.takeException();
    expect(find.byType(AppSearchField), findsOneWidget,
        reason:
            'the screen must use the shared field, not a hand-built capsule');
    expect(tester.getSize(find.byType(AppSearchField)).height,
        greaterThanOrEqualTo(52));
  }

  testWidgets('job orders search is 52', (tester) async {
    await expectSearch52(tester, JobOrdersScreen(jobsSignals: jobs));
  });

  testWidgets('LCP NAP search is 52', (tester) async {
    await expectSearch52(tester, LcpNapListScreen(signals: lcp));
  });

  testWidgets('job history search is 52', (tester) async {
    // JobHistoryView shows a "no technician" empty state (no search field at
    // all) until a technician email is known, regardless of search-field
    // height; a signed-in technician is the only way to reach the row this
    // test is actually checking.
    jobs.setTechnicianEmail('tech@example.com');
    await expectSearch52(
        tester, Scaffold(body: JobHistoryView(jobsSignals: jobs)));
  });
}
