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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Stores the untouched API record so updates can round-trip every
            // field the app does not model.
            await m.addColumn(jobOrders, jobOrders.rawJson);
          }
          if (from < 3) {
            // LCP NAP locations are a read-only mirror of the server, so the
            // table is simply rebuilt to match the API's real field list and
            // refilled on the next sync.
            await m.drop(lcpNapLocations);
            await m.createTable(lcpNapLocations);
          }
        },
      );
}
