import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/features/auth/services/google_auth_errors.dart';

void main() {
  group('googleAuthMessage', () {
    test('explains an unprovisioned Google account', () {
      expect(
        googleAuthMessage(code: 'ACCOUNT_NOT_PROVISIONED'),
        "This Google account isn't linked to a technician profile. "
        'Contact Dispatch.',
      );
    });

    test('reuses the existing inactive-account wording', () {
      expect(
        googleAuthMessage(code: 'ACCOUNT_INACTIVE'),
        'Your technician account is inactive. Please contact Dispatch.',
      );
    });

    test('explains a Google account bound to a different profile', () {
      expect(
        googleAuthMessage(code: 'ACCOUNT_MISMATCH'),
        "This Google account doesn't match the one linked to your profile. "
        'Contact Dispatch.',
      );
    });

    test('matches the code regardless of casing or padding', () {
      expect(
        googleAuthMessage(code: ' account_not_provisioned '),
        startsWith("This Google account isn't linked"),
      );
    });

    test('falls back to the server message for an unknown code', () {
      expect(
        googleAuthMessage(code: 'SOMETHING_NEW', serverMessage: 'Try later.'),
        'Try later.',
      );
    });

    test('falls back to the server message when there is no code', () {
      expect(
        googleAuthMessage(serverMessage: 'Gateway timeout.'),
        'Gateway timeout.',
      );
    });

    test('falls back to generic copy when the server says nothing useful', () {
      expect(
        googleAuthMessage(serverMessage: '   '),
        'Google sign-in failed. Please try again.',
      );
      expect(
        googleAuthMessage(),
        'Google sign-in failed. Please try again.',
      );
    });
  });
}
