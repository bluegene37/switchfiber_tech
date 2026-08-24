import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../models/lcp_nap_model.dart';
import '../services/map_clustering.dart';
import '../services/map_tiles.dart';
import '../signals/lcp_nap_signals.dart';
import 'lcp_nap_pin_popup.dart';

/// Map of LCP NAP sites, driven by the same filtered signal as the list view.
///
/// [tileProvider] is injectable so widget tests can supply one that never hits
/// the network.
class LcpNapMapView extends StatefulWidget {
  final LcpNapSignals signals;
  final TileProvider? tileProvider;
  final void Function(LcpNapDto location)? onOpenDetails;

  const LcpNapMapView({
    super.key,
    required this.signals,
    this.tileProvider,
    this.onOpenDetails,
  });

  @override
  State<LcpNapMapView> createState() => _LcpNapMapViewState();
}

class _LcpNapMapViewState extends State<LcpNapMapView> {
  final MapController _mapController = MapController();

  /// Centre used before any site has loaded: Binangonan, Rizal, where the
  /// current plant records sit.
  static const LatLng _fallbackCentre = LatLng(14.4695, 121.1956);

  TileProvider? _tiles;
  LcpNapDto? _selected;
  bool _didInitialFit = false;
  bool _satellite = false;
  bool _showLegend = false;
  double _zoom = 14;

  @override
  void initState() {
    super.initState();
    _tiles = widget.tileProvider;
    if (_tiles == null) _loadTileProvider();
  }

  Future<void> _loadTileProvider() async {
    final provider = await MapTiles.provider();
    if (!mounted) return;
    setState(() => _tiles = provider);
  }

  void _fitToSites(List<LcpNapDto> sites) {
    final points = sites.map((s) => s.latLng!).toList();
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 16);
      return;
    }
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(48),
      ),
    );
  }

  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      (_mapController.camera.zoom + 1).clamp(3.0, 19.0),
    );
  }

  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      (_mapController.camera.zoom - 1).clamp(3.0, 19.0),
    );
  }

  /// Frame every site the first time records arrive, so the technician opens
  /// the map on their whole plant rather than zoomed onto one arbitrary box.
  /// Sites load asynchronously from Drift, so this cannot be done via
  /// MapOptions' initial camera alone.
  void _fitOnFirstLoad(List<LcpNapDto> sites) {
    if (_didInitialFit || sites.isEmpty) return;
    _didInitialFit = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fitToSites(sites);
    });
  }

  /// Zoom to a cluster's members so they separate into individual pins.
  void _zoomInto(MapCluster cluster) {
    final points = cluster.sites.map((s) => s.latLng!).toList();
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(64),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _tiles;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (tiles == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    return SignalBuilder(
      builder: (context) {
        final sites = widget.signals.mappableLocations.value;
        final unmappedSites = widget.signals.unmappedLocations.value;
        final unmapped = unmappedSites.length;
        _fitOnFirstLoad(sites);

        // A site can disappear from the filtered set while its popup is open.
        final selected = _selected != null &&
                sites.any((s) => s.id == _selected!.id)
            ? sites.firstWhere((s) => s.id == _selected!.id)
            : null;

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: sites.isNotEmpty
                    ? sites.first.latLng!
                    : _fallbackCentre,
                initialZoom: sites.isEmpty ? 11 : 14,
                onTap: (_, __) => setState(() {
                  _selected = null;
                  _showLegend = false;
                }),
                onPositionChanged: (camera, _) {
                  // Re-cluster as the technician zooms.
                  if ((camera.zoom - _zoom).abs() >= 0.5) {
                    setState(() => _zoom = camera.zoom);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _satellite
                      ? MapTiles.satelliteUrl
                      : (isDark
                          ? MapTiles.streetDarkUrl
                          : MapTiles.streetLightUrl),
                  subdomains:
                      _satellite ? const [] : MapTiles.cartoSubdomains,
                  maxZoom: _satellite
                      ? MapTiles.satelliteMaxZoom
                      : MapTiles.streetMaxZoom,
                  userAgentPackageName: MapTiles.userAgentPackageName,
                  tileProvider: tiles,
                ),
                MarkerLayer(
                  markers: [
                    for (final cluster in clusterSites(sites, zoom: _zoom))
                      Marker(
                        point: cluster.center,
                        width: 44,
                        height: 44,
                        child: cluster.isCluster
                            ? GestureDetector(
                                key: const Key('lcpNapCluster'),
                                onTap: () => _zoomInto(cluster),
                                child: _ClusterPin(count: cluster.count),
                              )
                            : GestureDetector(
                                key: Key('lcpNapPin_${cluster.site.id}'),
                                onTap: () =>
                                    setState(() => _selected = cluster.site),
                                child: _Pin(
                                  selected: selected?.id == cluster.site.id,
                                  label: cluster.site.lcpNap,
                                  nap: cluster.site.nap,
                                  hue: lcpColorSeed(cluster.site.lcp),
                                ),
                              ),
                      ),
                  ],
                ),
              ],
            ),

            // Sites the map cannot place, so they are visibly missing.
            if (unmapped > 0)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: _UnmappedNotice(sites: unmappedSites),
              ),

            // Top Right: Base Layer Toggle
            Positioned(
              top: unmapped > 0 ? 52 : 8,
              right: 8,
              child: _BaseLayerToggle(
                satellite: _satellite,
                onChanged: (v) => setState(() => _satellite = v),
              ),
            ),

            // Top Left: Plant Legend Toggle
            Positioned(
              top: unmapped > 0 ? 52 : 8,
              left: 8,
              child: _PlantLegendButton(
                expanded: _showLegend,
                onToggle: () => setState(() => _showLegend = !_showLegend),
              ),
            ),

            // Plant Legend Expanded Card
            if (_showLegend)
              Positioned(
                top: (unmapped > 0 ? 52 : 8) + 40,
                left: 8,
                child: _PlantLegendOverlay(
                  signals: widget.signals,
                  onClose: () => setState(() => _showLegend = false),
                ),
              ),

            // Right Float: Zoom Controls + Fit Bounds
            Positioned(
              right: 8,
              bottom: selected == null ? 8 : 220,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MapZoomControl(
                    onZoomIn: _zoomIn,
                    onZoomOut: _zoomOut,
                  ),
                  const SizedBox(height: 8),
                  if (sites.isNotEmpty)
                    FloatingActionButton.small(
                      heroTag: 'lcpNapFitBounds',
                      backgroundColor: Theme.of(context).cardTheme.color ?? Colors.white,
                      foregroundColor: AppTheme.primary,
                      tooltip: 'Fit all sites',
                      onPressed: () => _fitToSites(sites),
                      child: const Icon(Icons.fit_screen_rounded),
                    ),
                ],
              ),
            ),

            // Bottom Selected Pin Popup Card
            if (selected != null)
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: LcpNapPinPopup(
                  location: selected,
                  onClose: () => setState(() => _selected = null),
                  onOpenDetails: () => widget.onOpenDetails?.call(selected),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Pin extends StatelessWidget {
  final bool selected;
  final String label;
  final String nap;
  final double hue;

  const _Pin({
    required this.selected,
    required this.label,
    required this.nap,
    required this.hue,
  });

  /// The NAP number alone; the cabinet is conveyed by the pin's colour.
  String get _shortLabel {
    final digits = nap.replaceAll(RegExp(r'\D'), '');
    return digits.isEmpty ? '?' : int.parse(digits).toString();
  }

  @override
  Widget build(BuildContext context) {
    final colour = HSLColor.fromAHSL(1, hue, 0.62, 0.44).toColor();
    return Semantics(
      label: 'Site $label',
      button: true,
      child: Center(
        child: Container(
          width: selected ? 34 : 28,
          height: selected ? 34 : 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colour,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.white : Colors.white70,
              width: selected ? 3 : 2,
            ),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 4,
                  offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            _shortLabel,
            style: TextStyle(
              color: Colors.white,
              fontSize: selected ? 13 : 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// Several sites merged because they would overlap at this zoom.
class _ClusterPin extends StatelessWidget {
  final int count;

  const _ClusterPin({required this.count});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$count sites, zoom in to separate',
      button: true,
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 6,
                  offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// Street / Satellite switch. Satellite is what technicians use to find the
/// actual pole or wall a NAP box is mounted on.
class _BaseLayerToggle extends StatelessWidget {
  final bool satellite;
  final ValueChanged<bool> onChanged;

  const _BaseLayerToggle({required this.satellite, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: Theme.of(context).cardTheme.color ?? Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _seg(context, 'Street', Icons.map_rounded, !satellite,
                () => onChanged(false)),
            _seg(context, 'Satellite', Icons.satellite_alt_rounded, satellite,
                () => onChanged(true)),
          ],
        ),
      ),
    );
  }

  Widget _seg(BuildContext context, String label, IconData icon, bool active,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: active ? Colors.white : AppTheme.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnmappedNotice extends StatelessWidget {
  final List<LcpNapDto> sites;

  const _UnmappedNotice({required this.sites});

  /// Names the records so a technician can go fix their coordinates, rather
  /// than only being told a number is missing.
  String get _summary {
    final names = sites
        .take(3)
        .map((s) => s.lcpNap.trim().isEmpty ? 'record #${s.id}' : s.lcpNap)
        .join(', ');
    final rest = sites.length - 3;
    return rest > 0 ? '$names and $rest more' : names;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.warningSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_off_outlined,
              size: 16, color: Color(0xFF92400E)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${sites.length} site${sites.length == 1 ? '' : 's'} '
              'without a GPS fix: $_summary',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Zoom in / out buttons on the map.
class _MapZoomControl extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _MapZoomControl({
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).cardTheme.color ?? Colors.white;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : AppTheme.darkSlate;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onZoomIn,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.add_rounded, size: 20, color: iconColor),
            ),
          ),
          Container(
            height: 1,
            width: 28,
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
          InkWell(
            onTap: onZoomOut,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.remove_rounded, size: 20, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Button to toggle the Plant Color Legend
class _PlantLegendButton extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const _PlantLegendButton({
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: Theme.of(context).cardTheme.color ?? Colors.white,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.palette_outlined, size: 15, color: AppTheme.primary),
              const SizedBox(width: 5),
              Text(
                'Legend',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: expanded ? AppTheme.primary : (isDark ? Colors.white : AppTheme.darkSlate),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dropdown card showing LCP Cabinet color keys and pin explanation
class _PlantLegendOverlay extends StatelessWidget {
  final LcpNapSignals signals;
  final VoidCallback onClose;

  const _PlantLegendOverlay({
    required this.signals,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final cabinets = signals.lcpCabinetList.value.where((c) => c != 'All').toList();

        return Card(
          elevation: 6,
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'LCP Cabinet Colors',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    InkWell(
                      onTap: onClose,
                      borderRadius: BorderRadius.circular(12),
                      child: const Icon(Icons.close_rounded, size: 16, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pin numbers show NAP box ID. Outer ring hue identifies Cabinet:',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cabinets.length,
                    itemBuilder: (context, index) {
                      final cab = cabinets[index];
                      final hue = lcpColorSeed(cab);
                      final color = HSLColor.fromAHSL(1, hue, 0.62, 0.44).toColor();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cab,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
