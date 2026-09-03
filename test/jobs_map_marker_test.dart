import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/jobs/widgets/jobs_map_view.dart';

void main() {
  // A technician who has bumped up the system font size still gets a map pin
  // that fits inside its fixed marker box.
  for (final scale in <double>[1.0, 1.3, 2.0]) {
    testWidgets('job markers fit their marker box at text scale $scale',
        (WidgetTester tester) async {
      late final AppDatabase db;
      late final JobsSignals jobsSignals;

      await tester.runAsync(() async {
        db = AppDatabase(NativeDatabase.memory());
        jobsSignals = JobsSignals(JobRepository(db.jobOrdersDao));
        await db.jobOrdersDao.insertOrUpdateJob(
          JobOrderDto(
            id: 701,
            ticketNumber: 'SF-2026-0701',
            customerName: 'Marker Mendoza',
            address: 'Blk 7 Lot 1, Fiber Street',
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

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              body: JobsMapView(jobsSignals: jobsSignals),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull,
          reason: 'the job marker overflowed its box at text scale $scale');

      // The pin is useless if the ticket number is cut short, so the box must
      // be wide enough to show it whole.
      final label = tester.renderObject<RenderParagraph>(
        find.descendant(
          of: find.byType(JobsMapView),
          matching: find.text('SF-2026-0701'),
        ),
      );
      expect(label.didExceedMaxLines, isFalse,
          reason: 'the ticket number was truncated at text scale $scale');

      await tester.runAsync(() async => db.close());
    });
  }
}
