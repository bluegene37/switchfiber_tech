import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../models/job_order_model.dart';
import '../signals/jobs_signals.dart';
import '../widgets/job_card.dart';

/// Job Orders list screen with filter tabs, live Signal counts, search, and instant status triggers.
class JobOrdersScreen extends StatefulWidget {
  final JobsSignals jobsSignals;
  final void Function(JobOrderDto job)? onSelectJobForReport;

  const JobOrdersScreen({
    super.key,
    required this.jobsSignals,
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

  @override
  Widget build(BuildContext context) {
    final signals = widget.jobsSignals;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assigned Work Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              'Field installations & repair dispatches',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          // Manual Sync Action Button
          SignalBuilder(
            builder: (context) {
              final syncing = signals.repository.syncWorker.isSyncing.value;
              final pending = signals.repository.syncWorker.pendingCount.value;

              return IconButton(
                tooltip: 'Sync with backend',
                onPressed: syncing
                    ? null
                    : () async {
                        final result =
                            await signals.repository.syncWorker.syncPendingJobs();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message),
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
          // Search & Filter Toolbar
          Container(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  onChanged: signals.setSearch,
                  decoration: InputDecoration(
                    hintText: 'Search subscriber, ticket #, address...',
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),

                // Status Filter Tabs with dynamic Signal counts
                _buildFilterTabs(signals),
              ],
            ),
          ),

          // Offline Sync Status Banner (if items are pending)
          SignalBuilder(
            builder: (context) {
              final pending = signals.unsyncedCount.value;
              if (pending == 0) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppTheme.warningSubtle,
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 16, color: Color(0xFF92400E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$pending local update(s) stored in Drift DB awaiting sync.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E),
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

          // Reactive Jobs List
          Expanded(
            child: SignalBuilder(
              builder: (context) {
                final jobs = signals.filteredJobs.value;

                if (jobs.isEmpty) {
                  return _buildEmptyState(signals);
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
                        onCycleStatus: () async {
                          await signals.advanceFieldStatus(job);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Updated ${job.ticketNumber} locally in Drift SQLite',
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppTheme.darkSlate,
                            ),
                          );
                        },
                        onOpenReport: () {
                          widget.onSelectJobForReport?.call(job);
                        },
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

  Widget _buildFilterTabs(JobsSignals signals) {
    return SignalBuilder(
      builder: (context) {
      final currentFilter = signals.activeFilter.value;
      // Tabs follow the API's on-site vocabulary; ids are FieldStatus names.
      final tabs = [
        {'id': 'all', 'label': 'All', 'count': signals.totalCount.value},
        {
          'id': FieldStatus.dispatched.name,
          'label': FieldStatus.dispatched.label,
          'count': signals.dispatchedCount.value,
        },
        {
          'id': FieldStatus.inProgress.name,
          'label': FieldStatus.inProgress.label,
          'count': signals.inProgressCount.value,
        },
        {
          'id': FieldStatus.done.name,
          'label': FieldStatus.done.label,
          'count': signals.doneCount.value,
        },
        {
          'id': FieldStatus.failed.name,
          'label': FieldStatus.failed.label,
          'count': signals.failedCount.value,
        },
        {
          'id': FieldStatus.reschedule.name,
          'label': FieldStatus.reschedule.label,
          'count': signals.rescheduleCount.value,
        },
      ];

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final isSelected = currentFilter == tab['id'];
            final count = tab['count'] as int;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tab['label'] as String),
                    const SizedBox(width: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : AppTheme.borderLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                onSelected: (_) {
                  signals.setFilter(tab['id'] as String);
                },
                selectedColor: AppTheme.primary,
                backgroundColor: AppTheme.lightBg,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.darkSlate,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.borderLight,
                  ),
                ),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildEmptyState(JobsSignals signals) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.primarySubtleBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_late_outlined,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Job Orders Found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'There are no job orders matching your selected status filter or search keyword.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                signals.setFilter('all');
                signals.setSearch('');
                _searchController.clear();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
