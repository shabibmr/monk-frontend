# Token Migration — current → target

Companion to [`IMPLEMENTATION_PLAN.md`](./IMPLEMENTATION_PLAN.md) Phase 1.
Current values read from `apps/monk/lib/core/theme/tokens.dart`.
Target values are authoritative in [`mockups/css/tokens.css`](./mockups/css/tokens.css).

**Token *names* are preserved wherever possible** so call sites don't restructure — only
values change. The exceptions are called out in §5 and they are breaking.

---

## 1. `ImColors`

### 1.1 Replaced in place — no call-site changes

| Token | Current | Target | Note |
|---|---|---|---|
| `ink900` | `#1D2B32` | `#1A1A2E` | Cooler, more violet-leaning |
| `ink600` | `#5A6B72` | `#5B6473` | **a11y-corrected** — see §4 |
| `ink300` | `#B9C2C6` | `#D1D5DB` | Lighter; hairlines only, never text |
| `white` | `#FFFFFF` | `#FFFFFF` | unchanged |
| `success600` | `#2E7D5B` | `#15803D` | **a11y-corrected** |
| `success100` | `#DBEEE5` | `#DCFCE7` | |
| `warning600` | `#B97A1B` | `#B45309` | **a11y-corrected** |
| `warning100` | `#F7E9D2` | `#FEF3C7` | |
| `danger600` | `#C24E3A` | `#DC2626` | 4.85:1, passes as-is |
| `danger100` | `#F6DEDA` | `#FEE2E2` | |
| `info600` | `#3A6EA5` | `#2563EB` | |
| `info100` | `#DEE9F4` | `#DBEAFE` | |

### 1.2 Retired — every reference must be rewritten

| Retired | Replacement | Where it's referenced today |
|---|---|---|
| `coral500` | `secondary600` `#EC4899` | `app_theme.dart` (influencer primaryPressed, admin sidebarActive, `colorScheme.secondary`) |
| `coral600` | `secondary600` | `app_theme.dart` influencer primary |
| `coral100` | `secondary100` `#FCE4F1`, **except** `ManagerContextBar` → `warning100` | `im_bubble_card.dart` creator side; `portal_shell.dart` manager bar |
| `teal700` | `primary600` `#6D3FF0` | `app_theme.dart` brand primary, admin primaryPressed |
| `teal800` | `admin600` `#4C1D95` | `app_theme.dart` admin primary + sidebarBg |
| `teal100` | `primary100` `#EDE7FD` | `im_bubble_card.dart` brand side |
| `cream50` | `surface` `#F7F7FB` | `app_theme.dart` `scaffoldBackgroundColor`, `appBarTheme` |
| `cream100` | `surfaceSubtle` `#FAFAFD` | `app_theme.dart` sidebarBg; `status_colors.dart` `StatusSemantic.ink` |

`ManagerContextBar` is the one place `coral100` must **not** become `secondary100`. It is an
"acting as someone else" warning state, so it takes `warning100`/`warning600` (spec §5.5).
It is golden-tested.

### 1.3 New

`primary500`, `primary100`, `secondary600`, `secondary100`, `admin600`, `surface`,
`surfaceCard`, `surfaceSubtle`, the five `accent*100`/`accent*600` stat-chip pairs,
`accentOrange500`, and `tagHot*`/`tagNew*`.

`accentOrange500` `#FB923C` is **decorative only** — 2.26:1 against white. It is a gradient
stop and nothing else. No text, no icon that carries meaning, ever.

### 1.4 Gradients (all new)

`gradientHero`, `gradientWarm`, `gradientCream`, `gradientDark`, `gradientPage`.

> **`gradientWarm` changed after the spec was written.** `design_context.md` §1 defines it as
> `secondary600 → accentOrange500` carrying white text. That failed on sight in the browser —
> and the source screenshots show a *pale wash carrying dark ink*. Target is the three-stop
> pale version in `tokens.css` with `ink900` text. Fix the spec before Phase 1.

## 2. `ImRadii`

| Token | Current | Target |
|---|---|---|
| `radiusSm` | 8 | **8** |
| `radiusMd` | 12 | **16** |
| `radiusLg` | 20 | **24** |
| `radiusXl` | — | **32** (new — floating shell only) |
| `radiusFull` | 999 | **999** |

`radiusMd` 12→16 changes buttons, inputs, and small cards everywhere at once. Note that
`app_theme.dart` currently builds `inputDecorationTheme` with `radiusSm`, not `radiusMd` —
switching it to `radiusMd` is a separate, deliberate change on top of the token bump.

## 3. `ImSpacing`

**Unchanged.** `4 / 8 / 12 / 16 / 24 / 32 / 48 / 64`.

## 4. Accessibility-corrected values

Four tokens are deliberately darker than the reference screenshots. Ratios measured against
the surface named:

| Token | Screenshot | Ratio | Target | Ratio |
|---|---|---|---|---|
| `ink600` on `surface` | `#6B7280` | **4.48:1** ✗ | `#5B6473` | ~5.5:1 ✓ |
| `success600` on white | `#16A34A` | **3.30:1** ✗ | `#15803D` | 5.02:1 ✓ |
| `warning600` on white | `#D97706` | **3.19:1** ✗ | `#B45309` | 5.05:1 ✓ |
| `warning600` on `warning100` | `#D97706` | ✗ | `#B45309` | 4.54:1 ✓ |
| `accentMint600` | `#059669` | ✗ | `#047857` | ✓ |
| `accentAmber600` | `#D97706` | ✗ | `#B45309` | ✓ |
| white on `accentOrange500` | — | **2.26:1** ✗ | *no text permitted* | — |

`ink600` fails by two hundredths, which is exactly why it needs to be written down — nobody
catches that by eye, and "it matches the mockup" is a persuasive-sounding reason to revert it.

## 5. `ImLayout` and `PortalThemeExtension` — breaking

### 5.1 `ImLayout`

| Token | Current | Target |
|---|---|---|
| `contentMaxWidth` | 1200 | **1440** |
| `sidebarWidth` | 264 | **removed** |
| `railWidth` | — | **360** (new — content rail, not nav) |
| `navHeight` | — | **72** (new) |
| `navHeightCompact` | — | **64** (new) |
| `shellInset` | — | **24** (new — floating shell) |
| `touchTarget` | 44 | **44** |
| `compactBreakpoint` | 600 | **600** |
| `mediumBreakpoint` | 1024 | **1024** |

`sidebarWidth` is referenced by `portal_shell.dart`, which isn't rewritten until Phase 3.
Either keep it as a deprecated alias across Phases 1–2 or land Phase 1 and 3 together.

### 5.2 `PortalThemeExtension`

| Current field | Target |
|---|---|
| `sidebarBg` | `navBg` |
| `sidebarFg` | `navFg` |
| `sidebarActive` | `navActive` |
| — | `shellStyle` (new — `flat` \| `floating`) |

Breaking rename with call sites to sweep, all in `portal_shell.dart`. Phase 3.

### 5.3 Per-portal primaries

| Portal | Current | Target |
|---|---|---|
| Brand | `teal700` | `primary600` `#6D3FF0` |
| Influencer | `coral600` | `secondary600` `#EC4899` |
| Admin | `teal800` | `admin600` `#4C1D95` |
| Manager | *(inherits influencer)* | inherits influencer; no mockup covers it |

## 6. `ImShadows`

Current: a single `float` — `ink900 @ 10%`, blur 16, offset (0,4).

Target — **hairline first, whisper-shadow second** (spec §4). The hairline delineates; the
shadow only lifts the card off the tinted surface.

| Token | Value |
|---|---|
| `card` | `ink900 @ 4%`, blur 12, offset (0,2) **+ 1px `ink300 @ 50%` hairline** |
| `float` | `ink900 @ 8%`, blur 24, offset (0,8) |
| `nav` | `ink900 @ 4%`, blur 16, offset (0,-2) — mobile bar top edge only |

Gradient cards carry **no** hairline.

The spec's earlier draft proposed blur 24 / offset 8 at 6% and said borders were dropped
entirely. Both overshoot — the mockup cards are flatter, and the campaign form's inputs and
option cards visibly carry hairlines.

## 7. `ImDurations`

Current: `hover: 150ms`, `panel: 250ms`, `easeOutCubic`. All three keep their values; the
migration is that they're now actually *assigned* to interactions (spec §6) instead of
declared and unused.

New: `press: 100ms`, `progress: 400ms`, `shimmer: 1200ms`.

Honour `MediaQuery.disableAnimations` — everything to zero except the skeleton, which holds a
static mid-tone rather than looping.

## 8. Typography

| Style | Current | Target |
|---|---|---|
| `displayLarge` | Baloo2 32/700 | **Outfit** 32/700 |
| `headlineMedium` | Baloo2 24/600 | **Outfit** 24/600 |
| `kpiNumber` | Baloo2 40/700 tabular | **Outfit** 40/700 tabular |
| `kpiNumberLarge` | — | **Outfit** 56/700 tabular (new) |
| `heroGreeting` | — | **Caveat** 40/700 (new) |
| `titleMedium` … `bodySmall` | Inter | Inter — unchanged |

Baloo2 is retired. Caveat has exactly one permitted usage site: the hero greeting, at most
once per screen. Never in chrome, buttons, labels, body, or empty states (spec §2).

Both faces are in `google_fonts`, so this is values-only in `typography.dart` — but it takes
the runtime fetch from one family to three.
