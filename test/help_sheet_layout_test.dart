import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/features/auth/signals/auth_signals.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';
import 'package:swithfiber_tech/main.dart';

/// Height of the simulated system navigation bar, in logical pixels.
const double _navBarHeight = 48;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late LcpNapSignals lcpNapSignals;

  Future<void> openHelpSheet(WidgetTester tester) async {
    final store = <String, String>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => call.method == 'readAll' ? store : null,
    );

    db = AppDatabase(NativeDatabase.memory());
    lcpNapSignals = LcpNapSignals(LcpNapRepository(LcpNapLocationsDao(db)));
    final authSignals = AuthSignals.instance;
    authSignals.currentUser.value = null;

    await tester.pumpWidget(
      SwitchFiberTechApp(
        authSignals: authSignals,
        jobsSignals: JobsSignals(JobRepository(db.jobOrdersDao)),
        lcpNapSignals: lcpNapSignals,
        showSplash: false,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // The larger field type scale pushes this link below the fixed test
    // surface on the default (unset) viewport size; scroll it into view
    // before tapping, exactly as a technician would on a real, taller phone.
    await tester.ensureVisible(find.text('Need help or forgot password?'));
    await tester.pump();
    await tester.tap(find.text('Need help or forgot password?'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> disposeAll(WidgetTester tester) async {
    await tester.runAsync(() async {
      await lcpNapSignals.dispose();
      await db.close();
    });
  }

  testWidgets('the hotline is named without a city', (tester) async {
    await openHelpSheet(tester);

    expect(find.text('Switch Fiber Operations'), findsOneWidget);
    expect(find.text('Switch Fiber Operations Manila'), findsNothing);

    await disposeAll(tester);
  });

  testWidgets('the copy button clears the system navigation bar',
      (tester) async {
    // A phone with a gesture/navigation bar along the bottom edge.
    tester.view.devicePixelRatio = 3.0;
    // 500 x 900 logical: wide enough that the login screen itself lays out
    // without overflowing, so the sheet is what is under test.
    tester.view.physicalSize = const Size(1500, 2700);
    tester.view.padding = const FakeViewPadding(bottom: _navBarHeight * 3.0);
    tester.view.viewPadding =
        const FakeViewPadding(bottom: _navBarHeight * 3.0);
    addTearDown(tester.view.reset);

    await openHelpSheet(tester);

    expect(find.text('Dispatch & Terminal Help'), findsOneWidget,
        reason: 'the help sheet must be open before measuring it');

    final copyButton = find.byTooltip('Copy Hotline');
    expect(copyButton, findsOneWidget);

    final screenHeight = tester.view.physicalSize.height / 3.0;
    final safeBottom = screenHeight - _navBarHeight;
    final rect = tester.getRect(copyButton);

    expect(rect.bottom, lessThanOrEqualTo(safeBottom),
        reason: 'the hotline copy button must sit above the navigation bar, '
            'not underneath it');

    await disposeAll(tester);
  });
}
