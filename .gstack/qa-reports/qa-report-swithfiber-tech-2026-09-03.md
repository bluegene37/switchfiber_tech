# QA Report — swithfiber_tech

- Branch: `feature/toolkit-lcp-nap`
- Date: 2026-09-03
- Tier: Standard
- Surface: Flutter mobile app. No `web/` target exists, so there is no browser
  surface to drive. The QA baseline is `flutter analyze` plus the widget/unit
  suite, with the failing screen root-caused through an instrumented probe.

## Health score

| | Baseline | Final |
|---|---|---|
| `flutter analyze` | 0 issues | 0 issues |
| `flutter test` | 156 passed, 1 failed | 158 passed, 0 failed |
| Score | 7/10 | 9/10 |

## ISSUE-001 — `pumpAndSettle` can never settle on the job detail screen (High)

**Symptom.** `test/widget_test.dart` → "JobOrderDetailScreen renders properly
in light and dark mode without RenderFlex crashes" failed with
`pumpAndSettle timed out` at the dark-theme pump.

**Root cause.** Instrumenting the test showed `transientCallbackCount` going to
1 and staying there the moment `scrollUntilVisible` reached the plant section.
That scroll mounts `RadiusConnectionCard`
(`lib/features/diagnostics/widgets/radius_connection_card.dart:22`), which
fires a live RADIUS lookup in `initState` and renders a
`CupertinoActivityIndicator` while it is in flight. An indeterminate indicator
schedules a frame forever, so the tree is never quiet. The light-theme
`pumpAndSettle` only passes because it runs before the card is scrolled into
the viewport.

**Fix.** `test/widget_test.dart` — the dark-theme pump is now a bounded
`pump()` + `pump(400ms)` for the theme transition, with a comment explaining
why settling is impossible on this screen.

**Status:** verified. Files: `test/widget_test.dart`.

## ISSUE-002 — a GPS fix on every rebuild of the job detail screen (High)

**Symptom.** Found while tracing ISSUE-001.
`lib/features/jobs/screens/job_order_detail_screen.dart` built its
"Distance from You" row as `FutureBuilder(future:
LocationService.instance.getCurrentPosition(), ...)` with the future created
inside `build`. Every rebuild of the screen started a fresh 4-second
high-accuracy GPS fix. The screen is wrapped in a signals `Watch`, so it
rebuilds on any job change. Battery cost in the field, and the row can flicker
between fixes.

**Fix.** The row moved into a small `_DistanceFromTechnicianRow` StatefulWidget
that requests the position once in its state. It is only built when the job
actually carries coordinates, so a job without a fix no longer asks the device
for one at all. `_buildSpecRow` became `static` so the new widget can reuse it.
`LocationService.instance` is no longer `final`, so tests can install a
stand-in.

**Evidence.** New test `test/job_detail_distance_test.dart` counts GPS
requests across four renders of the screen. Against the fixed code: 1 request.
Against the pre-fix code, re-applied to check the test bites: 7 requests.

**Status:** verified. Files:
`lib/features/jobs/screens/job_order_detail_screen.dart`,
`lib/core/services/location_service.dart`,
`test/job_detail_distance_test.dart`.

## Deferred

**D-1 — the widget suite calls the production API (High, not fixed).**
`RadiusConnectionCard` reaches `RadiusUserService.instance` directly from
`initState`, so every `flutter test` run issues real HTTPS requests to
`103.249.198.43:8090`. That is slow, flaky offline, and points test traffic at
production. Fixing it means an injection point on the card and a way to thread
it through `JobOrderDetailScreen`, which changes the constructor surface — your
call on the shape.

**D-2 — a failed single lookup downloads the whole RADIUS table (Medium, not
fixed).** `RadiusUserService.fetchRadiusUserByName`
(`lib/features/diagnostics/services/radius_user_service.dart:34`) wraps the
`GET /RadiusUser/{name}` call in a bare `catch (_)` and then falls through to
`fetchRadiusUsers()`. A timeout on a weak field connection is indistinguishable
from a 404, so the app answers a one-record miss by pulling every RADIUS
account. Narrow the fallback to an actual not-found response.

**D-3 — `AppDatabase` opened twice in one test (Low, not fixed).**
`test/widget_test.dart` triggers drift's "created the database class
AppDatabase multiple times" warning. Noise today; a corruption risk if those
tests ever share an executor.

## PR summary

QA found 3 issues, fixed 2, health score 7 → 9. 158 tests pass, analyzer clean.
