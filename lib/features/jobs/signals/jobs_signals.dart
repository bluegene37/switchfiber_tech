import 'dart:async';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/widgets/loading_states.dart';
import '../models/job_order_model.dart';
import '../repositories/job_repository.dart';
import '../services/sync_worker.dart';

/// Which terminal status of the technician's job history is shown.
enum HistoryStatusFilter {
  all('All'),
  activated('Activated'),
  completed('Completed');

  const HistoryStatusFilter(this.label);

  final String label;
}

/// The date window applied to the technician's job history.
enum HistoryRange {
  all('All time'),
  today('Today'),
  week('This week'),
  month('This month'),
  custom('Pick dates');

  const HistoryRange(this.label);

  final String label;
}

/// Signals state layer for Job Orders.
/// Pipes the Drift SQLite reactive stream into Signals and provides instant UI computations.
class JobsSignals {
  final JobRepository repository;

  /// Source of "now" for the history date windows; injectable for tests.
  final DateTime Function() clock;

  StreamSubscription<List<JobOrderDto>>? _driftSubscription;

  JobsSignals(this.repository, {DateTime Function()? clock})
      : clock = clock ?? DateTime.now {
    _initDriftStream();
  }

  // Raw State Signals
  final allJobs = signal<List<JobOrderDto>>([]);
  // Defaults to 'scheduled' so technicians immediately see their scheduled work orders.
  final activeFilter = signal<String>(JobStatus.scheduled.name);
  final searchQuery = signal<String>('');
  final selectedJob = signal<JobOrderDto?>(null);
  final isRefreshing = signal<bool>(false);
  // First-load presentation: downloading -> skeleton -> ready. Stays ready for
  // pull-to-refresh and manual syncs so existing data is never hidden.
  final loadPhase = signal<DataLoadPhase>(DataLoadPhase.ready);

  // Technician history: activated jobs whose assignedEmail matches the
  // signed-in technician, with their own date, area and search filters so the
  // history and the scheduled queue never fight over one query box.
  final technicianEmail = signal<String?>(null);
  final historyStatus = signal<HistoryStatusFilter>(HistoryStatusFilter.all);
  final historyRange = signal<HistoryRange>(HistoryRange.all);
  final historyRangeStart = signal<DateTime?>(null);
  final historyRangeEnd = signal<DateTime?>(null);
  final historyCity = signal<String?>(null);
  final historySearch = signal<String>('');

  // Computeds
  late final ReadonlySignal<List<JobOrderDto>> filteredJobs = computed(() {
    final jobs = allJobs.value;
    final query = searchQuery.value.trim().toLowerCase();

    return jobs.where((job) {
      // Strictly filter and show only Scheduled jobs
      if (!job.isScheduled) {
        return false;
      }

      // Search Query (Ticket #, Customer Name, Address, Barangay)
      if (query.isNotEmpty) {
        final matchesTicket = job.ticketNumber.toLowerCase().contains(query);
        final matchesCustomer = job.customerName.toLowerCase().contains(query);
        final matchesAddress = job.address.toLowerCase().contains(query);
        final matchesBarangay =
            (job.barangay ?? '').toLowerCase().contains(query);
        return matchesTicket ||
            matchesCustomer ||
            matchesAddress ||
            matchesBarangay;
      }

      return true;
    }).toList();
  });

  late final ReadonlySignal<int> totalCount =
      computed(() => allJobs.value.length);

  int _countOf(JobStatus s) =>
      allJobs.value.where((j) => j.jobStatus == s).length;

  late final ReadonlySignal<int> scheduledCount =
      computed(() => _countOf(JobStatus.scheduled));

  late final ReadonlySignal<int> activatedCount =
      computed(() => _countOf(JobStatus.activated));

  /// Jobs whose on-site visit failed or needs rescheduling. Not a tab, but
  /// surfaced so these stay visible rather than hiding under "All".
  late final ReadonlySignal<int> siteExceptionCount = computed(
    () => allJobs.value.where((j) => j.siteException != null).length,
  );

  late final ReadonlySignal<int> unsyncedCount = computed(
    () => allJobs.value.where((j) => !j.isSynced).length,
  );

  /// Every finished job (Activated or Completed) assigned to the signed-in
  /// technician, newest first. Empty until the technician's email is known.
  late final ReadonlySignal<List<JobOrderDto>> assignedJobs = computed(() {
    final history =
        allJobs.value.where((j) => j.isActivated || j.isCompleted).toList();

    history.sort((a, b) {
      final ad = a.historyDate;
      final bd = b.historyDate;
      if (ad == null && bd == null) return b.id.compareTo(a.id);
      if (ad == null) return 1;
      if (bd == null) return -1;
      final byDate = bd.compareTo(ad);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });
    return history;
  });

  /// Distinct cities across the technician's history, for the area filter.
  late final ReadonlySignal<List<String>> historyCities = computed(() {
    final cities = <String>{
      for (final j in assignedJobs.value)
        if (j.city?.trim().isNotEmpty == true) j.city!.trim(),
    }.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return cities;
  });

  /// Half-open [start, end) window for [range], or nulls for all time.
  (DateTime?, DateTime?) _windowFor(HistoryRange range) {
    final now = clock();
    final today = DateTime(now.year, now.month, now.day);
    return switch (range) {
      HistoryRange.all => (null, null),
      HistoryRange.today => (today, today.add(const Duration(days: 1))),
      HistoryRange.week => (
          today.subtract(Duration(days: today.weekday - DateTime.monday)),
          today.add(const Duration(days: 1)),
        ),
      HistoryRange.month => (
          DateTime(today.year, today.month),
          today.add(const Duration(days: 1)),
        ),
      HistoryRange.custom => (
          historyRangeStart.value,
          historyRangeEnd.value?.add(const Duration(days: 1)),
        ),
    };
  }

  bool _inWindow(JobOrderDto job, (DateTime?, DateTime?) window) {
    final (start, end) = window;
    if (start == null && end == null) return true;
    final d = job.historyDate;
    if (d == null) return false;
    if (start != null && d.isBefore(start)) return false;
    if (end != null && !d.isBefore(end)) return false;
    return true;
  }

  /// [assignedJobs] narrowed by the status filter, date window, city and search box.
  late final ReadonlySignal<List<JobOrderDto>> historyJobs = computed(() {
    final status = historyStatus.value;
    final window = _windowFor(historyRange.value);
    final city = historyCity.value?.trim().toLowerCase();
    final query = historySearch.value.trim().toLowerCase();

    return assignedJobs.value.where((job) {
      if (status == HistoryStatusFilter.activated && !job.isActivated) {
        return false;
      }
      if (status == HistoryStatusFilter.completed && !job.isCompleted) {
        return false;
      }
      if (!_inWindow(job, window)) return false;
      if (city != null &&
          city.isNotEmpty &&
          (job.city ?? '').trim().toLowerCase() != city) {
        return false;
      }
      if (query.isEmpty) return true;
      return job.ticketNumber.toLowerCase().contains(query) ||
          job.customerName.toLowerCase().contains(query) ||
          job.address.toLowerCase().contains(query) ||
          (job.barangay ?? '').toLowerCase().contains(query) ||
          (job.city ?? '').toLowerCase().contains(query);
    }).toList();
  });

  late final ReadonlySignal<int> historyTotalCount =
      computed(() => assignedJobs.value.length);

  late final ReadonlySignal<int> historyActivatedCount = computed(
    () => assignedJobs.value.where((j) => j.isActivated).length,
  );

  late final ReadonlySignal<int> historyCompletedCount = computed(
    () => assignedJobs.value.where((j) => j.isCompleted).length,
  );

  int _historyCountIn(HistoryRange range) {
    final window = _windowFor(range);
    return assignedJobs.value.where((j) => _inWindow(j, window)).length;
  }

  late final ReadonlySignal<int> historyThisWeekCount =
      computed(() => _historyCountIn(HistoryRange.week));

  late final ReadonlySignal<int> historyThisMonthCount =
      computed(() => _historyCountIn(HistoryRange.month));

  /// Pipe Drift SQLite reactive stream into allJobs signal
  void _initDriftStream() {
    _driftSubscription?.cancel();
    _driftSubscription = repository.watchJobs().listen((jobs) {
      allJobs.value = jobs;
    });
  }

  /// Pull scheduled jobs and the technician's activated history from the
  /// server and refresh the cache.
  ///
  /// With [initial] set, and only when Drift holds nothing yet, the screen is
  /// walked through the download indicator and a brief skeleton pass before
  /// the hydrated Drift rows are revealed.
  Future<void> fetchRemote({bool initial = false}) async {
    final showPhases = initial && allJobs.value.isEmpty;
    if (showPhases) loadPhase.value = DataLoadPhase.downloading;
    isRefreshing.value = true;
    try {
      await repository.fetchRemoteJobs(technicianEmail: technicianEmail.value);
    } finally {
      isRefreshing.value = false;
      if (showPhases) {
        loadPhase.value = DataLoadPhase.skeleton;
        await Future<void>.delayed(const Duration(milliseconds: 900));
        loadPhase.value = DataLoadPhase.ready;
      }
    }
  }

  /// Mark a job Completed, stamping it with the signed-in technician so it
  /// appears in history. Already-completed jobs are left alone.
  Future<SyncResult?> completeJob(JobOrderDto job) async {
    if (job.isCompleted) return null;
    return repository.completeJob(job.id,
        technicianEmail: technicianEmail.value);
  }

  /// Mark a job Activated, stamping it with the signed-in technician so it
  /// appears in their history. Already-activated jobs are left alone.
  Future<void> activateJob(JobOrderDto job) async {
    if (job.isActivated) return;
    await repository.activateJob(job.id,
        technicianEmail: technicianEmail.value);
  }

  /// Settings > Force Full Sync: push pending edits, then replace the local
  /// cache with the server's copy. See [JobRepository.forceRefreshFromServer].
  Future<SyncResult> forceRefresh() async {
    isRefreshing.value = true;
    try {
      return await repository.forceRefreshFromServer(
          technicianEmail: technicianEmail.value);
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Update tab filter
  void setFilter(String filter) {
    activeFilter.value = filter;
  }

  /// Update search keyword
  void setSearch(String query) {
    searchQuery.value = query;
  }

  /// The signed-in technician's email, which scopes the job history.
  void setTechnicianEmail(String? email) {
    technicianEmail.value = email;
  }

  /// Apply a date window. [start] and [end] (inclusive dates) are only used
  /// for [HistoryRange.custom].
  void setHistoryRange(HistoryRange range, {DateTime? start, DateTime? end}) {
    if (range == HistoryRange.custom) {
      historyRangeStart.value =
          start == null ? null : DateTime(start.year, start.month, start.day);
      historyRangeEnd.value =
          end == null ? null : DateTime(end.year, end.month, end.day);
    }
    historyRange.value = range;
  }

  /// Restrict the history to one city, or null for every area.
  void setHistoryCity(String? city) {
    historyCity.value = (city == null || city.trim().isEmpty) ? null : city;
  }

  /// Restrict the history to one status, or all history.
  void setHistoryStatus(HistoryStatusFilter status) {
    historyStatus.value = status;
  }

  void clearHistoryFilters() {
    historyStatus.value = HistoryStatusFilter.all;
    historyRange.value = HistoryRange.all;
    historyRangeStart.value = null;
    historyRangeEnd.value = null;
    historyCity.value = null;
    historySearch.value = '';
  }

  void setHistorySearch(String query) {
    historySearch.value = query;
  }

  /// Must be awaited: the Drift stream subscription has to be fully torn down
  /// before the database can be closed, otherwise close() blocks forever.
  Future<void> dispose() async {
    await _driftSubscription?.cancel();
    _driftSubscription = null;
  }
}
