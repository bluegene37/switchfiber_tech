import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_states.dart';
import '../../auth/signals/auth_signals.dart';
import '../models/job_order_model.dart';
import '../signals/jobs_signals.dart';
import '../widgets/job_history_tile.dart';
import 'job_order_detail_screen.dart';

/// The signed-in technician's activated job orders, newest first.
///
/// Strictly a record: tiles open the details in view-only mode, and the
/// screen offers date, area and text filters but no way to change a job.
class JobHistoryScreen extends StatefulWidget {
  final JobsSignals jobsSignals;
  final AuthSignals authSignals;

  const JobHistoryScreen({
    super.key,
    required this.jobsSignals,
    required this.authSignals,
  });

  @override
  State<JobHistoryScreen> createState() => _JobHistoryScreenState();
}

class _JobHistoryScreenState extends State<JobHistoryScreen> {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Job History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SignalBuilder(
              builder: (context) {
                final email = signals.technicianEmail.value?.trim() ?? '';
                return Text(
                  email.isEmpty
                      ? 'Activated jobs assigned to you'
                      : 'Activated jobs for $email',
                  style: TextStyle(fontSize: 12, color: muted),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ],
        ),
        actions: [
          SignalBuilder(
            builder: (context) {
              final refreshing = signals.isRefreshing.value;
              return IconButton(
                tooltip: 'Refresh from server',
                onPressed: refreshing ? null : () => signals.fetchRemote(),
                icon: refreshing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded),
              );
            },
          ),
        ],
      ),
      body: SignalBuilder(
        builder: (context) {
          final email = signals.technicianEmail.value?.trim() ?? '';
          if (email.isEmpty) {
            return _NoEmailState(
              isDark: isDark,
              onRefreshProfile: widget.authSignals.refreshProfile,
            );
          }

          return Column(
            children: [
              Container(
                color: isDark ? AppTheme.darkCard : Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    _SummaryStrip(signals: signals, isDark: isDark),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        signals.setHistorySearch(v);
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Search ticket #, subscriber, address...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  signals.setHistorySearch('');
                                  setState(() {});
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _RangeChips(
                        signals: signals, onPickCustom: _pickCustomRange),
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
                        subtitle:
                            'Fetching your job history from the server...',
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
      ),
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
        final week = signals.historyThisWeekCount.value;
        final month = signals.historyThisMonthCount.value;

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
              _Stat(label: 'Activated', value: total, color: AppTheme.success),
              _Stat(label: 'This Week', value: week, color: AppTheme.info),
              _Stat(label: 'This Month', value: month, color: AppTheme.primary),
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
              child: Icon(
                filtered ? Icons.filter_alt_off_rounded : Icons.history_rounded,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              filtered ? 'Nothing Matches' : 'No Activated Jobs Yet',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              filtered
                  ? 'No job in your history matches the current date, area or '
                      'search filters.'
                  : 'Jobs you mark as Activated appear here as a permanent '
                      'record. Pull down to refresh from the server.',
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
    );
  }
}
