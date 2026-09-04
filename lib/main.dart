import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'core/database/app_database.dart';
import 'core/database/daos/lcp_nap_dao.dart';
import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/signals/auth_signals.dart';
import 'features/jobs/repositories/job_repository.dart';
import 'features/jobs/signals/jobs_signals.dart';
import 'features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'features/lcp_nap/signals/lcp_nap_signals.dart';
import 'features/service_orders/signals/service_orders_signals.dart';
import 'features/settings/signals/settings_signals.dart';
import 'features/shell/technician_shell.dart';
import 'features/splash/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Drift SQLite Database & DAOs
  final database = AppDatabase();
  await database.jobOrdersDao.deleteSampleJobs();
  await database.lcpNapLocationsDao.deleteSampleLocations();
  final jobRepository = JobRepository(database.jobOrdersDao);
  final lcpNapRepository = LcpNapRepository(LcpNapLocationsDao(database));
  final serviceOrdersSignals =
      ServiceOrdersSignals(dao: database.serviceOrdersDao);

  // 2. Initialize Signals State Layer
  final authSignals = AuthSignals.instance;
  final jobsSignals = JobsSignals(jobRepository);
  final lcpNapSignals = LcpNapSignals(lcpNapRepository);

  // 3. Apply the technician's configured API base URL before any request is
  //    made, otherwise a URL saved in Settings is silently ignored after a
  //    restart and the app falls back to the compiled-in default.
  ApiClient.instance
      .setBaseUrl(await SecureStorageService.instance.getBaseUrl());

  // 4. Connect API client 401 callback to auth signals
  ApiClient.instance.onUnauthorized = () {
    authSignals.logout();
  };

  // 5. Restore display preferences and the active technician session
  await SettingsSignals.instance.restore();
  await authSignals.restoreSession();

  runApp(
    SwitchFiberTechApp(
      authSignals: authSignals,
      jobsSignals: jobsSignals,
      lcpNapSignals: lcpNapSignals,
      serviceOrdersSignals: serviceOrdersSignals,
      showSplash: true,
    ),
  );
}

class SwitchFiberTechApp extends StatelessWidget {
  final AuthSignals authSignals;
  final JobsSignals jobsSignals;
  final LcpNapSignals lcpNapSignals;
  final ServiceOrdersSignals? serviceOrdersSignals;
  final bool showSplash;

  const SwitchFiberTechApp({
    super.key,
    required this.authSignals,
    required this.jobsSignals,
    required this.lcpNapSignals,
    this.serviceOrdersSignals,
    this.showSplash = true,
  });

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        return MaterialApp(
          title: 'Switch Fiber Tech',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: SettingsSignals.instance.themeMode.value,
          home: _RootView(
            authSignals: authSignals,
            jobsSignals: jobsSignals,
            lcpNapSignals: lcpNapSignals,
            serviceOrdersSignals: serviceOrdersSignals,
            showSplash: showSplash,
          ),
        );
      },
    );
  }
}

/// Root view that keeps authentication state as the single source of truth for
/// which screen is shown.
///
/// The splash is a one-shot gate in front of this; once it completes, the tree
/// below reacts to [AuthSignals.isAuthenticated], so signing in or signing out
/// swaps the screen without any imperative navigation.
class _RootView extends StatefulWidget {
  final AuthSignals authSignals;
  final JobsSignals jobsSignals;
  final LcpNapSignals lcpNapSignals;
  final ServiceOrdersSignals? serviceOrdersSignals;
  final bool showSplash;

  const _RootView({
    required this.authSignals,
    required this.jobsSignals,
    required this.lcpNapSignals,
    this.serviceOrdersSignals,
    required this.showSplash,
  });

  @override
  State<_RootView> createState() => _RootViewState();
}

class _RootViewState extends State<_RootView> {
  late bool _splashComplete = !widget.showSplash;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: !_splashComplete
          ? SplashScreen(
              onComplete: () {
                if (mounted) setState(() => _splashComplete = true);
              },
            )
          : SignalBuilder(
              builder: (context) {
                final authenticated = widget.authSignals.isAuthenticated.value;
                if (!authenticated) {
                  return const LoginScreen();
                }
                return TechnicianShell(
                  authSignals: widget.authSignals,
                  jobsSignals: widget.jobsSignals,
                  lcpNapSignals: widget.lcpNapSignals,
                  serviceOrdersSignals: widget.serviceOrdersSignals,
                );
              },
            ),
    );
  }
}
