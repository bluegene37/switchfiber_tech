import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/image_capture_service.dart';
import '../../../core/services/map_navigation_service.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../catalogs/models/catalog_model.dart';
import '../../catalogs/services/catalog_service.dart';
import '../../diagnostics/widgets/radius_connection_card.dart';
import '../../reports/widgets/photo_capture_tile.dart';
import '../../reports/widgets/signature_pad.dart';
import '../models/service_order_model.dart';
import '../signals/service_orders_signals.dart';

/// Detailed view and completion form for a Service Order (repair, swap, pullout).
class ServiceOrderDetailScreen extends StatefulWidget {
  final int orderId;
  final ServiceOrdersSignals signals;

  const ServiceOrderDetailScreen({
    super.key,
    required this.orderId,
    required this.signals,
  });

  @override
  State<ServiceOrderDetailScreen> createState() =>
      _ServiceOrderDetailScreenState();
}

class _ServiceOrderDetailScreenState extends State<ServiceOrderDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _signatureController = SignaturePadController();

  late final TextEditingController _remarksController;
  late final TextEditingController _newSnController;
  late final TextEditingController _pulloutSnController;
  late final TextEditingController _pulloutRemarksController;

  String? _selectedRouterModel;
  List<RouterDto> _availableRouters = CatalogService.fallbackRouters;

  // Materials Counters
  int _dropCableMeters = 0;
  int _fastConnectors = 0;
  int _sClamps = 0;

  // Photos (Data URLs)
  String? _photo1;
  String? _photo2;
  String? _photo3;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final order = _findOrder();
    _remarksController = TextEditingController(text: order?.visitRemarks ?? '');
    _newSnController =
        TextEditingController(text: order?.newRouterModemSN ?? '');
    _pulloutSnController = TextEditingController(
        text: order?.pulloutRouterModelSN ?? order?.routerModemSN ?? '');
    _pulloutRemarksController =
        TextEditingController(text: order?.pulloutRemarks ?? '');

    // Materials prefill
    if (order != null) {
      _dropCableMeters = order.materialsUsed['Drop Cable (m)'] ?? 0;
      _fastConnectors = order.materialsUsed['SC/APC Fast Connector'] ?? 0;
      _sClamps = order.materialsUsed['S-Clamp'] ?? 0;
    }

    _loadCatalog();
  }

  ServiceOrderDto? _findOrder() {
    return widget.signals.allOrders.value
        .where((o) => o.id == widget.orderId)
        .firstOrNull;
  }

  Future<void> _loadCatalog() async {
    final routers = await CatalogService.instance.getRouters();
    if (!mounted) return;
    setState(() {
      _availableRouters = routers;
      _selectedRouterModel = _findOrder()?.routerModel ??
          (routers.isNotEmpty ? routers.first.compactName : 'Huawei 5v5');
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _remarksController.dispose();
    _newSnController.dispose();
    _pulloutSnController.dispose();
    _pulloutRemarksController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(ServiceOrderDto order) async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    String? signature;
    if (!_signatureController.isEmpty) {
      signature = await _signatureController.toDataUrl();
    }

    final materials = <String, int>{};
    if (_dropCableMeters > 0) materials['Drop Cable (m)'] = _dropCableMeters;
    if (_fastConnectors > 0) {
      materials['SC/APC Fast Connector'] = _fastConnectors;
    }
    if (_sClamps > 0) materials['S-Clamp'] = _sClamps;

    final updated = ServiceOrderDto(
      id: order.id,
      accountNumber: order.accountNumber,
      fullName: order.fullName,
      contactNumber: order.contactNumber,
      emailAddress: order.emailAddress,
      address: order.address,
      barangay: order.barangay,
      city: order.city,
      provider: order.provider,
      plan: order.plan,
      username: order.username,
      connectionType: order.connectionType,
      routerModemSN: order.routerModemSN,
      lcp: order.lcp,
      nap: order.nap,
      port: order.port,
      vlan: order.vlan,
      supportStatus: 'Resolved',
      concern: order.concern,
      priorityLevel: order.priorityLevel,
      visitStatus: 'Done',
      visitBy: widget.signals.technicianEmail.value ?? 'Technician',
      visitRemarks: _remarksController.text.trim(),
      assignedEmail: order.assignedEmail,
      newRouterModemSN: _newSnController.text.trim().isNotEmpty
          ? _newSnController.text.trim()
          : null,
      routerModel: _selectedRouterModel,
      pulloutRouterModelSN: _pulloutSnController.text.trim().isNotEmpty
          ? _pulloutSnController.text.trim()
          : null,
      pulloutRemarks: _pulloutRemarksController.text.trim(),
      materialsUsed: materials,
      clientSignature: signature ?? order.clientSignature,
      image1: _photo1 ?? order.image1,
      image2: _photo2 ?? order.image2,
      image3: _photo3 ?? order.image3,
      addressCoordinates: order.addressCoordinates,
    );

    final success = await widget.signals.submitCompletion(updated);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service Order marked as Completed!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.signals.syncError.value ??
              'Failed to submit service order'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SignalBuilder(
      builder: (context) {
        final order = _findOrder();
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Service Order')),
            body: const Center(child: Text('Service order not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SO-${order.id.toString().padLeft(4, '0')}',
                  style: context.text.titleMedium!.copyWith(
                    fontFamily: 'JetBrains Mono',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  order.concern,
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              // Clear the phone's navigation bar so the last control is not
              // half covered.
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
              children: [
                // 1. Concern & Subscriber Card
                _buildSubscriberCard(order, isDark),
                const SizedBox(height: 16),

                // 2. Plant & Hardware Allocation (2x2 Instrument Grid)
                _buildPlantAndHardwareCard(order, isDark),
                const SizedBox(height: 16),

                // 3. Hardware Swaps & Pullout Card
                _buildHardwareSwapCard(order, isDark),
                const SizedBox(height: 16),

                // 3b. Live RADIUS PPPoE Connection & Reconnect Test
                RadiusConnectionCard(
                  accountName: (order.username != null &&
                          order.username!.isNotEmpty &&
                          order.username!.toLowerCase() != 'switch')
                      ? order.username!
                      : order.accountNumber,
                  subscriberName: order.fullName,
                ),
                const SizedBox(height: 16),

                // 4. Materials Used (BOM)
                _buildMaterialsCounterCard(isDark),
                const SizedBox(height: 16),

                // 5. Photos Proofs (with GPS EXIF)
                _buildPhotosCard(isDark),
                const SizedBox(height: 16),

                // 6. Subscriber Signature Pad
                _buildSignatureCard(isDark),
                const SizedBox(height: 24),

                // 7. Complete Action Button (56dp height)
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _handleSubmit(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.checkmark_seal_fill,
                                size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Complete Service Order',
                              style: context.text.titleSmall!
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubscriberCard(ServiceOrderDto order, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        size: 16,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        order.concern,
                        style: context.text.labelMedium!
                            .copyWith(color: AppTheme.brandInkOf(context)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (order.isUrgent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            ),
            const SizedBox(height: 12),
            Text(
              order.fullName,
              style: context.text.titleMedium,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  'Account: ',
                  style: context.text.bodySmall,
                ),
                Text(
                  order.accountNumber,
                  style: context.text.bodySmall!.copyWith(
                    fontFamily: 'JetBrains Mono',
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandInkOf(context),
                  ),
                ),
                Text(
                  ' • ${order.provider ?? order.plan ?? "Switch Fiber"}',
                  style: context.text.bodySmall,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(CupertinoIcons.location_solid,
                    size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.address,
                    style: context.text.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (order.contactNumber.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          launchUrl(Uri.parse('tel:${order.contactNumber}')),
                      icon: const Icon(CupertinoIcons.phone_fill, size: 20),
                      label: const Text('Call Client'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                if (order.contactNumber.isNotEmpty && order.latLng != null)
                  const SizedBox(width: 10),
                if (order.latLng != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => MapNavigationService.navigateTo(
                          order.latLng!,
                          label: order.fullName),
                      icon: const Icon(CupertinoIcons.location_north_fill,
                          size: 20),
                      label: const Text('Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantAndHardwareCard(ServiceOrderDto order, bool isDark) {
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final muted = AppTheme.secondaryInkOf(context);
    final lcpText = order.lcp?.isNotEmpty == true ? order.lcp! : 'Unassigned';
    final napText = order.nap?.isNotEmpty == true ? order.nap! : 'Unassigned';
    final portText =
        order.port?.isNotEmpty == true ? order.port! : 'Unassigned';
    final ontText = order.routerModel?.isNotEmpty == true
        ? order.routerModel!
        : (order.routerModemSN?.isNotEmpty == true
            ? order.routerModemSN!
            : 'Pending Inspection');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hub_outlined,
                    size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Plant & Hardware Allocation',
                    style: context.text.titleMedium,
                  ),
                ),
                if (order.vlan != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkInput : AppTheme.fillLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor, width: 0.5),
                    ),
                    child: Text(
                      'VLAN ${order.vlan}',
                      style: context.text.labelMedium!.copyWith(
                        fontFamily: 'JetBrains Mono',
                        color: AppTheme.infoInkOf(context),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Modern 2x2 Instrument Grid Partitioned by Hairlines
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 0.5),
                color:
                    isDark ? const Color(0xFF14171F) : const Color(0xFFF8FAFC),
              ),
              child: Column(
                children: [
                  // Row 1: LCP & NAP
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.storage_rounded,
                                        size: 14, color: muted),
                                    const SizedBox(width: 4),
                                    Text(
                                      'LCP CABINET',
                                      style: context.text.labelSmall!.copyWith(
                                        color: muted,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lcpText,
                                  style: context.text.titleSmall!.copyWith(
                                    fontFamily: 'JetBrains Mono',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        VerticalDivider(
                            width: 0.5, thickness: 0.5, color: borderColor),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.alt_route_rounded,
                                        size: 14, color: muted),
                                    const SizedBox(width: 4),
                                    Text(
                                      'NAP BOX',
                                      style: context.text.labelSmall!.copyWith(
                                        color: muted,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  napText,
                                  style: context.text.titleSmall!.copyWith(
                                    fontFamily: 'JetBrains Mono',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 0.5, thickness: 0.5, color: borderColor),
                  // Row 2: Port & ONT
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.settings_ethernet_rounded,
                                        size: 14, color: muted),
                                    const SizedBox(width: 4),
                                    Text(
                                      'NAP PORT',
                                      style: context.text.labelSmall!.copyWith(
                                        color: muted,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  portText,
                                  style: context.text.titleSmall!.copyWith(
                                    fontFamily: 'JetBrains Mono',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        VerticalDivider(
                            width: 0.5, thickness: 0.5, color: borderColor),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.router_rounded,
                                        size: 14, color: muted),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ONT / MODEM',
                                      style: context.text.labelSmall!.copyWith(
                                        color: muted,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ontText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.titleSmall!.copyWith(
                                    fontFamily: 'JetBrains Mono',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHardwareSwapCard(ServiceOrderDto order, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.swap_horiz_rounded,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text('Hardware Swap / Pullout',
                    style: context.text.titleMedium),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _pulloutSnController,
              style: const TextStyle(fontFamily: 'JetBrains Mono'),
              decoration: const InputDecoration(
                labelText: 'Pullout Modem Serial Number (Old)',
                prefixIcon: Icon(Icons.qr_code_rounded, size: 20),
                hintText: 'e.g. HWTC991823 or ZTE88301',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newSnController,
              style: const TextStyle(fontFamily: 'JetBrains Mono'),
              decoration: const InputDecoration(
                labelText: 'Replacement Modem Serial Number (New)',
                prefixIcon: Icon(Icons.qr_code_scanner_rounded, size: 20),
                hintText: 'e.g. HWTC2026889',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRouterModel,
              decoration: const InputDecoration(
                labelText: 'Approved Replacement Model',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: _availableRouters.map((r) {
                return DropdownMenuItem(
                    value: r.compactName,
                    child: Text(r.displayName, style: context.text.bodySmall));
              }).toList(),
              onChanged: (val) => setState(() => _selectedRouterModel = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarksController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Technician Remarks / Work Performed',
                hintText:
                    'e.g. Replaced faulty ONU, re-spliced fast connector on Port 4',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsCounterCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text('Materials Consumed On-Site',
                    style: context.text.titleMedium),
              ],
            ),
            const SizedBox(height: 14),
            _buildCounterRow('Drop Cable', 'meters', _dropCableMeters,
                (v) => setState(() => _dropCableMeters = v)),
            const Divider(height: 16),
            _buildCounterRow('SC/APC Fast Connectors', 'pcs', _fastConnectors,
                (v) => setState(() => _fastConnectors = v)),
            const Divider(height: 16),
            _buildCounterRow('S-Clamps', 'pcs', _sClamps,
                (v) => setState(() => _sClamps = v)),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterRow(
      String name, String unit, int count, ValueChanged<int> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: context.text.titleSmall),
              Text(unit, style: context.text.labelSmall),
            ],
          ),
        ),
        IconButton(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: count > 0 ? () => onChanged(count - 1) : null,
          icon: const Icon(CupertinoIcons.minus_circle, size: 24),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 32),
          alignment: Alignment.center,
          child: Text('$count',
              style: context.text.titleSmall!.copyWith(
                fontFamily: 'JetBrains Mono',
                fontWeight: FontWeight.w700,
              )),
        ),
        IconButton(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => onChanged(count + 1),
          icon: const Icon(CupertinoIcons.plus_circle_fill,
              size: 24, color: AppTheme.primary),
        ),
      ],
    );
  }

  Widget _buildPhotosCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.camera_alt_outlined,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Proof of Service (GPS Geotagged)',
                    style: context.text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Capture photos of the repaired hardware, drop line, and residence.',
              style: context.text.labelSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PhotoCaptureTile(
                    label: 'Modem Setup',
                    hint: 'Modem lights',
                    icon: Icons.router_rounded,
                    value: _photo1,
                    pick: (source) =>
                        ImageCaptureService.instance.pickAsDataUrl(source),
                    onChanged: (v) => setState(() => _photo1 = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PhotoCaptureTile(
                    label: 'Drop / NAP',
                    hint: 'Drop cable',
                    icon: Icons.alt_route_rounded,
                    value: _photo2,
                    pick: (source) =>
                        ImageCaptureService.instance.pickAsDataUrl(source),
                    onChanged: (v) => setState(() => _photo2 = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PhotoCaptureTile(
                    label: 'House Front',
                    hint: 'House facade',
                    icon: Icons.home_rounded,
                    value: _photo3,
                    pick: (source) =>
                        ImageCaptureService.instance.pickAsDataUrl(source),
                    onChanged: (v) => setState(() => _photo3 = v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.draw_rounded,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text('Subscriber Sign-off', style: context.text.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            SignaturePad(controller: _signatureController),
          ],
        ),
      ),
    );
  }
}
