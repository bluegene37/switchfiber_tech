import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../models/job_order_model.dart';
import 'status_badge.dart';

/// Technician Job Card displaying subscriber details and interactive status triggers.
class JobCard extends StatelessWidget {
  final JobOrderDto job;
  final VoidCallback? onCycleStatus;
  final VoidCallback? onOpenReport;

  const JobCard({
    super.key,
    required this.job,
    this.onCycleStatus,
    this.onOpenReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onOpenReport,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Ticket # + Status + Sync Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primarySubtleBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.build_circle_rounded,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        job.ticketNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningSubtle,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cloud_off_rounded, size: 12, color: AppTheme.warning),
                                    SizedBox(width: 3),
                                    Text(
                                      'Offline',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      StatusBadge(status: job.jobStatus, rawStatus: job.status,
                        siteException: job.siteException),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Subscriber Info
              Text(
                job.customerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 4),

              // Address & Contact
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 15,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${job.address}${job.barangay != null ? ', ${job.barangay}' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (job.contactNumber != null && job.contactNumber!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 15,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.contactNumber!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1, color: AppTheme.borderLight),
              const SizedBox(height: 12),

              // Plan, NAP details & Optical Power
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Plan & NAP Tag
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.planName ?? 'Fiber Plan',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                        if (job.portId != null || job.napId != null)
                          Text(
                            'NAP-${job.napId ?? "X"} • ${job.portId ?? "Port"}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Optical Power Meter Chip if recorded
                  if (job.opticalPower != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getOpticalColorSubtle(job.opticalPower!),
                        borderRadius: BorderRadius.circular(8),
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
                              fontWeight: FontWeight.w700,
                              color: _getOpticalColor(job.opticalPower!),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Action Toolbar: Status cycle & Fill Report button
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCycleStatus,
                      icon: const Icon(Icons.sync_alt_rounded, size: 16),
                      label: Text(
                        _getNextStatusActionLabel(job.nextStatus),
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onOpenReport,
                      icon: const Icon(Icons.assignment_turned_in_rounded, size: 16),
                      label: const Text(
                        'Report / Onsite',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNextStatusActionLabel(JobStatus? next) {
    return switch (next) {
      JobStatus.inProgress => 'Start Work',
      JobStatus.completed => 'Mark Completed',
      JobStatus.activated => 'Mark Activated',
      null => 'Activated',
    };
  }

  /// Optical power thresholds follow the GPON standard in [AppConstants],
  /// matching the bands used by OpticalPowerGauge.
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

  Color _getOpticalColorSubtle(double dbm) {
    final base = _getOpticalColor(dbm);
    if (base == AppTheme.success) return AppTheme.successSubtle;
    if (base == AppTheme.warning) return AppTheme.warningSubtle;
    return AppTheme.dangerSubtle;
  }
}
