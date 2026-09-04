import '../../../core/network/api_client.dart';
import '../../../core/network/network_exceptions.dart';

/// The two job-order calls the app makes, behind an interface so the
/// repository and sync worker can be exercised without a server.
abstract class JobOrdersApi {
  /// `GET /api/JobOrders/status/{status}`: every job order in one status.
  /// The server matches the status case-insensitively.
  Future<List<Map<String, dynamic>>> fetchByStatus(String status);

  /// `GET /api/JobOrders/status-assigned`: filter by status and optional
  /// assigned technician email.
  Future<List<Map<String, dynamic>>> fetchByStatusAssigned({
    required String status,
    String? assignedEmail,
  }) =>
      fetchByStatus(status);

  /// `GET /api/JobOrders/status-date`: filter by status, date range, or both.
  /// [dateFrom] and [dateTo] filter on `dateInstalled` (format yyyy-MM-dd).
  Future<List<Map<String, dynamic>>> fetchByStatusDate({
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) =>
      fetchByStatus(status ?? '');

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
    final cleanStatus = Uri.encodeComponent(status.trim());
    final response = await _api.get('/JobOrders/status/$cleanStatus');
    final data = response.data;
    if (data is! List) return const [];
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) item,
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchByStatusAssigned({
    required String status,
    String? assignedEmail,
  }) async {
    final queryParams = <String, dynamic>{
      'status': status.trim(),
      if (assignedEmail != null && assignedEmail.trim().isNotEmpty)
        'assignedEmail': assignedEmail.trim(),
    };
    final response = await _api.get(
      '/JobOrders/status-assigned',
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data is! List) return const [];
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) item,
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchByStatusDate({
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.trim().isNotEmpty) {
      queryParams['status'] = status.trim();
    }
    if (dateFrom != null) {
      queryParams['dateFrom'] =
          '${dateFrom.year}-${dateFrom.month.toString().padLeft(2, '0')}-${dateFrom.day.toString().padLeft(2, '0')}';
    }
    if (dateTo != null) {
      queryParams['dateTo'] =
          '${dateTo.year}-${dateTo.month.toString().padLeft(2, '0')}-${dateTo.day.toString().padLeft(2, '0')}';
    }

    final response = await _api.get(
      '/JobOrders/status-date',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
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
