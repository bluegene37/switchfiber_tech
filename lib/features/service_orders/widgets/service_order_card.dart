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
              ? AppTheme.danger
              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          width: isUrgent ? 1.5 : 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Tappable Card Body
          Material(
            color: Colors.transparent,
            child: InkWell(
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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Monospace Ticket HUD, Concern Pill & Urgent / Distance
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                'SO-${order.id.toString().padLeft(4, '0')}',
                                style: context.text.labelMedium!.copyWith(
                                  fontFamily: 'JetBrains Mono',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: AppTheme.brandInkOf(context),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.primarySubtleBgDark
                                      : AppTheme.primarySubtleBg,
                                  borderRadius: BorderRadius.circular(6),
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
                                      size: 14,
                                      color: AppTheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        order.concern,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.text.labelSmall!.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.brandInkOf(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isUrgent && distanceStr != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.location_solid,
                                      size: 14,
                                      color: AppTheme.secondaryInkOf(context),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      distanceStr,
                                      style: context.text.labelSmall!.copyWith(
                                        color: AppTheme.secondaryInkOf(context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        if (isUrgent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.danger,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'URGENT',
                              style: context.text.labelSmall!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Subscriber Name
                    Text(
                      order.fullName,
                      style: context.text.titleSmall,
                    ),
                    const SizedBox(height: 3),

                    // Account Number & Plan
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: order.accountNumber,
                            style: context.text.bodySmall!.copyWith(
                              fontFamily: 'JetBrains Mono',
                              fontWeight: FontWeight.w600,
                              color: AppTheme.brandInkOf(context),
                            ),
                          ),
                          TextSpan(
                            text:
                                ' • ${order.provider ?? order.plan ?? "Switch Fiber"}',
                            style: context.text.bodySmall!.copyWith(
                              color: AppTheme.secondaryInkOf(context),
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          CupertinoIcons.location_solid,
                          size: 16,
                          color: AppTheme.primary,
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

                    // Plant Specs Info Badge (LCP / NAP / Port)
                    if (order.lcp?.isNotEmpty == true ||
                        order.nap?.isNotEmpty == true ||
                        order.port?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            width: 0.5,
                          ),
                        ),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (order.lcp?.isNotEmpty == true)
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'LCP: ',
                                      style: context.text.labelSmall!.copyWith(
                                        color: AppTheme.secondaryInkOf(context),
                                      ),
                                    ),
                                    TextSpan(
                                      text: order.lcp!,
                                      style: context.text.labelSmall!.copyWith(
                                        fontFamily: 'JetBrains Mono',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (order.nap?.isNotEmpty == true)
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'NAP: ',
                                      style: context.text.labelSmall!.copyWith(
                                        color: AppTheme.secondaryInkOf(context),
                                      ),
                                    ),
                                    TextSpan(
                                      text: order.nap!,
                                      style: context.text.labelSmall!.copyWith(
                                        fontFamily: 'JetBrains Mono',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (order.port?.isNotEmpty == true)
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'PORT: ',
                                      style: context.text.labelSmall!.copyWith(
                                        color: AppTheme.secondaryInkOf(context),
                                      ),
                                    ),
                                    TextSpan(
                                      text: order.port!,
                                      style: context.text.labelSmall!.copyWith(
                                        fontFamily: 'JetBrains Mono',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // 2. Partitioned 48dp Action Footer (Directions | Call)
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // Directions Action Button
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final latLng = order.latLng;
                      if (latLng != null) {
                        await MapNavigationService.navigateTo(
                          latLng,
                          label: order.fullName,
                        );
                      } else {
                        final fullAddr =
                            '${order.address}${order.barangay != null ? ", ${order.barangay}" : ""}${order.city != null ? ", ${order.city}" : ""}, Philippines';
                        final uri = Uri.parse(
                            'https://maps.apple.com/?q=${Uri.encodeComponent(fullAddr)}');
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.location_north_fill,
                                  size: 18,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Directions',
                                  style: context.text.labelLarge!.copyWith(
                                    color: AppTheme.brandInkOf(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Vertical Hairline Divider
                Container(
                  width: 0.5,
                  height: 48,
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),

                // Call Action Button
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      if (order.contactNumber.isNotEmpty) {
                        final uri = Uri.parse('tel:${order.contactNumber}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      }
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.phone_fill,
                                  size: 18,
                                  color: order.contactNumber.isNotEmpty
                                      ? const Color(0xFF10B981)
                                      : (isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textMuted),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Call',
                                  style: context.text.labelLarge!.copyWith(
                                    color: order.contactNumber.isNotEmpty
                                        ? AppTheme.successInkOf(context)
                                        : (isDark
                                            ? AppTheme.textSecondaryDark
                                            : AppTheme.textMuted),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
