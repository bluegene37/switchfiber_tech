import 'dart:io';
import 'dart:typed_data';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/services/photo_storage_service.dart';
import 'package:swithfiber_tech/core/utils/data_url.dart';
import 'package:swithfiber_tech/features/service_orders/models/service_order_model.dart';
import 'package:swithfiber_tech/features/service_orders/services/service_orders_api.dart';
import 'package:swithfiber_tech/features/service_orders/signals/service_orders_signals.dart';

class _MockServiceOrdersApi extends ServiceOrdersApi {
  List<ServiceOrderDto> remoteOrders = [];
  Map<int, Map<String, dynamic>> updatedOrders = {};
  bool shouldFailUpdate = false;

  @override
  Future<List<ServiceOrderDto>> fetchServiceOrders() async {
    return remoteOrders;
  }

  @override
  Future<bool> updateServiceOrder(int id, Map<String, dynamic> body) async {
    if (shouldFailUpdate) {
      throw Exception('Network unreachable');
    }
    updatedOrders[id] = body;
    return true;
  }
}

void main() {
  late AppDatabase db;
  late _MockServiceOrdersApi mockApi;
  late Directory tempDir;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    mockApi = _MockServiceOrdersApi();
    tempDir = Directory.systemTemp.createTempSync('service_orders_test_');
    PhotoStorageService.instance.setDirectoryForTesting(tempDir);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  final dummyOrder = ServiceOrderDto(
    id: 501,
    accountNumber: 'SO-2026-001',
    fullName: 'Maria Santos',
    contactNumber: '09171234567',
    emailAddress: 'maria@example.com',
    address: '123 Rizal St, Antipolo',
    concern: 'No Connection',
    priorityLevel: 'Urgent',
    supportStatus: 'Open',
    visitStatus: 'Pending',
  );

  test('ServiceOrdersDao inserts, reads, and updates orders', () async {
    final dao = db.serviceOrdersDao;
    expect(await dao.getAllOrders(), isEmpty);

    await dao.insertOrUpdateOrder(dummyOrder.toCompanion(synced: true));
    final loaded = await dao.getOrderById(501);
    expect(loaded, isNotNull);
    expect(loaded!.accountNumber, 'SO-2026-001');
    expect(loaded.isSynced, isTrue);

    // Watch stream receives updates
    final initialList = await dao.watchAllOrders().first;
    expect(initialList.length, 1);

    // Update with unsynced change
    await dao.insertOrUpdateOrder(
      dummyOrder.copyWith(visitStatus: 'Done').toCompanion(synced: false),
    );

    expect(await dao.countUnsynced(), 1);
    final unsynced = await dao.getUnsyncedOrders();
    expect(unsynced.single.id, 501);
    expect(unsynced.single.visitStatus, 'Done');
    expect(unsynced.single.isSynced, isFalse);

    // Mark as synced
    await dao.markAsSynced(501);
    expect(await dao.countUnsynced(), 0);
  });

  test('ServiceOrdersDao deletes synced orders while preserving unsynced edits',
      () async {
    final dao = db.serviceOrdersDao;

    // Order 501 is synced; Order 502 has an unsynced local edit
    await dao.insertOrUpdateOrder(dummyOrder.toCompanion(synced: true));
    await dao.insertOrUpdateOrder(
      dummyOrder
          .copyWith(id: 502, accountNumber: 'SO-002')
          .toCompanion(synced: false),
    );

    // Server returns only order 503 (501 and 502 are not returned)
    await dao.deleteSyncedOrdersNotIn({503});

    // 501 was synced and not in keepIds -> deleted
    expect(await dao.getOrderById(501), isNull);
    // 502 has local unsynced edit -> preserved!
    expect(await dao.getOrderById(502), isNotNull);
  });

  test('ServiceOrdersSignals fetchRemote populates Drift SQLite', () async {
    final dao = db.serviceOrdersDao;
    mockApi.remoteOrders = [dummyOrder];

    final signals = ServiceOrdersSignals(api: mockApi, dao: dao);
    addTearDown(signals.dispose);

    await signals.fetchRemote();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(signals.allOrders.value.length, 1);
    expect(signals.allOrders.value.single.id, 501);
    expect(signals.totalCount.value, 1);
    expect(signals.urgentCount.value, 1);

    // Verify written to Drift
    final fromDb = await dao.getOrderById(501);
    expect(fromDb, isNotNull);
    expect(fromDb!.fullName, 'Maria Santos');
  });

  test(
      'ServiceOrdersSignals submitCompletion saves locally and offloads photos',
      () async {
    final dao = db.serviceOrdersDao;
    final signals = ServiceOrdersSignals(api: mockApi, dao: dao);
    addTearDown(signals.dispose);

    final dummyPngBytes =
        Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    final signatureDataUrl =
        DataUrl.encode(dummyPngBytes, mimeType: 'image/png');

    final updated = dummyOrder.copyWith(
      visitStatus: 'Done',
      visitRemarks: 'Fiber splice replaced.',
      clientSignature: signatureDataUrl,
    );

    final success = await signals.submitCompletion(updated);
    expect(success, isTrue);

    // Order was saved to Drift SQLite
    final inDb = await dao.getOrderById(501);
    expect(inDb, isNotNull);
    expect(inDb!.visitStatus, 'Done');
    expect(inDb.isSynced, isFalse);

    // Signature was offloaded from Base64 string to a local .png file!
    expect(inDb.clientSignature, isNotNull);
    expect(inDb.clientSignature, endsWith('.png'));
    expect(inDb.clientSignature, startsWith(tempDir.path));
    expect(File(inDb.clientSignature!).existsSync(), isTrue);

    // Background sync worker ran and uploaded the payload back to API with resolved data URL
    while (signals.syncWorker!.isSyncing.value) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    if (!mockApi.updatedOrders.containsKey(501)) {
      await signals.syncWorker!.syncPendingOrders();
    }
    expect(mockApi.updatedOrders.containsKey(501), isTrue);
    final uploadedPayload = mockApi.updatedOrders[501]!;
    expect(uploadedPayload['clientSignature'], signatureDataUrl);

    // Now marked as synced in Drift
    final syncedRow = await dao.getOrderById(501);
    expect(syncedRow!.isSynced, isTrue);
  });
}
