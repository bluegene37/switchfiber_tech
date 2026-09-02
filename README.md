<p align="center">
  <img src="assets/images/logo.png" alt="Switch Fiber" width="96">
</p>

<h1 align="center">Switch Fiber Tech</h1>

<p align="center">
  Field operations app for Switch Fiber installation technicians.<br>
  Offline-first, built with Flutter for Android and iOS.
</p>

<p align="center">
  <a href="../../actions/workflows/ci.yml"><img alt="CI" src="../../actions/workflows/ci.yml/badge.svg"></a>
  <img alt="Flutter 3.47" src="https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white">
  <img alt="Platforms" src="https://img.shields.io/badge/platforms-Android%20%7C%20iOS-3DDC84">
  <img alt="Version" src="https://img.shields.io/badge/version-1.0.0-E74C5A">
</p>

---

Switch Fiber Tech puts a technician's day on one screen: the scheduled
installations waiting to be activated, the jobs they have already done, the
LCP/NAP plant on a map, and the calculators they reach for on a pole. Every
record is cached in SQLite, so the app keeps working in a basement with no
signal and syncs when the connection returns.

## Features

| Area | What it does |
|---|---|
| **Scheduled queue** | Lists scheduled work orders with search. Tapping a ticket opens its details, where it is marked *Activated* once the subscriber is online. |
| **My Job History** | Every *Activated* job order assigned to the signed-in technician's email, newest first. View-only, with date range (today, week, month, custom), area, and text filters plus weekly and monthly counts. |
| **Work-order detail** | Two-step workflow (Scheduled, Activated) with a confirmed *Mark as Activated* action, subscriber and location details, plant and hardware allocation, optical power reading, a zoomable gallery of attached photos, and one-tap navigation in Google Maps, Waze, or Apple Maps. |
| **Completion report** | Optical power gauge against GPON thresholds, ONT serial and model, NAP port, remarks, seven photo proofs taken with the camera or picked from the gallery (NAP box reading, ONT reading, installed setup, speed test, port label, signed contract, house front), and a drawn subscriber signature. Submitting it activates the job. |
| **LCP / NAP plant** | Cabinet and NAP records from the API on a clustered map with a satellite layer, cabinet grouping, filters, and cached tiles for offline use. |
| **Tech toolkit** | Optical link budget calculator, drop cable estimator, fiber color code reference, network diagnostic pings, and a field troubleshooting guide. |
| **Offline sync** | Edits are written to SQLite first and queued; a background worker replays them to the API and shows pending counts across the app. |
| **Settings** | Technician profile, configurable API base URL with a connectivity test, sync queue status, dark mode. |

## Architecture

The app is organised by feature, with a thin core layer underneath.

```
lib/
├── core/
│   ├── constants/      App-wide constants, storage keys, optical thresholds
│   ├── database/       Drift (SQLite) schema, migrations, and DAOs
│   ├── network/        Dio client with certificate pinning and 401 handling
│   ├── services/       External map navigation
│   ├── storage/        Secure storage (Keychain / Keystore)
│   ├── theme/          Light and dark Material themes
│   └── widgets/        Shared loading and skeleton states
└── features/
    ├── auth/           Login, session restore, technician profile
    ├── jobs/           Job orders: models, repository, sync worker, screens
    ├── lcp_nap/        Plant records, map tiles, clustering
    ├── reports/        On-site completion report
    ├── settings/       Settings screen and preferences
    ├── shell/          Bottom navigation and drawer
    ├── splash/         Launch screen
    └── toolkit/        Field calculators and references
```

Each feature follows the same shape: `models/` (DTOs), `repositories/`
(API plus local cache), `signals/` (reactive state), `screens/` and `widgets/`.

| Concern | Choice |
|---|---|
| State | [`signals_flutter`](https://pub.dev/packages/signals_flutter): Drift streams are piped into signals, screens rebuild from computed values. |
| Storage | [`drift`](https://pub.dev/packages/drift) over SQLite. Job orders keep the untouched API record in a `rawJson` column so updates round-trip every field the app does not model. |
| Networking | [`dio`](https://pub.dev/packages/dio) with the API server's self-signed certificate pinned by SHA-256 fingerprint. |
| Maps | [`flutter_map`](https://pub.dev/packages/flutter_map) with a Drift-backed tile cache. |
| Secrets | [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) for the session and base URL. |

### Data flow

1. On sign-in the shell pulls job orders through
   `GET /api/JobOrders/status/{status}`: every *Scheduled* job, plus the
   *Activated* jobs assigned to the technician's email for the history. Plant
   records come from the LCP/NAP endpoint. Everything is upserted into
   SQLite, and synced rows the server no longer returns are dropped.
2. Screens watch Drift streams through signals, so any local write repaints
   the UI immediately.
3. Technician edits (activation, completion report) are written locally
   with `isSynced = false`, then the sync worker replays them with
   `PUT /api/JobOrders/{id}`. On success the local row is replaced by the
   server's own copy of the record; if the server answers 404 the job was
   deleted by the office and the local row is dropped; any other failure is
   retried on the next cycle. A refresh never overwrites a row whose edit is
   still pending.

## Getting started

### Prerequisites

- Flutter 3.47 or newer on the stable channel (`flutter --version`)
- Android Studio with an SDK, or Xcode 16+ for iOS
- Android SDK licenses accepted: `flutter doctor --android-licenses`

### Run

```bash
git clone <this repository> swithfiber_tech
cd swithfiber_tech
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The generated Drift files (`*.g.dart`) are committed, so the `build_runner`
step is only needed after changing anything under `lib/core/database`.

### Configuration

There are no build-time secrets. The API base URL defaults to
`AppConstants.defaultBaseUrl` in
[`lib/core/constants/app_constants.dart`](lib/core/constants/app_constants.dart)
and can be overridden at runtime from *Settings*. The same file holds the
pinned certificate fingerprint; if the server certificate is reissued, update
`pinnedApiCertSha256` and ship a new build, otherwise every request fails.

The API contract is documented in [`API_SCHEMA.md`](API_SCHEMA.md). Treat it
as a guide rather than a guarantee: the live server differs in places (for
example, `GET /JobOrders` returns the whole unpaginated table and the login
response carries no email), and the code comments record each divergence
where it matters.

## Testing

```bash
flutter analyze --fatal-infos
dart format --set-exit-if-changed -o none lib test
flutter test
```

Tests live in [`test/`](test/) and cover the status model, the PUT payload
round-trip against the API's required-field list, Drift-to-signals data flow,
the job history filter, map clustering, and the main screens as widget tests
using an in-memory database.

## Release

See [`docs/RELEASE.md`](docs/RELEASE.md) for signing setup, the
pre-submission checklist, and the tag-driven release workflow. In short:

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/android
flutter build ipa --release --obfuscate --split-debug-info=build/symbols/ios
```

Pushing a `v*` tag runs [`release.yml`](.github/workflows/release.yml), which
builds a signed App Bundle and APK and attaches them to a GitHub Release.

## Project conventions

- A job has exactly two field stages, *Scheduled* and *Activated*. The
  office's `Applied` / `Confirmed` count as Scheduled; anything else the
  backend sends is shown verbatim. Activation stamps the technician's email
  and is final: activated jobs are view-only in the history.
- `onsiteStatus` values *Failed* and *Reschedule* are surfaced as an extra
  badge so problem visits stay visible.
- Job orders never send a partial update: the original record is replayed
  with only the technician's edits applied.
- Photos and the signature are stored in the job order's string fields as
  base64 data URLs, the same format the web console writes, compressed to
  1600 px at 80 % quality on the phone. There is no separate upload endpoint.
- Sensitive profile fields returned by the API are deliberately not modelled
  and never reach storage.

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md).

## License

Proprietary. Copyright © Switch Fiber. All rights reserved.
