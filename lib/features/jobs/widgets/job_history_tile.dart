import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../models/job_order_model.dart';
import 'status_badge.dart';

/// One row of the technician's job history with iOS Inset Grouped styling.
class JobHistoryTile extends StatelessWidget {
  final JobOrderDto job;
  final VoidCallback? onTap;

  const JobHistoryTile({super.key, required this.job, this.onTap});

  static final _dateFormat = DateFormat('MMM d, yyyy');

  /// The date shown for [job], or null when nothing is known.
  static String? dateLabel(JobOrderDto job) {
    final d = job.historyDate;
    return d == null ? null : _dateFormat.format(d);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted;
    final date = dateLabel(job);
    final power = job.opticalPower;

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
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusDot(job: job, isDark: isDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              job.ticketNumber,
                              style: context.text.titleSmall,
                              overflow: TextOverflow.ellipsis,
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
                      const SizedBox(height: 4),
                      Text(
                        job.customerName,
                        style: context.text.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          job.address,
                          if (job.barangay?.isNotEmpty == true) job.barangay!,
                          if (job.city?.isNotEmpty == true) job.city!,
                        ].join(', '),
                        style: context.text.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Meta(
                            icon: CupertinoIcons.calendar,
                            text: date ?? 'No date recorded',
                            color: muted,
                          ),
                          if (job.planName?.isNotEmpty == true)
                            _Meta(
                              icon: CupertinoIcons.wifi,
                              text: job.planName!,
                              color: muted,
                            ),
                          if (power != null)
                            _Meta(
                              icon: CupertinoIcons.speedometer,
                              text: '${power.toStringAsFixed(1)} dBm',
                              color: _opticalColor(power),
                              bold: true,
                            ),
                          if (!job.isSynced)
                            const _Meta(
                              icon: CupertinoIcons.cloud_upload,
                              text: 'Awaiting sync',
                              color: AppTheme.warning,
                              bold: true,
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

  static Color _opticalColor(double dbm) {
    if (dbm >= AppConstants.opticalMinOptimal &&
        dbm <= AppConstants.opticalMaxOptimal) {
      return AppTheme.success;
    }
    if (dbm >= AppConstants.opticalMarginalFloor &&
        dbm < AppConstants.opticalMinOptimal) {
      return AppTheme.warning;
    }
    return AppTheme.danger;
  }
}

/// A coloured marker that reads as a timeline node down the left edge.
class _StatusDot extends StatelessWidget {
  final JobOrderDto job;
  final bool isDark;

  const _StatusDot({required this.job, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData icon) = switch (job.siteException) {
      SiteException.failed => (
          AppTheme.danger,
          CupertinoIcons.exclamationmark_triangle_fill
        ),
      SiteException.reschedule => (
          const Color(0xFF7C3AED),
          CupertinoIcons.arrow_counterclockwise
        ),
      null => switch (job.jobStatus) {
          JobStatus.activated => (
              const Color(0xFF4F46E5),
              CupertinoIcons.checkmark_seal_fill
            ),
          JobStatus.completed => (
              AppTheme.success,
              CupertinoIcons.checkmark_circle_fill
            ),
          JobStatus.scheduled || null => (
              AppTheme.info,
              CupertinoIcons.calendar
            ),
        },
    };

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.5,
        ),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool bold;

  const _Meta({
    required this.icon,
    required this.text,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: (bold ? context.text.labelMedium : context.text.labelSmall)!
              .copyWith(color: _inkFor(context, color)),
        ),
      ],
    );
  }
}

/// Maps a `_Meta` fill colour (a bright status token or the neutral "muted"
/// grey) to the ink safe for text.
Color _inkFor(BuildContext context, Color fill) {
  if (fill == AppTheme.success) return AppTheme.successInkOf(context);
  if (fill == AppTheme.warning) return AppTheme.warningInkOf(context);
  if (fill == AppTheme.danger) return AppTheme.dangerInkOf(context);
  if (fill == AppTheme.info) return AppTheme.infoInkOf(context);
  return AppTheme.secondaryInkOf(context);
}
