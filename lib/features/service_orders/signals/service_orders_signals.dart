import 'package:signals_flutter/signals_flutter.dart';
import '../models/service_order_model.dart';
import '../services/service_orders_api.dart';

/// Signals state container for Service Orders (repairs, maintenance, swaps).
class ServiceOrdersSignals {
  final ServiceOrdersApi api;

  ServiceOrdersSignals({ServiceOrdersApi? api}) : api = api ?? ServiceOrdersApi();

  /// All service orders currently loaded
  final allOrders = signal<List<ServiceOrderDto>>([]);

  /// Whether a sync request is in-flight
  final isSyncing = signal<bool>(false);

  /// Error message from last sync attempt if any
  final syncError = signal<String?>(null);

  /// Search query (subscriber name, account number, address)
  final searchQuery = signal<String>('');

  /// Filter by priority ('All', 'Urgent', 'High', 'Normal')
  final priorityFilter = signal<String>('All');

  /// Filter to only tickets assigned to the logged-in technician
  final onlyAssignedToMe = signal<bool>(false);

  /// Logged-in technician email for matching
  final technicianEmail = signal<String?>(null);

  /// Total count of all service orders
  late final ReadonlySignal<int> totalCount = computed(() => allOrders.value.length);

  /// Urgent service orders count
  late final ReadonlySignal<int> urgentCount =
      computed(() => allOrders.value.where((o) => o.isUrgent).length);

  /// Filtered and sorted service orders
  late final ReadonlySignal<List<ServiceOrderDto>> filteredOrders = computed(() {
    final query = searchQuery.value.trim().toLowerCase();
    final priority = priorityFilter.value.trim().toLowerCase();
    final onlyMe = onlyAssignedToMe.value;
    final email = technicianEmail.value;

    return allOrders.value.where((order) {
      if (onlyMe && !order.isAssignedTo(email)) {
        return false;
      }

      if (priority != 'all') {
        final orderPriority = (order.priorityLevel ?? '').toLowerCase();
        if (!orderPriority.contains(priority)) {
          return false;
        }
      }

      if (query.isNotEmpty) {
        final matchAccount = order.accountNumber.toLowerCase().contains(query);
        final matchName = order.fullName.toLowerCase().contains(query);
        final matchAddress = order.address.toLowerCase().contains(query);
        final matchConcern = order.concern.toLowerCase().contains(query);
        if (!matchAccount && !matchName && !matchAddress && !matchConcern) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) {
        // Urgent first, then by ID descending
        if (a.isUrgent && !b.isUrgent) return -1;
        if (!a.isUrgent && b.isUrgent) return 1;
        return b.id.compareTo(a.id);
      });
  });

  /// Fetch latest service orders from the server
  Future<void> fetchRemote({String? technicianEmail}) async {
    if (technicianEmail != null) {
      this.technicianEmail.value = technicianEmail;
    }
    isSyncing.value = true;
    syncError.value = null;

    try {
      final remoteList = await api.fetchServiceOrders();
      allOrders.value = remoteList;
    } catch (e) {
      syncError.value = 'Failed to load service orders: $e';
    } finally {
      isSyncing.value = false;
    }
  }

  /// Update single service order locally and remotely
  Future<bool> submitCompletion(ServiceOrderDto updated) async {
    isSyncing.value = true;
    try {
      final ok = await api.updateServiceOrder(updated.id, updated.toJson());
      if (ok) {
        // Update in-memory list
        final list = List<ServiceOrderDto>.from(allOrders.value);
        final idx = list.indexWhere((o) => o.id == updated.id);
        if (idx != -1) {
          list[idx] = updated;
        } else {
          list.insert(0, updated);
        }
        allOrders.value = list;
        return true;
      }
    } catch (e) {
      syncError.value = 'Failed to update service order: $e';
    } finally {
      isSyncing.value = false;
    }
    return false;
  }
}
