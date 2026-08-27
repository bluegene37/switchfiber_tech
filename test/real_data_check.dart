library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';

void main() {
  test('parses every live job order record', () {
    final raw = File('/private/tmp/claude-501/-Users-bluegene37-StudioProjects-swithfiber-tech/0271518f-b1f6-4ae4-9627-cf89cb960d6b/scratchpad/joborders.json').readAsStringSync();
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    final counts = <FieldStatus, int>{};
    final nullKeys = <String, int>{};
    for (final item in list) {
      final dto = JobOrderDto.fromJson(item);
      counts.update(dto.fieldStatus, (v) => v + 1, ifAbsent: () => 1);
      final p = dto.toApiJson();
      p.forEach((k, v) {
        if (v == null) nullKeys.update(k, (x) => x + 1, ifAbsent: () => 1);
      });
    }
    // ignore: avoid_print
    print('parsed=${list.length}');
    for (final e in counts.entries) {
      print('  ${e.key.label}: ${e.value}');
    }
    print('payloads containing a null value: $payloadsWithNullIds');
    expect(list.length, 4004);
    expect(nullKeys.keys, isEmpty);
  }, timeout: const Timeout(Duration(seconds: 120)));
}
