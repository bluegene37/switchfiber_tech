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
  RealColumn get opticalPower => real().nullable()(); // Optical dBm meter reading
  TextColumn get modemRouterSN => text().nullable()();
  TextColumn get routerModel => text().nullable()();
  IntColumn get lcpId => integer().nullable()();
  IntColumn get napId => integer().nullable()();
  TextColumn get portId => text().nullable()();
  IntColumn get vlanId => integer().nullable()();
  DateTimeColumn get dateInstalled => dateTime().nullable()();
  TextColumn get boxReadingImage => text().nullable()();
  TextColumn get routerReadingImage => text().nullable()();
  TextColumn get clientSignature => text().nullable()();
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
  IntColumn get id => integer()();
  TextColumn get lcp => text()(); // e.g. "LCP 01"
  TextColumn get nap => text()(); // e.g. "NAP 04"
  TextColumn get lcpNap => text()(); // e.g. "LCP 01 - NAP 04"
  IntColumn get portTotal => integer().withDefault(const Constant(8))();
  IntColumn get portOccupied => integer().withDefault(const Constant(0))();
  TextColumn get coordinates => text().nullable()(); // "14.5995, 120.9842"
  TextColumn get barangay => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('Active'))(); // 'Active', 'Maintenance', 'Full'
  TextColumn get description => text().nullable()();
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
