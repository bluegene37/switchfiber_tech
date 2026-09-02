import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../toolkit/screens/fiber_color_code_tool.dart';
import '../../toolkit/screens/optical_budget_tool.dart';
import '../../toolkit/screens/drop_cable_tool.dart';
import '../../toolkit/screens/network_diagnostic_tool.dart';
import '../models/job_order_model.dart';
import '../signals/jobs_signals.dart';
import '../widgets/status_badge.dart';

/// Comprehensive details screen for an assigned Job Order with full Dark Mode support and responsive flex layouts.
class JobOrderDetailScreen extends StatelessWidget {
  final int jobId;
  final JobsSignals jobsSignals;
  final void Function(JobOrderDto job)? onOpenReport;

  const JobOrderDetailScreen({
    super.key,
    required this.jobId,
    required this.jobsSignals,
    this.onOpenReport,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SignalBuilder(
      builder: (context) {
        final allJobs = jobsSignals.allJobs.value;
        final job = allJobs.where((j) => j.id == jobId).firstOrNull;

        if (job == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Work Order Details')),
            body: Center(
              child: Text(
                'Job Order not found or removed.',
                style: TextStyle(
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.ticketNumber,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                Text(
                  job.planName ?? 'Switch Fiber Service',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            actions: [
              // Sync Status Badge
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: job.isSynced
                      ? (isDark
                          ? const Color(0xFF059669).withValues(alpha: 0.25)
                          : AppTheme.successSubtle)
                      : (isDark
                          ? const Color(0xFF78350F).withValues(alpha: 0.25)
                          : AppTheme.warningSubtle),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: job.isSynced
                        ? (isDark
                            ? const Color(0xFF059669).withValues(alpha: 0.4)
                            : const Color(0xFFBBF7D0))
                        : (isDark
                            ? const Color(0xFFD97706).withValues(alpha: 0.4)
                            : const Color(0xFFFDE68A)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      job.isSynced
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_off_rounded,
                      size: 13,
                      color: job.isSynced
                          ? (isDark ? const Color(0xFF4ADE80) : AppTheme.success)
                          : (isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.isSynced ? 'Synced' : 'Local DB',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: job.isSynced
                            ? (isDark ? const Color(0xFF4ADE80) : AppTheme.success)
                            : (isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
              // Completion Report Quick Access
              IconButton(
                icon: const Icon(Icons.assignment_turned_in_outlined, size: 20),
                tooltip: 'Field Completion Report',
                onPressed: () => _handleOpenReport(context, job),
              ),
              // Copy Ticket Summary Button
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20),
                tooltip: 'Copy Ticket Summary',
                onPressed: () => _copyJobSummary(context, job, isDark),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Status & Workflow Pipeline Card
              _buildWorkflowCard(context, job, isDark),
              const SizedBox(height: 14),

              // 2. Site Exception Alert (if applicable)
              if (job.siteException != null) ...[
                _buildExceptionBanner(job, isDark),
                const SizedBox(height: 14),
              ],

              // 3. Customer & Service Location Card
              _buildCustomerCard(context, job, isDark),
              const SizedBox(height: 14),

              // 4. Fiber Plant & Equipment Assignment
              _buildPlantAndHardwareCard(context, job, isDark),
              const SizedBox(height: 14),

              // 5. Tech Toolkit & Field Utilities
              _buildToolkitShortcutsCard(context, job, isDark),
              const SizedBox(height: 14),

              // 6. Optical Reading & Calibration
              if (job.opticalPower != null) ...[
                _buildOpticalPowerCard(job, isDark),
                const SizedBox(height: 14),
              ],

              // 7. Onsite Notes & Completion Proofs
              _buildOnsiteRecordsCard(context, job, isDark),
            ],
          ),
        );
      },
    );
  }

  /// Interactive Workflow Card showing stages and stage advancement
  Widget _buildWorkflowCard(BuildContext context, JobOrderDto job, bool isDark) {
    final currentStatus = job.jobStatus;
    final nextStatus = job.nextStatus;
    final isScheduled = job.isScheduled;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Workflow Stage',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                  ),
                ),
                StatusBadge(
                  status: currentStatus,
                  rawStatus: job.status,
                  siteException: job.siteException,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stepper Visualizer
            _buildStepper(job, isDark),
            const SizedBox(height: 16),

            // Who Dispatch assigned this job to
            _buildAssignmentRow(job, isDark),
            const SizedBox(height: 12),

            // Grab or Status Advance Button
            if (isScheduled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await jobsSignals.grabJob(job);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('⚡ Grabbed ${job.ticketNumber}! Moved to In-Progress.'),
                        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.darkSlate,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: const Text('⚡ Grab This Job Order (Start Dispatch)', style: TextStyle(fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            else if (nextStatus != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleAdvanceStatus(context, job, isDark),
                  icon: const Icon(Icons.arrow_circle_right_outlined, size: 18),
                  label: Text(_getAdvanceButtonLabel(nextStatus)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The technician email Dispatch assigned this job to. Emails run long, so
  /// unlike [_buildSpecRow] the value wraps rather than overflowing.
  Widget _buildAssignmentRow(JobOrderDto job, bool isDark) {
    final email = job.assignedEmail?.trim() ?? '';
    final muted = isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.person_pin_rounded, size: 16, color: muted),
        const SizedBox(width: 8),
        Text('Assigned To', style: TextStyle(fontSize: 13, color: muted)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            email.isEmpty ? 'Unassigned' : email,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: email.isEmpty ? muted : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper(JobOrderDto job, bool isDark) {
    final status = job.jobStatus;
    final steps = [
      {'label': 'Scheduled', 'active': true},
      {
        'label': 'In Progress',
        'active': status == JobStatus.inProgress ||
            status == JobStatus.completed ||
            status == JobStatus.activated,
      },
      {
        'label': 'Completed',
        'active': status == JobStatus.completed || status == JobStatus.activated,
      },
      {'label': 'Activated', 'active': status == JobStatus.activated},
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = (index ~/ 2) + 1;
          final isPrevActive = steps[stepIndex - 1]['active'] as bool;
          final isNextActive = steps[stepIndex]['active'] as bool;
          return Expanded(
            child: Container(
              height: 3,
              color: isPrevActive && isNextActive
                  ? AppTheme.primary
                  : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final step = steps[stepIndex];
        final isActive = step['active'] as bool;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primary
                    : (isDark ? AppTheme.darkInput : AppTheme.lightBg),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? AppTheme.primary
                      : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                  width: 2,
                ),
              ),
              child: Center(
                child: isActive
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              step['label'] as String,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? (isDark ? Colors.white : AppTheme.darkSlate)
                    : (isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildExceptionBanner(JobOrderDto job, bool isDark) {
    final exception = job.siteException!;
    final isReschedule = exception == SiteException.reschedule;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? (isReschedule
                ? const Color(0xFF78350F).withValues(alpha: 0.3)
                : const Color(0xFF7F1D1D).withValues(alpha: 0.3))
            : (isReschedule ? AppTheme.warningSubtle : AppTheme.dangerSubtle),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? (isReschedule
                  ? const Color(0xFFD97706).withValues(alpha: 0.5)
                  : const Color(0xFFDC2626).withValues(alpha: 0.5))
              : (isReschedule
                  ? const Color(0xFFFDE68A)
                  : const Color(0xFFFECACA)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isReschedule
                ? Icons.event_repeat_rounded
                : Icons.warning_amber_rounded,
            color: isReschedule ? AppTheme.warning : AppTheme.danger,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Site Exception: ${exception.label}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? (isReschedule ? const Color(0xFFFDE68A) : const Color(0xFFFCA5A5))
                        : (isReschedule ? const Color(0xFF92400E) : const Color(0xFF991B1B)),
                  ),
                ),
                if (job.onsiteRemarks != null && job.onsiteRemarks!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    job.onsiteRemarks!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? (isReschedule ? const Color(0xFFFCD34D) : const Color(0xFFFECACA))
                          : (isReschedule ? const Color(0xFF78350F) : const Color(0xFF7F1D1D)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, JobOrderDto job, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_pin_rounded, size: 18, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Subscriber & Location',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Customer Name & Plan
            Text(
              job.customerName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              job.planName ?? 'Fiber Plan',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Address Detail
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${job.address}${job.barangay != null ? ', ${job.barangay}' : ''}${job.city != null ? ', ${job.city}' : ''}',
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
            const SizedBox(height: 12),

            // Contact Action Buttons (Call, SMS, Copy Address)
            Row(
              children: [
                if (job.contactNumber != null && job.contactNumber!.isNotEmpty) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _promptContact(context, job.contactNumber!, isCall: true, isDark: isDark),
                      icon: const Icon(Icons.call_rounded, size: 16),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _promptContact(context, job.contactNumber!, isCall: false, job: job, isDark: isDark),
                      icon: const Icon(Icons.sms_outlined, size: 16),
                      label: const Text('SMS'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyAddress(context, job, isDark),
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Address'),
                    style: OutlinedButton.styleFrom(
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
    );
  }

  Widget _buildPlantAndHardwareCard(BuildContext context, JobOrderDto job, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.hub_outlined, size: 18, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Plant & Hardware Allocation',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _buildSpecRow('LCP Cabinet', job.lcpId != null ? 'LCP-${job.lcpId}' : 'Unassigned', Icons.storage_rounded, isDark),
            _buildSpecRow('NAP Box', job.napId != null ? 'NAP-${job.napId}' : 'Unassigned', Icons.router_rounded, isDark),
            _buildSpecRow('Port Assignment', job.portId ?? 'Port 1', Icons.electrical_services_rounded, isDark),
            if (job.vlanId != null)
              _buildSpecRow('VLAN Tag', 'VLAN ${job.vlanId}', Icons.tag_rounded, isDark),
            _buildSpecRow('Modem / ONT SN', job.modemRouterSN ?? 'Pending Installation', Icons.qr_code_rounded, isDark),
            if (job.routerModel != null && job.routerModel!.isNotEmpty)
              _buildSpecRow('ONT Model', job.routerModel!, Icons.devices_rounded, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildToolkitShortcutsCard(BuildContext context, JobOrderDto job, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.handyman_rounded, size: 18, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  'ISP Field Skills & Utilities',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.palette_rounded, size: 16, color: Color(0xFF0070BA)),
                  label: const Text('Fiber Color Code', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FiberColorCodeTool()),
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.speed_rounded, size: 16, color: AppTheme.primary),
                  label: const Text('Link Budget Calc', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OpticalBudgetTool()),
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.cable_rounded, size: 16, color: Color(0xFF10B981)),
                  label: const Text('Drop Cable BOM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DropCableTool()),
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.network_ping_rounded, size: 16, color: Color(0xFF8B5CF6)),
                  label: const Text('Ping / Diagnostics', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NetworkDiagnosticTool()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpticalPowerCard(JobOrderDto job, bool isDark) {
    final dbm = job.opticalPower!;
    final isOptimal = dbm >= AppConstants.opticalMinOptimal && dbm <= AppConstants.opticalMaxOptimal;
    final isMarginal = dbm >= AppConstants.opticalMarginalFloor && dbm < AppConstants.opticalMinOptimal;

    final badgeColor = isOptimal
        ? AppTheme.success
        : isMarginal
            ? AppTheme.warning
            : AppTheme.danger;

    final badgeSubtle = isDark
        ? badgeColor.withValues(alpha: 0.2)
        : (isOptimal
            ? AppTheme.successSubtle
            : isMarginal
                ? AppTheme.warningSubtle
                : AppTheme.dangerSubtle);

    final badgeLabel = isOptimal
        ? 'Optimal (Pass)'
        : isMarginal
            ? 'Marginal (Acceptable)'
            : 'Out of Spec (Faulty)';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.speed_rounded, size: 18, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Optical Power Measurement',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: badgeSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dbm.toStringAsFixed(1)} dBm',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: badgeColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Standard: -12.0 dBm to -24.0 dBm',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnsiteRecordsCard(BuildContext context, JobOrderDto job, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assignment_turned_in_outlined, size: 18, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  'On-Site Records & Verification',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (job.onsiteRemarks != null && job.onsiteRemarks!.isNotEmpty) ...[
              Text(
                'Technician Notes:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.onsiteRemarks!,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Photo attachments row (Safe non-overflow flex items)
            Row(
              children: [
                Expanded(
                  child: _buildProofChip(
                    label: 'Box Reading Photo',
                    attached: job.boxReadingImage != null && job.boxReadingImage!.isNotEmpty,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildProofChip(
                    label: 'ONT Rx Photo',
                    attached: job.routerReadingImage != null && job.routerReadingImage!.isNotEmpty,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildProofChip(
              label: 'Subscriber Digital Sign-Off',
              attached: job.clientSignature != null && job.clientSignature!.isNotEmpty,
              isDark: isDark,
            ),
            const SizedBox(height: 14),

            // Inline action to fill/update the completion report
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleOpenReport(context, job),
                icon: const Icon(Icons.assignment_turned_in_rounded, size: 16),
                label: const Text(
                  'Fill / Update Completion Report',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofChip({
    required String label,
    required bool attached,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: attached
            ? (isDark
                ? const Color(0xFF059669).withValues(alpha: 0.25)
                : AppTheme.successSubtle)
            : (isDark ? AppTheme.darkInput : AppTheme.lightBg),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: attached
              ? (isDark
                  ? const Color(0xFF059669).withValues(alpha: 0.4)
                  : const Color(0xFFBBF7D0))
              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            attached ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: attached
                ? (isDark ? const Color(0xFF4ADE80) : AppTheme.success)
                : (isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: attached
                    ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF166534))
                    : (isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  void _handleOpenReport(BuildContext context, JobOrderDto job) {
    if (onOpenReport != null) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      onOpenReport!(job);
    }
  }

  String _getAdvanceButtonLabel(JobStatus next) {
    return switch (next) {
      JobStatus.scheduled => 'Schedule Work',
      JobStatus.inProgress => 'Start Work (Mark In Progress)',
      JobStatus.completed => 'Mark Job Completed',
      JobStatus.activated => 'Mark Subscriber Activated',
    };
  }

  Future<void> _handleAdvanceStatus(BuildContext context, JobOrderDto job, bool isDark) async {
    await jobsSignals.advanceJobStatus(job);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated ${job.ticketNumber} to ${job.nextStatus?.label ?? "next stage"}'),
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.darkSlate,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyJobSummary(BuildContext context, JobOrderDto job, bool isDark) {
    final text = 'Switch Fiber JO: ${job.ticketNumber}\n'
        'Customer: ${job.customerName}\n'
        'Plan: ${job.planName ?? "Fiber"}\n'
        'Address: ${job.address}, ${job.barangay ?? ""}\n'
        'Contact: ${job.contactNumber ?? "N/A"}\n'
        'Status: ${job.status}';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ticket summary copied to clipboard!'),
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.darkSlate,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyAddress(BuildContext context, JobOrderDto job, bool isDark) {
    final addr = '${job.address}${job.barangay != null ? ', ${job.barangay}' : ''}${job.city != null ? ', ${job.city}' : ''}';

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Customer Location & Navigation',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              addr,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Start Navigation
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.navigation_rounded, color: Color(0xFF1A73E8), size: 20),
              ),
              title: const Text('Start Navigation in Google Maps', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              subtitle: Text(
                'Turn-by-turn driving directions from your location',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                ),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(addr)}&travelmode=driving');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: 6),

            // Copy Address
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3F2327) : AppTheme.primarySubtleBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.copy_rounded, color: AppTheme.primary, size: 20),
              ),
              title: const Text('Copy Address to Clipboard', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              subtitle: Text(
                'Copy complete subscriber address text',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                ),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: addr));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Address copied: $addr'),
                    backgroundColor: isDark ? AppTheme.darkCard : AppTheme.darkSlate,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _promptContact(
    BuildContext context,
    String phone, {
    required bool isCall,
    JobOrderDto? job,
    required bool isDark,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isCall ? 'Call Customer' : 'Send SMS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Number: $phone', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            if (!isCall && job != null)
              Text(
                'Pre-filled SMS:\n"Good day ${job.customerName}, Switch Fiber Technician is arriving shortly for ticket ${job.ticketNumber}."',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phone));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Phone number copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: isDark ? AppTheme.darkCard : AppTheme.darkSlate,
                ),
              );
            },
            child: const Text('Copy Number'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isCall ? 'Calling $phone...' : 'Opening SMS to $phone...'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
            child: Text(isCall ? 'Dial Now' : 'Send Message'),
          ),
        ],
      ),
    );
  }
}
