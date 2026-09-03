import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                    size: 19,
                    color:
                        job.isActivated ? AppTheme.success : AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              job.ticketNumber,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!job.isSynced) ...[
                            const Icon(
                              CupertinoIcons.cloud_upload,
                              size: 14,
                              color: AppTheme.warning,
                            ),
                            const SizedBox(width: 6),
                          ],
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (job.planName?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Text(
                          job.planName!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(CupertinoIcons.location, size: 14, color: muted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(
                                fontSize: 13,
                                color: muted,
                                height: 1.25,
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
                            Icon(CupertinoIcons.phone, size: 14, color: muted),
                            const SizedBox(width: 4),
                            Text(
                              job.contactNumber!,
                              style: TextStyle(
                                fontSize: 13,
                                color: muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Icon(
                    CupertinoIcons.chevron_forward,
                    size: 16,
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
