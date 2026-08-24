import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/signals/auth_signals.dart';
import '../signals/settings_signals.dart';
import '../../jobs/signals/jobs_signals.dart';

/// Settings & Technician Terminal Diagnostics screen.
class SettingsScreen extends StatefulWidget {
  final AuthSignals authSignals;
  final JobsSignals jobsSignals;

  const SettingsScreen({
    super.key,
    required this.authSignals,
    required this.jobsSignals,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _baseUrl = AppConstants.defaultBaseUrl;
  final _storage = SecureStorageService.instance;

  @override
  void initState() {
    super.initState();
    _loadUrl();
    // Login returns only name and access level; pull contact details too.
    widget.authSignals.refreshProfile();
  }

  Future<void> _loadUrl() async {
    final url = await _storage.getBaseUrl();
    if (mounted) setState(() => _baseUrl = url);
  }

  Widget _tag(String label, {bool success = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: success ? AppTheme.successSubtle : AppTheme.primarySubtleBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: success ? const Color(0xFF166534) : AppTheme.primaryActive,
          ),
        ),
      );

  Widget _detailRow(IconData icon, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: AppTheme.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      );

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to end your field terminal session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.authSignals.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.authSignals;
    final jobs = widget.jobsSignals;
    final syncWorker = jobs.repository.syncWorker;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terminal Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              'Technician profile & offline sync management',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Technician Profile Card
          SignalBuilder(
            builder: (context) {
              final user = auth.currentUser.value;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // The API has no avatar field, so initials stand in.
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppTheme.primarySubtleBg,
                            child: Text(
                              user?.initials ?? 'T',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? 'Technician User',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '@${user?.username ?? "technician"}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    _tag('Access level '
                                        '${user?.accessLevelId ?? "-"}'),
                                    if (user?.active == true)
                                      _tag('Active', success: true),
                                    if (user != null && user.menus.isNotEmpty)
                                      _tag('${user.menus.length} modules'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (user != null &&
                          (user.email.isNotEmpty ||
                              user.contactNumber.isNotEmpty ||
                              user.address.isNotEmpty)) ...[
                        const Divider(height: 24),
                        if (user.email.isNotEmpty)
                          _detailRow(Icons.mail_outline_rounded, user.email),
                        if (user.contactNumber.isNotEmpty)
                          _detailRow(
                              Icons.phone_outlined, user.contactNumber),
                        if (user.address.isNotEmpty)
                          _detailRow(Icons.place_outlined, user.address),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // 1b. Display preferences
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SignalBuilder(
                builder: (context) {
                  final dark = SettingsSignals.instance.isDarkMode;
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: AppTheme.primary,
                    ),
                    title: const Text(
                      'Dark mode',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      dark
                          ? 'Easier on the eyes at night'
                          : 'Better in direct sunlight',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textMuted),
                    ),
                    value: dark,
                    activeThumbColor: AppTheme.primary,
                    onChanged: (v) => SettingsSignals.instance.setDarkMode(v),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2. Offline Sync & Drift Database Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.sync_rounded,
                          size: 18, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Drift SQLite & Offline Cache',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Cache metrics
                  SignalBuilder(
                    builder: (context) {
                      final total = jobs.totalCount.value;
                      final pending = syncWorker.pendingCount.value;
                      final isSyncing = syncWorker.isSyncing.value;

                    return Column(
                      children: [
                        _buildMetricRow(
                          'Total Cached Job Orders',
                          '$total records',
                          Icons.folder_outlined,
                        ),
                        const SizedBox(height: 8),
                        _buildMetricRow(
                          'Pending Sync Queue',
                          '$pending offline updates',
                          Icons.cloud_upload_outlined,
                          badgeColor:
                              pending > 0 ? AppTheme.warning : AppTheme.success,
                        ),
                        const SizedBox(height: 16),

                        // Sync button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isSyncing
                                ? null
                                : () async {
                                    final res =
                                        await syncWorker.syncPendingJobs();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(res.message),
                                        backgroundColor: res.success
                                            ? AppTheme.success
                                            : AppTheme.warning,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                            icon: isSyncing
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.cloud_sync_rounded, size: 18),
                            label: Text(
                              isSyncing
                                  ? 'Synchronizing...'
                                  : 'Force Sync Database Now',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Seed demo button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await jobs.repository.seedSampleJobs();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Reset & populated sample field tech jobs in Drift DB.'),
                                  backgroundColor: AppTheme.darkSlate,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.restart_alt_rounded,
                                size: 16),
                            label: const Text('Re-seed Sample Field Data'),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 3. API Connection (read-only)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.dns_rounded, size: 18, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Backend Endpoint',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Spacer(),
                      Icon(Icons.lock_outline_rounded,
                          size: 15, color: AppTheme.textMuted),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The server this terminal syncs with. Read-only.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.darkSlate
                          : AppTheme.lightBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: SelectableText(
                      _baseUrl,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 4. Logout Action
          OutlinedButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded, color: AppTheme.danger),
            label: const Text(
              'Sign Out of Terminal',
              style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.danger, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),

          const SizedBox(height: 24),

          // App build info
          const Center(
            child: Text(
              '${AppConstants.appName} v${AppConstants.appVersion}\nSwitch Fiber Philippines • Dispatch Ops',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    IconData icon, {
    Color? badgeColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: badgeColor ?? AppTheme.darkSlate,
          ),
        ),
      ],
    );
  }
}
