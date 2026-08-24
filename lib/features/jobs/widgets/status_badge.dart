import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/job_order_model.dart';

/// Status pill badge matching Switch Fiber design system.
///
/// Shows the technician's on-site workflow state using the vocabulary the
/// Switch Fiber API actually returns.
class StatusBadge extends StatelessWidget {
  final FieldStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final Color borderColor;
    final IconData icon;

    switch (status) {
      case FieldStatus.inProgress:
        bgColor = AppTheme.warningSubtle;
        textColor = const Color(0xFF92400E);
        borderColor = const Color(0xFFFDE68A);
        icon = Icons.access_time_filled_rounded;
      case FieldStatus.done:
        bgColor = AppTheme.successSubtle;
        textColor = const Color(0xFF166534);
        borderColor = const Color(0xFF86EFAC);
        icon = Icons.check_circle_rounded;
      case FieldStatus.failed:
        bgColor = AppTheme.dangerSubtle;
        textColor = const Color(0xFF8B1A25);
        borderColor = const Color(0xFFFCA5A5);
        icon = Icons.error_rounded;
      case FieldStatus.reschedule:
        bgColor = const Color(0xFFF5F3FF);
        textColor = const Color(0xFF5B21B6);
        borderColor = const Color(0xFFDDD6FE);
        icon = Icons.event_repeat_rounded;
      case FieldStatus.dispatched:
        bgColor = AppTheme.infoSubtle;
        textColor = const Color(0xFF075985);
        borderColor = const Color(0xFFBAE6FD);
        icon = Icons.pending_rounded;
    }

    final label = status.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
