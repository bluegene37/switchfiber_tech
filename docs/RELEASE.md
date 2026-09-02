# Release guide

How to cut a store-ready build of Switch Fiber Tech. The CI pipeline
(`.github/workflows/ci.yml`) gates every pull request; the release pipeline
(`.github/workflows/release.yml`) builds signed Android artifacts when a `v*`
tag is pushed. iOS is built and uploaded from a Mac with Xcode signing.

## 1. One-time setup

### Android upload keystore

```bash
keytool -genkey -v -keystore ~/switchfiber-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Copy `android/key.properties.example` to `android/key.properties` and fill in
the path and passwords. The file is gitignored. **Back the keystore up
somewhere durable**: losing it means the app can never be updated on Google
Play under this application ID.

For CI, add these repository secrets:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -i ~/switchfiber-upload.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `ANDROID_KEY_ALIAS` | `upload` |
| `ANDROID_KEY_PASSWORD` | key password |

### Android SDK licenses

Release builds fail until the SDK licenses are accepted on the build machine.
This is interactive and must be run once by a person:

```bash
flutter doctor --android-licenses
```

### iOS signing

Open `ios/Runner.xcworkspace` in Xcode, select the Runner target, and enable
*Automatically manage signing* with the Switch Fiber team. The bundle
identifier is `ph.switchfiber.swithfiberTech`; it must exist in App Store
Connect before the first upload.

### Application identifiers

| Platform | Identifier |
|---|---|
| Android | `ph.switchfiber.swithfiber_tech` |
| iOS | `ph.switchfiber.swithfiberTech` |

Both carry the historical "swithfiber" spelling. Identifiers cannot be changed
after the first store upload, so if they are to be corrected, do it before
release 1.0.0 ships and update `android/app/build.gradle.kts`, the Kotlin
package directory, and the Xcode project.

## 2. Cutting a release

1. Update `CHANGELOG.md`: move the *Unreleased* entries under a new version
   heading with today's date.
2. Bump `version:` in `pubspec.yaml` (`MAJOR.MINOR.PATCH+BUILD`). The build
   number must be higher than every build ever uploaded to either store. CI
   overrides it with the workflow run number, so it only needs bumping for
   local uploads.
3. Verify locally:

   ```bash
   flutter analyze --fatal-infos && dart format --set-exit-if-changed -o none lib test && flutter test
   ```

4. Tag and push:

   ```bash
   git tag v1.0.0 && git push origin v1.0.0
   ```

   The release workflow attaches `app-release.aab`, `app-release.apk`, and the
   obfuscation symbols to a GitHub Release.

## 3. Building locally

Android, signed and obfuscated:

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/android
```

Direct-install APK for technicians outside the Play Store:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/symbols/android
```

iOS:

```bash
flutter build ipa --release --obfuscate --split-debug-info=build/symbols/ios
```

Then upload `build/ios/ipa/*.ipa` with Transporter or
`xcrun altool --upload-app`.

**Keep the `build/symbols` directory for every release.** Without it, crash
stack traces from obfuscated builds cannot be read, and the symbols cannot be
regenerated later.

## 4. Store submission checklist

- [ ] Version and build number bumped; build number never used before.
- [ ] `android/key.properties` present, or CI secrets set: the Gradle log must
      not print the "signed with the DEBUG key" warning.
- [ ] Obfuscation symbols archived with the release.
- [ ] Signed build tested on a real low-end Android device against the
      production API, including sign-in, pull-to-refresh, and an offline edit
      that syncs when the connection returns.
- [ ] Play Console *Data safety* form completed: the app collects technician
      account data and job-order records, transmitted over TLS, not shared.
- [ ] App Store Connect privacy questions answered to match.
- [ ] Certificate pin in `AppConstants.pinnedApiCertSha256` matches the
      production server's current certificate. A reissued server certificate
      breaks every installed build until an update ships.
- [ ] Staged rollout on Play (start at 10 to 20 percent); TestFlight before App
      Store review.

## 5. After release

Watch crash-free sessions for the first 24 hours. A Play staged rollout can be
halted; an App Store release can only be superseded by a new build, so the iOS
bar for "ready" is higher.
