# Design Context — Monk Visual Redesign

**Status:** adopted spec. Supersedes the deleted `docs/frontend/design.md`.
**Source:** four reference screenshots in `docs/design_samples/` — `brands_home_page.png`,
`campaign_create_form.png`, `creator_home_page.png`, `creator_home_page_mobile.png`.
**Target:** `apps/monk` only (see §0.2).

This document translates the reference screenshots' visual language into token and component
terms this codebase understands, so it can drive an implementation pass over:

- `apps/monk/lib/core/theme/tokens.dart` (`ImColors`, `ImSpacing`, `ImRadii`, `ImDurations`, `ImLayout`, `ImShadows`)
- `apps/monk/lib/core/theme/typography.dart` (`ImTypography`)
- `apps/monk/lib/core/theme/app_theme.dart` (`AppTheme`, `PortalThemeExtension`)
- `apps/monk/lib/core/theme/status_colors.dart`
- `apps/monk/lib/core/widgets/` (`im_*.dart` component library)
- `apps/monk/lib/core/router/shells/portal_shell.dart` (navigation architecture — see §5.1)

---

## 0. Ground rules

### 0.1 What is and isn't being adopted

The screenshots depict a third-party product called "Collabify". **Only the visual system is
being adopted** — palette, type, spacing, elevation, component anatomy, layout rhythm.

Explicitly **not** adopted: the "Collabify" name and wordmark, its logo mark, and its
copy. Monk branding stays; `apps/monk/lib/core/widgets/monk_logo.dart` and
`assets/monk_logo.png` are unchanged by this work.

The 3D illustrations, character mascot, and product photography in the mockups are
stock or AI-generated placeholders. They are **not** licensed for our use. Every
illustration slot in this document is a *slot* — the assets behind it need their own
sourcing decision, which is out of scope here and tracked in §12.

### 0.2 Scope decisions

| Decision | Ruling |
|---|---|
| **Target app** | `apps/monk` only. `apps/web` stays on the current coral/teal theme. |
| **Palette** | Full replacement. Token *names* and structure are preserved so call sites don't restructure — only values change. |
| **Display face** | **Outfit**, replacing Baloo2. |
| **Script face** | **Caveat**, newly added, hero greetings only. |
| **App shell** | Per-portal: brand + admin edge-to-edge, creator floating canvas (§5.2). |
| **Dark mode** | **Out of scope.** All four mockups are light-only and `app_theme.dart` hardcodes `Brightness.light`. Not designed for; do not partially implement. |

On `apps/web`: it holds near-duplicate theme and widget files that have **already drifted**
from `apps/monk` — `im_empty_state.dart` exists only in monk, `im_platform_icon.dart` only
in web. Targeting monk alone widens an existing gap rather than creating a new one, but it
does widen it. Resolving the duplication is a separate piece of work (§12).

### 0.3 Cost this document commits you to

Two items that are easy to miss when reading the sections below:

1. **Navigation architecture changes.** The app is a sidebar shell today; the mockups have
   no sidebar. This is a rewrite of `portal_shell.dart`, not a restyle. See §5.1 — and note
   the unresolved IA conflict flagged there, which needs a product answer.
2. **All golden tests break.** `test/goldens/` holds 11 reference PNGs across
   `im_widgets_golden_test.dart`, `im_stepper_golden_test.dart`, and
   `manager_context_bar_golden_test.dart`, covering button/card/status-chip in all three
   portal themes. Every one is invalidated by the palette change and must be regenerated
   and **visually reviewed** — not blind-regenerated, or the goldens stop being a safety net.

---

## 1. Color tokens

| Token (mirrors `ImColors` naming) | Hex | Usage |
|---|---|---|
| `primary600` | `#6D3FF0` | Primary buttons, active nav pill, links, focus ring, primary icons |
| `primary500` | `#8A63F5` | Hover/lighter primary, gradient start |
| `primary100` | `#EDE7FD` | Selected/tinted backgrounds — active nav pill fill, selected goal card |
| `secondary600` | `#EC4899` | Secondary accent — gradient end, "Top Creator" badge, notification dot |
| `secondary100` | `#FCE4F1` | Tinted secondary backgrounds |
| `accentOrange500` | `#FB923C` | Warm gradient end (Brand Score, Pro Tip) — **decorative only, never behind text** (§9) |
| `accentAmber100` / `600` | `#FEF3C7` / `#B45309` | Amber stat chip (Total Spend) |
| `accentMint100` / `600` | `#D1FAE5` / `#047857` | Mint stat chip (Engagement Rate) |
| `accentBlue100` / `600` | `#DBEAFE` / `#2563EB` | Blue stat chip (Total Reach) |
| `accentPink100` / `600` | `#FCE7F3` / `#DB2777` | Pink stat chip (Creators Collaborating) |
| `accentLavender100` / `600` | `#EDE9FE` / `#7C3AED` | Lavender stat chip (Active Campaigns) |
| `surface` | `#F7F7FB` | App background — very light lavender-tinted off-white |
| `surfaceCard` | `#FFFFFF` | Card/panel background |
| `surfaceSubtle` | `#FAFAFD` | Nested/inset panels inside a card (mobile stat tiles, task rows) |
| `ink900` | `#1A1A2E` | Headings, primary text |
| `ink600` | `#5B6473` | Body/secondary text, labels, chart axis labels |
| `ink300` | `#D1D5DB` | Hairline borders, dividers, disabled states — **never text** |
| `success600` / `success100` | `#15803D` / `#DCFCE7` | Positive trend %, "Live" badge |
| `warning600` / `warning100` | `#B45309` / `#FEF3C7` | "In Progress" badge |
| `danger600` / `danger100` | `#DC2626` / `#FEE2E2` | Negative trend %, error states |
| `info600` / `info100` | `#2563EB` / `#DBEAFE` | Informational badges |
| `tagHot100` / `600` | `#FEF3C7` / `#B45309` | "Hot" marketing tag (§7.2) |
| `tagNew100` / `600` | `#EDE9FE` / `#7C3AED` | "New" marketing tag (§7.2) |

Four of these values are **deliberately darker than the screenshots** — `ink600`,
`success600`, `warning600`, and the amber/mint `600`s. The mockup values fail WCAG AA.
See §9 for the measurements and the reasoning; do not "correct" them back toward the
screenshots.

**Gradient pairs.** Used sparingly — see the budget in §8.

- `gradientHero`: `primary500 → secondary600`, 135° — creator mobile hero card, avatar ring
- `gradientWarm`: `secondary100 → accentOrange500`, 135° — Brand Score card, campaign-form Pro Tip
- `gradientCream`: `#FEF6E7 → #FDEEDC`, 135° — creator desktop "Pro Tip for you" card
- `gradientDark`: `#3B1E8C → #1A1A2E`, 160° — Earnings Overview panel, creator right rail
- `gradientPage`: `#F3F0FE → #FAF7FD`, 160° — page background behind the creator floating shell (§5.2)

Note that `gradientWarm` and `gradientCream` are **two distinct callout treatments**, not
one. The campaign-form Pro Tip is pink→peach; the creator-desktop Pro Tip is flat cream.
Don't collapse them.

**Per-portal primary** stays differentiated via `PortalThemeExtension`, re-anchored:

| Portal | Primary | Notes |
|---|---|---|
| Brand | `primary600` `#6D3FF0` | |
| Creator / influencer | `secondary600` `#EC4899` | |
| Admin | `#4C1D95` deep indigo | |
| **Manager** | inherits creator | Not covered by any mockup; see §5.4 |

---

## 2. Typography

Three faces, each with a hard scope boundary.

| Role | Face | Scope |
|---|---|---|
| **Display** | **Outfit** | Headlines, section titles, KPI numbers. Replaces Baloo2. |
| **Body / UI** | **Inter** | Everything else — body, labels, buttons, inputs, tables. Unchanged. |
| **Script** | **Caveat** | Hero greeting only. See the rule below. |

**On dropping Baloo2.** The previous revision of this document kept Baloo2 on the grounds
that it "already fits this brief". It does not. Baloo2 is a heavy, rounded, high-x-height
display face; the mockup headings — "Good morning, LuxeGlow!", "Create New Campaign" — are a
tight geometric grotesk. Outfit is the closer match while staying warmer and more open than
a strict grotesk, which suits the product's tone.

**The script rule — read this before using Caveat.** Caveat has exactly one permitted usage
site: the hero greeting, at most once per screen. Never in navigation, buttons, labels,
body copy, form fields, table content, or empty states. A script face used twice on a
screen stops reading as a deliberate accent and starts reading as a broken font stack. If a
screen has no hero, it has no Caveat.

| Style | Face | Size / Weight / Line-height | Usage |
|---|---|---|---|
| `heroGreeting` (new) | Caveat | 40 / 700 / 1.15 | Mobile + creator hero greeting only |
| `displayLarge` | Outfit | 32 / 700 / 1.2 | Page greeting, page title |
| `headlineMedium` | Outfit | 24 / 600 / 1.2 | Section titles ("Your Active Campaigns") |
| `titleMedium` | Inter | 16 / 600 / 1.5 | Card titles, list item primary text |
| `bodyLarge` | Inter | 16 / 400 / 1.5 | Standard body copy |
| `bodyMedium` | Inter | 14 / 400 / 1.5 | Secondary body, descriptions |
| `labelLarge` | Inter | 14 / 600 / 1.5 | Buttons, form labels, nav items |
| `bodySmall` | Inter | 12 / 400 / 1.5 | Captions, timestamps, helper text |
| `kpiNumber` | Outfit | 40 / 700 / 1.2, tabular | Dashboard stat numbers ("8.6", "4.2M") |
| `kpiNumberLarge` (new) | Outfit | 56 / 700 / 1.15, tabular | Mobile hero influence score ("8,742") |

**Tabular figures** on every number that changes in place — KPI tiles, spend/earnings
values, chart axis labels, counters. `ImTypography.kpiNumber()` already applies
`FontFeature.tabularFigures()`; extend the same treatment to `kpiNumberLarge` and to any
`ImMoneyText` usage.

**Font loading.** Both Outfit and Caveat are available through `google_fonts`, already a
dependency, so this is a values-only change in `typography.dart` with no asset bundling.
But it takes the runtime font fetch from one family to three. If first paint regresses
noticeably, bundle all three as local assets — that's the fallback, not the default.

**Currency and numerals.** The mockups use Indian grouping and lakh abbreviation
(`₹12,42,300`, `₹12.4L`, `₹2.5L – ₹4L`). This is a product formatting decision, not a
theme one, but it belongs to the same visual pass: route it through `intl` (already a
dependency) with an `en_IN` locale rather than hand-formatting at call sites, and keep
`im_money_text.dart` as the single rendering site.

---

## 3. Spacing, radii, layout

**Spacing** — current scale is sufficient, unchanged:
`4 / 8 / 12 / 16 / 24 / 32 / 48 / 64` (`ImSpacing`).

**Radii** — the mockups read rounder than the current defaults:

| Token | Current | New | Usage |
|---|---|---|---|
| `radiusSm` | 8 | **8** | Chips, small badges, inline tags |
| `radiusMd` | 12 | **16** | Buttons, inputs, small cards, icon chips |
| `radiusLg` | 20 | **24** | Hero cards, large panels |
| `radiusXl` | — | **32** (new) | Creator floating shell container (§5.2) |
| `radiusFull` | 999 | **999** | Pill buttons, nav pills, avatars, progress bars |

**Layout** (`ImLayout`):

| Token | Current | New | Notes |
|---|---|---|---|
| `contentMaxWidth` | 1200 | **1440** | Mockups compose at ~1536 and read wider than 1200 allows |
| `sidebarWidth` | 264 | *removed* | Nav is no longer a sidebar — see §5.1 |
| `railWidth` | — | **360** (new) | Right content rail |
| `navHeight` | — | **72** (new) | Desktop top nav |
| `navHeightCompact` | — | **64** (new) | Mobile bottom tab bar |
| `touchTarget` | 44 | **44** | Unchanged |
| `compactBreakpoint` | 600 | **600** | Unchanged |
| `mediumBreakpoint` | 1024 | **1024** | Unchanged |

---

## 4. Elevation

The previous revision proposed a 24px-blur / 8px-offset shadow and stated that "borders are
dropped as the primary card delineator". Both overshoot. The mockup cards read
**near-flat**, and the campaign form's inputs, goal cards, and preview panel all clearly
carry 1px hairlines.

**The rule: hairline first, whisper-shadow second.** The hairline does the delineating; the
shadow only lifts the card off the tinted `surface` background just enough to separate them.
If you can point at the shadow, it's too strong.

| Token | Value | Usage |
|---|---|---|
| `ImShadows.card` | `ink900 @ 4%, blur 12, offset (0, 2)` + 1px `ink300 @ 50%` hairline | Resting state for all cards and panels |
| `ImShadows.float` | `ink900 @ 8%, blur 24, offset (0, 8)` | Hover/raised — carousel card on hover, dropdown, popover |
| `ImShadows.nav` | `ink900 @ 4%, blur 16, offset (0, -2)` | Mobile bottom bar top edge only |

Gradient hero and callout cards carry **no** hairline — the fill separates them already.

---

## 5. Layout and navigation

### 5.1 Navigation architecture — the big one

**The app today is a 264px sidebar shell.** `portal_shell.dart` renders a `Row` with a
fixed-width `Material` sidebar (`ImLayout.sidebarWidth`) driven by
`PortalThemeExtension.sidebarBg` / `sidebarFg` / `sidebarActive`.

**None of the four mockups have a sidebar.** Desktop navigation is a ~72px top bar. This is
a rewrite of `portal_shell.dart`'s expanded branch, not a restyle, and it carries a breaking
token-contract change:

- `ImLayout.sidebarWidth` → removed; `railWidth` and `navHeight` replace it
- `PortalThemeExtension.sidebarBg` / `sidebarFg` / `sidebarActive` → renamed
  `navBg` / `navFg` / `navActive`, with call sites swept
- `_PortalChrome.darkSidebar` (admin) → re-expressed as `shellStyle` (§5.2)

The compact branch already uses an `AppBar` + `NavigationBar` bottom bar, which maps onto the
mobile mockup cleanly. Only the expanded branch is being restructured.

> **⚠ Unresolved — needs a product answer before implementation.**
> The mockup top nav carries **5 labelled items**. The real IA carries **10** for brand
> (Dashboard, Discover, Shortlists, Campaigns, Applications, Briefs, Invoices, Team, Company,
> Settings), **9** for creator, 5 for manager, 4 for admin. Ten labelled items do not fit a
> single top bar at any reasonable width.
>
> This document cannot resolve it, because it's an information-architecture question, not a
> visual one. The options are: (a) promote 5 primary items to the bar and move the rest under
> an account/overflow menu; (b) group into ~5 top-level categories with dropdowns;
> (c) keep a sidebar for brand/creator and use top nav only where the item count allows —
> which abandons the mockup's chrome for the two densest portals.
>
> **Recommendation: (a).** It matches the mockups, and the trailing items (Team, Company,
> Settings, Invoices) are settings-shaped and already belong under an account menu. But this
> is a call for whoever owns the IA, and the redesign should not start on the shell until
> it's made. Everything else in this document is unblocked by it.

### 5.2 App shell — two variants

Per the scope decision, the shell differs by portal. Add a `shellStyle` field to
`PortalThemeExtension` so the shell widget branches on the style, not on the portal enum
directly — this keeps a future portal from having to be added in two places.

**`ShellStyle.flat`** — brand and admin. Full-bleed 72px top nav on `surfaceCard`, content
on flat `surface` below, no outer margin, no shell radius.

**`ShellStyle.floating`** — creator. The entire app sits in a `radiusXl` (32px)
`surfaceCard` container, inset 24px on all sides, over a `gradientPage` background. Nav sits
*inside* the container. Costs ~48px of viewport width and height, which is the price of the
look.

Below `compactBreakpoint`, **both** styles collapse to flat — the floating inset is a
desktop-only treatment.

### 5.3 Desktop dashboard grid

```
┌─────────────────────────────────────────────────────────────────────┐
│ [Logo]  Home  Campaigns  Creators  Analytics  Reports   🔍 🔔 💬 [Avatar ▾] │
├───────────────────────────────────────────────────┬─────────────────┤
│ Greeting hero (headline + subtext + 2 CTAs) [illus]│ Quick Actions   │
│                                  [Score card]      │  (icon grid)    │
├───────────────────────────────────────────────────┤                 │
│ Stat row — ONE card, 5 columns, hairline dividers  │ Spend/Earnings  │
├───────────────────────────────────────────────────┤  chart card     │
│ "Active Campaigns" — horizontal card carousel      ├─────────────────┤
├──────────────────────┬────────────────────────────┤ Upcoming list   │
│ Top Performing (list) │ Recent Activity (list)     │                 │
└──────────────────────┴────────────────────────────┴─────────────────┘
```

Main column ≈ 75%, right rail ≈ 25% (`railWidth` 360px, fixed). The rail is a **content
rail, not navigation**, and it starts at the top of the content area — this is a true
two-column split below the nav, not a main column with an aside tucked under it.

**Stat row.** Not five separate tiles. It is **one card** containing five equal columns
separated by full-height vertical hairlines (`ink300 @ 40%`). Each column is:
icon chip (44px, `radiusMd`, one accent pair from §1) → label (`bodyMedium`, `ink600`) →
value (`titleMedium` weight, *not* full `kpiNumber` size) → trend delta (`bodySmall`,
`success600`/`danger600` + arrow) → "vs last month" caption (`bodySmall`, `ink600`).

**Card carousel** ("Active Campaigns", "Brands that love your vibe"). Fixed-aspect image
thumbnail; status badge pill overlaid top-right; avatar stack overlaid bottom-left with `+N`
overflow chip; title + subtitle below the image; progress bar (4px, `primary600` fill,
`ink300 @ 30%` track) + amount text. Horizontal scroll with floating circular chevron
buttons that overlap the card edge (§7).

### 5.4 Nav is two patterns, not one

| Portal | Desktop nav |
|---|---|
| **Brand** | Full labelled top nav + search, notifications, messages, account menu |
| **Creator** | Logo only, no nav items, three circular action buttons top-right |
| **Admin** | Follows brand — full labelled nav. Item count (4) fits comfortably. |
| **Manager** | Follows creator, **plus** the `ManagerContextBar` (§5.5) |

The creator mockup's nav-less bar is only viable if creator navigation lives somewhere else
— which the mockup doesn't show. Pending the §5.1 IA decision, **build creator with the
labelled nav** and treat the mockup's minimal bar as an artifact of a marketing shot rather
than a specified state.

### 5.5 Manager context bar

`ManagerContextBar` in `portal_shell.dart` is a fourth chrome element no mockup covers. It
currently fills `ImColors.coral100`, which dies with the old palette. Re-anchor to
`warning100` with `warning600` text — it's an "you are acting as someone else" warning
state, and warning semantics fit better than a brand tint. It is golden-tested
(`manager_context_bar_golden_test.dart`); the golden must be regenerated and reviewed.

### 5.6 Multi-step form (`campaign_create_screen.dart`)

Step indicator = numbered circles joined by a hairline. This is a legitimate use of
numbering — it's a real 5-step sequence (Basic Info → Creators → Content & Deliverables →
Budget & Timeline → Review & Launch). Active step filled `primary600`; completed steps
filled with a check; upcoming steps outlined `ink300` with `ink600` numerals.

Two-column field grid on desktop, collapsing to one below `compactBreakpoint`. Right rail:
Pro Tip card (`gradientWarm`), live preview card mirroring what's being built, and a
"What's next?" vertical timeline list.

Bloc and state shape are unaffected — this is a visual pass. `im_stepper.dart` is
golden-tested; same regeneration note applies.

### 5.7 Mobile home

Single column. Large `radiusLg` hero card (`gradientHero`) with illustration slot, Caveat
greeting, `kpiNumberLarge` score, and a pill CTA. Horizontal quick-action row of **circular**
tinted chips (56px) with labels below — note these are full circles on mobile where desktop
uses `radiusMd` squircles. Stat tiles are **four across in a single row** on
`surfaceSubtle`, not a 2×2 grid. Then stacked list cards for active campaign and tasks.

Bottom tab bar: 64px, `surfaceCard`, `ImShadows.nav`, four icon+label items, active
`primary600` / inactive `ink600`, with a raised circular gradient FAB centred and
overlapping the bar's top edge.

---

## 6. Motion

`ImDurations` already defines `hover: 150ms`, `panel: 250ms`, and `easeOutCubic`. Assignments:

| Interaction | Duration | Curve |
|---|---|---|
| Button/card hover, icon-chip tint | `hover` 150ms | `easeOutCubic` |
| Button press (scale 0.98) | 100ms | `easeOut` |
| Nav pill active transition | `hover` 150ms | `easeOutCubic` |
| Carousel advance | `panel` 250ms | `easeOutCubic` |
| Stepper step transition | `panel` 250ms | `easeOutCubic` |
| Dropdown / popover open | `panel` 250ms | `easeOutCubic` |
| Skeleton shimmer | 1200ms, looping | `linear` |
| Progress bar fill | 400ms | `easeOutCubic` |
| Toast enter/exit | `panel` 250ms | `easeOutCubic` |

Respect `MediaQuery.disableAnimations` — when set, drop all of the above to zero except the
skeleton shimmer, which should hold a static mid-tone instead of looping.

---

## 7. Components

### 7.1 Already in the library

| Component | Spec |
|---|---|
| **Button (primary)** | `radiusMd`, `primary600` fill, white `labelLarge`, 44px min height, no shadow at rest, `ImShadows.float` on hover. Pill (`radiusFull`) for compact/icon-only. |
| **Button (secondary)** | `surfaceCard` fill, 1px `ink300` border, `ink900` text, same radius/height |
| **Card** (`im_card.dart`) | `surfaceCard`, `radiusLg`, `ImShadows.card`, `space24` padding |
| **KPI card** (`im_kpi_card.dart`) | Substantial extension. Today it is label + value only — no icon, no trend, no color prop (it hardcodes `ImColors.ink600` and wraps `ImCard`). §5.3 needs a **colored icon chip, a trend delta, a caption line, and a per-tile accent prop**, plus a divided-row container variant. |
| **Status chip** (`im_status_chip.dart`) | `radiusFull`, semantic `*100` fill, semantic `*600` text, `bodySmall` 600 weight, optional leading 14px icon |
| **Stepper** (`im_stepper.dart`) | Restyle to §5.6. 32px numbered circles, `radiusFull`, `ink300` connector, `primary600` for completed segments |
| **Input** (`im_text_field.dart`) | `surfaceCard` fill, 1px `ink300`, **`radiusMd`** (currently `radiusSm` — set in `app_theme.dart`'s `inputDecorationTheme`, which `im_text_field.dart` inherits, so it is a **one-site change**), `space16` horizontal padding, focus = 2px `primary600` ring |
| **Empty state** (`im_empty_state.dart`) | See §10. Currently a speech-bubble frame — replace with the illustration-slot pattern. |
| **Skeleton** (`im_skeleton.dart`) | Currently a "cream shimmer" — re-anchor to `surfaceSubtle` → `ink300 @ 20%` shimmer. See §10. |
| **Money text** (`im_money_text.dart`) | Tabular figures + `en_IN` formatting (§2) |
| **Bubble card** (`im_bubble_card.dart`) | **Keep.** This is a functional negotiation-offer bubble (tail-left = brand, tail-right = creator, `success600` border when locked), not a decorative leftover. Recolor only: brand side `teal100` → `primary100`, creator side `coral100` → `secondary100`. |
| **Toast** (`im_toast.dart`) | `ink900` fill, white text, `radiusMd`, floating |

### 7.2 New components

| Component | Spec |
|---|---|
| **Hero card** (`im_hero_card.dart`) | Gradient or flat fill, `radiusLg`, illustration slot right, headline + subtext + CTA left. Variants: `gradientHero`, `gradientWarm`, `gradientCream`, `gradientDark`. |
| **Avatar stack** (`im_avatar_stack.dart`) | Overlapping 28–32px circles, 2px `surfaceCard` ring, trailing `+N` chip on `ink300 @ 30%` |
| **Quick action tile** (`im_quick_action_tile.dart`) | Icon chip + label below. `radiusMd` squircle desktop, circle mobile. |
| **Marketing tag** (`im_tag.dart`) | Distinct from status chip — "Hot"/"New" are **not** `EntityStatus` values (§11). `radiusSm`, `tagHot*`/`tagNew*` from §1. |
| **Segmented toggle** | Row of pill options, `radiusMd` container on `surfaceSubtle`, selected = `surfaceCard` + `primary600` text + `ImShadows.card` |
| **Select / dropdown** | Matches input styling + trailing 20px chevron in `ink600` |
| **Character counter** | `bodySmall` `ink600`, bottom-right inside field. Turns `danger600` at 100%. |
| **Required marker** | `danger600` asterisk after label. Pair with `Semantics(required: true)` — never color-only. |
| **Selectable option card** | Icon chip + label, `radiusMd`, 1px `ink300`. Selected: `primary100` fill, `primary600` border, `primary600` check badge top-right. |
| **Timeline list** | Vertical `ink300` connector through 40px icon chips, title + subtitle per row ("What's next?") |
| **Task row** | Circular checkbox + title + subtitle + trailing points in `success600` |
| **Ranked list row** | Medal badge (1/2/3) + avatar + name/handle + metric columns |
| **"View all" link** | `labelLarge` `primary600`, 44px touch target. Appears on nearly every section header — one component, not ad-hoc `TextButton`s. |
| **Social icon row** | Platform icons + `+N` overflow chip. Port `im_platform_icon.dart` from `apps/web`. |
| **Carousel chevron** | 40px circular `surfaceCard`, `ImShadows.float`, overlapping the carousel edge. Hidden at scroll extents; keyboard-reachable. |
| **Notification badge** | `secondary600` fill, white `bodySmall`, `radiusFull`, on nav icons. Caps at "99+". |
| **Info tooltip** | 16px `ⓘ` in `ink600`. Must be focusable and respond to hover **and** tap. |
| **Verified badge** | 16px `info600` check, inline after a name |
| **Mobile FAB** | 56px circle, `gradientHero`, white icon, `ImShadows.float`, centred and overlapping the tab bar |

---

## 8. Illustration, gradient, and emoji budget

**Illustrations.** 3D-illustration accents appear **only** in hero and empty-state moments —
one per screen, never as filler. Everywhere else, flat/line icons inside the colored chip
pattern from §1. Every illustration is a *slot* pending asset sourcing (§0.1).

**Gradients — hard budget of two surfaces per screen.** Permitted: one hero card, one or two
callout cards (Brand Score, Pro Tip, Earnings Overview), and CTA button fills. Never on body
backgrounds, tables, list rows, or inputs. The `gradientPage` shell background (§5.2) is
exempt — it sits behind the chrome, not on it.

**Emoji.** The mockups lean on emoji heavily (👋 💜 ✨ 🌿 💡 🎉) and much of the product's
warmth rides on them. Ruling:

- Emoji are permitted in **content** — greetings, tips, task descriptions, marketing copy.
- Emoji are **not** permitted in **chrome** — nav labels, buttons, form labels, status chips,
  table headers, error messages.
- Never carry meaning by emoji alone. An emoji next to "In Progress" is decoration; an emoji
  *instead of* "In Progress" is a bug. Screen readers and emoji-less fallback fonts will
  both drop it.
- Flutter's emoji fallback varies by platform and is a known weak spot on Windows and older
  Android. Verify the specific glyphs above render on every target before shipping copy that
  depends on them; where one fails, use an icon, not a substitute emoji.

---

## 9. Accessibility

**Floor: WCAG 2.1 AA** — 4.5:1 for text under 18pt, 3:1 for large text and meaningful UI
boundaries.

**The screenshots do not meet this**, and several §1 values are deliberately darker than
what the mockups show. Measured against `surfaceCard` white unless noted:

| Combination | Mockup value | Ratio | Ruling |
|---|---|---|---|
| Body text on `surface` | `#6B7280` on `#F7F7FB` | **4.48:1** | Fails by a hair. `ink600` darkened to `#5B6473` → ≈5.5:1 |
| Positive trend "↑12%" | `#16A34A` | **3.30:1** | Fails — and it's 12px text. `success600` → `#15803D` → 5.0:1 |
| "In Progress" badge | `#D97706` | **3.19:1** | Fails. `warning600` → `#B45309` → 5.1:1 on white, 4.5:1 on `warning100` |
| White on `accentOrange500` | `#FFF` on `#FB923C` | **2.26:1** | Fails badly. **Never place text on `accentOrange500`** — decorative gradient stop only. |
| Chart axis labels | `ink300` | ~1.6:1 | Fails. Axis labels use `ink600`. `ink300` is for hairlines, never text. |
| `primary600` on white | `#6D3FF0` | 5.77:1 | Passes |
| `danger600` on white | `#DC2626` | 4.85:1 | Passes |

Text over `gradientHero` and `gradientDark` passes at every stop. Text over `gradientWarm`
does **not** at the orange end — the Brand Score card's body copy must sit over the pink
half, or gain a scrim.

Also required, and absent from the mockups:

- **Focus rings.** 2px `primary600` at 2px offset on every interactive element. The mockups
  show no focus state; that's a mockup limitation, not a design decision.
- **Never color-only.** Status chips carry text, not just tint. Trend deltas carry an arrow
  glyph, not just red/green. Required fields carry `Semantics(required: true)`.
- **Touch targets** ≥44px, including "View all" links, carousel chevrons, and the `ⓘ`
  tooltip trigger.
- **Chart data** must be reachable as text — a table or semantic label — not pixels alone.

---

## 10. Empty, loading, and error states

Absent from the mockups entirely, and the place §8's illustration guidance actually earns
its keep. Both components already exist and need re-anchoring.

**Empty** (`im_empty_state.dart`) — currently a speech-bubble frame carried over from the old
visual language. Replace with: centred illustration slot (120px), `headlineMedium` title,
`bodyMedium` `ink600` subtext, one primary CTA. This is the *one* permitted illustration per
screen when a screen is empty.

**Loading** (`im_skeleton.dart`) — currently a cream shimmer. Re-anchor to `surfaceSubtle`
base with an `ink300 @ 20%` sweep, 1200ms linear loop, `radiusMd` on blocks and `radiusFull`
on text lines. Skeletons must match the shape of what's arriving — a KPI row skeleton is five
columns, not one grey bar.

**Error** — `danger100` panel, `radiusMd`, `danger600` icon, `bodyMedium` `ink900` message,
retry action. No illustration; errors should not feel decorated.

---

## 11. Page-level mapping

| Mockup region | Target screen | Widget | Notes |
|---|---|---|---|
| Greeting hero + Brand Score | `brand_dashboard_screen.dart` | new `im_hero_card.dart` | Score card uses `gradientWarm`; mind the §9 contrast note |
| Stat row (5 columns) | brand + creator dashboards | `im_kpi_card.dart` | Needs per-tile accent prop; render as one card with dividers (§5.3) |
| Active Campaigns carousel | both dashboards | new `im_campaign_carousel_card.dart` | Image + badge overlay + avatar stack + progress |
| Quick Actions grid | both dashboards, rail | new `im_quick_action_tile.dart` | Reused mobile + desktop |
| Spend / Earnings chart | both dashboards | `features/analytics/presentation/widgets/metrics_chart_card.dart` | Already accepts a `primaryColor` override and handles `isLoading` via `im_skeleton.dart`. Restyle per the chart spec below; creator variant on `gradientDark`. |
| Top Performing / Recent Activity | `brand_dashboard_screen.dart` | new ranked list row + `im_status_chip.dart` | |
| Multi-step form shell | `campaign_create_screen.dart` | `im_stepper.dart` restyle | Bloc/state unaffected — visual only |
| Mobile hero + bottom nav | compact branch of `portal_shell.dart` | existing `NavigationBar` + new FAB | |
| Status badges | all | `im_status_chip.dart` | |
| "Hot" / "New" tags | creator dashboard | new `im_tag.dart` | **Not** `EntityStatus` — see below |
| Avatar stack | campaign/creator cards | new `im_avatar_stack.dart` | |

**Chart spec** (three of four screens have one, so it needs a real spec):
area chart, 2px `primary600` line, fill gradient from `primary600 @ 20%` to transparent,
4px dot marker at each point, larger glow dot on the final point, no vertical gridlines and
at most three faint horizontal ones (`ink300 @ 30%`), axis labels `bodySmall` `ink600`
tabular. Two variants — light-card (above) and the `gradientDark` earnings panel, which
inverts to a white line, white dots, and `#FFF @ 15%` fill.

**`status_colors.dart`** needs two changes:

1. `StatusSemantic.ink` currently maps to `cream100`, which dies with the palette. Re-anchor
   to `surfaceSubtle` background with `ink600` text.
2. "Hot" and "New" from the creator mockup are **marketing tags, not entity statuses**. They
   have no `EntityStatus` member and must not be forced into one — `statusSemanticFor()` is
   an exhaustive switch over a domain enum and adding presentation-only cases would corrupt
   it. They belong to the separate `im_tag.dart` component (§7.2).

---

## 12. Follow-ups

Out of scope here, but blocked on or created by this work:

- **IA decision on top-nav item count** (§5.1) — *blocks* the shell rewrite. Everything else
  in this document can proceed without it.
- **Illustration asset sourcing** (§0.1) — every illustration slot is empty until this lands.
- **Golden test regeneration** (§0.3) — 11 PNGs, 3 test files. Regenerate *and review*.
- **`apps/web` duplication** — left on the old theme by decision (§0.2). Decide whether it is
  retired, re-synced, or allowed to diverge permanently.
- **`apps/mobile`** — uses its own `mobile_theme.dart`, not `ImColors`/`ImTypography`. The
  mobile mockup implies an equivalent token pass, scoped separately.
- **Stale doc references** — **eight** files still cite the deleted `docs/frontend/design.md`
  and should be repointed at this document:
  `core/theme/tokens.dart:3`, `core/theme/status_colors.dart:6`,
  `core/widgets/im_bubble_card.dart:5`, `core/widgets/im_empty_state.dart:6`,
  `core/widgets/im_kpi_card.dart:9`, `core/widgets/im_skeleton.dart:5`,
  `core/widgets/im_stepper.dart:7`,
  `features/content/presentation/widgets/disclosure_banner.dart:6`.
  `portal_shell.dart:311` also carries a "Design.md §8" comment describing the now-superseded
  coral manager bar.
