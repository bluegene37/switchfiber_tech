import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';

/// Every field UpdateJobOrderRequest marks as required, taken from the live
/// OpenAPI document at /openapi/v1.json. PUT /api/JobOrders/{id} rejects or
/// blanks a body that does not carry all of them.
const requiredFields = <String>[
  'emailAddress',
  'referredBy',
  'firstName',
  'middleInitial',
  'lastName',
  'contactNumber',
  'applicantEmailAddress',
  'address',
  'location',
  'barangay',
  'city',
  'region',
  'planId',
  'remarks',
  'installationFee',
  'contractTemplate',
  'billingDay',
  'preferredDay',
  'joRemarks',
  'status',
  'verifiedBy',
  'modemRouterSN',
  'provider',
  'lcpId',
  'napId',
  'portId',
  'vlanId',
  'username',
  'visitBy',
  'visitWith',
  'visitWithOther',
  'onsiteStatus',
  'onsiteRemarks',
  'modifiedBy',
  'modifiedDate',
  'contractLink',
  'connectionType',
  'assignedEmail',
  'setupImage',
  'speedtestImage',
  'startTimeStamp',
  'endTimeStamp',
  'duration',
  'externalId',
  'lcpnapId',
  'billingStatus',
  'routerModel',
  'dateInstalled',
  'clientSignature',
  'ip',
  'signedContractImage',
  'boxReadingImage',
  'routerReadingImage',
  'usernameStatus',
  'lcpnapportId',
  'itemName1',
  'itemQuantity1',
  'itemName2',
  'itemQuantity2',
  'itemName3',
  'itemQuantity3',
  'itemName4',
  'itemQuantity4',
  'itemName5',
  'itemQuantity5',
  'itemName6',
  'itemQuantity6',
  'itemName7',
  'itemQuantity7',
  'itemName8',
  'itemQuantity8',
  'itemName9',
  'itemQuantity9',
  'itemName10',
  'itemQuantity10',
  'usageType',
  'renter',
  'installationLandmark',
  'statusRemarks',
  'portLabelImage',
  'secondContactNumber',
  'accountNo',
  'addressCoordinates',
  'referrersAccountNumber',
  'applicationId',
  'houseFront',
];

void main() {
  group('PUT body round-trips the whole server record', () {
    // A record shaped like the live API's, carrying fields the app does not
    // model at all.
    Map<String, dynamic> serverRecord() => <String, dynamic>{
          for (final f in requiredFields) f: 'original-$f',
          'id': 813,
          'status': 'Confirmed',
          'onsiteStatus': 'Done',
          'lcpId': 'LCP 002',
          'napId': 'NAP 006',
          'planId': 'SwitchLite - P699',
        };

    test('carries every field the endpoint requires', () {
      final payload = JobOrderDto.fromJson(serverRecord()).toApiJson();
      final missing =
          requiredFields.where((f) => !payload.containsKey(f)).toList();
      expect(missing, isEmpty,
          reason: 'a partial body would blank these out on the server');
    });

    test('preserves fields the app does not model', () {
      final payload = JobOrderDto.fromJson(serverRecord()).toApiJson();
      expect(payload['itemQuantity7'], 'original-itemQuantity7');
      expect(
          payload['referrersAccountNumber'], 'original-referrersAccountNumber');
      expect(payload['billingStatus'], 'original-billingStatus');
      expect(payload['houseFront'], 'original-houseFront');
    });

    test('preserves string ids the integer columns cannot hold', () {
      final payload = JobOrderDto.fromJson(serverRecord()).toApiJson();
      expect(payload['lcpId'], 'LCP 002',
          reason: 'parsing drops these to null; the record must survive');
      expect(payload['napId'], 'NAP 006');
      expect(payload['planId'], 'SwitchLite - P699');
    });

    test('applies the status the technician set', () {
      final dto = JobOrderDto.fromJson(serverRecord());
      final advanced = JobOrderDto.fromJson({
        ...jsonDecode(dto.rawJson!) as Map<String, dynamic>,
        'status': JobStatus.activated.wireValue,
      });
      final payload = advanced.toApiJson();
      expect(payload['status'], 'Activated');
      expect(payload['itemName3'], 'original-itemName3');
    });
  });
}
