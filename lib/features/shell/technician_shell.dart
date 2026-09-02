import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../auth/signals/auth_signals.dart';
import '../jobs/models/job_order_model.dart';
import '../jobs/screens/job_history_screen.dart';
import '../jobs/screens/job_orders_screen.dart';
import '../jobs/signals/jobs_signals.dart';
import '../lcp_nap/screens/lcp_nap_list_screen.dart';
import '../lcp_nap/signals/lcp_nap_signals.dart';
import '../reports/screens/create_report_screen.dart';
import '../reports/signals/report_signals.dart';
import '../settings/screens/settings_screen.dart';
import '../toolkit/screens/toolkit_screen.dart';

/// Main Technician Navigation Shell containing 5 bottom tabs and drawer.
class TechnicianShell extends StatefulWidget {
  final AuthSignals authSignals;
  final JobsSignals jobsSignals;
  final LcpNapSignals lcpNapSignals;

  const TechnicianShell({
    super.key,
    required this.authSignals,
    required this.jobsSignals,
    required this.lcpNapSignals,
  });

  @override
  State<TechnicianShell> createState() => _TechnicianShellState();
}

class _TechnicianShellState extends State<TechnicianShell> {
  static const int _tabScheduled = 0;
  static const int _tabHistory = 1;
  static const int _tabLcpNap = 2;
  static const int _tabToolkit = 3;
  static const int _tabSettings = 4;

  int _currentIndex = _tabScheduled;
  late final ReportSignals _reportSignals;
  late final void Function() _disposeEmailSync;

  @override
  void initState() {
    super.initState();
    _reportSignals = ReportSignals();
    // The job history is scoped to the signed-in technician's email. Kept in
    // sync reactively so a profile refresh that fills in the email (the login
    // response does not carry it) immediately unlocks the history.
    _disposeEmailSync = effect(() {
      widget.jobsSignals
          .setTechnicianEmail(widget.authSignals.currentUser.value?.email);
    });
    // Initial fetch / Drift seed. Runs here rather than at construction time so
    // that requests are only made once the technician is authenticated.
    // `initial` walks each screen through downloading -> skeleton -> data.
    widget.jobsSignals.fetchRemote(initial: true);
    widget.lcpNapSignals.fetchRemote(initial: true);
    // The login response carries no email, and the job history is matched on
    // it, so the full profile is pulled as soon as the shell appears rather
    // than only when the technician happens to open Settings.
    widget.authSignals.refreshProfile();
  }

  @override
  void dispose() {
    _disposeEmailSync();
    super.dispose();
  }

  /// Opens the on-site report for a job order as its own page, rather than a
  /// separate tab: a report only ever belongs to a job.
  void _openReportForJob(JobOrderDto job) {
    _reportSignals.setJobOrder(job);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(
          jobsSignals: widget.jobsSignals,
          reportSignals: _reportSignals,
          onReportSubmitted: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobs = widget.jobsSignals;
    final auth = widget.authSignals;

    final screens = [
      JobOrdersScreen(
        jobsSignals: jobs,
        onSelectJobForReport: _openReportForJob,
      ),
      JobHistoryScreen(
        jobsSignals: jobs,
        authSignals: auth,
        onSelectJobForReport: _openReportForJob,
      ),
      LcpNapListScreen(signals: widget.lcpNapSignals),
      const ToolkitScreen(),
      SettingsScreen(
        authSignals: auth,
        jobsSignals: jobs,
      ),
    ];

    return Scaffold(
      drawer: _buildDrawer(context, auth, jobs),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          // 1. Scheduled Job Orders with scheduled badge
          NavigationDestination(
            icon: SignalBuilder(
              builder: (context) {
                final scheduled = jobs.scheduledCount.value;

                return Badge(
                  isLabelVisible: scheduled > 0,
                  label: Text('$scheduled'),
                  backgroundColor: AppTheme.primary,
                  child: const Icon(Icons.calendar_today_outlined),
                );
              },
            ),
            selectedIcon: const Icon(Icons.calendar_today_rounded),
            label: 'Scheduled',
          ),

          // 2. The technician's own job history
          NavigationDestination(
            icon: SignalBuilder(
              builder: (context) {
                final mine = jobs.historyTotalCount.value;
                return Badge(
                  isLabelVisible: mine > 0,
                  label: Text('$mine'),
                  backgroundColor: AppTheme.success,
                  child: const Icon(Icons.history_outlined),
                );
              },
            ),
            selectedIcon: const Icon(Icons.history_rounded),
            label: 'My History',
          ),

          // 3. LCP NAP plant records and map
          NavigationDestination(
            icon: SignalBuilder(
              builder: (context) {
                final sites = widget.lcpNapSignals.totalSitesCount.value;
                return Badge(
                  isLabelVisible: sites > 0,
                  label: Text('$sites'),
                  backgroundColor: const Color(0xFF0EA5E9),
                  child: const Icon(Icons.share_location_outlined),
                );
              },
            ),
            selectedIcon: const Icon(Icons.share_location_rounded),
            label: 'LCP NAP',
          ),

          // 4. Technician Field Toolkit
          const NavigationDestination(
            icon: Icon(Icons.handyman_outlined),
            selectedIcon: Icon(Icons.handyman_rounded),
            label: 'Tech Toolkit',
          ),

          // 5. Settings & Terminal Diagnostics
          NavigationDestination(
            icon: SignalBuilder(
              builder: (context) {
                final pending = jobs.unsyncedCount.value;
                return Badge(
                  isLabelVisible: pending > 0,
                  label: Text('$pending'),
                  backgroundColor: AppTheme.warning,
                  child: const Icon(Icons.settings_outlined),
                );
              },
            ),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(
      BuildContext context, AuthSignals auth, JobsSignals jobs) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with Technician details
          SignalBuilder(
            builder: (context) {
              final user = auth.currentUser.value;
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    (user?.fname.isNotEmpty == true ? user!.fname[0] : 'T')
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                accountName: Text(
                  user?.fullName ?? 'Field Technician',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                accountEmail: Text(
                  user?.email.isNotEmpty == true
                      ? user!.email
                      : 'Switch Fiber Dispatch Tech',
                  style: const TextStyle(fontSize: 13),
                ),
              );
            },
          ),

          ListTile(
            leading:
                const Icon(Icons.receipt_long_rounded, color: AppTheme.primary),
            title: const Text('Job Orders'),
            trailing: SignalBuilder(
              builder: (context) {
                final scheduled = jobs.scheduledCount.value;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySubtleBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$scheduled scheduled',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryActive,
                    ),
                  ),
                );
              },
            ),
            selected: _currentIndex == _tabScheduled,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = _tabScheduled);
            },
          ),

          ListTile(
            leading: const Icon(Icons.history_rounded, color: AppTheme.primary),
            title: const Text('My Job History'),
            trailing: SignalBuilder(
              builder: (context) {
                final mine = jobs.historyTotalCount.value;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.successSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$mine assigned',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF166534),
                    ),
                  ),
                );
              },
            ),
            selected: _currentIndex == _tabHistory,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = _tabHistory);
            },
          ),

          ListTile(
            leading: const Icon(Icons.share_location_rounded,
                color: AppTheme.primary),
            title: const Text('LCP NAP Locations'),
            trailing: SignalBuilder(
              builder: (context) {
                final total = widget.lcpNapSignals.totalSitesCount.value;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySubtleBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$total sites',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryActive,
                    ),
                  ),
                );
              },
            ),
            selected: _currentIndex == _tabLcpNap,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = _tabLcpNap);
            },
          ),

          ListTile(
            leading:
                const Icon(Icons.handyman_rounded, color: AppTheme.primary),
            title: const Text('Tech Toolkit & Calculators'),
            selected: _currentIndex == _tabToolkit,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = _tabToolkit);
            },
          ),

          ListTile(
            leading: const Icon(Icons.sync_rounded, color: AppTheme.primary),
            title: const Text('Offline Sync Queue'),
            trailing: SignalBuilder(
              builder: (context) {
                final pending = jobs.unsyncedCount.value;
                if (pending == 0) {
                  return const Icon(Icons.check_circle_rounded,
                      size: 18, color: AppTheme.success);
                }
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.warningSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$pending pending',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                );
              },
            ),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = _tabSettings);
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Terminal Settings'),
            selected: _currentIndex == _tabSettings,
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = _tabSettings);
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppTheme.danger),
            title: const Text('Sign Out',
                style: TextStyle(color: AppTheme.danger)),
            onTap: () async {
              Navigator.pop(context);
              await auth.logout();
            },
          ),
        ],
      ),
    );
  }
}
