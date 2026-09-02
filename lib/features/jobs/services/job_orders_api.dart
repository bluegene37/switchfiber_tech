import '../../../core/network/api_client.dart';
import '../../../core/network/network_exceptions.dart';

/// The two job-order calls the app makes, behind an interface so the
/// repository and sync worker can be exercised without a server.
abstract class JobOrdersApi {
  /// `GET /api/JobOrders/status/{status}`: every job order in one status.
  /// The server matches the status case-insensitively.
  Future<List<Map<String, dynamic>>> fetchByStatus(String status);

  /// `GET /api/JobOrders/{id}`: one record as the server holds it now, or
  /// null when it no longer exists.
  Future<Map<String, dynamic>?> fetchById(int id);

  /// `PUT /api/JobOrders/{id}` with the complete record. Throws an
  /// [ApiException] whose `statusCode` is 404 when the record is gone.
  Future<void> update(int id, Map<String, dynamic> body);
}

/// [JobOrdersApi] over the shared, certificate-pinned [ApiClient].
class DioJobOrdersApi implements JobOrdersApi {
  final ApiClient _api;

  DioJobOrdersApi([ApiClient? api]) : _api = api ?? ApiClient.instance;

  @override
  Future<List<Map<String, dynamic>>> fetchByStatus(String status) async {
    final response = await _api.get('/JobOrders/status/$status');
    final data = response.data;
    if (data is! List) return const [];
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) item,
    ];
  }

  @override
  Future<Map<String, dynamic>?> fetchById(int id) async {
    try {
      final response = await _api.get('/JobOrders/$id');
      final data = response.data;
      return data is Map<String, dynamic> ? data : null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> update(int id, Map<String, dynamic> body) async {
    await _api.put('/JobOrders/$id', data: body);
  }
}
