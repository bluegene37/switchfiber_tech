import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/features/auth/models/user_model.dart';
import 'package:swithfiber_tech/features/auth/signals/auth_signals.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';
import 'package:swithfiber_tech/main.dart';

// Note: these use explicit pump() calls rather than pumpAndSettle(), because the
// splash screen's CircularProgressIndicator animates forever and never settles.
void main() {
  testWidgets('a successful login replaces the login screen with the shell',
      (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final jobsSignals = JobsSignals(JobRepository(db.jobOrdersDao));
    final lcpNapSignals =
        LcpNapSignals(LcpNapRepository(LcpNapLocationsDao(db)));
    final authSignals = AuthSignals.instance;
    authSignals.currentUser.value = null;

    // Production entrypoint always runs with showSplash: true.
    await tester.pumpWidget(
      SwitchFiberTechApp(
        authSignals: authSignals,
        jobsSignals: jobsSignals,
        lcpNapSignals: lcpNapSignals,
        showSplash: true,
      ),
    );
    await tester
        .pump(const Duration(milliseconds: 1300)); // splash min duration
    await tester.pump(const Duration(milliseconds: 500)); // switcher transition
    expect(find.text('Technician Sign In'), findsOneWidget);

    // Simulate exactly what AuthSignals.login() does on a successful response.
    authSignals.currentUser.value = UserModel(
      id: 104,
      username: 'tech_marcos',
      fname: 'Marcos',
      lname: 'Dela Cruz',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Technician Sign In'), findsNothing,
        reason: 'technician is authenticated but is still on the login screen');

    // And signing out must return to the login screen.
    authSignals.currentUser.value = null;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Technician Sign In'), findsOneWidget,
        reason: 'signing out must return the technician to the login screen');

    await tester.runAsync(() async {
      await lcpNapSignals.dispose();
      await jobsSignals.dispose();
      await db.close();
    });
  });
}
