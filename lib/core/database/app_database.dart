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
  int get schemaVersion => 6;

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
          if (from < 4) {
            // Technician assignment, so the job history can be filtered to
            // the signed-in technician without a server round trip.
            await m.addColumn(jobOrders, jobOrders.assignedEmail);
            await m.addColumn(jobOrders, jobOrders.modifiedDate);
          }
          if (from < 5) {
            // The remaining photo proof fields the completion report can
            // capture on site.
            await m.addColumn(jobOrders, jobOrders.setupImage);
            await m.addColumn(jobOrders, jobOrders.speedtestImage);
            await m.addColumn(jobOrders, jobOrders.portLabelImage);
            await m.addColumn(jobOrders, jobOrders.signedContractImage);
            await m.addColumn(jobOrders, jobOrders.houseFront);
          }
          if (from < 6) {
            // Selected NAP from /api/Naps
            await m.addColumn(jobOrders, jobOrders.nap);
          }
        },
      );
}
