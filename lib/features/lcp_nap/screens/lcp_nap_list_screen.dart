import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../models/lcp_nap_model.dart';
import '../signals/lcp_nap_signals.dart';
import '../widgets/lcp_nap_card.dart';
import '../widgets/lcp_nap_map_view.dart';
import 'lcp_nap_detail_screen.dart';

/// Scalable LCP NAP plant distribution screen supporting hierarchical cabinet grouping,
/// searchable cabinet filter, area groupings, and map views for large scale networks.
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
  final Set<String> _expandedCabinets = {};
  bool _initializedExpansion = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  void _toggleAllGroups(bool expand, List<String> allKeys) {
    setState(() {
      if (expand) {
        _expandedCabinets.addAll(allKeys);
      } else {
        _expandedCabinets.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final signals = widget.signals;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LCP NAP Plant Network',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              'Distribution cabinets & NAP plant sites',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
              ),
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
                SnackBar(
                  content: const Text('Syncing LCP NAP records with backend...'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: isDark ? AppTheme.darkCard : AppTheme.darkSlate,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Plant Metrics & Search Toolbar
          Container(
            color: isDark ? AppTheme.darkCard : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // KPI Stats Row
                SignalBuilder(
                  builder: (context) {
                    final sites = signals.totalSitesCount.value;
                    final ports = signals.totalPortsCount.value;
                    final cabinets = signals.lcpCabinetList.value.length - 1;

                    return Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.storage_rounded,
                          label: '$cabinets LCP Cabinets',
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          icon: Icons.pin_drop_outlined,
                          label: '$sites NAP Sites',
                          color: const Color(0xFF0EA5E9),
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          icon: Icons.hub_outlined,
                          label: '$ports Ports',
                          color: const Color(0xFF10B981),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Search Input Field
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    signals.setSearch(val);
                    if (val.isNotEmpty) {
                      // Auto-expand all matching groups when searching
                      final groups = signals.groupedByLcp.value.keys;
                      _expandedCabinets.addAll(groups);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search LCP, NAP, Barangay, City, Street...',
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

                // View Toggle (List vs Map) & Filter Controls
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<_LcpNapView>(
                        segments: const [
                          ButtonSegment(
                            value: _LcpNapView.list,
                            icon: Icon(Icons.account_tree_rounded, size: 16),
                            label: Text('Grouped List'),
                          ),
                          ButtonSegment(
                            value: _LcpNapView.map,
                            icon: Icon(Icons.map_rounded, size: 16),
                            label: Text('Plant Map'),
                          ),
                        ],
                        selected: {_view},
                        onSelectionChanged: (sel) =>
                            setState(() => _view = sel.first),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Cabinet Filter Selector Button
                    _buildCabinetFilterButton(signals, isDark),
                  ],
                ),
              ],
            ),
          ),

          // 2. Active Filter indicator (if a specific cabinet is filtered)
          SignalBuilder(
            builder: (context) {
              final activeLcp = signals.selectedLcpFilter.value;
              if (activeLcp == 'All') return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: isDark ? const Color(0xFF3F2327) : AppTheme.primarySubtleBg,
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_rounded, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Filtered by Cabinet: $activeLcp',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => signals.setLcpFilter('All'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Show All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            },
          ),

          // 3. Body View: Scalable Grouped List or Interactive Map
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
                  final grouped = signals.groupedByLcp.value;
                  final isLoading = signals.isLoading.value;

                  if (isLoading && grouped.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }

                  if (grouped.isEmpty) {
                    return _buildEmptyState(signals);
                  }

                  final allCabinetKeys = grouped.keys.toList()..sort();

                  // Auto-expand all on first load
                  if (!_initializedExpansion && allCabinetKeys.isNotEmpty) {
                    _expandedCabinets.addAll(allCabinetKeys);
                    _initializedExpansion = true;
                  }

                  return RefreshIndicator(
                    onRefresh: signals.fetchRemote,
                    color: AppTheme.primary,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Grouping Toolbar (Expand/Collapse all)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${allCabinetKeys.length} LCP Cabinet Group${allCabinetKeys.length == 1 ? "" : "s"} (${signals.filteredLocations.value.length} NAPs)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                              ),
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () => _toggleAllGroups(true, allCabinetKeys),
                                  icon: const Icon(Icons.unfold_more_rounded, size: 14),
                                  label: const Text('Expand All', style: TextStyle(fontSize: 11)),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _toggleAllGroups(false, allCabinetKeys),
                                  icon: const Icon(Icons.unfold_less_rounded, size: 14),
                                  label: const Text('Collapse All', style: TextStyle(fontSize: 11)),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // LCP Group Accordion Cards
                        ...allCabinetKeys.map((cabinetName) {
                          final naps = grouped[cabinetName] ?? [];
                          final isExpanded = _expandedCabinets.contains(cabinetName);
                          final totalPorts = naps.fold(0, (sum, n) => sum + n.portTotal);
                          final locationHint = naps.firstOrNull != null
                              ? [naps.first.barangay, naps.first.city].where((s) => s != null && s.isNotEmpty).join(', ')
                              : '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                // Cabinet Header
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedCabinets.remove(cabinetName);
                                      } else {
                                        _expandedCabinets.add(cabinetName);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.storage_rounded,
                                            size: 18,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cabinetName,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              if (locationHint.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  locationHint,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Badge for count of NAPs & ports
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isDark ? AppTheme.darkInput : AppTheme.lightBg,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                            ),
                                          ),
                                          child: Text(
                                            '${naps.length} NAPs • $totalPorts P',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up_rounded
                                              : Icons.keyboard_arrow_down_rounded,
                                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Expanded NAP list inside this cabinet
                                if (isExpanded) ...[
                                  Divider(height: 1, color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: naps.length,
                                      itemBuilder: (context, napIdx) {
                                        final nap = naps[napIdx];
                                        return LcpNapCard(
                                          location: nap,
                                          onTap: () => _openDetails(nap),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCabinetFilterButton(LcpNapSignals signals, bool isDark) {
    return SignalBuilder(
      builder: (context) {
        final cabinets = signals.lcpCabinetList.value;
        final selected = signals.selectedLcpFilter.value;

        return OutlinedButton.icon(
          onPressed: () => _showCabinetSelectionModal(context, signals, cabinets, selected, isDark),
          icon: const Icon(Icons.filter_list_rounded, size: 16),
          label: Text(
            selected == 'All' ? 'Filter LCP' : selected,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected != 'All' ? FontWeight.w800 : FontWeight.w600,
              color: selected != 'All' ? AppTheme.primary : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            side: BorderSide(
              color: selected != 'All' ? AppTheme.primary : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
            ),
          ),
        );
      },
    );
  }

  void _showCabinetSelectionModal(
    BuildContext context,
    LcpNapSignals signals,
    List<String> cabinets,
    String currentSelected,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.storage_rounded, color: AppTheme.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Filter by LCP Cabinet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select an LCP Cabinet to isolate its NAP plant locations:',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView.separated(
                    itemCount: cabinets.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    ),
                    itemBuilder: (context, index) {
                      final cabinet = cabinets[index];
                      final isSelected = cabinet == currentSelected;

                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        title: Text(
                          cabinet == 'All' ? 'All Cabinets (Show Everything)' : cabinet,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? AppTheme.primary : null,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 18)
                            : null,
                        onTap: () {
                          signals.setLcpFilter(cabinet);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
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

  Widget _buildEmptyState(LcpNapSignals signals) {
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
              'Try adjusting your search query or reset the LCP cabinet filter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                signals.setLcpFilter('All');
                signals.setSearch('');
                _searchController.clear();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
