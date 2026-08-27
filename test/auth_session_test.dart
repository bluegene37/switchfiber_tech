import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/auth/services/auth_session.dart';

/// The envelope POST /api/Users/login returns, and the one POST /api/Auth/google
/// must return byte-identically.
Map<String, dynamic> loginEnvelope({bool active = true}) => {
      'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.header.sig',
      'user': {
        'id': 1,
        'username': 'bluegene37',
        'fname': 'Gene',
        'lname': 'Medel',
        'email': 'bluegene37@gmail.com',
        'accesslevel_id': 1,
        'active': active,
      },
    };

void main() {
  group('AuthSession.fromResponse', () {
    test('reads the token and user out of the login envelope', () {
      final session = AuthSession.fromResponse(loginEnvelope());
      expect(session.token, startsWith('eyJhbGciOi'));
      expect(session.user.id, 1);
      expect(session.user.fullName, 'Gene Medel');
      expect(session.user.email, 'bluegene37@gmail.com');
    });

    test('accepts a bare user map with no envelope, leaving the token empty',
        () {
      final session = AuthSession.fromResponse({
        'id': 2,
        'username': 'tech_marcos',
        'fname': 'Marcos',
        'lname': 'Dela Cruz',
      });
      expect(session.token, isEmpty);
      expect(session.user.username, 'tech_marcos');
    });

    test('accepts accessToken as the token key', () {
      final data = loginEnvelope()..remove('token');
      data['accessToken'] = 'alternate-token';
      expect(AuthSession.fromResponse(data).token, 'alternate-token');
    });

    test('rejects an inactive technician', () {
      expect(
        () => AuthSession.fromResponse(loginEnvelope(active: false)),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message',
            contains('inactive'))),
      );
    });

    test('rejects an empty body', () {
      expect(() => AuthSession.fromResponse(null), throwsA(isA<Exception>()));
    });

    test('rejects a user payload that is not a map', () {
      expect(
        () => AuthSession.fromResponse({'token': 'x', 'user': 'not-a-map'}),
        throwsA(isA<Exception>()),
      );
    });
  });
}
