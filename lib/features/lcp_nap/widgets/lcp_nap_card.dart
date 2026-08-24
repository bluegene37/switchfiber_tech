import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/lcp_nap_model.dart';

/// Card widget representing an individual LCP NAP plant location.
class LcpNapCard extends StatelessWidget {
  final LcpNapDto location;
  final VoidCallback onTap;

  const LcpNapCard({
    super.key,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

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
                  // Port capacity. Occupancy is not reported by the API,
                  // so only the total is shown.
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySubtleBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primarySubtleBorder),
                    ),
                    child: Text(
                      '${location.portTotal} ports',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryActive,
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

              // Bottom Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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

}
