import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_states.dart';
import '../../lcp_nap/signals/lcp_nap_signals.dart';
import '../../service_orders/signals/service_orders_signals.dart';
import '../../service_orders/widgets/service_order_card.dart';
import '../models/job_order_model.dart';
import '../signals/jobs_signals.dart';
import '../widgets/job_card.dart';
import '../widgets/jobs_map_view.dart';
import 'job_order_detail_screen.dart';

enum _JobsViewMode { list, map }
enum _JobsCategory { installs, repairs }

/// The scheduled queue: every job order still waiting to be activated.
/// Tapping a ticket opens its details, where it can be marked Activated.
/// Supports both Inset Grouped Queue List and interactive Dispatch Map.
class JobOrdersScreen extends StatefulWidget {
  final JobsSignals jobsSignals;
  final LcpNapSignals? lcpNapSignals;
  final ServiceOrdersSignals? serviceOrdersSignals;
  final void Function(JobOrderDto job)? onSelectJobForDetails;
  final void Function(JobOrderDto job)? onSelectJobForReport;

  const JobOrdersScreen({
    super.key,
    required this.jobsSignals,
    this.lcpNapSignals,
    this.serviceOrdersSignals,
    this.onSelectJobForDetails,
    this.onSelectJobForReport,
  });

  @override
  State<JobOrdersScreen> createState() => _JobOrdersScreenState();
}

class _JobOrdersScreenState extends State<JobOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  _JobsViewMode _viewMode = _JobsViewMode.list;
  _JobsCategory _category = _JobsCategory.installs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(JobOrderDto job) {
    if (widget.onSelectJobForDetails != null) {
      widget.onSelectJobForDetails!(job);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobOrderDetailScreen(
          jobId: job.id,
          jobsSignals: widget.jobsSignals,
          onOpenReport: widget.onSelectJobForReport,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signals = widget.jobsSignals;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _category == _JobsCategory.installs
              ? 'Scheduled Installations'
              : 'Service & Repair Tickets',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          // Manual Sync & Refresh Action Button
          SignalBuilder(
            builder: (context) {
              final syncing = signals.repository.syncWorker.isSyncing.value ||
                  (widget.serviceOrdersSignals?.isSyncing.value ?? false);
              final pending = signals.repository.syncWorker.pendingCount.value;

              return IconButton(
                tooltip: 'Sync & refresh queue',
                onPressed: syncing
                    ? null
                    : () async {
                        final result = await signals.repository.syncWorker
                            .syncPendingJobs();
                        await signals.fetchRemote();
                        await widget.serviceOrdersSignals?.fetchRemote();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.failedCount == 0
                                  ? 'Synced with backend.'
                                  : result.message,
                            ),
                            backgroundColor: result.success
                                ? AppTheme.success
                                : AppTheme.warning,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                icon: Badge(
                  isLabelVisible: pending > 0,
                  label: Text('$pending'),
                  backgroundColor: AppTheme.primary,
                  child: syncing
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primary,
                          ),
                        )
                      : const Icon(CupertinoIcons.arrow_2_circlepath),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Scheduled Intake Header Banner & iOS Search
          Container(
            color: isDark ? AppTheme.darkCard : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Top Category Toggle: Installs vs Repairs
                if (widget.serviceOrdersSignals != null) ...[
                  SignalBuilder(
                    builder: (context) {
                      final installCount = signals.scheduledCount.value;
                      final repairCount = widget.serviceOrdersSignals?.allOrders.value.length ?? 0;

                      return SizedBox(
                        width: double.infinity,
                        child: CupertinoSlidingSegmentedControl<_JobsCategory>(
                          groupValue: _category,
                          backgroundColor:
                              isDark ? AppTheme.darkInput : AppTheme.fillLight,
                          thumbColor: isDark ? AppTheme.darkCard : Colors.white,
                          children: {
                            _JobsCategory.installs: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Text(
                                'Installs ($installCount)',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                            _JobsCategory.repairs: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Text(
                                'Repairs ($repairCount)',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          },
                          onValueChanged: (val) {
                            if (val != null) setState(() => _category = val);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],

                // iOS Capsule Search Bar
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkInput : AppTheme.fillLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.search,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (text) {
                            setState(() {});
                            signals.setSearch(text);
                            widget.serviceOrdersSignals?.searchQuery.value = text;
                          },
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : AppTheme.darkSlate,
                          ),
                          decoration: InputDecoration(
                            hintText: _category == _JobsCategory.installs
                                ? 'Search subscriber, ticket #, address...'
                                : 'Search repair ticket, account, concern...',
                            hintStyle: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {});
                            signals.setSearch('');
                            widget.serviceOrdersSignals?.searchQuery.value = '';
                          },
                          child: const Icon(
                            CupertinoIcons.clear_thick_circled,
                            size: 16,
                            color: AppTheme.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Scheduled Queue iOS Widget Banner
                SignalBuilder(
                  builder: (context) {
                    final scheduledCount = signals.scheduledCount.value;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C2230)
                            : const Color(0xFFF0F6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2563EB).withValues(alpha: 0.3)
                              : const Color(0xFFBFDBFE),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              CupertinoIcons.calendar,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$scheduledCount Scheduled Dispatch${scheduledCount == 1 ? "" : "es"} Available',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                    color: isDark
                                        ? const Color(0xFF93C5FD)
                                        : const Color(0xFF1E40AF),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Tap ticket to verify optical specs & activate subscriber.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppTheme.textSecondaryDark
                                        : const Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // iOS Segmented View Control (Queue List vs Dispatch Map)
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<_JobsViewMode>(
                    groupValue: _viewMode,
                    backgroundColor:
                        isDark ? AppTheme.darkInput : AppTheme.fillLight,
                    thumbColor: isDark ? AppTheme.darkCard : Colors.white,
                    children: const {
                      _JobsViewMode.list: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.list_bullet, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Ticket Queue',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      _JobsViewMode.map: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.map_fill, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Dispatch Map',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    },
                    onValueChanged: (val) {
                      if (val != null) setState(() => _viewMode = val);
                    },
                  ),
                ),
              ],
            ),
          ),

          // 2. Offline Sync Status Banner (if items are pending)
          SignalBuilder(
            builder: (context) {
              final pending = signals.unsyncedCount.value;
              if (pending == 0) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isDark
                    ? const Color(0xFF78350F).withValues(alpha: 0.3)
                    : AppTheme.warningSubtle,
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 16,
                      color: isDark
                          ? const Color(0xFFFDE68A)
                          : const Color(0xFF92400E),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$pending local update(s) awaiting server sync.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFFDE68A)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        signals.repository.syncWorker.syncPendingJobs();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Sync Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 3. Body: Repairs Queue OR (Interactive Dispatch Map / Scheduled Jobs List)
          Expanded(
            child: _category == _JobsCategory.repairs
                ? _buildRepairsBody(context, isDark)
                : (_viewMode == _JobsViewMode.map
                    ? JobsMapView(
                        jobsSignals: signals,
                        lcpNapSignals: widget.lcpNapSignals,
                        onOpenJob: _openDetails,
                      )
                    : SignalBuilder(
                        builder: (context) {
                          final jobs = signals.filteredJobs.value;
                          final phase = signals.loadPhase.value;

                          if (phase == DataLoadPhase.downloading) {
                            return const DownloadingIndicator(
                              title: 'Downloading Job Orders',
                              subtitle:
                                  'Fetching your scheduled dispatches from the server...',
                            );
                          }

                          if (phase == DataLoadPhase.skeleton) {
                            return const SkeletonCardList();
                          }

                          if (jobs.isEmpty) {
                            return _buildEmptyState(signals, isDark);
                          }

                          return RefreshIndicator(
                            onRefresh: signals.fetchRemote,
                            color: AppTheme.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: jobs.length,
                              itemBuilder: (context, index) {
                                final job = jobs[index];
                                return JobCard(
                                  job: job,
                                  onTap: () => _openDetails(job),
                                );
                              },
                            ),
                          );
                        },
                      )),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairsBody(BuildContext context, bool isDark) {
    final sos = widget.serviceOrdersSignals;
    if (sos == null) {
      return const Center(child: Text('Service Orders service unavailable'));
    }

    return SignalBuilder(
      builder: (context) {
        final orders = sos.filteredOrders.value;
        final syncing = sos.isSyncing.value;

        if (syncing && orders.isEmpty) {
          return const DownloadingIndicator(
            title: 'Loading Service Orders',
            subtitle: 'Fetching maintenance tickets and equipment pullouts...',
          );
        }

        if (orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3F2327) : AppTheme.primarySubtleBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.wrench, size: 36, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text('No Active Service Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    'No repair or swap tickets currently assigned.',
                    style: TextStyle(color: isDark ? Colors.white60 : AppTheme.textMuted, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => sos.fetchRemote(),
          color: AppTheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ServiceOrderCard(order: order, signals: sos);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(JobsSignals signals, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF3F2327) : AppTheme.primarySubtleBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppTheme.primary.withValues(alpha: 0.3)
                      : AppTheme.primarySubtleBorder,
                  width: 0.5,
                ),
              ),
              child: const Icon(
                CupertinoIcons.calendar_badge_plus,
                size: 38,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Scheduled Jobs Pending',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Every scheduled job has been activated. Pull down to refresh from the server.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                signals.fetchRemote();
              },
              icon: const Icon(CupertinoIcons.arrow_2_circlepath, size: 15),
              label: const Text('Pull Scheduled From Server'),
            ),
          ],
        ),
      ),
    );
  }
}
