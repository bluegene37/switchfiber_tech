import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/app_constants.dart';

/// The only file in the app that may import `google_sign_in`.
///
/// The package was rewritten between 6.x and 7.x; confining it here means the
/// next such rewrite touches one file. Everything else deals in a plain
/// `String?` ID token.
class GoogleSignInService {
  static final GoogleSignInService instance = GoogleSignInService._internal();

  factory GoogleSignInService() => instance;

  GoogleSignInService._internal();

  bool _initialised = false;

  static const String _unconfigured =
      "Google sign-in isn't configured for this build.";

  /// Initialise the plugin once, lazily.
  ///
  /// Lazily matters: a build with the flag off, or with the client IDs still
  /// empty, must never touch the plugin at startup.
  Future<void> _ensureInitialised() async {
    if (_initialised) return;
    await GoogleSignIn.instance.initialize(
      clientId: AppConstants.googleIosClientId.trim().isEmpty
          ? null
          : AppConstants.googleIosClientId.trim(),
      serverClientId: AppConstants.googleServerClientId.trim(),
    );
    _initialised = true;
  }

  /// Run the interactive Google sign-in and return the OpenID Connect ID token
  /// for the backend to verify.
  ///
  /// Returns `null` when the technician dismisses the chooser - a cancellation
  /// is not a failure and must not surface an error. Throws for everything
  /// else.
  Future<String?> obtainIdToken() async {
    if (!AppConstants.googleSignInConfigured) {
      throw Exception(_unconfigured);
    }

    await _ensureInitialised();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw Exception(
          'Google sign-in is not available on this device. Use your username '
          'and password.');
    }

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
          return null;
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          throw Exception(_unconfigured);
        case GoogleSignInExceptionCode.interrupted:
        case GoogleSignInExceptionCode.uiUnavailable:
        case GoogleSignInExceptionCode.userMismatch:
        case GoogleSignInExceptionCode.unknownError:
          throw Exception(e.description?.trim().isNotEmpty == true
              ? e.description!.trim()
              : 'Google sign-in failed. Please try again.');
      }
    }

    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      // Almost always a wrong or missing serverClientId: the chooser succeeds
      // but Google has no audience to mint an ID token for.
      throw Exception(_unconfigured);
    }
    return idToken;
  }

  /// Sign out of Google so the next attempt shows the account chooser again.
  ///
  /// Safe to call unconditionally: it is a no-op when the plugin was never
  /// initialised, which is the case for a build with the flag off.
  Future<void> signOut() async {
    if (!_initialised) return;
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Signing out of the Switch Fiber session is what matters; a failure to
      // clear Google's own state must never block it.
    }
  }
}
