import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

/// Clean DTO representation of a Job Order from the API.
/// The technician's on-site workflow state, using the vocabulary the Switch
/// Fiber API actually returns in `onsiteStatus`.
///
/// This is distinct from [JobOrderDto.status], which is the office-side order
/// state (`Applied`, `Confirmed`) and is not the technician's concern.
enum FieldStatus {
  dispatched('Dispatched', 'Dispatched'),
  inProgress('In Progress', 'In Progress'),
  done('Done', 'Done'),
  failed('Failed', 'Failed'),
  reschedule('Reschedule', 'Reschedule');

  const FieldStatus(this.label, this.wireValue);

  /// Text shown to the technician.
  final String label;

  /// Value sent back to the API in `onsiteStatus`.
  final String wireValue;

  /// The next state when the technician advances the job.
  ///
  /// [done] returns null: a finished visit must not roll back around a cycle,
  /// which on live data would overwrite a real completed record.
  FieldStatus? get next => switch (this) {
        FieldStatus.dispatched => FieldStatus.inProgress,
        FieldStatus.failed => FieldStatus.inProgress,
        FieldStatus.reschedule => FieldStatus.inProgress,
        FieldStatus.inProgress => FieldStatus.done,
        FieldStatus.done => null,
      };

  /// Parse an API `onsiteStatus` value. Unknown or empty values fall back to
  /// [dispatched] - work not yet started - rather than implying completion.
  static FieldStatus parse(String? raw) {
    final v = raw?.trim().toLowerCase().replaceAll(RegExp(r'[-_\s]+'), '');
    return switch (v) {
      'done' || 'completed' || 'complete' => FieldStatus.done,
      'inprogress' || 'ongoing' => FieldStatus.inProgress,
      'failed' || 'cancelled' || 'canceled' => FieldStatus.failed,
      'reschedule' || 'rescheduled' => FieldStatus.reschedule,
      _ => FieldStatus.dispatched,
    };
  }
}

class JobOrderDto {
  final int id;
  final String ticketNumber;
  final String customerName;
  final String? contactNumber;
  final String address;
  final String? barangay;
  final String? city;
  final String? planName;
  final int? planId;
  final String status;
  final String? onsiteStatus;

  final String? onsiteRemarks;
  final double? opticalPower;
  final String? modemRouterSN;
  final String? routerModel;
  final int? lcpId;
  final int? napId;
  final String? portId;
  final int? vlanId;
  final DateTime? dateInstalled;
  final String? boxReadingImage;
  final String? routerReadingImage;
  final String? clientSignature;
  final bool isSynced;
  final DateTime? updatedAt;

  JobOrderDto({
    required this.id,
    required this.ticketNumber,
    required this.customerName,
    this.contactNumber,
    required this.address,
    this.barangay,
    this.city,
    this.planName,
    this.planId,
    this.status = 'pending',
    this.onsiteStatus,
    this.onsiteRemarks,
    this.opticalPower,
    this.modemRouterSN,
    this.routerModel,
    this.lcpId,
    this.napId,
    this.portId,
    this.vlanId,
    this.dateInstalled,
    this.boxReadingImage,
    this.routerReadingImage,
    this.clientSignature,
    this.isSynced = true,
    this.updatedAt,
  });

  /// The technician's on-site workflow state for this job.
  FieldStatus get fieldStatus => FieldStatus.parse(onsiteStatus);

  factory JobOrderDto.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName']?.toString() ?? '';
    final lastName = json['lastName']?.toString() ?? '';
    final name = '$firstName $lastName'.trim();

    return JobOrderDto(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      ticketNumber: json['accountNo']?.toString() ??
          json['ticketNumber']?.toString() ??
          'JO-${json['id'] ?? '000'}',
      customerName: name.isNotEmpty
          ? name
          : json['fullName']?.toString() ??
              json['customerName']?.toString() ??
              'Subscriber',
      contactNumber: json['contactNumber']?.toString() ??
          json['mobileNumber']?.toString(),
      address: json['address']?.toString() ??
          json['installationAddress']?.toString() ??
          'N/A',
      barangay: json['barangay']?.toString(),
      city: json['city']?.toString(),
      planName: json['plan']?.toString() ?? json['desiredPlan']?.toString() ?? 'Fiber 50Mbps',
      planId: json['planId'] is int
          ? json['planId']
          : int.tryParse(json['planId']?.toString() ?? '0'),
      // Preserved verbatim: the API's office-side vocabulary is 'Applied' /
      // 'Confirmed', and lowercasing it silently broke every status comparison.
      status: json['status']?.toString().trim() ?? 'pending',
      onsiteStatus: json['onsiteStatus']?.toString(),
      onsiteRemarks: json['onsiteRemarks']?.toString(),
      opticalPower: json['opticalPower'] is num
          ? (json['opticalPower'] as num).toDouble()
          : double.tryParse(json['opticalPower']?.toString() ?? ''),
      modemRouterSN: json['modemRouterSN']?.toString() ?? json['routerModemSn']?.toString(),
      routerModel: json['routerModel']?.toString(),
      lcpId: json['lcpId'] is int
          ? json['lcpId']
          : int.tryParse(json['lcpId']?.toString() ?? ''),
      napId: json['napId'] is int
          ? json['napId']
          : int.tryParse(json['napId']?.toString() ?? ''),
      portId: json['portId']?.toString() ?? json['port']?.toString(),
      vlanId: json['vlanId'] is int
          ? json['vlanId']
          : int.tryParse(json['vlanId']?.toString() ?? ''),
      dateInstalled: json['dateInstalled'] != null
          ? DateTime.tryParse(json['dateInstalled'].toString())
          : null,
      boxReadingImage: json['boxReadingImage']?.toString(),
      routerReadingImage: json['routerReadingImage']?.toString(),
      clientSignature: json['clientSignature']?.toString(),
      isSynced: true,
      updatedAt: DateTime.now(),
    );
  }

  factory JobOrderDto.fromDrift(JobOrder row) {
    return JobOrderDto(
      id: row.id,
      ticketNumber: row.ticketNumber,
      customerName: row.customerName,
      contactNumber: row.contactNumber,
      address: row.address,
      barangay: row.barangay,
      city: row.city,
      planName: row.planName,
      planId: row.planId,
      status: row.status,
      onsiteStatus: row.onsiteStatus,
      onsiteRemarks: row.onsiteRemarks,
      opticalPower: row.opticalPower,
      modemRouterSN: row.modemRouterSN,
      routerModel: row.routerModel,
      lcpId: row.lcpId,
      napId: row.napId,
      portId: row.portId,
      vlanId: row.vlanId,
      dateInstalled: row.dateInstalled,
      boxReadingImage: row.boxReadingImage,
      routerReadingImage: row.routerReadingImage,
      clientSignature: row.clientSignature,
      isSynced: row.isSynced,
      updatedAt: row.updatedAt,
    );
  }

  JobOrdersCompanion toCompanion({bool synced = true}) {
    return JobOrdersCompanion(
      id: Value(id),
      ticketNumber: Value(ticketNumber),
      customerName: Value(customerName),
      contactNumber: Value(contactNumber),
      address: Value(address),
      barangay: Value(barangay),
      city: Value(city),
      planName: Value(planName),
      planId: Value(planId),
      status: Value(status),
      onsiteStatus: Value(onsiteStatus),
      onsiteRemarks: Value(onsiteRemarks),
      opticalPower: Value(opticalPower),
      modemRouterSN: Value(modemRouterSN),
      routerModel: Value(routerModel),
      lcpId: Value(lcpId),
      napId: Value(napId),
      portId: Value(portId),
      vlanId: Value(vlanId),
      dateInstalled: Value(dateInstalled),
      boxReadingImage: Value(boxReadingImage),
      routerReadingImage: Value(routerReadingImage),
      clientSignature: Value(clientSignature),
      isSynced: Value(synced),
      updatedAt: Value(updatedAt ?? DateTime.now()),
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'id': id,
      'status': status,
      'onsiteStatus': onsiteStatus ?? (status == 'completed' ? 'Completed' : 'In-Progress'),
      'onsiteRemarks': onsiteRemarks ?? '',
      'opticalPower': opticalPower,
      'modemRouterSN': modemRouterSN ?? '',
      'routerModel': routerModel ?? '',
      'lcpId': lcpId,
      'napId': napId,
      'portId': portId ?? '',
      'vlanId': vlanId,
      'dateInstalled': (dateInstalled ?? DateTime.now()).toIso8601String(),
      'boxReadingImage': boxReadingImage ?? '',
      'routerReadingImage': routerReadingImage ?? '',
      'clientSignature': clientSignature ?? '',
    };
  }
}
