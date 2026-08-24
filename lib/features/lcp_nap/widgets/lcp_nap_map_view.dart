import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../models/lcp_nap_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final tiles = _tiles;
    if (tiles == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    return SignalBuilder(
      builder: (context) {
        final sites = widget.signals.mappableLocations.value;
        final unmapped = widget.signals.unmappedCount.value;
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
                onTap: (_, __) => setState(() => _selected = null),
              ),
              children: [
                TileLayer(
                  urlTemplate: MapTiles.urlTemplate,
                  userAgentPackageName: MapTiles.userAgentPackageName,
                  tileProvider: tiles,
                ),
                MarkerLayer(
                  markers: [
                    for (final site in sites)
                      Marker(
                        point: site.latLng!,
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = site),
                          child: _Pin(
                            selected: selected?.id == site.id,
                            // Full site name: NAP numbers repeat across
                            // cabinets, so 'NAP 01' alone identifies nothing.
                            label: site.lcpNap,
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
                child: _UnmappedNotice(count: unmapped),
              ),

            if (sites.isNotEmpty)
              Positioned(
                right: 8,
                bottom: selected == null ? 8 : 200,
                child: FloatingActionButton.small(
                  heroTag: 'lcpNapFitBounds',
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primary,
                  tooltip: 'Fit all sites',
                  onPressed: () => _fitToSites(sites),
                  child: const Icon(Icons.fit_screen_rounded),
                ),
              ),

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

  const _Pin({required this.selected, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Site $label',
      button: true,
      child: Icon(
        Icons.location_on_rounded,
        size: selected ? 40 : 32,
        color: selected ? AppTheme.primaryActive : AppTheme.primary,
        shadows: const [
          Shadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
    );
  }
}

class _UnmappedNotice extends StatelessWidget {
  final int count;

  const _UnmappedNotice({required this.count});

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
        children: [
          const Icon(Icons.location_off_outlined,
              size: 16, color: Color(0xFF92400E)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count site${count == 1 ? '' : 's'} not mapped (no GPS fix)',
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
