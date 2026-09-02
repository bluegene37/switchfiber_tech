import 'package:latlong2/latlong.dart';

import '../models/lcp_nap_model.dart';

/// A pin on the map: either one site, or several merged because they would
/// otherwise overlap at the current zoom.
class MapCluster {
  final LatLng center;
  final List<LcpNapDto> sites;

  const MapCluster({required this.center, required this.sites});

  int get count => sites.length;

  bool get isCluster => sites.length > 1;

  /// The single site, when this is not a cluster.
  LcpNapDto get site => sites.first;
}

/// Group sites that would render on top of each other at [zoom].
///
/// A grid is used rather than a distance-based algorithm: it is O(n), stable as
/// the map pans, and produces the same grouping for the same viewport. The cell
/// halves with each zoom level, so pins separate as the technician zooms in.
///
/// Written in-repo because every published flutter_map clustering package is
/// still pinned to latlong2 <0.10 and will not resolve against flutter_map 8.
List<MapCluster> clusterSites(List<LcpNapDto> sites, {required double zoom}) {
  final mappable = sites.where((s) => s.isMappable).toList();
  if (mappable.isEmpty) return const [];

  // ~80px worth of degrees at this zoom, the point where markers start to
  // collide. 360 degrees spans 256 * 2^zoom pixels in Web Mercator.
  final cell = 360.0 / (256 * _pow2(zoom)) * 80;

  final buckets = <String, List<LcpNapDto>>{};
  for (final s in mappable) {
    final p = s.latLng!;
    final key =
        '${(p.latitude / cell).floor()}:${(p.longitude / cell).floor()}';
    buckets.putIfAbsent(key, () => <LcpNapDto>[]).add(s);
  }

  return buckets.values.map((group) {
    final lat = group.map((s) => s.latLng!.latitude).reduce((a, b) => a + b) /
        group.length;
    final lng = group.map((s) => s.latLng!.longitude).reduce((a, b) => a + b) /
        group.length;
    return MapCluster(center: LatLng(lat, lng), sites: group);
  }).toList();
}

double _pow2(double exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent.round(); i++) {
    result *= 2;
  }
  return result;
}

/// Stable hue for an LCP cabinet, so every NAP hanging off the same cabinet
/// reads as one family. Golden-angle spacing keeps many cabinets visually
/// distinct without a lookup table.
///
/// Mirrors the `lcpHue` function in the Switch Fiber web console so the two
/// clients colour the plant identically.
double lcpColorSeed(String? lcpName) {
  final name = lcpName ?? '';
  final digits = name.replaceAll(RegExp(r'\D'), '');
  var seed = digits.isNotEmpty ? int.tryParse(digits) ?? 0 : 0;
  if (seed == 0) {
    for (final unit in name.codeUnits) {
      seed = (seed * 31 + unit) % 100000;
    }
  }
  return (seed * 137.508) % 360;
}
