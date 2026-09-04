import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/loading_states.dart';
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
        title: Text(
          'LCP NAP Plant Network',
          style: context.text.titleMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_2_circlepath),
            tooltip: 'Sync Plant Records',
            onPressed: () {
              signals.fetchRemote();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      const Text('Syncing LCP NAP records with backend...'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor:
                      isDark ? AppTheme.darkCard : AppTheme.darkSlate,
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
                          context: context,
                          icon: CupertinoIcons.tray_2,
                          label: '$cabinets LCP Cabinets',
                          color: AppTheme.primary,
                          textColor: AppTheme.brandInkOf(context),
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          context: context,
                          icon: CupertinoIcons.location,
                          label: '$sites NAP Sites',
                          color: const Color(0xFF0EA5E9),
                          textColor: AppTheme.infoInkOf(context),
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          context: context,
                          icon: CupertinoIcons.circle_grid_hex,
                          label: '$ports Ports',
                          color: const Color(0xFF10B981),
                          textColor: AppTheme.successInkOf(context),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),

                AppSearchField(
                  controller: _searchController,
                  hintText: 'Search LCP, NAP, Barangay, City',
                  onChanged: (val) {
                    setState(() {});
                    signals.setSearch(val);
                    if (val.isNotEmpty) {
                      _expandedCabinets.addAll(signals.groupedByLcp.value.keys);
                    }
                  },
                ),
                const SizedBox(height: 10),

                // iOS Sliding Segmented Control & Cabinet Filter
                Row(
                  children: [
                    Expanded(
                      child: CupertinoSlidingSegmentedControl<_LcpNapView>(
                        groupValue: _view,
                        backgroundColor:
                            isDark ? AppTheme.darkInput : AppTheme.fillLight,
                        thumbColor:
                            isDark ? AppTheme.darkElevatedCard : Colors.white,
                        children: {
                          _LcpNapView.list: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.square_list,
                                  size: 24,
                                  color: _view == _LcpNapView.list
                                      ? (isDark
                                          ? Colors.white
                                          : AppTheme.darkSlate)
                                      : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Grouped List',
                                  style: context.text.labelLarge!.copyWith(
                                    color: _view == _LcpNapView.list
                                        ? (isDark
                                            ? Colors.white
                                            : AppTheme.darkSlate)
                                        : AppTheme.secondaryInkOf(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _LcpNapView.map: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.map,
                                  size: 24,
                                  color: _view == _LcpNapView.map
                                      ? (isDark
                                          ? Colors.white
                                          : AppTheme.darkSlate)
                                      : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Plant Map',
                                  style: context.text.labelLarge!.copyWith(
                                    color: _view == _LcpNapView.map
                                        ? (isDark
                                            ? Colors.white
                                            : AppTheme.darkSlate)
                                        : AppTheme.secondaryInkOf(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        },
                        onValueChanged: (val) {
                          if (val != null) {
                            setState(() => _view = val);
                          }
                        },
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color:
                    isDark ? const Color(0xFF3F2327) : AppTheme.primarySubtleBg,
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_rounded,
                        size: 20, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Filtered by Cabinet: $activeLcp',
                      style: context.text.labelLarge!.copyWith(
                        color: AppTheme.brandInkOf(context),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => signals.setLcpFilter('All'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Show All'),
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
                  final phase = signals.loadPhase.value;

                  if (phase == DataLoadPhase.downloading) {
                    return const DownloadingIndicator(
                      title: 'Downloading Plant Records',
                      subtitle:
                          'Fetching LCP NAP cabinets and sites from the server...',
                    );
                  }

                  if (phase == DataLoadPhase.skeleton ||
                      (isLoading && grouped.isEmpty)) {
                    return const SkeletonCardList();
                  }

                  if (grouped.isEmpty) {
                    return _buildEmptyState(context, signals);
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
                        // Grouping Toolbar (Expand/Collapse all).
                        // A Wrap, not a Row: at 200% text the summary label
                        // and the two buttons no longer fit on one line on a
                        // 392pt phone. Each item is a direct Wrap child (not
                        // grouped in a nested Row) so any one of the three
                        // can flow to its own line instead of overflowing.
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              '${allCabinetKeys.length} LCP Cabinet Group${allCabinetKeys.length == 1 ? "" : "s"} (${signals.filteredLocations.value.length} NAPs)',
                              style: context.text.labelMedium!.copyWith(
                                color: AppTheme.secondaryInkOf(context),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  _toggleAllGroups(true, allCabinetKeys),
                              icon: const Icon(Icons.unfold_more_rounded,
                                  size: 24),
                              label: const Text('Expand All'),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  _toggleAllGroups(false, allCabinetKeys),
                              icon: const Icon(Icons.unfold_less_rounded,
                                  size: 24),
                              label: const Text('Collapse All'),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // LCP Group Accordion Cards
                        ...allCabinetKeys.map((cabinetName) {
                          final naps = grouped[cabinetName] ?? [];
                          final isExpanded =
                              _expandedCabinets.contains(cabinetName);
                          final totalPorts =
                              naps.fold(0, (sum, n) => sum + n.portTotal);
                          final locationHint = naps.firstOrNull != null
                              ? [naps.first.barangay, naps.first.city]
                                  .where((s) => s != null && s.isNotEmpty)
                                  .join(', ')
                              : '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.borderDark
                                    : AppTheme.borderLight,
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
                                            color: AppTheme.primary.withValues(
                                                alpha: isDark ? 0.2 : 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cabinetName,
                                                style: context.text.titleMedium,
                                              ),
                                              if (locationHint.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  locationHint,
                                                  style:
                                                      context.text.labelSmall,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Badge for count of NAPs & ports
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppTheme.darkInput
                                                  : AppTheme.lightBg,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isDark
                                                    ? AppTheme.borderDark
                                                    : AppTheme.borderLight,
                                              ),
                                            ),
                                            child: Text(
                                              '${naps.length} NAPs • $totalPorts P',
                                              style: context.text.labelMedium,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up_rounded
                                              : Icons
                                                  .keyboard_arrow_down_rounded,
                                          color: isDark
                                              ? AppTheme.textSecondaryDark
                                              : AppTheme.textMuted,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Expanded NAP list inside this cabinet
                                if (isExpanded) ...[
                                  Divider(
                                      height: 1,
                                      color: isDark
                                          ? AppTheme.borderDark
                                          : AppTheme.borderLight),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12, 10, 12, 4),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
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
          onPressed: () => _showCabinetSelectionModal(
              context, signals, cabinets, selected, isDark),
          icon: const Icon(Icons.filter_list_rounded, size: 24),
          label: Text(
            selected == 'All' ? 'Filter LCP' : selected,
            style: context.text.labelLarge!.copyWith(
              fontWeight: selected != 'All' ? FontWeight.w800 : null,
              color: selected != 'All' ? AppTheme.brandInkOf(context) : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            side: BorderSide(
              color: selected != 'All'
                  ? AppTheme.primary
                  : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            // Clear the system navigation bar, which otherwise covers the
            // last row of the sheet.
            padding: EdgeInsets.fromLTRB(
                16, 10, 16, 24 + MediaQuery.of(context).padding.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // iOS Grabber Pill
                Center(
                  child: Container(
                    width: 36,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF38383A)
                          : const Color(0xFFD1D1D6),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(CupertinoIcons.tray_2_fill,
                            color: AppTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Filter by LCP Cabinet',
                          style: context.text.titleMedium,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppTheme.darkInput : AppTheme.fillLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.xmark,
                          size: 24,
                          color: isDark ? Colors.white : AppTheme.darkSlate,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select an LCP Cabinet to isolate its NAP plant locations:',
                  style: context.text.bodySmall,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: cabinets.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color:
                          isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    ),
                    itemBuilder: (context, index) {
                      final cabinet = cabinets[index];
                      final isSelected = cabinet == currentSelected;

                      return ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        title: Text(
                          cabinet == 'All'
                              ? 'All Cabinets (Show Everything)'
                              : cabinet,
                          style: context.text.titleSmall!.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.brandInkOf(context)
                                : null,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(CupertinoIcons.checkmark_alt,
                                color: AppTheme.primary, size: 18)
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
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: context.text.labelMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
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

  Widget _buildEmptyState(BuildContext context, LcpNapSignals signals) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.map_pin_ellipse,
                size: 44, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            Text(
              'No LCP NAP sites match',
              style: context.text.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your search query or reset the LCP cabinet filter.',
              textAlign: TextAlign.center,
              style: context.text.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                signals.setLcpFilter('All');
                signals.setSearch('');
                _searchController.clear();
              },
              icon: const Icon(CupertinoIcons.arrow_2_circlepath, size: 24),
              label: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
