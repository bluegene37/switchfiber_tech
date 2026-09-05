import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../models/job_order_model.dart';
import 'status_badge.dart';
import '../../../core/services/map_navigation_service.dart';

/// A scheduled job order in the queue with modern rugged field instrument styling.
///
/// Features Apple HIG / Stitch ergonomics, JetBrains Mono ticket HUD,
/// hairline border, clear operational hierarchy, and partitioned 48dp action footer.
class JobCard extends StatelessWidget {
  final JobOrderDto job;
  final VoidCallback? onTap;

  const JobCard({super.key, required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted;
    final location = [
      job.address,
      if (job.barangay?.isNotEmpty == true) job.barangay!,
      if (job.city?.isNotEmpty == true) job.city!,
    ].join(', ');

    // Calculate distance from technician if coordinates available
    String? distanceStr;
    final myPos = LocationService.instance.lastKnownPosition;
    final jobPos = job.latLng;
    if (myPos != null && jobPos != null) {
      final meters = LocationService.instance.distanceBetween(
        startLat: myPos.latitude,
        startLng: myPos.longitude,
        endLat: jobPos.latitude,
        endLng: jobPos.longitude,
      );
      distanceStr = LocationService.instance.formatDistance(meters);
    }

    final napText = job.nap?.isNotEmpty == true
        ? job.nap!
        : (job.napId != null && job.napId! > 0 ? 'NAP-${job.napId}' : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upper Card Content (Tappable for details)
            InkWell(
              onTap: onTap,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Ticket ID + Unsynced icon + Distance + Status Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                job.ticketNumber,
                                style: context.text.titleSmall?.copyWith(
                                  fontFamily: 'JetBrains Mono',
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (!job.isSynced)
                                const Icon(
                                  CupertinoIcons.cloud_upload,
                                  size: 18,
                                  color: AppTheme.warning,
                                ),
                              if (distanceStr != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.darkInput
                                        : AppTheme.fillLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.location_circle,
                                        size: 20,
                                        color: AppTheme.secondaryInkOf(context),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '$distanceStr away',
                                        style: context.text.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              AppTheme.secondaryInkOf(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          status: job.jobStatus,
                          rawStatus: job.status,
                          siteException: job.siteException,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Customer Name
                    Text(
                      job.customerName,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Plan & NAP Badges Row
                    if (job.planName?.isNotEmpty == true ||
                        napText != null) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (job.planName?.isNotEmpty == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.primarySubtleBgDark
                                    : AppTheme.primarySubtleBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.primarySubtleBorderDark
                                      : AppTheme.primarySubtleBorder,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                job.planName!,
                                style: context.text.labelMedium!.copyWith(
                                  color: AppTheme.brandInkOf(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (napText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0369A1)
                                        .withValues(alpha: 0.18)
                                    : const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF0284C7)
                                          .withValues(alpha: 0.35)
                                      : const Color(0xFFBAE6FD),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.hub_outlined,
                                    size: 20,
                                    color: Color(0xFF0284C7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    napText,
                                    style: context.text.labelMedium!.copyWith(
                                      color: AppTheme.infoInkOf(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Location Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          CupertinoIcons.location_solid,
                          size: 20,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            style: context.text.bodySmall?.copyWith(
                              color: AppTheme.secondaryInkOf(context),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    if (job.contactNumber?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(CupertinoIcons.phone, size: 18, color: muted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              job.contactNumber!,
                              style: context.text.bodySmall?.copyWith(
                                color: muted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 0.5px Hairline Divider
            Divider(
              height: 0.5,
              thickness: 0.5,
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            ),

            // Partitioned Action Footer (Directions & Call - 48dp touch targets)
            Row(
              children: [
                // Directions Button
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final latLng = job.latLng;
                      if (latLng != null) {
                        await MapNavigationService.navigateToCoordinates(
                          latitude: latLng.latitude,
                          longitude: latLng.longitude,
                          destinationLabel: job.customerName,
                        );
                      } else {
                        final fullAddr =
                            '${job.address}${job.barangay != null ? ", ${job.barangay}" : ""}${job.city != null ? ", ${job.city}" : ""}, Philippines';
                        await MapNavigationService.navigateToAddress(fullAddr);
                      }
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.location_north_fill,
                                  size: 18,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Directions',
                                  style: context.text.labelLarge!.copyWith(
                                    color: AppTheme.brandInkOf(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Vertical Divider
                Container(
                  width: 0.5,
                  height: 48,
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),

                // Call Button
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      if (job.contactNumber?.isNotEmpty == true) {
                        final uri = Uri.parse('tel:${job.contactNumber!}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      }
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.phone_fill,
                                  size: 18,
                                  color: job.contactNumber?.isNotEmpty == true
                                      ? const Color(0xFF10B981)
                                      : muted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Call',
                                  style: context.text.labelLarge!.copyWith(
                                    color: job.contactNumber?.isNotEmpty == true
                                        ? AppTheme.successInkOf(context)
                                        : muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
