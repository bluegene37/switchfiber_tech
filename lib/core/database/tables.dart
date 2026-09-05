import 'package:drift/drift.dart';

/// Drift SQLite table definition for JobOrders.
class JobOrders extends Table {
  IntColumn get id => integer()();
  TextColumn get ticketNumber => text().withLength(min: 1, max: 64)();
  TextColumn get customerName => text()();
  TextColumn get contactNumber => text().nullable()();
  TextColumn get address => text()();
  TextColumn get barangay => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get planName => text().nullable()();
  IntColumn get planId => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get onsiteStatus => text().nullable()();
  TextColumn get onsiteRemarks => text().nullable()();
  RealColumn get opticalPower =>
      real().nullable()(); // Optical dBm meter reading
  TextColumn get modemRouterSN => text().nullable()();
  TextColumn get routerModel => text().nullable()();
  IntColumn get lcpId => integer().nullable()();
  IntColumn get napId => integer().nullable()();
  TextColumn get nap => text().nullable()();
  TextColumn get portId => text().nullable()();
  IntColumn get vlanId => integer().nullable()();
  DateTimeColumn get dateInstalled => dateTime().nullable()();
  // Photo proofs and the subscriber's signature, stored exactly as the API
  // holds them: data URLs (`data:image/jpeg;base64,...`) captured on site,
  // or whatever path the office uploaded from the web console.
  TextColumn get boxReadingImage => text().nullable()();
  TextColumn get routerReadingImage => text().nullable()();
  TextColumn get clientSignature => text().nullable()();
  TextColumn get setupImage => text().nullable()();
  TextColumn get speedtestImage => text().nullable()();
  TextColumn get portLabelImage => text().nullable()();
  TextColumn get signedContractImage => text().nullable()();
  TextColumn get houseFront => text().nullable()();

  /// Email of the technician the office assigned this job to. This is the
  /// column the technician's job history is filtered on.
  TextColumn get assignedEmail => text().nullable()();

  /// When the server record was last changed. Orders the history for jobs
  /// that never reached an install date.
  DateTimeColumn get modifiedDate => dateTime().nullable()();

  /// The complete record exactly as the API returned it.
  ///
  /// PUT /api/JobOrders/{id} requires all 86 fields of UpdateJobOrderRequest,
  /// but this table models only the subset the app uses. Keeping the original
  /// JSON lets an update send the whole record back with just the changed
  /// fields replaced, instead of blanking out everything it does not model.
  TextColumn get rawJson => text().nullable()();

  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Drift SQLite table definition for LCP NAP Locations.
class LcpNapLocations extends Table {
  // Mirrors LCPNapLocation from the API exactly. Fields the API does not
  // provide - port occupancy, site status, description - are deliberately
  // absent: showing invented values here told technicians a NAP box was empty
  // when nothing was known about it.
  IntColumn get id => integer()();
  TextColumn get lcp => text()(); // e.g. "CAR LCP 002"
  TextColumn get nap => text()(); // e.g. "NAP 004"
  TextColumn get lcpNap => text()(); // e.g. "CAR LCP 002 NAP 004"
  IntColumn get portTotal => integer().withDefault(const Constant(8))();
  TextColumn get coordinates => text().nullable()(); // "14.469586, 121.195615"
  TextColumn get street => text().nullable()();
  TextColumn get barangay => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get region => text().nullable()();

  /// Photo paths as the API stores them. These are relative paths, not URLs,
  /// and no public base URL is known yet, so they are persisted but not shown.
  TextColumn get image => text().nullable()();
  TextColumn get image2 => text().nullable()();
  TextColumn get readingImage => text().nullable()();

  /// Who last touched the record on the server, and when.
  TextColumn get modifiedBy => text().nullable()();
  TextColumn get userEmail => text().nullable()();
  DateTimeColumn get modifiedDate => dateTime().nullable()();

  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Offline sync queue table for outbound pending updates.
class SyncQueues extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // e.g. 'JOB_ORDER'
  IntColumn get entityId => integer()();
  TextColumn get payload => text()(); // Serialized JSON payload
  TextColumn get action => text()(); // 'CREATE', 'UPDATE'
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Drift SQLite table definition for ServiceOrders (Repairs, Swaps, Maintenance).
class ServiceOrders extends Table {
  IntColumn get id => integer()();
  TextColumn get accountNumber => text()();
  TextColumn get fullName => text()();
  TextColumn get contactNumber => text().nullable()();
  TextColumn get emailAddress => text().nullable()();
  TextColumn get address => text()();
  TextColumn get barangay => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get provider => text().nullable()();
  TextColumn get plan => text().nullable()();
  TextColumn get username => text().nullable()();
  TextColumn get connectionType => text().nullable()();
  TextColumn get routerModemSN => text().nullable()();
  TextColumn get lcp => text().nullable()();
  TextColumn get nap => text().nullable()();
  TextColumn get port => text().nullable()();
  TextColumn get vlan => text().nullable()();
  TextColumn get supportStatus => text().withDefault(const Constant('Open'))();
  TextColumn get concern =>
      text().withDefault(const Constant('Service Call'))();
  TextColumn get priorityLevel => text().nullable()();
  TextColumn get visitStatus => text().nullable()();
  TextColumn get visitBy => text().nullable()();
  TextColumn get visitRemarks => text().nullable()();
  TextColumn get assignedEmail => text().nullable()();
  DateTimeColumn get createdDate => dateTime().nullable()();
  DateTimeColumn get dateInstalled => dateTime().nullable()();
  TextColumn get newRouterModemSN => text().nullable()();
  TextColumn get newLCP => text().nullable()();
  TextColumn get newNAP => text().nullable()();
  TextColumn get newPORT => text().nullable()();
  TextColumn get newVLAN => text().nullable()();
  TextColumn get routerModel => text().nullable()();
  TextColumn get pulloutRouterModel => text().nullable()();
  TextColumn get pulloutRouterModelSN => text().nullable()();
  TextColumn get pulloutRemarks => text().nullable()();
  TextColumn get materialsUsedJson => text().nullable()();
  TextColumn get clientSignature => text().nullable()();
  TextColumn get image1 => text().nullable()();
  TextColumn get image2 => text().nullable()();
  TextColumn get image3 => text().nullable()();
  TextColumn get houseFrontPicture => text().nullable()();
  TextColumn get addressCoordinates => text().nullable()();
  RealColumn get serviceCharge => real().withDefault(const Constant(0.0))();
  TextColumn get rawJson => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Every failed attempt to push a record to the server, kept on the phone.
///
/// The app is offline-first: a refused edit stays saved locally and retries.
/// That is deliberate, but it used to be silent, so a job could sit on
/// "needs to sync" forever with nothing anywhere saying why. Each attempt
/// that the server refuses is written here instead, with what was sent and
/// what came back, so the failure can be read on the phone that hit it.
class SyncErrorLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'JOB_ORDER' or 'SERVICE_ORDER'.
  TextColumn get entityType => text()();
  IntColumn get entityId => integer()();

  /// The ticket number, so a log line is readable without a lookup.
  TextColumn get reference => text().withDefault(const Constant(''))();

  /// What the technician was doing: 'complete', 'activate', 'field-status'.
  TextColumn get operation => text()();

  /// HTTP status, or null when the request never got an answer at all
  /// (no signal, timeout, connection reset).
  IntColumn get statusCode => integer().nullable()();

  /// The server's own message, or the exception when there was no response.
  TextColumn get message => text()();

  /// Size of the request body in bytes. A completion inlines every photo as
  /// Base64, so this is the first thing to look at when big pushes fail and
  /// small ones do not.
  IntColumn get payloadBytes => integer().withDefault(const Constant(0))();

  DateTimeColumn get occurredAt => dateTime().withDefault(currentDateAndTime)();

  /// Set once the same record syncs successfully, so the log shows what is
  /// still outstanding rather than everything that ever went wrong.
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();

  /// The HTTP method and full URL of the call that failed, e.g. `PUT` and
  /// `https://host:8090/api/JobOrders/123`, so the backend team can find the
  /// endpoint without reading the app.
  TextColumn get requestMethod => text().withDefault(const Constant(''))();
  TextColumn get requestUrl => text().withDefault(const Constant(''))();

  /// The JSON body exactly as sent, except that inline images are replaced
  /// by a marker with their size. A completion carries several megabytes of
  /// Base64, which no clipboard or chat message can take; the field names and
  /// every other value are what a validation error is about.
  TextColumn get requestBody => text().nullable()();

  /// The raw response body, when there was one.
  TextColumn get responseBody => text().nullable()();
}
