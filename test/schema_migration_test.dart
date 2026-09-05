import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';

/// Opening the database is the first thing `main()` awaits, before the first
/// frame. A migration that throws therefore looks like an app that installs
/// and then never draws: Android logs `performTraversals: cancelAndRedraw`
/// until someone kills it. Every upgrade path has to be exercised here.
void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('schema_migration');
    file = File('${dir.path}/app.sqlite');
    // Lay down a full current-version database, then rewind parts of it to
    // the shape an older build left behind.
    final db = AppDatabase(NativeDatabase(file));
    await db.jobOrdersDao.deleteSampleJobs();
    await db.close();
  });

  tearDown(() => dir.delete(recursive: true));

  Future<int> versionOf(AppDatabase db) async =>
      (await db.customSelect('pragma user_version').getSingle())
          .read<int>('user_version');

  Future<List<String>> columnsOf(AppDatabase db, String table) async =>
      (await db.customSelect('pragma table_info($table)').get())
          .map((r) => r.read<String>('name'))
          .toList();

  /// Reshapes the file the way an older build left it. The database is
  /// already at the current version here, so opening it runs no migration.
  Future<void> rewind(List<String> statements, int version) async {
    final db = AppDatabase(NativeDatabase(file));
    for (final sql in statements) {
      await db.customStatement(sql);
    }
    await db.customStatement('pragma user_version = $version');
    await db.close();
  }

  test('a version 6 database, as a phone first installed on 2026-09-03 has, '
      'upgrades to the current version', () async {
    await rewind(
        ['drop table service_orders', 'drop table sync_error_logs'], 6);

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    // `createTable` at step 8 already builds sync_error_logs with the
    // version 9 columns; step 9 must not add them a second time.
    await db.jobOrdersDao.deleteSampleJobs();

    expect(await versionOf(db), AppDatabase.currentSchemaVersion);
    expect(await columnsOf(db, 'sync_error_logs'),
        containsAll(['request_method', 'request_url', 'request_body', 'response_body']));
  });

  test('a version 8 database gets the four request columns added', () async {
    await rewind([
      'drop table sync_error_logs',
      '''CREATE TABLE sync_error_logs (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id INTEGER NOT NULL,
        reference TEXT NOT NULL DEFAULT '',
        operation TEXT NOT NULL,
        status_code INTEGER NULL,
        message TEXT NOT NULL,
        payload_bytes INTEGER NOT NULL DEFAULT 0,
        occurred_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
        resolved INTEGER NOT NULL DEFAULT 0 CHECK (resolved IN (0, 1)))''',
    ], 8);

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    await db.jobOrdersDao.deleteSampleJobs();

    expect(await versionOf(db), AppDatabase.currentSchemaVersion);
    expect(await columnsOf(db, 'sync_error_logs'),
        containsAll(['request_method', 'request_url', 'request_body', 'response_body']));
    await db.syncErrorLogsDao.log(
      entityType: 'JOB_ORDER',
      entityId: 1,
      reference: 'SF-1',
      operation: 'completed',
      statusCode: 500,
      message: 'boom',
      requestMethod: 'PUT',
      requestUrl: 'https://example/api/JobOrders/1',
      requestBody: '{}',
    );
    expect((await db.syncErrorLogsDao.getAll()).single.requestUrl,
        'https://example/api/JobOrders/1');
  });

  test('a phone left at version 6 by the failed migration recovers', () async {
    // The 2026-09-05 build ran steps 7 and 8, threw at step 9 and never
    // wrote the version, so the tables are current but the version is not.
    await rewind(const [], 6);

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    await db.jobOrdersDao.deleteSampleJobs();

    expect(await versionOf(db), AppDatabase.currentSchemaVersion);
  });
}
