import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../models/radius_user_model.dart';
import '../services/radius_user_service.dart';

/// Card displaying live RADIUS subscriber PPPoE connection telemetry and 1-tap connect/disconnect toggle.
class RadiusConnectionCard extends StatefulWidget {
  final String accountName;
  final String? subscriberName;

  const RadiusConnectionCard({
    super.key,
    required this.accountName,
    this.subscriberName,
  });

  @override
  State<RadiusConnectionCard> createState() => _RadiusConnectionCardState();
}

class _RadiusConnectionCardState extends State<RadiusConnectionCard> {
  RadiusUserDto? _user;
  bool _isLoading = true;
  bool _isPending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    if (widget.accountName.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'No RADIUS account assigned';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await RadiusUserService.instance
          .fetchRadiusUserByName(widget.accountName);
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
        if (user == null) {
          _error = 'Account not found in RADIUS';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to check connection';
      });
    }
  }

  Future<void> _handleToggle(bool desired) async {
    if (_isPending || _user == null) return;

    final oldUser = _user!;
    setState(() {
      _isPending = true;
      // Optimistic update
      _user = RadiusUserDto(
        id: oldUser.id,
        name: oldUser.name,
        group: desired ? 'SwitchLite' : 'Disconnected',
        disabled: !desired,
        password: oldUser.password,
        sharedUsers: oldUser.sharedUsers,
      );
    });

    try {
      final ok = await RadiusUserService.instance
          .toggleConnection(widget.accountName, desired);
      if (!ok) throw Exception('API rejected connection change');

      // Re-fetch to synchronize with server group source of truth
      await _fetchStatus();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            desired
                ? 'Account ${widget.accountName} Connected successfully.'
                : 'Account ${widget.accountName} Disconnected.',
          ),
          backgroundColor: desired ? AppTheme.success : AppTheme.darkSlate,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Revert optimistic update
      setState(() => _user = oldUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${desired ? "connect" : "disconnect"}: $e'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isConnected = _user?.isConnected ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.wifi,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  'RADIUS PPPoE Connection',
                  style: context.text.titleMedium,
                ),
                const Spacer(),
                if (_isLoading)
                  const CupertinoActivityIndicator(radius: 8)
                else
                  IconButton(
                    onPressed: _fetchStatus,
                    icon:
                        const Icon(CupertinoIcons.arrow_2_circlepath, size: 24),
                    tooltip: 'Refresh connection status',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_circle,
                        size: 20, color: AppTheme.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Account: ${widget.accountName.isEmpty ? "(None)" : widget.accountName} — $_error',
                        style: context.text.bodySmall,
                      ),
                    ),
                  ],
                ),
              )
            else if (_user != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Status Indicator
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isConnected ? AppTheme.success : AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_user!.name, style: context.text.titleSmall),
                          Text(
                            'Group: ${_user!.group.isEmpty ? "None" : _user!.group} • ${isConnected ? "Online" : "Cut Off"}',
                            style: context.text.labelMedium!.copyWith(
                              color: isConnected
                                  ? AppTheme.successInkOf(context)
                                  : AppTheme.secondaryInkOf(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Connect / Disconnect Toggle
                    if (_isPending)
                      const CupertinoActivityIndicator()
                    else
                      CupertinoSwitch(
                        value: isConnected,
                        activeTrackColor: AppTheme.success,
                        onChanged: (val) => _handleToggle(val),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toggle to test subscriber line cut or reconnect after repair.',
                style: context.text.labelSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
