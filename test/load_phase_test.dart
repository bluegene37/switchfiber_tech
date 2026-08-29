import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/widgets/loading_states.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';

/// Repositories whose remote fetch completes only when the test says so,
/// letting each phase transition be observed deterministically.
class _FakeJobRepository extends JobRepository {
  final fetchGate = Completer<void>();

  _FakeJobRepository(super.dao);

  @override
  Future<void> fetchRemoteJobs({String? statusFilter}) => fetchGate.future;
}

class _FakeLcpNapRepository extends LcpNapRepository {
  final fetchGate = Completer<void>();

  _FakeLcpNapRepository(super.dao);

  @override
  Future<void> fetchRemoteLocations() => fetchGate.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  group('First-load phase sequence (downloading -> skeleton -> ready)', () {
    test('JobsSignals walks the phases on an initial fetch of an empty cache',
        () async {
      final repository = _FakeJobRepository(db.jobOrdersDao);
      final signals = JobsSignals(repository);

      expect(signals.loadPhase.value, DataLoadPhase.ready);

      final fetch = signals.fetchRemote(initial: true);
      expect(signals.loadPhase.value, DataLoadPhase.downloading);

      repository.fetchGate.complete();
      // Let the fetch future resolve so the skeleton pass begins.
      await Future<void>.delayed(Duration.zero);
      expect(signals.loadPhase.value, DataLoadPhase.skeleton);

      await fetch;
      expect(signals.loadPhase.value, DataLoadPhase.ready);

      await signals.dispose();
      await db.close();
    });

    test('JobsSignals skips the phases when Drift already holds jobs',
        () async {
      // Seed through the real repository so the Drift stream hydrates allJobs.
      final seeder = JobRepository(db.jobOrdersDao);
      await seeder.seedSampleJobs();

      final repository = _FakeJobRepository(db.jobOrdersDao);
      final signals = JobsSignals(repository);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(signals.allJobs.value, isNotEmpty);

      final fetch = signals.fetchRemote(initial: true);
      expect(signals.loadPhase.value, DataLoadPhase.ready,
          reason: 'cached data must never be hidden behind a loader');

      repository.fetchGate.complete();
      await fetch;
      expect(signals.loadPhase.value, DataLoadPhase.ready);

      await signals.dispose();
      await db.close();
    });

    test('JobsSignals plain refresh never leaves the ready phase', () async {
      final repository = _FakeJobRepository(db.jobOrdersDao);
      final signals = JobsSignals(repository);

      final fetch = signals.fetchRemote();
      expect(signals.loadPhase.value, DataLoadPhase.ready);

      repository.fetchGate.complete();
      await fetch;
      expect(signals.loadPhase.value, DataLoadPhase.ready);

      await signals.dispose();
      await db.close();
    });

    test('LcpNapSignals walks the phases on an initial fetch of an empty cache',
        () async {
      final repository = _FakeLcpNapRepository(db.lcpNapLocationsDao);
      final signals = LcpNapSignals(repository);

      expect(signals.loadPhase.value, DataLoadPhase.ready);

      final fetch = signals.fetchRemote(initial: true);
      expect(signals.loadPhase.value, DataLoadPhase.downloading);

      repository.fetchGate.complete();
      await Future<void>.delayed(Duration.zero);
      expect(signals.loadPhase.value, DataLoadPhase.skeleton);

      await fetch;
      expect(signals.loadPhase.value, DataLoadPhase.ready);

      await signals.dispose();
      await db.close();
    });
  });
}
