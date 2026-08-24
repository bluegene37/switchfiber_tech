import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';

JobOrderDto job({String? onsiteStatus, String status = 'Confirmed'}) =>
    JobOrderDto.fromJson({
      'id': 1,
      'status': status,
      'onsiteStatus': onsiteStatus,
    });

void main() {
  group('field status derived from the live API onsiteStatus vocabulary', () {
    test('maps every onsiteStatus value the live API returns', () {
      expect(job(onsiteStatus: 'Done').fieldStatus, FieldStatus.done);
      expect(job(onsiteStatus: 'Failed').fieldStatus, FieldStatus.failed);
      expect(
          job(onsiteStatus: 'Reschedule').fieldStatus, FieldStatus.reschedule);
      expect(
          job(onsiteStatus: 'In Progress').fieldStatus, FieldStatus.inProgress);
      expect(job(onsiteStatus: '').fieldStatus, FieldStatus.dispatched);
      expect(job(onsiteStatus: null).fieldStatus, FieldStatus.dispatched);
    });

    test('tolerates casing and punctuation variants', () {
      expect(job(onsiteStatus: 'in-progress').fieldStatus,
          FieldStatus.inProgress);
      expect(job(onsiteStatus: 'DONE').fieldStatus, FieldStatus.done);
      expect(job(onsiteStatus: ' Completed ').fieldStatus, FieldStatus.done);
    });

    test('an unrecognised value is surfaced, never silently shown as done', () {
      expect(job(onsiteStatus: 'Something New').fieldStatus,
          FieldStatus.dispatched);
    });

    test('the office order status is preserved verbatim, not lowercased away',
        () {
      expect(job(status: 'Confirmed').status, 'Confirmed');
      expect(job(status: 'Applied').status, 'Applied');
    });
  });

  group('field workflow advance', () {
    test('advances dispatched -> in progress -> done', () {
      expect(FieldStatus.dispatched.next, FieldStatus.inProgress);
      expect(FieldStatus.inProgress.next, FieldStatus.done);
    });

    test('does not roll a completed job back around the cycle', () {
      expect(FieldStatus.done.next, isNull);
    });

    test('a failed or rescheduled visit can be retried', () {
      expect(FieldStatus.failed.next, FieldStatus.inProgress);
      expect(FieldStatus.reschedule.next, FieldStatus.inProgress);
    });

    test('wire values round-trip back to what the API expects', () {
      expect(FieldStatus.done.wireValue, 'Done');
      expect(FieldStatus.inProgress.wireValue, 'In Progress');
      expect(FieldStatus.reschedule.wireValue, 'Reschedule');
    });
  });

  group('sync payload safety', () {
    test('never sends null over a value the server already holds', () {
      // The live API returns lcpId/napId/planId as strings such as "LCP 002",
      // which the integer columns cannot hold, so they parse to null.
      final j = JobOrderDto.fromJson({
        'id': 813,
        'status': 'Confirmed',
        'onsiteStatus': 'Done',
        'lcpId': 'LCP 002',
        'napId': 'NAP 006',
        'planId': 'SwitchLite - P699',
      });
      final payload = j.toApiJson();

      expect(payload.containsKey('lcpId'), isFalse,
          reason: 'a null lcpId would wipe the real assignment on the server');
      expect(payload.containsKey('napId'), isFalse);
      expect(payload['id'], 813);
    });

    test('reports the real on-site status rather than guessing In-Progress', () {
      final untouched = JobOrderDto.fromJson({
        'id': 1,
        'status': 'Applied',
        'onsiteStatus': '',
      });
      expect(untouched.toApiJson()['onsiteStatus'], 'Dispatched');

      final done = JobOrderDto.fromJson({
        'id': 2,
        'status': 'Confirmed',
        'onsiteStatus': 'Done',
      });
      expect(done.toApiJson()['onsiteStatus'], 'Done');
    });
  });
}
