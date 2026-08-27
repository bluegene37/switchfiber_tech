import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';
import 'auth_session.dart';

/// Authentication service for field technician login and session management.
class AuthService {
  final ApiClient _api = ApiClient.instance;
  final SecureStorageService _storage = SecureStorageService.instance;

  /// Authenticate technician with username/email and password
  Future<UserModel> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final response = await _api.post(
      '/Users/login',
      data: {
        'username': usernameOrEmail.trim(),
        'password': password,
      },
    );

    return _persist(AuthSession.fromResponse(response.data));
  }

  /// Store a freshly established session and hand back the technician profile.
  Future<UserModel> _persist(AuthSession session) async {
    if (session.token.isNotEmpty) {
      await _storage.saveToken(session.token);
    }
    await _storage.saveUserSession(session.user.toRawJson());
    return session.user;
  }

  /// Exchange a Google ID token for a Switch Fiber session.
  ///
  /// The backend verifies the token against Google, maps the verified email to
  /// a technician record, and returns the same `{token, user}` envelope
  /// `/Users/login` returns - which is why both paths share [AuthSession] and
  /// [_persist].
  Future<UserModel> loginWithGoogle(String idToken) async {
    final response = await _api.post(
      '/Auth/google',
      data: {'idToken': idToken},
    );

    return _persist(AuthSession.fromResponse(response.data));
  }

  /// Restore active technician session from local storage on app start
  Future<UserModel?> restoreSession() async {
    try {
      final userJson = await _storage.getUserSession();
      if (userJson != null && userJson.isNotEmpty) {
        return UserModel.fromRawJson(userJson);
      }
    } catch (_) {
      await _storage.clearCredentials();
    }
    return null;
  }

  /// Fetch the technician's full profile.
  ///
  /// The login response carries only name, username and access level; contact
  /// number, address and email live on this endpoint.
  ///
  /// NOTE: this endpoint also returns the account password in plaintext.
  /// [UserModel] deliberately ignores that field so it never reaches storage.
  Future<UserModel> fetchProfile(int userId) async {
    final response = await _api.get('/Users/$userId');
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected profile response from server.');
    }
    final user = UserModel.fromJson(data);
    await _storage.saveUserSession(user.toRawJson());
    return user;
  }

  /// Request password reset link
  Future<void> requestPasswordReset(String email) async {
    await _api.post(
      '/Auth/request-password-reset',
      data: {'email': email.trim()},
    );
  }

  /// Terminate session and clear secure storage
  Future<void> logout() async {
    await _storage.clearCredentials();
  }
}
