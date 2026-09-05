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
        'accountNo': '202609022055224002481',
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

  test('applicationId is the record ID', () {
    final body = completedJob().toApiJson();
    expect(body['applicationId'], '1',
        reason: 'the GET omits applicationId, so the job ID is used to save');
  });

  test('applicationId falls back to zero only when there is no id', () {
    expect(JobOrderDto.normalizeForApi({'status': 'Activated'})['applicationId'], '0');
  });

  test('an applicationId the server already holds is kept', () {
    final raw = json.encode(
        {'id': 1, 'applicationId': '999', 'accountNo': '111', 'status': 'x'});
    expect(completedJob(raw: raw).toApiJson()['applicationId'], '999');
  });

  test('the numeric required fields are never sent as an empty string', () {
    // Empty strings cleared the 400 and then produced
    // "HTTP 500 An error occurred while updating job order with ID: 3977",
    // which is what parsing "" as a number looks like from outside.
    final body = completedJob().toApiJson();
    for (final field in [
      'duration',
      'applicationId',
      'billingDay',
      'installationFee'
    ]) {
      expect(body[field], isNot(''),
          reason: '$field holds a number; "" is not a safe filler');
      expect(body[field].toString().trim(), isNotEmpty);
    }
  });

  test('duration defaults to 2, as required on completion', () {
    expect(completedJob().toApiJson()['duration'], '2');
  });

  test('installationFee falls back to 1 when the record has none', () {
    final body = completedJob().toApiJson();
    expect(body['installationFee'], JobOrderDto.defaultInstallationFee);
    expect(body['installationFee'], '1');
  });

  test('an explicit zero installation fee is kept, not replaced by 1', () {
    final raw =
        json.encode({'id': 1, 'installationFee': 0.0, 'status': 'Activated'});
    final body = completedJob(raw: raw).toApiJson();
    expect(body['installationFee'], '0',
        reason: 'most job orders read 0 and a free install is a real value; '
            'only a null or empty fee counts as missing');
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

  test('normalizeForApi keeps contract values that already satisfy it', () {
    final clean = {
      'duration': '12',
      'billingDay': '5',
      'applicationId': '77',
      'installationFee': '1000',
    };
    final out = JobOrderDto.normalizeForApi(clean);
    for (final e in clean.entries) {
      expect(out[e.key], e.value, reason: '${e.key} must pass through');
    }
    expect(out.length, JobOrderDto.apiRequestFields.length,
        reason: 'the rest of the contract is filled in, not left out');
  });

  test('a job with no server record is normalized too', () {
    final body = completedJob(raw: '').toApiJson();
    expect(body['duration'], '2');
    expect(body['applicationId'], '1');
    expect(body['billingDay'], '27');
    expect(body['installationFee'], '1');
  });
}
