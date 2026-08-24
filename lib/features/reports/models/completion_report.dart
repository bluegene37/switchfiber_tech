/// Model for On-Site Completion and Optical Power Report.
class CompletionReportData {
  final int jobOrderId;
  final double opticalPowerDbm;
  final String modemRouterSN;
  final String routerModel;
  final String napPort;
  final String onsiteRemarks;
  final String? boxReadingImage;
  final String? routerReadingImage;
  final String? setupImage;
  final String? clientSignature;
  final Map<String, String> materialsUsed;

  CompletionReportData({
    required this.jobOrderId,
    required this.opticalPowerDbm,
    required this.modemRouterSN,
    required this.routerModel,
    required this.napPort,
    required this.onsiteRemarks,
    this.boxReadingImage,
    this.routerReadingImage,
    this.setupImage,
    this.clientSignature,
    this.materialsUsed = const {},
  });

  /// Evaluates optical power reading against GPON standard thresholds
  OpticalReadingQuality get opticalQuality {
    if (opticalPowerDbm >= -24.0 && opticalPowerDbm <= -12.0) {
      return OpticalReadingQuality.optimal;
    }
    if (opticalPowerDbm >= -27.0 && opticalPowerDbm < -24.0) {
      return OpticalReadingQuality.marginal;
    }
    return OpticalReadingQuality.outOfSpec;
  }
}

enum OpticalReadingQuality {
  optimal,   // -12 to -24 dBm (Green)
  marginal,  // -24.1 to -27 dBm (Amber)
  outOfSpec, // < -27 dBm or > -8 dBm (Red)
}
