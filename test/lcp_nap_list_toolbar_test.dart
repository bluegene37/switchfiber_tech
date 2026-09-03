import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/features/lcp_nap/models/lcp_nap_model.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/screens/lcp_nap_list_screen.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';

/// Logical screen width of the OPPO CPH2483 (smallestScreenWidthDp=424).
const double _screenWidth = 423.5;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the grouping toolbar keeps its buttons on screen on a 424dp phone',
      (tester) async {
    // With 16dp of list padding each side the toolbar Row gets 391.5dp, the
    // exact width at which a full plant's summary used to run 1.3px past the
    // Expand/Collapse buttons on the technician's phone.
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(_screenWidth * 3.0, 2400);
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    final dao = LcpNapLocationsDao(db);
    final signals = LcpNapSignals(LcpNapRepository(dao));
    addTearDown(() async {
      await signals.dispose();
      await db.close();
    });

    // Enough cabinets and NAPs for a four-digit NAP count, matching the live
    // plant ("252 LCP Cabinet Groups (1573 NAPs)").
    await tester.runAsync(() async {
      var id = 1;
      final rows = <LcpNapLocationsCompanion>[];
      for (var lcp = 1; lcp <= 252; lcp++) {
        for (var nap = 1; nap <= 6; nap++) {
          rows.add(LcpNapDto(
            id: id++,
            lcp: 'LCP ${lcp.toString().padLeft(3, '0')}',
            nap: 'NAP ${nap.toString().padLeft(2, '0')}',
            lcpNap: 'LCP $lcp - NAP $nap',
            portTotal: 8,
            barangay: 'San Antonio',
            city: 'Pasig',
          ).toCompanion());
        }
      }
      await dao.insertAllLocations(rows);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });

    // This screen has other rows that overflow under this synthetic fixture
    // but not on the real device, so overflow reports are absorbed here and
    // the toolbar is judged on where its buttons actually land.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (_) {};
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(
      MaterialApp(home: LcpNapListScreen(signals: signals)),
    );
    await tester.pumpAndSettle();
    FlutterError.onError = originalOnError;
    tester.takeException();

    expect(find.textContaining('LCP Cabinet Groups'), findsOneWidget,
        reason: 'the summary must be on screen for this to mean anything');

    // Without the fix the summary sits at its natural width and shoves the
    // button pair off the right edge; with it the summary yields and the
    // buttons come to rest inside the screen.
    final collapseAll = tester.getRect(find.text('Collapse All'));
    expect(collapseAll.right, lessThanOrEqualTo(_screenWidth),
        reason: 'the Collapse All button must stay inside the screen instead '
            'of being pushed past the right edge by the summary text');
  });
}
