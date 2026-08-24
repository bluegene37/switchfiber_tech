import 'package:signals_flutter/signals_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Central reactive signals for technician authentication state.
class AuthSignals {
  static final AuthSignals instance = AuthSignals._internal();
  factory AuthSignals() => instance;
  AuthSignals._internal();

  final AuthService _authService = AuthService();

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
    await _authService.logout();
    currentUser.value = null;
    authError.value = null;
  }
}
