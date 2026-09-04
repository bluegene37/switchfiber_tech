import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';

/// `PUT /api/JobOrders/{id}` is not a clean round trip.
///
/// The matching GET returns `duration`, `billingDay` and `installationFee` as
/// null and omits `applicationId` entirely, then the PUT refuses the record it
/// just handed out:
///
///   HTTP 400 One or more validation errors occurred.
///   Duration: The Duration field is required.
///   BillingDay: The BillingDay field is required.
///   ApplicationId: The ApplicationId field is required.
///   InstallationFee: The InstallationFee field is required.
///
/// Every completion the app pushed failed on this, silently, until the sync
/// error log surfaced it. These lock the fix to that exact error.
void main() {
  /// A server record shaped like the real GET response.
  String rawServerRecord() => json.encode({
        'id': 1,
        'firstName': 'Ana',
        'lastName': 'Reyes',
        'status': 'Activated',
        'duration': null,
        'billingDay': null,
        'installationFee': null,
        // applicationId deliberately absent: the GET does not return it.
        'modifiedDate': null,
        'createdBy': null,
        'createdDate': null,
        'startTimeStamp': null,
        'endTimeStamp': null,
        'dateInstalled': null,
      });

  JobOrderDto completedJob({String? raw}) => JobOrderDto(
        id: 1,
        ticketNumber: 'SF-2026-0001',
        customerName: 'Ana Reyes',
        address: 'Lot 1, Fiber Street',
        status: 'Completed',
        onsiteStatus: 'Done',
        rawJson: raw ?? rawServerRecord(),
      );

  test('the four fields the server demanded are all sent', () {
    final body = completedJob().toApiJson();

    for (final field in [
      'duration',
      'billingDay',
      'applicationId',
      'installationFee'
    ]) {
      expect(body.containsKey(field), isTrue,
          reason: '$field is required by the PUT and must be present');
      expect(body[field], isNotNull,
          reason: '$field null is what produced the 400');
    }
  });

  test('a missing required field is added, not just un-nulled', () {
    final body = completedJob().toApiJson();
    expect(body['applicationId'], '',
        reason: 'the GET omits applicationId entirely, so the PUT must add it');
  });

  test('billingDay falls back to 27 when the record has none', () {
    final body = completedJob().toApiJson();
    expect(body['billingDay'], JobOrderDto.defaultBillingDay);
    expect(body['billingDay'], '27');
  });

  test('a real billing day is never overwritten by the fallback', () {
    final raw =
        json.encode({'id': 1, 'billingDay': '15', 'status': 'Activated'});
    final body = completedJob(raw: raw).toApiJson();
    expect(body['billingDay'], '15',
        reason: 'overwriting a subscriber\'s billing day to satisfy a '
            'validator would change real billing data');
  });

  test('the six genuinely nullable fields stay null', () {
    final body = completedJob().toApiJson();
    for (final field in [
      'modifiedDate',
      'startTimeStamp',
      'endTimeStamp',
      'createdBy',
      'createdDate',
    ]) {
      expect(body[field], isNull,
          reason: '$field is a date the endpoint accepts as null; sending "" '
              'would fail to parse');
    }
  });

  test('the technician\'s own edits still win over the replayed record', () {
    final body = completedJob().toApiJson();
    expect(body['status'], 'Completed',
        reason: 'the replayed record said Activated');
    expect(body['onsiteStatus'], 'Done');
  });

  test('no value the server already holds is changed', () {
    final raw = json.encode({
      'id': 1,
      'firstName': 'Ana',
      'installationFee': '2500',
      'duration': '24',
      'status': 'Activated',
    });
    final body = completedJob(raw: raw).toApiJson();
    expect(body['firstName'], 'Ana');
    expect(body['installationFee'], '2500');
    expect(body['duration'], '24');
  });

  test('normalizeForApi leaves a body that already satisfies the contract', () {
    final clean = {
      'duration': '12',
      'billingDay': '5',
      'applicationId': '77',
      'installationFee': '1000',
    };
    expect(JobOrderDto.normalizeForApi(clean), clean);
  });

  test('a job with no server record is normalized too', () {
    final body = completedJob(raw: '').toApiJson();
    expect(body['duration'], '');
    expect(body['applicationId'], '');
    expect(body['billingDay'], '27');
  });
}
