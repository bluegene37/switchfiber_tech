import 'dart:async';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/widgets/loading_states.dart';
import '../models/job_order_model.dart';
import '../repositories/job_repository.dart';

/// Which slice of the technician's own job history is shown.
enum HistoryFilter {
  all('All'),
  inProgress('In Progress'),
  completed('Completed'),
  activated('Activated'),
  needsAttention('Needs Attention');

  const HistoryFilter(this.label);

  final String label;
}

/// Signals state layer for Job Orders.
/// Pipes the Drift SQLite reactive stream into Signals and provides instant UI computations.
class JobsSignals {
  final JobRepository repository;
  StreamSubscription<List<JobOrderDto>>? _driftSubscription;

  JobsSignals(this.repository) {
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

  // Technician history: the signed-in technician's email, matched against
  // each job's assignedEmail column, plus its own filter and search so the
  // history and the scheduled queue never fight over one query box.
  final technicianEmail = signal<String?>(null);
  final historyFilter = signal<HistoryFilter>(HistoryFilter.all);
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
        final matchesBarangay = (job.barangay ?? '').toLowerCase().contains(query);
        return matchesTicket || matchesCustomer || matchesAddress || matchesBarangay;
      }

      return true;
    }).toList();
  });

  late final ReadonlySignal<int> totalCount = computed(() => allJobs.value.length);

  int _countOf(JobStatus s) =>
      allJobs.value.where((j) => j.jobStatus == s).length;

  late final ReadonlySignal<int> scheduledCount =
      computed(() => _countOf(JobStatus.scheduled));

  late final ReadonlySignal<int> inProgressCount =
      computed(() => _countOf(JobStatus.inProgress));

  late final ReadonlySignal<int> completedCount =
      computed(() => _countOf(JobStatus.completed));

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

  /// Every job assigned to the signed-in technician, newest first. Empty
  /// until the technician's email is known.
  late final ReadonlySignal<List<JobOrderDto>> assignedJobs = computed(() {
    final email = technicianEmail.value;
    if (email == null || email.trim().isEmpty) return const <JobOrderDto>[];

    final mine = allJobs.value.where((j) => j.isAssignedTo(email)).toList();
    mine.sort((a, b) {
      final ad = a.historyDate;
      final bd = b.historyDate;
      if (ad == null && bd == null) return b.id.compareTo(a.id);
      if (ad == null) return 1;
      if (bd == null) return -1;
      final byDate = bd.compareTo(ad);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });
    return mine;
  });

  /// [assignedJobs] narrowed by the history filter chip and search box.
  late final ReadonlySignal<List<JobOrderDto>> historyJobs = computed(() {
    final filter = historyFilter.value;
    final query = historySearch.value.trim().toLowerCase();

    return assignedJobs.value.where((job) {
      final matchesFilter = switch (filter) {
        HistoryFilter.all => true,
        HistoryFilter.inProgress => job.isInProgress,
        HistoryFilter.completed => job.isCompleted,
        HistoryFilter.activated => job.isActivated,
        HistoryFilter.needsAttention => job.siteException != null,
      };
      if (!matchesFilter) return false;

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

  int _historyCountOf(JobStatus s) =>
      assignedJobs.value.where((j) => j.jobStatus == s).length;

  late final ReadonlySignal<int> historyInProgressCount =
      computed(() => _historyCountOf(JobStatus.inProgress));

  late final ReadonlySignal<int> historyCompletedCount =
      computed(() => _historyCountOf(JobStatus.completed));

  late final ReadonlySignal<int> historyActivatedCount =
      computed(() => _historyCountOf(JobStatus.activated));

  late final ReadonlySignal<int> historyExceptionCount = computed(
    () => assignedJobs.value.where((j) => j.siteException != null).length,
  );

  /// Pipe Drift SQLite reactive stream into allJobs signal
  void _initDriftStream() {
    _driftSubscription?.cancel();
    _driftSubscription = repository.watchJobs().listen((jobs) {
      allJobs.value = jobs;
    });
  }

  /// Initial load and remote fetch (optionally filtered by status).
  ///
  /// With [initial] set, and only when Drift holds nothing yet, the screen is
  /// walked through the download indicator and a brief skeleton pass before
  /// the hydrated Drift rows are revealed.
  Future<void> fetchRemote({String? statusFilter, bool initial = false}) async {
    final showPhases = initial && allJobs.value.isEmpty;
    if (showPhases) loadPhase.value = DataLoadPhase.downloading;
    isRefreshing.value = true;
    try {
      await repository.fetchRemoteJobs(statusFilter: statusFilter);
    } finally {
      isRefreshing.value = false;
      if (showPhases) {
        loadPhase.value = DataLoadPhase.skeleton;
        await Future<void>.delayed(const Duration(milliseconds: 900));
        loadPhase.value = DataLoadPhase.ready;
      }
    }
  }

  /// Grab / Accept a scheduled job and immediately put it In Progress
  Future<void> grabJob(JobOrderDto job) async {
    await repository.grabScheduledJob(job.id);
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

  void setHistoryFilter(HistoryFilter filter) {
    historyFilter.value = filter;
  }

  void setHistorySearch(String query) {
    historySearch.value = query;
  }

  /// Advance a job: In Progress -> Completed -> Activated.
  ///
  /// A job already Activated does not advance; rolling it around a cycle would
  /// overwrite a finished record on the server.
  Future<void> advanceJobStatus(JobOrderDto job) async {
    final next = job.nextStatus;
    if (next == null) return;
    await repository.updateJobStatus(job.id, next.wireValue);
  }

  /// Must be awaited: the Drift stream subscription has to be fully torn down
  /// before the database can be closed, otherwise close() blocks forever.
  Future<void> dispose() async {
    await _driftSubscription?.cancel();
    _driftSubscription = null;
  }
}
