import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_states.dart';
import '../models/job_order_model.dart';
import '../signals/jobs_signals.dart';
import '../widgets/job_card.dart';
import 'job_order_detail_screen.dart';

/// The scheduled queue: every job order still waiting to be activated.
/// Tapping a ticket opens its details, where it can be marked Activated.
class JobOrdersScreen extends StatefulWidget {
  final JobsSignals jobsSignals;
  final void Function(JobOrderDto job)? onSelectJobForDetails;
  final void Function(JobOrderDto job)? onSelectJobForReport;

  const JobOrdersScreen({
    super.key,
    required this.jobsSignals,
    this.onSelectJobForDetails,
    this.onSelectJobForReport,
  });

  @override
  State<JobOrdersScreen> createState() => _JobOrdersScreenState();
}

class _JobOrdersScreenState extends State<JobOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

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

    Navigator.of(context).push(
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scheduled Work Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              'Tap a ticket to view details and activate',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          // Manual Sync & Refresh Action Button
          SignalBuilder(
            builder: (context) {
              final syncing = signals.repository.syncWorker.isSyncing.value;
              final pending = signals.repository.syncWorker.pendingCount.value;

              return IconButton(
                tooltip: 'Sync & refresh scheduled jobs',
                onPressed: syncing
                    ? null
                    : () async {
                        final result = await signals.repository.syncWorker
                            .syncPendingJobs();
                        await signals.fetchRemote();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.failedCount == 0
                                  ? 'Synced with backend. Refreshed scheduled jobs.'
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
                      : const Icon(Icons.sync_rounded),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Scheduled Intake Header Banner & Search
          Container(
            color: isDark ? AppTheme.darkCard : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                // Scheduled Queue Banner
                SignalBuilder(
                  builder: (context) {
                    final scheduledCount = signals.scheduledCount.value;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF1E3A8A)
                                      .withValues(alpha: 0.3),
                                  const Color(0xFF172554).withValues(alpha: 0.2)
                                ]
                              : [
                                  const Color(0xFFE0F2FE),
                                  const Color(0xFFF0F9FF)
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1D4ED8).withValues(alpha: 0.4)
                              : const Color(0xFFBAE6FD),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0EA5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$scheduledCount Scheduled Dispatch${scheduledCount == 1 ? "" : "es"} Available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? const Color(0xFF7DD3FC)
                                        : const Color(0xFF0369A1),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Open a ticket to review it and mark it Activated once the subscriber is online.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppTheme.textSecondaryDark
                                        : const Color(0xFF0C4A6E),
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

                // Search Input Field
                TextField(
                  controller: _searchController,
                  onChanged: signals.setSearch,
                  decoration: InputDecoration(
                    hintText:
                        'Search scheduled subscriber, ticket #, address...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              signals.setSearch('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
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

          // 3. Reactive Scheduled Jobs List
          Expanded(
            child: SignalBuilder(
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
            ),
          ),
        ],
      ),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF3F2327) : AppTheme.primarySubtleBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Scheduled Jobs Pending',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Every scheduled job has been activated. Pull down to refresh from the server.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                signals.fetchRemote();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Pull Scheduled From Server'),
            ),
          ],
        ),
      ),
    );
  }
}
