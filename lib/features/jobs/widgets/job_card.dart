import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../models/job_order_model.dart';
import 'status_badge.dart';

/// A scheduled job order in the queue with native iOS card styling.
///
/// Features Apple HIG typography, squircle icon container, hairline border,
/// and trailing Cupertino chevron.
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
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // iOS Squircle Ticket Badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? (job.isActivated
                            ? const Color(0xFF34C759).withValues(alpha: 0.18)
                            : const Color(0xFF3F2327))
                        : (job.isActivated
                            ? AppTheme.successSubtle
                            : AppTheme.primarySubtleBg),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? (job.isActivated
                              ? const Color(0xFF34C759).withValues(alpha: 0.3)
                              : AppTheme.primary.withValues(alpha: 0.3))
                          : (job.isActivated
                              ? const Color(0xFFBBF7D0)
                              : AppTheme.primarySubtleBorder),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    job.isActivated
                        ? CupertinoIcons.checkmark_seal_fill
                        : CupertinoIcons.calendar,
                    size: 20,
                    color:
                        job.isActivated ? AppTheme.success : AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A Wrap, not a Row: the ticket number and the status
                      // badge each need their own room, and neither is
                      // squeezable, so when they don't both fit on one line
                      // at 200% text the badge flows to its own line below
                      // instead of the badge's own pill overflowing.
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            job.ticketNumber,
                            style: context.text.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!job.isSynced)
                            const Icon(
                              CupertinoIcons.cloud_upload,
                              size: 20,
                              color: AppTheme.warning,
                            ),
                          StatusBadge(
                            status: job.jobStatus,
                            rawStatus: job.status,
                            siteException: job.siteException,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        job.customerName,
                        style: context.text.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (job.planName?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          job.planName!,
                          style: context.text.labelMedium!.copyWith(
                            color: AppTheme.brandInkOf(context),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(CupertinoIcons.location, size: 20, color: muted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: context.text.bodySmall,
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
                            Icon(CupertinoIcons.phone, size: 20, color: muted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                job.contactNumber!,
                                style: context.text.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Quick Action Pills
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (job.contactNumber?.isNotEmpty == true) ...[
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () async {
                                final uri =
                                    Uri.parse('tel:${job.contactNumber!}');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minHeight: 48),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isDark
                                            ? AppTheme.borderDark
                                            : AppTheme.borderLight,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(CupertinoIcons.phone_fill,
                                            size: 24,
                                            color: Color(0xFF10B981)),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'Call',
                                            style: context.text.labelLarge,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              final latLng = job.latLng;
                              final Uri uri;
                              if (latLng != null) {
                                uri = Uri.parse(
                                    'https://maps.apple.com/?q=${latLng.latitude},${latLng.longitude}');
                              } else {
                                final fullAddr =
                                    '${job.address}${job.barangay != null ? ", ${job.barangay}" : ""}${job.city != null ? ", ${job.city}" : ""}, Philippines';
                                uri = Uri.parse(
                                    'https://maps.apple.com/?q=${Uri.encodeComponent(fullAddr)}');
                              }
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            },
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 48),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark
                                          ? AppTheme.borderDark
                                          : AppTheme.borderLight,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                          CupertinoIcons.location_north_fill,
                                          size: 24,
                                          color: AppTheme.primary),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Directions',
                                          style: context.text.labelLarge,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (job.nap?.isNotEmpty == true ||
                              (job.napId != null && job.napId! > 0))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.hub_rounded,
                                      size: 20, color: Color(0xFF0284C7)),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      job.nap?.isNotEmpty == true
                                          ? job.nap!
                                          : 'NAP-${job.napId}',
                                      style: context.text.labelLarge!.copyWith(
                                        color: AppTheme.infoInkOf(context),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Icon(
                    CupertinoIcons.chevron_forward,
                    size: 20,
                    color: muted.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
