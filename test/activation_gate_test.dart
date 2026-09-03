import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/utils/data_url.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'dart:typed_data';

JobOrderDto _job({String? signature, String? serial}) => JobOrderDto(
      id: 1,
      ticketNumber: 'SF-1',
      customerName: 'Subscriber',
      address: 'Lot 1',
      status: 'Scheduled',
      clientSignature: signature,
      modemRouterSN: serial,
    );

final _signature = DataUrl.encode(Uint8List.fromList([1, 2, 3]));

void main() {
  test('a job with no report cannot be activated', () {
    expect(_job().hasCompletedReport, isFalse);
  });

  test('a signature alone is not a completed report', () {
    expect(_job(signature: _signature).hasCompletedReport, isFalse);
  });

  test('a serial alone is not a completed report', () {
    expect(_job(serial: 'HWTC123').hasCompletedReport, isFalse);
  });

  test('blank strings do not count as a filed report', () {
    expect(_job(signature: '  ', serial: '  ').hasCompletedReport, isFalse);
  });

  test('a signature and a serial together complete the report', () {
    final job = _job(signature: _signature, serial: 'HWTC123');
    expect(job.hasCompletedReport, isTrue);
    expect(job.canActivate, isTrue,
        reason: 'a scheduled job with a filed report is ready to activate');
  });
}
