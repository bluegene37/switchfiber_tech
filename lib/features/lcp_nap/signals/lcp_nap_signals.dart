import 'dart:async';
import 'package:signals_flutter/signals_flutter.dart';
import '../models/lcp_nap_model.dart';
import '../repositories/lcp_nap_repository.dart';

/// Signals state management for LCP NAP Network Locations.
class LcpNapSignals {
  final LcpNapRepository repository;
  StreamSubscription<List<LcpNapDto>>? _driftSubscription;

  LcpNapSignals(this.repository) {
    _init();
  }

  // --- Core State Signals ---
  final Signal<List<LcpNapDto>> allLocations = signal<List<LcpNapDto>>([]);
  final Signal<String> selectedLcpFilter = signal<String>('All');
  final Signal<String> searchQuery = signal<String>('');
  final Signal<String> statusFilter = signal<String>('All');
  final Signal<LcpNapDto?> selectedLocation = signal<LcpNapDto?>(null);
  final Signal<bool> isLoading = signal<bool>(false);
  final Signal<String?> errorMessage = signal<String?>(null);

  // --- Computed Signals (Reactive Derived State) ---

  /// Locations filtered by search query, LCP cabinet, and status
  late final Computed<List<LcpNapDto>> filteredLocations = computed(() {
    final list = allLocations.value;
    final lcp = selectedLcpFilter.value;
    final status = statusFilter.value;
    final query = searchQuery.value.trim().toLowerCase();

    return list.where((loc) {
      // LCP cabinet filter
      if (lcp != 'All' && loc.lcp != lcp) return false;

      // Status filter
      if (status != 'All' && loc.status.toLowerCase() != status.toLowerCase()) {
        return false;
      }

      // Search match
      if (query.isNotEmpty) {
        final matchesLcpNap = loc.lcpNap.toLowerCase().contains(query);
        final matchesLcp = loc.lcp.toLowerCase().contains(query);
        final matchesNap = loc.nap.toLowerCase().contains(query);
        final matchesBarangay =
            loc.barangay?.toLowerCase().contains(query) ?? false;
        final matchesCity = loc.city?.toLowerCase().contains(query) ?? false;
        final matchesDesc =
            loc.description?.toLowerCase().contains(query) ?? false;

        return matchesLcpNap ||
            matchesLcp ||
            matchesNap ||
            matchesBarangay ||
            matchesCity ||
            matchesDesc;
      }

      return true;
    }).toList();
  });

  /// Distinct list of LCP Cabinets for horizontal filter chips
  late final Computed<List<String>> lcpCabinetList = computed(() {
    final list = allLocations.value;
    final cabinets = <String>{'All'};
    for (final loc in list) {
      if (loc.lcp.isNotEmpty) {
        cabinets.add(loc.lcp);
      }
    }
    final sorted = cabinets.toList()..sort();
    // Ensure 'All' is first
    sorted.remove('All');
    return ['All', ...sorted];
  });

  /// Total count of mapped sites
  late final Computed<int> totalSitesCount =
      computed(() => allLocations.value.length);

  /// Total plant ports count
  late final Computed<int> totalPortsCount = computed(() {
    return allLocations.value.fold(0, (sum, loc) => sum + loc.portTotal);
  });

  /// Total occupied ports across all sites
  late final Computed<int> totalOccupiedPorts = computed(() {
    return allLocations.value.fold(0, (sum, loc) => sum + loc.portOccupied);
  });

  /// Overall fiber capacity utilization (0.0 to 1.0)
  late final Computed<double> plantUtilization = computed(() {
    final total = totalPortsCount.value;
    final occupied = totalOccupiedPorts.value;
    return total > 0 ? (occupied / total).clamp(0.0, 1.0) : 0.0;
  });

  /// Active sites count
  late final Computed<int> activeCount = computed(() {
    return allLocations.value
        .where((loc) => loc.status.toLowerCase() == 'active')
        .length;
  });

  /// Maintenance sites count
  late final Computed<int> maintenanceCount = computed(() {
    return allLocations.value
        .where((loc) => loc.status.toLowerCase() == 'maintenance')
        .length;
  });

  /// Full capacity sites count
  late final Computed<int> fullCount = computed(() {
    return allLocations.value
        .where((loc) => loc.status.toLowerCase() == 'full')
        .length;
  });

  /// Sites from [filteredLocations] that carry a usable GPS fix, i.e. the pins
  /// the map can actually place. Derived from the same filtered list as the
  /// list view, so search and filters apply to both without extra wiring.
  late final Computed<List<LcpNapDto>> mappableLocations = computed(
    () => filteredLocations.value.where((l) => l.isMappable).toList(),
  );

  /// How many currently-filtered sites have no usable coordinates. Surfaced in
  /// the UI so records without a GPS fix are visibly missing, not silently lost.
  late final Computed<int> unmappedCount = computed(
    () => filteredLocations.value.length - mappableLocations.value.length,
  );

  // --- Initialization & Methods ---

  void _init() {
    // 1. Pipe Drift SQLite reactive stream into allLocations signal
    _driftSubscription = repository.watchLocations().listen((locations) {
      allLocations.value = locations;

      // Keep selectedLocation updated if currently inspected
      final currentSelected = selectedLocation.value;
      if (currentSelected != null) {
        final match = locations.where((l) => l.id == currentSelected.id).firstOrNull;
        if (match != null) {
          selectedLocation.value = match;
        }
      }
    });

    // Note: the remote fetch is deliberately NOT started here. Constructing this
    // object happens during app startup, before the technician has authenticated,
    // and an unauthenticated request trips the 401 interceptor which clears
    // secure storage. TechnicianShell triggers the fetch once signed in.
  }

  /// Trigger remote API synchronization
  Future<void> fetchRemote() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await repository.fetchRemoteLocations();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Update LCP Cabinet filter
  void setLcpFilter(String lcp) {
    selectedLcpFilter.value = lcp;
  }

  /// Update search text query
  void setSearch(String query) {
    searchQuery.value = query;
  }

  /// Update Status filter
  void setStatusFilter(String status) {
    statusFilter.value = status;
  }

  /// Select a site for detail inspection
  void selectLocation(LcpNapDto location) {
    selectedLocation.value = location;
  }

  /// Update site status in Drift (Active -> Maintenance -> Full -> Active)
  Future<void> updateSiteStatus(int id, String newStatus) async {
    await repository.updateLocationStatus(id, newStatus);
  }

  /// Cycle status quickly for technician testing
  Future<void> cycleStatus(LcpNapDto loc) async {
    final nextStatus = switch (loc.status.toLowerCase()) {
      'active' => 'Maintenance',
      'maintenance' => 'Full',
      _ => 'Active',
    };
    await updateSiteStatus(loc.id, nextStatus);
  }

  /// Must be awaited: the Drift stream subscription has to be fully torn down
  /// before the database can be closed, otherwise close() blocks forever.
  Future<void> dispose() async {
    await _driftSubscription?.cancel();
    _driftSubscription = null;
  }
}
