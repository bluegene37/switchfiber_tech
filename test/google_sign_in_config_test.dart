import 'package:flutter_test/flutter_test.dart';
import 'package:swithfiber_tech/core/constants/app_constants.dart';

void main() {
  group('Google sign-in configuration', () {
    test('the feature flag defaults to on', () {
      expect(AppConstants.googleSignInEnabled, isTrue,
          reason: 'GOOGLE_SIGN_IN defaults to true; '
              'pass --dart-define=GOOGLE_SIGN_IN=false to disable it');
    });

    test('is not considered configured until a server client ID is set', () {
      // The Google Cloud project does not exist yet. Until someone fills in
      // googleServerClientId the button must report an unconfigured build
      // rather than opening a chooser that cannot succeed.
      expect(
        AppConstants.googleSignInConfigured,
        AppConstants.googleServerClientId.trim().isNotEmpty,
      );
    });
  });
}
