# Switch Fiber Field UI Standard

**Status:** approved for implementation, 3 September 2026
**Scope:** the Flutter mobile app in this repository (iOS and Android). The desktop Flutter app and the Vue web console are separate repositories and out of scope.
**Published reference:** https://claude.ai/code/artifact/c7bab062-d843-4e35-a217-05434fe148b9

## Why

Field technicians read the app at arm's length, in daylight, often one-handed and sometimes with wet or gloved hands, while looking at a pole or a modem. The app as audited on 2026-09-03 works against that:

| Finding | Measured |
|---|---|
| Hardcoded `fontSize:` literals; the theme defines **no `textTheme`** | 383 |
| Of those at 9 to 13 px | 253 (66 %) |
| Widgets that read type from `Theme.of(context).textTheme` | 2 |
| Secondary grey `#8E8E93` on white | 3.26:1 (fails body 4.5:1) |
| Secondary grey `#8E8E93` on page background `#F2F2F7` | 2.92:1 (fails even large-text 3:1) |
| Tertiary grey `#C7C7CC` on white | 1.68:1 |
| Every semantic colour used *as text* on white | fails 4.5:1 (success 2.22, warning 2.20, danger 3.55, info 4.02, brand 3.76) |
| Buttons using `VisualDensity.compact` | 17 |
| Search fields overriding the theme with `isDense: true` and `contentPadding: EdgeInsets.zero` | 5 |
| Fixed 40 × 40 dp interactive containers | 3 |
| Icons at 16 px or smaller | 112 |
| Literal `Color(0x…)` outside `AppTheme` | 254 |
| Button themes set padding but **no `minimumSize`** | height lands ~43–46 dp |

Contrast ratios were computed with the WCAG 2.1 relative-luminance formula from the app's own tokens. Dark-mode secondary text already passes (5.22:1); the problem is light mode, which is the mode used outdoors.

## Type scale

The system font stays. It is free, follows the phone's text-size setting, and a custom face would cost weight and Dynamic Type for nothing a technician needs.

| Role | Material 3 slot | Size / weight | Line height | Use |
|---|---|---|---|---|
| Screen title | `titleLarge` | 22 / 700 | 1.2 | AppBar titles |
| Section heading | `titleMedium` | 17 / 700 | 1.25 | Card headers |
| Body strong | `titleSmall` | 16 / 600 | 1.4 | Names, key values |
| Body | `bodyMedium` (the default `Text` style) | 16 / 400 | 1.5 | All reading text |
| Body (unchanged M3 default) | `bodyLarge` | 16 / 400 | 1.5 | Same as body |
| Label | `labelLarge` | 14 / 600 | 1.2 | Buttons, chips, field labels |
| Label small | `labelMedium` | 13 / 600 | 1.2 | Small chips, badges |
| Caption | `bodySmall` | 13 / 500 | 1.35 | Metadata only, in **secondary ink** |
| Caption label | `labelSmall` | 13 / 500 | 1.2 | Tiny uppercase eyebrows |
| Data | `headlineSmall` | 20 / 700, monospace, tabular figures | 1.15 | dBm readings, counts, port numbers |

**Rules**

1. Nothing below 13 px. 13 px is for metadata a technician never has to act on.
2. The one exception is **map furniture** (pin labels in a fixed-size `Marker`), which stays at 9 px with `TextScaler.noScaling` because the box cannot grow. This exception already exists in code.
3. No new `fontSize:` literals in widgets. Type comes from the theme roles above. After the sweep, fewer than 20 literals may remain in `lib/`, all of them map furniture or the theme file itself.
4. Everything must survive the phone's text size at **200 %** without clipping. Fixed-height containers holding text are the usual failure.

## Touch targets and controls

| Control | Minimum |
|---|---|
| Any tappable widget | **48 × 48 dp** (`minimumSize` + `materialTapTargetSize: padded` in the theme) |
| Primary action on a screen (activate, save report, navigate) | 52–56 dp tall, full width |
| List rows | 56 dp |
| Search fields | **52 dp tall**, 16 px text, 14 px horizontal padding, 48 dp clear button, 22 px search icon |
| Icon glyphs | 20 px minimum; 24 px inside buttons |
| `VisualDensity.compact` | **removed everywhere** (17 sites). Compact density is for desktop mice, not thumbs. |

The theme's `inputDecorationTheme` already has sensible padding; the five search fields defeat it with `isDense: true` and `contentPadding: EdgeInsets.zero`. The fix is to delete those overrides, not to add anything. The map search bar added on 2026-09-03 is 44 dp; raise it to 52.

## Colour: keep the palette, fix the text

Brand and semantic colours stay for fills, badges, icons and borders. Bright colours are **never used as text**. Every colour gets an *ink* variant for text that passes 4.5:1 on both light surfaces (white card and `#F2F2F7` page) and both dark surfaces (`#1C1C1E` card and `#000000` page).

| Token | Fill / icon (existing) | Light ink (new) | Dark ink (new) |
|---|---|---|---|
| Secondary text | `#8E8E93` (hints only) | `#5A5A60` | `#AEAEB2` |
| Brand | `#E74C5A` | `#C02E3C` (exists as `primaryActive`) | `#FF8A94` |
| Success | `#34C759` | `#1B7F3B` | `#5CD27A` |
| Warning | `#FF9500` | `#8A5200` | `#FFB340` |
| Danger | `#FF3B30` | `#C1291F` | `#FF6B62` |
| Info | `#007AFF` | `#0062CC` | `#5AA9FF` |

Every ink value is enforced by a unit test that computes its WCAG ratio; a value that fails does not land. Never encode meaning in colour alone: a status pill always carries a word.

## Layout habits

- One primary action per screen, full width, at the bottom, clear of the phone's navigation bar. Secondary actions are outlined.
- State is a pill with text **and** colour, at label size or larger.
- Readings a technician acts on use the Data role.
- Cards separate genuinely separate things; no card inside a card.
- Every icon-only button has a `tooltip` (which is also its screen-reader label).

## Rollout order

1. Define the scale, minimum sizes, input padding and ink tokens in `AppTheme`. One file; theme-reading widgets pick it up immediately.
2. Remove the overrides that fight the theme: 17 compact densities, 5 search-field overrides, 3 fixed 40 dp buttons, the 44 dp map search bar.
3. Sweep the 383 `fontSize` literals to theme roles, one feature at a time, measuring with the audit command until fewer than 20 remain.
4. Sweep the 254 literal colours to tokens, routing text through ink tokens.
5. Verify every screen at 200 % text size on a real phone. Anything that clips is a fixed-height container holding text.

## Deliberately not in scope

- A custom typeface.
- A visual redesign. The iOS-flavoured look and palette stay.
- The desktop Flutter app (other repository; the 48 dp rule does not carry over).
- The Vue web console.

## Audit command

Run this before and after each sweep task; the numbers are the acceptance test.

```bash
grep -rhoE "fontSize:\s*[0-9.]+" lib | grep -oE "[0-9.]+" | sort -n | uniq -c
grep -rn "VisualDensity.compact" lib | wc -l
grep -rn "isDense: true" lib | wc -l
grep -rn "Color(0x" lib | grep -v core/theme | wc -l
```
