import 'dart:async';
import 'package:signals_flutter/signals_flutter.dart';
import '../models/job_order_model.dart';
import '../repositories/job_repository.dart';

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
  // 'all' or a JobStatus.name: inProgress, completed, activated.
  // Any job whose status is not one of the three appears only under 'all'.
  final activeFilter = signal<String>('all');
  final searchQuery = signal<String>('');
  final selectedJob = signal<JobOrderDto?>(null);
  final isRefreshing = signal<bool>(false);

  // Computeds
  late final ReadonlySignal<List<JobOrderDto>> filteredJobs = computed(() {
    final jobs = allJobs.value;
    final filter = activeFilter.value.toLowerCase();
    final query = searchQuery.value.trim().toLowerCase();

    return jobs.where((job) {
      // 1. Status filter. Handles workflow statuses, site exceptions, and 'all'.
      if (filter != 'all' && filter.isNotEmpty) {
        if (filter == 'exceptions') {
          if (job.siteException == null) return false;
        } else if (job.jobStatus?.name.toLowerCase() != filter) {
          return false;
        }
      }

      // 2. Search Query (Ticket #, Customer Name, Address, Barangay)
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

  /// Pipe Drift SQLite reactive stream into allJobs signal
  void _initDriftStream() {
    _driftSubscription?.cancel();
    _driftSubscription = repository.watchJobs().listen((jobs) {
      allJobs.value = jobs;
    });
  }

  /// Initial load and remote fetch
  Future<void> fetchRemote() async {
    isRefreshing.value = true;
    try {
      await repository.fetchRemoteJobs();
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
