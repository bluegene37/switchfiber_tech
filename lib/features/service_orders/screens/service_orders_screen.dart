import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/theme/app_theme.dart';
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
        title: const Text(
          'Service & Repair Tickets',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
                // iOS Capsule Search Bar
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkInput : AppTheme.fillLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.search,
                        size: 16,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (text) {
                            setState(() {});
                            signals.searchQuery.value = text;
                          },
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : AppTheme.darkSlate,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search repair ticket, account, concern...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {});
                            signals.searchQuery.value = '';
                          },
                          child: const Icon(
                            CupertinoIcons.clear_thick_circled,
                            size: 16,
                            color: AppTheme.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Priority Filter Chips
                SignalBuilder(
                  builder: (context) {
                    final currentPriority = signals.priorityFilter.value;

                    return SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _priorities.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final p = _priorities[index];
                          final isSelected =
                              currentPriority.toLowerCase() == p.toLowerCase();

                          return ChoiceChip(
                            label: Text(p),
                            selected: isSelected,
                            onSelected: (_) {
                              signals.priorityFilter.value = p;
                              setState(() {});
                            },
                            visualDensity: VisualDensity.compact,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppTheme.textSecondaryDark
                                      : AppTheme.darkSlate),
                            ),
                            selectedColor: p == 'Urgent'
                                ? AppTheme.primary
                                : (isDark ? AppTheme.primary : AppTheme.primary),
                          );
                        },
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
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.wrench_fill,
                            size: 16,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$total active repair ticket${total == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          const Spacer(),
                          if (urgent > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$urgent urgent',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
                          const Text(
                            'No Active Service Orders',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'No repair or swap tickets match the current filters.',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white60
                                  : AppTheme.textMuted,
                              fontSize: 13,
                            ),
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
