# Implementation Plan — Monk Visual Redesign

**Spec:** [`design_context.md`](./design_context.md) — the visual source of truth
**Mockups:** [`mockups/`](./mockups/) — the executable visual contract
**Target:** `apps/monk` only (spec §0.2)
**Companions:** [`TOKEN_MIGRATION.md`](./TOKEN_MIGRATION.md) · [`SCREEN_INVENTORY.md`](./SCREEN_INVENTORY.md)

---

## 1. Thesis

The architecture is already right. `apps/monk` has token classes, a `PortalThemeExtension`,
an `im_*` widget library, portal shells, and golden tests. Almost nothing here is a
restructure.

Three things actually change:

1. **Visual language** — palette, type, radii, elevation. Mechanical, high blast radius.
2. **Chrome** — a 264px nav sidebar becomes a 72px top bar. The only architectural change,
   and the only genuinely risky phase.
3. **Composition** — four screens get real layout work. The other 59 inherit the theme.

So: **token-first, component-second, shell-third, screens-fourth**, with golden tests as the
regression gate at every step.

The mockups exist because the spec's contested calls are cheaper to settle in CSS than in
Dart. Building them already caught one spec error — see §7.

## 2. Phase 0 — Unblock

Two decisions gate the work. Neither is a code change.

### 2.1 Nav IA (blocks Phase 3 only)

The mockup top bar holds **5** labelled items. The real IA has **10** for brand, **9** for
creator, 5 for manager, 4 for admin. Ten labelled items do not fit a top bar at any sane
width.

`mockups/brand-dashboard.html` implements the spec's recommendation — 5 primary items in the
bar, the remaining 5 under the account menu:

| In the bar | Under the account menu |
|---|---|
| Dashboard, Discover, Campaigns, Applications, Briefs | Shortlists, Invoices, Team, Company, Settings |

The overflow set is settings-shaped and already belongs under an account menu, which is why
this is the recommendation. **It still needs product sign-off.** Open the mockup and look at
it before deciding. Phases 1, 2, 4 and 5 are unblocked by this.

### 2.2 Golden-test strategy (blocks Phase 1)

`apps/monk/test/goldens/` holds **11 reference PNGs** across three test files:

| Test file | Goldens |
|---|---|
| `im_widgets_golden_test.dart` | `im_button_*`, `im_card_*`, `im_status_chip_*` × brand/influencer/admin (9) |
| `im_stepper_golden_test.dart` | `im_stepper_influencer` (1) |
| `manager_context_bar_golden_test.dart` | `manager_context_bar` (1) |

**Every one is invalidated by Phase 1.** Decide up front: regenerate per-phase with visual
review, or suspend and reinstate at the end. A blind `flutter test --update-goldens` turns
the suite green while destroying its value — the goldens are the only automated check that
the redesign didn't break widget rendering.

Recommendation: regenerate per-phase, and require the diff images be *looked at* in review.

## 3. Phase 1 — Tokens

**One PR. Ships alone.** Every screen in the app changes appearance simultaneously; that is
expected and is exactly why it doesn't share a PR with anything else.

| File | Change |
|---|---|
| `core/theme/tokens.dart` | Full palette replacement; `ImRadii` md 12→16, lg 20→24, new `radiusXl` 32; `ImShadows` rewrite; `ImLayout` restructure; `ImDurations` motion table |
| `core/theme/typography.dart` | Baloo2 → **Outfit**; add **Caveat** `heroGreeting`; add `kpiNumberLarge`; tabular figures |
| `core/theme/app_theme.dart` | Per-portal primaries; `scaffoldBackgroundColor` cream50 → `surface`; `inputDecorationTheme` radius `radiusSm` → `radiusMd`; `cardTheme` radius + border |
| `core/theme/status_colors.dart` | `StatusSemantic.ink` off `cream100` → `surfaceSubtle`/`ink600` |
| `core/router/shells/portal_shell.dart` | `ManagerContextBar` off `coral100` → `warning100`/`warning600` (§5.5) |

Full old→new mapping in [`TOKEN_MIGRATION.md`](./TOKEN_MIGRATION.md).

**Three traps in this phase:**

- **Use the mockups' a11y-corrected values, not the screenshot values.** `ink600 #5B6473`,
  `success600 #15803D`, `warning600 #B45309`, mint/amber darkened. These deliberately diverge
  from `design_samples/`; `mockups/css/tokens.css` documents the measured ratio at each one.
  Reverting them toward the screenshots reintroduces six AA failures (spec §9).
- **`ImLayout.sidebarWidth` is still referenced** by `portal_shell.dart` in Phase 1. Either
  keep it as a deprecated alias until Phase 3 or land the two together. Don't leave it dangling.
- **`google_fonts` goes from one family to three** at runtime. If first paint regresses,
  bundle Outfit/Inter/Caveat as local assets — that's the fallback, not the default.

**Gate:** `flutter analyze` clean · `flutter test` green · 11 goldens regenerated *and reviewed*.

## 4. Phase 2 — Components

Existing widgets to spec §7.1, then new ones from §7.2. Each ships against its mockup
counterpart. These can parallelise across people — they're independent.

**Existing (`core/widgets/`):**

| Widget | Work |
|---|---|
| `im_kpi_card.dart` | **Largest single item.** Today: label + value wrapping `ImCard`, hardcoded `ink600`, no icon/trend/colour prop. Needs icon chip, trend delta, caption, per-tile accent prop, and a divided-row container variant (mockup `.statrow`). |
| `im_card.dart` | `radiusLg`, hairline + whisper-shadow, drop the heavier border |
| `im_status_chip.dart` | `radiusFull`, semantic pairs, optional leading icon |
| `im_stepper.dart` | Restyle to 32px numbered circles + connectors (mockup `.stepper`) |
| `im_text_field.dart` | Inherits the radius from `app_theme.dart` — **one-site change**, already done in Phase 1 |
| `im_empty_state.dart` | Speech-bubble frame → illustration-slot pattern (§10) |
| `im_skeleton.dart` | Cream shimmer → `surfaceSubtle` + `ink300 @ 20%` sweep; honour `disableAnimations` |
| `im_bubble_card.dart` | **Recolor only.** It is a functional negotiation-offer bubble (tail-left/right, `success600` locked border), not a dead leftover. `teal100`→`primary100`, `coral100`→`secondary100`. |
| `im_money_text.dart` | `en_IN` grouping + tabular figures — single currency rendering site |

**New:** `im_hero_card.dart`, `im_avatar_stack.dart`, `im_quick_action_tile.dart`,
`im_tag.dart` (Hot/New — **not** `EntityStatus`, see §6), `im_campaign_carousel_card.dart`,
plus the smaller pieces in spec §7.2 (segmented toggle, option card, timeline list, task row,
ranked row, "View all" link, carousel chevron, notification badge, info tooltip, FAB).

**Also:** `metrics_chart_card.dart` (`features/analytics/presentation/widgets/`) restyles to
the spec §11 chart. It already accepts a `primaryColor` override and already wires
`im_skeleton.dart` for loading — restyle, don't replace.

**Gate:** widget tests green · each component visually diffed against its mockup.

## 5. Phase 3 — Shell

**The risky one.** Rewrite of `portal_shell.dart`'s expanded branch. Ships alone, behind
careful review.

- Sidebar (`Row` + 264px `Material`) → 72px top nav
- `PortalThemeExtension.sidebarBg`/`sidebarFg`/`sidebarActive` → `navBg`/`navFg`/`navActive`
  — breaking rename, sweep call sites
- Add `shellStyle` to `PortalThemeExtension`; brand + admin `flat`, creator `floating`
  (spec §5.2). Branch on the style, not the portal enum, so a future portal isn't a two-site change.
- Account overflow menu per the Phase 0 decision
- `_PortalChrome.darkSidebar` (admin) folds into `shellStyle`
- Compact branch already uses `AppBar` + `NavigationBar` — only the FAB and restyle are new

**Risk:** this touches routing chrome for all three portals plus manager context. It is the
one change that can silently break navigation without failing a test.

**Gate:** click every route in `app_router.dart` (80 paths) across brand, creator, manager
context, and admin. Nothing else in this plan needs that level of manual verification.

## 6. Phase 4 — Tier 1 screens

The four with mockups, plus auth. Real composition work, not inherited tokens.

| Screen | Mockup |
|---|---|
| `dashboards/…/brand_dashboard_screen.dart` | `brand-dashboard.html` |
| `dashboards/…/creator_dashboard_screen.dart` | `creator-dashboard.html` |
| `campaigns/…/campaign_create_screen.dart` | `campaign-create.html` |
| Compact branch of `portal_shell.dart` | `creator-mobile.html` |
| `auth/…/login_screen.dart`, `register_screen.dart` | none — first impression, cheap |

`campaign_create_screen.dart` is a **visual pass only**. `campaign_form_bloc.dart` state
shape is unaffected — `im_stepper.dart` is restyled, not rewired.

**`status_colors.dart` constraint.** `statusSemanticFor()` is an exhaustive switch over the
`EntityStatus` domain enum. "Hot" and "New" from the creator mockup are **marketing tags with
no `EntityStatus` member**. Do not add cases for them — they belong to `im_tag.dart`. Adding
presentation-only values to a domain enum is how that switch stops being exhaustive.

## 7. Phase 5 — Tier 2 and 3

Everything else, ordered by [`SCREEN_INVENTORY.md`](./SCREEN_INVENTORY.md). Tier 2 gets a
composition pass; Tier 3 inherits tokens and needs only a smoke check. Most of Tier 3 is
settings, admin, and wizard screens where the Phase 1 + 2 work is already sufficient.

## 8. What building the mockups changed

The mockups were built before this plan, and one spec value did not survive contact:

**`gradientWarm` was wrong.** The spec defined it as `secondary600 → accentOrange500` with
white text. Rendered, the white text over the pale end was unreadable — and checking the
source screenshots confirmed the Brand Score and Pro Tip cards are *pale washes carrying dark
ink*, not saturated fills carrying white. `mockups/css/tokens.css` now defines it as a pale
three-stop wash with `ink-900` text.

`design_context.md` §1 still carries the old definition. **Fix the spec to match the mockup
before Phase 1** — the mockup is right.

This is the argument for the mockups existing at all: that error would have cost a component
rebuild in Dart. It cost twenty minutes in CSS.

## 9. Risks

| Risk | Mitigation |
|---|---|
| Blind golden regeneration hides real breakage | Phase 0 decision; require diffs be reviewed |
| Shell rewrite silently breaks routes | Manual walk of all 80 paths; ships alone |
| Palette reverted toward screenshots, reintroducing AA failures | Ratios documented inline in `tokens.css`; contrast check in the gate |
| Three runtime webfonts regress first paint | Measure; bundle locally as the fallback |
| `apps/web` drifts further | Already drifted (`im_empty_state` monk-only, `im_platform_icon` web-only); accepted and tracked |
| Scope creep from 63 screens | Tiering is the control; Tier 3 is explicitly "inherit and smoke-test" |

## 10. Verification

**Per phase:** `flutter analyze` clean · `flutter test` green · goldens regenerated *and
eyeballed*.

**After Phase 3:** walk every route in `app_router.dart` across all three portals plus
manager context.

**End state:** run the app at desktop and mobile widths for brand, creator, and admin and
compare against `mockups/`. The mockups are the acceptance criteria — where Flutter and the
HTML disagree, one of them is a bug, and §8 is the precedent for it sometimes being the spec.

### Running the mockups

`file://` works for the HTML, but a local server avoids font and CORS quirks:

```bash
cd docs/claude_design_opinion/mockups && python -m http.server 8777
# http://127.0.0.1:8777/brand-dashboard.html
```

The CSS holds one invariant worth keeping: **no hex literal outside `tokens.css`** —
the same rule `tokens.dart` enforces in Dart.

```bash
grep -rn '#[0-9a-fA-F]\{6\}' css/ --exclude=tokens.css   # must return nothing
```
