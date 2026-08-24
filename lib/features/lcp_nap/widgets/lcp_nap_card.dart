import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/lcp_nap_model.dart';

/// Card widget representing an individual LCP NAP plant location.
class LcpNapCard extends StatelessWidget {
  final LcpNapDto location;
  final VoidCallback onTap;
  final VoidCallback onCycleStatus;

  const LcpNapCard({
    super.key,
    required this.location,
    required this.onTap,
    required this.onCycleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeBg, badgeFg, badgeBorder) = _getStatusColors(location.status);
    final utilization = location.utilizationRate;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: LCP/NAP Header & Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySubtleBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      location.lcp,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '•',
                    style: TextStyle(
                      color: AppTheme.textMuted.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location.nap,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: badgeBorder),
                    ),
                    child: Text(
                      location.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeFg,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Location / Address row
              if (location.barangay != null || location.city != null)
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 15, color: AppTheme.textMuted),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        [location.barangay, location.city]
                            .where((s) => s != null && s.isNotEmpty)
                            .join(', '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.darkSlate,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              // GPS Coordinates Pill (if present)
              if (location.coordinates != null &&
                  location.coordinates!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.gps_fixed_rounded,
                        size: 13, color: AppTheme.textMuted),
                    const SizedBox(width: 5),
                    Text(
                      location.coordinates!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1, color: AppTheme.borderLight),
              const SizedBox(height: 10),

              // Port Capacity Utilization Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ports Occupancy (${location.portOccupied}/${location.portTotal})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    '${(utilization * 100).toInt()}% utilized',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: utilization > 0.85
                          ? AppTheme.danger
                          : (utilization > 0.6
                              ? AppTheme.warning
                              : AppTheme.success),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: utilization,
                  minHeight: 6,
                  backgroundColor: AppTheme.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    utilization >= 1.0
                        ? AppTheme.danger
                        : (utilization > 0.6
                            ? AppTheme.warning
                            : AppTheme.success),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Bottom Actions Row: Quick Status Cycle & Details prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: onCycleStatus,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.change_circle_outlined,
                              size: 14, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          const Text(
                            'Cycle Status',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 11, color: AppTheme.textMuted),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
