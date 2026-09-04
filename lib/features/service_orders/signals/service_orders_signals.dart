import 'dart:async';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/service_orders_dao.dart';
import '../../../core/services/photo_storage_service.dart';
import '../models/service_order_model.dart';
import '../services/service_orders_api.dart';
import '../services/service_orders_sync_worker.dart';

/// Signals state container for Service Orders (repairs, maintenance, swaps).
/// Connects reactive Drift SQLite persistence and background sync worker.
class ServiceOrdersSignals {
  final ServiceOrdersApi api;
  final ServiceOrdersDao? dao;
  late final ServiceOrdersSyncWorker? syncWorker;
  StreamSubscription<List<ServiceOrder>>? _driftSubscription;

  ServiceOrdersSignals({
    ServiceOrdersApi? api,
    this.dao,
  }) : api = api ?? ServiceOrdersApi() {
    if (dao != null) {
      syncWorker = ServiceOrdersSyncWorker(dao!, api: this.api);
      _initDriftStream();
    } else {
      syncWorker = null;
    }
  }

  void _initDriftStream() {
    if (dao == null) return;
    _driftSubscription?.cancel();
    _driftSubscription = dao!.watchAllOrders().listen((rows) {
      allOrders.value = rows.map(ServiceOrderDto.fromDrift).toList();
    });
  }

  void dispose() {
    _driftSubscription?.cancel();
  }

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
  late final ReadonlySignal<int> totalCount =
      computed(() => allOrders.value.length);

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
      if (dao != null) {
        final pending = await dao!.getUnsyncedIds();
        final companions = <ServiceOrdersCompanion>[];
        final keep = <int>{};
        for (final dto in remoteList) {
          keep.add(dto.id);
          if (pending.contains(dto.id)) continue;
          companions.add(dto.toCompanion(synced: true));
        }
        if (companions.isNotEmpty) {
          await dao!.insertAllOrders(companions);
        }
        await dao!.deleteSyncedOrdersNotIn(keep);
      } else {
        allOrders.value = remoteList;
      }
    } catch (e) {
      syncError.value = 'Failed to load service orders: $e';
    } finally {
      isSyncing.value = false;
    }
  }

  /// Update single service order locally and remotely
  Future<bool> submitCompletion(ServiceOrderDto updated) async {
    isSyncing.value = true;
    syncError.value = null;

    // Offload Base64 photos & signatures to disk files before SQLite write
    final photoStorage = PhotoStorageService.instance;
    final savedSig = await photoStorage.savePhotoLocally(
      updated.clientSignature,
      tag: 'sig',
      entityId: updated.id,
    );
    final savedImg1 = await photoStorage.savePhotoLocally(
      updated.image1,
      tag: 'img1',
      entityId: updated.id,
    );
    final savedImg2 = await photoStorage.savePhotoLocally(
      updated.image2,
      tag: 'img2',
      entityId: updated.id,
    );
    final savedImg3 = await photoStorage.savePhotoLocally(
      updated.image3,
      tag: 'img3',
      entityId: updated.id,
    );
    final savedHf = await photoStorage.savePhotoLocally(
      updated.houseFrontPicture,
      tag: 'house_front',
      entityId: updated.id,
    );

    final prepared = updated.copyWith(
      clientSignature: savedSig,
      image1: savedImg1,
      image2: savedImg2,
      image3: savedImg3,
      houseFrontPicture: savedHf,
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    if (dao != null) {
      // Optimistic local persist to Drift SQLite
      await dao!.insertOrUpdateOrder(prepared.toCompanion(synced: false));
      // Proactively trigger background sync
      unawaited(syncWorker?.syncPendingOrders());
      isSyncing.value = false;
      return true;
    }

    try {
      final payload = await prepared.toApiJsonAsync();
      final ok = await api.updateServiceOrder(prepared.id, payload);
      if (ok) {
        // Update in-memory list
        final list = List<ServiceOrderDto>.from(allOrders.value);
        final idx = list.indexWhere((o) => o.id == prepared.id);
        if (idx != -1) {
          list[idx] = prepared.copyWith(isSynced: true);
        } else {
          list.insert(0, prepared.copyWith(isSynced: true));
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
