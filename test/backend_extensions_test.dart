import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/catalogs/models/catalog_model.dart';
import 'package:swithfiber_tech/features/catalogs/services/catalog_service.dart';
import 'package:swithfiber_tech/features/diagnostics/models/radius_user_model.dart';
import 'package:swithfiber_tech/features/service_orders/models/service_order_model.dart';

void main() {
  group('Step 1: Catalogs (Plans & Routers)', () {
    test('PlanDto deserializes correctly from OpenAPI sample', () {
      final json = {
        'id': 1,
        'name': 'SwitchLite - P699',
        'description': 'SwitchLite - P699 Up to 50 Mbps',
        'amount': 699.00,
        'discountId': 1,
      };

      final plan = PlanDto.fromJson(json);
      expect(plan.id, 1);
      expect(plan.name, 'SwitchLite - P699');
      expect(plan.amount, 699.0);
      expect(plan.formattedPrice, '₱699.00');
    });

    test('RouterDto formats display name and compact name', () {
      final json = {
        'id': 3,
        'name': 'Huawei',
        'description': '5v5',
        'brand': 'DUAL BAND ONU MODEM',
        'model': '1',
      };

      final router = RouterDto.fromJson(json);
      expect(router.id, 3);
      expect(router.name, 'Huawei');
      expect(router.compactName, 'Huawei 5v5');
      expect(router.displayName, 'Huawei 5v5 (DUAL BAND ONU MODEM)');
    });

    test('CatalogService has valid fallbacks', () {
      expect(CatalogService.fallbackPlans.isNotEmpty, true);
      expect(CatalogService.fallbackRouters.isNotEmpty, true);
    });
  });

  group('Step 2: Service Orders (Repairs & Swaps)', () {
    test('ServiceOrderDto deserializes fields and extracts materials slots',
        () {
      final json = {
        'id': 42,
        'accountNumber': '202300042',
        'fullName': 'Mark John P Vizcarra',
        'contactNumber': '09653671826',
        'emailAddress': 'mark@example.com',
        'address': '014 Camias St. Dalig',
        'concern': 'Pullout',
        'priorityLevel': 'Urgent',
        'routerModemSN': 'OLD-SN-1234',
        'newRouterModemSN': 'NEW-SN-5678',
        'addressCoordinates': '14.4705, 121.2150',
        'itemName1': 'Drop Cable (m)',
        'itemQuantity1': 150,
        'itemName2': 'SC/APC Fast Connector',
        'itemQuantity2': 4,
      };

      final order = ServiceOrderDto.fromJson(json);
      expect(order.id, 42);
      expect(order.fullName, 'Mark John P Vizcarra');
      expect(order.concern, 'Pullout');
      expect(order.isUrgent, true);
      expect(order.materialsUsed['Drop Cable (m)'], 150);
      expect(order.materialsUsed['SC/APC Fast Connector'], 4);
      expect(order.latLng, isNotNull);
      expect(order.latLng!.latitude, closeTo(14.4705, 0.0001));
      expect(order.latLng!.longitude, closeTo(121.2150, 0.0001));
    });

    test('ServiceOrderDto serializes materials back to itemName1..10 slots',
        () {
      const order = ServiceOrderDto(
        id: 10,
        accountNumber: 'ACC10',
        fullName: 'Juan',
        contactNumber: '0912',
        emailAddress: 'juan@example.com',
        address: 'Manila',
        materialsUsed: {
          'Drop Cable': 50,
          'Fast Connector': 2,
        },
      );

      final map = order.toJson();
      expect(map['itemName1'], 'Drop Cable');
      expect(map['itemQuantity1'], 50);
      expect(map['itemName2'], 'Fast Connector');
      expect(map['itemQuantity2'], 2);
    });
  });

  group('Step 3: Live RADIUS Telemetry', () {
    test(
        'RadiusUserDto parses group correctly and detects Connected vs Disconnected',
        () {
      final connectedJson = {
        'id': '',
        'name': 'accountt0601261206',
        'group': 'SwitchLite',
        'disabled': false,
        'password': 'switchfiber2023!',
      };

      final disconnectedJson = {
        'id': '',
        'name': 'account3t30812261612',
        'group': 'SwitchLite-Disconnected',
        'disabled': true,
        'password': 'switchfiber2023!',
      };

      final plainDisconnectedJson = {
        'id': '',
        'name': 'cut_off_user',
        'group': 'Disconnected',
        'disabled': false,
      };

      final user1 = RadiusUserDto.fromJson(connectedJson);
      final user2 = RadiusUserDto.fromJson(disconnectedJson);
      final user3 = RadiusUserDto.fromJson(plainDisconnectedJson);

      expect(user1.isConnected, true);
      expect(user1.statusLabel, 'Connected');

      expect(user2.isConnected, false);
      expect(user2.statusLabel, 'Disconnected');

      expect(user3.isConnected, false);
      expect(user3.statusLabel, 'Disconnected');
    });
  });
}
