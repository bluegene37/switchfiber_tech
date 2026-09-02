import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// Supported PLC optical splitter configurations in FTTH GPON/XGS-PON networks.
enum SplitterRatio {
  ratio1x2('1:2 Splitter', 3.5),
  ratio1x4('1:4 Splitter', 7.2),
  ratio1x8('1:8 Splitter', 10.5),
  ratio1x16('1:16 Splitter', 13.8),
  ratio1x32('1:32 Splitter', 17.1),
  ratio1x64('1:64 Splitter', 20.5);

  final String label;
  final double insertionLossDb;

  const SplitterRatio(this.label, this.insertionLossDb);
}

/// GPON / XGS-PON Optical Link Budget Calculator & Validator.
class OpticalBudgetModel {
  final double oltTxPower; // dBm (e.g. +3.0 to +5.0 dBm)
  final double fiberDistanceKm; // Distance from OLT to subscriber in km
  final double
      fiberAttenuationPerKm; // dB/km (default 0.35 for 1310nm, 0.25 for 1490nm)
  final SplitterRatio lcpSplitter; // First stage splitter at LCP
  final SplitterRatio?
      napSplitter; // Second stage splitter at NAP (nullable if 1-stage)
  final int fusionSpliceCount; // Number of fusion splices (0.05 dB each)
  final int connectorCount; // Number of SC/APC connector pairs (0.3 dB each)
  final double?
      measuredRxPower; // Actual OPM reading taken at subscriber ONT (dBm)

  const OpticalBudgetModel({
    this.oltTxPower = 4.0,
    this.fiberDistanceKm = 2.5,
    this.fiberAttenuationPerKm = 0.35,
    this.lcpSplitter = SplitterRatio.ratio1x4,
    this.napSplitter = SplitterRatio.ratio1x8,
    this.fusionSpliceCount = 4,
    this.connectorCount = 2,
    this.measuredRxPower,
  });

  /// Total calculated optical attenuation loss across the passive link (in dB).
  double get totalCalculatedLoss {
    final fiberLoss = fiberDistanceKm * fiberAttenuationPerKm;
    final lcpLoss = lcpSplitter.insertionLossDb;
    final napLoss = napSplitter?.insertionLossDb ?? 0.0;
    final spliceLoss = fusionSpliceCount * 0.05;
    final connectorLoss = connectorCount * 0.30;

    return fiberLoss + lcpLoss + napLoss + spliceLoss + connectorLoss;
  }

  /// Expected theoretical Optical Power received at the subscriber ONT (in dBm).
  double get expectedRxPower => oltTxPower - totalCalculatedLoss;

  /// Power variance between theoretical calculation and field meter reading (in dB).
  double? get variance =>
      measuredRxPower != null ? measuredRxPower! - expectedRxPower : null;

  /// Health status of the measured optical power reading.
  OpticalPowerStatus get status {
    final power = measuredRxPower ?? expectedRxPower;
    if (power >= AppConstants.opticalMinOptimal &&
        power <= AppConstants.opticalMaxOptimal) {
      return OpticalPowerStatus.optimal;
    }
    if (power >= AppConstants.opticalMarginalFloor &&
        power < AppConstants.opticalMinOptimal) {
      return OpticalPowerStatus.marginal;
    }
    return OpticalPowerStatus.faulty;
  }
}

enum OpticalPowerStatus {
  optimal('Optimal (Pass)', AppTheme.success, AppTheme.successSubtle),
  marginal('Marginal (Acceptable)', AppTheme.warning, AppTheme.warningSubtle),
  faulty('Out of Spec (Faulty)', AppTheme.danger, AppTheme.dangerSubtle);

  final String label;
  final Color color;
  final Color subtleColor;

  const OpticalPowerStatus(this.label, this.color, this.subtleColor);
}
