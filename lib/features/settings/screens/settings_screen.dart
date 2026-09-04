import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/server_display.dart';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Padding(
        // Clear the system navigation bar, which otherwise covers the last
        // row of the sheet.
        padding: EdgeInsets.fromLTRB(
            20, 10, 20, 28 + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // iOS Grabber Pill
            Center(
              child: Container(
                width: 36,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF38383A)
                      : const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.speedometer,
                        color: AppTheme.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'GPON Optical Power Standards',
                      style: ctx.text.titleSmall,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkInput : AppTheme.fillLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.xmark,
                      size: 24,
                      color: isDark ? Colors.white : AppTheme.darkSlate,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildStandardRow(
              title: 'Optimal / Pass (-12.0 to -24.0 dBm)',
              description:
                  'Target range for all fiber installations. Ensures maximum throughput and stability.',
              color: AppTheme.success,
              subtle: AppTheme.successSubtle,
            ),
            const SizedBox(height: 10),
            _buildStandardRow(
              title: 'Marginal (-24.0 to -27.0 dBm)',
              description:
                  'Service operational but approaching attenuation floor. Clean connectors & check bend radius.',
              color: AppTheme.warning,
              subtle: AppTheme.warningSubtle,
            ),
            const SizedBox(height: 10),
            _buildStandardRow(
              title: 'Faulty / Out of Spec (< -27.0 or > -8.0 dBm)',
              description:
                  'Excessive insertion loss or saturation. Re-splice drop cable or inspect NAP splitter port.',
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
    // The three call sites only ever pass one of these three brand/status
    // fills; route the text to the ink that matches so it never renders in
    // the bright colour itself.
    final Color textInk = color == AppTheme.success
        ? AppTheme.successInkOf(context)
        : color == AppTheme.warning
            ? AppTheme.warningInkOf(context)
            : AppTheme.dangerInkOf(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.18) : subtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.circle_fill, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: context.text.labelLarge!.copyWith(color: textInk),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: context.text.bodyMedium!
                .copyWith(color: AppTheme.secondaryInkOf(context)),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, {bool success = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: success
            ? (isDark
                ? const Color(0xFF34C759).withValues(alpha: 0.2)
                : AppTheme.successSubtle)
            : (isDark ? const Color(0xFF3F2327) : AppTheme.primarySubtleBg),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: success
              ? (isDark
                  ? const Color(0xFF34C759).withValues(alpha: 0.3)
                  : const Color(0xFFBBF7D0))
              : (isDark
                  ? AppTheme.primary.withValues(alpha: 0.3)
                  : AppTheme.primarySubtleBorder),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: context.text.labelMedium!.copyWith(
          color: success
              ? AppTheme.successInkOf(context)
              : AppTheme.brandInkOf(context),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppTheme.textMuted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: context.text.bodySmall,
              ),
            ),
          ],
        ),
      );

  Future<void> _handleLogout() async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            'Are you sure you want to end your field terminal session?',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            isDefaultAction: true,
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, true),
            isDestructiveAction: true,
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.authSignals.logout();
    }
  }

  Widget _buildIosSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: context.text.labelSmall,
      ),
    );
  }

  Widget _buildIosGroupedCard({
    required List<Widget> children,
    required bool isDark,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.5,
        ),
      ),
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildIosSettingRow({
    required IconData icon,
    required Color iconBg,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required bool isDark,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                // iOS Squircle Icon Badge
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: Colors.white, size: 17),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.text.titleMedium,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: context.text.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 56,
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.authSignals;
    final jobs = widget.jobsSignals;
    final syncWorker = jobs.repository.syncWorker;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: context.text.titleMedium,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          // Section 1: Technician Profile Header
          _buildIosSectionHeader('Technician Profile'),
          SignalBuilder(
            builder: (context) {
              final user = auth.currentUser.value;
              return _buildIosGroupedCard(
                isDark: isDark,
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: isDark
                            ? const Color(0xFF3F2327)
                            : AppTheme.primarySubtleBg,
                        child: Text(
                          user?.initials ?? 'T',
                          style: context.text.titleLarge!
                              .copyWith(color: AppTheme.brandInkOf(context)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Technician User',
                              style: context.text.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '@${user?.username ?? "technician"}',
                              style: context.text.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _tag(
                                    'Access level ${user?.accessLevelId ?? "-"}'),
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
                    Divider(
                      height: 24,
                      thickness: 0.5,
                      color:
                          isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    ),
                    if (user.email.isNotEmpty)
                      _detailRow(CupertinoIcons.mail, user.email),
                    if (user.contactNumber.isNotEmpty)
                      _detailRow(CupertinoIcons.phone, user.contactNumber),
                    if (user.address.isNotEmpty)
                      _detailRow(CupertinoIcons.location_solid, user.address),
                  ],
                ],
              );
            },
          ),

          // Section 2: Appearance & Display Preferences
          _buildIosSectionHeader('Appearance & Display'),
          SignalBuilder(
            builder: (context) {
              final dark = SettingsSignals.instance.isDarkMode;
              return _buildIosGroupedCard(
                isDark: isDark,
                children: [
                  _buildIosSettingRow(
                    icon: dark
                        ? CupertinoIcons.moon_fill
                        : CupertinoIcons.sun_max_fill,
                    iconBg: const Color(0xFF5856D6), // iOS Indigo
                    title: 'Dark Mode',
                    subtitle: dark
                        ? 'Easier on the eyes in low light'
                        : 'Optimized for high outdoor sunlight',
                    isDark: isDark,
                    showDivider: false,
                    trailing: CupertinoSwitch(
                      value: dark,
                      activeTrackColor: AppTheme.primary,
                      onChanged: (v) => SettingsSignals.instance.setDarkMode(v),
                    ),
                  ),
                ],
              );
            },
          ),

          // Section 3: Field Reference Tools
          _buildIosSectionHeader('Field Reference Tools'),
          _buildIosGroupedCard(
            isDark: isDark,
            children: [
              _buildIosSettingRow(
                icon: CupertinoIcons.speedometer,
                iconBg: AppTheme.primary,
                title: 'GPON Optical Power Standards',
                subtitle: 'Thresholds & attenuation loss specs',
                isDark: isDark,
                showDivider: false,
                onTap: _showOpticalPowerStandards,
                trailing: const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 24,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),

          // Section 4: Offline Storage & Drift Database Cache
          _buildIosSectionHeader('Offline Storage (Drift SQLite)'),
          _buildIosGroupedCard(
            isDark: isDark,
            padding: const EdgeInsets.all(14),
            children: [
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
                        CupertinoIcons.folder,
                      ),
                      const SizedBox(height: 8),
                      _buildMetricRow(
                        'Pending Sync Queue',
                        '$pending offline updates',
                        CupertinoIcons.cloud_upload,
                        badgeColor:
                            pending > 0 ? AppTheme.warning : AppTheme.success,
                      ),
                      const SizedBox(height: 8),
                      _buildMetricRow(
                        'Drift Engine Status',
                        isSyncing
                            ? 'Synchronizing...'
                            : 'Reactive Stream Active',
                        CupertinoIcons.layers_alt,
                        badgeColor:
                            isSyncing ? AppTheme.primary : AppTheme.success,
                      ),
                      const SizedBox(height: 14),

                      // Force Sync Button
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
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(CupertinoIcons.arrow_2_circlepath,
                                  size: 24),
                          label: Text(
                            isSyncing
                                ? 'Synchronizing...'
                                : 'Force Full Sync (Drift ↔ API)',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          // Section 5: Backend Connection & SSL Pinning
          _buildIosSectionHeader('Backend Connection & Diagnostics'),
          _buildIosGroupedCard(
            isDark: isDark,
            padding: const EdgeInsets.all(14),
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.shield_lefthalf_fill,
                      size: 17, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'SSL Pinned Channel',
                    style: context.text.titleSmall,
                  ),
                  const Spacer(),
                  _buildPinningBadge(isDark),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Direct communication channel with Switch Fiber dispatch server.',
                style: context.text.bodyMedium!
                    .copyWith(color: AppTheme.secondaryInkOf(context)),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ServerDisplay.mask(_baseUrl),
                        style: context.text.bodyMedium!.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (_lastPingMs != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _pingSuccess == true
                              ? (isDark
                                  ? const Color(0xFF34C759)
                                      .withValues(alpha: 0.2)
                                  : AppTheme.successSubtle)
                              : (isDark
                                  ? const Color(0xFFFF3B30)
                                      .withValues(alpha: 0.2)
                                  : AppTheme.dangerSubtle),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_lastPingMs}ms',
                          style: context.text.labelMedium!.copyWith(
                            color: _pingSuccess == true
                                ? AppTheme.successInkOf(context)
                                : AppTheme.dangerInkOf(context),
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
                      : const Icon(CupertinoIcons.waveform_path_ecg, size: 24),
                  label: Text(_isTestingPing
                      ? 'Testing latency...'
                      : 'Test Connection Latency'),
                ),
              ),
            ],
          ),

          // Section 6: Session & Logout Action
          _buildIosSectionHeader('Account Session'),
          _buildIosGroupedCard(
            isDark: isDark,
            children: [
              _buildIosSettingRow(
                icon: CupertinoIcons.square_arrow_left,
                iconBg: AppTheme.danger,
                title: 'Sign Out of Terminal',
                isDark: isDark,
                showDivider: false,
                onTap: _handleLogout,
                trailing: const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 24,
                  color: AppTheme.danger,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // App build info
          Center(
            child: Text(
              '${AppConstants.appName} v${AppConstants.appVersion}\nSwitch Fiber Philippines • Dispatch Ops',
              textAlign: TextAlign.center,
              style: context.text.labelSmall,
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
        color: isDark
            ? const Color(0xFF34C759).withValues(alpha: 0.2)
            : AppTheme.successSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark
              ? const Color(0xFF34C759).withValues(alpha: 0.35)
              : const Color(0xFFBBF7D0),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.checkmark_shield_fill,
            size: 20,
            color: isDark ? const Color(0xFF4ADE80) : AppTheme.success,
          ),
          const SizedBox(width: 4),
          Text(
            'SSL Pinned (SHA-256)',
            style: context.text.labelMedium!
                .copyWith(color: AppTheme.successInkOf(context)),
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
    // Call sites only ever pass one of these three brand/status fills (or
    // leave it null for the default ink); route whichever was passed to the
    // ink that matches so the value never renders in the bright colour.
    final Color? valueInk = badgeColor == null
        ? null
        : badgeColor == AppTheme.success
            ? AppTheme.successInkOf(context)
            : badgeColor == AppTheme.warning
                ? AppTheme.warningInkOf(context)
                : AppTheme.brandInkOf(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: context.text.bodySmall,
          ),
        ),
        Text(
          value,
          style: context.text.labelMedium!.copyWith(
            color: valueInk ??
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppTheme.darkSlate),
          ),
        ),
      ],
    );
  }
}
