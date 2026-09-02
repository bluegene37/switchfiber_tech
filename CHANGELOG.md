# Changelog

All notable changes to Switch Fiber Tech are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.0.0] - 2026-09-02

First production release for Switch Fiber field technicians.

### Added
- Technician sign-in against the Switch Fiber API with a persisted session.
- Scheduled work-order queue with search and one-tap "Grab Job" dispatch.
- My Job History: every job order assigned to the signed-in technician's email,
  with status filters, search, and summary counts.
- Work-order detail screen: workflow stepper, subscriber and location details,
  plant and hardware allocation, optical power reading, on-site records, and
  external navigation to Google Maps, Waze, or Apple Maps.
- On-site completion report with optical power gauge, ONT details, and
  photo/signature fields.
- LCP/NAP plant records with a clustered map view, satellite layer, cabinet
  grouping, filters, and offline tile cache.
- Technician toolkit: optical budget calculator, drop cable estimator, fiber
  color code reference, network diagnostic pings, and a field troubleshooting
  guide.
- Offline-first storage in SQLite (Drift) with a background sync queue for
  edits made without a connection.
- Certificate-pinned HTTPS client, configurable API base URL, dark mode.

### Security
- The API server's self-signed certificate is pinned by SHA-256 fingerprint.
- Session data is stored in the platform keychain / keystore; sensitive profile
  fields returned by the API are never persisted.
