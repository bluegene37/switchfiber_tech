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
  final Signal<LcpNapDto?> selectedLocation = signal<LcpNapDto?>(null);
  final Signal<bool> isLoading = signal<bool>(false);
  final Signal<String?> errorMessage = signal<String?>(null);

  // --- Computed Signals (Reactive Derived State) ---

  /// Locations filtered by search query, LCP cabinet, and status
  late final Computed<List<LcpNapDto>> filteredLocations = computed(() {
    final list = allLocations.value;
    final lcp = selectedLcpFilter.value;
    final query = searchQuery.value.trim().toLowerCase();

    return list.where((loc) {
      // LCP cabinet filter
      if (lcp != 'All' && loc.lcp != lcp) return false;

      // Status filter

      // Search match
      if (query.isNotEmpty) {
        final matchesLcpNap = loc.lcpNap.toLowerCase().contains(query);
        final matchesLcp = loc.lcp.toLowerCase().contains(query);
        final matchesNap = loc.nap.toLowerCase().contains(query);
        final matchesBarangay =
            loc.barangay?.toLowerCase().contains(query) ?? false;
        final matchesCity = loc.city?.toLowerCase().contains(query) ?? false;
        final matchesDesc =
            (loc.street?.toLowerCase().contains(query) ?? false) ||
            (loc.region?.toLowerCase().contains(query) ?? false);

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
  late final Computed<List<LcpNapDto>> mappableLocations = computed(
    () => filteredLocations.value.where((l) => l.isMappable).toList(),
  );

  /// Sites the map cannot place because they carry no usable GPS fix.
  late final Computed<List<LcpNapDto>> unmappedLocations = computed(
    () => filteredLocations.value.where((l) => !l.isMappable).toList(),
  );

  /// How many currently-filtered sites have no usable coordinates. Surfaced in
  /// the UI so records without a GPS fix are visibly missing, not silently lost.
  late final Computed<int> unmappedCount =
      computed(() => unmappedLocations.value.length);

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


  /// Select a site for detail inspection
  void selectLocation(LcpNapDto location) {
    selectedLocation.value = location;
  }



  /// Must be awaited: the Drift stream subscription has to be fully torn down
  /// before the database can be closed, otherwise close() blocks forever.
  Future<void> dispose() async {
    await _driftSubscription?.cancel();
    _driftSubscription = null;
  }
}
