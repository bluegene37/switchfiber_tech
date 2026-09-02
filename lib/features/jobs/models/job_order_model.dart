import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

/// The two stages a job order moves through in the field.
///
/// A job arrives **Scheduled** (the backend's `Applied` / `Confirmed` /
/// `Scheduled`) and the technician marks it **Activated** once the subscriber
/// is online. Activated jobs leave the scheduled queue and appear in the
/// technician's history, where they are view-only.
///
/// Statuses written by earlier versions of this app are folded in so nothing
/// already in the table vanishes: `In Progress` is still open work and counts
/// as Scheduled; `Completed` is finished work and counts as Activated.
enum JobStatus {
  scheduled('Scheduled'),
  activated('Activated');

  const JobStatus(this.wireValue);

  /// Exact wording sent back to the API, and shown to the technician.
  final String wireValue;

  String get label => wireValue;

  /// The next stage. [activated] is terminal.
  JobStatus? get next => switch (this) {
        JobStatus.scheduled => JobStatus.activated,
        JobStatus.activated => null,
      };

  /// Match a raw `status` value to the workflow stages.
  static JobStatus? parse(String? raw) {
    final v = raw?.trim().toLowerCase().replaceAll(RegExp(r'[-_\s]+'), '');
    return switch (v) {
      'scheduled' ||
      'confirmed' ||
      'applied' ||
      'pending' ||
      'inprogress' =>
        JobStatus.scheduled,
      'activated' || 'completed' => JobStatus.activated,
      _ => null,
    };
  }
}

/// The photo proofs a technician can attach to a job order, one per API
/// field. [clientSignature] is drawn rather than photographed and lives
/// alongside these on [JobOrderDto].
enum JobPhoto {
  boxReading('boxReadingImage', 'NAP Box Reading',
      'Optical power meter reading at the NAP port'),
  routerReading('routerReadingImage', 'ONT Rx Reading',
      'Optical reading at the subscriber ONT'),
  setup('setupImage', 'Installed Setup', 'ONT and router as installed'),
  speedtest('speedtestImage', 'Speed Test', 'Speed test result screenshot'),
  portLabel('portLabelImage', 'Port Label', 'Labelled NAP port'),
  signedContract(
      'signedContractImage', 'Signed Contract', 'Subscriber service contract'),
  houseFront(
      'houseFront', 'House Front', 'Subscriber premises from the street');

  const JobPhoto(this.jsonKey, this.label, this.hint);

  /// Field name on the API record and in [JobOrderDto.toApiJson].
  final String jsonKey;
  final String label;
  final String hint;
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
  final String? setupImage;
  final String? speedtestImage;
  final String? portLabelImage;
  final String? signedContractImage;
  final String? houseFront;

  /// Email of the technician the office assigned this job to.
  final String? assignedEmail;

  /// When the server record was last changed.
  final DateTime? modifiedDate;

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
    this.setupImage,
    this.speedtestImage,
    this.portLabelImage,
    this.signedContractImage,
    this.houseFront,
    this.assignedEmail,
    this.modifiedDate,
    this.isSynced = true,
    this.updatedAt,
  });

  /// This job's workflow stage, or null for a backend status the app does
  /// not recognise (shown verbatim in that case).
  JobStatus? get jobStatus => JobStatus.parse(status);

  bool get isScheduled => jobStatus == JobStatus.scheduled;
  bool get isActivated => jobStatus == JobStatus.activated;

  /// Anything not yet activated can be activated.
  bool get canActivate => !isActivated;

  /// The next stage when the technician advances this job. A job outside the
  /// workflow goes straight to Activated.
  JobStatus? get nextStatus =>
      jobStatus == null ? JobStatus.activated : jobStatus!.next;

  /// A failed or postponed visit that must stay visible to the technician.
  SiteException? get siteException => SiteException.parse(onsiteStatus);

  /// The stored value for a photo proof: a data URL captured on site, a path
  /// the office uploaded, or null / empty when nothing is attached.
  String? imageFor(JobPhoto photo) => switch (photo) {
        JobPhoto.boxReading => boxReadingImage,
        JobPhoto.routerReading => routerReadingImage,
        JobPhoto.setup => setupImage,
        JobPhoto.speedtest => speedtestImage,
        JobPhoto.portLabel => portLabelImage,
        JobPhoto.signedContract => signedContractImage,
        JobPhoto.houseFront => houseFront,
      };

  bool hasImage(JobPhoto photo) => imageFor(photo)?.trim().isNotEmpty == true;

  bool get hasSignature => clientSignature?.trim().isNotEmpty == true;

  /// Whether this job is assigned to the technician with [email].
  ///
  /// Compared case-insensitively and ignoring surrounding whitespace, since
  /// the office types these by hand. A blank email on either side never
  /// matches: an unassigned job belongs to nobody's history.
  bool isAssignedTo(String? email) {
    final mine = email?.trim().toLowerCase() ?? '';
    final theirs = assignedEmail?.trim().toLowerCase() ?? '';
    return mine.isNotEmpty && mine == theirs;
  }

  /// The date this job is placed at in the technician's history: when it was
  /// installed, otherwise when the server record last changed. Null when
  /// neither is known; the local cache timestamp is deliberately not used
  /// because it only says when the row was downloaded, not when the work
  /// happened.
  DateTime? get historyDate => dateInstalled ?? modifiedDate;

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
      contactNumber:
          json['contactNumber']?.toString() ?? json['mobileNumber']?.toString(),
      address: json['address']?.toString() ??
          json['installationAddress']?.toString() ??
          'N/A',
      barangay: json['barangay']?.toString(),
      city: json['city']?.toString(),
      planName: json['plan']?.toString() ??
          json['desiredPlan']?.toString() ??
          'Fiber 50Mbps',
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
      modemRouterSN: json['modemRouterSN']?.toString() ??
          json['routerModemSn']?.toString(),
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
      setupImage: json['setupImage']?.toString(),
      speedtestImage: json['speedtestImage']?.toString(),
      portLabelImage: json['portLabelImage']?.toString(),
      signedContractImage: json['signedContractImage']?.toString(),
      houseFront: json['houseFront']?.toString(),
      assignedEmail: json['assignedEmail']?.toString(),
      modifiedDate: json['modifiedDate'] != null
          ? DateTime.tryParse(json['modifiedDate'].toString())
          : null,
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
      setupImage: row.setupImage,
      speedtestImage: row.speedtestImage,
      portLabelImage: row.portLabelImage,
      signedContractImage: row.signedContractImage,
      houseFront: row.houseFront,
      assignedEmail: row.assignedEmail,
      modifiedDate: row.modifiedDate,
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
      setupImage: Value(setupImage),
      speedtestImage: Value(speedtestImage),
      portLabelImage: Value(portLabelImage),
      signedContractImage: Value(signedContractImage),
      houseFront: Value(houseFront),
      assignedEmail: Value(assignedEmail),
      modifiedDate: Value(modifiedDate),
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
        // Photos and the signature are sent only when the app holds a value
        // (an empty string clears one on purpose). A null means the column
        // was added after the row was cached, and the server's copy in
        // rawJson must win rather than be blanked.
        if (boxReadingImage != null) 'boxReadingImage': boxReadingImage,
        if (routerReadingImage != null)
          'routerReadingImage': routerReadingImage,
        if (clientSignature != null) 'clientSignature': clientSignature,
        if (setupImage != null) 'setupImage': setupImage,
        if (speedtestImage != null) 'speedtestImage': speedtestImage,
        if (portLabelImage != null) 'portLabelImage': portLabelImage,
        if (signedContractImage != null)
          'signedContractImage': signedContractImage,
        if (houseFront != null) 'houseFront': houseFront,
        // Stamped on activation. Left out when unknown so a cached row from
        // before this column existed never blanks the office's assignment.
        if (assignedEmail != null) 'assignedEmail': assignedEmail,
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
