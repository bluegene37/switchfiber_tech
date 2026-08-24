import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/job_order_model.dart';

/// Status pill for a job order, matching the Switch Fiber design system.
///
/// Shows one of the three workflow statuses when the job has reached the field
/// workflow. Otherwise it shows the backend's own wording (`Applied`,
/// `Confirmed`) rather than inventing a status the record does not have.
///
/// A failed or rescheduled visit is shown as an extra pill, so those jobs stay
/// visible even though they are not one of the three statuses.
class StatusBadge extends StatelessWidget {
  final JobStatus? status;
  final String rawStatus;
  final SiteException? siteException;

  const StatusBadge({
    super.key,
    required this.status,
    this.rawStatus = '',
    this.siteException,
  });

  @override
  Widget build(BuildContext context) {
    final exception = siteException;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _Pill(
          label: status?.label ??
              (rawStatus.trim().isEmpty ? 'No status' : rawStatus.trim()),
          icon: _iconFor(status),
          bg: _bgFor(status),
          fg: _fgFor(status),
          border: _borderFor(status),
        ),
        if (exception != null)
          _Pill(
            label: exception.label,
            icon: exception == SiteException.failed
                ? Icons.error_rounded
                : Icons.event_repeat_rounded,
            bg: exception == SiteException.failed
                ? AppTheme.dangerSubtle
                : const Color(0xFFF5F3FF),
            fg: exception == SiteException.failed
                ? const Color(0xFF8B1A25)
                : const Color(0xFF5B21B6),
            border: exception == SiteException.failed
                ? const Color(0xFFFCA5A5)
                : const Color(0xFFDDD6FE),
          ),
      ],
    );
  }

  static IconData _iconFor(JobStatus? s) => switch (s) {
        JobStatus.inProgress => Icons.access_time_filled_rounded,
        JobStatus.completed => Icons.check_circle_rounded,
        JobStatus.activated => Icons.verified_rounded,
        null => Icons.pending_rounded,
      };

  static Color _bgFor(JobStatus? s) => switch (s) {
        JobStatus.inProgress => AppTheme.warningSubtle,
        JobStatus.completed => AppTheme.successSubtle,
        JobStatus.activated => const Color(0xFFEFF6FF),
        null => AppTheme.infoSubtle,
      };

  static Color _fgFor(JobStatus? s) => switch (s) {
        JobStatus.inProgress => const Color(0xFF92400E),
        JobStatus.completed => const Color(0xFF166534),
        JobStatus.activated => const Color(0xFF1E40AF),
        null => const Color(0xFF075985),
      };

  static Color _borderFor(JobStatus? s) => switch (s) {
        JobStatus.inProgress => const Color(0xFFFDE68A),
        JobStatus.completed => const Color(0xFF86EFAC),
        JobStatus.activated => const Color(0xFFBFDBFE),
        null => const Color(0xFFBAE6FD),
      };
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color border;

  const _Pill({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
