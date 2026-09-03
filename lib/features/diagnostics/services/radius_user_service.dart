import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../models/radius_user_model.dart';

/// Service managing RADIUS subscriber accounts and live connection/disconnection toggles.
class RadiusUserService {
  static final RadiusUserService instance = RadiusUserService._internal();
  final ApiClient _api;

  RadiusUserService._internal([ApiClient? api]) : _api = api ?? ApiClient.instance;

  factory RadiusUserService({ApiClient? api}) =>
      api == null ? instance : RadiusUserService._internal(api);

  /// Fetch all RADIUS subscriber accounts
  Future<List<RadiusUserDto>> fetchRadiusUsers() async {
    final response = await _api.get('/RadiusUser');
    dynamic raw = response.data;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {}
    }

    if (raw is List) {
      return [
        for (final item in raw)
          if (item is Map<String, dynamic>) RadiusUserDto.fromJson(item),
      ];
    }
    return [];
  }

  /// Fetch a single RADIUS account by name
  Future<RadiusUserDto?> fetchRadiusUserByName(String name) async {
    if (name.trim().isEmpty) return null;
    try {
      final response = await _api.get('/RadiusUser/${Uri.encodeComponent(name)}');
      dynamic raw = response.data;
      if (raw is String) {
        try {
          raw = jsonDecode(raw);
        } catch (_) {}
      }
      if (raw is Map<String, dynamic>) {
        return RadiusUserDto.fromJson(raw);
      }
    } catch (_) {}

    // Fallback: search within list
    final all = await fetchRadiusUsers();
    return all.where((u) => u.name.trim().toLowerCase() == name.trim().toLowerCase()).firstOrNull;
  }

  /// Connect an account via `POST /api/RadiusUser/{name}/connect`
  Future<bool> connectRadiusUser(String name) async {
    final encoded = Uri.encodeComponent(name.trim());
    final response = await _api.post('/RadiusUser/$encoded/connect');
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Disconnect an account via `POST /api/RadiusUser/{name}/disconnect`
  Future<bool> disconnectRadiusUser(String name) async {
    final encoded = Uri.encodeComponent(name.trim());
    final response = await _api.post('/RadiusUser/$encoded/disconnect');
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Toggle connection state and verify against server
  Future<bool> toggleConnection(String name, bool desiredConnected) async {
    if (desiredConnected) {
      return await connectRadiusUser(name);
    } else {
      return await disconnectRadiusUser(name);
    }
  }
}
