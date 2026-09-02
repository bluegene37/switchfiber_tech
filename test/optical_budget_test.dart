import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/toolkit/models/optical_budget_model.dart';

void main() {
  group('Optical Link Budget Calculations', () {
    test('Calculates standard 2-stage GPON link attenuation', () {
      // 4.0 dBm Tx, 2.5km (0.35 dB/km = 0.875 dB), 1:4 LCP (7.2 dB), 1:8 NAP (10.5 dB), 4 splices (0.2 dB), 2 connectors (0.6 dB)
      // Total loss = 0.875 + 7.2 + 10.5 + 0.2 + 0.6 = 19.375 dB
      // Expected Rx = 4.0 - 19.375 = -15.375 dBm
      const model = OpticalBudgetModel(
        oltTxPower: 4.0,
        fiberDistanceKm: 2.5,
        fiberAttenuationPerKm: 0.35,
        lcpSplitter: SplitterRatio.ratio1x4,
        napSplitter: SplitterRatio.ratio1x8,
        fusionSpliceCount: 4,
        connectorCount: 2,
      );

      expect(model.totalCalculatedLoss, closeTo(19.375, 0.01));
      expect(model.expectedRxPower, closeTo(-15.375, 0.01));
      expect(model.status, OpticalPowerStatus.optimal);
    });

    test('Validates marginal and faulty measured optical powers', () {
      const marginalModel = OpticalBudgetModel(
        measuredRxPower: -25.5,
      );
      expect(marginalModel.status, OpticalPowerStatus.marginal);

      const faultyModel = OpticalBudgetModel(
        measuredRxPower: -29.0,
      );
      expect(faultyModel.status, OpticalPowerStatus.faulty);
    });
  });
}
