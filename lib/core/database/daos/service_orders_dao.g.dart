// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_orders_dao.dart';

// ignore_for_file: type=lint
mixin _$ServiceOrdersDaoMixin on DatabaseAccessor<AppDatabase> {
  $ServiceOrdersTable get serviceOrders => attachedDatabase.serviceOrders;
  ServiceOrdersDaoManager get managers => ServiceOrdersDaoManager(this);
}

class ServiceOrdersDaoManager {
  final _$ServiceOrdersDaoMixin _db;
  ServiceOrdersDaoManager(this._db);
  $$ServiceOrdersTableTableManager get serviceOrders =>
      $$ServiceOrdersTableTableManager(_db.attachedDatabase, _db.serviceOrders);
}
