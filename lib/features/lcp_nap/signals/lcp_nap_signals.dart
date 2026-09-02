import 'dart:async';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/widgets/loading_states.dart';
import '../models/lcp_nap_model.dart';
import '../repositories/lcp_nap_repository.dart';

/// Grouping presentation modes for large scale LCP NAP plant records.
enum LcpGroupMode {
  byLcp('By LCP Cabinet'),
  byCity('By City / Area'),
  flatList('Flat List');

  final String label;
  const LcpGroupMode(this.label);
}

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
  final Signal<String> selectedCityFilter = signal<String>('All');
  final Signal<LcpGroupMode> groupMode = signal<LcpGroupMode>(LcpGroupMode.byLcp);
  final Signal<String> searchQuery = signal<String>('');
  final Signal<LcpNapDto?> selectedLocation = signal<LcpNapDto?>(null);
  final Signal<bool> isLoading = signal<bool>(false);
  final Signal<String?> errorMessage = signal<String?>(null);
  // First-load presentation: downloading -> skeleton -> ready. Stays ready for
  // pull-to-refresh and manual syncs so existing data is never hidden.
  final Signal<DataLoadPhase> loadPhase =
      signal<DataLoadPhase>(DataLoadPhase.ready);

  // --- Computed Signals (Reactive Derived State) ---

  /// Locations filtered by search query, LCP cabinet, and city
  late final Computed<List<LcpNapDto>> filteredLocations = computed(() {
    final list = allLocations.value;
    final lcp = selectedLcpFilter.value;
    final city = selectedCityFilter.value;
    final query = searchQuery.value.trim().toLowerCase();

    return list.where((loc) {
      // LCP cabinet filter
      if (lcp != 'All' && loc.lcp != lcp) return false;

      // City / Area filter
      if (city != 'All' && loc.city != city) return false;

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

  /// Locations grouped by LCP Cabinet for expandable accordion views
  late final Computed<Map<String, List<LcpNapDto>>> groupedByLcp = computed(() {
    final map = <String, List<LcpNapDto>>{};
    for (final loc in filteredLocations.value) {
      final key = loc.lcp.trim().isNotEmpty ? loc.lcp.trim() : 'Unassigned LCP';
      map.putIfAbsent(key, () => []).add(loc);
    }
    return map;
  });

  /// Locations grouped by City / Area
  late final Computed<Map<String, List<LcpNapDto>>> groupedByCity = computed(() {
    final map = <String, List<LcpNapDto>>{};
    for (final loc in filteredLocations.value) {
      final key = (loc.city != null && loc.city!.trim().isNotEmpty)
          ? loc.city!.trim()
          : (loc.barangay != null && loc.barangay!.trim().isNotEmpty
              ? loc.barangay!.trim()
              : 'Other Areas');
      map.putIfAbsent(key, () => []).add(loc);
    }
    return map;
  });

  /// Distinct list of LCP Cabinets with site counts
  late final Computed<List<String>> lcpCabinetList = computed(() {
    final list = allLocations.value;
    final cabinets = <String>{'All'};
    for (final loc in list) {
      if (loc.lcp.isNotEmpty) {
        cabinets.add(loc.lcp);
      }
    }
    final sorted = cabinets.toList()..sort();
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

  /// Mappable GPS sites
  late final Computed<List<LcpNapDto>> mappableLocations = computed(
    () => filteredLocations.value.where((l) => l.isMappable).toList(),
  );

  /// Sites without GPS fix
  late final Computed<List<LcpNapDto>> unmappedLocations = computed(
    () => filteredLocations.value.where((l) => !l.isMappable).toList(),
  );

  late final Computed<int> unmappedCount =
      computed(() => unmappedLocations.value.length);

  // --- Initialization & Methods ---

  void _init() {
    _driftSubscription = repository.watchLocations().listen((locations) {
      allLocations.value = locations;

      final currentSelected = selectedLocation.value;
      if (currentSelected != null) {
        final match =
            locations.where((l) => l.id == currentSelected.id).firstOrNull;
        if (match != null) {
          selectedLocation.value = match;
        }
      }
    });
  }

  /// Trigger remote API synchronization.
  ///
  /// With [initial] set, and only when Drift holds nothing yet, the screen is
  /// walked through the download indicator and a brief skeleton pass before
  /// the hydrated Drift rows are revealed.
  Future<void> fetchRemote({bool initial = false}) async {
    final showPhases = initial && allLocations.value.isEmpty;
    if (showPhases) loadPhase.value = DataLoadPhase.downloading;
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await repository.fetchRemoteLocations();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      if (showPhases) {
        loadPhase.value = DataLoadPhase.skeleton;
        await Future<void>.delayed(const Duration(milliseconds: 900));
        loadPhase.value = DataLoadPhase.ready;
      }
    }
  }

  /// Update LCP Cabinet filter
  void setLcpFilter(String lcp) {
    selectedLcpFilter.value = lcp;
  }

  /// Update City / Area filter
  void setCityFilter(String city) {
    selectedCityFilter.value = city;
  }

  /// Update Grouping Mode
  void setGroupMode(LcpGroupMode mode) {
    groupMode.value = mode;
  }

  /// Update search text query
  void setSearch(String query) {
    searchQuery.value = query;
  }

  /// Select a site for detail inspection
  void selectLocation(LcpNapDto location) {
    selectedLocation.value = location;
  }

  Future<void> dispose() async {
    await _driftSubscription?.cancel();
    _driftSubscription = null;
  }
}
