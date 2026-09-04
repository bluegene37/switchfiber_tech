# Design System — Switch Fiber Tech

## Product Context
- **What this is:** Offline-first mobile operations application for fiber installation technicians and repair crews.
- **Who it's for:** Field technicians, linemen, and fiber splicing specialists operating outdoors on poles, ladders, and in basements.
- **Space/industry:** Telecommunications / FTTH (Fiber-to-the-Home) last-mile network operations.
- **Project type:** Flutter mobile utility app (iOS & Android).
- **Core constraint:** High-glanceability under harsh daylight, single-handed gloved touch interaction, and resilient offline SQLite persistence in network dead zones.

---

## Aesthetic Direction
- **Direction:** **The Rugged Field Instrument** (Fluke / EXFO precision testing tool aesthetic with Apple Human Interface Guidelines ergonomics).
- **Decoration level:** Minimal — no ornamental blobs, decorative background gradients, or heavy drop shadows. Surfaces communicate hierarchy through lightness contrast (`#F2F2F7` vs `#FFFFFF` in light mode; `#000000` vs `#1C1C1E` in dark mode) and 0.5px hairline dividers (`#E5E5EA` / `#38383A`).
- **Mood:** Indestructible, precise, highly legible, calm, and respectful of the technician's time and battery. Feels like precision hardware converted to glass.

---

## Typography
System-native typography delivers zero runtime overhead, instant cold start, and full OS Dynamic Type scaling. Monospace accents elevate technical telemetry into an instrument HUD.

- **Display / App Titles:** System Font (SF Pro / Roboto) — Bold (700).
- **Body & Labels:** System Font (SF Pro / Roboto) — Regular (400) / SemiBold (600).
- **Data & Telemetry:** `JetBrains Mono` / System Monospace (SF Mono / Roboto Mono) — Bold (700) with tabular figures for optical dBm readouts, port labels, and serial numbers.
- **Scale (Material 3 Slots):**

| Role | M3 Slot | Size / Weight | Line Height | Usage |
|---|---|---|---|---|
| Screen Title | `titleLarge` | 22 / 700 | 1.2 | Top AppBar headers |
| Section Header | `titleMedium` | 17 / 700 | 1.25 | Operational card headers |
| Body Strong | `titleSmall` | 16 / 600 | 1.4 | Customer names, key field labels |
| Body Reading | `bodyMedium` | 16 / 400 | 1.5 | Addresses, notes, form reading text |
| Action CTA | `labelLarge` | 14 / 600 | 1.2 | Buttons, full-width action bars |
| Status Badge | `labelMedium` | 13 / 600 | 1.2 | Status pills, filter chips |
| Metadata Floor | `bodySmall` | 13 / 500 | 1.35 | Timestamps, secondary subtitles (in secondary ink) |
| Instrument Data | `headlineSmall` | 20 / 700 (mono) | 1.15 | Optical power (-19.5 dBm), ports, ticket tags |

- **Strict Rules:**
  1. **13px Minimum Floor:** Nothing below 13px in UI components. Only fixed map pin labels (map furniture) may drop to 9px with `TextScaler.noScaling`.
  2. **200% Text Scale Resilience:** Every layout must survive 200% system font scaling without text clipping or RenderFlex overflow (use `Wrap` and flexible scrollable rows).
  3. No raw `fontSize:` literals in component code — all type routes through `Theme.of(context).textTheme`.

---

## Color & Outdoor Contrast System
Bright colors are strictly reserved for fills, badges, and icons. **Text is never rendered with unadjusted bright tokens.** Text routes through calibrated ink tokens that mathematically pass WCAG 2.1 AA (≥4.5:1) on both card and page surfaces in both themes.

### Light Mode (Outdoor Daylight Target)
- **Page Background:** `#F2F2F7` (iOS System Grouped Background)
- **Card Surface:** `#FFFFFF` (Pure White)
- **Brand Primary:** `#E74C5A` (Warm Rose Red fill)
- **Hairline Border:** `#E5E5EA` (0.5px border)

#### Light Mode Semantic Inks (WCAG Text Tested)
- **Primary Text:** `#1C1C1E` (15.8:1 on white, 14.2:1 on page)
- **Secondary Ink:** `#5A5A60` (6.85:1 on white, 6.14:1 on page) — `AppTheme.secondaryInkOf(context)`
- **Brand Ink:** `#C02E3C` (5.68:1 on white) — `AppTheme.brandInkOf(context)`
- **Success Ink:** `#1B7F3B` (5.07:1 on white, 4.54:1 on page) — `AppTheme.successInkOf(context)`
- **Warning Ink:** `#8A5200` (6.39:1 on white, 5.73:1 on page) — `AppTheme.warningInkOf(context)`
- **Danger Ink:** `#C1291F` (5.83:1 on white, 5.22:1 on page) — `AppTheme.dangerInkOf(context)`
- **Info Ink:** `#0062CC` (5.80:1 on white, 5.20:1 on page) — `AppTheme.infoInkOf(context)`

### Dark Mode (OLED Field & Low-Glare Target)
- **Page Background:** `#000000` (Pitch Black OLED battery-saver)
- **Card Surface:** `#1C1C1E` (Dark Grouped Surface)
- **Input Fill:** `#2C2C2E`
- **Hairline Border:** `#38383A` (0.5px border)

#### Dark Mode Semantic Inks
- **Primary Text:** `#FFFFFF` (15.5:1 on card)
- **Secondary Ink Dark:** `#AEAEB2` (7.69:1 on card, 9.50:1 on page)
- **Brand Ink Dark:** `#FF8A94` (7.55:1 on card)
- **Success Ink Dark:** `#5CD27A` (8.88:1 on card)
- **Warning Ink Dark:** `#FFB340` (9.54:1 on card)
- **Danger Ink Dark:** `#FF6B62` (6.10:1 on card)
- **Info Ink Dark:** `#5AA9FF` (6.93:1 on card)

---

## Controls & Touch Targets
Designed for one-handed operation while holding tools or balancing on poles.

- **Minimum Touch Target:** **48 × 48 dp** enforced globally via `minimumSize` and `MaterialTapTargetSize.padded`.
- **Primary Bottom Action CTA:** **52–56 dp height**, full width, bottom-anchored, with dynamic single-action workflow progression:
  - When completion report is pending: `"Fill Completion Report"`
  - When completion report is filed: `"Mark as Completed"`
- **List Rows:** 56 dp minimum height (`minTileHeight: 56`).
- **Search Inputs:** 52 dp height with integrated 48dp clear button (`AppSearchField`).
- **Icon Buttons:** 20px minimum glyph; always carries a `tooltip` for screen-reader accessibility.
- **Mouse Density:** `VisualDensity.compact` is strictly prohibited everywhere.

---

## Layout & Hierarchy
- **Card Disciplined:** Cards group distinct operational domains (Workflow, Site Exception, Customer/Location, Plant/Hardware, RADIUS Diagnostics, Optical Telemetry, On-Site Proofs).
- **No Nested Cards:** Never nest a Card inside another Card.
- **Top-to-Bottom Flow:** Essential status and immediate action anchor at the top; customer contacts and navigation buttons follow; technical hardware and diagnostics follow below.
- **Adaptive Tablet View:** On viewports with width ≥ 768dp (service van dashboard mounts), the screen automatically branches into a master-detail split view (queue on left, details on right).

---

## Motion & Transitions
- **Approach:** Minimal-Functional.
- **Transitions:** Native iOS Cupertino sliding page push (`CupertinoPageRoute`). Instant tab switches.
- **Feedback:** Activity indicators use native `CupertinoActivityIndicator`. Interactive completion actions provide tactile feedback and floating confirmation SnackBars.

---

## Decisions Log
| Date | Decision | Rationale |
|---|---|---|
| 2026-09-04 | Initial Design System Formalized | Created via `/design-consultation` based on Field UI Standard, 278 passing tests, and outdoor technician usability. |
| 2026-09-04 | Adopted "The Rugged Field Instrument" | Infused Fluke/EXFO precision instrument HUD, monospace telemetry, and segmented LED optical power meters. |
| 2026-09-04 | Dynamic Primary Action Progression | Replaced disabled static buttons with single-action forward flow (`"Fill Completion Report"` → `"Mark as Completed"`). |
| 2026-09-04 | Tablet Master-Detail Two-Pane Layout | Added adaptive two-pane layout for screens ≥ 768dp to optimize service van tablet mounts. |
