# Google Sign-In Layer — Design

**Date:** 2026-08-27
**Status:** Approved for implementation
**Scope:** Add Google as an alternate way to establish a Switch Fiber technician
session, alongside the existing username/password login.

## 1. Problem

The app authenticates through `POST /api/Users/login` with a username and
password, receives a JWT, and attaches it as a Bearer token to every subsequent
request. Technicians want to sign in with Google.

A survey of the live API (`https://103.249.198.43:8090/openapi/v1.json`, 79
paths) confirmed the backend has no external-identity support: `LoginRequest` is
`{username, password}`, `components.securitySchemes` is empty, and the only
auth-adjacent endpoints are `/api/Users/login`, `/api/Auth/request-password-reset`,
`/api/Auth/reset-password`, and the `/api/Token/*` family.

Google Sign-In on the device yields a Google ID token, which the Switch Fiber API
cannot currently accept. Without a Switch Fiber JWT the technician cannot load a
single job order. **The client half cannot work without a backend endpoint.**

## 2. Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Backend | We own it; add a new endpoint | Only approach that is actually secure |
| Login UX | Google **alongside** username/password | No lockout risk, no hard Play Services dependency |
| Identity mapping | Match verified Google email to an existing `Users` row; **reject** if none | Dispatch stays in control of who exists; never auto-provisions |
| Domain policy | **Any** Google account accepted | Chosen by product owner; see Risks |
| Platforms | Android **and** iOS | Both platform directories are live in the repo |
| Rollout | Behind a build flag, default `true` | Client can land before the endpoint deploys |

## 3. Architecture

One new seam. Google sign-in is an alternate way to obtain the *same* session,
not a second kind of session.

```
Today:
  LoginScreen -> AuthSignals.login() -> AuthService.login()
    -> POST /api/Users/login -> {token, user} -> secure storage

Added:
  LoginScreen -> AuthSignals.loginWithGoogle() -> GoogleSignInService.obtainIdToken()
    -> Google ID token
    -> AuthService.loginWithGoogle(idToken)
    -> POST /api/Auth/google {idToken} -> {token, user}   [identical shape]
    -> secure storage
```

Because `/api/Auth/google` returns a response byte-identical to
`/api/Users/login`, the following are untouched: `UserModel`, the `ApiClient`
Bearer interceptor, the 401-to-logout hook in `main.dart`,
`AuthService.restoreSession()`, and every downstream feature.

The `google_sign_in` package is imported by exactly one file
(`google_sign_in_service.dart`). Nothing else in the app depends on its API. The
6.x-to-7.x rewrite is precedent for keeping that blast radius small.

## 4. Backend contract — `POST /api/Auth/google`

**Request:** `{ "idToken": "<Google ID token>" }`

**Verification, in order. All steps are mandatory.**

1. Verify the RS256 signature against Google's JWKS
   (`https://www.googleapis.com/oauth2/v3/certs`), cached per its
   `Cache-Control` header.
2. `iss` is `accounts.google.com` or `https://accounts.google.com`.
3. `aud` is one of our own OAuth client IDs. This is what prevents replay of a
   valid Google token minted for a different application. Non-negotiable.
4. `exp` is in the future.
5. `email_verified == true`.
6. Look up `Users` by `email`, case-insensitive, trimmed.

**Decision table:**

| Condition | Response |
|---|---|
| No matching `Users` row | `403` code `ACCOUNT_NOT_PROVISIONED` |
| Row exists, `active == false` | `403` code `ACCOUNT_INACTIVE` |
| Row has no `google_sub` | store the token's `sub`, issue JWT (`200`) |
| Row's `google_sub` equals the token's `sub` | issue JWT (`200`) |
| Row's `google_sub` differs from the token's `sub` | `403` code `ACCOUNT_MISMATCH` |

**Success response:** exactly the body `/api/Users/login` returns today —
`{ token, user: { ... } }`.

**Error response body:** `{ "message": "<human readable>", "code": "<CODE>" }`.
The client's existing `ApiException.fromDioException` already surfaces
`data['message']`, so server-supplied text reaches the UI with no new plumbing.

**Schema change:** `Users.google_sub`, nullable string, unique index.

**Also required:** rate-limit the endpoint, and record attempts in the existing
`LogTrail`.

## 5. Client changes

### 5.1 Feature flag

In `lib/core/constants/app_constants.dart`:

```dart
static const bool googleSignInEnabled =
    bool.fromEnvironment('GOOGLE_SIGN_IN', defaultValue: true);
```

Defaults to `true`. `--dart-define=GOOGLE_SIGN_IN=false` disables it per build
with no code edit. When disabled, the button is not rendered **and** the plugin
is never initialized, so an absent or wrong client ID cannot crash startup.

Alongside it: `googleServerClientId` and `googleIosClientId`. OAuth client IDs
are public identifiers, not secrets, so compile-time constants are appropriate.
`serverClientId` determines the `aud` claim the backend verifies in step 3.

### 5.2 Files

| File | Change |
|---|---|
| `pubspec.yaml` | add `google_sign_in: ^7.2.0`; raise `environment.sdk` from `^3.5.0` to `^3.7.0` (required by 7.2.0; local Dart is 3.13.1) |
| `lib/core/constants/app_constants.dart` | feature flag, `googleServerClientId`, `googleIosClientId` |
| **new** `lib/features/auth/services/google_sign_in_service.dart` | wraps the plugin; `Future<String?> obtainIdToken()` returns `null` on user cancel and throws on genuine failure; `signOut()`; lazy one-time `initialize()` |
| `lib/features/auth/services/auth_service.dart` | add `loginWithGoogle(String idToken)`; extract the shared "parse `{token, user}`, reject inactive, persist token and session" block currently inline in `login()` so both paths execute identical code |
| `lib/features/auth/signals/auth_signals.dart` | add `Future<bool> loginWithGoogle()`; call `GoogleSignInService.signOut()` from `logout()` so the next sign-in shows the account chooser |
| `lib/features/auth/screens/login_screen.dart` | divider plus Google button below the existing form, wrapped in the flag; optional `googleEnabled` constructor override for tests |
| `android/app/build.gradle.kts` and Google Cloud console | register SHA-1 fingerprints for the debug **and** release keystores |
| `ios/Runner/Info.plist` | reversed-client-ID URL scheme |
| `API_SCHEMA.md` | document `/api/Auth/google` in section 2 |

### 5.3 Error handling

| Situation | Behaviour |
|---|---|
| Technician dismisses the account chooser | Not an error. Loading stops, no snackbar, `authError` stays null. |
| `403 ACCOUNT_NOT_PROVISIONED` | "This Google account isn't linked to a technician profile. Contact Dispatch." |
| `403 ACCOUNT_INACTIVE` | Reuses the existing inactive-account copy. The server rejects inactive accounts before returning a user, so the client's own `active` check in the shared block never fires on this path; it is retained as defence in depth. |
| `403 ACCOUNT_MISMATCH` | "This Google account doesn't match the one linked to your profile. Contact Dispatch." |
| Google returns a null idToken | "Google sign-in isn't configured for this build." A `serverClientId` misconfiguration is a build error, not a user error, and must not hide behind generic copy. |
| Offline / timeout | Existing `ApiException` copy, unchanged. |

Client copy is keyed on the response `code` and falls back to the server's
`message`. A 403 does not trip the 401 interceptor, so a rejected Google login
leaves any existing session intact.

## 6. Testing

Test-driven, following the existing patterns under `test/`.

**Unit:**
- `loginWithGoogle` parses `{token, user}` and persists both token and session.
- An inactive account throws and stores nothing.
- Cancel returns `false`, sets no error, and clears the loading flag.
- Each 403 `code` maps to its user-facing message; an unknown code falls back to
  the server `message`.

**Widget** (extending `test/login_navigation_test.dart`):
- The Google button renders when enabled and is absent when disabled. This is
  why `LoginScreen` takes a `googleEnabled` override — a `const` cannot be
  flipped at test time.

## 7. Risks and accepted trade-offs

**Any-Google-account policy.** The product owner chose to accept any verified
Google account rather than restricting to a Workspace domain. The security of a
technician login therefore rests entirely on `Users.email` being accurate:
whoever controls that mailbox can sign in. Mitigations built into this design:

- `email_verified == true` is mandatory (section 4, step 5).
- Link-on-first-use binds the row to a specific Google `sub` after the first
  successful login, so a later email reassignment fails closed with
  `ACCOUNT_MISMATCH`.

The first login is not protected by either mitigation. **Dispatch should audit
`Users.email` for stale or shared addresses before the flag is turned on.**

**Unrelated, and more urgent than this feature.** `CreateTokenRequest` on
`POST /api/Token` carries `{userId, username, expirationDays, scope}` and no
credential field. If that endpoint is reachable without a valid Bearer token, it
mints a session for any named user on request, which would make every control in
this document moot. This was **not** tested against production. The backend
owners must confirm the endpoint is authenticated.

**App Store review.** Guideline 4.8 can require offering Sign in with Apple when
an app offers third-party login. Retaining username/password login, and internal
distribution, usually sidesteps it. Treated as a separate follow-up.

## 8. Out of scope

- Sign in with Apple.
- Auto-provisioning technician accounts.
- Workspace domain restriction or contractor allowlist.
- Any change to session lifetime, refresh, or the 401 handling path.
