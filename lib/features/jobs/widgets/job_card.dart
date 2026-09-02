import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../models/job_order_model.dart';
import 'status_badge.dart';

/// Technician Job Card displaying subscriber details, status indicators, and quick action triggers.
class JobCard extends StatelessWidget {
  final JobOrderDto job;
  final VoidCallback? onTap;
  final VoidCallback? onOpenDetails;
  final VoidCallback? onCycleStatus;
  final VoidCallback? onOpenReport;
  final VoidCallback? onGrabJob;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onOpenDetails,
    this.onCycleStatus,
    this.onOpenReport,
    this.onGrabJob,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isScheduled = job.isScheduled;
    final isInProgress = job.isInProgress;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap ?? onOpenDetails ?? onOpenReport,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Ticket # + Plan Tag + Status + Sync Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3F2327)
                              : AppTheme.primarySubtleBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isScheduled
                              ? Icons.calendar_today_rounded
                              : (isInProgress
                                  ? Icons.build_circle_rounded
                                  : Icons.check_circle_rounded),
                          size: 16,
                          color: isScheduled
                              ? AppTheme.info
                              : (isInProgress
                                  ? AppTheme.primary
                                  : AppTheme.success),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        job.ticketNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Sync indicator
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        child: job.isSynced
                            ? const Icon(
                                Icons.cloud_done_rounded,
                                size: 16,
                                color: AppTheme.success,
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF78350F)
                                          .withValues(alpha: 0.3)
                                      : AppTheme.warningSubtle,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFFD97706)
                                            .withValues(alpha: 0.5)
                                        : const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.cloud_off_rounded,
                                        size: 12, color: AppTheme.warning),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Offline',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? const Color(0xFFFDE68A)
                                            : const Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      StatusBadge(
                        status: job.jobStatus,
                        rawStatus: job.status,
                        siteException: job.siteException,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Subscriber Info & Plan Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.planName ?? 'Fiber Plan',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (job.napId != null || job.portId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.borderDark
                              : AppTheme.borderLight,
                        ),
                      ),
                      child: Text(
                        'NAP-${job.napId ?? "?"} • ${job.portId ?? "Port"}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textMuted,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${job.address}${job.barangay != null ? ', ${job.barangay}' : ''}${job.city != null ? ', ${job.city}' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (job.contactNumber != null &&
                  job.contactNumber!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 15,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.contactNumber!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              // Onsite remarks or landmark snippet if available
              if (job.onsiteRemarks != null &&
                  job.onsiteRemarks!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppTheme.darkInput : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    job.onsiteRemarks!,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : const Color(0xFF475569),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              const SizedBox(height: 12),
              Divider(
                  height: 1,
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              const SizedBox(height: 12),

              // Optical Power Meter Chip if recorded
              if (job.opticalPower != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Optical Measurement:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textMuted,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            _getOpticalColorSubtle(job.opticalPower!, isDark),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.speed_rounded,
                            size: 13,
                            color: _getOpticalColor(job.opticalPower!),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${job.opticalPower!.toStringAsFixed(1)} dBm',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _getOpticalColor(job.opticalPower!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              // Dynamic Action Toolbar Based on Workflow Status
              if (isScheduled) ...[
                // Scheduled Job: Highlighted "Grab Job" dispatch button
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: onGrabJob ?? onCycleStatus,
                        icon: const Icon(Icons.flash_on_rounded, size: 16),
                        label: const Text(
                          '⚡ Grab Job (Start)',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: onOpenDetails,
                        icon: const Icon(Icons.info_outline_rounded, size: 16),
                        label: const Text('Details',
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (isInProgress) ...[
                // In Progress Job: Complete Report & Advance
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onOpenReport,
                        icon: const Icon(Icons.assignment_turned_in_rounded,
                            size: 16),
                        label: const Text(
                          'Complete Report',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCycleStatus,
                        icon: const Icon(Icons.arrow_circle_right_outlined,
                            size: 16),
                        label: Text(
                          _getNextStatusActionLabel(job.nextStatus),
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Completed / Activated Job
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onOpenDetails,
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: const Text('View Order Details',
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onOpenReport,
                        icon: const Icon(Icons.edit_note_rounded, size: 16),
                        label: const Text('Update Report',
                            style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          backgroundColor:
                              isDark ? AppTheme.darkInput : AppTheme.lightBg,
                          foregroundColor:
                              isDark ? Colors.white : AppTheme.darkSlate,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getNextStatusActionLabel(JobStatus? next) {
    return switch (next) {
      JobStatus.scheduled => 'Schedule Work',
      JobStatus.inProgress => 'Start Work',
      JobStatus.completed => 'Mark Completed',
      JobStatus.activated => 'Mark Activated',
      null => 'Activated',
    };
  }

  Color _getOpticalColor(double dbm) {
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

  Color _getOpticalColorSubtle(double dbm, bool isDark) {
    final base = _getOpticalColor(dbm);
    if (isDark) {
      return base.withValues(alpha: 0.2);
    }
    if (base == AppTheme.success) return AppTheme.successSubtle;
    if (base == AppTheme.warning) return AppTheme.warningSubtle;
    return AppTheme.dangerSubtle;
  }
}
