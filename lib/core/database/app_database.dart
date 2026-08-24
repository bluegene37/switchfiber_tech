import 'package:drift/drift.dart';
import 'daos/job_orders_dao.dart';
import 'daos/lcp_nap_dao.dart';
import 'native_database.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [JobOrders, SyncQueues, LcpNapLocations],
  daos: [JobOrdersDao, LcpNapLocationsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? constructDbConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );
}
