import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_text.dart';
import '../theme/app_theme.dart';

/// Opens turn-by-turn directions in a map *app*, never the browser.
///
/// Every https map link (`maps.apple.com`, `google.com/maps`) lands in the
/// phone's browser on Android, and in the browser on iOS too when Google
/// Maps is not installed. A technician on a pole then gets a web page asking
/// them to open the app. So the order is always: Google Maps if it is
/// installed, then whatever the phone uses for map links, and only when
/// nothing on the phone can show a map, the https link as a last resort.
class MapNavigationService {
  MapNavigationService._();

  /// Seam for tests: whether the phone has something that opens [uri].
  @visibleForTesting
  static Future<bool> Function(Uri uri) canLaunch = canLaunchUrl;

  /// Seam for tests: hands [uri] to the phone.
  @visibleForTesting
  static Future<bool> Function(Uri uri) launch =
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

  static bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// Launch turn-by-turn navigation to a coordinates object (such as LatLng).
  static Future<bool> navigateTo(
    dynamic coordinates, {
    String? label,
  }) async {
    final double lat = (coordinates.latitude as num).toDouble();
    final double lng = (coordinates.longitude as num).toDouble();
    return navigateToCoordinates(
      latitude: lat,
      longitude: lng,
      destinationLabel: label,
    );
  }

  /// Directions from the technician's position to [latitude],[longitude].
  static Future<bool> navigateToCoordinates({
    required double latitude,
    required double longitude,
    String? destinationLabel,
  }) {
    final point = '$latitude,$longitude';
    final label = destinationLabel == null || destinationLabel.trim().isEmpty
        ? ''
        : '(${Uri.encodeComponent(destinationLabel.trim())})';
    return _launchFirst(_isIOS
        ? [
            Uri.parse(
                'comgooglemaps://?daddr=$point&directionsmode=driving'),
            Uri.parse('maps://?daddr=$point&dirflg=d'),
            Uri.parse('https://maps.apple.com/?daddr=$point&dirflg=d'),
          ]
        : [
            Uri.parse('google.navigation:q=$point&mode=d'),
            Uri.parse('geo:$point?q=$point$label'),
            Uri.parse('https://www.google.com/maps/dir/?api=1'
                '&destination=$point&travelmode=driving'),
          ]);
  }

  /// Directions to a street [address] when the record carries no
  /// coordinates. The map app geocodes it.
  static Future<bool> navigateToAddress(String address) {
    final q = Uri.encodeComponent(address.trim());
    if (q.isEmpty) return Future.value(false);
    return _launchFirst(_isIOS
        ? [
            Uri.parse('comgooglemaps://?daddr=$q&directionsmode=driving'),
            Uri.parse('maps://?daddr=$q&dirflg=d'),
            Uri.parse('https://maps.apple.com/?daddr=$q&dirflg=d'),
          ]
        : [
            Uri.parse('google.navigation:q=$q&mode=d'),
            Uri.parse('geo:0,0?q=$q'),
            Uri.parse('https://www.google.com/maps/dir/?api=1'
                '&destination=$q&travelmode=driving'),
          ]);
  }

  /// Launch one particular navigation app. Its own URL scheme comes first
  /// so an installed app opens directly; the https form is only for a phone
  /// without it, where the link leads to the store or the browser.
  static Future<bool> launchSpecificMap({
    required String appType,
    required double latitude,
    required double longitude,
    String? label,
  }) {
    final point = '$latitude,$longitude';
    switch (appType.toLowerCase()) {
      case 'waze':
        return _launchFirst([
          Uri.parse('waze://?ll=$point&navigate=yes'),
          Uri.parse('https://waze.com/ul?ll=$point&navigate=yes'),
        ]);
      case 'apple':
        return _launchFirst([
          Uri.parse('maps://?daddr=$point&dirflg=d'),
          Uri.parse('https://maps.apple.com/?daddr=$point&dirflg=d'),
        ]);
      case 'google':
      default:
        return _launchFirst([
          if (_isIOS)
            Uri.parse('comgooglemaps://?daddr=$point&directionsmode=driving')
          else
            Uri.parse('google.navigation:q=$point&mode=d'),
          Uri.parse('https://www.google.com/maps/dir/?api=1'
              '&destination=$point&travelmode=driving'),
        ]);
    }
  }

  /// Tries each candidate in order and stops at the first the phone opens.
  ///
  /// An https link is a valid target for any phone with a browser, which is
  /// exactly the wrong answer here, so it is only ever the final entry.
  static Future<bool> _launchFirst(List<Uri> candidates) async {
    for (final uri in candidates) {
      try {
        if (!await canLaunch(uri)) continue;
        if (await launch(uri)) return true;
      } catch (_) {
        // Try the next one.
      }
    }
    return false;
  }

  /// Shows a modal bottom sheet allowing the technician to pick their preferred navigation app or copy coordinates.
  static void showNavigationChooser({
    required BuildContext context,
    required double latitude,
    required double longitude,
    required String title,
    String? subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        // Clear the system navigation bar, which otherwise covers the last
        // row of the sheet.
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, 24 + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primarySubtleBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.navigation_rounded,
                          color: AppTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Navigation',
                          style: ctx.text.titleSmall,
                        ),
                        Text(
                          title,
                          style: ctx.text.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (subtitle != null && subtitle.isNotEmpty) ...[
              Text(
                subtitle,
                style: ctx.text.bodySmall,
              ),
              const SizedBox(height: 14),
            ],

            // 1. Google Maps Navigation Option
            _buildAppTile(
              context: ctx,
              title: 'Google Maps (Turn-by-Turn Navigation)',
              subtitle: 'Opens the Google Maps app with live driving directions',
              icon: Icons.map_rounded,
              iconColor: const Color(0xFF1A73E8),
              onTap: () async {
                Navigator.pop(ctx);
                final launched = await launchSpecificMap(
                  appType: 'google',
                  latitude: latitude,
                  longitude: longitude,
                  label: title,
                );
                if (!launched && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not launch Google Maps navigation.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.darkSlate,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),

            // 2. Waze Navigation Option
            _buildAppTile(
              context: ctx,
              title: 'Waze Navigation',
              subtitle: 'Live traffic, road alerts, and fastest routes',
              icon: Icons.directions_car_rounded,
              iconColor: const Color(0xFF33CCFF),
              onTap: () async {
                Navigator.pop(ctx);
                final launched = await launchSpecificMap(
                  appType: 'waze',
                  latitude: latitude,
                  longitude: longitude,
                  label: title,
                );
                if (!launched && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not launch Waze navigation.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.darkSlate,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),

            // 3. Copy Coordinates Option
            _buildAppTile(
              context: ctx,
              title: 'Copy GPS Coordinates ($latitude, $longitude)',
              subtitle: 'Copy exact WGS84 location to clipboard',
              icon: Icons.copy_rounded,
              iconColor: AppTheme.primary,
              onTap: () {
                Clipboard.setData(ClipboardData(text: '$latitude, $longitude'));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Coordinates copied: $latitude, $longitude'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.darkSlate,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildAppTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSlate : AppTheme.lightBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.text.labelSmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 24, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
