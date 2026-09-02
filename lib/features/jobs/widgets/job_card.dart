import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/job_order_model.dart';
import 'status_badge.dart';

/// A scheduled job order in the queue.
///
/// Deliberately plain: the card identifies the ticket and where it is, and
/// tapping it opens the details. Every action, including activation, lives on
/// the detail screen so the list stays scannable on a phone in the field.
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

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3F2327)
                      : AppTheme.primarySubtleBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  job.isActivated
                      ? Icons.verified_rounded
                      : Icons.calendar_today_rounded,
                  size: 18,
                  color: job.isActivated ? AppTheme.success : AppTheme.primary,
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
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!job.isSynced) ...[
                          const Icon(Icons.cloud_off_rounded,
                              size: 14, color: AppTheme.warning),
                          const SizedBox(width: 6),
                        ],
                        StatusBadge(
                          status: job.jobStatus,
                          rawStatus: job.status,
                          siteException: job.siteException,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 15, color: muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(fontSize: 13, color: muted),
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
                          Icon(Icons.phone_outlined, size: 15, color: muted),
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
                padding: const EdgeInsets.only(top: 8),
                child:
                    Icon(Icons.chevron_right_rounded, size: 22, color: muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
