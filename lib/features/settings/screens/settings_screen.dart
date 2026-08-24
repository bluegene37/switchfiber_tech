import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
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

  bool _isTestingPing = false;
  int? _lastPingMs;
  bool? _pingSuccess;

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

  Future<void> _testConnection() async {
    setState(() {
      _isTestingPing = true;
      _pingSuccess = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      await ApiClient.instance.get('/Users');
      stopwatch.stop();
      if (!mounted) return;
      setState(() {
        _isTestingPing = false;
        _lastPingMs = stopwatch.elapsedMilliseconds;
        _pingSuccess = true;
      });
    } catch (_) {
      stopwatch.stop();
      if (!mounted) return;
      setState(() {
        _isTestingPing = false;
        _lastPingMs = stopwatch.elapsedMilliseconds;
        _pingSuccess = false;
      });
    }
  }

  void _showOpticalPowerStandards() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.speed_rounded, color: AppTheme.primary, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'GPON Optical Power Standards',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStandardRow(
              title: 'Optimal / Pass (-12.0 to -24.0 dBm)',
              description: 'Target range for all fiber installations. Ensures maximum throughput and stability.',
              color: AppTheme.success,
              subtle: AppTheme.successSubtle,
            ),
            const SizedBox(height: 10),
            _buildStandardRow(
              title: 'Marginal (-24.0 to -27.0 dBm)',
              description: 'Service operational but approaching attenuation floor. Clean connectors & check bend radius.',
              color: AppTheme.warning,
              subtle: AppTheme.warningSubtle,
            ),
            const SizedBox(height: 10),
            _buildStandardRow(
              title: 'Faulty / Out of Spec (< -27.0 or > -8.0 dBm)',
              description: 'Excessive insertion loss or saturation. Re-splice drop cable or inspect NAP splitter port.',
              color: AppTheme.danger,
              subtle: AppTheme.dangerSubtle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardRow({
    required String title,
    required String description,
    required Color color,
    required Color subtle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.2) : subtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, color: color, size: 10),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, {bool success = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: success
            ? (isDark ? const Color(0xFF059669).withValues(alpha: 0.25) : AppTheme.successSubtle)
            : (isDark ? const Color(0xFF3F2327) : AppTheme.primarySubtleBg),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: success
              ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF166534))
              : (isDark ? const Color(0xFFFF8591) : AppTheme.primaryActive),
        ),
      ),
    );
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                          // Avatar with technician initials
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: isDark ? const Color(0xFF3F2327) : AppTheme.primarySubtleBg,
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
                                    _tag('Access level ${user?.accessLevelId ?? "-"}'),
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
                          _detailRow(Icons.phone_outlined, user.contactNumber),
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

          // 2. Display preferences
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
                          ? 'Easier on the eyes in low light'
                          : 'Optimized for high outdoor sunlight',
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

          // 3. Field Reference Tools: Optical Power Guide
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3F2327) : AppTheme.primarySubtleBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.speed_rounded, color: AppTheme.primary, size: 20),
              ),
              title: const Text(
                'GPON Optical Power Standards',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'View dBm reference thresholds & loss guidelines',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
              ),
              onTap: _showOpticalPowerStandards,
            ),
          ),

          const SizedBox(height: 16),

          // 4. Offline Sync & Drift Database Status
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
                            badgeColor: pending > 0
                                ? AppTheme.warning
                                : AppTheme.success,
                          ),
                          const SizedBox(height: 8),
                          _buildMetricRow(
                            'Drift Engine Status',
                            isSyncing ? 'Synchronizing...' : 'Reactive Stream Active',
                            Icons.storage_rounded,
                            badgeColor: isSyncing
                                ? AppTheme.primary
                                : AppTheme.success,
                          ),
                          const SizedBox(height: 14),

                          // Sync now button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isSyncing
                                  ? null
                                  : () async {
                                      final res = await syncWorker
                                          .syncPendingJobs();
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
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.sync_rounded, size: 16),
                              label: Text(
                                isSyncing
                                    ? 'Synchronizing...'
                                    : 'Force Full Sync (Drift ↔ API)',
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
                                  SnackBar(
                                    content: const Text(
                                        'Reset & populated sample field tech jobs in Drift DB.'),
                                    backgroundColor: isDark ? AppTheme.darkCard : AppTheme.darkSlate,
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
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 5. API Connection & Live Diagnostics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.dns_rounded, size: 18, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Backend Diagnostics',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      _buildPinningBadge(isDark),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Direct communication channel with Switch Fiber dispatch server.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SelectableText(
                            _baseUrl,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_lastPingMs != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _pingSuccess == true
                                  ? (isDark ? const Color(0xFF059669).withValues(alpha: 0.25) : AppTheme.successSubtle)
                                  : (isDark ? const Color(0xFFDC2626).withValues(alpha: 0.25) : AppTheme.dangerSubtle),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_lastPingMs}ms',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _pingSuccess == true
                                    ? (isDark ? const Color(0xFF4ADE80) : AppTheme.success)
                                    : (isDark ? const Color(0xFFF87171) : AppTheme.danger),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isTestingPing ? null : _testConnection,
                      icon: _isTestingPing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.network_ping_rounded, size: 16),
                      label: Text(_isTestingPing ? 'Testing latency...' : 'Test Connection Latency'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 6. Logout Action
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
          Center(
            child: Text(
              '${AppConstants.appName} v${AppConstants.appVersion}\nSwitch Fiber Philippines • Dispatch Ops',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinningBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF059669).withValues(alpha: 0.25) : AppTheme.successSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? const Color(0xFF059669).withValues(alpha: 0.4) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_rounded,
            size: 12,
            color: isDark ? const Color(0xFF4ADE80) : AppTheme.success,
          ),
          const SizedBox(width: 4),
          Text(
            'SSL Pinned (SHA-256)',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF166534),
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
            color: badgeColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.darkSlate),
          ),
        ),
      ],
    );
  }
}
