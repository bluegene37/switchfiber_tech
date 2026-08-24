import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../models/lcp_nap_model.dart';
import '../signals/lcp_nap_signals.dart';
import '../widgets/lcp_nap_card.dart';
import '../widgets/lcp_nap_map_view.dart';
import 'lcp_nap_detail_screen.dart';

/// Screen displaying the list of all LCP NAP distribution points with live search,
/// LCP cabinet filtering, port stats, and reactive state from Drift SQLite.
class LcpNapListScreen extends StatefulWidget {
  final LcpNapSignals signals;

  const LcpNapListScreen({
    super.key,
    required this.signals,
  });

  @override
  State<LcpNapListScreen> createState() => _LcpNapListScreenState();
}

enum _LcpNapView { list, map }

class _LcpNapListScreenState extends State<LcpNapListScreen> {
  final TextEditingController _searchController = TextEditingController();
  _LcpNapView _view = _LcpNapView.list;

  void _openDetails(LcpNapDto location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LcpNapDetailScreen(
          locationId: location.id,
          signals: widget.signals,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signals = widget.signals;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LCP NAP Locations'),
            Text(
              'Fiber plant distribution cabinets & NAP boxes',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Sync Plant Records',
            onPressed: () {
              signals.fetchRemote();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Syncing LCP NAP records with backend...'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.darkSlate,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Plant Metrics Summary Banner (Reactive Computed Signals)
          SignalBuilder(
            builder: (context) {
              final sites = signals.totalSitesCount.value;
              final ports = signals.totalPortsCount.value;

              return Container(
                color: Theme.of(context).cardTheme.color ?? Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    // Stats Row
                    Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.storage_rounded,
                          label: '$sites Sites',
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        // Only total capacity is shown: the API does not
                        // report how many ports are actually in use.
                        _buildStatChip(
                          icon: Icons.hub_outlined,
                          label: '$ports Ports',
                          color: const Color(0xFF2563EB),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Search input
                    TextField(
                      controller: _searchController,
                      onChanged: signals.setSearch,
                      decoration: InputDecoration(
                        hintText: 'Search LCP, NAP, Barangay, City...',
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
                    const SizedBox(height: 10),

                    // List / Map view toggle - both views share this search box
                    // and the filters below it.
                    SegmentedButton<_LcpNapView>(
                      segments: const [
                        ButtonSegment(
                          value: _LcpNapView.list,
                          icon: Icon(Icons.view_list_rounded, size: 18),
                          label: Text('List'),
                        ),
                        ButtonSegment(
                          value: _LcpNapView.map,
                          icon: Icon(Icons.map_rounded, size: 18),
                          label: Text('Map'),
                        ),
                      ],
                      selected: {_view},
                      onSelectionChanged: (sel) =>
                          setState(() => _view = sel.first),
                    ),
                    const SizedBox(height: 10),

                    // Horizontal LCP Cabinet Filter Chips
                    _buildLcpCabinetChips(signals),

                  ],
                ),
              );
            },
          ),

          // 2. Reactive body: list or map, both fed by the same filters
          if (_view == _LcpNapView.map)
            Expanded(
              child: LcpNapMapView(
                signals: signals,
                onOpenDetails: _openDetails,
              ),
            )
          else
          Expanded(
            child: SignalBuilder(
              builder: (context) {
                final locations = signals.filteredLocations.value;
                final isLoading = signals.isLoading.value;

                if (isLoading && locations.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                if (locations.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: signals.fetchRemote,
                  color: AppTheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final item = locations[index];
                      return LcpNapCard(
                        location: item,
                        onTap: () => _openDetails(item),
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

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Horizontal chips for filtering by LCP cabinet.
  Widget _buildLcpCabinetChips(LcpNapSignals signals) {
    return SignalBuilder(
      builder: (context) {
        final cabinets = signals.lcpCabinetList.value;
        final selected = signals.selectedLcpFilter.value;

        return SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cabinets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cabinet = cabinets[index];
              final isSelected = cabinet == selected;

              return ChoiceChip(
                label: Text(cabinet),
                selected: isSelected,
                onSelected: (_) => signals.setLcpFilter(cabinet),
                selectedColor: AppTheme.primary,
                backgroundColor: AppTheme.lightBg,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.darkSlate,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : AppTheme.borderLight,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.share_location_outlined,
                size: 44, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            const Text(
              'No LCP NAP sites match',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try a different search or cabinet filter, or pull to sync the '
              'plant records again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
