import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../models/job_order_model.dart';
import 'status_badge.dart';

/// One row of the technician's job history.
///
/// Leaner than [JobCard]: the history is a record of work done, not a queue
/// of actions, so it shows when and where rather than what to do next.
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

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
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
                      style: TextStyle(fontSize: 12, color: muted),
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
                          icon: Icons.event_rounded,
                          text: date ?? 'No date recorded',
                          color: muted,
                        ),
                        if (job.planName?.isNotEmpty == true)
                          _Meta(
                            icon: Icons.wifi_rounded,
                            text: job.planName!,
                            color: muted,
                          ),
                        if (power != null)
                          _Meta(
                            icon: Icons.speed_rounded,
                            text: '${power.toStringAsFixed(1)} dBm',
                            color: _opticalColor(power),
                            bold: true,
                          ),
                        if (!job.isSynced)
                          const _Meta(
                            icon: Icons.cloud_off_rounded,
                            text: 'Awaiting sync',
                            color: AppTheme.warning,
                            bold: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 20, color: muted),
            ],
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
      SiteException.failed => (AppTheme.danger, Icons.error_rounded),
      SiteException.reschedule => (
          const Color(0xFF7C3AED),
          Icons.event_repeat_rounded
        ),
      null => switch (job.jobStatus) {
          JobStatus.activated => (
              const Color(0xFF4F46E5),
              Icons.verified_rounded
            ),
          JobStatus.completed => (AppTheme.success, Icons.check_rounded),
          JobStatus.inProgress => (AppTheme.warning, Icons.build_rounded),
          JobStatus.scheduled || null => (
              AppTheme.info,
              Icons.calendar_today_rounded
            ),
        },
    };

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Icon(icon, size: 17, color: color),
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
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
