import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_states.dart';
import '../../auth/signals/auth_signals.dart';
import '../models/job_order_model.dart';
import '../signals/jobs_signals.dart';
import '../widgets/job_history_tile.dart';
import '../screens/job_order_detail_screen.dart';

/// Reusable widget rendering the signed-in technician's activated job history.
class JobHistoryView extends StatefulWidget {
  final JobsSignals jobsSignals;
  final AuthSignals? authSignals;
  final void Function(JobOrderDto job)? onSelectJob;

  const JobHistoryView({
    super.key,
    required this.jobsSignals,
    this.authSignals,
    this.onSelectJob,
  });

  @override
  State<JobHistoryView> createState() => _JobHistoryViewState();
}

class _JobHistoryViewState extends State<JobHistoryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.jobsSignals.historySearch.value;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(JobOrderDto job) {
    if (widget.onSelectJob != null) {
      widget.onSelectJob!(job);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JobOrderDetailScreen(
          jobId: job.id,
          jobsSignals: widget.jobsSignals,
          readOnly: true,
        ),
      ),
    );
  }

  Future<void> _pickCustomRange() async {
    final signals = widget.jobsSignals;
    final now = signals.clock();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: signals.historyRangeStart.value != null &&
              signals.historyRangeEnd.value != null
          ? DateTimeRange(
              start: signals.historyRangeStart.value!,
              end: signals.historyRangeEnd.value!,
            )
          : null,
      helpText: 'Show jobs activated between',
    );
    if (picked == null) return;
    signals.setHistoryRange(HistoryRange.custom,
        start: picked.start, end: picked.end);
  }

  void _clearFilters() {
    _searchController.clear();
    widget.jobsSignals.clearHistoryFilters();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final signals = widget.jobsSignals;
    final auth = widget.authSignals ?? AuthSignals.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SignalBuilder(
      builder: (context) {
        final email = signals.technicianEmail.value?.trim() ?? '';
        if (email.isEmpty && signals.assignedJobs.value.isEmpty) {
          return _NoEmailState(
            isDark: isDark,
            onRefreshProfile: auth.refreshProfile,
          );
        }

        return Column(
          children: [
            Container(
              color: isDark ? AppTheme.darkCard : Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  _SummaryStrip(signals: signals, isDark: isDark),
                  const SizedBox(height: 10),
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
                            onChanged: (v) {
                              signals.setHistorySearch(v);
                              setState(() {});
                            },
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : AppTheme.darkSlate,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search ticket #, subscriber, address...',
                              hintStyle: TextStyle(
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
                              signals.setHistorySearch('');
                              setState(() {});
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
                  _StatusChips(signals: signals),
                  const SizedBox(height: 8),
                  _RangeChips(
                    signals: signals,
                    onPickCustom: _pickCustomRange,
                  ),
                  SignalBuilder(
                    builder: (context) {
                      final cities = signals.historyCities.value;
                      if (cities.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _CityChips(signals: signals, cities: cities),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SignalBuilder(
                builder: (context) {
                  final phase = signals.loadPhase.value;
                  if (phase == DataLoadPhase.downloading) {
                    return const DownloadingIndicator(
                      title: 'Downloading Job Orders',
                      subtitle: 'Fetching your job history from the server...',
                    );
                  }
                  if (phase == DataLoadPhase.skeleton) {
                    return const SkeletonCardList();
                  }

                  final jobs = signals.historyJobs.value;
                  if (jobs.isEmpty) {
                    final total = signals.historyTotalCount.value;
                    return _EmptyState(
                      isDark: isDark,
                      filtered: total > 0,
                      onRefresh: () => signals.fetchRemote(),
                      onClearFilters: _clearFilters,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: signals.fetchRemote,
                    color: AppTheme.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return JobHistoryTile(
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
        );
      },
    );
  }
}

/// Totals across the technician's whole history, regardless of filter.
class _SummaryStrip extends StatelessWidget {
  final JobsSignals signals;
  final bool isDark;

  const _SummaryStrip({required this.signals, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final total = signals.historyTotalCount.value;
        final activated = signals.historyActivatedCount.value;
        final completed = signals.historyCompletedCount.value;
        final week = signals.historyThisWeekCount.value;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF064E3B).withValues(alpha: 0.5),
                      const Color(0xFF022C22).withValues(alpha: 0.35),
                    ]
                  : [AppTheme.successSubtle, const Color(0xFFF7FEF9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF059669).withValues(alpha: 0.4)
                  : const Color(0xFFBBF7D0),
            ),
          ),
          child: Row(
            children: [
              _Stat(label: 'Total', value: total, color: AppTheme.primary),
              _Stat(
                label: 'Activated',
                value: activated,
                color: const Color(0xFF4F46E5),
              ),
              _Stat(
                label: 'Completed',
                value: completed,
                color: AppTheme.success,
              ),
              _Stat(label: 'This Week', value: week, color: AppTheme.info),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Status filter chips for technician history (All, Activated, Completed).
class _StatusChips extends StatelessWidget {
  final JobsSignals signals;

  const _StatusChips({required this.signals});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final active = signals.historyStatus.value;
        return SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: HistoryStatusFilter.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = HistoryStatusFilter.values[index];
              return ChoiceChip(
                label: Text(filter.label),
                selected: filter == active,
                onSelected: (_) => signals.setHistoryStatus(filter),
                visualDensity: VisualDensity.compact,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Date window chips. The custom chip shows the chosen dates once picked.
class _RangeChips extends StatelessWidget {
  final JobsSignals signals;
  final Future<void> Function() onPickCustom;

  const _RangeChips({required this.signals, required this.onPickCustom});

  static final _short = DateFormat('MMM d');

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final active = signals.historyRange.value;
        final start = signals.historyRangeStart.value;
        final end = signals.historyRangeEnd.value;

        return SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: HistoryRange.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final range = HistoryRange.values[index];
              final isCustom = range == HistoryRange.custom;
              final label = isCustom && start != null && end != null
                  ? '${_short.format(start)} - ${_short.format(end)}'
                  : range.label;
              return ChoiceChip(
                avatar: isCustom
                    ? Icon(
                        Icons.date_range_rounded,
                        size: 16,
                        color: range == active ? Colors.white : null,
                      )
                    : null,
                label: Text(label),
                selected: range == active,
                onSelected: (_) {
                  if (isCustom) {
                    onPickCustom();
                  } else {
                    signals.setHistoryRange(range);
                  }
                },
                visualDensity: VisualDensity.compact,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Area filter built from the cities present in the technician's history.
class _CityChips extends StatelessWidget {
  final JobsSignals signals;
  final List<String> cities;

  const _CityChips({required this.signals, required this.cities});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final active = signals.historyCity.value;
        final options = <String?>[null, ...cities];
        return SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final city = options[index];
              return FilterChip(
                avatar: city == null
                    ? null
                    : const Icon(Icons.location_city_rounded, size: 14),
                label: Text(city ?? 'All areas'),
                selected: city == active,
                onSelected: (_) => signals.setHistoryCity(city),
                visualDensity: VisualDensity.compact,
                showCheckmark: false,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Shown when the profile carries no email, so nothing can be matched.
class _NoEmailState extends StatelessWidget {
  final bool isDark;
  final Future<void> Function() onRefreshProfile;

  const _NoEmailState({required this.isDark, required this.onRefreshProfile});

  @override
  Widget build(BuildContext context) {
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
                Icons.alternate_email_rounded,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Email On Your Profile',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Job orders are matched to you by the email address on your '
              'technician account. Refresh your profile, or ask Dispatch to '
              'add one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRefreshProfile,
              icon: const Icon(Icons.person_search_rounded, size: 16),
              label: const Text('Refresh My Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;

  /// True when the technician has history but the filters hide it.
  final bool filtered;
  final VoidCallback onRefresh;
  final VoidCallback onClearFilters;

  const _EmptyState({
    required this.isDark,
    required this.filtered,
    required this.onRefresh,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDark ? const Color(0xFF3F2327) : AppTheme.primarySubtleBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  filtered ? Icons.filter_alt_off_rounded : Icons.history_rounded,
                  size: 40,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                filtered ? 'Nothing Matches' : 'No History Jobs Yet',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                filtered
                    ? 'No job in your history matches the current status, date, '
                        'area or search filters.'
                    : 'Jobs marked as Activated or Completed appear here as a '
                        'permanent record. Pull down to refresh from the server.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              if (filtered)
                OutlinedButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_all_rounded, size: 16),
                  label: const Text('Clear Filters'),
                )
              else
                ElevatedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Refresh From Server'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
