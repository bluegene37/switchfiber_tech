import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_orders_screen.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/jobs/widgets/job_card.dart';
import 'package:swithfiber_tech/features/jobs/widgets/jobs_map_view.dart';

void main() {
  testWidgets('JobOrdersScreen toggles between List and Map views',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late final AppDatabase db;
    late final JobsSignals jobsSignals;

    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      jobsSignals = JobsSignals(JobRepository(db.jobOrdersDao));
      await db.jobOrdersDao.insertOrUpdateJob(
        JobOrderDto(
          id: 101,
          ticketNumber: 'SF-2026-101',
          customerName: 'Juan Dela Cruz',
          address: '123 Rizal St',
          barangay: 'San Isidro',
          city: 'Antipolo',
          status: 'Scheduled',
          onsiteStatus: 'Scheduled',
          contactNumber: '09171234567',
          nap: 'NAP-01',
          napId: 1,
          isSynced: true,
          updatedAt: DateTime.now(),
          rawJson: '{"coordinates": "14.580000, 121.170000"}',
        ).toCompanion(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: JobOrdersScreen(
          jobsSignals: jobsSignals,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Initially in List view
    expect(find.byType(JobCard), findsOneWidget);
    expect(find.text('SF-2026-101'), findsOneWidget);
    expect(find.text('Juan Dela Cruz'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Directions'), findsOneWidget);
    expect(find.text('NAP-01'), findsOneWidget);
    expect(find.byType(JobsMapView), findsNothing);

    // Tap Map view toggle
    final mapToggle = find.text('Map');
    expect(mapToggle, findsOneWidget);
    await tester.tap(mapToggle);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Now in Map view
    expect(find.byType(JobsMapView), findsOneWidget);
    expect(find.byType(JobCard), findsNothing);

    // Tap List view toggle
    final listToggle = find.text('List');
    expect(listToggle, findsOneWidget);
    await tester.tap(listToggle);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Back to List view
    expect(find.byType(JobCard), findsOneWidget);
    expect(find.byType(JobsMapView), findsNothing);

    await tester.runAsync(() async {
      await jobsSignals.dispose();
      await db.close();
    });
  });

  testWidgets('JobOrdersScreen shows search empty state and clears search',
      (WidgetTester tester) async {
    late final AppDatabase db;
    late final JobsSignals jobsSignals;

    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      jobsSignals = JobsSignals(JobRepository(db.jobOrdersDao));
      await db.jobOrdersDao.insertOrUpdateJob(
        JobOrderDto(
          id: 101,
          ticketNumber: 'SF-2026-101',
          customerName: 'Juan Dela Cruz',
          address: '123 Rizal St',
          barangay: 'San Isidro',
          city: 'Antipolo',
          status: 'Scheduled',
          onsiteStatus: 'Scheduled',
          contactNumber: '09171234567',
          nap: 'NAP-01',
          napId: 1,
          isSynced: true,
          updatedAt: DateTime.now(),
        ).toCompanion(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: JobOrdersScreen(
          jobsSignals: jobsSignals,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(JobCard), findsOneWidget);

    // Enter a search that matches nothing
    await tester.enterText(find.byType(TextField), 'NonexistentSubscriber');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(JobCard), findsNothing);
    expect(find.text('No jobs matching "NonexistentSubscriber"'), findsOneWidget);
    expect(find.text('Clear Search'), findsOneWidget);

    // Tap Clear Search button
    await tester.tap(find.text('Clear Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(JobCard), findsOneWidget);
    expect(find.text('No jobs matching "NonexistentSubscriber"'), findsNothing);

    await tester.runAsync(() async {
      await jobsSignals.dispose();
      await db.close();
    });
  });
}

