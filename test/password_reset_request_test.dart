import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/database/app_database.dart';
import 'package:swithfiber_tech/core/database/daos/lcp_nap_dao.dart';
import 'package:swithfiber_tech/core/network/api_client.dart';
import 'package:swithfiber_tech/features/auth/services/auth_service.dart';
import 'package:swithfiber_tech/features/auth/signals/auth_signals.dart';
import 'package:swithfiber_tech/features/jobs/repositories/job_repository.dart';
import 'package:swithfiber_tech/features/jobs/signals/jobs_signals.dart';
import 'package:swithfiber_tech/features/lcp_nap/repositories/lcp_nap_repository.dart';
import 'package:swithfiber_tech/features/lcp_nap/signals/lcp_nap_signals.dart';
import 'package:swithfiber_tech/main.dart';

/// Captures the outgoing request instead of hitting the live server.
class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    captured = options;
    return ResponseBody.fromString('{}', 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // The request interceptor reads the bearer token from secure storage,
    // which has no platform implementation under `flutter test`.
    final store = <String, String>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        switch (call.method) {
          case 'read':
            return store[call.arguments['key']];
          case 'write':
            store[call.arguments['key']] = call.arguments['value'] as String;
            return null;
          case 'readAll':
            return store;
          default:
            return null;
        }
      },
    );
  });

  test('a reset request sends username, the only field the API accepts',
      () async {
    final adapter = _RecordingAdapter();
    final dio = ApiClient.instance.dio;
    final original = dio.httpClientAdapter;
    dio.httpClientAdapter = adapter;
    addTearDown(() => dio.httpClientAdapter = original);

    await AuthService().requestPasswordReset('  tech_marcos  ');

    final captured = adapter.captured!;
    expect(captured.path, '/Auth/request-password-reset');
    expect(captured.method, 'POST');

    final body = captured.data as Map;
    // The server answers an `email` key with 400 "The Username field is
    // required", so the payload must carry `username` and nothing else.
    expect(body['username'], 'tech_marcos',
        reason: 'the username must be sent trimmed');
    expect(body.containsKey('email'), isFalse,
        reason: 'the endpoint rejects an email field with a 400');
    expect(jsonEncode(body), '{"username":"tech_marcos"}');
  });

  testWidgets('the sign-in field asks for a username only, never an email',
      (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final jobsSignals = JobsSignals(JobRepository(db.jobOrdersDao));
    final lcpNapSignals =
        LcpNapSignals(LcpNapRepository(LcpNapLocationsDao(db)));
    final authSignals = AuthSignals.instance;
    authSignals.currentUser.value = null;

    await tester.pumpWidget(
      SwitchFiberTechApp(
        authSignals: authSignals,
        jobsSignals: jobsSignals,
        lcpNapSignals: lcpNapSignals,
        showSplash: false,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Username or Email'), findsNothing,
        reason: 'technicians sign in with a username only');

    await tester.runAsync(() async {
      await lcpNapSignals.dispose();
      await db.close();
    });
  });
}
