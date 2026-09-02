import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/auth/models/user_model.dart';
import 'package:swithfiber_tech/features/auth/signals/auth_signals.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_history_screen.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_order_detail_screen.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/jobs/widgets/job_history_tile.dart';

const _me = 'tech@switchfiber.ph';

JobOrderDto _job(int id, String email, String status, {DateTime? installed}) =>
    JobOrderDto(
      id: id,
      ticketNumber: 'SF-$id',
      customerName: 'Subscriber $id',
      address: 'Lot $id, Sample St.',
      city: 'Antipolo',
      status: status,
      assignedEmail: email,
      dateInstalled: installed,
    );

void main() {
  late AppDatabase db;
  late JobsSignals jobsSignals;
  final auth = AuthSignals.instance;

  Future<void> seed(WidgetTester tester, List<JobOrderDto> jobs) async {
    // Database work must run in runAsync: the fake-async test zone never
    // advances Drift's stream otherwise, and allJobs would stay empty.
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      jobsSignals = JobsSignals(JobRepository(db.jobOrdersDao));
      await db.jobOrdersDao
          .insertAllJobs([for (final j in jobs) j.toCompanion()]);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
  }

  Future<void> pumpScreen(WidgetTester tester) => tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: JobHistoryScreen(
            jobsSignals: jobsSignals,
            authSignals: auth,
          ),
        ),
      );

  tearDown(() async {
    auth.currentUser.value = null;
    await jobsSignals.dispose();
    await db.close();
  });

  testWidgets('shows only the signed-in technician\'s jobs, newest first',
      (tester) async {
    await seed(tester, [
      _job(1, _me, 'Completed', installed: DateTime(2026, 8, 1)),
      _job(2, 'other@switchfiber.ph', 'Completed',
          installed: DateTime(2026, 8, 30)),
      _job(3, _me, 'Activated', installed: DateTime(2026, 8, 20)),
    ]);
    jobsSignals.setTechnicianEmail(_me);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('My Job History'), findsOneWidget);
    expect(find.text('Assigned to $_me'), findsOneWidget);
    expect(find.text('SF-1'), findsOneWidget);
    expect(find.text('SF-3'), findsOneWidget);
    expect(find.text('SF-2'), findsNothing,
        reason: 'another technician\'s job must never appear');

    final tiles = tester
        .widgetList<JobHistoryTile>(find.byType(JobHistoryTile))
        .map((t) => t.job.id)
        .toList();
    expect(tiles, [3, 1], reason: 'most recent install first');
    expect(find.text('Aug 20, 2026'), findsOneWidget);
  });

  testWidgets('filter chips narrow the list and clear from the empty state',
      (tester) async {
    await seed(tester, [
      _job(1, _me, 'Completed'),
      _job(2, _me, 'Activated'),
    ]);
    jobsSignals.setTechnicianEmail(_me);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Activated'));
    await tester.pumpAndSettle();
    expect(find.text('SF-2'), findsOneWidget);
    expect(find.text('SF-1'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'In Progress'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing Matches'), findsOneWidget);

    await tester.tap(find.text('Clear Filters'));
    await tester.pumpAndSettle();
    expect(find.text('SF-1'), findsOneWidget);
    expect(find.text('SF-2'), findsOneWidget);
  });

  testWidgets('explains when the profile has no email to match on',
      (tester) async {
    await seed(tester, [_job(1, _me, 'Completed')]);
    jobsSignals.setTechnicianEmail('');

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('No Email On Your Profile'), findsOneWidget);
    expect(find.text('SF-1'), findsNothing);
  });

  testWidgets('tapping a tile opens the job order details', (tester) async {
    await seed(tester, [_job(1, _me, 'Completed')]);
    jobsSignals.setTechnicianEmail(_me);
    auth.currentUser.value = UserModel(id: 1, username: 'tech', email: _me);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(JobHistoryTile));
    await tester.pumpAndSettle();

    expect(find.byType(JobOrderDetailScreen), findsOneWidget);
    expect(find.text('Subscriber 1'), findsOneWidget);
  });
}
