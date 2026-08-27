import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/network/network_exceptions.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/google_auth_errors.dart';
import '../services/google_sign_in_service.dart';

/// Central reactive signals for technician authentication state.
class AuthSignals {
  static final AuthSignals instance = AuthSignals._internal();
  factory AuthSignals() => instance;
  AuthSignals._internal();

  final AuthService _authService = AuthService();

  /// Source of the Google ID token. Overridable in tests so the sign-in flow
  /// can be exercised without the platform plugin; null means use the real one.
  Future<String?> Function()? obtainGoogleIdToken;

  // Signals
  final currentUser = signal<UserModel?>(null);
  final authLoading = signal<bool>(false);
  final authError = signal<String?>(null);
  final rememberMe = signal<bool>(true);

  // Computed state
  late final ReadonlySignal<bool> isAuthenticated = computed(
    () => currentUser.value != null,
  );

  /// Restore user session on startup
  Future<void> restoreSession() async {
    authLoading.value = true;
    try {
      final user = await _authService.restoreSession();
      currentUser.value = user;
    } catch (e) {
      authError.value = e.toString();
    } finally {
      authLoading.value = false;
    }
  }

  /// Perform technician login
  Future<bool> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    authLoading.value = true;
    authError.value = null;
    try {
      final user = await _authService.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );
      currentUser.value = user;
      return true;
    } catch (e) {
      authError.value = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      authLoading.value = false;
    }
  }

  /// Sign in with Google.
  ///
  /// Returns false both when the technician dismisses the account chooser and
  /// when the exchange fails - but only the failure sets [authError]. Backing
  /// out of the chooser is a choice, not an error, and must stay silent.
  Future<bool> loginWithGoogle() async {
    authLoading.value = true;
    authError.value = null;
    try {
      final source =
          obtainGoogleIdToken ?? GoogleSignInService.instance.obtainIdToken;
      final idToken = await source();
      if (idToken == null) return false;

      currentUser.value = await _authService.loginWithGoogle(idToken);
      return true;
    } on ApiException catch (e) {
      final details = e.details;
      authError.value = googleAuthMessage(
        code:
            details is Map<String, dynamic> ? details['code']?.toString() : null,
        serverMessage: e.message,
      );
      return false;
    } catch (e) {
      authError.value = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      authLoading.value = false;
    }
  }

  /// Refresh the signed-in technician's profile from the server.
  /// Silently keeps the cached profile when offline.
  Future<void> refreshProfile() async {
    final current = currentUser.value;
    if (current == null) return;
    try {
      currentUser.value = await _authService.fetchProfile(current.id);
    } catch (_) {
      // Offline or endpoint unavailable: the cached session stays valid.
    }
  }

  /// Perform technician logout
  Future<void> logout() async {
    // Clear Google's own state too, so the next sign-in shows the account
    // chooser instead of silently reusing the last technician's account.
    await GoogleSignInService.instance.signOut();
    await _authService.logout();
    currentUser.value = null;
    authError.value = null;
  }
}
