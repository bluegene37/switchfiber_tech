import 'package:drift/drift.dart';
import 'daos/job_orders_dao.dart';
import 'daos/lcp_nap_dao.dart';
import 'daos/service_orders_dao.dart';
import 'daos/sync_error_logs_dao.dart';
import 'native_database.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    JobOrders,
    SyncQueues,
    LcpNapLocations,
    ServiceOrders,
    SyncErrorLogs
  ],
  daos: [JobOrdersDao, LcpNapLocationsDao, ServiceOrdersDao, SyncErrorLogsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? constructDbConnection());

  /// Bumped with every change to [migration] below.
  static const int currentSchemaVersion = 9;

  @override
  int get schemaVersion => currentSchemaVersion;

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
          if (from < 7) {
            // Service orders table for offline repairs & maintenance
            await m.createTable(serviceOrders);
          }
          if (from < 8) {
            // Why a pending push was refused, kept on the phone that hit it.
            await m.createTable(syncErrorLogs);
          }
          if (from == 8) {
            // The request itself, so a refusal can be handed to the backend
            // team as something they can replay.
            //
            // Only for a database that is exactly at 8. `createTable` above
            // builds the table from its *current* definition, so a database
            // coming from 7 or lower already has these four columns, and
            // adding them again fails with "duplicate column name" before the
            // app draws its first frame.
            await m.addColumn(syncErrorLogs, syncErrorLogs.requestMethod);
            await m.addColumn(syncErrorLogs, syncErrorLogs.requestUrl);
            await m.addColumn(syncErrorLogs, syncErrorLogs.requestBody);
            await m.addColumn(syncErrorLogs, syncErrorLogs.responseBody);
          }
        },
      );
}
