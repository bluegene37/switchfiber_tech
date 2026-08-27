import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/network/network_exceptions.dart';
import 'package:swithfiber_tech/features/auth/services/auth_session.dart';
import 'package:swithfiber_tech/features/auth/services/google_auth_errors.dart';
import 'package:swithfiber_tech/features/auth/signals/auth_signals.dart';

/// Build the ApiException the client produces for a real 403 from
/// POST /api/Auth/google, so the code-to-copy path is exercised end to end
/// rather than asserted on a hand-made object.
ApiException rejection(String code, String message) {
  final request = RequestOptions(path: '/Auth/google');
  return ApiException.fromDioException(
    DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: request,
        statusCode: 403,
        data: {'message': message, 'code': code},
      ),
    ),
  );
}

String copyFor(ApiException e) {
  final details = e.details;
  return googleAuthMessage(
    code: details is Map<String, dynamic> ? details['code']?.toString() : null,
    serverMessage: e.message,
  );
}

void main() {
  group('Google login rejections', () {
    test('an unprovisioned account tells the technician to call Dispatch', () {
      final e = rejection('ACCOUNT_NOT_PROVISIONED', 'No such user.');
      expect(e.statusCode, 403);
      expect(copyFor(e),
          "This Google account isn't linked to a technician profile. "
          'Contact Dispatch.');
    });

    test('a mismatched Google account is explained specifically', () {
      final e = rejection('ACCOUNT_MISMATCH', 'Linked to another Google user.');
      expect(copyFor(e),
          "This Google account doesn't match the one linked to your profile. "
          'Contact Dispatch.');
    });

    test('an unrecognised code still surfaces the server wording', () {
      final e = rejection('RATE_LIMITED', 'Too many attempts. Wait a minute.');
      expect(copyFor(e), 'Too many attempts. Wait a minute.');
    });
  });

  group('Google login success', () {
    test('parses the same envelope the password endpoint returns', () {
      // POST /api/Auth/google must return this byte-identically to
      // POST /api/Users/login; that equivalence is the whole design.
      final session = AuthSession.fromResponse({
        'token': 'google-issued-switchfiber-jwt',
        'user': {
          'id': 7,
          'username': 'tech_marcos',
          'fname': 'Marcos',
          'lname': 'Dela Cruz',
          'email': 'marcos@switchfiber.ph',
          'accesslevel_id': 1,
          'active': true,
        },
      });
      expect(session.token, 'google-issued-switchfiber-jwt');
      expect(session.user.fullName, 'Marcos Dela Cruz');
      expect(session.user.email, 'marcos@switchfiber.ph');
    });

    test('an inactive account is refused even if the server let it through',
        () {
      expect(
        () => AuthSession.fromResponse({
          'token': 't',
          'user': {'id': 7, 'username': 'x', 'active': false},
        }),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AuthSignals.loginWithGoogle', () {
    tearDown(() {
      AuthSignals.instance.obtainGoogleIdToken = null;
      AuthSignals.instance.authError.value = null;
      AuthSignals.instance.authLoading.value = false;
      AuthSignals.instance.currentUser.value = null;
    });

    test('dismissing the account chooser is silent, not an error', () async {
      final auth = AuthSignals.instance;
      auth.obtainGoogleIdToken = () async => null;

      final result = await auth.loginWithGoogle();

      expect(result, isFalse);
      expect(auth.authError.value, isNull,
          reason: 'a technician who backs out of the chooser has not hit an '
              'error and must not be shown one');
      expect(auth.authLoading.value, isFalse,
          reason: 'the spinner must stop when the chooser is dismissed');
      expect(auth.currentUser.value, isNull);
    });

    test('a failure obtaining the token surfaces its message', () async {
      final auth = AuthSignals.instance;
      auth.obtainGoogleIdToken =
          () async => throw Exception("Google sign-in isn't configured for "
              'this build.');

      final result = await auth.loginWithGoogle();

      expect(result, isFalse);
      expect(auth.authError.value, "Google sign-in isn't configured for this "
          'build.');
      expect(auth.authLoading.value, isFalse);
    });
  });
}
