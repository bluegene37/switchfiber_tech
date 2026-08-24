import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/lcp_nap_model.dart';

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
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    location.lcpNap,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Close',
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined,
                    size: 15, color: AppTheme.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
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
                // Total capacity only: the API does not report occupancy.
                _Stat(
                  icon: Icons.hub_outlined,
                  label: '${location.portTotal} ports',
                ),
                _Stat(
                  icon: Icons.my_location_rounded,
                  label: location.coordinates ?? '',
                ),
              ],
            ),
            if (_provenance != null) ...[
              const SizedBox(height: 8),
              Text(
                _provenance!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onOpenDetails,
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('View full details'),
              ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primarySubtleBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.primaryActive),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryActive,
            ),
          ),
        ],
      ),
    );
  }
}
