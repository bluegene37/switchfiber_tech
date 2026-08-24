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

        final (statusBg, statusFg, statusBorder) =
            _getStatusColors(location.status);

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
                              color: statusBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: statusBorder),
                            ),
                            child: Text(
                              location.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: statusFg,
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

              // 2. Interactive Status Modifier (Demonstrates Drift -> Signals -> UI Reactivity)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune_rounded,
                              size: 18, color: AppTheme.primary),
                          SizedBox(width: 8),
                          Text(
                            'Field Status Control (Live Drift DB)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap to update this site status. Notice how state updates immediately across the app via Signals and persists to Drift SQLite.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          _buildStatusButton(
                            context: context,
                            label: 'Active',
                            icon: Icons.check_circle_outline_rounded,
                            isSelected: location.status.toLowerCase() == 'active',
                            activeBg: AppTheme.successSubtle,
                            activeFg: const Color(0xFF166534),
                            onPressed: () => _updateStatus(context, 'Active'),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusButton(
                            context: context,
                            label: 'Maintenance',
                            icon: Icons.build_circle_outlined,
                            isSelected:
                                location.status.toLowerCase() == 'maintenance',
                            activeBg: AppTheme.warningSubtle,
                            activeFg: const Color(0xFF92400E),
                            onPressed: () =>
                                _updateStatus(context, 'Maintenance'),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusButton(
                            context: context,
                            label: 'Full',
                            icon: Icons.block_rounded,
                            isSelected: location.status.toLowerCase() == 'full',
                            activeBg: AppTheme.dangerSubtle,
                            activeFg: const Color(0xFF8B1A25),
                            onPressed: () => _updateStatus(context, 'Full'),
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
                            '${location.portOccupied} of ${location.portTotal} Occupied',
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
                          final isOccupied = portNumber <= location.portOccupied;

                          return Container(
                            decoration: BoxDecoration(
                              color: isOccupied
                                  ? const Color(0xFFF3F4F6)
                                  : AppTheme.successSubtle,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isOccupied
                                    ? AppTheme.borderLight
                                    : const Color(0xFF86EFAC),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isOccupied
                                        ? Icons.cable_rounded
                                        : Icons.circle_outlined,
                                    size: 14,
                                    color: isOccupied
                                        ? AppTheme.textMuted
                                        : const Color(0xFF166534),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'P$portNumber',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isOccupied
                                          ? AppTheme.textMuted
                                          : const Color(0xFF166534),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Port legend
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegendDot(
                            color: Color(0xFF166534),
                            label: 'Available Port',
                          ),
                          SizedBox(width: 20),
                          _LegendDot(
                            color: AppTheme.textMuted,
                            label: 'Occupied Port',
                          ),
                        ],
                      ),
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
              if (location.description != null &&
                  location.description!.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.notes_rounded,
                                size: 18, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text(
                              'Plant Remarks & Mounting Info',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          location.description!,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppTheme.darkSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color activeBg,
    required Color activeFg,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : AppTheme.lightBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeFg : AppTheme.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? activeFg : AppTheme.textMuted),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? activeFg : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateStatus(BuildContext context, String newStatus) async {
    await signals.updateSiteStatus(locationId, newStatus);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated status to $newStatus in Drift SQLite'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.darkSlate,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  (Color, Color, Color) _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return (
          AppTheme.successSubtle,
          const Color(0xFF166534),
          const Color(0xFFBBF7D0)
        );
      case 'maintenance':
        return (
          AppTheme.warningSubtle,
          const Color(0xFF92400E),
          const Color(0xFFFDE68A)
        );
      case 'full':
        return (
          AppTheme.dangerSubtle,
          const Color(0xFF8B1A25),
          const Color(0xFFFCA5A5)
        );
      default:
        return (
          AppTheme.lightBg,
          AppTheme.textMuted,
          AppTheme.borderLight
        );
    }
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}
