// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_orders_dao.dart';

// ignore_for_file: type=lint
mixin _$JobOrdersDaoMixin on DatabaseAccessor<AppDatabase> {
  $JobOrdersTable get jobOrders => attachedDatabase.jobOrders;
  JobOrdersDaoManager get managers => JobOrdersDaoManager(this);
}

class JobOrdersDaoManager {
  final _$JobOrdersDaoMixin _db;
  JobOrdersDaoManager(this._db);
  $$JobOrdersTableTableManager get jobOrders =>
      $$JobOrdersTableTableManager(_db.attachedDatabase, _db.jobOrders);
}
