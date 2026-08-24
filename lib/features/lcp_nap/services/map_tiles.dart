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

  /// Public OpenStreetMap tiles.
  ///
  /// NOTE: the OSM Foundation's tile usage policy does not permit heavy or
  /// commercial app traffic against this server. It is fine for development,
  /// but a production rollout needs a dedicated tile server or a paid provider.
  /// Swapping that is a one-line change here.
  static const String urlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Sent so OSM can identify this client, as their policy requires.
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
