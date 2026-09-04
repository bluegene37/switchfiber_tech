import '../../../core/network/api_client.dart';
import '../models/service_order_model.dart';

/// API client for interacting with `/api/ServiceOrders` on the Switch Fiber backend.
class ServiceOrdersApi {
  final ApiClient _api;

  ServiceOrdersApi([ApiClient? api]) : _api = api ?? ApiClient.instance;

  /// Fetch all active service orders from the backend
  Future<List<ServiceOrderDto>> fetchServiceOrders() async {
    final response = await _api.get('/ServiceOrders');
    final data = response.data;
    if (data is List) {
      return [
        for (final item in data)
          if (item is Map<String, dynamic>) ServiceOrderDto.fromJson(item),
      ];
    }
    return [];
  }

  /// Fetch a single service order by its unique ID
  Future<ServiceOrderDto?> fetchServiceOrderById(int id) async {
    final response = await _api.get('/ServiceOrders/$id');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ServiceOrderDto.fromJson(data);
    }
    return null;
  }

  /// Update a service order (e.g. submit completion, equipment swap, or materials)
  Future<bool> updateServiceOrder(int id, Map<String, dynamic> payload) async {
    final response = await _api.put('/ServiceOrders/$id', data: payload);
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
