import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../signals/lcp_nap_signals.dart';
import '../widgets/lcp_nap_card.dart';
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

class _LcpNapListScreenState extends State<LcpNapListScreen> {
  final TextEditingController _searchController = TextEditingController();

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
              final occupied = signals.totalOccupiedPorts.value;
              final utilization = signals.plantUtilization.value;

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
                        _buildStatChip(
                          icon: Icons.hub_outlined,
                          label: '$occupied/$ports Ports',
                          color: const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          icon: Icons.pie_chart_outline_rounded,
                          label: '${(utilization * 100).toInt()}% Plant Load',
                          color: utilization > 0.8
                              ? AppTheme.danger
                              : AppTheme.success,
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

                    // Horizontal LCP Cabinet Filter Chips
                    _buildLcpCabinetChips(signals),
                    const SizedBox(height: 8),

                    // Status Filters (All / Active / Maintenance / Full)
                    _buildStatusFilterChips(signals),
                  ],
                ),
              );
            },
          ),

          // 2. Reactive Locations List
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
                        onTap: () {
                          // Navigate to detail screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LcpNapDetailScreen(
                                locationId: item.id,
                                signals: signals,
                              ),
                            ),
                          );
                        },
                        onCycleStatus: () async {
                          await signals.cycleStatus(item);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Cycled ${item.lcpNap} in Drift SQLite'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppTheme.darkSlate,
                            ),
                          );
                        },
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

  Widget _buildLcpCabinetChips(LcpNapSignals signals) {
    return SignalBuilder(
      builder: (context) {
        final cabinets = signals.lcpCabinetList.value;
        final selected = signals.selectedLcpFilter.value;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: cabinets.map((cab) {
              final isSelected = selected == cab;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(cab),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.primary : AppTheme.darkSlate,
                  ),
                  backgroundColor: AppTheme.lightBg,
                  selectedColor: AppTheme.primarySubtleBg,
                  checkmarkColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : AppTheme.borderLight,
                    ),
                  ),
                  onSelected: (_) => signals.setLcpFilter(cab),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStatusFilterChips(LcpNapSignals signals) {
    return SignalBuilder(
      builder: (context) {
        final selected = signals.statusFilter.value;
        final statuses = ['All', 'Active', 'Maintenance', 'Full'];

        return Row(
          children: statuses.map((st) {
            final isSelected = selected == st;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                selected: isSelected,
                label: Text(st),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.darkSlate,
                ),
                selectedColor: AppTheme.primary,
                backgroundColor: AppTheme.lightBg,
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onSelected: (_) => signals.setStatusFilter(st),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primarySubtleBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No LCP NAP locations match filters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try clearing your search keyword or switching LCP cabinet filters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                widget.signals.setSearch('');
                widget.signals.setLcpFilter('All');
                widget.signals.setStatusFilter('All');
              },
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
