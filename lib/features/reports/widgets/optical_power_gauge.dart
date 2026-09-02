import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/completion_report.dart';

/// Optical Power Meter Gauge widget displaying live signal quality feedback.
class OpticalPowerGauge extends StatelessWidget {
  final double? opticalPowerDbm;

  const OpticalPowerGauge({
    super.key,
    required this.opticalPowerDbm,
  });

  @override
  Widget build(BuildContext context) {
    final dbm = opticalPowerDbm ?? -19.0;
    final quality = _evaluateQuality(dbm);

    Color statusColor;
    String statusTitle;
    String statusDescription;
    IconData statusIcon;

    switch (quality) {
      case OpticalReadingQuality.optimal:
        statusColor = AppTheme.success;
        statusTitle = 'Optimal Signal (PASS)';
        statusDescription =
            'Excellent optical link budget within GPON standard (-12 to -24 dBm).';
        statusIcon = Icons.check_circle_rounded;
        break;
      case OpticalReadingQuality.marginal:
        statusColor = AppTheme.warning;
        statusTitle = 'Marginal Signal (WARNING)';
        statusDescription =
            'Acceptable but near sensitivity threshold (-24.1 to -27 dBm). Verify fiber bend radius.';
        statusIcon = Icons.warning_amber_rounded;
        break;
      case OpticalReadingQuality.outOfSpec:
        statusColor = AppTheme.danger;
        statusTitle = 'Out of Spec (FAIL)';
        statusDescription =
            'High attenuation (<-27 dBm) or saturation (>-8 dBm). Clean SC/APC connector and check splice.';
        statusIcon = Icons.error_outline_rounded;
        break;
    }

    // Gauge normalized progress from -35 dBm (0.0) to -5 dBm (1.0)
    final clamped = dbm.clamp(-35.0, -5.0);
    final progress = (clamped - (-35.0)) / ((-5.0) - (-35.0));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    statusTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${dbm.toStringAsFixed(1)} dBm',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Linear Scale Meter
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 6),

          // Gauge Labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('-35 dBm (Low)',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              Text('-24 dBm (Threshold)',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              Text('-12 dBm (Strong)',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            statusDescription,
            style: TextStyle(
              fontSize: 12,
              color: statusColor.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  OpticalReadingQuality _evaluateQuality(double dbm) {
    if (dbm >= -24.0 && dbm <= -12.0) return OpticalReadingQuality.optimal;
    if (dbm >= -27.0 && dbm < -24.0) return OpticalReadingQuality.marginal;
    return OpticalReadingQuality.outOfSpec;
  }
}
