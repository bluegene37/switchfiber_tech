import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/lcp_nap_model.dart';

/// Card widget representing an individual LCP NAP plant location with iOS Inset Grouped styling.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: LCP/NAP Header & Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3F2327)
                            : AppTheme.primarySubtleBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.primary.withValues(alpha: 0.3)
                              : AppTheme.primarySubtleBorder,
                          width: 0.5,
                        ),
                      ),
                      child: const Text(
                        'LCP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${location.lcp} - ${location.nap}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    // Port capacity pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3F2327)
                            : AppTheme.primarySubtleBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF882933)
                              : AppTheme.primarySubtleBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '${location.portTotal} ports',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFFF8591)
                              : AppTheme.primaryActive,
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
                      Icon(
                        CupertinoIcons.location,
                        size: 14,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          [location.barangay, location.city]
                              .where((s) => s != null && s.isNotEmpty)
                              .join(', '),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : AppTheme.darkSlate,
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
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.scope,
                        size: 13,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        location.coordinates!,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),
                const SizedBox(height: 8),

                // Bottom Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'View Details & GPS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textMuted,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_forward,
                      size: 13,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
