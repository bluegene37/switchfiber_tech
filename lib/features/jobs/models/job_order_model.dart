import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

/// Clean DTO representation of a Job Order from the API.
/// The three job order statuses the technician works with.
///
/// These are the values the backend's `status` field carries once a job enters
/// the field workflow. Records outside these three - the application-side
/// `Applied` and `Confirmed` that make up almost the whole table today - have a
/// null [JobOrderDto.jobStatus] and appear only under the "All" tab.
enum JobStatus {
  inProgress('In Progress'),
  completed('Completed'),
  activated('Activated');

  const JobStatus(this.wireValue);

  /// Exact wording sent back to the API, and shown to the technician.
  final String wireValue;

  String get label => wireValue;

  /// The next status when the technician advances the job.
  /// [activated] is terminal: it must not roll back around a cycle.
  JobStatus? get next => switch (this) {
        JobStatus.inProgress => JobStatus.completed,
        JobStatus.completed => JobStatus.activated,
        JobStatus.activated => null,
      };

  /// Match a raw `status` value, or null when it is not one of the three.
  static JobStatus? parse(String? raw) {
    final v = raw?.trim().toLowerCase().replaceAll(RegExp(r'[-_\s]+'), '');
    return switch (v) {
      'inprogress' => JobStatus.inProgress,
      'completed' => JobStatus.completed,
      'activated' => JobStatus.activated,
      _ => null,
    };
  }
}

/// An on-site outcome that needs the technician's attention, taken from
/// `onsiteStatus`. Surfaced alongside the job status so a failed or postponed
/// visit stays visible instead of hiding behind "Confirmed".
enum SiteException {
  failed('Failed'),
  reschedule('Reschedule');

  const SiteException(this.label);

  final String label;

  static SiteException? parse(String? raw) {
    final v = raw?.trim().toLowerCase();
    return switch (v) {
      'failed' || 'cancelled' || 'canceled' => SiteException.failed,
      'reschedule' || 'rescheduled' => SiteException.reschedule,
      _ => null,
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

  /// The untouched API record, replayed on update. Null for demo rows.
  final String? rawJson;

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
    this.rawJson,
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

  /// This job's status, when it is one of the three the technician works with.
  /// Null for any other backend status, such as `Applied` or `Confirmed`.
  JobStatus? get jobStatus => JobStatus.parse(status);

  /// The next status when the technician advances this job. A job that is not
  /// yet in the field workflow starts at In Progress.
  JobStatus? get nextStatus =>
      jobStatus == null ? JobStatus.inProgress : jobStatus!.next;

  /// A failed or postponed visit that must stay visible to the technician.
  SiteException? get siteException => SiteException.parse(onsiteStatus);

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
      rawJson: jsonEncode(json),
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
      rawJson: row.rawJson,
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
      rawJson: Value(rawJson),
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

  /// Fields the technician's app is allowed to change on the server.
  ///
  /// Everything else in the record is echoed back untouched.
  Map<String, dynamic> _technicianEdits() => {
        'status': status,
        'onsiteStatus': onsiteStatus ?? '',
        'onsiteRemarks': onsiteRemarks ?? '',
        'modemRouterSN': modemRouterSN ?? '',
        'routerModel': routerModel ?? '',
        'portId': portId ?? '',
        'boxReadingImage': boxReadingImage ?? '',
        'routerReadingImage': routerReadingImage ?? '',
        'clientSignature': clientSignature ?? '',
      };

  /// Body for `PUT /api/JobOrders/{id}`.
  ///
  /// The endpoint's UpdateJobOrderRequest marks all 86 of its fields required,
  /// so a partial body is not an option: it would either fail validation or
  /// blank out every field the app does not model. The original record is
  /// therefore replayed in full with only the technician's edits applied on
  /// top.
  ///
  /// [rawJson] is absent only for locally seeded demo rows, which have no
  /// server record to preserve; those fall back to the modelled subset.
  Map<String, dynamic> toApiJson() {
    final original = rawJson;
    if (original == null || original.trim().isEmpty) {
      final fallback = <String, dynamic>{'id': id, ..._technicianEdits()};
      // Never send a null over a value the server may already hold.
      for (final e in <String, Object?>{
        'opticalPower': opticalPower,
        'lcpId': lcpId,
        'napId': napId,
        'vlanId': vlanId,
        'dateInstalled': dateInstalled?.toIso8601String(),
      }.entries) {
        if (e.value != null) fallback[e.key] = e.value;
      }
      return fallback;
    }

    final decoded = json.decode(original);
    if (decoded is! Map<String, dynamic>) {
      return <String, dynamic>{'id': id, ..._technicianEdits()};
    }

    return <String, dynamic>{
      ...decoded,
      ..._technicianEdits(),
      if (dateInstalled != null)
        'dateInstalled': dateInstalled!.toIso8601String(),
      if (opticalPower != null) 'opticalPower': opticalPower,
    };
  }
}
