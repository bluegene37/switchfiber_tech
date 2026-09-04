import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';

/// Network Diagnostic Tool for Field Technicians (Ping, DNS, IP/VLAN calculator).
class NetworkDiagnosticTool extends StatefulWidget {
  const NetworkDiagnosticTool({super.key});

  @override
  State<NetworkDiagnosticTool> createState() => _NetworkDiagnosticToolState();
}

class _PingTarget {
  final String label;
  final String host;
  final int port;
  int? latencyMs;
  bool? isSuccess;
  bool isTesting = false;

  _PingTarget({
    required this.label,
    required this.host,
    this.port = 53,
  });
}

class _NetworkDiagnosticToolState extends State<NetworkDiagnosticTool> {
  final List<_PingTarget> _targets = [
    _PingTarget(
        label: 'Switch Fiber API', host: 'api.switchfiber.ph', port: 443),
    _PingTarget(label: 'Google Public DNS', host: '8.8.8.8', port: 53),
    _PingTarget(label: 'Cloudflare DNS', host: '1.1.1.1', port: 53),
    _PingTarget(label: 'OpenDNS Resolver', host: '208.67.222.222', port: 53),
  ];

  final TextEditingController _customHostController = TextEditingController();
  bool _isTestingAll = false;

  // Subnet calculator state
  String _selectedCidr = '/29';
  final Map<String, Map<String, String>> _cidrProfiles = {
    '/24': {
      'mask': '255.255.255.0',
      'usable': '254 hosts',
      'usage': 'LAN Subnet / Corporate Office'
    },
    '/28': {
      'mask': '255.255.255.240',
      'usable': '14 hosts',
      'usage': 'Multi-IP Business Pool'
    },
    '/29': {
      'mask': '255.255.255.248',
      'usable': '6 hosts',
      'usage': 'Standard Static IP Block (5 Usable)'
    },
    '/30': {
      'mask': '255.255.255.252',
      'usable': '2 hosts',
      'usage': 'Point-to-Point WAN / Router Interconnect'
    },
    '/10 (CGNAT)': {
      'mask': '255.192.0.0',
      'usable': '4,194,302 hosts',
      'usage': 'RFC 6598 Carrier-Grade NAT (100.64.0.0/10)'
    },
  };

  @override
  void dispose() {
    _customHostController.dispose();
    super.dispose();
  }

  Future<void> _pingHost(_PingTarget target) async {
    setState(() {
      target.isTesting = true;
      target.isSuccess = null;
    });

    final sw = Stopwatch()..start();
    try {
      final socket = await Socket.connect(
        target.host,
        target.port,
        timeout: const Duration(seconds: 4),
      );
      sw.stop();
      socket.destroy();

      if (!mounted) return;
      setState(() {
        target.isTesting = false;
        target.isSuccess = true;
        target.latencyMs = sw.elapsedMilliseconds;
      });
    } catch (_) {
      sw.stop();
      if (!mounted) return;
      setState(() {
        target.isTesting = false;
        target.isSuccess = false;
        target.latencyMs = null;
      });
    }
  }

  Future<void> _pingAll() async {
    setState(() => _isTestingAll = true);
    for (final t in _targets) {
      await _pingHost(t);
    }
    if (mounted) setState(() => _isTestingAll = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Network Diagnostics', style: context.text.titleMedium),
            Text('Ping, DNS latency & Subnet calculator',
                style: context.text.bodySmall),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Latency & Ping Matrix Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.network_ping_rounded,
                              size: 18, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Field Latency & DNS Ping',
                            style: context.text.titleMedium,
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _isTestingAll ? null : _pingAll,
                        icon: _isTestingAll
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.play_arrow_rounded, size: 24),
                        label: Text('Test All',
                            style: context.text.labelLarge!
                                .copyWith(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _targets.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: isDark
                            ? AppTheme.borderDark
                            : AppTheme.borderLight),
                    itemBuilder: (context, index) {
                      final t = _targets[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: t.isSuccess == true
                                    ? AppTheme.success
                                    : t.isSuccess == false
                                        ? AppTheme.danger
                                        : AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.label, style: context.text.titleSmall),
                                  Text(
                                    '${t.host}:${t.port}',
                                    style: context.text.bodyMedium!
                                        .copyWith(fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                            ),
                            if (t.isTesting)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppTheme.primary),
                              )
                            else if (t.latencyMs != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: t.latencyMs! < 50
                                      ? (isDark
                                          ? const Color(0xFF059669)
                                              .withValues(alpha: 0.25)
                                          : AppTheme.successSubtle)
                                      : (isDark
                                          ? const Color(0xFF78350F)
                                              .withValues(alpha: 0.25)
                                          : AppTheme.warningSubtle),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${t.latencyMs} ms',
                                  style: context.text.titleSmall!.copyWith(
                                    color: t.latencyMs! < 50
                                        ? AppTheme.successInkOf(context)
                                        : AppTheme.warningInkOf(context),
                                  ),
                                ),
                              )
                            else if (t.isSuccess == false)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF7F1D1D)
                                          .withValues(alpha: 0.25)
                                      : AppTheme.dangerSubtle,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Timeout',
                                  style: context.text.labelSmall!.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.dangerInkOf(context)),
                                ),
                              )
                            else
                              IconButton(
                                icon:
                                    const Icon(Icons.refresh_rounded, size: 18),
                                onPressed: () => _pingHost(t),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. IP & Subnet Mask Quick Reference
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.dns_rounded,
                          size: 18, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'IP Subnet & CGNAT Helper',
                        style: context.text.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCidr,
                    decoration: const InputDecoration(
                        labelText: 'CIDR Prefix / Block Size'),
                    items: _cidrProfiles.keys
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCidr = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isDark
                              ? AppTheme.borderDark
                              : AppTheme.borderLight),
                    ),
                    child: Column(
                      children: [
                        _buildSubnetRow(context, 'Subnet Mask',
                            _cidrProfiles[_selectedCidr]!['mask']!),
                        const SizedBox(height: 6),
                        _buildSubnetRow(context, 'Usable Hosts',
                            _cidrProfiles[_selectedCidr]!['usable']!),
                        const SizedBox(height: 6),
                        _buildSubnetRow(context, 'Common Use',
                            _cidrProfiles[_selectedCidr]!['usage']!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. ONT Default Gateway Web IP Quick Access
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.router_outlined,
                          size: 18, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Standard ONT Gateway Addresses',
                        style: context.text.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildOntRow(context, 'Huawei EG8145V5 / HG8145',
                      '192.168.100.1', isDark),
                  _buildOntRow(
                      context, 'ZTE F670L / F660', '192.168.1.1', isDark),
                  _buildOntRow(context, 'FiberHome HG680 / AN5506',
                      '192.168.1.1', isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubnetRow(BuildContext context, String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.text.bodySmall),
        Flexible(
          child: Text(
            val,
            textAlign: TextAlign.end,
            style: context.text.titleSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildOntRow(
      BuildContext context, String model, String ip, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(model, style: context.text.bodyMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkInput : AppTheme.primarySubtleBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(ip,
                style: context.text.labelSmall!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandInkOf(context))),
          ),
        ],
      ),
    );
  }
}
