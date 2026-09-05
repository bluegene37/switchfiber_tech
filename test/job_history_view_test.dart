import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/auth/models/user_model.dart';
import 'package:swithfiber_tech/features/auth/signals/auth_signals.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_order_detail_screen.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/jobs/widgets/job_history_tile.dart';
import 'package:swithfiber_tech/features/jobs/widgets/job_history_view.dart';

const _me = 'tech@switchfiber.ph';
final _now = DateTime(2026, 9, 2, 14);

JobOrderDto _job(
  int id,
  String email,
  String status, {
  DateTime? installed,
  String city = 'Antipolo',
}) =>
    JobOrderDto(
      id: id,
      ticketNumber: 'SF-$id',
      customerName: 'Subscriber $id',
      address: 'Lot $id, Sample St.',
      city: city,
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
      jobsSignals =
          JobsSignals(JobRepository(db.jobOrdersDao), clock: () => _now);
      await db.jobOrdersDao
          .insertAllJobs([for (final j in jobs) j.toCompanion()]);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
  }

  Future<void> pumpView(WidgetTester tester) => tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: JobHistoryView(
              jobsSignals: jobsSignals,
              authSignals: auth,
            ),
          ),
        ),
      );

  tearDown(() async {
    auth.currentUser.value = null;
    await jobsSignals.dispose();
    await db.close();
  });

  testWidgets('shows history jobs, newest first, excluding scheduled',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await seed(tester, [
      _job(1, _me, 'Activated', installed: DateTime(2026, 8, 1)),
      _job(2, 'other@switchfiber.ph', 'Activated',
          installed: DateTime(2026, 8, 30)),
      _job(3, _me, 'Activated', installed: DateTime(2026, 8, 20)),
      _job(4, _me, 'Scheduled'),
    ]);
    jobsSignals.setTechnicianEmail(_me);

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.text('SF-2'), findsNothing,
        reason: 'assigned to another technician, so not my history');
    expect(find.text('SF-3'), findsOneWidget);
    expect(find.text('SF-1'), findsOneWidget);
    expect(find.text('SF-4'), findsNothing,
        reason: 'a job that is still scheduled is not history');

    final tiles = tester
        .widgetList<JobHistoryTile>(find.byType(JobHistoryTile))
        .map((t) => t.job.id)
        .toList();
    expect(tiles, [3, 1], reason: 'most recent activation first');
    expect(find.text('Aug 20, 2026'), findsOneWidget);
  });

  testWidgets('date and area chips narrow the list and clear together',
      (tester) async {
    await seed(tester, [
      _job(1, _me, 'Activated', installed: DateTime(2026, 9, 2, 9)),
      _job(2, _me, 'Activated',
          installed: DateTime(2026, 8, 20), city: 'Pasig'),
    ]);
    jobsSignals.setTechnicianEmail(_me);

    await pumpView(tester);
    await tester.pumpAndSettle();
    expect(find.text('SF-1'), findsOneWidget);
    expect(find.text('SF-2'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Today'));
    await tester.pumpAndSettle();
    expect(find.text('SF-1'), findsOneWidget);
    expect(find.text('SF-2'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'Pasig'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing Matches'), findsOneWidget);

    await tester.tap(find.text('Clear Filters'));
    await tester.pumpAndSettle();
    expect(find.text('SF-1'), findsOneWidget);
    expect(find.text('SF-2'), findsOneWidget);
  });

  testWidgets('status chips filter history between Activated and Completed',
      (tester) async {
    await seed(tester, [
      _job(1, _me, 'Activated', installed: DateTime(2026, 9, 2, 9)),
      _job(2, _me, 'Completed',
          installed: DateTime(2026, 8, 20), city: 'Pasig'),
    ]);
    jobsSignals.setTechnicianEmail(_me);

    await pumpView(tester);
    await tester.pumpAndSettle();
    expect(find.text('SF-1'), findsOneWidget);
    expect(find.text('SF-2'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Activated'));
    await tester.pumpAndSettle();
    expect(find.text('SF-1'), findsOneWidget);
    expect(find.text('SF-2'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
    await tester.pumpAndSettle();
    expect(find.text('SF-1'), findsNothing);
    expect(find.text('SF-2'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();
    expect(find.text('SF-1'), findsOneWidget);
    expect(find.text('SF-2'), findsOneWidget);
  });

  testWidgets("another technician's jobs never show once my email is known",
      (tester) async {
    // A pull made before the email was known can leave other crews' rows in
    // the cache; the history must not show them.
    await seed(tester, [
      _job(1, _me, 'Activated'),
      _job(2, 'tech1@switchfiber.ph', 'Activated'),
    ]);
    jobsSignals.setTechnicianEmail(_me);

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.text('SF-1'), findsOneWidget);
    expect(find.text('SF-2'), findsNothing);
  });

  testWidgets('displays history jobs even when technician email is not set',
      (tester) async {
    await seed(tester, [_job(1, _me, 'Activated')]);
    jobsSignals.setTechnicianEmail('');

    await pumpView(tester);
    await tester.pumpAndSettle();

    expect(find.text('SF-1'), findsOneWidget);
  });

  testWidgets('tapping a tile opens the details in view-only mode',
      (tester) async {
    await seed(tester, [_job(1, _me, 'Activated')]);
    jobsSignals.setTechnicianEmail(_me);
    auth.currentUser.value = UserModel(id: 1, username: 'tech', email: _me);

    await pumpView(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(JobHistoryTile));
    await tester.pumpAndSettle();

    final detail =
        tester.widget<JobOrderDetailScreen>(find.byType(JobOrderDetailScreen));
    expect(detail.readOnly, isTrue);
    expect(find.textContaining('View only'), findsOneWidget);
    expect(find.text('Complete'), findsNothing);
    expect(find.text('Mark as Activated'), findsNothing);
    expect(find.byTooltip('Field Completion Report'), findsNothing);
    expect(find.text('Fill / Update Completion Report'), findsNothing);
  });
}
