// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $JobOrdersTable extends JobOrders
    with TableInfo<$JobOrdersTable, JobOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ticketNumberMeta =
      const VerificationMeta('ticketNumber');
  @override
  late final GeneratedColumn<String> ticketNumber = GeneratedColumn<String>(
      'ticket_number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactNumberMeta =
      const VerificationMeta('contactNumber');
  @override
  late final GeneratedColumn<String> contactNumber = GeneratedColumn<String>(
      'contact_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _barangayMeta =
      const VerificationMeta('barangay');
  @override
  late final GeneratedColumn<String> barangay = GeneratedColumn<String>(
      'barangay', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _planNameMeta =
      const VerificationMeta('planName');
  @override
  late final GeneratedColumn<String> planName = GeneratedColumn<String>(
      'plan_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
      'plan_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _onsiteStatusMeta =
      const VerificationMeta('onsiteStatus');
  @override
  late final GeneratedColumn<String> onsiteStatus = GeneratedColumn<String>(
      'onsite_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _onsiteRemarksMeta =
      const VerificationMeta('onsiteRemarks');
  @override
  late final GeneratedColumn<String> onsiteRemarks = GeneratedColumn<String>(
      'onsite_remarks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _opticalPowerMeta =
      const VerificationMeta('opticalPower');
  @override
  late final GeneratedColumn<double> opticalPower = GeneratedColumn<double>(
      'optical_power', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _modemRouterSNMeta =
      const VerificationMeta('modemRouterSN');
  @override
  late final GeneratedColumn<String> modemRouterSN = GeneratedColumn<String>(
      'modem_router_s_n', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _routerModelMeta =
      const VerificationMeta('routerModel');
  @override
  late final GeneratedColumn<String> routerModel = GeneratedColumn<String>(
      'router_model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lcpIdMeta = const VerificationMeta('lcpId');
  @override
  late final GeneratedColumn<int> lcpId = GeneratedColumn<int>(
      'lcp_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _napIdMeta = const VerificationMeta('napId');
  @override
  late final GeneratedColumn<int> napId = GeneratedColumn<int>(
      'nap_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _portIdMeta = const VerificationMeta('portId');
  @override
  late final GeneratedColumn<String> portId = GeneratedColumn<String>(
      'port_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vlanIdMeta = const VerificationMeta('vlanId');
  @override
  late final GeneratedColumn<int> vlanId = GeneratedColumn<int>(
      'vlan_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dateInstalledMeta =
      const VerificationMeta('dateInstalled');
  @override
  late final GeneratedColumn<DateTime> dateInstalled =
      GeneratedColumn<DateTime>('date_installed', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _boxReadingImageMeta =
      const VerificationMeta('boxReadingImage');
  @override
  late final GeneratedColumn<String> boxReadingImage = GeneratedColumn<String>(
      'box_reading_image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _routerReadingImageMeta =
      const VerificationMeta('routerReadingImage');
  @override
  late final GeneratedColumn<String> routerReadingImage =
      GeneratedColumn<String>('router_reading_image', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientSignatureMeta =
      const VerificationMeta('clientSignature');
  @override
  late final GeneratedColumn<String> clientSignature = GeneratedColumn<String>(
      'client_signature', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _assignedEmailMeta =
      const VerificationMeta('assignedEmail');
  @override
  late final GeneratedColumn<String> assignedEmail = GeneratedColumn<String>(
      'assigned_email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modifiedDateMeta =
      const VerificationMeta('modifiedDate');
  @override
  late final GeneratedColumn<DateTime> modifiedDate = GeneratedColumn<DateTime>(
      'modified_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        ticketNumber,
        customerName,
        contactNumber,
        address,
        barangay,
        city,
        planName,
        planId,
        status,
        onsiteStatus,
        onsiteRemarks,
        opticalPower,
        modemRouterSN,
        routerModel,
        lcpId,
        napId,
        portId,
        vlanId,
        dateInstalled,
        boxReadingImage,
        routerReadingImage,
        clientSignature,
        assignedEmail,
        modifiedDate,
        rawJson,
        isSynced,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_orders';
  @override
  VerificationContext validateIntegrity(Insertable<JobOrder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ticket_number')) {
      context.handle(
          _ticketNumberMeta,
          ticketNumber.isAcceptableOrUnknown(
              data['ticket_number']!, _ticketNumberMeta));
    } else if (isInserting) {
      context.missing(_ticketNumberMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('contact_number')) {
      context.handle(
          _contactNumberMeta,
          contactNumber.isAcceptableOrUnknown(
              data['contact_number']!, _contactNumberMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('barangay')) {
      context.handle(_barangayMeta,
          barangay.isAcceptableOrUnknown(data['barangay']!, _barangayMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('plan_name')) {
      context.handle(_planNameMeta,
          planName.isAcceptableOrUnknown(data['plan_name']!, _planNameMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(_planIdMeta,
          planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('onsite_status')) {
      context.handle(
          _onsiteStatusMeta,
          onsiteStatus.isAcceptableOrUnknown(
              data['onsite_status']!, _onsiteStatusMeta));
    }
    if (data.containsKey('onsite_remarks')) {
      context.handle(
          _onsiteRemarksMeta,
          onsiteRemarks.isAcceptableOrUnknown(
              data['onsite_remarks']!, _onsiteRemarksMeta));
    }
    if (data.containsKey('optical_power')) {
      context.handle(
          _opticalPowerMeta,
          opticalPower.isAcceptableOrUnknown(
              data['optical_power']!, _opticalPowerMeta));
    }
    if (data.containsKey('modem_router_s_n')) {
      context.handle(
          _modemRouterSNMeta,
          modemRouterSN.isAcceptableOrUnknown(
              data['modem_router_s_n']!, _modemRouterSNMeta));
    }
    if (data.containsKey('router_model')) {
      context.handle(
          _routerModelMeta,
          routerModel.isAcceptableOrUnknown(
              data['router_model']!, _routerModelMeta));
    }
    if (data.containsKey('lcp_id')) {
      context.handle(
          _lcpIdMeta, lcpId.isAcceptableOrUnknown(data['lcp_id']!, _lcpIdMeta));
    }
    if (data.containsKey('nap_id')) {
      context.handle(
          _napIdMeta, napId.isAcceptableOrUnknown(data['nap_id']!, _napIdMeta));
    }
    if (data.containsKey('port_id')) {
      context.handle(_portIdMeta,
          portId.isAcceptableOrUnknown(data['port_id']!, _portIdMeta));
    }
    if (data.containsKey('vlan_id')) {
      context.handle(_vlanIdMeta,
          vlanId.isAcceptableOrUnknown(data['vlan_id']!, _vlanIdMeta));
    }
    if (data.containsKey('date_installed')) {
      context.handle(
          _dateInstalledMeta,
          dateInstalled.isAcceptableOrUnknown(
              data['date_installed']!, _dateInstalledMeta));
    }
    if (data.containsKey('box_reading_image')) {
      context.handle(
          _boxReadingImageMeta,
          boxReadingImage.isAcceptableOrUnknown(
              data['box_reading_image']!, _boxReadingImageMeta));
    }
    if (data.containsKey('router_reading_image')) {
      context.handle(
          _routerReadingImageMeta,
          routerReadingImage.isAcceptableOrUnknown(
              data['router_reading_image']!, _routerReadingImageMeta));
    }
    if (data.containsKey('client_signature')) {
      context.handle(
          _clientSignatureMeta,
          clientSignature.isAcceptableOrUnknown(
              data['client_signature']!, _clientSignatureMeta));
    }
    if (data.containsKey('assigned_email')) {
      context.handle(
          _assignedEmailMeta,
          assignedEmail.isAcceptableOrUnknown(
              data['assigned_email']!, _assignedEmailMeta));
    }
    if (data.containsKey('modified_date')) {
      context.handle(
          _modifiedDateMeta,
          modifiedDate.isAcceptableOrUnknown(
              data['modified_date']!, _modifiedDateMeta));
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobOrder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ticketNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ticket_number'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      contactNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_number']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      barangay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barangay']),
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      planName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_name']),
      planId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}plan_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      onsiteStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}onsite_status']),
      onsiteRemarks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}onsite_remarks']),
      opticalPower: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}optical_power']),
      modemRouterSN: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}modem_router_s_n']),
      routerModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}router_model']),
      lcpId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lcp_id']),
      napId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nap_id']),
      portId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}port_id']),
      vlanId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vlan_id']),
      dateInstalled: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_installed']),
      boxReadingImage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}box_reading_image']),
      routerReadingImage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}router_reading_image']),
      clientSignature: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}client_signature']),
      assignedEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assigned_email']),
      modifiedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}modified_date']),
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $JobOrdersTable createAlias(String alias) {
    return $JobOrdersTable(attachedDatabase, alias);
  }
}

class JobOrder extends DataClass implements Insertable<JobOrder> {
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

  /// Email of the technician the office assigned this job to. This is the
  /// column the technician's job history is filtered on.
  final String? assignedEmail;

  /// When the server record was last changed. Orders the history for jobs
  /// that never reached an install date.
  final DateTime? modifiedDate;

  /// The complete record exactly as the API returned it.
  ///
  /// PUT /api/JobOrders/{id} requires all 86 fields of UpdateJobOrderRequest,
  /// but this table models only the subset the app uses. Keeping the original
  /// JSON lets an update send the whole record back with just the changed
  /// fields replaced, instead of blanking out everything it does not model.
  final String? rawJson;
  final bool isSynced;
  final DateTime updatedAt;
  const JobOrder(
      {required this.id,
      required this.ticketNumber,
      required this.customerName,
      this.contactNumber,
      required this.address,
      this.barangay,
      this.city,
      this.planName,
      this.planId,
      required this.status,
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
      this.assignedEmail,
      this.modifiedDate,
      this.rawJson,
      required this.isSynced,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ticket_number'] = Variable<String>(ticketNumber);
    map['customer_name'] = Variable<String>(customerName);
    if (!nullToAbsent || contactNumber != null) {
      map['contact_number'] = Variable<String>(contactNumber);
    }
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || barangay != null) {
      map['barangay'] = Variable<String>(barangay);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || planName != null) {
      map['plan_name'] = Variable<String>(planName);
    }
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<int>(planId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || onsiteStatus != null) {
      map['onsite_status'] = Variable<String>(onsiteStatus);
    }
    if (!nullToAbsent || onsiteRemarks != null) {
      map['onsite_remarks'] = Variable<String>(onsiteRemarks);
    }
    if (!nullToAbsent || opticalPower != null) {
      map['optical_power'] = Variable<double>(opticalPower);
    }
    if (!nullToAbsent || modemRouterSN != null) {
      map['modem_router_s_n'] = Variable<String>(modemRouterSN);
    }
    if (!nullToAbsent || routerModel != null) {
      map['router_model'] = Variable<String>(routerModel);
    }
    if (!nullToAbsent || lcpId != null) {
      map['lcp_id'] = Variable<int>(lcpId);
    }
    if (!nullToAbsent || napId != null) {
      map['nap_id'] = Variable<int>(napId);
    }
    if (!nullToAbsent || portId != null) {
      map['port_id'] = Variable<String>(portId);
    }
    if (!nullToAbsent || vlanId != null) {
      map['vlan_id'] = Variable<int>(vlanId);
    }
    if (!nullToAbsent || dateInstalled != null) {
      map['date_installed'] = Variable<DateTime>(dateInstalled);
    }
    if (!nullToAbsent || boxReadingImage != null) {
      map['box_reading_image'] = Variable<String>(boxReadingImage);
    }
    if (!nullToAbsent || routerReadingImage != null) {
      map['router_reading_image'] = Variable<String>(routerReadingImage);
    }
    if (!nullToAbsent || clientSignature != null) {
      map['client_signature'] = Variable<String>(clientSignature);
    }
    if (!nullToAbsent || assignedEmail != null) {
      map['assigned_email'] = Variable<String>(assignedEmail);
    }
    if (!nullToAbsent || modifiedDate != null) {
      map['modified_date'] = Variable<DateTime>(modifiedDate);
    }
    if (!nullToAbsent || rawJson != null) {
      map['raw_json'] = Variable<String>(rawJson);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JobOrdersCompanion toCompanion(bool nullToAbsent) {
    return JobOrdersCompanion(
      id: Value(id),
      ticketNumber: Value(ticketNumber),
      customerName: Value(customerName),
      contactNumber: contactNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(contactNumber),
      address: Value(address),
      barangay: barangay == null && nullToAbsent
          ? const Value.absent()
          : Value(barangay),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      planName: planName == null && nullToAbsent
          ? const Value.absent()
          : Value(planName),
      planId:
          planId == null && nullToAbsent ? const Value.absent() : Value(planId),
      status: Value(status),
      onsiteStatus: onsiteStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(onsiteStatus),
      onsiteRemarks: onsiteRemarks == null && nullToAbsent
          ? const Value.absent()
          : Value(onsiteRemarks),
      opticalPower: opticalPower == null && nullToAbsent
          ? const Value.absent()
          : Value(opticalPower),
      modemRouterSN: modemRouterSN == null && nullToAbsent
          ? const Value.absent()
          : Value(modemRouterSN),
      routerModel: routerModel == null && nullToAbsent
          ? const Value.absent()
          : Value(routerModel),
      lcpId:
          lcpId == null && nullToAbsent ? const Value.absent() : Value(lcpId),
      napId:
          napId == null && nullToAbsent ? const Value.absent() : Value(napId),
      portId:
          portId == null && nullToAbsent ? const Value.absent() : Value(portId),
      vlanId:
          vlanId == null && nullToAbsent ? const Value.absent() : Value(vlanId),
      dateInstalled: dateInstalled == null && nullToAbsent
          ? const Value.absent()
          : Value(dateInstalled),
      boxReadingImage: boxReadingImage == null && nullToAbsent
          ? const Value.absent()
          : Value(boxReadingImage),
      routerReadingImage: routerReadingImage == null && nullToAbsent
          ? const Value.absent()
          : Value(routerReadingImage),
      clientSignature: clientSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(clientSignature),
      assignedEmail: assignedEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedEmail),
      modifiedDate: modifiedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedDate),
      rawJson: rawJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawJson),
      isSynced: Value(isSynced),
      updatedAt: Value(updatedAt),
    );
  }

  factory JobOrder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobOrder(
      id: serializer.fromJson<int>(json['id']),
      ticketNumber: serializer.fromJson<String>(json['ticketNumber']),
      customerName: serializer.fromJson<String>(json['customerName']),
      contactNumber: serializer.fromJson<String?>(json['contactNumber']),
      address: serializer.fromJson<String>(json['address']),
      barangay: serializer.fromJson<String?>(json['barangay']),
      city: serializer.fromJson<String?>(json['city']),
      planName: serializer.fromJson<String?>(json['planName']),
      planId: serializer.fromJson<int?>(json['planId']),
      status: serializer.fromJson<String>(json['status']),
      onsiteStatus: serializer.fromJson<String?>(json['onsiteStatus']),
      onsiteRemarks: serializer.fromJson<String?>(json['onsiteRemarks']),
      opticalPower: serializer.fromJson<double?>(json['opticalPower']),
      modemRouterSN: serializer.fromJson<String?>(json['modemRouterSN']),
      routerModel: serializer.fromJson<String?>(json['routerModel']),
      lcpId: serializer.fromJson<int?>(json['lcpId']),
      napId: serializer.fromJson<int?>(json['napId']),
      portId: serializer.fromJson<String?>(json['portId']),
      vlanId: serializer.fromJson<int?>(json['vlanId']),
      dateInstalled: serializer.fromJson<DateTime?>(json['dateInstalled']),
      boxReadingImage: serializer.fromJson<String?>(json['boxReadingImage']),
      routerReadingImage:
          serializer.fromJson<String?>(json['routerReadingImage']),
      clientSignature: serializer.fromJson<String?>(json['clientSignature']),
      assignedEmail: serializer.fromJson<String?>(json['assignedEmail']),
      modifiedDate: serializer.fromJson<DateTime?>(json['modifiedDate']),
      rawJson: serializer.fromJson<String?>(json['rawJson']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ticketNumber': serializer.toJson<String>(ticketNumber),
      'customerName': serializer.toJson<String>(customerName),
      'contactNumber': serializer.toJson<String?>(contactNumber),
      'address': serializer.toJson<String>(address),
      'barangay': serializer.toJson<String?>(barangay),
      'city': serializer.toJson<String?>(city),
      'planName': serializer.toJson<String?>(planName),
      'planId': serializer.toJson<int?>(planId),
      'status': serializer.toJson<String>(status),
      'onsiteStatus': serializer.toJson<String?>(onsiteStatus),
      'onsiteRemarks': serializer.toJson<String?>(onsiteRemarks),
      'opticalPower': serializer.toJson<double?>(opticalPower),
      'modemRouterSN': serializer.toJson<String?>(modemRouterSN),
      'routerModel': serializer.toJson<String?>(routerModel),
      'lcpId': serializer.toJson<int?>(lcpId),
      'napId': serializer.toJson<int?>(napId),
      'portId': serializer.toJson<String?>(portId),
      'vlanId': serializer.toJson<int?>(vlanId),
      'dateInstalled': serializer.toJson<DateTime?>(dateInstalled),
      'boxReadingImage': serializer.toJson<String?>(boxReadingImage),
      'routerReadingImage': serializer.toJson<String?>(routerReadingImage),
      'clientSignature': serializer.toJson<String?>(clientSignature),
      'assignedEmail': serializer.toJson<String?>(assignedEmail),
      'modifiedDate': serializer.toJson<DateTime?>(modifiedDate),
      'rawJson': serializer.toJson<String?>(rawJson),
      'isSynced': serializer.toJson<bool>(isSynced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  JobOrder copyWith(
          {int? id,
          String? ticketNumber,
          String? customerName,
          Value<String?> contactNumber = const Value.absent(),
          String? address,
          Value<String?> barangay = const Value.absent(),
          Value<String?> city = const Value.absent(),
          Value<String?> planName = const Value.absent(),
          Value<int?> planId = const Value.absent(),
          String? status,
          Value<String?> onsiteStatus = const Value.absent(),
          Value<String?> onsiteRemarks = const Value.absent(),
          Value<double?> opticalPower = const Value.absent(),
          Value<String?> modemRouterSN = const Value.absent(),
          Value<String?> routerModel = const Value.absent(),
          Value<int?> lcpId = const Value.absent(),
          Value<int?> napId = const Value.absent(),
          Value<String?> portId = const Value.absent(),
          Value<int?> vlanId = const Value.absent(),
          Value<DateTime?> dateInstalled = const Value.absent(),
          Value<String?> boxReadingImage = const Value.absent(),
          Value<String?> routerReadingImage = const Value.absent(),
          Value<String?> clientSignature = const Value.absent(),
          Value<String?> assignedEmail = const Value.absent(),
          Value<DateTime?> modifiedDate = const Value.absent(),
          Value<String?> rawJson = const Value.absent(),
          bool? isSynced,
          DateTime? updatedAt}) =>
      JobOrder(
        id: id ?? this.id,
        ticketNumber: ticketNumber ?? this.ticketNumber,
        customerName: customerName ?? this.customerName,
        contactNumber:
            contactNumber.present ? contactNumber.value : this.contactNumber,
        address: address ?? this.address,
        barangay: barangay.present ? barangay.value : this.barangay,
        city: city.present ? city.value : this.city,
        planName: planName.present ? planName.value : this.planName,
        planId: planId.present ? planId.value : this.planId,
        status: status ?? this.status,
        onsiteStatus:
            onsiteStatus.present ? onsiteStatus.value : this.onsiteStatus,
        onsiteRemarks:
            onsiteRemarks.present ? onsiteRemarks.value : this.onsiteRemarks,
        opticalPower:
            opticalPower.present ? opticalPower.value : this.opticalPower,
        modemRouterSN:
            modemRouterSN.present ? modemRouterSN.value : this.modemRouterSN,
        routerModel: routerModel.present ? routerModel.value : this.routerModel,
        lcpId: lcpId.present ? lcpId.value : this.lcpId,
        napId: napId.present ? napId.value : this.napId,
        portId: portId.present ? portId.value : this.portId,
        vlanId: vlanId.present ? vlanId.value : this.vlanId,
        dateInstalled:
            dateInstalled.present ? dateInstalled.value : this.dateInstalled,
        boxReadingImage: boxReadingImage.present
            ? boxReadingImage.value
            : this.boxReadingImage,
        routerReadingImage: routerReadingImage.present
            ? routerReadingImage.value
            : this.routerReadingImage,
        clientSignature: clientSignature.present
            ? clientSignature.value
            : this.clientSignature,
        assignedEmail:
            assignedEmail.present ? assignedEmail.value : this.assignedEmail,
        modifiedDate:
            modifiedDate.present ? modifiedDate.value : this.modifiedDate,
        rawJson: rawJson.present ? rawJson.value : this.rawJson,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  JobOrder copyWithCompanion(JobOrdersCompanion data) {
    return JobOrder(
      id: data.id.present ? data.id.value : this.id,
      ticketNumber: data.ticketNumber.present
          ? data.ticketNumber.value
          : this.ticketNumber,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      contactNumber: data.contactNumber.present
          ? data.contactNumber.value
          : this.contactNumber,
      address: data.address.present ? data.address.value : this.address,
      barangay: data.barangay.present ? data.barangay.value : this.barangay,
      city: data.city.present ? data.city.value : this.city,
      planName: data.planName.present ? data.planName.value : this.planName,
      planId: data.planId.present ? data.planId.value : this.planId,
      status: data.status.present ? data.status.value : this.status,
      onsiteStatus: data.onsiteStatus.present
          ? data.onsiteStatus.value
          : this.onsiteStatus,
      onsiteRemarks: data.onsiteRemarks.present
          ? data.onsiteRemarks.value
          : this.onsiteRemarks,
      opticalPower: data.opticalPower.present
          ? data.opticalPower.value
          : this.opticalPower,
      modemRouterSN: data.modemRouterSN.present
          ? data.modemRouterSN.value
          : this.modemRouterSN,
      routerModel:
          data.routerModel.present ? data.routerModel.value : this.routerModel,
      lcpId: data.lcpId.present ? data.lcpId.value : this.lcpId,
      napId: data.napId.present ? data.napId.value : this.napId,
      portId: data.portId.present ? data.portId.value : this.portId,
      vlanId: data.vlanId.present ? data.vlanId.value : this.vlanId,
      dateInstalled: data.dateInstalled.present
          ? data.dateInstalled.value
          : this.dateInstalled,
      boxReadingImage: data.boxReadingImage.present
          ? data.boxReadingImage.value
          : this.boxReadingImage,
      routerReadingImage: data.routerReadingImage.present
          ? data.routerReadingImage.value
          : this.routerReadingImage,
      clientSignature: data.clientSignature.present
          ? data.clientSignature.value
          : this.clientSignature,
      assignedEmail: data.assignedEmail.present
          ? data.assignedEmail.value
          : this.assignedEmail,
      modifiedDate: data.modifiedDate.present
          ? data.modifiedDate.value
          : this.modifiedDate,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobOrder(')
          ..write('id: $id, ')
          ..write('ticketNumber: $ticketNumber, ')
          ..write('customerName: $customerName, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('address: $address, ')
          ..write('barangay: $barangay, ')
          ..write('city: $city, ')
          ..write('planName: $planName, ')
          ..write('planId: $planId, ')
          ..write('status: $status, ')
          ..write('onsiteStatus: $onsiteStatus, ')
          ..write('onsiteRemarks: $onsiteRemarks, ')
          ..write('opticalPower: $opticalPower, ')
          ..write('modemRouterSN: $modemRouterSN, ')
          ..write('routerModel: $routerModel, ')
          ..write('lcpId: $lcpId, ')
          ..write('napId: $napId, ')
          ..write('portId: $portId, ')
          ..write('vlanId: $vlanId, ')
          ..write('dateInstalled: $dateInstalled, ')
          ..write('boxReadingImage: $boxReadingImage, ')
          ..write('routerReadingImage: $routerReadingImage, ')
          ..write('clientSignature: $clientSignature, ')
          ..write('assignedEmail: $assignedEmail, ')
          ..write('modifiedDate: $modifiedDate, ')
          ..write('rawJson: $rawJson, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        ticketNumber,
        customerName,
        contactNumber,
        address,
        barangay,
        city,
        planName,
        planId,
        status,
        onsiteStatus,
        onsiteRemarks,
        opticalPower,
        modemRouterSN,
        routerModel,
        lcpId,
        napId,
        portId,
        vlanId,
        dateInstalled,
        boxReadingImage,
        routerReadingImage,
        clientSignature,
        assignedEmail,
        modifiedDate,
        rawJson,
        isSynced,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobOrder &&
          other.id == this.id &&
          other.ticketNumber == this.ticketNumber &&
          other.customerName == this.customerName &&
          other.contactNumber == this.contactNumber &&
          other.address == this.address &&
          other.barangay == this.barangay &&
          other.city == this.city &&
          other.planName == this.planName &&
          other.planId == this.planId &&
          other.status == this.status &&
          other.onsiteStatus == this.onsiteStatus &&
          other.onsiteRemarks == this.onsiteRemarks &&
          other.opticalPower == this.opticalPower &&
          other.modemRouterSN == this.modemRouterSN &&
          other.routerModel == this.routerModel &&
          other.lcpId == this.lcpId &&
          other.napId == this.napId &&
          other.portId == this.portId &&
          other.vlanId == this.vlanId &&
          other.dateInstalled == this.dateInstalled &&
          other.boxReadingImage == this.boxReadingImage &&
          other.routerReadingImage == this.routerReadingImage &&
          other.clientSignature == this.clientSignature &&
          other.assignedEmail == this.assignedEmail &&
          other.modifiedDate == this.modifiedDate &&
          other.rawJson == this.rawJson &&
          other.isSynced == this.isSynced &&
          other.updatedAt == this.updatedAt);
}

class JobOrdersCompanion extends UpdateCompanion<JobOrder> {
  final Value<int> id;
  final Value<String> ticketNumber;
  final Value<String> customerName;
  final Value<String?> contactNumber;
  final Value<String> address;
  final Value<String?> barangay;
  final Value<String?> city;
  final Value<String?> planName;
  final Value<int?> planId;
  final Value<String> status;
  final Value<String?> onsiteStatus;
  final Value<String?> onsiteRemarks;
  final Value<double?> opticalPower;
  final Value<String?> modemRouterSN;
  final Value<String?> routerModel;
  final Value<int?> lcpId;
  final Value<int?> napId;
  final Value<String?> portId;
  final Value<int?> vlanId;
  final Value<DateTime?> dateInstalled;
  final Value<String?> boxReadingImage;
  final Value<String?> routerReadingImage;
  final Value<String?> clientSignature;
  final Value<String?> assignedEmail;
  final Value<DateTime?> modifiedDate;
  final Value<String?> rawJson;
  final Value<bool> isSynced;
  final Value<DateTime> updatedAt;
  const JobOrdersCompanion({
    this.id = const Value.absent(),
    this.ticketNumber = const Value.absent(),
    this.customerName = const Value.absent(),
    this.contactNumber = const Value.absent(),
    this.address = const Value.absent(),
    this.barangay = const Value.absent(),
    this.city = const Value.absent(),
    this.planName = const Value.absent(),
    this.planId = const Value.absent(),
    this.status = const Value.absent(),
    this.onsiteStatus = const Value.absent(),
    this.onsiteRemarks = const Value.absent(),
    this.opticalPower = const Value.absent(),
    this.modemRouterSN = const Value.absent(),
    this.routerModel = const Value.absent(),
    this.lcpId = const Value.absent(),
    this.napId = const Value.absent(),
    this.portId = const Value.absent(),
    this.vlanId = const Value.absent(),
    this.dateInstalled = const Value.absent(),
    this.boxReadingImage = const Value.absent(),
    this.routerReadingImage = const Value.absent(),
    this.clientSignature = const Value.absent(),
    this.assignedEmail = const Value.absent(),
    this.modifiedDate = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  JobOrdersCompanion.insert({
    this.id = const Value.absent(),
    required String ticketNumber,
    required String customerName,
    this.contactNumber = const Value.absent(),
    required String address,
    this.barangay = const Value.absent(),
    this.city = const Value.absent(),
    this.planName = const Value.absent(),
    this.planId = const Value.absent(),
    this.status = const Value.absent(),
    this.onsiteStatus = const Value.absent(),
    this.onsiteRemarks = const Value.absent(),
    this.opticalPower = const Value.absent(),
    this.modemRouterSN = const Value.absent(),
    this.routerModel = const Value.absent(),
    this.lcpId = const Value.absent(),
    this.napId = const Value.absent(),
    this.portId = const Value.absent(),
    this.vlanId = const Value.absent(),
    this.dateInstalled = const Value.absent(),
    this.boxReadingImage = const Value.absent(),
    this.routerReadingImage = const Value.absent(),
    this.clientSignature = const Value.absent(),
    this.assignedEmail = const Value.absent(),
    this.modifiedDate = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : ticketNumber = Value(ticketNumber),
        customerName = Value(customerName),
        address = Value(address);
  static Insertable<JobOrder> custom({
    Expression<int>? id,
    Expression<String>? ticketNumber,
    Expression<String>? customerName,
    Expression<String>? contactNumber,
    Expression<String>? address,
    Expression<String>? barangay,
    Expression<String>? city,
    Expression<String>? planName,
    Expression<int>? planId,
    Expression<String>? status,
    Expression<String>? onsiteStatus,
    Expression<String>? onsiteRemarks,
    Expression<double>? opticalPower,
    Expression<String>? modemRouterSN,
    Expression<String>? routerModel,
    Expression<int>? lcpId,
    Expression<int>? napId,
    Expression<String>? portId,
    Expression<int>? vlanId,
    Expression<DateTime>? dateInstalled,
    Expression<String>? boxReadingImage,
    Expression<String>? routerReadingImage,
    Expression<String>? clientSignature,
    Expression<String>? assignedEmail,
    Expression<DateTime>? modifiedDate,
    Expression<String>? rawJson,
    Expression<bool>? isSynced,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ticketNumber != null) 'ticket_number': ticketNumber,
      if (customerName != null) 'customer_name': customerName,
      if (contactNumber != null) 'contact_number': contactNumber,
      if (address != null) 'address': address,
      if (barangay != null) 'barangay': barangay,
      if (city != null) 'city': city,
      if (planName != null) 'plan_name': planName,
      if (planId != null) 'plan_id': planId,
      if (status != null) 'status': status,
      if (onsiteStatus != null) 'onsite_status': onsiteStatus,
      if (onsiteRemarks != null) 'onsite_remarks': onsiteRemarks,
      if (opticalPower != null) 'optical_power': opticalPower,
      if (modemRouterSN != null) 'modem_router_s_n': modemRouterSN,
      if (routerModel != null) 'router_model': routerModel,
      if (lcpId != null) 'lcp_id': lcpId,
      if (napId != null) 'nap_id': napId,
      if (portId != null) 'port_id': portId,
      if (vlanId != null) 'vlan_id': vlanId,
      if (dateInstalled != null) 'date_installed': dateInstalled,
      if (boxReadingImage != null) 'box_reading_image': boxReadingImage,
      if (routerReadingImage != null)
        'router_reading_image': routerReadingImage,
      if (clientSignature != null) 'client_signature': clientSignature,
      if (assignedEmail != null) 'assigned_email': assignedEmail,
      if (modifiedDate != null) 'modified_date': modifiedDate,
      if (rawJson != null) 'raw_json': rawJson,
      if (isSynced != null) 'is_synced': isSynced,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  JobOrdersCompanion copyWith(
      {Value<int>? id,
      Value<String>? ticketNumber,
      Value<String>? customerName,
      Value<String?>? contactNumber,
      Value<String>? address,
      Value<String?>? barangay,
      Value<String?>? city,
      Value<String?>? planName,
      Value<int?>? planId,
      Value<String>? status,
      Value<String?>? onsiteStatus,
      Value<String?>? onsiteRemarks,
      Value<double?>? opticalPower,
      Value<String?>? modemRouterSN,
      Value<String?>? routerModel,
      Value<int?>? lcpId,
      Value<int?>? napId,
      Value<String?>? portId,
      Value<int?>? vlanId,
      Value<DateTime?>? dateInstalled,
      Value<String?>? boxReadingImage,
      Value<String?>? routerReadingImage,
      Value<String?>? clientSignature,
      Value<String?>? assignedEmail,
      Value<DateTime?>? modifiedDate,
      Value<String?>? rawJson,
      Value<bool>? isSynced,
      Value<DateTime>? updatedAt}) {
    return JobOrdersCompanion(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      customerName: customerName ?? this.customerName,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      barangay: barangay ?? this.barangay,
      city: city ?? this.city,
      planName: planName ?? this.planName,
      planId: planId ?? this.planId,
      status: status ?? this.status,
      onsiteStatus: onsiteStatus ?? this.onsiteStatus,
      onsiteRemarks: onsiteRemarks ?? this.onsiteRemarks,
      opticalPower: opticalPower ?? this.opticalPower,
      modemRouterSN: modemRouterSN ?? this.modemRouterSN,
      routerModel: routerModel ?? this.routerModel,
      lcpId: lcpId ?? this.lcpId,
      napId: napId ?? this.napId,
      portId: portId ?? this.portId,
      vlanId: vlanId ?? this.vlanId,
      dateInstalled: dateInstalled ?? this.dateInstalled,
      boxReadingImage: boxReadingImage ?? this.boxReadingImage,
      routerReadingImage: routerReadingImage ?? this.routerReadingImage,
      clientSignature: clientSignature ?? this.clientSignature,
      assignedEmail: assignedEmail ?? this.assignedEmail,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      rawJson: rawJson ?? this.rawJson,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ticketNumber.present) {
      map['ticket_number'] = Variable<String>(ticketNumber.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (contactNumber.present) {
      map['contact_number'] = Variable<String>(contactNumber.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (barangay.present) {
      map['barangay'] = Variable<String>(barangay.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (planName.present) {
      map['plan_name'] = Variable<String>(planName.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (onsiteStatus.present) {
      map['onsite_status'] = Variable<String>(onsiteStatus.value);
    }
    if (onsiteRemarks.present) {
      map['onsite_remarks'] = Variable<String>(onsiteRemarks.value);
    }
    if (opticalPower.present) {
      map['optical_power'] = Variable<double>(opticalPower.value);
    }
    if (modemRouterSN.present) {
      map['modem_router_s_n'] = Variable<String>(modemRouterSN.value);
    }
    if (routerModel.present) {
      map['router_model'] = Variable<String>(routerModel.value);
    }
    if (lcpId.present) {
      map['lcp_id'] = Variable<int>(lcpId.value);
    }
    if (napId.present) {
      map['nap_id'] = Variable<int>(napId.value);
    }
    if (portId.present) {
      map['port_id'] = Variable<String>(portId.value);
    }
    if (vlanId.present) {
      map['vlan_id'] = Variable<int>(vlanId.value);
    }
    if (dateInstalled.present) {
      map['date_installed'] = Variable<DateTime>(dateInstalled.value);
    }
    if (boxReadingImage.present) {
      map['box_reading_image'] = Variable<String>(boxReadingImage.value);
    }
    if (routerReadingImage.present) {
      map['router_reading_image'] = Variable<String>(routerReadingImage.value);
    }
    if (clientSignature.present) {
      map['client_signature'] = Variable<String>(clientSignature.value);
    }
    if (assignedEmail.present) {
      map['assigned_email'] = Variable<String>(assignedEmail.value);
    }
    if (modifiedDate.present) {
      map['modified_date'] = Variable<DateTime>(modifiedDate.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobOrdersCompanion(')
          ..write('id: $id, ')
          ..write('ticketNumber: $ticketNumber, ')
          ..write('customerName: $customerName, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('address: $address, ')
          ..write('barangay: $barangay, ')
          ..write('city: $city, ')
          ..write('planName: $planName, ')
          ..write('planId: $planId, ')
          ..write('status: $status, ')
          ..write('onsiteStatus: $onsiteStatus, ')
          ..write('onsiteRemarks: $onsiteRemarks, ')
          ..write('opticalPower: $opticalPower, ')
          ..write('modemRouterSN: $modemRouterSN, ')
          ..write('routerModel: $routerModel, ')
          ..write('lcpId: $lcpId, ')
          ..write('napId: $napId, ')
          ..write('portId: $portId, ')
          ..write('vlanId: $vlanId, ')
          ..write('dateInstalled: $dateInstalled, ')
          ..write('boxReadingImage: $boxReadingImage, ')
          ..write('routerReadingImage: $routerReadingImage, ')
          ..write('clientSignature: $clientSignature, ')
          ..write('assignedEmail: $assignedEmail, ')
          ..write('modifiedDate: $modifiedDate, ')
          ..write('rawJson: $rawJson, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncQueuesTable extends SyncQueues
    with TableInfo<$SyncQueuesTable, SyncQueue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, entityType, entityId, payload, action, retryCount, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queues';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueue> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueue(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}entity_id'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncQueuesTable createAlias(String alias) {
    return $SyncQueuesTable(attachedDatabase, alias);
  }
}

class SyncQueue extends DataClass implements Insertable<SyncQueue> {
  final int id;
  final String entityType;
  final int entityId;
  final String payload;
  final String action;
  final int retryCount;
  final DateTime createdAt;
  const SyncQueue(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.payload,
      required this.action,
      required this.retryCount,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<int>(entityId);
    map['payload'] = Variable<String>(payload);
    map['action'] = Variable<String>(action);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueuesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueuesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      payload: Value(payload),
      action: Value(action),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueue.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueue(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<int>(json['entityId']),
      payload: serializer.fromJson<String>(json['payload']),
      action: serializer.fromJson<String>(json['action']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<int>(entityId),
      'payload': serializer.toJson<String>(payload),
      'action': serializer.toJson<String>(action),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueue copyWith(
          {int? id,
          String? entityType,
          int? entityId,
          String? payload,
          String? action,
          int? retryCount,
          DateTime? createdAt}) =>
      SyncQueue(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        payload: payload ?? this.payload,
        action: action ?? this.action,
        retryCount: retryCount ?? this.retryCount,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncQueue copyWithCompanion(SyncQueuesCompanion data) {
    return SyncQueue(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      action: data.action.present ? data.action.value : this.action,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueue(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('action: $action, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entityType, entityId, payload, action, retryCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueue &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.payload == this.payload &&
          other.action == this.action &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt);
}

class SyncQueuesCompanion extends UpdateCompanion<SyncQueue> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<int> entityId;
  final Value<String> payload;
  final Value<String> action;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  const SyncQueuesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.action = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueuesCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required int entityId,
    required String payload,
    required String action,
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : entityType = Value(entityType),
        entityId = Value(entityId),
        payload = Value(payload),
        action = Value(action);
  static Insertable<SyncQueue> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<int>? entityId,
    Expression<String>? payload,
    Expression<String>? action,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (payload != null) 'payload': payload,
      if (action != null) 'action': action,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueuesCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<int>? entityId,
      Value<String>? payload,
      Value<String>? action,
      Value<int>? retryCount,
      Value<DateTime>? createdAt}) {
    return SyncQueuesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      action: action ?? this.action,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueuesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('action: $action, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LcpNapLocationsTable extends LcpNapLocations
    with TableInfo<$LcpNapLocationsTable, LcpNapLocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LcpNapLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lcpMeta = const VerificationMeta('lcp');
  @override
  late final GeneratedColumn<String> lcp = GeneratedColumn<String>(
      'lcp', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _napMeta = const VerificationMeta('nap');
  @override
  late final GeneratedColumn<String> nap = GeneratedColumn<String>(
      'nap', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lcpNapMeta = const VerificationMeta('lcpNap');
  @override
  late final GeneratedColumn<String> lcpNap = GeneratedColumn<String>(
      'lcp_nap', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _portTotalMeta =
      const VerificationMeta('portTotal');
  @override
  late final GeneratedColumn<int> portTotal = GeneratedColumn<int>(
      'port_total', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(8));
  static const VerificationMeta _coordinatesMeta =
      const VerificationMeta('coordinates');
  @override
  late final GeneratedColumn<String> coordinates = GeneratedColumn<String>(
      'coordinates', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _streetMeta = const VerificationMeta('street');
  @override
  late final GeneratedColumn<String> street = GeneratedColumn<String>(
      'street', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _barangayMeta =
      const VerificationMeta('barangay');
  @override
  late final GeneratedColumn<String> barangay = GeneratedColumn<String>(
      'barangay', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
      'region', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _image2Meta = const VerificationMeta('image2');
  @override
  late final GeneratedColumn<String> image2 = GeneratedColumn<String>(
      'image2', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _readingImageMeta =
      const VerificationMeta('readingImage');
  @override
  late final GeneratedColumn<String> readingImage = GeneratedColumn<String>(
      'reading_image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modifiedByMeta =
      const VerificationMeta('modifiedBy');
  @override
  late final GeneratedColumn<String> modifiedBy = GeneratedColumn<String>(
      'modified_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userEmailMeta =
      const VerificationMeta('userEmail');
  @override
  late final GeneratedColumn<String> userEmail = GeneratedColumn<String>(
      'user_email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _modifiedDateMeta =
      const VerificationMeta('modifiedDate');
  @override
  late final GeneratedColumn<DateTime> modifiedDate = GeneratedColumn<DateTime>(
      'modified_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        lcp,
        nap,
        lcpNap,
        portTotal,
        coordinates,
        street,
        barangay,
        city,
        region,
        image,
        image2,
        readingImage,
        modifiedBy,
        userEmail,
        modifiedDate,
        isSynced,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lcp_nap_locations';
  @override
  VerificationContext validateIntegrity(Insertable<LcpNapLocation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lcp')) {
      context.handle(
          _lcpMeta, lcp.isAcceptableOrUnknown(data['lcp']!, _lcpMeta));
    } else if (isInserting) {
      context.missing(_lcpMeta);
    }
    if (data.containsKey('nap')) {
      context.handle(
          _napMeta, nap.isAcceptableOrUnknown(data['nap']!, _napMeta));
    } else if (isInserting) {
      context.missing(_napMeta);
    }
    if (data.containsKey('lcp_nap')) {
      context.handle(_lcpNapMeta,
          lcpNap.isAcceptableOrUnknown(data['lcp_nap']!, _lcpNapMeta));
    } else if (isInserting) {
      context.missing(_lcpNapMeta);
    }
    if (data.containsKey('port_total')) {
      context.handle(_portTotalMeta,
          portTotal.isAcceptableOrUnknown(data['port_total']!, _portTotalMeta));
    }
    if (data.containsKey('coordinates')) {
      context.handle(
          _coordinatesMeta,
          coordinates.isAcceptableOrUnknown(
              data['coordinates']!, _coordinatesMeta));
    }
    if (data.containsKey('street')) {
      context.handle(_streetMeta,
          street.isAcceptableOrUnknown(data['street']!, _streetMeta));
    }
    if (data.containsKey('barangay')) {
      context.handle(_barangayMeta,
          barangay.isAcceptableOrUnknown(data['barangay']!, _barangayMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('region')) {
      context.handle(_regionMeta,
          region.isAcceptableOrUnknown(data['region']!, _regionMeta));
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    }
    if (data.containsKey('image2')) {
      context.handle(_image2Meta,
          image2.isAcceptableOrUnknown(data['image2']!, _image2Meta));
    }
    if (data.containsKey('reading_image')) {
      context.handle(
          _readingImageMeta,
          readingImage.isAcceptableOrUnknown(
              data['reading_image']!, _readingImageMeta));
    }
    if (data.containsKey('modified_by')) {
      context.handle(
          _modifiedByMeta,
          modifiedBy.isAcceptableOrUnknown(
              data['modified_by']!, _modifiedByMeta));
    }
    if (data.containsKey('user_email')) {
      context.handle(_userEmailMeta,
          userEmail.isAcceptableOrUnknown(data['user_email']!, _userEmailMeta));
    }
    if (data.containsKey('modified_date')) {
      context.handle(
          _modifiedDateMeta,
          modifiedDate.isAcceptableOrUnknown(
              data['modified_date']!, _modifiedDateMeta));
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LcpNapLocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LcpNapLocation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      lcp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lcp'])!,
      nap: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nap'])!,
      lcpNap: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lcp_nap'])!,
      portTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}port_total'])!,
      coordinates: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}coordinates']),
      street: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}street']),
      barangay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barangay']),
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      region: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}region']),
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image']),
      image2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image2']),
      readingImage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reading_image']),
      modifiedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}modified_by']),
      userEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_email']),
      modifiedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}modified_date']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LcpNapLocationsTable createAlias(String alias) {
    return $LcpNapLocationsTable(attachedDatabase, alias);
  }
}

class LcpNapLocation extends DataClass implements Insertable<LcpNapLocation> {
  final int id;
  final String lcp;
  final String nap;
  final String lcpNap;
  final int portTotal;
  final String? coordinates;
  final String? street;
  final String? barangay;
  final String? city;
  final String? region;

  /// Photo paths as the API stores them. These are relative paths, not URLs,
  /// and no public base URL is known yet, so they are persisted but not shown.
  final String? image;
  final String? image2;
  final String? readingImage;

  /// Who last touched the record on the server, and when.
  final String? modifiedBy;
  final String? userEmail;
  final DateTime? modifiedDate;
  final bool isSynced;
  final DateTime updatedAt;
  const LcpNapLocation(
      {required this.id,
      required this.lcp,
      required this.nap,
      required this.lcpNap,
      required this.portTotal,
      this.coordinates,
      this.street,
      this.barangay,
      this.city,
      this.region,
      this.image,
      this.image2,
      this.readingImage,
      this.modifiedBy,
      this.userEmail,
      this.modifiedDate,
      required this.isSynced,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lcp'] = Variable<String>(lcp);
    map['nap'] = Variable<String>(nap);
    map['lcp_nap'] = Variable<String>(lcpNap);
    map['port_total'] = Variable<int>(portTotal);
    if (!nullToAbsent || coordinates != null) {
      map['coordinates'] = Variable<String>(coordinates);
    }
    if (!nullToAbsent || street != null) {
      map['street'] = Variable<String>(street);
    }
    if (!nullToAbsent || barangay != null) {
      map['barangay'] = Variable<String>(barangay);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<String>(image);
    }
    if (!nullToAbsent || image2 != null) {
      map['image2'] = Variable<String>(image2);
    }
    if (!nullToAbsent || readingImage != null) {
      map['reading_image'] = Variable<String>(readingImage);
    }
    if (!nullToAbsent || modifiedBy != null) {
      map['modified_by'] = Variable<String>(modifiedBy);
    }
    if (!nullToAbsent || userEmail != null) {
      map['user_email'] = Variable<String>(userEmail);
    }
    if (!nullToAbsent || modifiedDate != null) {
      map['modified_date'] = Variable<DateTime>(modifiedDate);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LcpNapLocationsCompanion toCompanion(bool nullToAbsent) {
    return LcpNapLocationsCompanion(
      id: Value(id),
      lcp: Value(lcp),
      nap: Value(nap),
      lcpNap: Value(lcpNap),
      portTotal: Value(portTotal),
      coordinates: coordinates == null && nullToAbsent
          ? const Value.absent()
          : Value(coordinates),
      street:
          street == null && nullToAbsent ? const Value.absent() : Value(street),
      barangay: barangay == null && nullToAbsent
          ? const Value.absent()
          : Value(barangay),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      region:
          region == null && nullToAbsent ? const Value.absent() : Value(region),
      image:
          image == null && nullToAbsent ? const Value.absent() : Value(image),
      image2:
          image2 == null && nullToAbsent ? const Value.absent() : Value(image2),
      readingImage: readingImage == null && nullToAbsent
          ? const Value.absent()
          : Value(readingImage),
      modifiedBy: modifiedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedBy),
      userEmail: userEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(userEmail),
      modifiedDate: modifiedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedDate),
      isSynced: Value(isSynced),
      updatedAt: Value(updatedAt),
    );
  }

  factory LcpNapLocation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LcpNapLocation(
      id: serializer.fromJson<int>(json['id']),
      lcp: serializer.fromJson<String>(json['lcp']),
      nap: serializer.fromJson<String>(json['nap']),
      lcpNap: serializer.fromJson<String>(json['lcpNap']),
      portTotal: serializer.fromJson<int>(json['portTotal']),
      coordinates: serializer.fromJson<String?>(json['coordinates']),
      street: serializer.fromJson<String?>(json['street']),
      barangay: serializer.fromJson<String?>(json['barangay']),
      city: serializer.fromJson<String?>(json['city']),
      region: serializer.fromJson<String?>(json['region']),
      image: serializer.fromJson<String?>(json['image']),
      image2: serializer.fromJson<String?>(json['image2']),
      readingImage: serializer.fromJson<String?>(json['readingImage']),
      modifiedBy: serializer.fromJson<String?>(json['modifiedBy']),
      userEmail: serializer.fromJson<String?>(json['userEmail']),
      modifiedDate: serializer.fromJson<DateTime?>(json['modifiedDate']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lcp': serializer.toJson<String>(lcp),
      'nap': serializer.toJson<String>(nap),
      'lcpNap': serializer.toJson<String>(lcpNap),
      'portTotal': serializer.toJson<int>(portTotal),
      'coordinates': serializer.toJson<String?>(coordinates),
      'street': serializer.toJson<String?>(street),
      'barangay': serializer.toJson<String?>(barangay),
      'city': serializer.toJson<String?>(city),
      'region': serializer.toJson<String?>(region),
      'image': serializer.toJson<String?>(image),
      'image2': serializer.toJson<String?>(image2),
      'readingImage': serializer.toJson<String?>(readingImage),
      'modifiedBy': serializer.toJson<String?>(modifiedBy),
      'userEmail': serializer.toJson<String?>(userEmail),
      'modifiedDate': serializer.toJson<DateTime?>(modifiedDate),
      'isSynced': serializer.toJson<bool>(isSynced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LcpNapLocation copyWith(
          {int? id,
          String? lcp,
          String? nap,
          String? lcpNap,
          int? portTotal,
          Value<String?> coordinates = const Value.absent(),
          Value<String?> street = const Value.absent(),
          Value<String?> barangay = const Value.absent(),
          Value<String?> city = const Value.absent(),
          Value<String?> region = const Value.absent(),
          Value<String?> image = const Value.absent(),
          Value<String?> image2 = const Value.absent(),
          Value<String?> readingImage = const Value.absent(),
          Value<String?> modifiedBy = const Value.absent(),
          Value<String?> userEmail = const Value.absent(),
          Value<DateTime?> modifiedDate = const Value.absent(),
          bool? isSynced,
          DateTime? updatedAt}) =>
      LcpNapLocation(
        id: id ?? this.id,
        lcp: lcp ?? this.lcp,
        nap: nap ?? this.nap,
        lcpNap: lcpNap ?? this.lcpNap,
        portTotal: portTotal ?? this.portTotal,
        coordinates: coordinates.present ? coordinates.value : this.coordinates,
        street: street.present ? street.value : this.street,
        barangay: barangay.present ? barangay.value : this.barangay,
        city: city.present ? city.value : this.city,
        region: region.present ? region.value : this.region,
        image: image.present ? image.value : this.image,
        image2: image2.present ? image2.value : this.image2,
        readingImage:
            readingImage.present ? readingImage.value : this.readingImage,
        modifiedBy: modifiedBy.present ? modifiedBy.value : this.modifiedBy,
        userEmail: userEmail.present ? userEmail.value : this.userEmail,
        modifiedDate:
            modifiedDate.present ? modifiedDate.value : this.modifiedDate,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LcpNapLocation copyWithCompanion(LcpNapLocationsCompanion data) {
    return LcpNapLocation(
      id: data.id.present ? data.id.value : this.id,
      lcp: data.lcp.present ? data.lcp.value : this.lcp,
      nap: data.nap.present ? data.nap.value : this.nap,
      lcpNap: data.lcpNap.present ? data.lcpNap.value : this.lcpNap,
      portTotal: data.portTotal.present ? data.portTotal.value : this.portTotal,
      coordinates:
          data.coordinates.present ? data.coordinates.value : this.coordinates,
      street: data.street.present ? data.street.value : this.street,
      barangay: data.barangay.present ? data.barangay.value : this.barangay,
      city: data.city.present ? data.city.value : this.city,
      region: data.region.present ? data.region.value : this.region,
      image: data.image.present ? data.image.value : this.image,
      image2: data.image2.present ? data.image2.value : this.image2,
      readingImage: data.readingImage.present
          ? data.readingImage.value
          : this.readingImage,
      modifiedBy:
          data.modifiedBy.present ? data.modifiedBy.value : this.modifiedBy,
      userEmail: data.userEmail.present ? data.userEmail.value : this.userEmail,
      modifiedDate: data.modifiedDate.present
          ? data.modifiedDate.value
          : this.modifiedDate,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LcpNapLocation(')
          ..write('id: $id, ')
          ..write('lcp: $lcp, ')
          ..write('nap: $nap, ')
          ..write('lcpNap: $lcpNap, ')
          ..write('portTotal: $portTotal, ')
          ..write('coordinates: $coordinates, ')
          ..write('street: $street, ')
          ..write('barangay: $barangay, ')
          ..write('city: $city, ')
          ..write('region: $region, ')
          ..write('image: $image, ')
          ..write('image2: $image2, ')
          ..write('readingImage: $readingImage, ')
          ..write('modifiedBy: $modifiedBy, ')
          ..write('userEmail: $userEmail, ')
          ..write('modifiedDate: $modifiedDate, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      lcp,
      nap,
      lcpNap,
      portTotal,
      coordinates,
      street,
      barangay,
      city,
      region,
      image,
      image2,
      readingImage,
      modifiedBy,
      userEmail,
      modifiedDate,
      isSynced,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LcpNapLocation &&
          other.id == this.id &&
          other.lcp == this.lcp &&
          other.nap == this.nap &&
          other.lcpNap == this.lcpNap &&
          other.portTotal == this.portTotal &&
          other.coordinates == this.coordinates &&
          other.street == this.street &&
          other.barangay == this.barangay &&
          other.city == this.city &&
          other.region == this.region &&
          other.image == this.image &&
          other.image2 == this.image2 &&
          other.readingImage == this.readingImage &&
          other.modifiedBy == this.modifiedBy &&
          other.userEmail == this.userEmail &&
          other.modifiedDate == this.modifiedDate &&
          other.isSynced == this.isSynced &&
          other.updatedAt == this.updatedAt);
}

class LcpNapLocationsCompanion extends UpdateCompanion<LcpNapLocation> {
  final Value<int> id;
  final Value<String> lcp;
  final Value<String> nap;
  final Value<String> lcpNap;
  final Value<int> portTotal;
  final Value<String?> coordinates;
  final Value<String?> street;
  final Value<String?> barangay;
  final Value<String?> city;
  final Value<String?> region;
  final Value<String?> image;
  final Value<String?> image2;
  final Value<String?> readingImage;
  final Value<String?> modifiedBy;
  final Value<String?> userEmail;
  final Value<DateTime?> modifiedDate;
  final Value<bool> isSynced;
  final Value<DateTime> updatedAt;
  const LcpNapLocationsCompanion({
    this.id = const Value.absent(),
    this.lcp = const Value.absent(),
    this.nap = const Value.absent(),
    this.lcpNap = const Value.absent(),
    this.portTotal = const Value.absent(),
    this.coordinates = const Value.absent(),
    this.street = const Value.absent(),
    this.barangay = const Value.absent(),
    this.city = const Value.absent(),
    this.region = const Value.absent(),
    this.image = const Value.absent(),
    this.image2 = const Value.absent(),
    this.readingImage = const Value.absent(),
    this.modifiedBy = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.modifiedDate = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LcpNapLocationsCompanion.insert({
    this.id = const Value.absent(),
    required String lcp,
    required String nap,
    required String lcpNap,
    this.portTotal = const Value.absent(),
    this.coordinates = const Value.absent(),
    this.street = const Value.absent(),
    this.barangay = const Value.absent(),
    this.city = const Value.absent(),
    this.region = const Value.absent(),
    this.image = const Value.absent(),
    this.image2 = const Value.absent(),
    this.readingImage = const Value.absent(),
    this.modifiedBy = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.modifiedDate = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : lcp = Value(lcp),
        nap = Value(nap),
        lcpNap = Value(lcpNap);
  static Insertable<LcpNapLocation> custom({
    Expression<int>? id,
    Expression<String>? lcp,
    Expression<String>? nap,
    Expression<String>? lcpNap,
    Expression<int>? portTotal,
    Expression<String>? coordinates,
    Expression<String>? street,
    Expression<String>? barangay,
    Expression<String>? city,
    Expression<String>? region,
    Expression<String>? image,
    Expression<String>? image2,
    Expression<String>? readingImage,
    Expression<String>? modifiedBy,
    Expression<String>? userEmail,
    Expression<DateTime>? modifiedDate,
    Expression<bool>? isSynced,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lcp != null) 'lcp': lcp,
      if (nap != null) 'nap': nap,
      if (lcpNap != null) 'lcp_nap': lcpNap,
      if (portTotal != null) 'port_total': portTotal,
      if (coordinates != null) 'coordinates': coordinates,
      if (street != null) 'street': street,
      if (barangay != null) 'barangay': barangay,
      if (city != null) 'city': city,
      if (region != null) 'region': region,
      if (image != null) 'image': image,
      if (image2 != null) 'image2': image2,
      if (readingImage != null) 'reading_image': readingImage,
      if (modifiedBy != null) 'modified_by': modifiedBy,
      if (userEmail != null) 'user_email': userEmail,
      if (modifiedDate != null) 'modified_date': modifiedDate,
      if (isSynced != null) 'is_synced': isSynced,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LcpNapLocationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? lcp,
      Value<String>? nap,
      Value<String>? lcpNap,
      Value<int>? portTotal,
      Value<String?>? coordinates,
      Value<String?>? street,
      Value<String?>? barangay,
      Value<String?>? city,
      Value<String?>? region,
      Value<String?>? image,
      Value<String?>? image2,
      Value<String?>? readingImage,
      Value<String?>? modifiedBy,
      Value<String?>? userEmail,
      Value<DateTime?>? modifiedDate,
      Value<bool>? isSynced,
      Value<DateTime>? updatedAt}) {
    return LcpNapLocationsCompanion(
      id: id ?? this.id,
      lcp: lcp ?? this.lcp,
      nap: nap ?? this.nap,
      lcpNap: lcpNap ?? this.lcpNap,
      portTotal: portTotal ?? this.portTotal,
      coordinates: coordinates ?? this.coordinates,
      street: street ?? this.street,
      barangay: barangay ?? this.barangay,
      city: city ?? this.city,
      region: region ?? this.region,
      image: image ?? this.image,
      image2: image2 ?? this.image2,
      readingImage: readingImage ?? this.readingImage,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      userEmail: userEmail ?? this.userEmail,
      modifiedDate: modifiedDate ?? this.modifiedDate,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lcp.present) {
      map['lcp'] = Variable<String>(lcp.value);
    }
    if (nap.present) {
      map['nap'] = Variable<String>(nap.value);
    }
    if (lcpNap.present) {
      map['lcp_nap'] = Variable<String>(lcpNap.value);
    }
    if (portTotal.present) {
      map['port_total'] = Variable<int>(portTotal.value);
    }
    if (coordinates.present) {
      map['coordinates'] = Variable<String>(coordinates.value);
    }
    if (street.present) {
      map['street'] = Variable<String>(street.value);
    }
    if (barangay.present) {
      map['barangay'] = Variable<String>(barangay.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (image2.present) {
      map['image2'] = Variable<String>(image2.value);
    }
    if (readingImage.present) {
      map['reading_image'] = Variable<String>(readingImage.value);
    }
    if (modifiedBy.present) {
      map['modified_by'] = Variable<String>(modifiedBy.value);
    }
    if (userEmail.present) {
      map['user_email'] = Variable<String>(userEmail.value);
    }
    if (modifiedDate.present) {
      map['modified_date'] = Variable<DateTime>(modifiedDate.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LcpNapLocationsCompanion(')
          ..write('id: $id, ')
          ..write('lcp: $lcp, ')
          ..write('nap: $nap, ')
          ..write('lcpNap: $lcpNap, ')
          ..write('portTotal: $portTotal, ')
          ..write('coordinates: $coordinates, ')
          ..write('street: $street, ')
          ..write('barangay: $barangay, ')
          ..write('city: $city, ')
          ..write('region: $region, ')
          ..write('image: $image, ')
          ..write('image2: $image2, ')
          ..write('readingImage: $readingImage, ')
          ..write('modifiedBy: $modifiedBy, ')
          ..write('userEmail: $userEmail, ')
          ..write('modifiedDate: $modifiedDate, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JobOrdersTable jobOrders = $JobOrdersTable(this);
  late final $SyncQueuesTable syncQueues = $SyncQueuesTable(this);
  late final $LcpNapLocationsTable lcpNapLocations =
      $LcpNapLocationsTable(this);
  late final JobOrdersDao jobOrdersDao = JobOrdersDao(this as AppDatabase);
  late final LcpNapLocationsDao lcpNapLocationsDao =
      LcpNapLocationsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [jobOrders, syncQueues, lcpNapLocations];
}

typedef $$JobOrdersTableCreateCompanionBuilder = JobOrdersCompanion Function({
  Value<int> id,
  required String ticketNumber,
  required String customerName,
  Value<String?> contactNumber,
  required String address,
  Value<String?> barangay,
  Value<String?> city,
  Value<String?> planName,
  Value<int?> planId,
  Value<String> status,
  Value<String?> onsiteStatus,
  Value<String?> onsiteRemarks,
  Value<double?> opticalPower,
  Value<String?> modemRouterSN,
  Value<String?> routerModel,
  Value<int?> lcpId,
  Value<int?> napId,
  Value<String?> portId,
  Value<int?> vlanId,
  Value<DateTime?> dateInstalled,
  Value<String?> boxReadingImage,
  Value<String?> routerReadingImage,
  Value<String?> clientSignature,
  Value<String?> assignedEmail,
  Value<DateTime?> modifiedDate,
  Value<String?> rawJson,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});
typedef $$JobOrdersTableUpdateCompanionBuilder = JobOrdersCompanion Function({
  Value<int> id,
  Value<String> ticketNumber,
  Value<String> customerName,
  Value<String?> contactNumber,
  Value<String> address,
  Value<String?> barangay,
  Value<String?> city,
  Value<String?> planName,
  Value<int?> planId,
  Value<String> status,
  Value<String?> onsiteStatus,
  Value<String?> onsiteRemarks,
  Value<double?> opticalPower,
  Value<String?> modemRouterSN,
  Value<String?> routerModel,
  Value<int?> lcpId,
  Value<int?> napId,
  Value<String?> portId,
  Value<int?> vlanId,
  Value<DateTime?> dateInstalled,
  Value<String?> boxReadingImage,
  Value<String?> routerReadingImage,
  Value<String?> clientSignature,
  Value<String?> assignedEmail,
  Value<DateTime?> modifiedDate,
  Value<String?> rawJson,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});

class $$JobOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $JobOrdersTable> {
  $$JobOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ticketNumber => $composableBuilder(
      column: $table.ticketNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactNumber => $composableBuilder(
      column: $table.contactNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barangay => $composableBuilder(
      column: $table.barangay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get planName => $composableBuilder(
      column: $table.planName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get planId => $composableBuilder(
      column: $table.planId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onsiteStatus => $composableBuilder(
      column: $table.onsiteStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onsiteRemarks => $composableBuilder(
      column: $table.onsiteRemarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get opticalPower => $composableBuilder(
      column: $table.opticalPower, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modemRouterSN => $composableBuilder(
      column: $table.modemRouterSN, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routerModel => $composableBuilder(
      column: $table.routerModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lcpId => $composableBuilder(
      column: $table.lcpId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get napId => $composableBuilder(
      column: $table.napId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get portId => $composableBuilder(
      column: $table.portId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vlanId => $composableBuilder(
      column: $table.vlanId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateInstalled => $composableBuilder(
      column: $table.dateInstalled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boxReadingImage => $composableBuilder(
      column: $table.boxReadingImage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routerReadingImage => $composableBuilder(
      column: $table.routerReadingImage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientSignature => $composableBuilder(
      column: $table.clientSignature,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assignedEmail => $composableBuilder(
      column: $table.assignedEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get modifiedDate => $composableBuilder(
      column: $table.modifiedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$JobOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $JobOrdersTable> {
  $$JobOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ticketNumber => $composableBuilder(
      column: $table.ticketNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactNumber => $composableBuilder(
      column: $table.contactNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barangay => $composableBuilder(
      column: $table.barangay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get planName => $composableBuilder(
      column: $table.planName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get planId => $composableBuilder(
      column: $table.planId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onsiteStatus => $composableBuilder(
      column: $table.onsiteStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onsiteRemarks => $composableBuilder(
      column: $table.onsiteRemarks,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get opticalPower => $composableBuilder(
      column: $table.opticalPower,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modemRouterSN => $composableBuilder(
      column: $table.modemRouterSN,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routerModel => $composableBuilder(
      column: $table.routerModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lcpId => $composableBuilder(
      column: $table.lcpId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get napId => $composableBuilder(
      column: $table.napId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get portId => $composableBuilder(
      column: $table.portId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get vlanId => $composableBuilder(
      column: $table.vlanId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateInstalled => $composableBuilder(
      column: $table.dateInstalled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boxReadingImage => $composableBuilder(
      column: $table.boxReadingImage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routerReadingImage => $composableBuilder(
      column: $table.routerReadingImage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientSignature => $composableBuilder(
      column: $table.clientSignature,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assignedEmail => $composableBuilder(
      column: $table.assignedEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get modifiedDate => $composableBuilder(
      column: $table.modifiedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$JobOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobOrdersTable> {
  $$JobOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ticketNumber => $composableBuilder(
      column: $table.ticketNumber, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get contactNumber => $composableBuilder(
      column: $table.contactNumber, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get barangay =>
      $composableBuilder(column: $table.barangay, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get planName =>
      $composableBuilder(column: $table.planName, builder: (column) => column);

  GeneratedColumn<int> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get onsiteStatus => $composableBuilder(
      column: $table.onsiteStatus, builder: (column) => column);

  GeneratedColumn<String> get onsiteRemarks => $composableBuilder(
      column: $table.onsiteRemarks, builder: (column) => column);

  GeneratedColumn<double> get opticalPower => $composableBuilder(
      column: $table.opticalPower, builder: (column) => column);

  GeneratedColumn<String> get modemRouterSN => $composableBuilder(
      column: $table.modemRouterSN, builder: (column) => column);

  GeneratedColumn<String> get routerModel => $composableBuilder(
      column: $table.routerModel, builder: (column) => column);

  GeneratedColumn<int> get lcpId =>
      $composableBuilder(column: $table.lcpId, builder: (column) => column);

  GeneratedColumn<int> get napId =>
      $composableBuilder(column: $table.napId, builder: (column) => column);

  GeneratedColumn<String> get portId =>
      $composableBuilder(column: $table.portId, builder: (column) => column);

  GeneratedColumn<int> get vlanId =>
      $composableBuilder(column: $table.vlanId, builder: (column) => column);

  GeneratedColumn<DateTime> get dateInstalled => $composableBuilder(
      column: $table.dateInstalled, builder: (column) => column);

  GeneratedColumn<String> get boxReadingImage => $composableBuilder(
      column: $table.boxReadingImage, builder: (column) => column);

  GeneratedColumn<String> get routerReadingImage => $composableBuilder(
      column: $table.routerReadingImage, builder: (column) => column);

  GeneratedColumn<String> get clientSignature => $composableBuilder(
      column: $table.clientSignature, builder: (column) => column);

  GeneratedColumn<String> get assignedEmail => $composableBuilder(
      column: $table.assignedEmail, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedDate => $composableBuilder(
      column: $table.modifiedDate, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$JobOrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $JobOrdersTable,
    JobOrder,
    $$JobOrdersTableFilterComposer,
    $$JobOrdersTableOrderingComposer,
    $$JobOrdersTableAnnotationComposer,
    $$JobOrdersTableCreateCompanionBuilder,
    $$JobOrdersTableUpdateCompanionBuilder,
    (JobOrder, BaseReferences<_$AppDatabase, $JobOrdersTable, JobOrder>),
    JobOrder,
    PrefetchHooks Function()> {
  $$JobOrdersTableTableManager(_$AppDatabase db, $JobOrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> ticketNumber = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<String?> contactNumber = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String?> barangay = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> planName = const Value.absent(),
            Value<int?> planId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> onsiteStatus = const Value.absent(),
            Value<String?> onsiteRemarks = const Value.absent(),
            Value<double?> opticalPower = const Value.absent(),
            Value<String?> modemRouterSN = const Value.absent(),
            Value<String?> routerModel = const Value.absent(),
            Value<int?> lcpId = const Value.absent(),
            Value<int?> napId = const Value.absent(),
            Value<String?> portId = const Value.absent(),
            Value<int?> vlanId = const Value.absent(),
            Value<DateTime?> dateInstalled = const Value.absent(),
            Value<String?> boxReadingImage = const Value.absent(),
            Value<String?> routerReadingImage = const Value.absent(),
            Value<String?> clientSignature = const Value.absent(),
            Value<String?> assignedEmail = const Value.absent(),
            Value<DateTime?> modifiedDate = const Value.absent(),
            Value<String?> rawJson = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              JobOrdersCompanion(
            id: id,
            ticketNumber: ticketNumber,
            customerName: customerName,
            contactNumber: contactNumber,
            address: address,
            barangay: barangay,
            city: city,
            planName: planName,
            planId: planId,
            status: status,
            onsiteStatus: onsiteStatus,
            onsiteRemarks: onsiteRemarks,
            opticalPower: opticalPower,
            modemRouterSN: modemRouterSN,
            routerModel: routerModel,
            lcpId: lcpId,
            napId: napId,
            portId: portId,
            vlanId: vlanId,
            dateInstalled: dateInstalled,
            boxReadingImage: boxReadingImage,
            routerReadingImage: routerReadingImage,
            clientSignature: clientSignature,
            assignedEmail: assignedEmail,
            modifiedDate: modifiedDate,
            rawJson: rawJson,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String ticketNumber,
            required String customerName,
            Value<String?> contactNumber = const Value.absent(),
            required String address,
            Value<String?> barangay = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> planName = const Value.absent(),
            Value<int?> planId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> onsiteStatus = const Value.absent(),
            Value<String?> onsiteRemarks = const Value.absent(),
            Value<double?> opticalPower = const Value.absent(),
            Value<String?> modemRouterSN = const Value.absent(),
            Value<String?> routerModel = const Value.absent(),
            Value<int?> lcpId = const Value.absent(),
            Value<int?> napId = const Value.absent(),
            Value<String?> portId = const Value.absent(),
            Value<int?> vlanId = const Value.absent(),
            Value<DateTime?> dateInstalled = const Value.absent(),
            Value<String?> boxReadingImage = const Value.absent(),
            Value<String?> routerReadingImage = const Value.absent(),
            Value<String?> clientSignature = const Value.absent(),
            Value<String?> assignedEmail = const Value.absent(),
            Value<DateTime?> modifiedDate = const Value.absent(),
            Value<String?> rawJson = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              JobOrdersCompanion.insert(
            id: id,
            ticketNumber: ticketNumber,
            customerName: customerName,
            contactNumber: contactNumber,
            address: address,
            barangay: barangay,
            city: city,
            planName: planName,
            planId: planId,
            status: status,
            onsiteStatus: onsiteStatus,
            onsiteRemarks: onsiteRemarks,
            opticalPower: opticalPower,
            modemRouterSN: modemRouterSN,
            routerModel: routerModel,
            lcpId: lcpId,
            napId: napId,
            portId: portId,
            vlanId: vlanId,
            dateInstalled: dateInstalled,
            boxReadingImage: boxReadingImage,
            routerReadingImage: routerReadingImage,
            clientSignature: clientSignature,
            assignedEmail: assignedEmail,
            modifiedDate: modifiedDate,
            rawJson: rawJson,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JobOrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $JobOrdersTable,
    JobOrder,
    $$JobOrdersTableFilterComposer,
    $$JobOrdersTableOrderingComposer,
    $$JobOrdersTableAnnotationComposer,
    $$JobOrdersTableCreateCompanionBuilder,
    $$JobOrdersTableUpdateCompanionBuilder,
    (JobOrder, BaseReferences<_$AppDatabase, $JobOrdersTable, JobOrder>),
    JobOrder,
    PrefetchHooks Function()>;
typedef $$SyncQueuesTableCreateCompanionBuilder = SyncQueuesCompanion Function({
  Value<int> id,
  required String entityType,
  required int entityId,
  required String payload,
  required String action,
  Value<int> retryCount,
  Value<DateTime> createdAt,
});
typedef $$SyncQueuesTableUpdateCompanionBuilder = SyncQueuesCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<int> entityId,
  Value<String> payload,
  Value<String> action,
  Value<int> retryCount,
  Value<DateTime> createdAt,
});

class $$SyncQueuesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueuesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueuesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueuesTable,
    SyncQueue,
    $$SyncQueuesTableFilterComposer,
    $$SyncQueuesTableOrderingComposer,
    $$SyncQueuesTableAnnotationComposer,
    $$SyncQueuesTableCreateCompanionBuilder,
    $$SyncQueuesTableUpdateCompanionBuilder,
    (SyncQueue, BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>),
    SyncQueue,
    PrefetchHooks Function()> {
  $$SyncQueuesTableTableManager(_$AppDatabase db, $SyncQueuesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<int> entityId = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncQueuesCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            payload: payload,
            action: action,
            retryCount: retryCount,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required int entityId,
            required String payload,
            required String action,
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncQueuesCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            payload: payload,
            action: action,
            retryCount: retryCount,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueuesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueuesTable,
    SyncQueue,
    $$SyncQueuesTableFilterComposer,
    $$SyncQueuesTableOrderingComposer,
    $$SyncQueuesTableAnnotationComposer,
    $$SyncQueuesTableCreateCompanionBuilder,
    $$SyncQueuesTableUpdateCompanionBuilder,
    (SyncQueue, BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>),
    SyncQueue,
    PrefetchHooks Function()>;
typedef $$LcpNapLocationsTableCreateCompanionBuilder = LcpNapLocationsCompanion
    Function({
  Value<int> id,
  required String lcp,
  required String nap,
  required String lcpNap,
  Value<int> portTotal,
  Value<String?> coordinates,
  Value<String?> street,
  Value<String?> barangay,
  Value<String?> city,
  Value<String?> region,
  Value<String?> image,
  Value<String?> image2,
  Value<String?> readingImage,
  Value<String?> modifiedBy,
  Value<String?> userEmail,
  Value<DateTime?> modifiedDate,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});
typedef $$LcpNapLocationsTableUpdateCompanionBuilder = LcpNapLocationsCompanion
    Function({
  Value<int> id,
  Value<String> lcp,
  Value<String> nap,
  Value<String> lcpNap,
  Value<int> portTotal,
  Value<String?> coordinates,
  Value<String?> street,
  Value<String?> barangay,
  Value<String?> city,
  Value<String?> region,
  Value<String?> image,
  Value<String?> image2,
  Value<String?> readingImage,
  Value<String?> modifiedBy,
  Value<String?> userEmail,
  Value<DateTime?> modifiedDate,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});

class $$LcpNapLocationsTableFilterComposer
    extends Composer<_$AppDatabase, $LcpNapLocationsTable> {
  $$LcpNapLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lcp => $composableBuilder(
      column: $table.lcp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nap => $composableBuilder(
      column: $table.nap, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lcpNap => $composableBuilder(
      column: $table.lcpNap, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get portTotal => $composableBuilder(
      column: $table.portTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coordinates => $composableBuilder(
      column: $table.coordinates, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get street => $composableBuilder(
      column: $table.street, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barangay => $composableBuilder(
      column: $table.barangay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get region => $composableBuilder(
      column: $table.region, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image2 => $composableBuilder(
      column: $table.image2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get readingImage => $composableBuilder(
      column: $table.readingImage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modifiedBy => $composableBuilder(
      column: $table.modifiedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userEmail => $composableBuilder(
      column: $table.userEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get modifiedDate => $composableBuilder(
      column: $table.modifiedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LcpNapLocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LcpNapLocationsTable> {
  $$LcpNapLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lcp => $composableBuilder(
      column: $table.lcp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nap => $composableBuilder(
      column: $table.nap, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lcpNap => $composableBuilder(
      column: $table.lcpNap, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get portTotal => $composableBuilder(
      column: $table.portTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coordinates => $composableBuilder(
      column: $table.coordinates, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get street => $composableBuilder(
      column: $table.street, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barangay => $composableBuilder(
      column: $table.barangay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get region => $composableBuilder(
      column: $table.region, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image2 => $composableBuilder(
      column: $table.image2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get readingImage => $composableBuilder(
      column: $table.readingImage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modifiedBy => $composableBuilder(
      column: $table.modifiedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userEmail => $composableBuilder(
      column: $table.userEmail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get modifiedDate => $composableBuilder(
      column: $table.modifiedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LcpNapLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LcpNapLocationsTable> {
  $$LcpNapLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lcp =>
      $composableBuilder(column: $table.lcp, builder: (column) => column);

  GeneratedColumn<String> get nap =>
      $composableBuilder(column: $table.nap, builder: (column) => column);

  GeneratedColumn<String> get lcpNap =>
      $composableBuilder(column: $table.lcpNap, builder: (column) => column);

  GeneratedColumn<int> get portTotal =>
      $composableBuilder(column: $table.portTotal, builder: (column) => column);

  GeneratedColumn<String> get coordinates => $composableBuilder(
      column: $table.coordinates, builder: (column) => column);

  GeneratedColumn<String> get street =>
      $composableBuilder(column: $table.street, builder: (column) => column);

  GeneratedColumn<String> get barangay =>
      $composableBuilder(column: $table.barangay, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get image2 =>
      $composableBuilder(column: $table.image2, builder: (column) => column);

  GeneratedColumn<String> get readingImage => $composableBuilder(
      column: $table.readingImage, builder: (column) => column);

  GeneratedColumn<String> get modifiedBy => $composableBuilder(
      column: $table.modifiedBy, builder: (column) => column);

  GeneratedColumn<String> get userEmail =>
      $composableBuilder(column: $table.userEmail, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedDate => $composableBuilder(
      column: $table.modifiedDate, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LcpNapLocationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LcpNapLocationsTable,
    LcpNapLocation,
    $$LcpNapLocationsTableFilterComposer,
    $$LcpNapLocationsTableOrderingComposer,
    $$LcpNapLocationsTableAnnotationComposer,
    $$LcpNapLocationsTableCreateCompanionBuilder,
    $$LcpNapLocationsTableUpdateCompanionBuilder,
    (
      LcpNapLocation,
      BaseReferences<_$AppDatabase, $LcpNapLocationsTable, LcpNapLocation>
    ),
    LcpNapLocation,
    PrefetchHooks Function()> {
  $$LcpNapLocationsTableTableManager(
      _$AppDatabase db, $LcpNapLocationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LcpNapLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LcpNapLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LcpNapLocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> lcp = const Value.absent(),
            Value<String> nap = const Value.absent(),
            Value<String> lcpNap = const Value.absent(),
            Value<int> portTotal = const Value.absent(),
            Value<String?> coordinates = const Value.absent(),
            Value<String?> street = const Value.absent(),
            Value<String?> barangay = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> region = const Value.absent(),
            Value<String?> image = const Value.absent(),
            Value<String?> image2 = const Value.absent(),
            Value<String?> readingImage = const Value.absent(),
            Value<String?> modifiedBy = const Value.absent(),
            Value<String?> userEmail = const Value.absent(),
            Value<DateTime?> modifiedDate = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              LcpNapLocationsCompanion(
            id: id,
            lcp: lcp,
            nap: nap,
            lcpNap: lcpNap,
            portTotal: portTotal,
            coordinates: coordinates,
            street: street,
            barangay: barangay,
            city: city,
            region: region,
            image: image,
            image2: image2,
            readingImage: readingImage,
            modifiedBy: modifiedBy,
            userEmail: userEmail,
            modifiedDate: modifiedDate,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String lcp,
            required String nap,
            required String lcpNap,
            Value<int> portTotal = const Value.absent(),
            Value<String?> coordinates = const Value.absent(),
            Value<String?> street = const Value.absent(),
            Value<String?> barangay = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> region = const Value.absent(),
            Value<String?> image = const Value.absent(),
            Value<String?> image2 = const Value.absent(),
            Value<String?> readingImage = const Value.absent(),
            Value<String?> modifiedBy = const Value.absent(),
            Value<String?> userEmail = const Value.absent(),
            Value<DateTime?> modifiedDate = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              LcpNapLocationsCompanion.insert(
            id: id,
            lcp: lcp,
            nap: nap,
            lcpNap: lcpNap,
            portTotal: portTotal,
            coordinates: coordinates,
            street: street,
            barangay: barangay,
            city: city,
            region: region,
            image: image,
            image2: image2,
            readingImage: readingImage,
            modifiedBy: modifiedBy,
            userEmail: userEmail,
            modifiedDate: modifiedDate,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LcpNapLocationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LcpNapLocationsTable,
    LcpNapLocation,
    $$LcpNapLocationsTableFilterComposer,
    $$LcpNapLocationsTableOrderingComposer,
    $$LcpNapLocationsTableAnnotationComposer,
    $$LcpNapLocationsTableCreateCompanionBuilder,
    $$LcpNapLocationsTableUpdateCompanionBuilder,
    (
      LcpNapLocation,
      BaseReferences<_$AppDatabase, $LcpNapLocationsTable, LcpNapLocation>
    ),
    LcpNapLocation,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JobOrdersTableTableManager get jobOrders =>
      $$JobOrdersTableTableManager(_db, _db.jobOrders);
  $$SyncQueuesTableTableManager get syncQueues =>
      $$SyncQueuesTableTableManager(_db, _db.syncQueues);
  $$LcpNapLocationsTableTableManager get lcpNapLocations =>
      $$LcpNapLocationsTableTableManager(_db, _db.lcpNapLocations);
}
