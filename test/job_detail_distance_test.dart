import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/services/location_service.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_order_detail_screen.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';

/// Stands in for the device GPS and counts how often a fix was asked for.
class _CountingLocationService extends LocationService {
  int calls = 0;

  @override
  Future<Position?> getCurrentPosition({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    calls++;
    return Position(
      latitude: 14.470000,
      longitude: 121.196000,
      timestamp: DateTime.utc(2026, 1, 1),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  @override
  double distanceBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) =>
      850;
}

void main() {
  // Regression: the "Distance from You" row used to build its future inside
  // `build`, so every rebuild of the details screen started a fresh 4-second
  // high-accuracy GPS fix. Found by /qa on 2026-09-03.
  // Report: .gstack/qa-reports/qa-report-swithfiber-tech-2026-09-03.md
  testWidgets('the GPS fix is requested once per mount, not once per rebuild',
      (WidgetTester tester) async {
    final gps = _CountingLocationService();
    final realService = LocationService.instance;
    LocationService.instance = gps;
    addTearDown(() => LocationService.instance = realService);

    late final AppDatabase db;
    late final JobsSignals jobsSignals;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      final repository = JobRepository(db.jobOrdersDao);
      jobsSignals = JobsSignals(repository);
      await db.jobOrdersDao.insertOrUpdateJob(
        JobOrderDto(
          id: 901,
          ticketNumber: 'SF-2026-0901',
          customerName: 'Coordinates Carter',
          address: 'Blk 1 Lot 1, Plant Road',
          barangay: 'San Roque',
          city: 'Binangonan',
          status: 'Scheduled',
          onsiteStatus: 'Scheduled',
          isSynced: true,
          updatedAt: DateTime.now(),
          rawJson: '{"coordinates": "14.469586, 121.195615"}',
        ).toCompanion(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    Widget screen(ThemeData theme) => MaterialApp(
          theme: theme,
          home: JobOrderDetailScreen(jobId: 901, jobsSignals: jobsSignals),
        );

    await tester.pumpWidget(screen(AppTheme.lightTheme));
    await tester.pump();

    // The location card sits below the fold; reach it the way a technician
    // does. Never pumpAndSettle here - the RADIUS card mounted along the way
    // spins an indeterminate indicator that schedules frames forever.
    await tester.scrollUntilVisible(
      find.text('Service Location & GPS Coordinates'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Distance from You'), findsOneWidget);
    expect(gps.calls, 1);

    // Rebuild the whole screen a few times. The fix must survive it.
    for (final theme in [
      AppTheme.darkTheme,
      AppTheme.lightTheme,
      AppTheme.darkTheme,
    ]) {
      await tester.pumpWidget(screen(theme));
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(
      gps.calls,
      1,
      reason: 'rebuilding the screen must not re-issue a GPS fix',
    );

    await tester.runAsync(() async {
      await jobsSignals.dispose();
      await db.close();
    });
  });
}
