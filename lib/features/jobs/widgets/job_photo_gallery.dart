import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_text.dart';
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
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.camera, size: 20, color: muted),
            const SizedBox(width: 8),
            Text('No photos attached yet', style: context.text.bodySmall),
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
    final data = bytes;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: data != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(
                          data,
                          cacheWidth: 300,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                        // GPS Badge
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(CupertinoIcons.location_fill,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 2),
                                Text(
                                  'GPS',
                                  style: context.text.labelMedium!
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_done_rounded,
                              size: 22, color: AppTheme.success),
                          const SizedBox(height: 4),
                          Text('On server', style: context.text.labelSmall),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: context.text.labelMedium,
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
