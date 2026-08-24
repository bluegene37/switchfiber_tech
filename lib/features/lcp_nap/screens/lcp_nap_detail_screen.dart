import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../signals/lcp_nap_signals.dart';

/// Screen displaying comprehensive details and status controls for an LCP NAP site.
class LcpNapDetailScreen extends StatelessWidget {
  final int locationId;
  final LcpNapSignals signals;

  const LcpNapDetailScreen({
    super.key,
    required this.locationId,
    required this.signals,
  });

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        // Fetch current site reactively from allLocations signal
        final all = signals.allLocations.value;
        final location = all.where((l) => l.id == locationId).firstOrNull;

        if (location == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Site Details')),
            body: const Center(child: Text('Location not found')),
          );
        }


        return Scaffold(
          appBar: AppBar(
            title: Text(
              location.lcpNap,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            actions: [
              // Offline sync badge
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: location.isSynced
                      ? AppTheme.successSubtle
                      : AppTheme.warningSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      location.isSynced
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_off_rounded,
                      size: 14,
                      color: location.isSynced
                          ? AppTheme.success
                          : const Color(0xFF92400E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location.isSynced ? 'Synced' : 'Drift SQLite (Local)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: location.isSynced
                            ? AppTheme.success
                            : const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Overview Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primarySubtleBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.router_rounded,
                                    color: AppTheme.primary, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location.lcpNap,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    '${location.lcp} Distribution Point',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primarySubtleBg,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppTheme.primarySubtleBorder),
                            ),
                            child: Text(
                              '${location.portTotal} ports',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryActive,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppTheme.borderLight),
                      const SizedBox(height: 14),

                      // Location hierarchy
                      Row(
                        children: [
                          const Icon(Icons.location_city_rounded,
                              size: 16, color: AppTheme.textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${location.barangay ?? "N/A"}, ${location.city ?? "Metro Manila"}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkSlate,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Port Allocation & Visual Grid
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.hub_outlined,
                                  size: 18, color: AppTheme.primary),
                              SizedBox(width: 8),
                              Text(
                                'Port Matrix & Capacity',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${location.portTotal} ports',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryActive,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Visual Ports Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.8,
                        ),
                        itemCount: location.portTotal,
                        itemBuilder: (context, index) {
                          final portNumber = index + 1;
                          // The API reports total ports only; which are in use
                          // is unknown, so no port is coloured as occupied.
                          return Container(
                            decoration: BoxDecoration(
                              color: AppTheme.lightBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.circle_outlined,
                                    size: 14,
                                    color: AppTheme.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'P$portNumber',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Port occupancy is not tracked by the backend, so no '
                        'port is shown as used.',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 12),

                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. GPS Geolocation Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.pin_drop_outlined,
                              size: 18, color: AppTheme.primary),
                          SizedBox(width: 8),
                          Text(
                            'GPS Geolocation Coordinates',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.lightBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'WGS84 Coordinates',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  location.coordinates ?? 'No GPS fix recorded',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            if (location.coordinates != null)
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 18),
                                tooltip: 'Copy coordinates',
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: location.coordinates!),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Copied: ${location.coordinates}'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppTheme.darkSlate,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Remarks / Plant Notes
            ],
          ),
        );
      },
    );
  }



}

