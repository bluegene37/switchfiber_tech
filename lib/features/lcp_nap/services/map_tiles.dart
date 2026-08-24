import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:http_cache_drift_store/http_cache_drift_store.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Tile source and on-disk cache for the LCP NAP map.
///
/// Tiles are fetched over the network and cached to disk, so areas a technician
/// has already viewed keep rendering without a signal. Pin data itself comes
/// from Drift and is always available offline.
class MapTiles {
  MapTiles._();

  /// Base layers, matching the Switch Fiber web console so both clients show
  /// the same plant on the same cartography.
  ///
  /// CARTO rather than raw OSM tiles: the OSM Foundation's usage policy does
  /// not permit app traffic against their servers. Esri World Imagery backs the
  /// satellite view, which technicians use to find an actual pole or wall.
  static const String streetLightUrl =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
  static const String streetDarkUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
  static const String satelliteUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/'
      'MapServer/tile/{z}/{y}/{x}';

  static const List<String> cartoSubdomains = ['a', 'b', 'c', 'd'];

  static const String streetAttribution = '© OpenStreetMap © CARTO';
  static const String satelliteAttribution =
      'Imagery © Esri — Source: Esri, Maxar, Earthstar Geographics';

  /// Esri's imagery service does not serve tiles past zoom 19.
  static const double satelliteMaxZoom = 19;
  static const double streetMaxZoom = 20;

  /// Identifies this client to the tile providers.
  static const String userAgentPackageName = 'ph.switchfiber.tech';

  /// How long a cached tile stays usable offline before it is refetched.
  static const Duration _cacheDuration = Duration(days: 30);

  static TileProvider? _provider;

  /// Build the caching tile provider. Safe to call repeatedly; the underlying
  /// store is created once.
  ///
  /// Uses its own [Dio] instance rather than the app's API client, which is
  /// pinned to the Switch Fiber server's self-signed certificate and must not
  /// be reused for public hosts.
  static Future<TileProvider> provider() async {
    final existing = _provider;
    if (existing != null) return existing;

    final dir = await getApplicationCacheDirectory();
    final store = DriftCacheStore(
      databasePath: p.join(dir.path, 'map_tiles'),
    );

    final created = CachedTileProvider(
      store: store,
      maxStale: _cacheDuration,
      dio: Dio(),
    );
    _provider = created;
    return created;
  }
}
