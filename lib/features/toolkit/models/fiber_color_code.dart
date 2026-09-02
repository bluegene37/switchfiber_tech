import 'package:flutter/material.dart';

/// Standard 12-color fiber optical color scheme according to TIA-598-C.
class FiberColor {
  final int position; // 1-12
  final String name;
  final Color color;
  final Color textColor;

  const FiberColor({
    required this.position,
    required this.name,
    required this.color,
    this.textColor = Colors.white,
  });

  static const List<FiberColor> standard12 = [
    FiberColor(
      position: 1,
      name: 'Blue',
      color: Color(0xFF0070BA),
      textColor: Colors.white,
    ),
    FiberColor(
      position: 2,
      name: 'Orange',
      color: Color(0xFFFF7900),
      textColor: Colors.white,
    ),
    FiberColor(
      position: 3,
      name: 'Green',
      color: Color(0xFF00A344),
      textColor: Colors.white,
    ),
    FiberColor(
      position: 4,
      name: 'Brown',
      color: Color(0xFF8C593B),
      textColor: Colors.white,
    ),
    FiberColor(
      position: 5,
      name: 'Slate',
      color: Color(0xFF708090),
      textColor: Colors.white,
    ),
    FiberColor(
      position: 6,
      name: 'White',
      color: Color(0xFFF8F9FA),
      textColor: Color(0xFF212529),
    ),
    FiberColor(
      position: 7,
      name: 'Red',
      color: Color(0xFFE52421),
      textColor: Colors.white,
    ),
    FiberColor(
      position: 8,
      name: 'Black',
      color: Color(0xFF212529),
      textColor: Colors.white,
    ),
    FiberColor(
      position: 9,
      name: 'Yellow',
      color: Color(0xFFFFD700),
      textColor: Color(0xFF212529),
    ),
    FiberColor(
      position: 10,
      name: 'Violet',
      color: Color(0xFF8A2BE2),
      textColor: Colors.white,
    ),
    FiberColor(
      position: 11,
      name: 'Rose',
      color: Color(0xFFFF69B4),
      textColor: Colors.white,
    ),
    FiberColor(
      position: 12,
      name: 'Aqua',
      color: Color(0xFF00BFFF),
      textColor: Color(0xFF212529),
    ),
  ];

  static FiberColor getByPosition(int pos) {
    if (pos < 1 || pos > 12) {
      final normalized = ((pos - 1) % 12) + 1;
      return standard12[normalized - 1];
    }
    return standard12[pos - 1];
  }
}

/// Calculation result for a specific fiber core within a multi-tube fiber cable.
class FiberCoreResult {
  final int coreNumber;
  final int tubeNumber;
  final FiberColor tubeColor;
  final bool hasTubeStripe;
  final int fiberIndexInTube;
  final FiberColor fiberColor;
  final int fibersPerTube;

  const FiberCoreResult({
    required this.coreNumber,
    required this.tubeNumber,
    required this.tubeColor,
    this.hasTubeStripe = false,
    required this.fiberIndexInTube,
    required this.fiberColor,
    required this.fibersPerTube,
  });

  String get summary =>
      'Tube $tubeNumber (${tubeColor.name}${hasTubeStripe ? " w/ Stripe" : ""}) • Core $fiberIndexInTube (${fiberColor.name})';
}

/// Helper for calculating fiber cable core mappings.
class FiberColorCalculator {
  /// Calculate tube color and fiber core color for any given core number.
  static FiberCoreResult calculate(int coreNumber, {int fibersPerTube = 12}) {
    if (coreNumber < 1) coreNumber = 1;
    if (fibersPerTube < 1) fibersPerTube = 12;

    final tubeIndex = (coreNumber - 1) ~/ fibersPerTube; // 0-indexed
    final tubeNumber = tubeIndex + 1;
    final tubeColor = FiberColor.getByPosition((tubeIndex % 12) + 1);
    final hasTubeStripe = tubeIndex >= 12;

    final fiberIndex = (coreNumber - 1) % fibersPerTube; // 0-indexed
    final fiberPosition = (fiberIndex % 12) + 1;
    final fiberColor = FiberColor.getByPosition(fiberPosition);

    return FiberCoreResult(
      coreNumber: coreNumber,
      tubeNumber: tubeNumber,
      tubeColor: tubeColor,
      hasTubeStripe: hasTubeStripe,
      fiberIndexInTube: fiberIndex + 1,
      fiberColor: fiberColor,
      fibersPerTube: fibersPerTube,
    );
  }
}
