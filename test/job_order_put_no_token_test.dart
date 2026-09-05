import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/constants/app_constants.dart';
import 'package:swithfiber_tech/core/network/api_client.dart';
import 'package:swithfiber_tech/features/jobs/services/job_orders_api.dart';

/// Records every outgoing request instead of hitting the live server.
class _RecordingAdapter implements HttpClientAdapter {
  final captured = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    captured.add(options);
    return ResponseBody.fromString('{}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingAdapter adapter;

  setUp(() {
    // A signed-in phone holds a token; the point is what the PUT does with it.
    final store = <String, String>{AppConstants.keyJwtToken: 'jwt-abc'};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => call.method == 'read' ? store[call.arguments['key']] : null,
    );

    adapter = _RecordingAdapter();
    final dio = ApiClient.instance.dio;
    final original = dio.httpClientAdapter;
    dio.httpClientAdapter = adapter;
    addTearDown(() => dio.httpClientAdapter = original);
  });

  test('the job order PUT goes out bare, with no Authorization header',
      () async {
    await DioJobOrdersApi().update(3979, {'status': 'Completed'});

    final put = adapter.captured.single;
    expect(put.method, 'PUT');
    expect(put.uri.toString(), endsWith('/api/JobOrders/3979'));
    expect(put.headers.containsKey('Authorization'), isFalse,
        reason: 'the bare curl is what the server accepts; the app must send '
            'the same request');
    expect(put.headers['Content-Type'], 'application/json');
  });

  test('every other call still carries the token', () async {
    await DioJobOrdersApi().fetchById(3979);

    final get = adapter.captured.single;
    expect(get.method, 'GET');
    expect(get.headers['Authorization'], 'Bearer jwt-abc',
        reason: 'only the update is sent bare');
  });
}
