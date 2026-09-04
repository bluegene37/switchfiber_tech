import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_order_detail_screen.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';

/// The SMS a technician sends is a draft, not a script. These cover the part
/// that has to hold: the suggested wording appears, it can be replaced, and
/// the edited text is what leaves the sheet.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late JobsSignals jobs;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    jobs = JobsSignals(JobRepository(db.jobOrdersDao));
  });

  tearDown(() async {
    await jobs.dispose();
    await db.close();
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> openSmsSheet(WidgetTester tester) async {
    await tester.runAsync(() async {
      await db.jobOrdersDao.insertOrUpdateJob(JobOrderDto(
        id: 1,
        ticketNumber: 'SF-2026-0001',
        customerName: 'Ana Reyes',
        address: 'Lot 1, Fiber Street, San Roque',
        barangay: 'San Roque',
        city: 'Binangonan',
        status: 'Scheduled',
        onsiteStatus: 'Scheduled',
        contactNumber: '09171234567',
        isSynced: true,
        updatedAt: DateTime.now(),
      ).toCompanion());
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: JobOrderDetailScreen(jobId: 1, jobsSignals: jobs),
    ));
    // Fixed frames rather than pumpAndSettle: the detail screen keeps a
    // RADIUS lookup spinner turning, so settling never completes.
    await settle(tester);

    // The contact buttons sit below the fold on a long detail screen, so the
    // tap has to be scrolled into view or it silently misses.
    final smsButton = find.widgetWithText(OutlinedButton, 'SMS');
    await tester.scrollUntilVisible(smsButton, 200,
        scrollable: find.byType(Scrollable).first);
    await settle(tester);
    await tester.tap(smsButton);
    await settle(tester);
  }

  testWidgets('the suggested wording opens in an editable field',
      (tester) async {
    await openSmsSheet(tester);

    final field = find.byType(TextField);
    expect(field, findsOneWidget,
        reason: 'the draft must be typed into, not just read');

    final controller = tester.widget<TextField>(field).controller!;
    expect(controller.text, contains('Ana Reyes'),
        reason: 'the draft names the subscriber it is addressed to');
    expect(controller.text, contains('SF-2026-0001'),
        reason: 'the draft carries the ticket the visit is for');
    expect(tester.widget<TextField>(field).enabled, isNot(false),
        reason: 'a disabled field would make this read-only again');
  });

  testWidgets('a rewritten message replaces the suggestion', (tester) async {
    await openSmsSheet(tester);

    const rewritten = 'Running 30 minutes late, sorry for the wait.';
    await tester.enterText(find.byType(TextField), rewritten);
    await settle(tester);

    final controller =
        tester.widget<TextField>(find.byType(TextField)).controller!;
    expect(controller.text, rewritten,
        reason: 'what the technician typed is what gets sent');
    expect(controller.text, isNot(contains('arriving shortly')),
        reason: 'the suggestion must not survive being typed over');
  });

  testWidgets('an emptied draft cannot be sent', (tester) async {
    await openSmsSheet(tester);

    await tester.enterText(find.byType(TextField), '   ');
    await settle(tester);

    final send = tester
        .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Send'));
    expect(send.onPressed, isNull,
        reason: 'sending blank would open the messaging app with nothing');
  });

  testWidgets('reset restores the suggestion after an edit', (tester) async {
    await openSmsSheet(tester);

    final reset = find.widgetWithText(TextButton, 'Reset to suggested');
    expect(tester.widget<TextButton>(reset).onPressed, isNull,
        reason: 'nothing to reset before the draft is touched');

    await tester.enterText(find.byType(TextField), 'Something else entirely');
    await settle(tester);
    await tester.tap(reset);
    await settle(tester);

    final controller =
        tester.widget<TextField>(find.byType(TextField)).controller!;
    expect(controller.text, contains('arriving shortly'),
        reason: 'reset brings the suggested wording back');
  });

  test('the template names the subscriber and the ticket', () {
    final job = JobOrderDto(
      id: 2,
      ticketNumber: 'SF-2026-0042',
      customerName: 'Ben Cruz',
      address: 'Lot 2',
      status: 'Scheduled',
      onsiteStatus: 'Scheduled',
      isSynced: true,
      updatedAt: DateTime.now(),
    );
    final text = JobOrderDetailScreen.smsTemplate(job);
    expect(text, contains('Ben Cruz'));
    expect(text, contains('SF-2026-0042'));
  });
}
