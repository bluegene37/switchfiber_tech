import '../../../core/network/api_client.dart';
import '../models/catalog_model.dart';

/// Service managing official ISP subscription plans and approved ONT/router hardware models.
class CatalogService {
  static final CatalogService instance = CatalogService._internal();
  final ApiClient _api;

  CatalogService._internal([ApiClient? api]) : _api = api ?? ApiClient.instance;

  factory CatalogService({ApiClient? api}) =>
      api == null ? instance : CatalogService._internal(api);

  List<PlanDto>? _cachedPlans;
  List<RouterDto>? _cachedRouters;

  /// Bundled fallback plans matching the live Switch Fiber database
  static const List<PlanDto> fallbackPlans = [
    PlanDto(
      id: 1,
      name: 'SwitchLite - P699',
      description: 'SwitchLite - P699 Up to 50 Mbps',
      amount: 699.0,
      discountId: 1,
    ),
    PlanDto(
      id: 2,
      name: 'SwitchConnect - P799',
      description: 'SwitchConnect - P799 Up to 90 Mbps',
      amount: 799.0,
      discountId: 1,
    ),
    PlanDto(
      id: 3,
      name: 'SwitchNet - P999',
      description: 'SwitchNet - P999 Up to 150 Mbps',
      amount: 999.0,
      discountId: 1,
    ),
  ];

  /// Bundled fallback router models matching the live Switch Fiber database
  static const List<RouterDto> fallbackRouters = [
    RouterDto(
      id: 3,
      name: 'Huawei',
      description: '5v5',
      brand: 'DUAL BAND ONU MODEM',
      model: '1',
    ),
    RouterDto(
      id: 5,
      name: 'UT-KING',
      description: 'UT-XP6486-S',
      brand: 'DUAL BAND ONU MODEM',
      model: '1',
    ),
    RouterDto(
      id: 6,
      name: 'ZTE',
      description: 'F670L',
      brand: 'DUAL BAND MODEM',
      model: '1',
    ),
  ];

  /// Fetch all active broadband plans from `/api/Plans` with cache & fallback
  Future<List<PlanDto>> getPlans({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedPlans != null) {
      return _cachedPlans!;
    }
    try {
      final response = await _api.get('/Plans');
      final data = response.data;
      if (data is List) {
        _cachedPlans = [
          for (final item in data)
            if (item is Map<String, dynamic>) PlanDto.fromJson(item),
        ];
        return _cachedPlans!;
      }
    } catch (_) {}
    return _cachedPlans ?? fallbackPlans;
  }

  /// Fetch approved ONT/router models from `/api/Routers` with cache & fallback
  Future<List<RouterDto>> getRouters({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedRouters != null) {
      return _cachedRouters!;
    }
    try {
      final response = await _api.get('/Routers');
      final data = response.data;
      if (data is List) {
        _cachedRouters = [
          for (final item in data)
            if (item is Map<String, dynamic>) RouterDto.fromJson(item),
        ];
        return _cachedRouters!;
      }
    } catch (_) {}
    return _cachedRouters ?? fallbackRouters;
  }

  List<NapDto>? _cachedNaps;

  /// Bundled fallback NAPs matching the live Switch Fiber database
  static const List<NapDto> fallbackNaps = [
    NapDto(id: 2, name: 'NAP 001', description: 'NAP 001 Description'),
    NapDto(id: 3, name: 'NAP 002', description: 'NAP 002 Description'),
    NapDto(id: 4, name: 'NAP 003', description: 'NAP 003 Description'),
    NapDto(id: 5, name: 'NAP 004', description: 'NAP 004 Description'),
    NapDto(id: 6, name: 'NAP 005', description: 'NAP 005 Description'),
    NapDto(id: 7, name: 'NAP 006', description: 'NAP 006 Description'),
    NapDto(id: 8, name: 'NAP 007', description: 'NAP 007 Description'),
    NapDto(id: 9, name: 'NAP 008', description: 'NAP 008 Description'),
    NapDto(id: 1, name: 'NONE', description: 'NONE Description'),
    NapDto(id: 10, name: 'test nap 1', description: 'test nap 1 Description'),
  ];

  /// Fetch active NAPs from `/api/Naps` with cache & fallback
  Future<List<NapDto>> getNaps({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedNaps != null) {
      return _cachedNaps!;
    }
    try {
      final response = await _api.get('/Naps');
      final data = response.data;
      if (data is List) {
        _cachedNaps = [
          for (final item in data)
            if (item is Map<String, dynamic>) NapDto.fromJson(item),
        ];
        return _cachedNaps!;
      }
    } catch (_) {}
    return _cachedNaps ?? fallbackNaps;
  }
}
