import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_theme.dart';

/// Resolves a typed place or address to a point, or null when nothing matches.
typedef PlaceLookup = Future<LatLng?> Function(String query);

/// Built lazily on first real search, so tests that inject a fake lookup
/// never construct the platform geocoder.
final geo.Geocoding _geocoder = geo.Geocoding();

/// The phone's own geocoder: Apple's on iOS, Android's Geocoder on Android.
/// No API key is involved.
///
/// Returns the first match, or null when there is none. The geocoding
/// package's 5.x API exposes no public "not found" exception, so an empty
/// list is the only "no result" signal; anything thrown means the geocoder
/// itself could not run, and the caller reports that separately.
Future<LatLng?> nativePlaceLookup(String query) async {
  final results = await _geocoder.locationFromAddress(query);
  if (results.isEmpty) return null;
  final first = results.first;
  return LatLng(first.latitude, first.longitude);
}

/// A search field that floats over a map and moves it to a place.
///
/// The plant is in the Philippines, so a bare query like "SM Megamall" is
/// looked up as "SM Megamall, Philippines" rather than a same-named place
/// abroad. A query that already names the country is passed through as is.
class MapSearchBar extends StatefulWidget {
  final void Function(LatLng target, String query) onLocated;
  final PlaceLookup lookup;

  const MapSearchBar({
    super.key,
    required this.onLocated,
    this.lookup = nativePlaceLookup,
  });

  /// Height of the bar, so maps can place their other overlays beneath it.
  static const double height = 52;

  /// What is actually sent to the geocoder for [query].
  static String biasedQuery(String query) {
    final trimmed = query.trim();
    final lower = trimmed.toLowerCase();
    if (lower.contains('philippines') || lower.contains('pilipinas')) {
      return trimmed;
    }
    return '$trimmed, Philippines';
  }

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty || _busy) return;
    _focus.unfocus();
    setState(() => _busy = true);

    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final target = await widget.lookup(MapSearchBar.biasedQuery(query));
      if (!mounted) return;
      if (target == null) {
        messenger?.showSnackBar(SnackBar(
          content: Text('No place found for "$query".'),
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }
      widget.onLocated(target, query);
    } catch (_) {
      if (!mounted) return;
      messenger?.showSnackBar(const SnackBar(
        content: Text('Place search is not available on this phone right now.'),
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppTheme.darkCard : Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: MapSearchBar.height),
        child: TextField(
          controller: _controller,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          onChanged: (_) => setState(() {}),
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search a place or address',
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            prefixIcon: Icon(Icons.search_rounded,
                size: 22, color: AppTheme.secondaryInkOf(context)),
            suffixIcon: _busy
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                      ),
                    ),
                  )
                : _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: Icon(Icons.close_rounded,
                            size: 18,
                            color: AppTheme.secondaryInkOf(context)),
                        onPressed: () => setState(_controller.clear),
                      ),
          ),
        ),
      ),
    );
  }
}

/// The pin dropped on a map at a searched place, with the query as its label.
///
/// Sized for a `Marker` of 180 by 64 with `Alignment.topCenter`, so the
/// pin's tip sits on the point and the label floats above it.
class MapSearchPin extends StatelessWidget {
  final String label;

  const MapSearchPin({super.key, required this.label});

  static const double markerWidth = 180;
  static const double markerHeight = 64;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.primary, width: 1),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontSize: 11, // map furniture
              fontWeight: FontWeight.w700,
              color: AppTheme.brandInkOf(context),
            ),
          ),
        ),
        const Icon(Icons.location_on_rounded,
            color: AppTheme.primary, size: 36),
      ],
    );
  }
}
