# Google Sign-In Setup

Everything the repository cannot do for itself. Until all of it is done,
`AppConstants.googleSignInConfigured` stays false and the button reports an
unconfigured build instead of opening a chooser that cannot succeed.

Design and rationale: `docs/superpowers/specs/2026-08-27-google-sign-in-design.md`.

## 1. Google Cloud project

Create (or reuse) a project, then configure the OAuth consent screen. Four
client IDs are involved and it matters which is which.

| Client type | Needs | Used by |
|---|---|---|
| **Web** | nothing platform-specific | `AppConstants.googleServerClientId`, **and** the `aud` value the backend verifies |
| **Android** | package name `ph.switchfiber.swithfiber_tech` + SHA-1 | the Play Services sign-in flow |
| **iOS** | bundle ID `ph.switchfiber.swithfiber_tech` | `AppConstants.googleIosClientId` |

The Web client ID is the one that ends up inside the ID token as `aud`, because
the app passes it as `serverClientId`. The backend must verify against that
exact value.

### Android SHA-1 fingerprints

Both are required — debug builds fail silently against a release-only client.

```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | grep SHA1
```

For release, run the same command against the keystore named in
`android/app/build.gradle.kts` and register that SHA-1 too.

## 2. Fill in the constants

In `lib/core/constants/app_constants.dart`:

```dart
static const String googleServerClientId = '<web client ID>.apps.googleusercontent.com';
static const String googleIosClientId = '<iOS client ID>.apps.googleusercontent.com';
```

These are public identifiers, not secrets.

## 3. iOS URL scheme

In `ios/Runner/Info.plist`, uncomment the `CFBundleURLSchemes` entry and set it
to the **reversed** iOS client ID:

```
com.googleusercontent.apps.<iOS client ID without the suffix>
```

Sign-in will not return to the app without it.

## 4. Backend endpoint

`POST /api/Auth/google` must exist and must verify the ID token as documented in
`API_SCHEMA.md` §2.3. The client is complete without it, but every sign-in
attempt will fail until it ships.

## 5. Turning it off

The feature defaults to on. To ship a build without it:

```bash
flutter build apk --dart-define=GOOGLE_SIGN_IN=false
```

The button is then not rendered and the plugin is never initialised.
