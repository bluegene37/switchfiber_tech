import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/data_url.dart';
import '../../reports/widgets/photo_capture_tile.dart' show showPhotoViewer;
import '../models/job_order_model.dart';

/// Read-only grid of the photo proofs and signature attached to a job.
///
/// Inline images open a zoomable viewer; values the app cannot render (paths
/// the office uploaded) are listed as stored on the server.
class JobPhotoGallery extends StatelessWidget {
  final JobOrderDto job;

  const JobPhotoGallery({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted;

    final entries = <(String, String)>[
      for (final p in JobPhoto.values)
        if (job.hasImage(p)) (p.label, job.imageFor(p)!),
      if (job.hasSignature) ('Subscriber Signature', job.clientSignature!),
    ];

    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.no_photography_outlined, size: 18, color: muted),
            const SizedBox(width: 8),
            Text('No photos attached yet',
                style: TextStyle(fontSize: 12, color: muted)),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final (label, value) = entries[index];
        final bytes = DataUrl.decode(value);
        return _PhotoThumb(
          label: label,
          bytes: bytes,
          isDark: isDark,
          onTap: bytes == null
              ? null
              : () => showPhotoViewer(context, bytes, title: label),
        );
      },
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final String label;
  final Uint8List? bytes;
  final bool isDark;
  final VoidCallback? onTap;

  const _PhotoThumb({
    required this.label,
    required this.bytes,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted;
    final data = bytes;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: data != null
                  ? Image.memory(
                      data,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_done_rounded,
                              size: 22, color: AppTheme.success),
                          const SizedBox(height: 4),
                          Text('On server',
                              style: TextStyle(fontSize: 10, color: muted)),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
