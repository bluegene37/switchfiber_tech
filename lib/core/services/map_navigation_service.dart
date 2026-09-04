import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_text.dart';
import '../theme/app_theme.dart';

/// Service to handle launching external GPS navigation apps (Google Maps, Waze, Apple Maps).
class MapNavigationService {
  MapNavigationService._();

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

  /// Launch turn-by-turn navigation from current location to destination [latitude, longitude].
  static Future<bool> navigateToCoordinates({
    required double latitude,
    required double longitude,
    String? destinationLabel,
  }) async {
    final label =
        destinationLabel != null ? Uri.encodeComponent(destinationLabel) : '';

    // Standard Google Maps directions URL (opens Google Maps app with turn-by-turn navigation)
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude${label.isNotEmpty ? "($label)" : ""}&travelmode=driving',
    );

    // Apple Maps directions URL for iOS
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d${label.isNotEmpty ? "&q=$label" : ""}',
    );

    try {
      if (!kIsWeb && Platform.isIOS) {
        if (await canLaunchUrl(appleMapsUrl)) {
          return await launchUrl(appleMapsUrl,
              mode: LaunchMode.externalApplication);
        }
      }

      // Default to Google Maps universal navigation
      if (await canLaunchUrl(googleMapsUrl)) {
        return await launchUrl(googleMapsUrl,
            mode: LaunchMode.externalApplication);
      } else {
        // Fallback to geo URI
        final geoUri = Uri.parse(
            'geo:$latitude,$longitude?q=$latitude,$longitude${label.isNotEmpty ? "($label)" : ""}');
        if (await canLaunchUrl(geoUri)) {
          return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (_) {
      // Fallback
    }

    return false;
  }

  /// Launch specific navigation app
  static Future<bool> launchSpecificMap({
    required String appType,
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    Uri url;
    final encodedLabel = label != null ? Uri.encodeComponent(label) : '';

    switch (appType.toLowerCase()) {
      case 'waze':
        url = Uri.parse(
            'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes');
        break;
      case 'apple':
        url = Uri.parse(
            'https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d');
        break;
      case 'google':
      default:
        url = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude${encodedLabel.isNotEmpty ? "($encodedLabel)" : ""}&travelmode=driving',
        );
        break;
    }

    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
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
              subtitle: 'Starts live driving directions from your GPS location',
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
