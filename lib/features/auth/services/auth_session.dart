import '../models/user_model.dart';

/// A technician session as returned by an authentication endpoint: the profile
/// plus the bearer token that authorises every later request.
///
/// Both `POST /api/Users/login` and `POST /api/Auth/google` return the same
/// envelope, so both paths parse through here and cannot drift apart.
class AuthSession {
  final UserModel user;
  final String token;

  const AuthSession({required this.user, required this.token});

  /// Parse an authentication response body.
  ///
  /// Accepts either the `{token, user: {...}}` envelope or a bare user map for
  /// servers that return the profile unwrapped. Throws when the body is empty,
  /// when the user payload is not a map, or when the account is inactive.
  factory AuthSession.fromResponse(dynamic data) {
    if (data == null) {
      throw Exception('Empty response from authentication server.');
    }

    final rawUser = data is Map<String, dynamic> && data['user'] != null
        ? data['user']
        : data;

    if (rawUser is! Map<String, dynamic>) {
      throw Exception('Invalid user data returned from authentication server.');
    }

    final user = UserModel.fromJson(rawUser);

    if (!user.active) {
      throw Exception(
          'Your technician account is inactive. Please contact Dispatch.');
    }

    final token = data is Map<String, dynamic>
        ? (data['token'] ?? data['accessToken'] ?? '')
        : '';

    return AuthSession(user: user, token: token.toString());
  }
}
