/// Drop Cable & On-Site Installation Material Estimator Model.
class DropCableEstimatorModel {
  final int poleSpans; // Number of utility pole spans
  final double averageSpanMeters; // Average distance between poles (typically 30-40m)
  final double sagPercentage; // Drop wire sag factor (typically 5-10%)
  final double facadeDripLoopMeters; // Outdoor entry / drip loop slack (typically 3m)
  final double indoorRunMeters; // Cable run inside house/building to ONT
  final double serviceLoopMeters; // Extra service slack at NAP and ONT (typically 4m)

  const DropCableEstimatorModel({
    this.poleSpans = 2,
    this.averageSpanMeters = 35.0,
    this.sagPercentage = 8.0,
    this.facadeDripLoopMeters = 3.0,
    this.indoorRunMeters = 10.0,
    this.serviceLoopMeters = 4.0,
  });

  /// Aerial span subtotal including sag allowance.
  double get aerialSpanLength {
    final rawDistance = poleSpans * averageSpanMeters;
    return rawDistance * (1 + (sagPercentage / 100.0));
  }

  /// Indoor and slack allowance subtotal.
  double get slackAndIndoorLength =>
      facadeDripLoopMeters + indoorRunMeters + serviceLoopMeters;

  /// Total recommended drop wire length in meters.
  double get totalMeters => aerialSpanLength + slackAndIndoorLength;

  /// Bill of Materials (BOM) items required for this drop installation.
  List<BOMItem> get recommendedBOM {
    final metersRounded = totalMeters.ceil();
    final clampsRequired = (poleSpans + 1); // 1 clamp per pole attachment + house hook

    return [
      BOMItem(
        name: '1-Core G.657A2 Flat Drop Cable',
        quantity: '$metersRounded meters',
        category: 'Cable',
      ),
      const BOMItem(
        name: 'SC/APC Pre-embedded Fast Connectors',
        quantity: '2 pcs (NAP + ONT)',
        category: 'Optics',
      ),
      BOMItem(
        name: 'S-Type / Fish Drop Wire Tension Clamps',
        quantity: '$clampsRequired pcs',
        category: 'Hardware',
      ),
      const BOMItem(
        name: 'Fiber Optical Wall Outlet (Rosette Box)',
        quantity: '1 pc',
        category: 'Subscriber',
      ),
      const BOMItem(
        name: 'SC/APC to SC/APC Simplex Patch Cord 1m',
        quantity: '1 pc',
        category: 'Subscriber',
      ),
      const BOMItem(
        name: 'Wall Anchors & Drive Rings / Cable Clips',
        quantity: '10 pcs',
        category: 'Hardware',
      ),
    ];
  }
}

class BOMItem {
  final String name;
  final String quantity;
  final String category;

  const BOMItem({
    required this.name,
    required this.quantity,
    required this.category,
  });
}
