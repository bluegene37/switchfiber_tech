import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/map_navigation_service.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../models/lcp_nap_model.dart';
import '../services/map_clustering.dart';

/// Summary card shown when a technician taps a pin on the LCP NAP map.
///
/// Deliberately a summary: the full record lives in LcpNapDetailScreen, which
/// this opens rather than duplicates.
class LcpNapPinPopup extends StatelessWidget {
  final LcpNapDto location;
  final VoidCallback? onClose;
  final VoidCallback? onOpenDetails;

  const LcpNapPinPopup({
    super.key,
    required this.location,
    this.onClose,
    this.onOpenDetails,
  });

  String get _address {
    final parts = <String?>[
      location.street,
      location.barangay,
      location.city,
      location.region,
    ].where((p) => p != null && p.trim().isNotEmpty).cast<String>();
    return parts.isEmpty ? 'No address recorded' : parts.join(', ');
  }

  /// Who last touched the record on the server, so a technician knows how
  /// current the pin is.
  String? get _provenance {
    final who = location.modifiedBy?.trim().isNotEmpty == true
        ? location.modifiedBy!.trim()
        : location.userEmail?.trim();
    final when = location.modifiedDate;
    if (when == null && (who == null || who.isEmpty)) return null;
    final date = when == null
        ? null
        : '${when.year}-${when.month.toString().padLeft(2, '0')}'
            '-${when.day.toString().padLeft(2, '0')}';
    if (who == null || who.isEmpty) return 'Updated $date';
    return date == null ? 'Updated by $who' : 'Updated by $who on $date';
  }

  @override
  Widget build(BuildContext context) {
    final hue = lcpColorSeed(location.lcp);
    final cabinetColor = HSLColor.fromAHSL(1, hue, 0.62, 0.44).toColor();
    final latLng = location.latLng;

    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cabinetColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: cabinetColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cabinetColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        location.lcp,
                        style: context.text.labelSmall!.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cabinetColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location.lcpNap,
                    style: context.text.titleSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Close',
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_rounded,
                    size: 20, color: AppTheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _address,
                    style: context.text.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Wraps rather than overflowing: coordinate strings are long and
            // the popup is only as wide as the map.
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Stat(
                  icon: Icons.hub_outlined,
                  label: '${location.portTotal} ports',
                ),
                if (location.coordinates != null)
                  InkWell(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: location.coordinates!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Coordinates copied: ${location.coordinates}'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppTheme.darkCard
                                  : AppTheme.darkSlate,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: _Stat(
                      icon: Icons.my_location_rounded,
                      label: location.coordinates ?? '',
                    ),
                  ),
              ],
            ),
            if (_provenance != null) ...[
              const SizedBox(height: 8),
              Text(
                _provenance!,
                style: context.text.labelSmall!
                    .copyWith(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (latLng != null) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      MapNavigationService.showNavigationChooser(
                        context: context,
                        latitude: latLng.latitude,
                        longitude: latLng.longitude,
                        title: location.lcpNap,
                        subtitle: _address,
                      );
                    },
                    icon: const Icon(Icons.navigation_rounded, size: 24),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenDetails,
                    icon: const Icon(Icons.open_in_new_rounded, size: 24),
                    label: const Text('View details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3F2327) : AppTheme.primarySubtleBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? const Color(0xFFFF8591) : AppTheme.primaryActive,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.text.labelSmall!.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.brandInkOf(context),
            ),
          ),
        ],
      ),
    );
  }
}
