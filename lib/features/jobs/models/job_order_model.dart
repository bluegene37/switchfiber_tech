import 'dart:convert';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:drift/drift.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/photo_storage_service.dart';

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
  activated('Activated'),
  completed('Completed');

  const JobStatus(this.wireValue);

  /// Exact wording sent back to the API, and shown to the technician.
  final String wireValue;

  String get label => wireValue;

  /// The next stage. [completed] and [activated] are terminal stages.
  JobStatus? get next => switch (this) {
        JobStatus.scheduled => JobStatus.completed,
        JobStatus.activated => null,
        JobStatus.completed => null,
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
      'activated' => JobStatus.activated,
      'completed' => JobStatus.completed,
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
  final String? nap;
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
    this.nap,
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
  bool get isCompleted => jobStatus == JobStatus.completed;
  bool get isHistory => isActivated || isCompleted;

  /// Anything not yet in history can be activated.
  bool get canActivate => !isHistory;

  /// The next stage when the technician advances this job. A job outside the
  /// workflow goes straight to Completed.
  JobStatus? get nextStatus =>
      jobStatus == null ? JobStatus.completed : jobStatus!.next;

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

  /// Whether the on-site completion report has been filed for this job.
  ///
  /// These are the same two fields `ReportSignals.isFormValid` requires before
  /// it will let a report be submitted, so the two agree on what "complete"
  /// means. Activation is final, so it is gated on this.
  bool get hasCompletedReport =>
      hasSignature && modemRouterSN?.trim().isNotEmpty == true;

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

  /// The subscriber or installation location fix, parsed from rawJson if present.
  LatLng? get latLng {
    if (rawJson != null) {
      try {
        final map = jsonDecode(rawJson!);
        if (map is Map<String, dynamic>) {
          final raw = map['coordinates'] ?? map['location'] ?? map['latLng'];
          if (raw is String && raw.trim().isNotEmpty) {
            final parts = raw
                .replaceAll(RegExp(r'[^\d.,\s-]'), '')
                .split(RegExp(r'[,;\s]+'));
            if (parts.length >= 2) {
              final lat = double.tryParse(parts[0]);
              final lng = double.tryParse(parts[1]);
              if (lat != null &&
                  lng != null &&
                  lat.abs() <= 90 &&
                  lng.abs() <= 180 &&
                  !(lat == 0 && lng == 0)) {
                return LatLng(lat, lng);
              }
            }
          }
          final lat = map['latitude'] ?? map['lat'];
          final lng = map['longitude'] ?? map['lng'] ?? map['lon'];
          if (lat != null && lng != null) {
            final latD = double.tryParse(lat.toString());
            final lngD = double.tryParse(lng.toString());
            if (latD != null &&
                lngD != null &&
                latD.abs() <= 90 &&
                lngD.abs() <= 180 &&
                !(latD == 0 && lngD == 0)) {
              return LatLng(latD, lngD);
            }
          }
        }
      } catch (_) {}
    }
    return null;
  }

  factory JobOrderDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    final firstName = json['firstName']?.toString().trim() ?? '';
    final lastName = json['lastName']?.toString().trim() ?? '';
    final name = '$firstName $lastName'.trim();

    final rawAccountNo = json['accountNo']?.toString().trim() ?? '';
    final rawTicket = json['ticketNumber']?.toString().trim() ?? '';
    final ticketNumber = rawAccountNo.isNotEmpty
        ? rawAccountNo
        : (rawTicket.isNotEmpty ? rawTicket : 'JO-$id');

    final customerName = name.isNotEmpty
        ? name
        : (json['fullName']?.toString().trim().isNotEmpty == true
            ? json['fullName'].toString().trim()
            : (json['customerName']?.toString().trim().isNotEmpty == true
                ? json['customerName'].toString().trim()
                : 'Subscriber #$id'));

    final rawAddr = (json['address']?.toString() ??
            json['installationAddress']?.toString() ??
            '')
        .trim();
    final address = rawAddr.isNotEmpty ? rawAddr : 'N/A';

    return JobOrderDto(
      id: id,
      ticketNumber: ticketNumber,
      customerName: customerName,
      contactNumber:
          json['contactNumber']?.toString() ?? json['mobileNumber']?.toString(),
      address: address,
      barangay: json['barangay']?.toString(),
      city: json['city']?.toString(),
      planName: json['plan']?.toString() ??
          json['desiredPlan']?.toString() ??
          (json['planId'] is String ? json['planId'] as String : null) ??
          json['choose_Plan']?.toString() ??
          '',
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
      nap: json['nap']?.toString() ??
          (json['napId'] is String ? json['napId'] as String : null),
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
      nap: row.nap,
      portId: row.portId,
      vlanId: row.vlanId,
      dateInstalled: row.dateInstalled,
      boxReadingImage: PhotoStorageService.instance
          .resolveToDataUrlSync(row.boxReadingImage),
      routerReadingImage: PhotoStorageService.instance
          .resolveToDataUrlSync(row.routerReadingImage),
      clientSignature: PhotoStorageService.instance
          .resolveToDataUrlSync(row.clientSignature),
      setupImage:
          PhotoStorageService.instance.resolveToDataUrlSync(row.setupImage),
      speedtestImage:
          PhotoStorageService.instance.resolveToDataUrlSync(row.speedtestImage),
      portLabelImage:
          PhotoStorageService.instance.resolveToDataUrlSync(row.portLabelImage),
      signedContractImage: PhotoStorageService.instance
          .resolveToDataUrlSync(row.signedContractImage),
      houseFront:
          PhotoStorageService.instance.resolveToDataUrlSync(row.houseFront),
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
      nap: Value(nap),
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

  /// Every field of `UpdateJobOrderRequest`, exactly as the owner's working
  /// curl sends it. The PUT body is built from this list and nothing else.
  ///
  /// The GET returns 99 keys, a dozen of which (`id`, `timestamp`, `nap`,
  /// `lcp`, `vlan`, `choose_Plan`, …) are read-side echoes the request type
  /// does not declare. Replaying them was one more way for the update to
  /// fail without saying which field it disliked.
  static const List<String> apiRequestFields = [
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
    'createdBy',
    'createdDate',
  ];

  /// Fields `PUT /api/JobOrders/{id}` accepts as null.
  ///
  /// Everything else in UpdateJobOrderRequest is a non-nullable string, so a
  /// null fails validation where an empty string passes.
  static const Set<String> _nullableApiFields = {
    'modifiedDate',
    'startTimeStamp',
    'endTimeStamp',
    'dateInstalled',
    'createdBy',
    'createdDate',
  };

  /// Fields the PUT requires that the matching GET does not always return.
  ///
  /// The endpoint is not a clean round trip: `GET /api/JobOrders/{id}` hands
  /// back `duration`, `billingDay` and `installationFee` as null and omits
  /// `applicationId` entirely, then the PUT rejects the very record it just
  /// gave out with "The Duration field is required". Replaying the server's
  /// own response therefore fails with HTTP 400 unless these are filled in.
  /// These four hold numbers, so an empty string is not a safe filler: the
  /// endpoint accepted `""` past validation and then failed inside the update
  /// with `HTTP 500 An error occurred while updating job order with ID`,
  /// which is what a numeric parse of an empty string looks like from the
  /// outside. Each is given a numeric default instead.
  ///
  /// `duration` is null on every record on the server, so there is no
  /// populated example to copy a format from; zero is the neutral choice.
  /// `applicationId` is handled separately: it is the application's own
  /// number, which the record already carries as `accountNo`.
  static const Map<String, String> _requiredApiFields = {
    'duration': defaultDuration,
    'billingDay': defaultBillingDay,
    'installationFee': defaultInstallationFee,
  };

  /// Default duration set on job completion.
  static const String defaultDuration = '2';

  /// Billing day used when the record carries none.
  ///
  /// A subscriber that already has a billing day keeps it: overwriting one
  /// would change real billing data to satisfy a validator.
  static const String defaultBillingDay = '27';

  /// Installation fee used when the record carries none.
  ///
  /// A record that already has a fee keeps it, **including an explicit 0**.
  /// Most job orders on the server currently read 0, and a zero fee is a real
  /// value the office may have set on purpose; only a null or empty fee is
  /// treated as missing.
  static const String defaultInstallationFee = '1';

  /// Makes [body] satisfy UpdateJobOrderRequest without changing any value
  /// the server actually holds.
  ///
  /// Produces exactly the contract's fields, every value a string, in the
  /// shape the owner's own curl uses:
  ///
  /// - keys outside [apiRequestFields] are dropped;
  /// - the four numeric required fields get a numeric default when the record
  ///   has none, whether they arrived null or were missing entirely;
  /// - the six genuinely nullable fields stay null;
  /// - every other null becomes `""`, and every number (`0.0`, `22`) becomes
  ///   its string form, since the request type declares strings.
  static Map<String, dynamic> normalizeForApi(Map<String, dynamic> body) {
    final out = Map<String, dynamic>.from(body);

    for (final entry in _requiredApiFields.entries) {
      final current = out[entry.key];
      // Only a null or blank counts as missing. A value the office already
      // set is kept, including an explicit zero fee or a real billing day.
      if (current == null || current.toString().trim().isEmpty) {
        out[entry.key] = entry.value;
      }
    }

    // The GET never returns applicationId, but the PUT requires it.
    // Use the record's ID to satisfy the backend requirement.
    final applicationId = out['applicationId'];
    if (applicationId == null || applicationId.toString().trim().isEmpty) {
      final idVal = out['id']?.toString().trim() ?? '';
      out['applicationId'] = idVal.isNotEmpty ? idVal : (out['accountNo']?.toString().trim() ?? '0');
    }

    final result = <String, dynamic>{};
    for (final key in apiRequestFields) {
      final value = out[key];
      if (value == null) {
        result[key] = _nullableApiFields.contains(key) ? null : '';
      } else if (value is num) {
        // 22 -> "22", 0.0 -> "0", 799.5 -> "799.5".
        result[key] = value == value.truncateToDouble() && value.abs() < 1e15
            ? value.toInt().toString()
            : value.toString();
      } else {
        result[key] = value.toString();
      }
    }
    return result;
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
        if (nap != null) 'nap': nap,
        if (nap != null) 'napId': nap,
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
      return normalizeForApi(fallback);
    }

    final decoded = json.decode(original);
    if (decoded is! Map<String, dynamic>) {
      return normalizeForApi(
          <String, dynamic>{'id': id, ..._technicianEdits()});
    }

    return normalizeForApi(<String, dynamic>{
      'id': id,
      ...decoded,
      ..._technicianEdits(),
      if (dateInstalled != null)
        'dateInstalled': dateInstalled!.toIso8601String(),
      if (opticalPower != null) 'opticalPower': opticalPower,
    });
  }

  /// Whether `PUT /api/JobOrders/{id}` can take an image inline.
  ///
  /// It cannot yet. Probed on 2026-09-05 against job order 3975:
  /// clientSignature, setupImage and houseFront accept 255 characters and
  /// answer HTTP 500 "An error occurred while updating job order" at 256, so
  /// any real image failed the whole completion. Until the backend takes
  /// uploads, each captured image is sent as the placeholder URL the owner
  /// asked for and the image itself stays on the phone. Flip this once the
  /// backend stores inline images.
  static const bool serverAcceptsInlineImages = false;

  /// Stand-ins sent while [serverAcceptsInlineImages] is false.
  static const String placeholderPhotoUrl = 'https://picsum.photos/200';
  static const String placeholderSignatureUrl =
      'https://picsum.photos/200/300?grayscale';

  /// The image fields of `UpdateJobOrderRequest`.
  static const List<String> imageFields = [
    'boxReadingImage',
    'routerReadingImage',
    'clientSignature',
    'setupImage',
    'speedtestImage',
    'portLabelImage',
    'signedContractImage',
    'houseFront',
  ];

  /// Converts fields to API JSON map. Captured photos and the signature go
  /// out as Base64 data URLs when [serverAcceptsInlineImages], otherwise as
  /// the placeholder URLs. A value the server itself holds (`image.jpeg`,
  /// `uploads/...`) or an empty field is echoed back unchanged.
  Future<Map<String, dynamic>> toApiJsonAsync() async {
    if (serverAcceptsInlineImages) return toApiJsonWithInlineImages();
    final map = toApiJson();
    final storage = PhotoStorageService.instance;
    for (final key in imageFields) {
      final value = map[key];
      if (value is! String || !storage.isCapturedImage(value)) continue;
      map[key] = key == 'clientSignature'
          ? placeholderSignatureUrl
          : placeholderPhotoUrl;
    }
    return map;
  }

  /// The old inline form, kept for the day the flag above flips.
  @visibleForTesting
  Future<Map<String, dynamic>> toApiJsonWithInlineImages() async {
    final map = toApiJson();
    final storage = PhotoStorageService.instance;
    const keys = [
      'boxReadingImage',
      'routerReadingImage',
      'clientSignature',
      'setupImage',
      'speedtestImage',
      'portLabelImage',
      'signedContractImage',
      'houseFront',
    ];
    for (final key in keys) {
      if (map.containsKey(key) && map[key] is String) {
        map[key] = await storage.resolveToDataUrl(map[key] as String);
      }
    }
    return map;
  }
}
