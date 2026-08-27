# Google Sign-In Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a technician establish a Switch Fiber session with Google, alongside the existing username/password login, behind a build flag.

**Architecture:** Google sign-in is an alternate way to obtain the *same* session. `GoogleSignInService` gets a Google ID token, `AuthService.loginWithGoogle` trades it at `POST /api/Auth/google` for the identical `{token, user}` body `/api/Users/login` returns today, and everything downstream is untouched. Parsing and error-copy logic are extracted as pure functions so they are testable without adding a mocking dependency.

**Tech Stack:** Flutter 3.47 / Dart 3.13, `google_sign_in` 7.2.0, `signals_flutter`, `dio`, `flutter_secure_storage`.

**Spec:** `docs/superpowers/specs/2026-08-27-google-sign-in-design.md`

## Global Constraints

- `google_sign_in: ^7.2.0`; `environment.sdk` must be `^3.7.0` (7.2.0 requires it).
- No new mocking package. Tests are pure-Dart unit tests plus `flutter_test` widget tests, matching the existing style in `test/`.
- Feature flag: `bool.fromEnvironment('GOOGLE_SIGN_IN', defaultValue: true)`. When disabled the button must not render **and** the plugin must never be initialized.
- The success response of `/api/Auth/google` is byte-identical to `/api/Users/login`: `{ token, user: {...} }`.
- Error bodies are `{ "message": ..., "code": ... }` with codes `ACCOUNT_NOT_PROVISIONED`, `ACCOUNT_INACTIVE`, `ACCOUNT_MISMATCH`.
- `google_sign_in` may only be imported by `lib/features/auth/services/google_sign_in_service.dart`.
- Verified API surface (7.2.0, read from the pub cache — do not improvise):
  - `GoogleSignIn.instance.initialize({String? clientId, String? serverClientId})`
  - `GoogleSignIn.instance.supportsAuthenticate() -> bool`
  - `GoogleSignIn.instance.authenticate() -> Future<GoogleSignInAccount>` (throws `GoogleSignInException`)
  - `account.authentication.idToken -> String?`
  - `GoogleSignInException{ GoogleSignInExceptionCode code, String? description }`
  - `GoogleSignInExceptionCode.{unknownError, canceled, interrupted, clientConfigurationError, providerConfigurationError, uiUnavailable, userMismatch}`
  - `GoogleSignIn.instance.signOut()`

---

### Task 1: Extract session parsing as a pure function

Today `AuthService.login()` parses `{token, user}`, checks `active`, and persists — all inline. The Google path needs the identical logic, and inline code cannot be tested without hitting storage.

**Files:**
- Create: `lib/features/auth/services/auth_session.dart`
- Modify: `lib/features/auth/services/auth_service.dart`
- Test: `test/auth_session_test.dart`

**Interfaces:**
- Consumes: `UserModel.fromJson` from `lib/features/auth/models/user_model.dart`.
- Produces: `class AuthSession { final UserModel user; final String token; }` and `factory AuthSession.fromResponse(dynamic data)`, which throws `Exception` on an empty body, a non-map user, or an inactive account.

- [ ] **Step 1: Write the failing test** — `test/auth_session_test.dart` covering: the nested `{token, user:{...}}` shape; a bare user map with no envelope (token empty); an empty body throwing; an inactive account throwing; a non-map user throwing.
- [ ] **Step 2: Run it and confirm it fails** — `flutter test test/auth_session_test.dart`, expect a compile failure on the missing file.
- [ ] **Step 3: Implement `AuthSession`** — move the logic verbatim out of `AuthService.login()`, preserving the existing message "Your technician account is inactive. Please contact Dispatch."
- [ ] **Step 4: Rewrite `AuthService.login()` to use it** — behaviour must not change; it still saves the token when non-empty and always saves the session.
- [ ] **Step 5: Run the full suite** — `flutter test`, all green, proving the refactor broke nothing.
- [ ] **Step 6: Commit.**

---

### Task 2: Google error copy as a pure function

**Files:**
- Create: `lib/features/auth/services/google_auth_errors.dart`
- Test: `test/google_auth_errors_test.dart`

**Interfaces:**
- Produces: `String googleAuthMessage({String? code, String? serverMessage})`.

Mapping, exactly as specified:

| `code` | Returned copy |
|---|---|
| `ACCOUNT_NOT_PROVISIONED` | `This Google account isn't linked to a technician profile. Contact Dispatch.` |
| `ACCOUNT_INACTIVE` | `Your technician account is inactive. Please contact Dispatch.` |
| `ACCOUNT_MISMATCH` | `This Google account doesn't match the one linked to your profile. Contact Dispatch.` |
| anything else / null | `serverMessage` if non-empty, else `Google sign-in failed. Please try again.` |

- [ ] **Step 1: Write the failing test** — one case per row above, plus an unknown code falling back to `serverMessage`, plus a null/empty `serverMessage` falling back to the generic line.
- [ ] **Step 2: Run it and confirm it fails.**
- [ ] **Step 3: Implement the function.**
- [ ] **Step 4: Run the tests and confirm they pass.**
- [ ] **Step 5: Commit.**

---

### Task 3: Feature flag and OAuth client ID constants

**Files:**
- Modify: `lib/core/constants/app_constants.dart`
- Test: `test/google_sign_in_config_test.dart`

**Interfaces:**
- Produces: `AppConstants.googleSignInEnabled`, `AppConstants.googleServerClientId`, `AppConstants.googleIosClientId`, `AppConstants.googleSignInConfigured`.

`googleSignInConfigured` is `googleSignInEnabled && googleServerClientId` not being the unset placeholder. The client IDs ship as the empty string until the Google Cloud project exists; the UI must degrade to a clear message rather than a crash.

- [ ] **Step 1: Write the failing test** — asserts the flag defaults to `true`, and that `googleSignInConfigured` is `false` while the client ID is empty.
- [ ] **Step 2: Run it and confirm it fails.**
- [ ] **Step 3: Add the constants.**
- [ ] **Step 4: Run the tests and confirm they pass.**
- [ ] **Step 5: Commit.**

---

### Task 4: `GoogleSignInService` plugin wrapper

The only file in the app permitted to import `google_sign_in`.

**Files:**
- Create: `lib/features/auth/services/google_sign_in_service.dart`

**Interfaces:**
- Consumes: `AppConstants.googleServerClientId`, `googleIosClientId`, `googleSignInConfigured`.
- Produces: `GoogleSignInService.instance`, `Future<String?> obtainIdToken()` (returns `null` when the technician dismisses the chooser), `Future<void> signOut()`.

`obtainIdToken` must: return `null` on `GoogleSignInExceptionCode.canceled`; throw `Exception('Google sign-in isn\'t configured for this build.')` when unconfigured, when `supportsAuthenticate()` is false, on `clientConfigurationError` / `providerConfigurationError`, or when `idToken` comes back null; and `initialize()` exactly once, lazily.

- [ ] **Step 1: Implement the service.** No unit test — it is a thin passthrough over a platform plugin with no seam to fake, and every branch it owns is asserted through Tasks 2 and 6. Behaviour is verified on-device.
- [ ] **Step 2: Run `flutter analyze`** — expect no issues.
- [ ] **Step 3: Commit.**

---

### Task 5: Wire the Google login through service and signals

**Files:**
- Modify: `lib/features/auth/services/auth_service.dart`
- Modify: `lib/features/auth/signals/auth_signals.dart`
- Test: `test/google_login_flow_test.dart`

**Interfaces:**
- Consumes: `AuthSession.fromResponse` (Task 1), `googleAuthMessage` (Task 2), `GoogleSignInService.obtainIdToken` (Task 4).
- Produces: `AuthService.loginWithGoogle(String idToken) -> Future<UserModel>`, `AuthSignals.loginWithGoogle() -> Future<bool>`.

`AuthSignals.loginWithGoogle()` returns `false` **without setting `authError`** when `obtainIdToken()` returns null, so a dismissed chooser is silent. On an `ApiException` it reads `details['code']` and passes it through `googleAuthMessage`. `AuthSignals.logout()` additionally calls `GoogleSignInService.instance.signOut()`, guarded so a disabled flag is a no-op.

- [ ] **Step 1: Write the failing test** — asserts that a 403 body `{message, code}` maps to the right copy through `ApiException` plus `googleAuthMessage`, and that `AuthSession.fromResponse` accepts the `/api/Auth/google` success body unchanged.
- [ ] **Step 2: Run it and confirm it fails.**
- [ ] **Step 3: Implement `loginWithGoogle` on both layers.**
- [ ] **Step 4: Run the full suite and confirm it passes.**
- [ ] **Step 5: Commit.**

---

### Task 6: Login screen button behind the flag

**Files:**
- Modify: `lib/features/auth/screens/login_screen.dart`
- Test: `test/google_login_button_test.dart`

**Interfaces:**
- Consumes: `AuthSignals.loginWithGoogle` (Task 5), `AppConstants.googleSignInEnabled` (Task 3).
- Produces: `LoginScreen({bool? googleEnabled})` — a test-only override that defaults to `AppConstants.googleSignInEnabled`.

An "or" divider and an outlined `Continue with Google` button below the existing sign-in button, matching `AppTheme`. Disabled while `authLoading` is true.

- [ ] **Step 1: Write the failing widget test** — `LoginScreen(googleEnabled: true)` finds `Continue with Google`; `LoginScreen(googleEnabled: false)` finds nothing; the username and password fields are present in both.
- [ ] **Step 2: Run it and confirm it fails.**
- [ ] **Step 3: Implement the button and the override.**
- [ ] **Step 4: Run the full suite and confirm it passes.**
- [ ] **Step 5: Commit.**

---

### Task 7: Platform configuration and documentation

No test — this is configuration that only a real device exercises.

**Files:**
- Modify: `ios/Runner/Info.plist`
- Modify: `API_SCHEMA.md`
- Create: `docs/google-sign-in-setup.md`

- [ ] **Step 1: Document the setup** — `docs/google-sign-in-setup.md` recording the Google Cloud steps the repo cannot perform: create the OAuth consent screen; create an Android client with package `ph.switchfiber.swithfiber_tech` plus the debug and release SHA-1 fingerprints; create an iOS client with bundle ID `ph.switchfiber.swithfiber_tech`; create a Web client whose ID becomes `googleServerClientId` and the backend's expected `aud`; then fill the two constants and add the reversed iOS client ID to `Info.plist`.
- [ ] **Step 2: Add the `CFBundleURLTypes` block to `Info.plist`** with a commented placeholder for the reversed client ID.
- [ ] **Step 3: Document `POST /api/Auth/google` in `API_SCHEMA.md` section 2** — request, success body, the three error codes, and the six verification steps the backend owes.
- [ ] **Step 4: Run `flutter analyze` and the full test suite.**
- [ ] **Step 5: Commit.**

---

## Verification Limits

Tasks 1-6 are fully verifiable in this repo. End-to-end sign-in is **not** verifiable here and must not be claimed: it needs a Google Cloud project that does not exist yet, and the `POST /api/Auth/google` endpoint that the backend team has yet to build. Until both land, `googleSignInConfigured` stays false and the button reports that the build is unconfigured.
