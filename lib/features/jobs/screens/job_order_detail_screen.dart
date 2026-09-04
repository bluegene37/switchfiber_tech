import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../diagnostics/widgets/radius_connection_card.dart';
import '../../lcp_nap/models/lcp_nap_model.dart';
import '../../lcp_nap/signals/lcp_nap_signals.dart';
import '../models/job_order_model.dart';
import '../signals/jobs_signals.dart';
import '../widgets/job_photo_gallery.dart';
import '../widgets/status_badge.dart';
import '../../reports/screens/create_report_screen.dart';
import '../../reports/signals/report_signals.dart';

/// Comprehensive details screen for a Job Order with full Dark Mode support
/// and responsive flex layouts.
///
/// With [readOnly] set (the job history) every action that changes the record
/// is hidden: no activation, no completion report. Navigation, calling and
/// copying stay available since they do not touch the job.
class JobOrderDetailScreen extends StatelessWidget {
  final int jobId;
  final JobsSignals jobsSignals;
  final LcpNapSignals? lcpNapSignals;
  final void Function(JobOrderDto job)? onOpenReport;
  final bool readOnly;
  final bool automaticallyImplyLeading;

  const JobOrderDetailScreen({
    super.key,
    required this.jobId,
    required this.jobsSignals,
    this.lcpNapSignals,
    this.onOpenReport,
    this.readOnly = false,
    this.automaticallyImplyLeading = true,
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
            appBar: AppBar(
              automaticallyImplyLeading: automaticallyImplyLeading,
              title: const Text('Work Order Details'),
            ),
            body: Center(
              child: Text(
                'Job Order not found or removed.',
                style: TextStyle(color: AppTheme.secondaryInkOf(context)),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: automaticallyImplyLeading,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.ticketNumber,
                  style: context.text.titleMedium,
                ),
                Text(
                  job.planName ?? 'Switch Fiber Service',
                  style: context.text.bodySmall,
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
                      size: 20,
                      color: job.isSynced
                          ? (isDark
                              ? const Color(0xFF4ADE80)
                              : AppTheme.success)
                          : (isDark
                              ? const Color(0xFFFDE68A)
                              : const Color(0xFF92400E)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.isSynced ? 'Synced' : 'Local DB',
                      style: context.text.labelMedium!.copyWith(
                        color: job.isSynced
                            ? AppTheme.successInkOf(context)
                            : AppTheme.warningInkOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Completion Report Quick Access
              if (!readOnly)
                IconButton(
                  icon:
                      const Icon(Icons.assignment_turned_in_outlined, size: 24),
                  tooltip: 'Field Completion Report',
                  onPressed: () => _handleOpenReport(context, job),
                ),
              // Copy Ticket Summary Button
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 24),
                tooltip: 'Copy Ticket Summary',
                onPressed: () => _copyJobSummary(context, job, isDark),
              ),
            ],
          ),
          bottomNavigationBar: readOnly || !job.canActivate
              ? null
              : SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? AppTheme.borderDark
                              : AppTheme.borderLight,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: job.hasCompletedReport
                          ? () => _handleComplete(context, job, isDark)
                          : () => _handleOpenReport(context, job),
                      icon: Icon(
                        job.hasCompletedReport
                            ? Icons.check_circle_rounded
                            : Icons.assignment_turned_in_rounded,
                        size: 22,
                      ),
                      label: Text(
                        job.hasCompletedReport
                            ? 'Mark as Completed'
                            : 'Fill Completion Report',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
          body: ListView(
            // The activate button sits at the very bottom, so the scroll has
            // to clear the phone's navigation bar.
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
            children: [
              // 1. Status & Workflow Pipeline Card
              _buildWorkflowCard(context, job, isDark),
              const SizedBox(height: 14),

              // 2. Site Exception Alert (if applicable)
              if (job.siteException != null) ...[
                _buildExceptionBanner(context, job, isDark),
                const SizedBox(height: 14),
              ],

              // 3. Customer & Service Location Card
              _buildCustomerCard(context, job, isDark),
              const SizedBox(height: 14),

              // 3b. GPS Coordinates & Field Navigation
              _buildLocationAndGpsCard(context, job, isDark),
              const SizedBox(height: 14),

              // 4. Fiber Plant & Equipment Assignment
              _buildPlantAndHardwareCard(context, job, isDark),
              const SizedBox(height: 14),

              // 4b. Live RADIUS PPPoE Connection & Reconnect Test
              RadiusConnectionCard(
                accountName: _radiusAccountOf(job),
                subscriberName: job.customerName,
              ),
              const SizedBox(height: 14),

              // 5. Optical Reading & Calibration
              if (job.opticalPower != null) ...[
                _buildOpticalPowerCard(context, job, isDark),
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
  Widget _buildWorkflowCard(
      BuildContext context, JobOrderDto job, bool isDark) {
    final currentStatus = job.jobStatus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A Wrap, not a Row: at 200% text the label and the badge no
            // longer fit on one line, so the badge flows to its own line
            // instead of overflowing.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  'Workflow Stage',
                  style: context.text.labelMedium!
                      .copyWith(color: AppTheme.secondaryInkOf(context)),
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
            _buildStepper(context, job, isDark),
            const SizedBox(height: 16),

            // Who Dispatch assigned this job to
            _buildAssignmentRow(context, job, isDark),
            const SizedBox(height: 12),

            // The one field action: Scheduled -> Completed.
            if (readOnly)
              _buildViewOnlyNote(context, isDark)
            else if (job.canActivate) ...[
              if (!job.hasCompletedReport)
                _buildReportRequiredNote(context, isDark)
              else
                _buildReportReadyNote(context, isDark),
            ] else
              _buildActivatedNote(context, job, isDark),
          ],
        ),
      ),
    );
  }

  /// The technician email Dispatch assigned this job to. Emails run long, so
  /// unlike [_buildSpecRow] the value wraps rather than overflowing.
  Widget _buildAssignmentRow(
      BuildContext context, JobOrderDto job, bool isDark) {
    final email = job.assignedEmail?.trim() ?? '';
    final muted = isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.person_pin_rounded, size: 20, color: muted),
        const SizedBox(width: 8),
        Text('Assigned To', style: context.text.bodySmall),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            email.isEmpty ? 'Unassigned' : email,
            textAlign: TextAlign.right,
            style: context.text.titleSmall!.copyWith(
              color: email.isEmpty ? AppTheme.secondaryInkOf(context) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper(BuildContext context, JobOrderDto job, bool isDark) {
    final status = job.jobStatus;
    final isFinished =
        status == JobStatus.activated || status == JobStatus.completed;
    final terminalLabel =
        status == JobStatus.activated ? 'Activated' : 'Completed';
    final steps = [
      {'label': 'Scheduled', 'active': true},
      {'label': terminalLabel, 'active': isFinished},
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

        return Expanded(
          child: Column(
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
                      ? const Icon(Icons.check, size: 20, color: Colors.white)
                      : Text(
                          '${stepIndex + 1}',
                          style: context.text.labelMedium!.copyWith(
                            color: AppTheme.secondaryInkOf(context),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step['label'] as String,
                textAlign: TextAlign.center,
                style: isActive
                    ? context.text.labelMedium
                    : context.text.bodySmall,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildExceptionBanner(
      BuildContext context, JobOrderDto job, bool isDark) {
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
                  style: context.text.titleSmall!.copyWith(
                    color: isDark
                        ? (isReschedule
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFFFCA5A5))
                        : (isReschedule
                            ? const Color(0xFF92400E)
                            : const Color(0xFF991B1B)),
                  ),
                ),
                if (job.onsiteRemarks != null &&
                    job.onsiteRemarks!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    job.onsiteRemarks!,
                    style: context.text.bodySmall!.copyWith(
                      color: isDark
                          ? (isReschedule
                              ? const Color(0xFFFCD34D)
                              : const Color(0xFFFECACA))
                          : (isReschedule
                              ? const Color(0xFF78350F)
                              : const Color(0xFF7F1D1D)),
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

  Widget _buildCustomerCard(
      BuildContext context, JobOrderDto job, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_pin_rounded,
                    size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Subscriber & Location',
                    style: context.text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Customer Name & Plan
            Text(
              job.customerName,
              style: context.text.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(
              job.planName ?? 'Fiber Plan',
              style: context.text.labelMedium!
                  .copyWith(color: AppTheme.brandInkOf(context)),
            ),
            const SizedBox(height: 12),

            // Address Detail
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color:
                      isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${job.address}${job.barangay != null ? ', ${job.barangay}' : ''}${job.city != null ? ', ${job.city}' : ''}',
                    style: context.text.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(
                height: 1,
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
            const SizedBox(height: 12),

            // Contact Action Buttons (Call, SMS, Copy Address). Navigation
            // lives in the Service Location card below, so it is not repeated
            // here.
            Row(
              children: [
                if (job.contactNumber != null &&
                    job.contactNumber!.isNotEmpty) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _promptContact(
                          context, job.contactNumber!,
                          isCall: true, isDark: isDark),
                      icon: const Icon(Icons.call_rounded, size: 24),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _promptContact(
                          context, job.contactNumber!,
                          isCall: false, job: job, isDark: isDark),
                      icon: const Icon(Icons.sms_outlined, size: 24),
                      label: const Text('SMS'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  tooltip: 'Copy Address',
                  icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 24),
                  onPressed: () => _copyAddress(context, job, isDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAndGpsCard(
      BuildContext context, JobOrderDto job, bool isDark) {
    final latLng = job.latLng;
    final dms = latLng != null
        ? LocationService.instance.formatDms(latLng.latitude, latLng.longitude)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(CupertinoIcons.location_circle_fill,
                    size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Service Location & GPS Coordinates',
                    style: context.text.titleMedium,
                  ),
                ),
                if (latLng != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'GPS Fixed',
                      style: context.text.labelMedium!
                          .copyWith(color: AppTheme.successInkOf(context)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _buildSpecRow(
              context,
              'Coordinates',
              dms ?? 'Derived from service area',
              CupertinoIcons.location_solid,
              isDark,
            ),
            if (latLng != null)
              _buildSpecRow(
                context,
                'Decimal Lat/Lng',
                '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}',
                CupertinoIcons.map_pin_ellipse,
                isDark,
              ),
            // The GPS fix is owned by a widget that asks for it once. Building
            // the future inline here restarted a 4-second high-accuracy fix on
            // every rebuild of this screen, and there is nothing to measure
            // against when the job carries no coordinates.
            if (latLng != null)
              _DistanceFromTechnicianRow(target: latLng, isDark: isDark),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () => _openNavigation(job),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.location_north_fill,
                        size: 24, color: Colors.white),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Start Turn-by-Turn Navigation',
                        style: context.text.labelLarge!
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Nearest LCP NAP Pole Details & Navigation
            () {
              final nearestNapInfo = _findNearestNap(job);
              if (nearestNapInfo == null) return const SizedBox.shrink();

              return Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.35)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF10B981).withValues(alpha: 0.4)
                            : const Color(0xFFA7F3D0),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.hub_rounded,
                                size: 20, color: Color(0xFF10B981)),
                            const SizedBox(width: 6),
                            Text(
                              'Nearest LCP NAP Pole',
                              style: context.text.labelMedium!.copyWith(
                                color: isDark
                                    ? const Color(0xFF6EE7B7)
                                    : const Color(0xFF047857),
                              ),
                            ),
                            const Spacer(),
                            if (nearestNapInfo.distanceMeters > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${LocationService.instance.formatDistance(nearestNapInfo.distanceMeters)} away',
                                  style: context.text.labelMedium!
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          nearestNapInfo.nap.lcpNap,
                          style: context.text.titleSmall,
                        ),
                        if (nearestNapInfo.nap.street?.isNotEmpty == true ||
                            nearestNapInfo.nap.barangay?.isNotEmpty ==
                                true) ...[
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (nearestNapInfo.nap.street?.isNotEmpty == true)
                                nearestNapInfo.nap.street,
                              if (nearestNapInfo.nap.barangay?.isNotEmpty ==
                                  true)
                                nearestNapInfo.nap.barangay,
                            ].join(', '),
                            style: context.text.bodySmall,
                          ),
                        ],
                        if (nearestNapInfo.nap.latLng != null) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFF10B981), width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                              icon: const Icon(
                                  CupertinoIcons.arrow_turn_up_right,
                                  size: 24,
                                  color: Color(0xFF10B981)),
                              label: Text(
                                'Directions to NAP Pole',
                                style: context.text.labelLarge!
                                    .copyWith(color: const Color(0xFF10B981)),
                              ),
                              onPressed: () {
                                final p = nearestNapInfo.nap.latLng!;
                                final uri = Uri.parse(
                                    'https://maps.apple.com/?q=${p.latitude},${p.longitude}');
                                launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }(),
          ],
        ),
      ),
    );
  }

  ({LcpNapDto nap, double distanceMeters})? _findNearestNap(JobOrderDto job) {
    if (lcpNapSignals == null) return null;
    final naps = lcpNapSignals!.allLocations.value;
    if (naps.isEmpty) return null;

    final targetPos = job.latLng;
    if (targetPos != null) {
      double minD = double.infinity;
      LcpNapDto? nearest;
      for (final n in naps) {
        if (n.latLng == null) continue;
        final d = LocationService.instance.distanceBetween(
          startLat: targetPos.latitude,
          startLng: targetPos.longitude,
          endLat: n.latLng!.latitude,
          endLng: n.latLng!.longitude,
        );
        if (d < minD) {
          minD = d;
          nearest = n;
        }
      }
      if (nearest != null && minD.isFinite) {
        return (nap: nearest, distanceMeters: minD);
      }
    }

    if (job.napId != null) {
      for (final n in naps) {
        if (n.id == job.napId) {
          return (nap: n, distanceMeters: 0.0);
        }
      }
    }

    return null;
  }

  Future<void> _openNavigation(JobOrderDto job) async {
    final latLng = job.latLng;
    final Uri uri;
    if (latLng != null) {
      uri = Uri.parse(
          'https://maps.apple.com/?q=${latLng.latitude},${latLng.longitude}');
    } else {
      final fullAddr =
          '${job.address}${job.barangay != null ? ", ${job.barangay}" : ""}${job.city != null ? ", ${job.city}" : ""}, Philippines';
      uri = Uri.parse(
          'https://maps.apple.com/?q=${Uri.encodeComponent(fullAddr)}');
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildPlantAndHardwareCard(
      BuildContext context, JobOrderDto job, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hub_outlined,
                    size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Plant & Hardware Allocation',
                    style: context.text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildSpecRow(
                context,
                'LCP Cabinet',
                job.lcpId != null ? 'LCP-${job.lcpId}' : 'Unassigned',
                Icons.storage_rounded,
                isDark),
            _buildSpecRow(
                context,
                'NAP Box',
                job.nap?.isNotEmpty == true
                    ? job.nap!
                    : (job.napId != null && job.napId! > 0
                        ? 'NAP-${job.napId}'
                        : 'Unassigned'),
                Icons.hub_rounded,
                isDark),
            _buildSpecRow(context, 'Port Assignment', job.portId ?? 'Port 1',
                Icons.electrical_services_rounded, isDark),
            if (job.vlanId != null)
              _buildSpecRow(context, 'VLAN Tag', 'VLAN ${job.vlanId}',
                  Icons.tag_rounded, isDark),
            _buildSpecRow(
                context,
                'Modem / ONT SN',
                job.modemRouterSN ?? 'Pending Installation',
                Icons.qr_code_rounded,
                isDark),
            if (job.routerModel != null && job.routerModel!.isNotEmpty)
              _buildSpecRow(context, 'ONT Model', job.routerModel!,
                  Icons.devices_rounded, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildOpticalPowerCard(
      BuildContext context, JobOrderDto job, bool isDark) {
    final dbm = job.opticalPower!;
    final isOptimal = dbm >= AppConstants.opticalMinOptimal &&
        dbm <= AppConstants.opticalMaxOptimal;
    final isMarginal = dbm >= AppConstants.opticalMarginalFloor &&
        dbm < AppConstants.opticalMinOptimal;

    final badgeColor = isOptimal
        ? AppTheme.success
        : isMarginal
            ? AppTheme.warning
            : AppTheme.danger;

    // The reading's own colour, but pulled from the ink palette since it
    // sits on Text rather than a fill.
    final badgeColorInk = isOptimal
        ? AppTheme.successInkOf(context)
        : isMarginal
            ? AppTheme.warningInkOf(context)
            : AppTheme.dangerInkOf(context);

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
            Row(
              children: [
                const Icon(Icons.speed_rounded,
                    size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Optical Power Measurement',
                    style: context.text.titleMedium,
                  ),
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
                        style: context.text.headlineSmall!
                            .copyWith(color: badgeColorInk),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Standard: -12.0 dBm to -24.0 dBm',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeLabel,
                      style: context.text.labelMedium!
                          .copyWith(color: Colors.white),
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

  Widget _buildOnsiteRecordsCard(
      BuildContext context, JobOrderDto job, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_turned_in_outlined,
                    size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'On-Site Records & Verification',
                    style: context.text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (job.onsiteRemarks != null && job.onsiteRemarks!.isNotEmpty) ...[
              Text(
                'Technician Notes:',
                style: context.text.labelMedium!
                    .copyWith(color: AppTheme.secondaryInkOf(context)),
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
                  style: context.text.bodyMedium,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Photo proofs and signature, tap to zoom
            Text(
              'Photo Proofs:',
              style: context.text.labelMedium!
                  .copyWith(color: AppTheme.secondaryInkOf(context)),
            ),
            const SizedBox(height: 6),
            JobPhotoGallery(job: job),
            const SizedBox(height: 14),

            // Inline action to fill/update the completion report
            if (!readOnly)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleOpenReport(context, job),
                  icon:
                      const Icon(Icons.assignment_turned_in_rounded, size: 24),
                  label: Text(
                    'Fill / Update Completion Report',
                    style:
                        context.text.labelLarge!.copyWith(color: Colors.white),
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

  static Widget _buildSpecRow(BuildContext context, String label, String value,
      IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: context.text.bodySmall,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: context.text.titleSmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the report on top of this screen.
  ///
  /// This used to pop the detail screen first, which left the report sitting
  /// directly on the job list: backing out of it landed the technician on the
  /// main screen instead of the job they were working.
  void _handleOpenReport(BuildContext context, JobOrderDto job) {
    if (onOpenReport != null) {
      onOpenReport!(job);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(
          jobsSignals: jobsSignals,
          reportSignals: ReportSignals()..setJobOrder(job),
          onReportSubmitted: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }

  /// Informs the technician that a completion report is needed before finalizing.
  Widget _buildReportRequiredNote(BuildContext context, bool isDark) {
    final muted = isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Step 1 of 2: Completion report required. Tap "Fill Completion '
              'Report" below to record modem serial and subscriber signature.',
              style: context.text.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  /// Informs the technician that the report is complete and ready to finalize.
  Widget _buildReportReadyNote(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.success.withValues(alpha: 0.15)
            : AppTheme.successSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? AppTheme.success.withValues(alpha: 0.3)
              : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 20, color: AppTheme.successInkOf(context)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Step 2 of 2: Completion report filed. Tap "Mark as Completed" '
              'below to finalize and sync order.',
              style: context.text.bodySmall!.copyWith(
                color: AppTheme.successInkOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A read-only banner for the history: the record can be inspected but not
  /// changed from here.
  Widget _buildViewOnlyNote(BuildContext context, bool isDark) {
    final muted = isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 20, color: muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'View only. This job is in your history and cannot be changed.',
              style: context.text.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivatedNote(
      BuildContext context, JobOrderDto job, bool isDark) {
    final when = job.dateInstalled;
    final prefix = job.isCompleted ? 'Completed' : 'Activated';
    final label = when == null
        ? prefix
        : '$prefix on ${when.year}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF059669).withValues(alpha: 0.2)
            : AppTheme.successSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? const Color(0xFF059669).withValues(alpha: 0.4)
              : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded,
              size: 20,
              color: isDark ? const Color(0xFF4ADE80) : AppTheme.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: context.text.labelMedium!
                  .copyWith(color: AppTheme.successInkOf(context)),
            ),
          ),
        ],
      ),
    );
  }

  /// Confirm, then complete. Completion is terminal and moves the job into
  /// history, so it deserves a second look.
  Future<void> _handleComplete(
      BuildContext context, JobOrderDto job, bool isDark) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Mark as Completed?'),
        content: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${job.ticketNumber} for ${job.customerName} will be marked '
            'Completed and moved to your job history. This cannot be undone '
            'from the app.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            isDefaultAction: true,
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await jobsSignals.completeJob(job);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${job.ticketNumber} marked as completed. It now appears in History.'),
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
    final addr =
        '${job.address}${job.barangay != null ? ', ${job.barangay}' : ''}${job.city != null ? ', ${job.city}' : ''}';

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        // Clear the system navigation bar, which otherwise covers the last
        // row of the sheet.
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, 24 + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppTheme.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Customer Location & Navigation',
                      style: ctx.text.titleMedium,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 24),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              addr,
              style: ctx.text.titleSmall,
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
                child: const Icon(Icons.navigation_rounded,
                    color: Color(0xFF1A73E8), size: 24),
              ),
              title: Text('Start Navigation in Google Maps',
                  style: ctx.text.titleSmall),
              subtitle: Text(
                'Turn-by-turn driving directions from your location',
                style: ctx.text.bodySmall,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse(
                    'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(addr)}&travelmode=driving');
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
                  color: isDark
                      ? const Color(0xFF3F2327)
                      : AppTheme.primarySubtleBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.copy_rounded,
                    color: AppTheme.primary, size: 24),
              ),
              title:
                  Text('Copy Address to Clipboard', style: ctx.text.titleSmall),
              subtitle: Text(
                'Copy complete subscriber address text',
                style: ctx.text.bodySmall,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: addr));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Address copied: $addr'),
                    backgroundColor:
                        isDark ? AppTheme.darkCard : AppTheme.darkSlate,
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
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(isCall ? 'Call Subscriber' : 'Send SMS'),
        message: Text(
          !isCall && job != null
              ? '$phone\n\n"Good day ${job.customerName}, Switch Fiber Technician is arriving shortly for ticket ${job.ticketNumber}."'
              : phone,
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isCall
                      ? 'Calling $phone...'
                      : 'Opening SMS to $phone...'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
            isDefaultAction: true,
            child: Text(isCall ? 'Dial Now' : 'Send Message'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phone));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Phone number copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor:
                      isDark ? AppTheme.darkCard : AppTheme.darkSlate,
                ),
              );
            },
            child: const Text('Copy Number'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  String _radiusAccountOf(JobOrderDto job) {
    if (job.rawJson != null) {
      try {
        final map = jsonDecode(job.rawJson!);
        if (map is Map<String, dynamic>) {
          final u = map['username']?.toString().trim();
          if (u != null && u.isNotEmpty && u.toLowerCase() != 'switch') {
            return u;
          }
          final acc = map['accountNumber']?.toString().trim();
          if (acc != null && acc.isNotEmpty) return acc;
        }
      } catch (_) {}
    }
    return job.ticketNumber;
  }
}

/// The straight-line distance between the technician and the job's coordinates.
///
/// The position request is made once, in [initState], rather than in `build`:
/// a future created during build is re-issued on every rebuild, which turned
/// each repaint of the details screen into a fresh high-accuracy GPS fix.
class _DistanceFromTechnicianRow extends StatefulWidget {
  final LatLng target;
  final bool isDark;

  const _DistanceFromTechnicianRow({
    required this.target,
    required this.isDark,
  });

  @override
  State<_DistanceFromTechnicianRow> createState() =>
      _DistanceFromTechnicianRowState();
}

class _DistanceFromTechnicianRowState
    extends State<_DistanceFromTechnicianRow> {
  late final Future<String?> _distance = _measure();

  Future<String?> _measure() async {
    final here = await LocationService.instance.getCurrentPosition();
    if (here == null) return null;
    final meters = LocationService.instance.distanceBetween(
      startLat: here.latitude,
      startLng: here.longitude,
      endLat: widget.target.latitude,
      endLng: widget.target.longitude,
    );
    return LocationService.instance.formatDistance(meters);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _distance,
      builder: (context, snapshot) {
        final distance = snapshot.data;
        if (distance == null) return const SizedBox.shrink();
        return JobOrderDetailScreen._buildSpecRow(
          context,
          'Distance from You',
          distance,
          CupertinoIcons.arrow_up_right_diamond_fill,
          widget.isDark,
        );
      },
    );
  }
}
