import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/toolkit/models/drop_cable_estimator_model.dart';

void main() {
  group('Drop Cable & Material Estimation', () {
    test('Calculates drop wire requirement accurately', () {
      // 2 spans @ 35m = 70m raw aerial * 1.08 (8% sag) = 75.6m
      // Facade (3m) + Indoor (10m) + Service (4m) = 17m
      // Total = 75.6 + 17 = 92.6m
      const model = DropCableEstimatorModel(
        poleSpans: 2,
        averageSpanMeters: 35.0,
        sagPercentage: 8.0,
        facadeDripLoopMeters: 3.0,
        indoorRunMeters: 10.0,
        serviceLoopMeters: 4.0,
      );

      expect(model.aerialSpanLength, closeTo(75.6, 0.01));
      expect(model.slackAndIndoorLength, closeTo(17.0, 0.01));
      expect(model.totalMeters, closeTo(92.6, 0.01));

      final bom = model.recommendedBOM;
      expect(bom.any((b) => b.name.contains('Drop Cable')), isTrue);
      expect(bom.any((b) => b.name.contains('Fast Connectors')), isTrue);
      expect(bom.any((b) => b.name.contains('Clamps')), isTrue);
    });
  });
}
