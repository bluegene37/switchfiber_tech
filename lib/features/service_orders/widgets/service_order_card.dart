import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/map_navigation_service.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../models/service_order_model.dart';
import '../screens/service_order_detail_screen.dart';
import '../signals/service_orders_signals.dart';

/// Inset Grouped iOS card displaying a Service Order (repair, pullout, trouble ticket).
class ServiceOrderCard extends StatelessWidget {
  final ServiceOrderDto order;
  final ServiceOrdersSignals signals;

  const ServiceOrderCard({
    super.key,
    required this.order,
    required this.signals,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrgent = order.isUrgent;

    // Calculate distance from technician if coordinates available
    String? distanceStr;
    final myPos = LocationService.instance.lastKnownPosition;
    final orderPos = order.latLng;
    if (myPos != null && orderPos != null) {
      final meters = LocationService.instance.distanceBetween(
        startLat: myPos.latitude,
        startLng: myPos.longitude,
        endLat: orderPos.latitude,
        endLng: orderPos.longitude,
      );
      distanceStr = LocationService.instance.formatDistance(meters);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent
              ? AppTheme.primary
              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          width: isUrgent ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => ServiceOrderDetailScreen(
                  orderId: order.id,
                  signals: signals,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Concern Pill & Priority Badge
                Row(
                  children: [
                    // The concern is free text from the ticket and can be long
                    // ("No Internet Connection"); at a doubled text scale it
                    // overflowed this row by 506 px. Flexible plus an ellipsis
                    // lets the pill give way to the priority badge beside it.
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.primarySubtleBgDark
                              : AppTheme.primarySubtleBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.primarySubtleBorderDark
                                : AppTheme.primarySubtleBorder,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              order.concern.toLowerCase().contains('pullout')
                                  ? CupertinoIcons.arrow_right_arrow_left
                                  : CupertinoIcons.wrench_fill,
                              size: 20,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                order.concern,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.labelLarge!.copyWith(
                                  color: AppTheme.brandInkOf(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'URGENT',
                          style: context.text.labelLarge!.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else if (distanceStr != null)
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.location_solid,
                            size: 20,
                            color: isDark ? Colors.white60 : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            distanceStr,
                            style: context.text.labelMedium!.copyWith(
                              color: AppTheme.secondaryInkOf(context),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subscriber Name
                Text(
                  order.fullName,
                  style: context.text.titleSmall,
                ),
                const SizedBox(height: 3),

                // Account Number & Plan
                Text(
                  'Acc: ${order.accountNumber} • ${order.provider ?? order.plan ?? "Switch Fiber"}',
                  style: context.text.bodySmall,
                ),
                const SizedBox(height: 10),

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.map_pin_ellipse,
                      size: 20,
                      color: isDark ? Colors.white54 : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Action Bar: Quick Call & Direct Navigation
                // Both actions are Flexible so the row survives a long
                // contact number, a 24 px icon and a doubled text scale
                // together: the labels ellipsize rather than overflowing,
                // and the chevron always keeps its place on the right.
                Row(
                  children: [
                    if (order.contactNumber.isNotEmpty)
                      Flexible(
                        child: OutlinedButton.icon(
                          onPressed: () => launchUrl(
                              Uri.parse('tel:${order.contactNumber}')),
                          icon: const Icon(CupertinoIcons.phone_fill, size: 24),
                          label: Text(
                            order.contactNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelLarge,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (order.latLng != null)
                      Flexible(
                        child: TextButton.icon(
                          onPressed: () => MapNavigationService.navigateTo(
                            order.latLng!,
                            label: order.fullName,
                          ),
                          icon: const Icon(
                              CupertinoIcons.arrow_up_right_diamond_fill,
                              size: 24),
                          label: Text(
                            'Navigate',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelLarge,
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.brandInkOf(context),
                          ),
                        ),
                      ),
                    const Icon(CupertinoIcons.chevron_right,
                        size: 24, color: AppTheme.textMuted),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
