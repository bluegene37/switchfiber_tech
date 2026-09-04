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
  static const VerificationMeta _napMeta = const VerificationMeta('nap');
  @override
  late final GeneratedColumn<String> nap = GeneratedColumn<String>(
      'nap', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  static const VerificationMeta _setupImageMeta =
      const VerificationMeta('setupImage');
  @override
  late final GeneratedColumn<String> setupImage = GeneratedColumn<String>(
      'setup_image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _speedtestImageMeta =
      const VerificationMeta('speedtestImage');
  @override
  late final GeneratedColumn<String> speedtestImage = GeneratedColumn<String>(
      'speedtest_image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _portLabelImageMeta =
      const VerificationMeta('portLabelImage');
  @override
  late final GeneratedColumn<String> portLabelImage = GeneratedColumn<String>(
      'port_label_image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _signedContractImageMeta =
      const VerificationMeta('signedContractImage');
  @override
  late final GeneratedColumn<String> signedContractImage =
      GeneratedColumn<String>('signed_contract_image', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _houseFrontMeta =
      const VerificationMeta('houseFront');
  @override
  late final GeneratedColumn<String> houseFront = GeneratedColumn<String>(
      'house_front', aliasedName, true,
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
        nap,
        portId,
        vlanId,
        dateInstalled,
        boxReadingImage,
        routerReadingImage,
        clientSignature,
        setupImage,
        speedtestImage,
        portLabelImage,
        signedContractImage,
        houseFront,
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
    if (data.containsKey('nap')) {
      context.handle(
          _napMeta, nap.isAcceptableOrUnknown(data['nap']!, _napMeta));
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
    if (data.containsKey('setup_image')) {
      context.handle(
          _setupImageMeta,
          setupImage.isAcceptableOrUnknown(
              data['setup_image']!, _setupImageMeta));
    }
    if (data.containsKey('speedtest_image')) {
      context.handle(
          _speedtestImageMeta,
          speedtestImage.isAcceptableOrUnknown(
              data['speedtest_image']!, _speedtestImageMeta));
    }
    if (data.containsKey('port_label_image')) {
      context.handle(
          _portLabelImageMeta,
          portLabelImage.isAcceptableOrUnknown(
              data['port_label_image']!, _portLabelImageMeta));
    }
    if (data.containsKey('signed_contract_image')) {
      context.handle(
          _signedContractImageMeta,
          signedContractImage.isAcceptableOrUnknown(
              data['signed_contract_image']!, _signedContractImageMeta));
    }
    if (data.containsKey('house_front')) {
      context.handle(
          _houseFrontMeta,
          houseFront.isAcceptableOrUnknown(
              data['house_front']!, _houseFrontMeta));
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
      nap: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nap']),
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
      setupImage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}setup_image']),
      speedtestImage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}speedtest_image']),
      portLabelImage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}port_label_image']),
      signedContractImage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}signed_contract_image']),
      houseFront: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}house_front']),
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
    if (!nullToAbsent || nap != null) {
      map['nap'] = Variable<String>(nap);
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
    if (!nullToAbsent || setupImage != null) {
      map['setup_image'] = Variable<String>(setupImage);
    }
    if (!nullToAbsent || speedtestImage != null) {
      map['speedtest_image'] = Variable<String>(speedtestImage);
    }
    if (!nullToAbsent || portLabelImage != null) {
      map['port_label_image'] = Variable<String>(portLabelImage);
    }
    if (!nullToAbsent || signedContractImage != null) {
      map['signed_contract_image'] = Variable<String>(signedContractImage);
    }
    if (!nullToAbsent || houseFront != null) {
      map['house_front'] = Variable<String>(houseFront);
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
      nap: nap == null && nullToAbsent ? const Value.absent() : Value(nap),
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
      setupImage: setupImage == null && nullToAbsent
          ? const Value.absent()
          : Value(setupImage),
      speedtestImage: speedtestImage == null && nullToAbsent
          ? const Value.absent()
          : Value(speedtestImage),
      portLabelImage: portLabelImage == null && nullToAbsent
          ? const Value.absent()
          : Value(portLabelImage),
      signedContractImage: signedContractImage == null && nullToAbsent
          ? const Value.absent()
          : Value(signedContractImage),
      houseFront: houseFront == null && nullToAbsent
          ? const Value.absent()
          : Value(houseFront),
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
      nap: serializer.fromJson<String?>(json['nap']),
      portId: serializer.fromJson<String?>(json['portId']),
      vlanId: serializer.fromJson<int?>(json['vlanId']),
      dateInstalled: serializer.fromJson<DateTime?>(json['dateInstalled']),
      boxReadingImage: serializer.fromJson<String?>(json['boxReadingImage']),
      routerReadingImage:
          serializer.fromJson<String?>(json['routerReadingImage']),
      clientSignature: serializer.fromJson<String?>(json['clientSignature']),
      setupImage: serializer.fromJson<String?>(json['setupImage']),
      speedtestImage: serializer.fromJson<String?>(json['speedtestImage']),
      portLabelImage: serializer.fromJson<String?>(json['portLabelImage']),
      signedContractImage:
          serializer.fromJson<String?>(json['signedContractImage']),
      houseFront: serializer.fromJson<String?>(json['houseFront']),
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
      'nap': serializer.toJson<String?>(nap),
      'portId': serializer.toJson<String?>(portId),
      'vlanId': serializer.toJson<int?>(vlanId),
      'dateInstalled': serializer.toJson<DateTime?>(dateInstalled),
      'boxReadingImage': serializer.toJson<String?>(boxReadingImage),
      'routerReadingImage': serializer.toJson<String?>(routerReadingImage),
      'clientSignature': serializer.toJson<String?>(clientSignature),
      'setupImage': serializer.toJson<String?>(setupImage),
      'speedtestImage': serializer.toJson<String?>(speedtestImage),
      'portLabelImage': serializer.toJson<String?>(portLabelImage),
      'signedContractImage': serializer.toJson<String?>(signedContractImage),
      'houseFront': serializer.toJson<String?>(houseFront),
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
          Value<String?> nap = const Value.absent(),
          Value<String?> portId = const Value.absent(),
          Value<int?> vlanId = const Value.absent(),
          Value<DateTime?> dateInstalled = const Value.absent(),
          Value<String?> boxReadingImage = const Value.absent(),
          Value<String?> routerReadingImage = const Value.absent(),
          Value<String?> clientSignature = const Value.absent(),
          Value<String?> setupImage = const Value.absent(),
          Value<String?> speedtestImage = const Value.absent(),
          Value<String?> portLabelImage = const Value.absent(),
          Value<String?> signedContractImage = const Value.absent(),
          Value<String?> houseFront = const Value.absent(),
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
        nap: nap.present ? nap.value : this.nap,
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
        setupImage: setupImage.present ? setupImage.value : this.setupImage,
        speedtestImage:
            speedtestImage.present ? speedtestImage.value : this.speedtestImage,
        portLabelImage:
            portLabelImage.present ? portLabelImage.value : this.portLabelImage,
        signedContractImage: signedContractImage.present
            ? signedContractImage.value
            : this.signedContractImage,
        houseFront: houseFront.present ? houseFront.value : this.houseFront,
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
      nap: data.nap.present ? data.nap.value : this.nap,
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
      setupImage:
          data.setupImage.present ? data.setupImage.value : this.setupImage,
      speedtestImage: data.speedtestImage.present
          ? data.speedtestImage.value
          : this.speedtestImage,
      portLabelImage: data.portLabelImage.present
          ? data.portLabelImage.value
          : this.portLabelImage,
      signedContractImage: data.signedContractImage.present
          ? data.signedContractImage.value
          : this.signedContractImage,
      houseFront:
          data.houseFront.present ? data.houseFront.value : this.houseFront,
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
          ..write('nap: $nap, ')
          ..write('portId: $portId, ')
          ..write('vlanId: $vlanId, ')
          ..write('dateInstalled: $dateInstalled, ')
          ..write('boxReadingImage: $boxReadingImage, ')
          ..write('routerReadingImage: $routerReadingImage, ')
          ..write('clientSignature: $clientSignature, ')
          ..write('setupImage: $setupImage, ')
          ..write('speedtestImage: $speedtestImage, ')
          ..write('portLabelImage: $portLabelImage, ')
          ..write('signedContractImage: $signedContractImage, ')
          ..write('houseFront: $houseFront, ')
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
        nap,
        portId,
        vlanId,
        dateInstalled,
        boxReadingImage,
        routerReadingImage,
        clientSignature,
        setupImage,
        speedtestImage,
        portLabelImage,
        signedContractImage,
        houseFront,
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
          other.nap == this.nap &&
          other.portId == this.portId &&
          other.vlanId == this.vlanId &&
          other.dateInstalled == this.dateInstalled &&
          other.boxReadingImage == this.boxReadingImage &&
          other.routerReadingImage == this.routerReadingImage &&
          other.clientSignature == this.clientSignature &&
          other.setupImage == this.setupImage &&
          other.speedtestImage == this.speedtestImage &&
          other.portLabelImage == this.portLabelImage &&
          other.signedContractImage == this.signedContractImage &&
          other.houseFront == this.houseFront &&
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
  final Value<String?> nap;
  final Value<String?> portId;
  final Value<int?> vlanId;
  final Value<DateTime?> dateInstalled;
  final Value<String?> boxReadingImage;
  final Value<String?> routerReadingImage;
  final Value<String?> clientSignature;
  final Value<String?> setupImage;
  final Value<String?> speedtestImage;
  final Value<String?> portLabelImage;
  final Value<String?> signedContractImage;
  final Value<String?> houseFront;
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
    this.nap = const Value.absent(),
    this.portId = const Value.absent(),
    this.vlanId = const Value.absent(),
    this.dateInstalled = const Value.absent(),
    this.boxReadingImage = const Value.absent(),
    this.routerReadingImage = const Value.absent(),
    this.clientSignature = const Value.absent(),
    this.setupImage = const Value.absent(),
    this.speedtestImage = const Value.absent(),
    this.portLabelImage = const Value.absent(),
    this.signedContractImage = const Value.absent(),
    this.houseFront = const Value.absent(),
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
    this.nap = const Value.absent(),
    this.portId = const Value.absent(),
    this.vlanId = const Value.absent(),
    this.dateInstalled = const Value.absent(),
    this.boxReadingImage = const Value.absent(),
    this.routerReadingImage = const Value.absent(),
    this.clientSignature = const Value.absent(),
    this.setupImage = const Value.absent(),
    this.speedtestImage = const Value.absent(),
    this.portLabelImage = const Value.absent(),
    this.signedContractImage = const Value.absent(),
    this.houseFront = const Value.absent(),
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
    Expression<String>? nap,
    Expression<String>? portId,
    Expression<int>? vlanId,
    Expression<DateTime>? dateInstalled,
    Expression<String>? boxReadingImage,
    Expression<String>? routerReadingImage,
    Expression<String>? clientSignature,
    Expression<String>? setupImage,
    Expression<String>? speedtestImage,
    Expression<String>? portLabelImage,
    Expression<String>? signedContractImage,
    Expression<String>? houseFront,
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
      if (nap != null) 'nap': nap,
      if (portId != null) 'port_id': portId,
      if (vlanId != null) 'vlan_id': vlanId,
      if (dateInstalled != null) 'date_installed': dateInstalled,
      if (boxReadingImage != null) 'box_reading_image': boxReadingImage,
      if (routerReadingImage != null)
        'router_reading_image': routerReadingImage,
      if (clientSignature != null) 'client_signature': clientSignature,
      if (setupImage != null) 'setup_image': setupImage,
      if (speedtestImage != null) 'speedtest_image': speedtestImage,
      if (portLabelImage != null) 'port_label_image': portLabelImage,
      if (signedContractImage != null)
        'signed_contract_image': signedContractImage,
      if (houseFront != null) 'house_front': houseFront,
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
      Value<String?>? nap,
      Value<String?>? portId,
      Value<int?>? vlanId,
      Value<DateTime?>? dateInstalled,
      Value<String?>? boxReadingImage,
      Value<String?>? routerReadingImage,
      Value<String?>? clientSignature,
      Value<String?>? setupImage,
      Value<String?>? speedtestImage,
      Value<String?>? portLabelImage,
      Value<String?>? signedContractImage,
      Value<String?>? houseFront,
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
      nap: nap ?? this.nap,
      portId: portId ?? this.portId,
      vlanId: vlanId ?? this.vlanId,
      dateInstalled: dateInstalled ?? this.dateInstalled,
      boxReadingImage: boxReadingImage ?? this.boxReadingImage,
      routerReadingImage: routerReadingImage ?? this.routerReadingImage,
      clientSignature: clientSignature ?? this.clientSignature,
      setupImage: setupImage ?? this.setupImage,
      speedtestImage: speedtestImage ?? this.speedtestImage,
      portLabelImage: portLabelImage ?? this.portLabelImage,
      signedContractImage: signedContractImage ?? this.signedContractImage,
      houseFront: houseFront ?? this.houseFront,
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
    if (nap.present) {
      map['nap'] = Variable<String>(nap.value);
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
    if (setupImage.present) {
      map['setup_image'] = Variable<String>(setupImage.value);
    }
    if (speedtestImage.present) {
      map['speedtest_image'] = Variable<String>(speedtestImage.value);
    }
    if (portLabelImage.present) {
      map['port_label_image'] = Variable<String>(portLabelImage.value);
    }
    if (signedContractImage.present) {
      map['signed_contract_image'] =
          Variable<String>(signedContractImage.value);
    }
    if (houseFront.present) {
      map['house_front'] = Variable<String>(houseFront.value);
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
          ..write('nap: $nap, ')
          ..write('portId: $portId, ')
          ..write('vlanId: $vlanId, ')
          ..write('dateInstalled: $dateInstalled, ')
          ..write('boxReadingImage: $boxReadingImage, ')
          ..write('routerReadingImage: $routerReadingImage, ')
          ..write('clientSignature: $clientSignature, ')
          ..write('setupImage: $setupImage, ')
          ..write('speedtestImage: $speedtestImage, ')
          ..write('portLabelImage: $portLabelImage, ')
          ..write('signedContractImage: $signedContractImage, ')
          ..write('houseFront: $houseFront, ')
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

class $ServiceOrdersTable extends ServiceOrders
    with TableInfo<$ServiceOrdersTable, ServiceOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _accountNumberMeta =
      const VerificationMeta('accountNumber');
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
      'account_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactNumberMeta =
      const VerificationMeta('contactNumber');
  @override
  late final GeneratedColumn<String> contactNumber = GeneratedColumn<String>(
      'contact_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailAddressMeta =
      const VerificationMeta('emailAddress');
  @override
  late final GeneratedColumn<String> emailAddress = GeneratedColumn<String>(
      'email_address', aliasedName, true,
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
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _planMeta = const VerificationMeta('plan');
  @override
  late final GeneratedColumn<String> plan = GeneratedColumn<String>(
      'plan', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _connectionTypeMeta =
      const VerificationMeta('connectionType');
  @override
  late final GeneratedColumn<String> connectionType = GeneratedColumn<String>(
      'connection_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _routerModemSNMeta =
      const VerificationMeta('routerModemSN');
  @override
  late final GeneratedColumn<String> routerModemSN = GeneratedColumn<String>(
      'router_modem_s_n', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lcpMeta = const VerificationMeta('lcp');
  @override
  late final GeneratedColumn<String> lcp = GeneratedColumn<String>(
      'lcp', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _napMeta = const VerificationMeta('nap');
  @override
  late final GeneratedColumn<String> nap = GeneratedColumn<String>(
      'nap', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<String> port = GeneratedColumn<String>(
      'port', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vlanMeta = const VerificationMeta('vlan');
  @override
  late final GeneratedColumn<String> vlan = GeneratedColumn<String>(
      'vlan', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _supportStatusMeta =
      const VerificationMeta('supportStatus');
  @override
  late final GeneratedColumn<String> supportStatus = GeneratedColumn<String>(
      'support_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Open'));
  static const VerificationMeta _concernMeta =
      const VerificationMeta('concern');
  @override
  late final GeneratedColumn<String> concern = GeneratedColumn<String>(
      'concern', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Service Call'));
  static const VerificationMeta _priorityLevelMeta =
      const VerificationMeta('priorityLevel');
  @override
  late final GeneratedColumn<String> priorityLevel = GeneratedColumn<String>(
      'priority_level', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _visitStatusMeta =
      const VerificationMeta('visitStatus');
  @override
  late final GeneratedColumn<String> visitStatus = GeneratedColumn<String>(
      'visit_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _visitByMeta =
      const VerificationMeta('visitBy');
  @override
  late final GeneratedColumn<String> visitBy = GeneratedColumn<String>(
      'visit_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _visitRemarksMeta =
      const VerificationMeta('visitRemarks');
  @override
  late final GeneratedColumn<String> visitRemarks = GeneratedColumn<String>(
      'visit_remarks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _assignedEmailMeta =
      const VerificationMeta('assignedEmail');
  @override
  late final GeneratedColumn<String> assignedEmail = GeneratedColumn<String>(
      'assigned_email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdDateMeta =
      const VerificationMeta('createdDate');
  @override
  late final GeneratedColumn<DateTime> createdDate = GeneratedColumn<DateTime>(
      'created_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dateInstalledMeta =
      const VerificationMeta('dateInstalled');
  @override
  late final GeneratedColumn<DateTime> dateInstalled =
      GeneratedColumn<DateTime>('date_installed', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _newRouterModemSNMeta =
      const VerificationMeta('newRouterModemSN');
  @override
  late final GeneratedColumn<String> newRouterModemSN = GeneratedColumn<String>(
      'new_router_modem_s_n', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _newLCPMeta = const VerificationMeta('newLCP');
  @override
  late final GeneratedColumn<String> newLCP = GeneratedColumn<String>(
      'new_l_c_p', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _newNAPMeta = const VerificationMeta('newNAP');
  @override
  late final GeneratedColumn<String> newNAP = GeneratedColumn<String>(
      'new_n_a_p', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _newPORTMeta =
      const VerificationMeta('newPORT');
  @override
  late final GeneratedColumn<String> newPORT = GeneratedColumn<String>(
      'new_p_o_r_t', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _newVLANMeta =
      const VerificationMeta('newVLAN');
  @override
  late final GeneratedColumn<String> newVLAN = GeneratedColumn<String>(
      'new_v_l_a_n', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _routerModelMeta =
      const VerificationMeta('routerModel');
  @override
  late final GeneratedColumn<String> routerModel = GeneratedColumn<String>(
      'router_model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pulloutRouterModelMeta =
      const VerificationMeta('pulloutRouterModel');
  @override
  late final GeneratedColumn<String> pulloutRouterModel =
      GeneratedColumn<String>('pullout_router_model', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pulloutRouterModelSNMeta =
      const VerificationMeta('pulloutRouterModelSN');
  @override
  late final GeneratedColumn<String> pulloutRouterModelSN =
      GeneratedColumn<String>('pullout_router_model_s_n', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pulloutRemarksMeta =
      const VerificationMeta('pulloutRemarks');
  @override
  late final GeneratedColumn<String> pulloutRemarks = GeneratedColumn<String>(
      'pullout_remarks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _materialsUsedJsonMeta =
      const VerificationMeta('materialsUsedJson');
  @override
  late final GeneratedColumn<String> materialsUsedJson =
      GeneratedColumn<String>('materials_used_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientSignatureMeta =
      const VerificationMeta('clientSignature');
  @override
  late final GeneratedColumn<String> clientSignature = GeneratedColumn<String>(
      'client_signature', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _image1Meta = const VerificationMeta('image1');
  @override
  late final GeneratedColumn<String> image1 = GeneratedColumn<String>(
      'image1', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _image2Meta = const VerificationMeta('image2');
  @override
  late final GeneratedColumn<String> image2 = GeneratedColumn<String>(
      'image2', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _image3Meta = const VerificationMeta('image3');
  @override
  late final GeneratedColumn<String> image3 = GeneratedColumn<String>(
      'image3', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _houseFrontPictureMeta =
      const VerificationMeta('houseFrontPicture');
  @override
  late final GeneratedColumn<String> houseFrontPicture =
      GeneratedColumn<String>('house_front_picture', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressCoordinatesMeta =
      const VerificationMeta('addressCoordinates');
  @override
  late final GeneratedColumn<String> addressCoordinates =
      GeneratedColumn<String>('address_coordinates', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serviceChargeMeta =
      const VerificationMeta('serviceCharge');
  @override
  late final GeneratedColumn<double> serviceCharge = GeneratedColumn<double>(
      'service_charge', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
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
        accountNumber,
        fullName,
        contactNumber,
        emailAddress,
        address,
        barangay,
        city,
        provider,
        plan,
        username,
        connectionType,
        routerModemSN,
        lcp,
        nap,
        port,
        vlan,
        supportStatus,
        concern,
        priorityLevel,
        visitStatus,
        visitBy,
        visitRemarks,
        assignedEmail,
        createdDate,
        dateInstalled,
        newRouterModemSN,
        newLCP,
        newNAP,
        newPORT,
        newVLAN,
        routerModel,
        pulloutRouterModel,
        pulloutRouterModelSN,
        pulloutRemarks,
        materialsUsedJson,
        clientSignature,
        image1,
        image2,
        image3,
        houseFrontPicture,
        addressCoordinates,
        serviceCharge,
        rawJson,
        isSynced,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_orders';
  @override
  VerificationContext validateIntegrity(Insertable<ServiceOrder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_number')) {
      context.handle(
          _accountNumberMeta,
          accountNumber.isAcceptableOrUnknown(
              data['account_number']!, _accountNumberMeta));
    } else if (isInserting) {
      context.missing(_accountNumberMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('contact_number')) {
      context.handle(
          _contactNumberMeta,
          contactNumber.isAcceptableOrUnknown(
              data['contact_number']!, _contactNumberMeta));
    }
    if (data.containsKey('email_address')) {
      context.handle(
          _emailAddressMeta,
          emailAddress.isAcceptableOrUnknown(
              data['email_address']!, _emailAddressMeta));
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
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    }
    if (data.containsKey('plan')) {
      context.handle(
          _planMeta, plan.isAcceptableOrUnknown(data['plan']!, _planMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    }
    if (data.containsKey('connection_type')) {
      context.handle(
          _connectionTypeMeta,
          connectionType.isAcceptableOrUnknown(
              data['connection_type']!, _connectionTypeMeta));
    }
    if (data.containsKey('router_modem_s_n')) {
      context.handle(
          _routerModemSNMeta,
          routerModemSN.isAcceptableOrUnknown(
              data['router_modem_s_n']!, _routerModemSNMeta));
    }
    if (data.containsKey('lcp')) {
      context.handle(
          _lcpMeta, lcp.isAcceptableOrUnknown(data['lcp']!, _lcpMeta));
    }
    if (data.containsKey('nap')) {
      context.handle(
          _napMeta, nap.isAcceptableOrUnknown(data['nap']!, _napMeta));
    }
    if (data.containsKey('port')) {
      context.handle(
          _portMeta, port.isAcceptableOrUnknown(data['port']!, _portMeta));
    }
    if (data.containsKey('vlan')) {
      context.handle(
          _vlanMeta, vlan.isAcceptableOrUnknown(data['vlan']!, _vlanMeta));
    }
    if (data.containsKey('support_status')) {
      context.handle(
          _supportStatusMeta,
          supportStatus.isAcceptableOrUnknown(
              data['support_status']!, _supportStatusMeta));
    }
    if (data.containsKey('concern')) {
      context.handle(_concernMeta,
          concern.isAcceptableOrUnknown(data['concern']!, _concernMeta));
    }
    if (data.containsKey('priority_level')) {
      context.handle(
          _priorityLevelMeta,
          priorityLevel.isAcceptableOrUnknown(
              data['priority_level']!, _priorityLevelMeta));
    }
    if (data.containsKey('visit_status')) {
      context.handle(
          _visitStatusMeta,
          visitStatus.isAcceptableOrUnknown(
              data['visit_status']!, _visitStatusMeta));
    }
    if (data.containsKey('visit_by')) {
      context.handle(_visitByMeta,
          visitBy.isAcceptableOrUnknown(data['visit_by']!, _visitByMeta));
    }
    if (data.containsKey('visit_remarks')) {
      context.handle(
          _visitRemarksMeta,
          visitRemarks.isAcceptableOrUnknown(
              data['visit_remarks']!, _visitRemarksMeta));
    }
    if (data.containsKey('assigned_email')) {
      context.handle(
          _assignedEmailMeta,
          assignedEmail.isAcceptableOrUnknown(
              data['assigned_email']!, _assignedEmailMeta));
    }
    if (data.containsKey('created_date')) {
      context.handle(
          _createdDateMeta,
          createdDate.isAcceptableOrUnknown(
              data['created_date']!, _createdDateMeta));
    }
    if (data.containsKey('date_installed')) {
      context.handle(
          _dateInstalledMeta,
          dateInstalled.isAcceptableOrUnknown(
              data['date_installed']!, _dateInstalledMeta));
    }
    if (data.containsKey('new_router_modem_s_n')) {
      context.handle(
          _newRouterModemSNMeta,
          newRouterModemSN.isAcceptableOrUnknown(
              data['new_router_modem_s_n']!, _newRouterModemSNMeta));
    }
    if (data.containsKey('new_l_c_p')) {
      context.handle(_newLCPMeta,
          newLCP.isAcceptableOrUnknown(data['new_l_c_p']!, _newLCPMeta));
    }
    if (data.containsKey('new_n_a_p')) {
      context.handle(_newNAPMeta,
          newNAP.isAcceptableOrUnknown(data['new_n_a_p']!, _newNAPMeta));
    }
    if (data.containsKey('new_p_o_r_t')) {
      context.handle(_newPORTMeta,
          newPORT.isAcceptableOrUnknown(data['new_p_o_r_t']!, _newPORTMeta));
    }
    if (data.containsKey('new_v_l_a_n')) {
      context.handle(_newVLANMeta,
          newVLAN.isAcceptableOrUnknown(data['new_v_l_a_n']!, _newVLANMeta));
    }
    if (data.containsKey('router_model')) {
      context.handle(
          _routerModelMeta,
          routerModel.isAcceptableOrUnknown(
              data['router_model']!, _routerModelMeta));
    }
    if (data.containsKey('pullout_router_model')) {
      context.handle(
          _pulloutRouterModelMeta,
          pulloutRouterModel.isAcceptableOrUnknown(
              data['pullout_router_model']!, _pulloutRouterModelMeta));
    }
    if (data.containsKey('pullout_router_model_s_n')) {
      context.handle(
          _pulloutRouterModelSNMeta,
          pulloutRouterModelSN.isAcceptableOrUnknown(
              data['pullout_router_model_s_n']!, _pulloutRouterModelSNMeta));
    }
    if (data.containsKey('pullout_remarks')) {
      context.handle(
          _pulloutRemarksMeta,
          pulloutRemarks.isAcceptableOrUnknown(
              data['pullout_remarks']!, _pulloutRemarksMeta));
    }
    if (data.containsKey('materials_used_json')) {
      context.handle(
          _materialsUsedJsonMeta,
          materialsUsedJson.isAcceptableOrUnknown(
              data['materials_used_json']!, _materialsUsedJsonMeta));
    }
    if (data.containsKey('client_signature')) {
      context.handle(
          _clientSignatureMeta,
          clientSignature.isAcceptableOrUnknown(
              data['client_signature']!, _clientSignatureMeta));
    }
    if (data.containsKey('image1')) {
      context.handle(_image1Meta,
          image1.isAcceptableOrUnknown(data['image1']!, _image1Meta));
    }
    if (data.containsKey('image2')) {
      context.handle(_image2Meta,
          image2.isAcceptableOrUnknown(data['image2']!, _image2Meta));
    }
    if (data.containsKey('image3')) {
      context.handle(_image3Meta,
          image3.isAcceptableOrUnknown(data['image3']!, _image3Meta));
    }
    if (data.containsKey('house_front_picture')) {
      context.handle(
          _houseFrontPictureMeta,
          houseFrontPicture.isAcceptableOrUnknown(
              data['house_front_picture']!, _houseFrontPictureMeta));
    }
    if (data.containsKey('address_coordinates')) {
      context.handle(
          _addressCoordinatesMeta,
          addressCoordinates.isAcceptableOrUnknown(
              data['address_coordinates']!, _addressCoordinatesMeta));
    }
    if (data.containsKey('service_charge')) {
      context.handle(
          _serviceChargeMeta,
          serviceCharge.isAcceptableOrUnknown(
              data['service_charge']!, _serviceChargeMeta));
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
  ServiceOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceOrder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accountNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_number'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      contactNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_number']),
      emailAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email_address']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      barangay: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barangay']),
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city']),
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider']),
      plan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan']),
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username']),
      connectionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}connection_type']),
      routerModemSN: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}router_modem_s_n']),
      lcp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lcp']),
      nap: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nap']),
      port: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}port']),
      vlan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vlan']),
      supportStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}support_status'])!,
      concern: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}concern'])!,
      priorityLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority_level']),
      visitStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visit_status']),
      visitBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visit_by']),
      visitRemarks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visit_remarks']),
      assignedEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assigned_email']),
      createdDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_date']),
      dateInstalled: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_installed']),
      newRouterModemSN: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}new_router_modem_s_n']),
      newLCP: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}new_l_c_p']),
      newNAP: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}new_n_a_p']),
      newPORT: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}new_p_o_r_t']),
      newVLAN: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}new_v_l_a_n']),
      routerModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}router_model']),
      pulloutRouterModel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}pullout_router_model']),
      pulloutRouterModelSN: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pullout_router_model_s_n']),
      pulloutRemarks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pullout_remarks']),
      materialsUsedJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}materials_used_json']),
      clientSignature: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}client_signature']),
      image1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image1']),
      image2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image2']),
      image3: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image3']),
      houseFrontPicture: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}house_front_picture']),
      addressCoordinates: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}address_coordinates']),
      serviceCharge: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}service_charge'])!,
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json']),
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ServiceOrdersTable createAlias(String alias) {
    return $ServiceOrdersTable(attachedDatabase, alias);
  }
}

class ServiceOrder extends DataClass implements Insertable<ServiceOrder> {
  final int id;
  final String accountNumber;
  final String fullName;
  final String? contactNumber;
  final String? emailAddress;
  final String address;
  final String? barangay;
  final String? city;
  final String? provider;
  final String? plan;
  final String? username;
  final String? connectionType;
  final String? routerModemSN;
  final String? lcp;
  final String? nap;
  final String? port;
  final String? vlan;
  final String supportStatus;
  final String concern;
  final String? priorityLevel;
  final String? visitStatus;
  final String? visitBy;
  final String? visitRemarks;
  final String? assignedEmail;
  final DateTime? createdDate;
  final DateTime? dateInstalled;
  final String? newRouterModemSN;
  final String? newLCP;
  final String? newNAP;
  final String? newPORT;
  final String? newVLAN;
  final String? routerModel;
  final String? pulloutRouterModel;
  final String? pulloutRouterModelSN;
  final String? pulloutRemarks;
  final String? materialsUsedJson;
  final String? clientSignature;
  final String? image1;
  final String? image2;
  final String? image3;
  final String? houseFrontPicture;
  final String? addressCoordinates;
  final double serviceCharge;
  final String? rawJson;
  final bool isSynced;
  final DateTime updatedAt;
  const ServiceOrder(
      {required this.id,
      required this.accountNumber,
      required this.fullName,
      this.contactNumber,
      this.emailAddress,
      required this.address,
      this.barangay,
      this.city,
      this.provider,
      this.plan,
      this.username,
      this.connectionType,
      this.routerModemSN,
      this.lcp,
      this.nap,
      this.port,
      this.vlan,
      required this.supportStatus,
      required this.concern,
      this.priorityLevel,
      this.visitStatus,
      this.visitBy,
      this.visitRemarks,
      this.assignedEmail,
      this.createdDate,
      this.dateInstalled,
      this.newRouterModemSN,
      this.newLCP,
      this.newNAP,
      this.newPORT,
      this.newVLAN,
      this.routerModel,
      this.pulloutRouterModel,
      this.pulloutRouterModelSN,
      this.pulloutRemarks,
      this.materialsUsedJson,
      this.clientSignature,
      this.image1,
      this.image2,
      this.image3,
      this.houseFrontPicture,
      this.addressCoordinates,
      required this.serviceCharge,
      this.rawJson,
      required this.isSynced,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_number'] = Variable<String>(accountNumber);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || contactNumber != null) {
      map['contact_number'] = Variable<String>(contactNumber);
    }
    if (!nullToAbsent || emailAddress != null) {
      map['email_address'] = Variable<String>(emailAddress);
    }
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || barangay != null) {
      map['barangay'] = Variable<String>(barangay);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    if (!nullToAbsent || plan != null) {
      map['plan'] = Variable<String>(plan);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || connectionType != null) {
      map['connection_type'] = Variable<String>(connectionType);
    }
    if (!nullToAbsent || routerModemSN != null) {
      map['router_modem_s_n'] = Variable<String>(routerModemSN);
    }
    if (!nullToAbsent || lcp != null) {
      map['lcp'] = Variable<String>(lcp);
    }
    if (!nullToAbsent || nap != null) {
      map['nap'] = Variable<String>(nap);
    }
    if (!nullToAbsent || port != null) {
      map['port'] = Variable<String>(port);
    }
    if (!nullToAbsent || vlan != null) {
      map['vlan'] = Variable<String>(vlan);
    }
    map['support_status'] = Variable<String>(supportStatus);
    map['concern'] = Variable<String>(concern);
    if (!nullToAbsent || priorityLevel != null) {
      map['priority_level'] = Variable<String>(priorityLevel);
    }
    if (!nullToAbsent || visitStatus != null) {
      map['visit_status'] = Variable<String>(visitStatus);
    }
    if (!nullToAbsent || visitBy != null) {
      map['visit_by'] = Variable<String>(visitBy);
    }
    if (!nullToAbsent || visitRemarks != null) {
      map['visit_remarks'] = Variable<String>(visitRemarks);
    }
    if (!nullToAbsent || assignedEmail != null) {
      map['assigned_email'] = Variable<String>(assignedEmail);
    }
    if (!nullToAbsent || createdDate != null) {
      map['created_date'] = Variable<DateTime>(createdDate);
    }
    if (!nullToAbsent || dateInstalled != null) {
      map['date_installed'] = Variable<DateTime>(dateInstalled);
    }
    if (!nullToAbsent || newRouterModemSN != null) {
      map['new_router_modem_s_n'] = Variable<String>(newRouterModemSN);
    }
    if (!nullToAbsent || newLCP != null) {
      map['new_l_c_p'] = Variable<String>(newLCP);
    }
    if (!nullToAbsent || newNAP != null) {
      map['new_n_a_p'] = Variable<String>(newNAP);
    }
    if (!nullToAbsent || newPORT != null) {
      map['new_p_o_r_t'] = Variable<String>(newPORT);
    }
    if (!nullToAbsent || newVLAN != null) {
      map['new_v_l_a_n'] = Variable<String>(newVLAN);
    }
    if (!nullToAbsent || routerModel != null) {
      map['router_model'] = Variable<String>(routerModel);
    }
    if (!nullToAbsent || pulloutRouterModel != null) {
      map['pullout_router_model'] = Variable<String>(pulloutRouterModel);
    }
    if (!nullToAbsent || pulloutRouterModelSN != null) {
      map['pullout_router_model_s_n'] = Variable<String>(pulloutRouterModelSN);
    }
    if (!nullToAbsent || pulloutRemarks != null) {
      map['pullout_remarks'] = Variable<String>(pulloutRemarks);
    }
    if (!nullToAbsent || materialsUsedJson != null) {
      map['materials_used_json'] = Variable<String>(materialsUsedJson);
    }
    if (!nullToAbsent || clientSignature != null) {
      map['client_signature'] = Variable<String>(clientSignature);
    }
    if (!nullToAbsent || image1 != null) {
      map['image1'] = Variable<String>(image1);
    }
    if (!nullToAbsent || image2 != null) {
      map['image2'] = Variable<String>(image2);
    }
    if (!nullToAbsent || image3 != null) {
      map['image3'] = Variable<String>(image3);
    }
    if (!nullToAbsent || houseFrontPicture != null) {
      map['house_front_picture'] = Variable<String>(houseFrontPicture);
    }
    if (!nullToAbsent || addressCoordinates != null) {
      map['address_coordinates'] = Variable<String>(addressCoordinates);
    }
    map['service_charge'] = Variable<double>(serviceCharge);
    if (!nullToAbsent || rawJson != null) {
      map['raw_json'] = Variable<String>(rawJson);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ServiceOrdersCompanion toCompanion(bool nullToAbsent) {
    return ServiceOrdersCompanion(
      id: Value(id),
      accountNumber: Value(accountNumber),
      fullName: Value(fullName),
      contactNumber: contactNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(contactNumber),
      emailAddress: emailAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(emailAddress),
      address: Value(address),
      barangay: barangay == null && nullToAbsent
          ? const Value.absent()
          : Value(barangay),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      plan: plan == null && nullToAbsent ? const Value.absent() : Value(plan),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      connectionType: connectionType == null && nullToAbsent
          ? const Value.absent()
          : Value(connectionType),
      routerModemSN: routerModemSN == null && nullToAbsent
          ? const Value.absent()
          : Value(routerModemSN),
      lcp: lcp == null && nullToAbsent ? const Value.absent() : Value(lcp),
      nap: nap == null && nullToAbsent ? const Value.absent() : Value(nap),
      port: port == null && nullToAbsent ? const Value.absent() : Value(port),
      vlan: vlan == null && nullToAbsent ? const Value.absent() : Value(vlan),
      supportStatus: Value(supportStatus),
      concern: Value(concern),
      priorityLevel: priorityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(priorityLevel),
      visitStatus: visitStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(visitStatus),
      visitBy: visitBy == null && nullToAbsent
          ? const Value.absent()
          : Value(visitBy),
      visitRemarks: visitRemarks == null && nullToAbsent
          ? const Value.absent()
          : Value(visitRemarks),
      assignedEmail: assignedEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedEmail),
      createdDate: createdDate == null && nullToAbsent
          ? const Value.absent()
          : Value(createdDate),
      dateInstalled: dateInstalled == null && nullToAbsent
          ? const Value.absent()
          : Value(dateInstalled),
      newRouterModemSN: newRouterModemSN == null && nullToAbsent
          ? const Value.absent()
          : Value(newRouterModemSN),
      newLCP:
          newLCP == null && nullToAbsent ? const Value.absent() : Value(newLCP),
      newNAP:
          newNAP == null && nullToAbsent ? const Value.absent() : Value(newNAP),
      newPORT: newPORT == null && nullToAbsent
          ? const Value.absent()
          : Value(newPORT),
      newVLAN: newVLAN == null && nullToAbsent
          ? const Value.absent()
          : Value(newVLAN),
      routerModel: routerModel == null && nullToAbsent
          ? const Value.absent()
          : Value(routerModel),
      pulloutRouterModel: pulloutRouterModel == null && nullToAbsent
          ? const Value.absent()
          : Value(pulloutRouterModel),
      pulloutRouterModelSN: pulloutRouterModelSN == null && nullToAbsent
          ? const Value.absent()
          : Value(pulloutRouterModelSN),
      pulloutRemarks: pulloutRemarks == null && nullToAbsent
          ? const Value.absent()
          : Value(pulloutRemarks),
      materialsUsedJson: materialsUsedJson == null && nullToAbsent
          ? const Value.absent()
          : Value(materialsUsedJson),
      clientSignature: clientSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(clientSignature),
      image1:
          image1 == null && nullToAbsent ? const Value.absent() : Value(image1),
      image2:
          image2 == null && nullToAbsent ? const Value.absent() : Value(image2),
      image3:
          image3 == null && nullToAbsent ? const Value.absent() : Value(image3),
      houseFrontPicture: houseFrontPicture == null && nullToAbsent
          ? const Value.absent()
          : Value(houseFrontPicture),
      addressCoordinates: addressCoordinates == null && nullToAbsent
          ? const Value.absent()
          : Value(addressCoordinates),
      serviceCharge: Value(serviceCharge),
      rawJson: rawJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawJson),
      isSynced: Value(isSynced),
      updatedAt: Value(updatedAt),
    );
  }

  factory ServiceOrder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceOrder(
      id: serializer.fromJson<int>(json['id']),
      accountNumber: serializer.fromJson<String>(json['accountNumber']),
      fullName: serializer.fromJson<String>(json['fullName']),
      contactNumber: serializer.fromJson<String?>(json['contactNumber']),
      emailAddress: serializer.fromJson<String?>(json['emailAddress']),
      address: serializer.fromJson<String>(json['address']),
      barangay: serializer.fromJson<String?>(json['barangay']),
      city: serializer.fromJson<String?>(json['city']),
      provider: serializer.fromJson<String?>(json['provider']),
      plan: serializer.fromJson<String?>(json['plan']),
      username: serializer.fromJson<String?>(json['username']),
      connectionType: serializer.fromJson<String?>(json['connectionType']),
      routerModemSN: serializer.fromJson<String?>(json['routerModemSN']),
      lcp: serializer.fromJson<String?>(json['lcp']),
      nap: serializer.fromJson<String?>(json['nap']),
      port: serializer.fromJson<String?>(json['port']),
      vlan: serializer.fromJson<String?>(json['vlan']),
      supportStatus: serializer.fromJson<String>(json['supportStatus']),
      concern: serializer.fromJson<String>(json['concern']),
      priorityLevel: serializer.fromJson<String?>(json['priorityLevel']),
      visitStatus: serializer.fromJson<String?>(json['visitStatus']),
      visitBy: serializer.fromJson<String?>(json['visitBy']),
      visitRemarks: serializer.fromJson<String?>(json['visitRemarks']),
      assignedEmail: serializer.fromJson<String?>(json['assignedEmail']),
      createdDate: serializer.fromJson<DateTime?>(json['createdDate']),
      dateInstalled: serializer.fromJson<DateTime?>(json['dateInstalled']),
      newRouterModemSN: serializer.fromJson<String?>(json['newRouterModemSN']),
      newLCP: serializer.fromJson<String?>(json['newLCP']),
      newNAP: serializer.fromJson<String?>(json['newNAP']),
      newPORT: serializer.fromJson<String?>(json['newPORT']),
      newVLAN: serializer.fromJson<String?>(json['newVLAN']),
      routerModel: serializer.fromJson<String?>(json['routerModel']),
      pulloutRouterModel:
          serializer.fromJson<String?>(json['pulloutRouterModel']),
      pulloutRouterModelSN:
          serializer.fromJson<String?>(json['pulloutRouterModelSN']),
      pulloutRemarks: serializer.fromJson<String?>(json['pulloutRemarks']),
      materialsUsedJson:
          serializer.fromJson<String?>(json['materialsUsedJson']),
      clientSignature: serializer.fromJson<String?>(json['clientSignature']),
      image1: serializer.fromJson<String?>(json['image1']),
      image2: serializer.fromJson<String?>(json['image2']),
      image3: serializer.fromJson<String?>(json['image3']),
      houseFrontPicture:
          serializer.fromJson<String?>(json['houseFrontPicture']),
      addressCoordinates:
          serializer.fromJson<String?>(json['addressCoordinates']),
      serviceCharge: serializer.fromJson<double>(json['serviceCharge']),
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
      'accountNumber': serializer.toJson<String>(accountNumber),
      'fullName': serializer.toJson<String>(fullName),
      'contactNumber': serializer.toJson<String?>(contactNumber),
      'emailAddress': serializer.toJson<String?>(emailAddress),
      'address': serializer.toJson<String>(address),
      'barangay': serializer.toJson<String?>(barangay),
      'city': serializer.toJson<String?>(city),
      'provider': serializer.toJson<String?>(provider),
      'plan': serializer.toJson<String?>(plan),
      'username': serializer.toJson<String?>(username),
      'connectionType': serializer.toJson<String?>(connectionType),
      'routerModemSN': serializer.toJson<String?>(routerModemSN),
      'lcp': serializer.toJson<String?>(lcp),
      'nap': serializer.toJson<String?>(nap),
      'port': serializer.toJson<String?>(port),
      'vlan': serializer.toJson<String?>(vlan),
      'supportStatus': serializer.toJson<String>(supportStatus),
      'concern': serializer.toJson<String>(concern),
      'priorityLevel': serializer.toJson<String?>(priorityLevel),
      'visitStatus': serializer.toJson<String?>(visitStatus),
      'visitBy': serializer.toJson<String?>(visitBy),
      'visitRemarks': serializer.toJson<String?>(visitRemarks),
      'assignedEmail': serializer.toJson<String?>(assignedEmail),
      'createdDate': serializer.toJson<DateTime?>(createdDate),
      'dateInstalled': serializer.toJson<DateTime?>(dateInstalled),
      'newRouterModemSN': serializer.toJson<String?>(newRouterModemSN),
      'newLCP': serializer.toJson<String?>(newLCP),
      'newNAP': serializer.toJson<String?>(newNAP),
      'newPORT': serializer.toJson<String?>(newPORT),
      'newVLAN': serializer.toJson<String?>(newVLAN),
      'routerModel': serializer.toJson<String?>(routerModel),
      'pulloutRouterModel': serializer.toJson<String?>(pulloutRouterModel),
      'pulloutRouterModelSN': serializer.toJson<String?>(pulloutRouterModelSN),
      'pulloutRemarks': serializer.toJson<String?>(pulloutRemarks),
      'materialsUsedJson': serializer.toJson<String?>(materialsUsedJson),
      'clientSignature': serializer.toJson<String?>(clientSignature),
      'image1': serializer.toJson<String?>(image1),
      'image2': serializer.toJson<String?>(image2),
      'image3': serializer.toJson<String?>(image3),
      'houseFrontPicture': serializer.toJson<String?>(houseFrontPicture),
      'addressCoordinates': serializer.toJson<String?>(addressCoordinates),
      'serviceCharge': serializer.toJson<double>(serviceCharge),
      'rawJson': serializer.toJson<String?>(rawJson),
      'isSynced': serializer.toJson<bool>(isSynced),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ServiceOrder copyWith(
          {int? id,
          String? accountNumber,
          String? fullName,
          Value<String?> contactNumber = const Value.absent(),
          Value<String?> emailAddress = const Value.absent(),
          String? address,
          Value<String?> barangay = const Value.absent(),
          Value<String?> city = const Value.absent(),
          Value<String?> provider = const Value.absent(),
          Value<String?> plan = const Value.absent(),
          Value<String?> username = const Value.absent(),
          Value<String?> connectionType = const Value.absent(),
          Value<String?> routerModemSN = const Value.absent(),
          Value<String?> lcp = const Value.absent(),
          Value<String?> nap = const Value.absent(),
          Value<String?> port = const Value.absent(),
          Value<String?> vlan = const Value.absent(),
          String? supportStatus,
          String? concern,
          Value<String?> priorityLevel = const Value.absent(),
          Value<String?> visitStatus = const Value.absent(),
          Value<String?> visitBy = const Value.absent(),
          Value<String?> visitRemarks = const Value.absent(),
          Value<String?> assignedEmail = const Value.absent(),
          Value<DateTime?> createdDate = const Value.absent(),
          Value<DateTime?> dateInstalled = const Value.absent(),
          Value<String?> newRouterModemSN = const Value.absent(),
          Value<String?> newLCP = const Value.absent(),
          Value<String?> newNAP = const Value.absent(),
          Value<String?> newPORT = const Value.absent(),
          Value<String?> newVLAN = const Value.absent(),
          Value<String?> routerModel = const Value.absent(),
          Value<String?> pulloutRouterModel = const Value.absent(),
          Value<String?> pulloutRouterModelSN = const Value.absent(),
          Value<String?> pulloutRemarks = const Value.absent(),
          Value<String?> materialsUsedJson = const Value.absent(),
          Value<String?> clientSignature = const Value.absent(),
          Value<String?> image1 = const Value.absent(),
          Value<String?> image2 = const Value.absent(),
          Value<String?> image3 = const Value.absent(),
          Value<String?> houseFrontPicture = const Value.absent(),
          Value<String?> addressCoordinates = const Value.absent(),
          double? serviceCharge,
          Value<String?> rawJson = const Value.absent(),
          bool? isSynced,
          DateTime? updatedAt}) =>
      ServiceOrder(
        id: id ?? this.id,
        accountNumber: accountNumber ?? this.accountNumber,
        fullName: fullName ?? this.fullName,
        contactNumber:
            contactNumber.present ? contactNumber.value : this.contactNumber,
        emailAddress:
            emailAddress.present ? emailAddress.value : this.emailAddress,
        address: address ?? this.address,
        barangay: barangay.present ? barangay.value : this.barangay,
        city: city.present ? city.value : this.city,
        provider: provider.present ? provider.value : this.provider,
        plan: plan.present ? plan.value : this.plan,
        username: username.present ? username.value : this.username,
        connectionType:
            connectionType.present ? connectionType.value : this.connectionType,
        routerModemSN:
            routerModemSN.present ? routerModemSN.value : this.routerModemSN,
        lcp: lcp.present ? lcp.value : this.lcp,
        nap: nap.present ? nap.value : this.nap,
        port: port.present ? port.value : this.port,
        vlan: vlan.present ? vlan.value : this.vlan,
        supportStatus: supportStatus ?? this.supportStatus,
        concern: concern ?? this.concern,
        priorityLevel:
            priorityLevel.present ? priorityLevel.value : this.priorityLevel,
        visitStatus: visitStatus.present ? visitStatus.value : this.visitStatus,
        visitBy: visitBy.present ? visitBy.value : this.visitBy,
        visitRemarks:
            visitRemarks.present ? visitRemarks.value : this.visitRemarks,
        assignedEmail:
            assignedEmail.present ? assignedEmail.value : this.assignedEmail,
        createdDate: createdDate.present ? createdDate.value : this.createdDate,
        dateInstalled:
            dateInstalled.present ? dateInstalled.value : this.dateInstalled,
        newRouterModemSN: newRouterModemSN.present
            ? newRouterModemSN.value
            : this.newRouterModemSN,
        newLCP: newLCP.present ? newLCP.value : this.newLCP,
        newNAP: newNAP.present ? newNAP.value : this.newNAP,
        newPORT: newPORT.present ? newPORT.value : this.newPORT,
        newVLAN: newVLAN.present ? newVLAN.value : this.newVLAN,
        routerModel: routerModel.present ? routerModel.value : this.routerModel,
        pulloutRouterModel: pulloutRouterModel.present
            ? pulloutRouterModel.value
            : this.pulloutRouterModel,
        pulloutRouterModelSN: pulloutRouterModelSN.present
            ? pulloutRouterModelSN.value
            : this.pulloutRouterModelSN,
        pulloutRemarks:
            pulloutRemarks.present ? pulloutRemarks.value : this.pulloutRemarks,
        materialsUsedJson: materialsUsedJson.present
            ? materialsUsedJson.value
            : this.materialsUsedJson,
        clientSignature: clientSignature.present
            ? clientSignature.value
            : this.clientSignature,
        image1: image1.present ? image1.value : this.image1,
        image2: image2.present ? image2.value : this.image2,
        image3: image3.present ? image3.value : this.image3,
        houseFrontPicture: houseFrontPicture.present
            ? houseFrontPicture.value
            : this.houseFrontPicture,
        addressCoordinates: addressCoordinates.present
            ? addressCoordinates.value
            : this.addressCoordinates,
        serviceCharge: serviceCharge ?? this.serviceCharge,
        rawJson: rawJson.present ? rawJson.value : this.rawJson,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ServiceOrder copyWithCompanion(ServiceOrdersCompanion data) {
    return ServiceOrder(
      id: data.id.present ? data.id.value : this.id,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      contactNumber: data.contactNumber.present
          ? data.contactNumber.value
          : this.contactNumber,
      emailAddress: data.emailAddress.present
          ? data.emailAddress.value
          : this.emailAddress,
      address: data.address.present ? data.address.value : this.address,
      barangay: data.barangay.present ? data.barangay.value : this.barangay,
      city: data.city.present ? data.city.value : this.city,
      provider: data.provider.present ? data.provider.value : this.provider,
      plan: data.plan.present ? data.plan.value : this.plan,
      username: data.username.present ? data.username.value : this.username,
      connectionType: data.connectionType.present
          ? data.connectionType.value
          : this.connectionType,
      routerModemSN: data.routerModemSN.present
          ? data.routerModemSN.value
          : this.routerModemSN,
      lcp: data.lcp.present ? data.lcp.value : this.lcp,
      nap: data.nap.present ? data.nap.value : this.nap,
      port: data.port.present ? data.port.value : this.port,
      vlan: data.vlan.present ? data.vlan.value : this.vlan,
      supportStatus: data.supportStatus.present
          ? data.supportStatus.value
          : this.supportStatus,
      concern: data.concern.present ? data.concern.value : this.concern,
      priorityLevel: data.priorityLevel.present
          ? data.priorityLevel.value
          : this.priorityLevel,
      visitStatus:
          data.visitStatus.present ? data.visitStatus.value : this.visitStatus,
      visitBy: data.visitBy.present ? data.visitBy.value : this.visitBy,
      visitRemarks: data.visitRemarks.present
          ? data.visitRemarks.value
          : this.visitRemarks,
      assignedEmail: data.assignedEmail.present
          ? data.assignedEmail.value
          : this.assignedEmail,
      createdDate:
          data.createdDate.present ? data.createdDate.value : this.createdDate,
      dateInstalled: data.dateInstalled.present
          ? data.dateInstalled.value
          : this.dateInstalled,
      newRouterModemSN: data.newRouterModemSN.present
          ? data.newRouterModemSN.value
          : this.newRouterModemSN,
      newLCP: data.newLCP.present ? data.newLCP.value : this.newLCP,
      newNAP: data.newNAP.present ? data.newNAP.value : this.newNAP,
      newPORT: data.newPORT.present ? data.newPORT.value : this.newPORT,
      newVLAN: data.newVLAN.present ? data.newVLAN.value : this.newVLAN,
      routerModel:
          data.routerModel.present ? data.routerModel.value : this.routerModel,
      pulloutRouterModel: data.pulloutRouterModel.present
          ? data.pulloutRouterModel.value
          : this.pulloutRouterModel,
      pulloutRouterModelSN: data.pulloutRouterModelSN.present
          ? data.pulloutRouterModelSN.value
          : this.pulloutRouterModelSN,
      pulloutRemarks: data.pulloutRemarks.present
          ? data.pulloutRemarks.value
          : this.pulloutRemarks,
      materialsUsedJson: data.materialsUsedJson.present
          ? data.materialsUsedJson.value
          : this.materialsUsedJson,
      clientSignature: data.clientSignature.present
          ? data.clientSignature.value
          : this.clientSignature,
      image1: data.image1.present ? data.image1.value : this.image1,
      image2: data.image2.present ? data.image2.value : this.image2,
      image3: data.image3.present ? data.image3.value : this.image3,
      houseFrontPicture: data.houseFrontPicture.present
          ? data.houseFrontPicture.value
          : this.houseFrontPicture,
      addressCoordinates: data.addressCoordinates.present
          ? data.addressCoordinates.value
          : this.addressCoordinates,
      serviceCharge: data.serviceCharge.present
          ? data.serviceCharge.value
          : this.serviceCharge,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceOrder(')
          ..write('id: $id, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('fullName: $fullName, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('emailAddress: $emailAddress, ')
          ..write('address: $address, ')
          ..write('barangay: $barangay, ')
          ..write('city: $city, ')
          ..write('provider: $provider, ')
          ..write('plan: $plan, ')
          ..write('username: $username, ')
          ..write('connectionType: $connectionType, ')
          ..write('routerModemSN: $routerModemSN, ')
          ..write('lcp: $lcp, ')
          ..write('nap: $nap, ')
          ..write('port: $port, ')
          ..write('vlan: $vlan, ')
          ..write('supportStatus: $supportStatus, ')
          ..write('concern: $concern, ')
          ..write('priorityLevel: $priorityLevel, ')
          ..write('visitStatus: $visitStatus, ')
          ..write('visitBy: $visitBy, ')
          ..write('visitRemarks: $visitRemarks, ')
          ..write('assignedEmail: $assignedEmail, ')
          ..write('createdDate: $createdDate, ')
          ..write('dateInstalled: $dateInstalled, ')
          ..write('newRouterModemSN: $newRouterModemSN, ')
          ..write('newLCP: $newLCP, ')
          ..write('newNAP: $newNAP, ')
          ..write('newPORT: $newPORT, ')
          ..write('newVLAN: $newVLAN, ')
          ..write('routerModel: $routerModel, ')
          ..write('pulloutRouterModel: $pulloutRouterModel, ')
          ..write('pulloutRouterModelSN: $pulloutRouterModelSN, ')
          ..write('pulloutRemarks: $pulloutRemarks, ')
          ..write('materialsUsedJson: $materialsUsedJson, ')
          ..write('clientSignature: $clientSignature, ')
          ..write('image1: $image1, ')
          ..write('image2: $image2, ')
          ..write('image3: $image3, ')
          ..write('houseFrontPicture: $houseFrontPicture, ')
          ..write('addressCoordinates: $addressCoordinates, ')
          ..write('serviceCharge: $serviceCharge, ')
          ..write('rawJson: $rawJson, ')
          ..write('isSynced: $isSynced, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        accountNumber,
        fullName,
        contactNumber,
        emailAddress,
        address,
        barangay,
        city,
        provider,
        plan,
        username,
        connectionType,
        routerModemSN,
        lcp,
        nap,
        port,
        vlan,
        supportStatus,
        concern,
        priorityLevel,
        visitStatus,
        visitBy,
        visitRemarks,
        assignedEmail,
        createdDate,
        dateInstalled,
        newRouterModemSN,
        newLCP,
        newNAP,
        newPORT,
        newVLAN,
        routerModel,
        pulloutRouterModel,
        pulloutRouterModelSN,
        pulloutRemarks,
        materialsUsedJson,
        clientSignature,
        image1,
        image2,
        image3,
        houseFrontPicture,
        addressCoordinates,
        serviceCharge,
        rawJson,
        isSynced,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceOrder &&
          other.id == this.id &&
          other.accountNumber == this.accountNumber &&
          other.fullName == this.fullName &&
          other.contactNumber == this.contactNumber &&
          other.emailAddress == this.emailAddress &&
          other.address == this.address &&
          other.barangay == this.barangay &&
          other.city == this.city &&
          other.provider == this.provider &&
          other.plan == this.plan &&
          other.username == this.username &&
          other.connectionType == this.connectionType &&
          other.routerModemSN == this.routerModemSN &&
          other.lcp == this.lcp &&
          other.nap == this.nap &&
          other.port == this.port &&
          other.vlan == this.vlan &&
          other.supportStatus == this.supportStatus &&
          other.concern == this.concern &&
          other.priorityLevel == this.priorityLevel &&
          other.visitStatus == this.visitStatus &&
          other.visitBy == this.visitBy &&
          other.visitRemarks == this.visitRemarks &&
          other.assignedEmail == this.assignedEmail &&
          other.createdDate == this.createdDate &&
          other.dateInstalled == this.dateInstalled &&
          other.newRouterModemSN == this.newRouterModemSN &&
          other.newLCP == this.newLCP &&
          other.newNAP == this.newNAP &&
          other.newPORT == this.newPORT &&
          other.newVLAN == this.newVLAN &&
          other.routerModel == this.routerModel &&
          other.pulloutRouterModel == this.pulloutRouterModel &&
          other.pulloutRouterModelSN == this.pulloutRouterModelSN &&
          other.pulloutRemarks == this.pulloutRemarks &&
          other.materialsUsedJson == this.materialsUsedJson &&
          other.clientSignature == this.clientSignature &&
          other.image1 == this.image1 &&
          other.image2 == this.image2 &&
          other.image3 == this.image3 &&
          other.houseFrontPicture == this.houseFrontPicture &&
          other.addressCoordinates == this.addressCoordinates &&
          other.serviceCharge == this.serviceCharge &&
          other.rawJson == this.rawJson &&
          other.isSynced == this.isSynced &&
          other.updatedAt == this.updatedAt);
}

class ServiceOrdersCompanion extends UpdateCompanion<ServiceOrder> {
  final Value<int> id;
  final Value<String> accountNumber;
  final Value<String> fullName;
  final Value<String?> contactNumber;
  final Value<String?> emailAddress;
  final Value<String> address;
  final Value<String?> barangay;
  final Value<String?> city;
  final Value<String?> provider;
  final Value<String?> plan;
  final Value<String?> username;
  final Value<String?> connectionType;
  final Value<String?> routerModemSN;
  final Value<String?> lcp;
  final Value<String?> nap;
  final Value<String?> port;
  final Value<String?> vlan;
  final Value<String> supportStatus;
  final Value<String> concern;
  final Value<String?> priorityLevel;
  final Value<String?> visitStatus;
  final Value<String?> visitBy;
  final Value<String?> visitRemarks;
  final Value<String?> assignedEmail;
  final Value<DateTime?> createdDate;
  final Value<DateTime?> dateInstalled;
  final Value<String?> newRouterModemSN;
  final Value<String?> newLCP;
  final Value<String?> newNAP;
  final Value<String?> newPORT;
  final Value<String?> newVLAN;
  final Value<String?> routerModel;
  final Value<String?> pulloutRouterModel;
  final Value<String?> pulloutRouterModelSN;
  final Value<String?> pulloutRemarks;
  final Value<String?> materialsUsedJson;
  final Value<String?> clientSignature;
  final Value<String?> image1;
  final Value<String?> image2;
  final Value<String?> image3;
  final Value<String?> houseFrontPicture;
  final Value<String?> addressCoordinates;
  final Value<double> serviceCharge;
  final Value<String?> rawJson;
  final Value<bool> isSynced;
  final Value<DateTime> updatedAt;
  const ServiceOrdersCompanion({
    this.id = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.fullName = const Value.absent(),
    this.contactNumber = const Value.absent(),
    this.emailAddress = const Value.absent(),
    this.address = const Value.absent(),
    this.barangay = const Value.absent(),
    this.city = const Value.absent(),
    this.provider = const Value.absent(),
    this.plan = const Value.absent(),
    this.username = const Value.absent(),
    this.connectionType = const Value.absent(),
    this.routerModemSN = const Value.absent(),
    this.lcp = const Value.absent(),
    this.nap = const Value.absent(),
    this.port = const Value.absent(),
    this.vlan = const Value.absent(),
    this.supportStatus = const Value.absent(),
    this.concern = const Value.absent(),
    this.priorityLevel = const Value.absent(),
    this.visitStatus = const Value.absent(),
    this.visitBy = const Value.absent(),
    this.visitRemarks = const Value.absent(),
    this.assignedEmail = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.dateInstalled = const Value.absent(),
    this.newRouterModemSN = const Value.absent(),
    this.newLCP = const Value.absent(),
    this.newNAP = const Value.absent(),
    this.newPORT = const Value.absent(),
    this.newVLAN = const Value.absent(),
    this.routerModel = const Value.absent(),
    this.pulloutRouterModel = const Value.absent(),
    this.pulloutRouterModelSN = const Value.absent(),
    this.pulloutRemarks = const Value.absent(),
    this.materialsUsedJson = const Value.absent(),
    this.clientSignature = const Value.absent(),
    this.image1 = const Value.absent(),
    this.image2 = const Value.absent(),
    this.image3 = const Value.absent(),
    this.houseFrontPicture = const Value.absent(),
    this.addressCoordinates = const Value.absent(),
    this.serviceCharge = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ServiceOrdersCompanion.insert({
    this.id = const Value.absent(),
    required String accountNumber,
    required String fullName,
    this.contactNumber = const Value.absent(),
    this.emailAddress = const Value.absent(),
    required String address,
    this.barangay = const Value.absent(),
    this.city = const Value.absent(),
    this.provider = const Value.absent(),
    this.plan = const Value.absent(),
    this.username = const Value.absent(),
    this.connectionType = const Value.absent(),
    this.routerModemSN = const Value.absent(),
    this.lcp = const Value.absent(),
    this.nap = const Value.absent(),
    this.port = const Value.absent(),
    this.vlan = const Value.absent(),
    this.supportStatus = const Value.absent(),
    this.concern = const Value.absent(),
    this.priorityLevel = const Value.absent(),
    this.visitStatus = const Value.absent(),
    this.visitBy = const Value.absent(),
    this.visitRemarks = const Value.absent(),
    this.assignedEmail = const Value.absent(),
    this.createdDate = const Value.absent(),
    this.dateInstalled = const Value.absent(),
    this.newRouterModemSN = const Value.absent(),
    this.newLCP = const Value.absent(),
    this.newNAP = const Value.absent(),
    this.newPORT = const Value.absent(),
    this.newVLAN = const Value.absent(),
    this.routerModel = const Value.absent(),
    this.pulloutRouterModel = const Value.absent(),
    this.pulloutRouterModelSN = const Value.absent(),
    this.pulloutRemarks = const Value.absent(),
    this.materialsUsedJson = const Value.absent(),
    this.clientSignature = const Value.absent(),
    this.image1 = const Value.absent(),
    this.image2 = const Value.absent(),
    this.image3 = const Value.absent(),
    this.houseFrontPicture = const Value.absent(),
    this.addressCoordinates = const Value.absent(),
    this.serviceCharge = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : accountNumber = Value(accountNumber),
        fullName = Value(fullName),
        address = Value(address);
  static Insertable<ServiceOrder> custom({
    Expression<int>? id,
    Expression<String>? accountNumber,
    Expression<String>? fullName,
    Expression<String>? contactNumber,
    Expression<String>? emailAddress,
    Expression<String>? address,
    Expression<String>? barangay,
    Expression<String>? city,
    Expression<String>? provider,
    Expression<String>? plan,
    Expression<String>? username,
    Expression<String>? connectionType,
    Expression<String>? routerModemSN,
    Expression<String>? lcp,
    Expression<String>? nap,
    Expression<String>? port,
    Expression<String>? vlan,
    Expression<String>? supportStatus,
    Expression<String>? concern,
    Expression<String>? priorityLevel,
    Expression<String>? visitStatus,
    Expression<String>? visitBy,
    Expression<String>? visitRemarks,
    Expression<String>? assignedEmail,
    Expression<DateTime>? createdDate,
    Expression<DateTime>? dateInstalled,
    Expression<String>? newRouterModemSN,
    Expression<String>? newLCP,
    Expression<String>? newNAP,
    Expression<String>? newPORT,
    Expression<String>? newVLAN,
    Expression<String>? routerModel,
    Expression<String>? pulloutRouterModel,
    Expression<String>? pulloutRouterModelSN,
    Expression<String>? pulloutRemarks,
    Expression<String>? materialsUsedJson,
    Expression<String>? clientSignature,
    Expression<String>? image1,
    Expression<String>? image2,
    Expression<String>? image3,
    Expression<String>? houseFrontPicture,
    Expression<String>? addressCoordinates,
    Expression<double>? serviceCharge,
    Expression<String>? rawJson,
    Expression<bool>? isSynced,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountNumber != null) 'account_number': accountNumber,
      if (fullName != null) 'full_name': fullName,
      if (contactNumber != null) 'contact_number': contactNumber,
      if (emailAddress != null) 'email_address': emailAddress,
      if (address != null) 'address': address,
      if (barangay != null) 'barangay': barangay,
      if (city != null) 'city': city,
      if (provider != null) 'provider': provider,
      if (plan != null) 'plan': plan,
      if (username != null) 'username': username,
      if (connectionType != null) 'connection_type': connectionType,
      if (routerModemSN != null) 'router_modem_s_n': routerModemSN,
      if (lcp != null) 'lcp': lcp,
      if (nap != null) 'nap': nap,
      if (port != null) 'port': port,
      if (vlan != null) 'vlan': vlan,
      if (supportStatus != null) 'support_status': supportStatus,
      if (concern != null) 'concern': concern,
      if (priorityLevel != null) 'priority_level': priorityLevel,
      if (visitStatus != null) 'visit_status': visitStatus,
      if (visitBy != null) 'visit_by': visitBy,
      if (visitRemarks != null) 'visit_remarks': visitRemarks,
      if (assignedEmail != null) 'assigned_email': assignedEmail,
      if (createdDate != null) 'created_date': createdDate,
      if (dateInstalled != null) 'date_installed': dateInstalled,
      if (newRouterModemSN != null) 'new_router_modem_s_n': newRouterModemSN,
      if (newLCP != null) 'new_l_c_p': newLCP,
      if (newNAP != null) 'new_n_a_p': newNAP,
      if (newPORT != null) 'new_p_o_r_t': newPORT,
      if (newVLAN != null) 'new_v_l_a_n': newVLAN,
      if (routerModel != null) 'router_model': routerModel,
      if (pulloutRouterModel != null)
        'pullout_router_model': pulloutRouterModel,
      if (pulloutRouterModelSN != null)
        'pullout_router_model_s_n': pulloutRouterModelSN,
      if (pulloutRemarks != null) 'pullout_remarks': pulloutRemarks,
      if (materialsUsedJson != null) 'materials_used_json': materialsUsedJson,
      if (clientSignature != null) 'client_signature': clientSignature,
      if (image1 != null) 'image1': image1,
      if (image2 != null) 'image2': image2,
      if (image3 != null) 'image3': image3,
      if (houseFrontPicture != null) 'house_front_picture': houseFrontPicture,
      if (addressCoordinates != null) 'address_coordinates': addressCoordinates,
      if (serviceCharge != null) 'service_charge': serviceCharge,
      if (rawJson != null) 'raw_json': rawJson,
      if (isSynced != null) 'is_synced': isSynced,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ServiceOrdersCompanion copyWith(
      {Value<int>? id,
      Value<String>? accountNumber,
      Value<String>? fullName,
      Value<String?>? contactNumber,
      Value<String?>? emailAddress,
      Value<String>? address,
      Value<String?>? barangay,
      Value<String?>? city,
      Value<String?>? provider,
      Value<String?>? plan,
      Value<String?>? username,
      Value<String?>? connectionType,
      Value<String?>? routerModemSN,
      Value<String?>? lcp,
      Value<String?>? nap,
      Value<String?>? port,
      Value<String?>? vlan,
      Value<String>? supportStatus,
      Value<String>? concern,
      Value<String?>? priorityLevel,
      Value<String?>? visitStatus,
      Value<String?>? visitBy,
      Value<String?>? visitRemarks,
      Value<String?>? assignedEmail,
      Value<DateTime?>? createdDate,
      Value<DateTime?>? dateInstalled,
      Value<String?>? newRouterModemSN,
      Value<String?>? newLCP,
      Value<String?>? newNAP,
      Value<String?>? newPORT,
      Value<String?>? newVLAN,
      Value<String?>? routerModel,
      Value<String?>? pulloutRouterModel,
      Value<String?>? pulloutRouterModelSN,
      Value<String?>? pulloutRemarks,
      Value<String?>? materialsUsedJson,
      Value<String?>? clientSignature,
      Value<String?>? image1,
      Value<String?>? image2,
      Value<String?>? image3,
      Value<String?>? houseFrontPicture,
      Value<String?>? addressCoordinates,
      Value<double>? serviceCharge,
      Value<String?>? rawJson,
      Value<bool>? isSynced,
      Value<DateTime>? updatedAt}) {
    return ServiceOrdersCompanion(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      fullName: fullName ?? this.fullName,
      contactNumber: contactNumber ?? this.contactNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      address: address ?? this.address,
      barangay: barangay ?? this.barangay,
      city: city ?? this.city,
      provider: provider ?? this.provider,
      plan: plan ?? this.plan,
      username: username ?? this.username,
      connectionType: connectionType ?? this.connectionType,
      routerModemSN: routerModemSN ?? this.routerModemSN,
      lcp: lcp ?? this.lcp,
      nap: nap ?? this.nap,
      port: port ?? this.port,
      vlan: vlan ?? this.vlan,
      supportStatus: supportStatus ?? this.supportStatus,
      concern: concern ?? this.concern,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      visitStatus: visitStatus ?? this.visitStatus,
      visitBy: visitBy ?? this.visitBy,
      visitRemarks: visitRemarks ?? this.visitRemarks,
      assignedEmail: assignedEmail ?? this.assignedEmail,
      createdDate: createdDate ?? this.createdDate,
      dateInstalled: dateInstalled ?? this.dateInstalled,
      newRouterModemSN: newRouterModemSN ?? this.newRouterModemSN,
      newLCP: newLCP ?? this.newLCP,
      newNAP: newNAP ?? this.newNAP,
      newPORT: newPORT ?? this.newPORT,
      newVLAN: newVLAN ?? this.newVLAN,
      routerModel: routerModel ?? this.routerModel,
      pulloutRouterModel: pulloutRouterModel ?? this.pulloutRouterModel,
      pulloutRouterModelSN: pulloutRouterModelSN ?? this.pulloutRouterModelSN,
      pulloutRemarks: pulloutRemarks ?? this.pulloutRemarks,
      materialsUsedJson: materialsUsedJson ?? this.materialsUsedJson,
      clientSignature: clientSignature ?? this.clientSignature,
      image1: image1 ?? this.image1,
      image2: image2 ?? this.image2,
      image3: image3 ?? this.image3,
      houseFrontPicture: houseFrontPicture ?? this.houseFrontPicture,
      addressCoordinates: addressCoordinates ?? this.addressCoordinates,
      serviceCharge: serviceCharge ?? this.serviceCharge,
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
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (contactNumber.present) {
      map['contact_number'] = Variable<String>(contactNumber.value);
    }
    if (emailAddress.present) {
      map['email_address'] = Variable<String>(emailAddress.value);
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
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (plan.present) {
      map['plan'] = Variable<String>(plan.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (connectionType.present) {
      map['connection_type'] = Variable<String>(connectionType.value);
    }
    if (routerModemSN.present) {
      map['router_modem_s_n'] = Variable<String>(routerModemSN.value);
    }
    if (lcp.present) {
      map['lcp'] = Variable<String>(lcp.value);
    }
    if (nap.present) {
      map['nap'] = Variable<String>(nap.value);
    }
    if (port.present) {
      map['port'] = Variable<String>(port.value);
    }
    if (vlan.present) {
      map['vlan'] = Variable<String>(vlan.value);
    }
    if (supportStatus.present) {
      map['support_status'] = Variable<String>(supportStatus.value);
    }
    if (concern.present) {
      map['concern'] = Variable<String>(concern.value);
    }
    if (priorityLevel.present) {
      map['priority_level'] = Variable<String>(priorityLevel.value);
    }
    if (visitStatus.present) {
      map['visit_status'] = Variable<String>(visitStatus.value);
    }
    if (visitBy.present) {
      map['visit_by'] = Variable<String>(visitBy.value);
    }
    if (visitRemarks.present) {
      map['visit_remarks'] = Variable<String>(visitRemarks.value);
    }
    if (assignedEmail.present) {
      map['assigned_email'] = Variable<String>(assignedEmail.value);
    }
    if (createdDate.present) {
      map['created_date'] = Variable<DateTime>(createdDate.value);
    }
    if (dateInstalled.present) {
      map['date_installed'] = Variable<DateTime>(dateInstalled.value);
    }
    if (newRouterModemSN.present) {
      map['new_router_modem_s_n'] = Variable<String>(newRouterModemSN.value);
    }
    if (newLCP.present) {
      map['new_l_c_p'] = Variable<String>(newLCP.value);
    }
    if (newNAP.present) {
      map['new_n_a_p'] = Variable<String>(newNAP.value);
    }
    if (newPORT.present) {
      map['new_p_o_r_t'] = Variable<String>(newPORT.value);
    }
    if (newVLAN.present) {
      map['new_v_l_a_n'] = Variable<String>(newVLAN.value);
    }
    if (routerModel.present) {
      map['router_model'] = Variable<String>(routerModel.value);
    }
    if (pulloutRouterModel.present) {
      map['pullout_router_model'] = Variable<String>(pulloutRouterModel.value);
    }
    if (pulloutRouterModelSN.present) {
      map['pullout_router_model_s_n'] =
          Variable<String>(pulloutRouterModelSN.value);
    }
    if (pulloutRemarks.present) {
      map['pullout_remarks'] = Variable<String>(pulloutRemarks.value);
    }
    if (materialsUsedJson.present) {
      map['materials_used_json'] = Variable<String>(materialsUsedJson.value);
    }
    if (clientSignature.present) {
      map['client_signature'] = Variable<String>(clientSignature.value);
    }
    if (image1.present) {
      map['image1'] = Variable<String>(image1.value);
    }
    if (image2.present) {
      map['image2'] = Variable<String>(image2.value);
    }
    if (image3.present) {
      map['image3'] = Variable<String>(image3.value);
    }
    if (houseFrontPicture.present) {
      map['house_front_picture'] = Variable<String>(houseFrontPicture.value);
    }
    if (addressCoordinates.present) {
      map['address_coordinates'] = Variable<String>(addressCoordinates.value);
    }
    if (serviceCharge.present) {
      map['service_charge'] = Variable<double>(serviceCharge.value);
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
    return (StringBuffer('ServiceOrdersCompanion(')
          ..write('id: $id, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('fullName: $fullName, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('emailAddress: $emailAddress, ')
          ..write('address: $address, ')
          ..write('barangay: $barangay, ')
          ..write('city: $city, ')
          ..write('provider: $provider, ')
          ..write('plan: $plan, ')
          ..write('username: $username, ')
          ..write('connectionType: $connectionType, ')
          ..write('routerModemSN: $routerModemSN, ')
          ..write('lcp: $lcp, ')
          ..write('nap: $nap, ')
          ..write('port: $port, ')
          ..write('vlan: $vlan, ')
          ..write('supportStatus: $supportStatus, ')
          ..write('concern: $concern, ')
          ..write('priorityLevel: $priorityLevel, ')
          ..write('visitStatus: $visitStatus, ')
          ..write('visitBy: $visitBy, ')
          ..write('visitRemarks: $visitRemarks, ')
          ..write('assignedEmail: $assignedEmail, ')
          ..write('createdDate: $createdDate, ')
          ..write('dateInstalled: $dateInstalled, ')
          ..write('newRouterModemSN: $newRouterModemSN, ')
          ..write('newLCP: $newLCP, ')
          ..write('newNAP: $newNAP, ')
          ..write('newPORT: $newPORT, ')
          ..write('newVLAN: $newVLAN, ')
          ..write('routerModel: $routerModel, ')
          ..write('pulloutRouterModel: $pulloutRouterModel, ')
          ..write('pulloutRouterModelSN: $pulloutRouterModelSN, ')
          ..write('pulloutRemarks: $pulloutRemarks, ')
          ..write('materialsUsedJson: $materialsUsedJson, ')
          ..write('clientSignature: $clientSignature, ')
          ..write('image1: $image1, ')
          ..write('image2: $image2, ')
          ..write('image3: $image3, ')
          ..write('houseFrontPicture: $houseFrontPicture, ')
          ..write('addressCoordinates: $addressCoordinates, ')
          ..write('serviceCharge: $serviceCharge, ')
          ..write('rawJson: $rawJson, ')
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
  late final $ServiceOrdersTable serviceOrders = $ServiceOrdersTable(this);
  late final JobOrdersDao jobOrdersDao = JobOrdersDao(this as AppDatabase);
  late final LcpNapLocationsDao lcpNapLocationsDao =
      LcpNapLocationsDao(this as AppDatabase);
  late final ServiceOrdersDao serviceOrdersDao =
      ServiceOrdersDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [jobOrders, syncQueues, lcpNapLocations, serviceOrders];
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
  Value<String?> nap,
  Value<String?> portId,
  Value<int?> vlanId,
  Value<DateTime?> dateInstalled,
  Value<String?> boxReadingImage,
  Value<String?> routerReadingImage,
  Value<String?> clientSignature,
  Value<String?> setupImage,
  Value<String?> speedtestImage,
  Value<String?> portLabelImage,
  Value<String?> signedContractImage,
  Value<String?> houseFront,
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
  Value<String?> nap,
  Value<String?> portId,
  Value<int?> vlanId,
  Value<DateTime?> dateInstalled,
  Value<String?> boxReadingImage,
  Value<String?> routerReadingImage,
  Value<String?> clientSignature,
  Value<String?> setupImage,
  Value<String?> speedtestImage,
  Value<String?> portLabelImage,
  Value<String?> signedContractImage,
  Value<String?> houseFront,
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

  ColumnFilters<String> get nap => $composableBuilder(
      column: $table.nap, builder: (column) => ColumnFilters(column));

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

  ColumnFilters<String> get setupImage => $composableBuilder(
      column: $table.setupImage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get speedtestImage => $composableBuilder(
      column: $table.speedtestImage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get portLabelImage => $composableBuilder(
      column: $table.portLabelImage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get signedContractImage => $composableBuilder(
      column: $table.signedContractImage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get houseFront => $composableBuilder(
      column: $table.houseFront, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get nap => $composableBuilder(
      column: $table.nap, builder: (column) => ColumnOrderings(column));

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

  ColumnOrderings<String> get setupImage => $composableBuilder(
      column: $table.setupImage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get speedtestImage => $composableBuilder(
      column: $table.speedtestImage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get portLabelImage => $composableBuilder(
      column: $table.portLabelImage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get signedContractImage => $composableBuilder(
      column: $table.signedContractImage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get houseFront => $composableBuilder(
      column: $table.houseFront, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get nap =>
      $composableBuilder(column: $table.nap, builder: (column) => column);

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

  GeneratedColumn<String> get setupImage => $composableBuilder(
      column: $table.setupImage, builder: (column) => column);

  GeneratedColumn<String> get speedtestImage => $composableBuilder(
      column: $table.speedtestImage, builder: (column) => column);

  GeneratedColumn<String> get portLabelImage => $composableBuilder(
      column: $table.portLabelImage, builder: (column) => column);

  GeneratedColumn<String> get signedContractImage => $composableBuilder(
      column: $table.signedContractImage, builder: (column) => column);

  GeneratedColumn<String> get houseFront => $composableBuilder(
      column: $table.houseFront, builder: (column) => column);

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
            Value<String?> nap = const Value.absent(),
            Value<String?> portId = const Value.absent(),
            Value<int?> vlanId = const Value.absent(),
            Value<DateTime?> dateInstalled = const Value.absent(),
            Value<String?> boxReadingImage = const Value.absent(),
            Value<String?> routerReadingImage = const Value.absent(),
            Value<String?> clientSignature = const Value.absent(),
            Value<String?> setupImage = const Value.absent(),
            Value<String?> speedtestImage = const Value.absent(),
            Value<String?> portLabelImage = const Value.absent(),
            Value<String?> signedContractImage = const Value.absent(),
            Value<String?> houseFront = const Value.absent(),
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
            nap: nap,
            portId: portId,
            vlanId: vlanId,
            dateInstalled: dateInstalled,
            boxReadingImage: boxReadingImage,
            routerReadingImage: routerReadingImage,
            clientSignature: clientSignature,
            setupImage: setupImage,
            speedtestImage: speedtestImage,
            portLabelImage: portLabelImage,
            signedContractImage: signedContractImage,
            houseFront: houseFront,
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
            Value<String?> nap = const Value.absent(),
            Value<String?> portId = const Value.absent(),
            Value<int?> vlanId = const Value.absent(),
            Value<DateTime?> dateInstalled = const Value.absent(),
            Value<String?> boxReadingImage = const Value.absent(),
            Value<String?> routerReadingImage = const Value.absent(),
            Value<String?> clientSignature = const Value.absent(),
            Value<String?> setupImage = const Value.absent(),
            Value<String?> speedtestImage = const Value.absent(),
            Value<String?> portLabelImage = const Value.absent(),
            Value<String?> signedContractImage = const Value.absent(),
            Value<String?> houseFront = const Value.absent(),
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
            nap: nap,
            portId: portId,
            vlanId: vlanId,
            dateInstalled: dateInstalled,
            boxReadingImage: boxReadingImage,
            routerReadingImage: routerReadingImage,
            clientSignature: clientSignature,
            setupImage: setupImage,
            speedtestImage: speedtestImage,
            portLabelImage: portLabelImage,
            signedContractImage: signedContractImage,
            houseFront: houseFront,
            assignedEmail: assignedEmail,
            modifiedDate: modifiedDate,
            rawJson: rawJson,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$JobOrdersTable, JobOrder>(table),
                    BaseReferences<_$AppDatabase, $JobOrdersTable, JobOrder>(
                        db, table, e)
                  ))
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
              .map((e) => (
                    e.readTable<$SyncQueuesTable, SyncQueue>(table),
                    BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>(
                        db, table, e)
                  ))
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
              .map((e) => (
                    e.readTable<$LcpNapLocationsTable, LcpNapLocation>(table),
                    BaseReferences<_$AppDatabase, $LcpNapLocationsTable,
                        LcpNapLocation>(db, table, e)
                  ))
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
typedef $$ServiceOrdersTableCreateCompanionBuilder = ServiceOrdersCompanion
    Function({
  Value<int> id,
  required String accountNumber,
  required String fullName,
  Value<String?> contactNumber,
  Value<String?> emailAddress,
  required String address,
  Value<String?> barangay,
  Value<String?> city,
  Value<String?> provider,
  Value<String?> plan,
  Value<String?> username,
  Value<String?> connectionType,
  Value<String?> routerModemSN,
  Value<String?> lcp,
  Value<String?> nap,
  Value<String?> port,
  Value<String?> vlan,
  Value<String> supportStatus,
  Value<String> concern,
  Value<String?> priorityLevel,
  Value<String?> visitStatus,
  Value<String?> visitBy,
  Value<String?> visitRemarks,
  Value<String?> assignedEmail,
  Value<DateTime?> createdDate,
  Value<DateTime?> dateInstalled,
  Value<String?> newRouterModemSN,
  Value<String?> newLCP,
  Value<String?> newNAP,
  Value<String?> newPORT,
  Value<String?> newVLAN,
  Value<String?> routerModel,
  Value<String?> pulloutRouterModel,
  Value<String?> pulloutRouterModelSN,
  Value<String?> pulloutRemarks,
  Value<String?> materialsUsedJson,
  Value<String?> clientSignature,
  Value<String?> image1,
  Value<String?> image2,
  Value<String?> image3,
  Value<String?> houseFrontPicture,
  Value<String?> addressCoordinates,
  Value<double> serviceCharge,
  Value<String?> rawJson,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});
typedef $$ServiceOrdersTableUpdateCompanionBuilder = ServiceOrdersCompanion
    Function({
  Value<int> id,
  Value<String> accountNumber,
  Value<String> fullName,
  Value<String?> contactNumber,
  Value<String?> emailAddress,
  Value<String> address,
  Value<String?> barangay,
  Value<String?> city,
  Value<String?> provider,
  Value<String?> plan,
  Value<String?> username,
  Value<String?> connectionType,
  Value<String?> routerModemSN,
  Value<String?> lcp,
  Value<String?> nap,
  Value<String?> port,
  Value<String?> vlan,
  Value<String> supportStatus,
  Value<String> concern,
  Value<String?> priorityLevel,
  Value<String?> visitStatus,
  Value<String?> visitBy,
  Value<String?> visitRemarks,
  Value<String?> assignedEmail,
  Value<DateTime?> createdDate,
  Value<DateTime?> dateInstalled,
  Value<String?> newRouterModemSN,
  Value<String?> newLCP,
  Value<String?> newNAP,
  Value<String?> newPORT,
  Value<String?> newVLAN,
  Value<String?> routerModel,
  Value<String?> pulloutRouterModel,
  Value<String?> pulloutRouterModelSN,
  Value<String?> pulloutRemarks,
  Value<String?> materialsUsedJson,
  Value<String?> clientSignature,
  Value<String?> image1,
  Value<String?> image2,
  Value<String?> image3,
  Value<String?> houseFrontPicture,
  Value<String?> addressCoordinates,
  Value<double> serviceCharge,
  Value<String?> rawJson,
  Value<bool> isSynced,
  Value<DateTime> updatedAt,
});

class $$ServiceOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceOrdersTable> {
  $$ServiceOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactNumber => $composableBuilder(
      column: $table.contactNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emailAddress => $composableBuilder(
      column: $table.emailAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barangay => $composableBuilder(
      column: $table.barangay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plan => $composableBuilder(
      column: $table.plan, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get connectionType => $composableBuilder(
      column: $table.connectionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routerModemSN => $composableBuilder(
      column: $table.routerModemSN, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lcp => $composableBuilder(
      column: $table.lcp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nap => $composableBuilder(
      column: $table.nap, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get port => $composableBuilder(
      column: $table.port, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vlan => $composableBuilder(
      column: $table.vlan, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supportStatus => $composableBuilder(
      column: $table.supportStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get concern => $composableBuilder(
      column: $table.concern, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priorityLevel => $composableBuilder(
      column: $table.priorityLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get visitStatus => $composableBuilder(
      column: $table.visitStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get visitBy => $composableBuilder(
      column: $table.visitBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get visitRemarks => $composableBuilder(
      column: $table.visitRemarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assignedEmail => $composableBuilder(
      column: $table.assignedEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdDate => $composableBuilder(
      column: $table.createdDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateInstalled => $composableBuilder(
      column: $table.dateInstalled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get newRouterModemSN => $composableBuilder(
      column: $table.newRouterModemSN,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get newLCP => $composableBuilder(
      column: $table.newLCP, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get newNAP => $composableBuilder(
      column: $table.newNAP, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get newPORT => $composableBuilder(
      column: $table.newPORT, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get newVLAN => $composableBuilder(
      column: $table.newVLAN, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get routerModel => $composableBuilder(
      column: $table.routerModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pulloutRouterModel => $composableBuilder(
      column: $table.pulloutRouterModel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pulloutRouterModelSN => $composableBuilder(
      column: $table.pulloutRouterModelSN,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pulloutRemarks => $composableBuilder(
      column: $table.pulloutRemarks,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get materialsUsedJson => $composableBuilder(
      column: $table.materialsUsedJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientSignature => $composableBuilder(
      column: $table.clientSignature,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image1 => $composableBuilder(
      column: $table.image1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image2 => $composableBuilder(
      column: $table.image2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image3 => $composableBuilder(
      column: $table.image3, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get houseFrontPicture => $composableBuilder(
      column: $table.houseFrontPicture,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get addressCoordinates => $composableBuilder(
      column: $table.addressCoordinates,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get serviceCharge => $composableBuilder(
      column: $table.serviceCharge, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ServiceOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceOrdersTable> {
  $$ServiceOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactNumber => $composableBuilder(
      column: $table.contactNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emailAddress => $composableBuilder(
      column: $table.emailAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barangay => $composableBuilder(
      column: $table.barangay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plan => $composableBuilder(
      column: $table.plan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get connectionType => $composableBuilder(
      column: $table.connectionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routerModemSN => $composableBuilder(
      column: $table.routerModemSN,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lcp => $composableBuilder(
      column: $table.lcp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nap => $composableBuilder(
      column: $table.nap, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get port => $composableBuilder(
      column: $table.port, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vlan => $composableBuilder(
      column: $table.vlan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supportStatus => $composableBuilder(
      column: $table.supportStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get concern => $composableBuilder(
      column: $table.concern, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priorityLevel => $composableBuilder(
      column: $table.priorityLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visitStatus => $composableBuilder(
      column: $table.visitStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visitBy => $composableBuilder(
      column: $table.visitBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visitRemarks => $composableBuilder(
      column: $table.visitRemarks,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assignedEmail => $composableBuilder(
      column: $table.assignedEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdDate => $composableBuilder(
      column: $table.createdDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateInstalled => $composableBuilder(
      column: $table.dateInstalled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get newRouterModemSN => $composableBuilder(
      column: $table.newRouterModemSN,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get newLCP => $composableBuilder(
      column: $table.newLCP, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get newNAP => $composableBuilder(
      column: $table.newNAP, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get newPORT => $composableBuilder(
      column: $table.newPORT, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get newVLAN => $composableBuilder(
      column: $table.newVLAN, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get routerModel => $composableBuilder(
      column: $table.routerModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pulloutRouterModel => $composableBuilder(
      column: $table.pulloutRouterModel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pulloutRouterModelSN => $composableBuilder(
      column: $table.pulloutRouterModelSN,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pulloutRemarks => $composableBuilder(
      column: $table.pulloutRemarks,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get materialsUsedJson => $composableBuilder(
      column: $table.materialsUsedJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientSignature => $composableBuilder(
      column: $table.clientSignature,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image1 => $composableBuilder(
      column: $table.image1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image2 => $composableBuilder(
      column: $table.image2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image3 => $composableBuilder(
      column: $table.image3, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get houseFrontPicture => $composableBuilder(
      column: $table.houseFrontPicture,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get addressCoordinates => $composableBuilder(
      column: $table.addressCoordinates,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get serviceCharge => $composableBuilder(
      column: $table.serviceCharge,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ServiceOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceOrdersTable> {
  $$ServiceOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get contactNumber => $composableBuilder(
      column: $table.contactNumber, builder: (column) => column);

  GeneratedColumn<String> get emailAddress => $composableBuilder(
      column: $table.emailAddress, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get barangay =>
      $composableBuilder(column: $table.barangay, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get plan =>
      $composableBuilder(column: $table.plan, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get connectionType => $composableBuilder(
      column: $table.connectionType, builder: (column) => column);

  GeneratedColumn<String> get routerModemSN => $composableBuilder(
      column: $table.routerModemSN, builder: (column) => column);

  GeneratedColumn<String> get lcp =>
      $composableBuilder(column: $table.lcp, builder: (column) => column);

  GeneratedColumn<String> get nap =>
      $composableBuilder(column: $table.nap, builder: (column) => column);

  GeneratedColumn<String> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get vlan =>
      $composableBuilder(column: $table.vlan, builder: (column) => column);

  GeneratedColumn<String> get supportStatus => $composableBuilder(
      column: $table.supportStatus, builder: (column) => column);

  GeneratedColumn<String> get concern =>
      $composableBuilder(column: $table.concern, builder: (column) => column);

  GeneratedColumn<String> get priorityLevel => $composableBuilder(
      column: $table.priorityLevel, builder: (column) => column);

  GeneratedColumn<String> get visitStatus => $composableBuilder(
      column: $table.visitStatus, builder: (column) => column);

  GeneratedColumn<String> get visitBy =>
      $composableBuilder(column: $table.visitBy, builder: (column) => column);

  GeneratedColumn<String> get visitRemarks => $composableBuilder(
      column: $table.visitRemarks, builder: (column) => column);

  GeneratedColumn<String> get assignedEmail => $composableBuilder(
      column: $table.assignedEmail, builder: (column) => column);

  GeneratedColumn<DateTime> get createdDate => $composableBuilder(
      column: $table.createdDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dateInstalled => $composableBuilder(
      column: $table.dateInstalled, builder: (column) => column);

  GeneratedColumn<String> get newRouterModemSN => $composableBuilder(
      column: $table.newRouterModemSN, builder: (column) => column);

  GeneratedColumn<String> get newLCP =>
      $composableBuilder(column: $table.newLCP, builder: (column) => column);

  GeneratedColumn<String> get newNAP =>
      $composableBuilder(column: $table.newNAP, builder: (column) => column);

  GeneratedColumn<String> get newPORT =>
      $composableBuilder(column: $table.newPORT, builder: (column) => column);

  GeneratedColumn<String> get newVLAN =>
      $composableBuilder(column: $table.newVLAN, builder: (column) => column);

  GeneratedColumn<String> get routerModel => $composableBuilder(
      column: $table.routerModel, builder: (column) => column);

  GeneratedColumn<String> get pulloutRouterModel => $composableBuilder(
      column: $table.pulloutRouterModel, builder: (column) => column);

  GeneratedColumn<String> get pulloutRouterModelSN => $composableBuilder(
      column: $table.pulloutRouterModelSN, builder: (column) => column);

  GeneratedColumn<String> get pulloutRemarks => $composableBuilder(
      column: $table.pulloutRemarks, builder: (column) => column);

  GeneratedColumn<String> get materialsUsedJson => $composableBuilder(
      column: $table.materialsUsedJson, builder: (column) => column);

  GeneratedColumn<String> get clientSignature => $composableBuilder(
      column: $table.clientSignature, builder: (column) => column);

  GeneratedColumn<String> get image1 =>
      $composableBuilder(column: $table.image1, builder: (column) => column);

  GeneratedColumn<String> get image2 =>
      $composableBuilder(column: $table.image2, builder: (column) => column);

  GeneratedColumn<String> get image3 =>
      $composableBuilder(column: $table.image3, builder: (column) => column);

  GeneratedColumn<String> get houseFrontPicture => $composableBuilder(
      column: $table.houseFrontPicture, builder: (column) => column);

  GeneratedColumn<String> get addressCoordinates => $composableBuilder(
      column: $table.addressCoordinates, builder: (column) => column);

  GeneratedColumn<double> get serviceCharge => $composableBuilder(
      column: $table.serviceCharge, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ServiceOrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ServiceOrdersTable,
    ServiceOrder,
    $$ServiceOrdersTableFilterComposer,
    $$ServiceOrdersTableOrderingComposer,
    $$ServiceOrdersTableAnnotationComposer,
    $$ServiceOrdersTableCreateCompanionBuilder,
    $$ServiceOrdersTableUpdateCompanionBuilder,
    (
      ServiceOrder,
      BaseReferences<_$AppDatabase, $ServiceOrdersTable, ServiceOrder>
    ),
    ServiceOrder,
    PrefetchHooks Function()> {
  $$ServiceOrdersTableTableManager(_$AppDatabase db, $ServiceOrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> accountNumber = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String?> contactNumber = const Value.absent(),
            Value<String?> emailAddress = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String?> barangay = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> provider = const Value.absent(),
            Value<String?> plan = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<String?> connectionType = const Value.absent(),
            Value<String?> routerModemSN = const Value.absent(),
            Value<String?> lcp = const Value.absent(),
            Value<String?> nap = const Value.absent(),
            Value<String?> port = const Value.absent(),
            Value<String?> vlan = const Value.absent(),
            Value<String> supportStatus = const Value.absent(),
            Value<String> concern = const Value.absent(),
            Value<String?> priorityLevel = const Value.absent(),
            Value<String?> visitStatus = const Value.absent(),
            Value<String?> visitBy = const Value.absent(),
            Value<String?> visitRemarks = const Value.absent(),
            Value<String?> assignedEmail = const Value.absent(),
            Value<DateTime?> createdDate = const Value.absent(),
            Value<DateTime?> dateInstalled = const Value.absent(),
            Value<String?> newRouterModemSN = const Value.absent(),
            Value<String?> newLCP = const Value.absent(),
            Value<String?> newNAP = const Value.absent(),
            Value<String?> newPORT = const Value.absent(),
            Value<String?> newVLAN = const Value.absent(),
            Value<String?> routerModel = const Value.absent(),
            Value<String?> pulloutRouterModel = const Value.absent(),
            Value<String?> pulloutRouterModelSN = const Value.absent(),
            Value<String?> pulloutRemarks = const Value.absent(),
            Value<String?> materialsUsedJson = const Value.absent(),
            Value<String?> clientSignature = const Value.absent(),
            Value<String?> image1 = const Value.absent(),
            Value<String?> image2 = const Value.absent(),
            Value<String?> image3 = const Value.absent(),
            Value<String?> houseFrontPicture = const Value.absent(),
            Value<String?> addressCoordinates = const Value.absent(),
            Value<double> serviceCharge = const Value.absent(),
            Value<String?> rawJson = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ServiceOrdersCompanion(
            id: id,
            accountNumber: accountNumber,
            fullName: fullName,
            contactNumber: contactNumber,
            emailAddress: emailAddress,
            address: address,
            barangay: barangay,
            city: city,
            provider: provider,
            plan: plan,
            username: username,
            connectionType: connectionType,
            routerModemSN: routerModemSN,
            lcp: lcp,
            nap: nap,
            port: port,
            vlan: vlan,
            supportStatus: supportStatus,
            concern: concern,
            priorityLevel: priorityLevel,
            visitStatus: visitStatus,
            visitBy: visitBy,
            visitRemarks: visitRemarks,
            assignedEmail: assignedEmail,
            createdDate: createdDate,
            dateInstalled: dateInstalled,
            newRouterModemSN: newRouterModemSN,
            newLCP: newLCP,
            newNAP: newNAP,
            newPORT: newPORT,
            newVLAN: newVLAN,
            routerModel: routerModel,
            pulloutRouterModel: pulloutRouterModel,
            pulloutRouterModelSN: pulloutRouterModelSN,
            pulloutRemarks: pulloutRemarks,
            materialsUsedJson: materialsUsedJson,
            clientSignature: clientSignature,
            image1: image1,
            image2: image2,
            image3: image3,
            houseFrontPicture: houseFrontPicture,
            addressCoordinates: addressCoordinates,
            serviceCharge: serviceCharge,
            rawJson: rawJson,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String accountNumber,
            required String fullName,
            Value<String?> contactNumber = const Value.absent(),
            Value<String?> emailAddress = const Value.absent(),
            required String address,
            Value<String?> barangay = const Value.absent(),
            Value<String?> city = const Value.absent(),
            Value<String?> provider = const Value.absent(),
            Value<String?> plan = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<String?> connectionType = const Value.absent(),
            Value<String?> routerModemSN = const Value.absent(),
            Value<String?> lcp = const Value.absent(),
            Value<String?> nap = const Value.absent(),
            Value<String?> port = const Value.absent(),
            Value<String?> vlan = const Value.absent(),
            Value<String> supportStatus = const Value.absent(),
            Value<String> concern = const Value.absent(),
            Value<String?> priorityLevel = const Value.absent(),
            Value<String?> visitStatus = const Value.absent(),
            Value<String?> visitBy = const Value.absent(),
            Value<String?> visitRemarks = const Value.absent(),
            Value<String?> assignedEmail = const Value.absent(),
            Value<DateTime?> createdDate = const Value.absent(),
            Value<DateTime?> dateInstalled = const Value.absent(),
            Value<String?> newRouterModemSN = const Value.absent(),
            Value<String?> newLCP = const Value.absent(),
            Value<String?> newNAP = const Value.absent(),
            Value<String?> newPORT = const Value.absent(),
            Value<String?> newVLAN = const Value.absent(),
            Value<String?> routerModel = const Value.absent(),
            Value<String?> pulloutRouterModel = const Value.absent(),
            Value<String?> pulloutRouterModelSN = const Value.absent(),
            Value<String?> pulloutRemarks = const Value.absent(),
            Value<String?> materialsUsedJson = const Value.absent(),
            Value<String?> clientSignature = const Value.absent(),
            Value<String?> image1 = const Value.absent(),
            Value<String?> image2 = const Value.absent(),
            Value<String?> image3 = const Value.absent(),
            Value<String?> houseFrontPicture = const Value.absent(),
            Value<String?> addressCoordinates = const Value.absent(),
            Value<double> serviceCharge = const Value.absent(),
            Value<String?> rawJson = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ServiceOrdersCompanion.insert(
            id: id,
            accountNumber: accountNumber,
            fullName: fullName,
            contactNumber: contactNumber,
            emailAddress: emailAddress,
            address: address,
            barangay: barangay,
            city: city,
            provider: provider,
            plan: plan,
            username: username,
            connectionType: connectionType,
            routerModemSN: routerModemSN,
            lcp: lcp,
            nap: nap,
            port: port,
            vlan: vlan,
            supportStatus: supportStatus,
            concern: concern,
            priorityLevel: priorityLevel,
            visitStatus: visitStatus,
            visitBy: visitBy,
            visitRemarks: visitRemarks,
            assignedEmail: assignedEmail,
            createdDate: createdDate,
            dateInstalled: dateInstalled,
            newRouterModemSN: newRouterModemSN,
            newLCP: newLCP,
            newNAP: newNAP,
            newPORT: newPORT,
            newVLAN: newVLAN,
            routerModel: routerModel,
            pulloutRouterModel: pulloutRouterModel,
            pulloutRouterModelSN: pulloutRouterModelSN,
            pulloutRemarks: pulloutRemarks,
            materialsUsedJson: materialsUsedJson,
            clientSignature: clientSignature,
            image1: image1,
            image2: image2,
            image3: image3,
            houseFrontPicture: houseFrontPicture,
            addressCoordinates: addressCoordinates,
            serviceCharge: serviceCharge,
            rawJson: rawJson,
            isSynced: isSynced,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ServiceOrdersTable, ServiceOrder>(table),
                    BaseReferences<_$AppDatabase, $ServiceOrdersTable,
                        ServiceOrder>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ServiceOrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ServiceOrdersTable,
    ServiceOrder,
    $$ServiceOrdersTableFilterComposer,
    $$ServiceOrdersTableOrderingComposer,
    $$ServiceOrdersTableAnnotationComposer,
    $$ServiceOrdersTableCreateCompanionBuilder,
    $$ServiceOrdersTableUpdateCompanionBuilder,
    (
      ServiceOrder,
      BaseReferences<_$AppDatabase, $ServiceOrdersTable, ServiceOrder>
    ),
    ServiceOrder,
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
  $$ServiceOrdersTableTableManager get serviceOrders =>
      $$ServiceOrdersTableTableManager(_db, _db.serviceOrders);
}
