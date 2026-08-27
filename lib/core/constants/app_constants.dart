/// Application constants and storage keys.
class AppConstants {
  static const String appName = 'Switch Fiber Tech';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Switch Fiber';
  static const String appTagline = 'Distributed Fiber Network Management';

  // API Config
  static const String defaultBaseUrl = 'https://103.249.198.43:8090/api';
  static const int connectTimeout = 30000; // 30s
  // GET /JobOrders currently returns the entire unpaginated table (~10.8 MB,
  // ~55 s), which sits right on the old 60 s ceiling. Raised until the endpoint
  // supports paging or technician-scoped filtering.
  static const int receiveTimeout = 120000; // 120s

  /// SHA-256 fingerprint of the API server's self-signed certificate.
  /// Update this whenever the server certificate is reissued.
  static const String pinnedApiCertSha256 =
      '3C:5F:C8:D3:27:79:0C:D6:F3:D6:CC:56:70:45:37:C5:'
      '95:D3:16:B4:32:78:3D:72:78:6A:83:95:26:2B:7C:33';

  // Google Sign-In
  //
  // An alternate way to establish the same technician session: the Google ID
  // token is exchanged at POST /api/Auth/google for the identical {token, user}
  // envelope POST /api/Users/login returns.
  //
  // Defaults to on. Build with --dart-define=GOOGLE_SIGN_IN=false to drop the
  // button entirely; the plugin is then never initialised.
  static const bool googleSignInEnabled =
      bool.fromEnvironment('GOOGLE_SIGN_IN', defaultValue: true);

  /// OAuth Web client ID. This is the value the backend must accept as the
  /// `aud` claim, so it has to match what the API verifies.
  ///
  /// OAuth client IDs are public identifiers, not secrets.
  /// Empty until the Google Cloud project exists - see
  /// docs/google-sign-in-setup.md.
  static const String googleServerClientId = '';

  /// OAuth iOS client ID. Must match the reversed URL scheme in
  /// ios/Runner/Info.plist. Empty until the Cloud project exists.
  static const String googleIosClientId = '';

  /// Whether Google sign-in can actually be attempted in this build.
  ///
  /// The flag being on is not enough: without a server client ID the chooser
  /// could open but never produce a usable token, so the UI reports an
  /// unconfigured build instead.
  static bool get googleSignInConfigured =>
      googleSignInEnabled && googleServerClientId.trim().isNotEmpty;

  // Storage Keys
  static const String keyJwtToken = 'jwt_token';
  static const String keyUserSession = 'user_session';
  static const String keyApiBaseUrl = 'api_base_url';
  static const String keyDarkMode = 'dark_mode_enabled';

  // Optical Power dBm Standards (GPON standard)
  static const double opticalMinOptimal = -24.0;
  static const double opticalMaxOptimal = -12.0;
  static const double opticalMarginalFloor = -27.0;
  static const double opticalSaturationCeiling = -8.0;

  // Job Order Status Constants
  static const String statusPending = 'pending';
  static const String statusInProgress = 'inprogress';
  static const String statusCompleted = 'completed';
  static const String statusActivated = 'activated';
  static const String statusFailed = 'failed';
}
