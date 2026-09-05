import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/core/theme/app_theme.dart';
import 'package:swithfiber_tech/core/utils/data_url.dart';
import 'package:swithfiber_tech/features/auth/signals/auth_signals.dart';
import 'package:swithfiber_tech/features/jobs/models/job_order_model.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/screens/job_order_detail_screen.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/jobs/widgets/job_card.dart';
import 'package:swithfiber_tech/features/jobs/widgets/jobs_map_view.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';
import 'package:swithfiber_tech/features/shell/technician_shell.dart';

/// A real 1x1 PNG (same fixture as create_report_screen_test.dart and
/// photo_capture_tile_test.dart): the on-site report card renders an
/// existing signature with Image.memory, so the bytes have to actually
/// decode rather than just be present.
final _signature = DataUrl.encode(
  Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, //
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, //
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, //
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]),
  mimeType: 'image/png',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late JobsSignals jobs;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    jobs = JobsSignals(JobRepository(db.jobOrdersDao));
  });

  tearDown(() async {
    await jobs.dispose();
    await db.close();
  });

  Future<void> seedJob(WidgetTester tester) async {
    await tester.runAsync(() async {
      await db.jobOrdersDao.insertOrUpdateJob(JobOrderDto(
        id: 7,
        ticketNumber: 'SF-2026-0007',
        customerName: 'Target Torres',
        address: 'Lot 7, Fiber Street',
        status: 'Scheduled',
        onsiteStatus: 'Scheduled',
        contactNumber: '09171234567',
        clientSignature: _signature,
        modemRouterSN: 'HWTC7',
        isSynced: true,
        updatedAt: DateTime.now(),
        rawJson: '{"coordinates": "14.469586, 121.195615"}',
      ).toCompanion());
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
  }

  testWidgets('Call, SMS and Complete are at least 48 tall', (tester) async {
    // The brief's Step 1 fixture named this button 'Mark as Activated', but
    // the shipped screen's primary action for a completed report reads
    // 'Complete' (see job_order_detail_screen.dart ~line 264) — activating
    // a job is what pressing it does, not its label. Matching on the real
    // label so this test can actually find the widget it means to measure.
    //
    // The screen's body is a plain ListView, which virtualizes children
    // outside the viewport — ensureVisible can't scroll a button into view
    // if it was never built in the first place, and by the time Call/SMS
    // are scrolled into view the Complete button below them has been
    // scrolled out and unmounted. Rather than juggle scroll position, size
    // the test viewport tall enough that the whole card renders at once
    // (the same pattern job_history_view_test.dart and others use for
    // the taller Task 2 type scale).
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await seedJob(tester);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: JobOrderDetailScreen(jobId: 7, jobsSignals: jobs),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // The taller viewport above now also builds JobPhotoGallery, which
    // renders the seeded signature with Image.memory — using the real
    // 1x1 PNG fixture above means that decodes cleanly, so no exception
    // needs to be swallowed here.

    for (final label in ['Call', 'SMS']) {
      final button = find.ancestor(
          of: find.text(label), matching: find.byType(OutlinedButton));
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48),
          reason: '$label button');
    }
    final activate = find.ancestor(
        of: find.text('Mark as Completed'),
        matching: find.byType(ElevatedButton));
    expect(tester.getSize(activate).height, greaterThanOrEqualTo(52),
        reason: 'primary action');
  });

  testWidgets('map floating buttons are at least 48', (tester) async {
    await seedJob(tester);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: JobsMapView(jobsSignals: jobs)),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final size = tester.getSize(find.byTooltip('Satellite View'));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  test(
      'no widget asks for compact density, a shrink-wrapped tap target, or '
      'a zeroed minimum size', () {
    // The theme's minimum sizes (Task 2) only hold if nothing overrides
    // them with a desktop-mouse density, or shrinks the Material tap target
    // padding back down below 48dp. Walk every .dart source file under
    // lib/ and fail if any of the three has crept back in, rather than
    // merely documenting the intent.
    final compactOffenders = <String>[];
    final shrinkWrapOffenders = <String>[];
    final zeroMinSizeOffenders = <String>[];
    final libDir = Directory('lib');
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final contents = entity.readAsStringSync();
      if (contents.contains('VisualDensity.compact')) {
        compactOffenders.add(entity.path);
      }
      if (contents.contains('MaterialTapTargetSize.shrinkWrap')) {
        shrinkWrapOffenders.add(entity.path);
      }
      if (contents.contains('minimumSize: Size.zero')) {
        zeroMinSizeOffenders.add(entity.path);
      }
    }
    expect(compactOffenders, isEmpty,
        reason:
            'VisualDensity.compact found in: ${compactOffenders.join(', ')}');
    expect(shrinkWrapOffenders, isEmpty,
        reason: 'MaterialTapTargetSize.shrinkWrap found in: '
            '${shrinkWrapOffenders.join(', ')}');
    expect(zeroMinSizeOffenders, isEmpty,
        reason:
            'minimumSize: Size.zero found in: ${zeroMinSizeOffenders.join(', ')}');
  });

  testWidgets('bottom tab bar hit areas are at least 48dp tall',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final shellJobs = JobsSignals(JobRepository(db.jobOrdersDao));
    final lcpNap = LcpNapSignals(LcpNapRepository(LcpNapLocationsDao(db)));
    final auth = AuthSignals.instance;
    auth.currentUser.value = null;

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: TechnicianShell(
        authSignals: auth,
        jobsSignals: shellJobs,
        lcpNapSignals: lcpNap,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    for (final label in [
      'Scheduled',
      'Repairs',
      'LCP NAP',
      'Tech Toolkit',
      'Settings',
    ]) {
      final tab = find.ancestor(
          of: find.text(label), matching: find.byType(GestureDetector));
      expect(tester.getSize(tab).height, greaterThanOrEqualTo(48),
          reason: '$label tab');
    }

    await tester.runAsync(() async {
      await shellJobs.dispose();
      await lcpNap.dispose();
      await db.close();
    });
  });

  testWidgets('JobCard Call and Directions pills are at least 48dp tall',
      (tester) async {
    final job = JobOrderDto(
      id: 42,
      ticketNumber: 'SF-2026-0042',
      customerName: 'Tap Target Torres',
      address: 'Lot 42, Fiber Street',
      status: 'Scheduled',
      onsiteStatus: 'Scheduled',
      contactNumber: '09171234567',
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: JobCard(job: job, onTap: () {})),
    ));
    await tester.pump();

    for (final label in ['Call', 'Directions']) {
      // The card itself is wrapped in an InkWell, which builds its own
      // internal GestureDetector, so the ancestor chain above each pill's
      // own tap-target GestureDetector also passes through that one. The
      // pill's is the nearer of the two matches.
      final pill = find
          .ancestor(
              of: find.text(label), matching: find.byType(GestureDetector))
          .first;
      expect(tester.getSize(pill).height, greaterThanOrEqualTo(48),
          reason: '$label pill');
    }
  });
}
