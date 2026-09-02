import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/toolkit/models/fiber_color_code.dart';

void main() {
  group('Fiber Color Code Calculations (TIA-598-C Standard)', () {
    test('Calculates Core #1: Tube 1 Blue, Fiber 1 Blue', () {
      final res = FiberColorCalculator.calculate(1, fibersPerTube: 12);
      expect(res.coreNumber, 1);
      expect(res.tubeNumber, 1);
      expect(res.tubeColor.name, 'Blue');
      expect(res.hasTubeStripe, false);
      expect(res.fiberIndexInTube, 1);
      expect(res.fiberColor.name, 'Blue');
    });

    test('Calculates Core #2: Tube 1 Blue, Fiber 2 Orange', () {
      final res = FiberColorCalculator.calculate(2, fibersPerTube: 12);
      expect(res.tubeNumber, 1);
      expect(res.tubeColor.name, 'Blue');
      expect(res.fiberIndexInTube, 2);
      expect(res.fiberColor.name, 'Orange');
    });

    test('Calculates Core #12: Tube 1 Blue, Fiber 12 Aqua', () {
      final res = FiberColorCalculator.calculate(12, fibersPerTube: 12);
      expect(res.tubeNumber, 1);
      expect(res.tubeColor.name, 'Blue');
      expect(res.fiberIndexInTube, 12);
      expect(res.fiberColor.name, 'Aqua');
    });

    test('Calculates Core #13 (Crosses to Tube 2): Tube 2 Orange, Fiber 1 Blue',
        () {
      final res = FiberColorCalculator.calculate(13, fibersPerTube: 12);
      expect(res.tubeNumber, 2);
      expect(res.tubeColor.name, 'Orange');
      expect(res.fiberIndexInTube, 1);
      expect(res.fiberColor.name, 'Blue');
    });

    test('Calculates Core #48 (48F Cable): Tube 4 Brown, Fiber 12 Aqua', () {
      final res = FiberColorCalculator.calculate(48, fibersPerTube: 12);
      expect(res.tubeNumber, 4);
      expect(res.tubeColor.name, 'Brown');
      expect(res.fiberIndexInTube, 12);
      expect(res.fiberColor.name, 'Aqua');
    });

    test('Calculates Core #144 (144F Cable): Tube 12 Aqua, Fiber 12 Aqua', () {
      final res = FiberColorCalculator.calculate(144, fibersPerTube: 12);
      expect(res.tubeNumber, 12);
      expect(res.tubeColor.name, 'Aqua');
      expect(res.fiberIndexInTube, 12);
      expect(res.fiberColor.name, 'Aqua');
    });

    test(
        'Calculates 6-fiber per tube cable (e.g. Core 7 is Tube 2 Orange, Fiber 1 Blue)',
        () {
      final res = FiberColorCalculator.calculate(7, fibersPerTube: 6);
      expect(res.tubeNumber, 2);
      expect(res.tubeColor.name, 'Orange');
      expect(res.fiberIndexInTube, 1);
      expect(res.fiberColor.name, 'Blue');
    });
  });
}
