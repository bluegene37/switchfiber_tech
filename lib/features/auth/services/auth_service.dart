import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

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

    final data = response.data;
    if (data == null) {
      throw Exception('Empty response from authentication server.');
    }

    // Extract user profile and token
    final rawUser = data is Map<String, dynamic> && data['user'] != null
        ? data['user']
        : data;

    if (rawUser is! Map<String, dynamic>) {
      throw Exception('Invalid user data returned from authentication server.');
    }

    final user = UserModel.fromJson(rawUser);

    if (!user.active) {
      throw Exception('Your technician account is inactive. Please contact Dispatch.');
    }

    final token = data is Map<String, dynamic>
        ? (data['token'] ?? data['accessToken'] ?? '')
        : '';

    if (token.toString().isNotEmpty) {
      await _storage.saveToken(token.toString());
    }

    await _storage.saveUserSession(user.toRawJson());

    return user;
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
