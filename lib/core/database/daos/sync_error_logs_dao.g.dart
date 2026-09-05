// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_error_logs_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncErrorLogsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncErrorLogsTable get syncErrorLogs => attachedDatabase.syncErrorLogs;
  SyncErrorLogsDaoManager get managers => SyncErrorLogsDaoManager(this);
}

class SyncErrorLogsDaoManager {
  final _$SyncErrorLogsDaoMixin _db;
  SyncErrorLogsDaoManager(this._db);
  $$SyncErrorLogsTableTableManager get syncErrorLogs =>
      $$SyncErrorLogsTableTableManager(_db.attachedDatabase, _db.syncErrorLogs);
}
