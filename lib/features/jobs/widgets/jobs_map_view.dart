import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/location_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../lcp_nap/models/lcp_nap_model.dart';
import '../../lcp_nap/services/map_tiles.dart';
import '../../lcp_nap/signals/lcp_nap_signals.dart';
import '../models/job_order_model.dart';
import '../signals/jobs_signals.dart';
import '../../lcp_nap/widgets/map_search_bar.dart';

/// Interactive map view for field technician scheduled job orders,
/// plotting subscriber locations, nearby NAP fiber distribution boxes, and technician GPS position.
class JobsMapView extends StatefulWidget {
  final JobsSignals jobsSignals;
  final LcpNapSignals? lcpNapSignals;
  final void Function(JobOrderDto job)? onOpenJob;

  /// Place search backend. Defaults to the phone's own geocoder; tests
  /// inject a fake so they never touch the platform plugin.
  final PlaceLookup? placeLookup;

  const JobsMapView({
    super.key,
    required this.jobsSignals,
    this.lcpNapSignals,
    this.onOpenJob,
    this.placeLookup,
  });

  @override
  State<JobsMapView> createState() => _JobsMapViewState();
}

class _JobsMapViewState extends State<JobsMapView> {
  final MapController _mapController = MapController();

  static const LatLng _defaultCenter = LatLng(
    LocationService.fallbackLat,
    LocationService.fallbackLng,
  );

  TileProvider? _tiles;
  JobOrderDto? _selectedJob;
  LcpNapDto? _selectedNap;
  LatLng? _technicianPosition;

  /// Where the last place search landed, and what was typed to get there.
  LatLng? _searchTarget;
  String? _searchLabel;

  bool _satellite = false;
  bool _showNaps = true;
  bool _didInitialFit = false;

  @override
  void initState() {
    super.initState();
    _loadTiles();
    _fetchTechnicianLocation();
  }

  Future<void> _loadTiles() async {
    final provider = await MapTiles.provider();
    if (!mounted) return;
    setState(() => _tiles = provider);
  }

  Future<void> _fetchTechnicianLocation() async {
    final pos = await LocationService.instance.getCurrentPosition();
    if (!mounted) return;
    if (pos != null) {
      setState(() {
        _technicianPosition = LatLng(pos.latitude, pos.longitude);
      });
    }
  }

  /// Resolve coordinates for a job: uses direct latLng, or looks up its NAP box.
  LatLng _resolveJobLocation(JobOrderDto job, List<LcpNapDto> naps) {
    if (job.latLng != null) return job.latLng!;

    // Match NAP box by ID
    if (job.napId != null) {
      for (final n in naps) {
        if (n.id == job.napId && n.latLng != null) {
          // Add subtle offset so job doesn't overlap the pole icon exactly
          return LatLng(
            n.latLng!.latitude + 0.00035,
            n.latLng!.longitude + 0.00035,
          );
        }
      }
    }

    // Stable deterministic offset around fallback center based on job ID
    final angle = (job.id * 137.5) * (math.pi / 180.0);
    final radius = 0.003 + ((job.id % 7) * 0.0015);
    return LatLng(
      _defaultCenter.latitude + (radius * math.cos(angle)),
      _defaultCenter.longitude + (radius * math.sin(angle)),
    );
  }

  /// Drop a pin at a searched place and fly the map to it.
  void _onPlaceLocated(LatLng target, String query) {
    setState(() {
      _searchTarget = target;
      _searchLabel = query;
      _selectedJob = null;
      _selectedNap = null;
    });
    _mapController.move(target, 17);
  }

  void _fitAllJobs(List<JobOrderDto> jobs, List<LcpNapDto> naps) {
    final points = <LatLng>[];
    for (final j in jobs) {
      points.add(_resolveJobLocation(j, naps));
    }
    if (_technicianPosition != null) {
      points.add(_technicianPosition!);
    }

    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 16);
      return;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 160),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final jobs = widget.jobsSignals.filteredJobs.value;
    final naps = widget.lcpNapSignals?.allLocations.value ?? [];

    if (!_didInitialFit && jobs.isNotEmpty) {
      _didInitialFit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fitAllJobs(jobs, naps);
      });
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _defaultCenter,
            initialZoom: 14.5,
            minZoom: 4,
            maxZoom: 19,
            onTap: (_, __) {
              setState(() {
                _selectedJob = null;
                _selectedNap = null;
                _searchTarget = null;
              });
            },
          ),
          children: [
            // Map Tile Layer
            TileLayer(
              urlTemplate:
                  _satellite ? MapTiles.satelliteUrl : MapTiles.streetUrl,
              tileProvider: _tiles,
              maxZoom: _satellite
                  ? MapTiles.satelliteMaxZoom
                  : MapTiles.streetMaxZoom,
              userAgentPackageName: MapTiles.userAgentPackageName,
            ),

            // NAP Boxes Layer (Optional Overlay)
            if (_showNaps && naps.isNotEmpty)
              MarkerLayer(
                markers: [
                  for (final nap in naps)
                    if (nap.latLng != null)
                      Marker(
                        point: nap.latLng!,
                        width: 30,
                        height: 30,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedNap = nap;
                              _selectedJob = null;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.hub_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                ],
              ),

            // Job Orders Markers Layer
            MarkerLayer(
              markers: [
                for (final job in jobs)
                  Marker(
                    point: _resolveJobLocation(job, naps),
                    // Wide enough for a full ticket number on one line: the
                    // label measures 108px at this size, plus padding and
                    // border. The box is fixed, so it never reflows.
                    width: 132,
                    height: 52,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedJob = job;
                          _selectedNap = null;
                        });
                        _mapController.move(
                          _resolveJobLocation(job, naps),
                          _mapController.camera.zoom.clamp(15.0, 18.0),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppTheme.primary,
                                width: 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              job.ticketNumber,
                              // Map furniture sits in a fixed-size box, so it
                              // keeps one line at one size. Letting it wrap or
                              // follow the system font scale overflowed the
                              // marker.
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              textScaler: TextScaler.noScaling,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              CupertinoIcons.person_fill,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Current Technician Position Marker
                if (_technicianPosition != null)
                  Marker(
                    point: _technicianPosition!,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x662563EB),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // The searched place, if any.
            if (_searchTarget != null)
              MarkerLayer(
                markers: [
                  Marker(
                    key: const Key('jobsSearchPin'),
                    point: _searchTarget!,
                    width: MapSearchPin.markerWidth,
                    height: MapSearchPin.markerHeight,
                    alignment: Alignment.topCenter,
                    child: MapSearchPin(label: _searchLabel ?? ''),
                  ),
                ],
              ),
          ],
        ),

        // Top: place search, using the phone's own geocoder.
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: MapSearchBar(
            lookup: widget.placeLookup ?? nativePlaceLookup,
            onLocated: _onPlaceLocated,
          ),
        ),

        // Top Floating Control Buttons, beneath the search bar.
        Positioned(
          top: 16 + MapSearchBar.height + 8,
          right: 16,
          child: Column(
            children: [
              _buildMapButton(
                icon: _satellite ? CupertinoIcons.map : CupertinoIcons.globe,
                tooltip: _satellite ? 'Street Map' : 'Satellite View',
                isDark: isDark,
                onTap: () => setState(() => _satellite = !_satellite),
              ),
              const SizedBox(height: 8),
              _buildMapButton(
                icon: _showNaps
                    ? CupertinoIcons.eye_slash_fill
                    : CupertinoIcons.eye_fill,
                tooltip: _showNaps ? 'Hide NAP Boxes' : 'Show NAP Boxes',
                isDark: isDark,
                onTap: () => setState(() => _showNaps = !_showNaps),
              ),
              const SizedBox(height: 8),
              _buildMapButton(
                icon: CupertinoIcons.arrow_up_left_arrow_down_right,
                tooltip: 'Fit All Jobs',
                isDark: isDark,
                onTap: () => _fitAllJobs(jobs, naps),
              ),
              const SizedBox(height: 8),
              _buildMapButton(
                icon: CupertinoIcons.location_fill,
                tooltip: 'My Location',
                isDark: isDark,
                onTap: () async {
                  await _fetchTechnicianLocation();
                  if (_technicianPosition != null) {
                    _mapController.move(_technicianPosition!, 16);
                  }
                },
              ),
            ],
          ),
        ),

        // Bottom Selected Job Card Popup
        if (_selectedJob != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _buildJobCardPopup(context, _selectedJob!, isDark, naps),
          ),

        // Bottom Selected NAP Card Popup
        if (_selectedNap != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _buildNapCardPopup(context, _selectedNap!, isDark),
          ),
      ],
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required String tooltip,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.5,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon,
            size: 20, color: isDark ? Colors.white : AppTheme.darkSlate),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildJobCardPopup(
    BuildContext context,
    JobOrderDto job,
    bool isDark,
    List<LcpNapDto> naps,
  ) {
    final jobPos = _resolveJobLocation(job, naps);
    String? distanceStr;
    if (_technicianPosition != null) {
      final meters = LocationService.instance.distanceBetween(
        startLat: _technicianPosition!.latitude,
        startLng: _technicianPosition!.longitude,
        endLat: jobPos.latitude,
        endLng: jobPos.longitude,
      );
      distanceStr = LocationService.instance.formatDistance(meters);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.5,
        ),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primarySubtleBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppTheme.primarySubtleBorder, width: 0.5),
                ),
                child: Text(
                  job.ticketNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              if (distanceStr != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkInput : AppTheme.fillLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.location_solid,
                          size: 10, color: AppTheme.primary),
                      const SizedBox(width: 3),
                      Text(
                        distanceStr,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              GestureDetector(
                onTap: () => setState(() => _selectedJob = null),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkInput : AppTheme.fillLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(CupertinoIcons.xmark,
                      size: 12,
                      color: isDark ? Colors.white : AppTheme.darkSlate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            job.customerName,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          ),
          const SizedBox(height: 2),
          Text(
            '${job.planName ?? "Fiber Plan"} • ${job.address}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  color: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  borderRadius: BorderRadius.circular(10),
                  onPressed: () {
                    widget.onOpenJob?.call(job);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.doc_text_fill,
                          size: 15, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Open Ticket',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkInput : AppTheme.fillLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          isDark ? AppTheme.borderDark : AppTheme.borderLight,
                      width: 0.5),
                ),
                child: IconButton(
                  tooltip: 'Navigate',
                  icon: const Icon(CupertinoIcons.location_north_fill,
                      color: AppTheme.primary, size: 18),
                  onPressed: () {
                    final url = Uri.parse(
                        'https://maps.apple.com/?q=${jobPos.latitude},${jobPos.longitude}');
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNapCardPopup(BuildContext context, LcpNapDto nap, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 0.5,
        ),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  nap.lcpNap,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedNap = null),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkInput : AppTheme.fillLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(CupertinoIcons.xmark,
                      size: 12,
                      color: isDark ? Colors.white : AppTheme.darkSlate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${nap.lcp} - ${nap.nap}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            nap.street ?? nap.barangay ?? 'No address recorded',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
