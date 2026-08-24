import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/job_order_model.dart';

/// Status pill for a job order, matching the Switch Fiber design system with full Dark Mode support.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exception = siteException;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _Pill(
          label: status?.label ??
              (rawStatus.trim().isEmpty ? 'Scheduled' : rawStatus.trim()),
          icon: _iconFor(status),
          bg: _bgFor(status, isDark),
          fg: _fgFor(status, isDark),
          border: _borderFor(status, isDark),
        ),
        if (exception != null)
          _Pill(
            label: exception.label,
            icon: exception == SiteException.failed
                ? Icons.error_rounded
                : Icons.event_repeat_rounded,
            bg: isDark
                ? (exception == SiteException.failed
                    ? const Color(0xFFDC2626).withValues(alpha: 0.25)
                    : const Color(0xFF7C3AED).withValues(alpha: 0.25))
                : (exception == SiteException.failed
                    ? AppTheme.dangerSubtle
                    : const Color(0xFFF5F3FF)),
            fg: isDark
                ? (exception == SiteException.failed
                    ? const Color(0xFFF87171)
                    : const Color(0xFFA78BFA))
                : (exception == SiteException.failed
                    ? const Color(0xFF8B1A25)
                    : const Color(0xFF5B21B6)),
            border: isDark
                ? (exception == SiteException.failed
                    ? const Color(0xFFDC2626).withValues(alpha: 0.4)
                    : const Color(0xFF7C3AED).withValues(alpha: 0.4))
                : (exception == SiteException.failed
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFDDD6FE)),
          ),
      ],
    );
  }

  static IconData _iconFor(JobStatus? s) => switch (s) {
        JobStatus.scheduled => Icons.calendar_today_rounded,
        JobStatus.inProgress => Icons.access_time_filled_rounded,
        JobStatus.completed => Icons.check_circle_rounded,
        JobStatus.activated => Icons.verified_rounded,
        null => Icons.calendar_today_rounded,
      };

  static Color _bgFor(JobStatus? s, bool isDark) {
    if (isDark) {
      return switch (s) {
        JobStatus.scheduled => const Color(0xFF0369A1).withValues(alpha: 0.25),
        JobStatus.inProgress => const Color(0xFFD97706).withValues(alpha: 0.25),
        JobStatus.completed => const Color(0xFF059669).withValues(alpha: 0.25),
        JobStatus.activated => const Color(0xFF4F46E5).withValues(alpha: 0.25),
        null => const Color(0xFF0369A1).withValues(alpha: 0.25),
      };
    }
    return switch (s) {
      JobStatus.scheduled => const Color(0xFFF0F9FF),
      JobStatus.inProgress => AppTheme.warningSubtle,
      JobStatus.completed => AppTheme.successSubtle,
      JobStatus.activated => const Color(0xFFEFF6FF),
      null => const Color(0xFFF0F9FF),
    };
  }

  static Color _fgFor(JobStatus? s, bool isDark) {
    if (isDark) {
      return switch (s) {
        JobStatus.scheduled => const Color(0xFF38BDF8),
        JobStatus.inProgress => const Color(0xFFFBBF24),
        JobStatus.completed => const Color(0xFF4ADE80),
        JobStatus.activated => const Color(0xFF818CF8),
        null => const Color(0xFF38BDF8),
      };
    }
    return switch (s) {
      JobStatus.scheduled => const Color(0xFF0369A1),
      JobStatus.inProgress => const Color(0xFF92400E),
      JobStatus.completed => const Color(0xFF166534),
      JobStatus.activated => const Color(0xFF1E40AF),
      null => const Color(0xFF0369A1),
    };
  }

  static Color _borderFor(JobStatus? s, bool isDark) {
    if (isDark) {
      return switch (s) {
        JobStatus.scheduled => const Color(0xFF0284C7).withValues(alpha: 0.4),
        JobStatus.inProgress => const Color(0xFFD97706).withValues(alpha: 0.4),
        JobStatus.completed => const Color(0xFF059669).withValues(alpha: 0.4),
        JobStatus.activated => const Color(0xFF4F46E5).withValues(alpha: 0.4),
        null => const Color(0xFF0284C7).withValues(alpha: 0.4),
      };
    }
    return switch (s) {
      JobStatus.scheduled => const Color(0xFFBAE6FD),
      JobStatus.inProgress => const Color(0xFFFDE68A),
      JobStatus.completed => const Color(0xFF86EFAC),
      JobStatus.activated => const Color(0xFFBFDBFE),
      null => const Color(0xFFBAE6FD),
    };
  }
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
