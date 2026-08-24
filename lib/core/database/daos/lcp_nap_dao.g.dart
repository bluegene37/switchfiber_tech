// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcp_nap_dao.dart';

// ignore_for_file: type=lint
mixin _$LcpNapLocationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LcpNapLocationsTable get lcpNapLocations => attachedDatabase.lcpNapLocations;
  LcpNapLocationsDaoManager get managers => LcpNapLocationsDaoManager(this);
}

class LcpNapLocationsDaoManager {
  final _$LcpNapLocationsDaoMixin _db;
  LcpNapLocationsDaoManager(this._db);
  $$LcpNapLocationsTableTableManager get lcpNapLocations =>
      $$LcpNapLocationsTableTableManager(
          _db.attachedDatabase, _db.lcpNapLocations);
}
