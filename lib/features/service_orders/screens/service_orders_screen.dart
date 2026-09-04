import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../../core/widgets/loading_states.dart';
import '../signals/service_orders_signals.dart';
import '../widgets/service_order_card.dart';

/// Dedicated screen for Service Orders (Repairs, Equipment Swaps, Maintenance).
class ServiceOrdersScreen extends StatefulWidget {
  final ServiceOrdersSignals signals;

  const ServiceOrdersScreen({
    super.key,
    required this.signals,
  });

  @override
  State<ServiceOrdersScreen> createState() => _ServiceOrdersScreenState();
}

class _ServiceOrdersScreenState extends State<ServiceOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _priorities = ['All', 'Urgent', 'High', 'Normal'];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.signals.searchQuery.value;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signals = widget.signals;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Service & Repair Tickets',
          style: context.text.titleMedium,
        ),
        actions: [
          SignalBuilder(
            builder: (context) {
              final syncing = signals.isSyncing.value;

              return IconButton(
                tooltip: 'Refresh tickets',
                onPressed: syncing
                    ? null
                    : () async {
                        await signals.fetchRemote();
                        if (!context.mounted) return;
                        final error = signals.syncError.value;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              error ?? 'Repairs queue updated from server.',
                            ),
                            backgroundColor: error != null
                                ? AppTheme.warning
                                : AppTheme.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                icon: syncing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      )
                    : const Icon(CupertinoIcons.arrow_2_circlepath),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar & Priority Chips Header
          Container(
            color: isDark ? AppTheme.darkCard : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                AppSearchField(
                  controller: _searchController,
                  hintText: 'Search repair ticket, account, concern',
                  onChanged: (text) {
                    setState(() {});
                    signals.searchQuery.value = text;
                  },
                ),
                const SizedBox(height: 10),

                // Priority Filter Chips
                SignalBuilder(
                  builder: (context) {
                    final currentPriority = signals.priorityFilter.value;

                    // Intrinsic height, not a fixed box: at 200% text a
                    // ChoiceChip needs more than the 32px an 8pt scale was
                    // designed around, and a SizedBox forces it into that
                    // height instead of erroring, silently squeezing the
                    // label. SingleChildScrollView lets the row size to
                    // whatever the chips need while still scrolling
                    // horizontally, same as the ListView it replaces.
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var index = 0;
                              index < _priorities.length;
                              index++) ...[
                            if (index > 0) const SizedBox(width: 8),
                            Builder(builder: (chipContext) {
                              final p = _priorities[index];
                              final isSelected =
                                  currentPriority.toLowerCase() ==
                                      p.toLowerCase();

                              return ChoiceChip(
                                label: Text(p),
                                selected: isSelected,
                                onSelected: (_) {
                                  signals.priorityFilter.value = p;
                                  setState(() {});
                                },
                                labelStyle:
                                    chipContext.text.labelLarge!.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.secondaryInkOf(chipContext),
                                ),
                                selectedColor: switch (p) {
                                  'Urgent' => AppTheme.danger,
                                  'High' => AppTheme.warning,
                                  'Normal' => AppTheme.info,
                                  _ => AppTheme.primary,
                                },
                              );
                            }),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Status Banner
                SignalBuilder(
                  builder: (context) {
                    final total = signals.totalCount.value;
                    final urgent = signals.urgentCount.value;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.borderDark
                              : AppTheme.borderLight,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.wrench_fill,
                            size: 18,
                            color: AppTheme.brandInkOf(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$total active repair ticket${total == 1 ? '' : 's'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.labelMedium!.copyWith(
                                color: AppTheme.secondaryInkOf(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (urgent > 0) const SizedBox(width: 8),
                          if (urgent > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.danger,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$urgent urgent',
                                style: context.text.labelSmall!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 2. Orders List Body
          Expanded(
            child: SignalBuilder(
              builder: (context) {
                final orders = signals.filteredOrders.value;
                final syncing = signals.isSyncing.value;

                if (syncing && orders.isEmpty) {
                  return const DownloadingIndicator(
                    title: 'Loading Service Orders',
                    subtitle:
                        'Fetching maintenance tickets and equipment pullouts...',
                  );
                }

                if (orders.isEmpty) {
                  final hasQuery =
                      signals.searchQuery.value.trim().isNotEmpty;
                  if (hasQuery) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No repair tickets found',
                              style: context.text.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'No tickets matching "${signals.searchQuery.value.trim()}". Check account number or subscriber name.',
                              style: context.text.bodyMedium!.copyWith(
                                color: AppTheme.secondaryInkOf(context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () {
                                _searchController.clear();
                                signals.searchQuery.value = '';
                                setState(() {});
                              },
                              child: const Text('Clear search'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3F2327)
                                  : AppTheme.primarySubtleBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.wrench,
                              size: 36,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Active Service Orders',
                            style: context.text.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'No repair or swap tickets match the current filters.',
                            style: context.text.bodyMedium!.copyWith(
                                color: AppTheme.secondaryInkOf(context)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => signals.fetchRemote(),
                  color: AppTheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return ServiceOrderCard(order: order, signals: signals);
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
}
