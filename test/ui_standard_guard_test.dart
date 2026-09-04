import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the two rules of the field UI standard that nothing else enforces.
///
/// Both of these silently regressed once already: four commits reintroduced
/// seven `fontSize` literals and sixteen sub-floor icons while the whole suite
/// stayed green, because the rules lived only in review prose. They live here
/// now, so breaking one fails the build instead of the next technician's eyes.
///
/// The app is used one-handed, outdoors, in daylight, at a utility pole. That
/// is the reason for both rules and the reason neither has a soft version.
void main() {
  final libFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('lib has Dart files to scan', () {
    // Guards the guards: a bad glob would make both tests below pass on an
    // empty list, which is exactly the vacuous-pass failure this file exists
    // to prevent elsewhere.
    expect(libFiles.length, greaterThan(20));
  });

  test('font sizes come from the theme, never from a widget literal', () {
    // The one sanctioned exception is map furniture: a label inside a Marker
    // child, which must stay at a fixed size or it outgrows its pin. Each is
    // commented `// map furniture` on the same line.
    final offenders = <String>[];

    for (final file in libFiles) {
      if (file.path.endsWith('core/theme/app_theme.dart')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (!line.contains('fontSize:')) continue;
        if (line.contains('map furniture')) continue;
        offenders.add('${file.path}:${i + 1}: ${line.trim()}');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Type comes from context.text.<role>, and sizes live only in '
          'lib/core/theme/app_theme.dart. Found a literal in a widget:\n'
          '${offenders.join('\n')}',
    );
  });

  test('no icon renders below the 20px floor', () {
    // Icons are 24 inside something tappable and 20 when decorative. Anything
    // at 16 or below was unreadable at arm's length in sunlight. The only
    // exemptions are the three glyphs centred inside fixed-diameter map pin
    // circles, which overflow their pin if grown; each is commented too.
    final sizePattern = RegExp(r'\bsize:\s*(\d+(?:\.\d+)?)');
    final iconPattern =
        RegExp(r'\bIcon\(|\bIcons\.|\bCupertinoIcons\.|\biconSize\b');
    final offenders = <String>[];

    for (final file in libFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final match = sizePattern.firstMatch(lines[i]);
        if (match == null) continue;
        if (double.parse(match.group(1)!) > 16) continue;
        if (lines[i].contains('map furniture')) continue;
        // `size:` alone is ambiguous, so only count it when an icon
        // constructor sits within the few lines above it.
        final context = lines.sublist(i - 4 < 0 ? 0 : i - 4, i + 1).join('\n');
        if (!iconPattern.hasMatch(context)) continue;
        offenders.add('${file.path}:${i + 1}: ${lines[i].trim()}');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Icons are 24 when tappable and 20 when decorative; nothing '
          'renders at 16 or below except commented map furniture. Found:\n'
          '${offenders.join('\n')}',
    );
  });
}
