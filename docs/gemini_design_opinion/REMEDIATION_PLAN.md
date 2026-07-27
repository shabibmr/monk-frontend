# Implementation Task List — Remediate the Gemini UI Redesign

## Context

The Flutter UI was revamped on `feature/gemini-ui-redesign`, living as a nested git clone at
`docs/gemini_design_opinion/monk-frontend/`, 3 commits ahead of `main` @ `72ec453`.
I reviewed it — full findings in **`docs/gemini_design_opinion/CODE_REVIEW.md`**.

The token layer and the five new components are good work. The three commits above them
(shell, auth, dashboards) are prototype-grade: they hardcode demo data, drop live BLoC bindings,
and introduce navigation bugs that crash or misroute. This plan fixes that, and collapses the
`apps/monk` / `apps/web` fork along the way.

**Decisions taken:**
- Work happens **inside the nested clone** (`docs/gemini_design_opinion/monk-frontend/`), on
  `feature/gemini-ui-redesign`. Merging upward into the main working tree is a later step.
- **`apps/monk` becomes the single canonical app**; `apps/web` is retired.

**Key finding driving Phase 0:** `apps/web` at base compiles cleanly (**0 errors**, 9 info lints)
and its `ImSpacing` already defines `space2`/`space6` while its `ImColors` already defines
`ink800/700/500/400/100`. `apps/monk` was the stale fork — 65 errors at base, 16 on the branch.
The redesign re-derived the ink tokens but not the spacing ones. So the remaining 16 errors are
fixed by **porting from `apps/web`**, not by hand-authoring fixes.

Drift is bidirectional but small — 25 files differ, most by under 15 lines:
- **`apps/monk` ahead:** DI (split into 3 files, 426 lines vs web's single 379), auth screens
  (`MonkLogo` + hero tags from `2639487`), plus the 13 redesign files.
- **`apps/web` ahead:** the compile fixes, `onboarding_wizard_screen.dart` (+38 lines),
  and two files monk lacks entirely.

---

# Phase 0 — Collapse the fork and unblock the build

Nothing downstream can be verified visually until `apps/monk` runs. Do this first.

### 0.1 Port the two files `apps/web` has and `apps/monk` lacks
- `apps/web/lib/core/mock/mock_config.dart` → `apps/monk/lib/core/mock/`
- `apps/web/lib/core/widgets/im_platform_icon.dart` → `apps/monk/lib/core/widgets/`
- Add `export 'im_platform_icon.dart';` to `apps/monk/lib/core/widgets/widgets.dart`
- Resolve any import-path deltas; confirm nothing in monk already provides `mock_config`'s role.

### 0.2 Add the two missing spacing tokens
`apps/monk/lib/core/theme/tokens.dart` — add to `ImSpacing`, matching `apps/web`:
```dart
static const space2 = 2.0;
static const space6 = 6.0;
```
Clears 6 of the 16 errors (`fraud_warning_banner.dart:109,119`, `ai_side_panel.dart:269`).
`fraud_warning_banner.dart` is byte-identical between the two apps, so this is its only fix.

### 0.3 Port `apps/web`'s compiling versions of the three broken widgets
These differ between the apps and web's versions compile. Take web's, then re-check.

| File | Errors in monk | web's fix |
|---|---|---|
| `features/ai/presentation/widgets/ai_side_panel.dart` | 5 | `ImToast.show(context, state.errorMessage!, isError: true)` → named `message:` + `tone: ImToastTone.danger` |
| `features/publish/presentation/widgets/schedule_publish_dialog.dart` | 1 | `ImTextField(placeholder:)` → `hint:` |
| `features/recommendations/presentation/widgets/recommendations_rail.dart` | 4 | `ImMoneyText(amount:/currency:)` → `(minorUnits:/currencyCode:)` |

⚠️ On `recommendations_rail`: `Recommendation.estimatedBudget` is a `double?` in **major** units,
but `ImMoneyText` takes `int minorUnits` and its doc comment says *"Displays API-provided minor
units. No client-side fee math."* Check how `apps/web` resolved this. If it converts inline
(`* 100).round()`), that contradicts the widget's contract — prefer changing the entity to minor
units, or add an explicitly-named major-units constructor. Do not silently multiply.

Also drop the unused import at `ai_bloc.dart:3` and `dashboard_stubs.dart:7`.

### 0.4 Reconcile the remaining non-redesign drift (9 files)
For each, diff both versions and take the newer. Expected direction:

**Take `apps/web`'s version** (web ahead):
- `features/onboarding_influencer/.../onboarding_wizard_screen.dart` (+38 lines)
- `features/contracts/.../contract_screen.dart`, `features/disputes/.../dispute_filing_screen.dart`,
  `features/payments/domain/entities/payment.dart`, `features/shell_homes/.../dashboard_stubs.dart`
  (1–2 lines each — likely the same import/lint cleanups)

**Keep `apps/monk`'s version** (monk ahead):
- `core/di/injection.dart` + `register_http_repositories.dart` + `register_mock_repositories.dart` —
  monk's 3-file split (426 lines) supersedes web's single 379-line file. Verify the split covers
  every registration web's version had before discarding it.
- `features/auth/presentation/screens/landing_screen.dart` — monk uses `MonkLogo(heroTag:)`,
  web still has a text wordmark
- `features/auth/presentation/screens/sessions_screen.dart` — monk has the logout work from `72ec453`
- `features/auth/presentation/widgets/mock_demo_persona_selector.dart` — monk-only, keep

### 0.5 Retire `apps/web`
- Delete `apps/web/`
- Port any of its 42 test files that cover something monk's 47 don't
- `apps/monk/pubspec.yaml`: rename `name: monk_web` → `monk` (both apps currently share the name);
  update every `package:monk_web/...` import across `lib/` and `test/`
- `.github/workflows/web-ci.yml`: repoint the three `apps/web` references to `apps/monk`
- Root `README.md`: it still describes the tree as `apps/web/` only, with no mention of
  `apps/monk` or `apps/mobile`. Rewrite the structure section and the run instructions
  (currently deferring to the now-deleted `apps/web/README.md`).

### 0.6 Gate
```bash
cd apps/monk && flutter analyze --no-pub   # must be 0 errors
```
Commit as one "collapse fork, restore build" change, separate from any design work.

---

# Phase 1 — Land the design system

The good commit (`d75e1f7`), with six fixes. Everything here is in
`apps/monk/lib/core/theme/` and `apps/monk/lib/core/widgets/`.

### 1.1 Add `borderStrong` and stop using `ink300` as an input border
`ink300` moved `#B9C2C6` → `#ECECF3` and is simultaneously the card hairline, the divider, and
every `OutlineInputBorder` side in `app_theme.dart`. Against white that is ~**1.1:1** — WCAG 2.2
SC 1.4.11 requires **3:1** for UI component boundaries. Every text field's resting border is
effectively invisible.
- Add `static const borderStrong = Color(0xFF9CA3AF);` (or darker) to `ImColors`
- Point all five `OutlineInputBorder` sides in `app_theme.dart` `inputDecorationTheme` at it
- Keep `ink300` for `ImBorders.card` only
- Revert `dividerColor` to a tinted value — the branch changed it from `ink300.withValues(alpha: 0.4)`
  to full-strength `ink300`, which is *lighter* than what it replaced

### 1.2 Move `danger` off pink
```dart
secondary600 = #EC4899   // brand pink
danger600    = #DB2777   // error — one hue away
danger100    = #FCE7F3   // vs secondary100 #FCE4F1, ΔE ≈ 1
accentPinkFg = #DB2777   // byte-identical to danger600
```
`ImButton(variant: destructive)` is indistinguishable from a primary action in the influencer
portal. Move `danger600`/`danger100` to a red (`#DC2626` / `#FEE2E2`), then re-check
`statusChipColors(danger)` and every `ImColors.danger*` call site.

### 1.3 Restore portal theming in `ImButton`
`im_button.dart:53` hardcodes `backgroundColor: ImColors.primary600`; `:94` hardcodes
`foregroundColor: ImColors.primary600` for tertiary. These previously inherited from
`elevatedButtonTheme`, which `AppTheme._build()` derives per portal. As written, all three
portals render violet.
- Replace both literals with `Theme.of(context).colorScheme.primary`
- Then decide `PortalThemeExtension`'s fate: after the shell rewrite, `context.portalTheme` has
  exactly **one** consumer (`im_stepper.dart:29`), and `sidebarBg`/`sidebarFg`/`sidebarActive` +
  `ImLayout.sidebarWidth` are dead. Either restore the admin dark treatment (deleted with the
  `darkSidebar` flag) or remove the extension. Do not leave it half-wired.

### 1.4 Move the stray hex literals into `ImColors`
`tokens.dart`'s header still says *"never raw hex"*. The branch breaks it in 14 places:

| File | Values |
|---|---|
| `app_theme.dart` | `0xFF5B2FD6`, `0xFFD93688`, `0xFF4C1D95`, `0xFF3B0764`, `0xFF2E1065` |
| `status_colors.dart` | `0xFF7C3AED` |
| `im_rank_badge.dart` | `0xFFF59E0B`, `0xFF94A3B8`, `0xFFD97706` |
| both dashboards, `login`/`register` | `0xE6FFFFFF`, `0xCCFFFFFF`, `0x99FFFFFF`, `0xFFA78BFA`, `0xFFFEF9C3`, `0xFFFDE047`, `0xFF713F12` |

Name the pressed/admin values properly; add an `onGradient` / `inkInverse` set for the
white-alpha values, which recur across four files on gradient panels.

### 1.5 Fix the inverted legacy aliases
```dart
static const coral500 = primary600;   // was the LIGHTER coral
static const coral600 = primary500;   // was the DARKER coral   ← reversed
```
Any hover/pressed pair built on these now gets *lighter* on press. Swap them. Then file a tracked
removal task for the whole alias block — `coral*` and `teal*` both collapse to one violet, so any
screen that used coral-vs-teal to distinguish two things now shows one color. The aliases are a
migration crutch, not a destination.

### 1.6 Make `ImCard`'s shadow opt-out-able
`im_card.dart` applies `ImShadows.card` (40px blur) unconditionally across **68 call sites**,
including nested ones — `ImKpiCard` *is* an `ImCard`, and the dashboards nest them inside `ImCard`
sections. Two problems: stacked 40px blurs read as mud, and large-blur `BoxShadow` is a real
per-frame raster cost on CanvasKit.
- Reduce `ImShadows.card` blur to ~24px
- Honour `elevation: const []` as a no-shadow opt-out for nested use, and apply it in `ImKpiCard`
- Note for reviewers: default padding also changed `16 → 24` and radius `12 → 24`, silently
  re-laying-out all 68 consumers. Intentional per spec, but nobody has looked at them.

### 1.7 Audit `ImKpiCard`'s call sites
Label demoted `labelLarge` → `bodySmall`; layout changed Column → Row with an optional 48px icon.
Any caller sizing tiles at a fixed narrow width (dashboards use `SizedBox(width: 180)` patterns)
is now cramped. Walk the ~10 non-dashboard call sites.

### 1.8 Green the golden suite
- Regenerate `manager_context_bar` — it fails on the branch (`+10 -1`) because
  `ManagerContextBar` gained `fontWeight: FontWeight.bold` and its golden wasn't updated with
  the others
- Delete the **44 committed failure artifacts** under `apps/monk/test/goldens/failures/`
  (`*_isolatedDiff.png`, `*_maskedDiff.png`, `*_masterImage.png`, `*_testImage.png` — these are
  `flutter test` scratch output)
- Add `test/goldens/failures/` to `apps/monk/.gitignore`

---

# Phase 2 — Rework the portal shell

All in `apps/monk/lib/core/router/shells/portal_shell.dart`.

### 2.1 Fix the bottom nav — it crashes for managers *(blocker)*
`:463-475` passes a hardcoded const 4-item list to `ImBottomNavBar` but wires `onTap` to a
**different** list:
```dart
ImBottomNavBar(
  currentIndex: index.clamp(0, 3),
  onTap: (i) => context.go(items[i].path),   // ← portal nav list
  items: const [ /* four unrelated literals */ ],
)
```
| Portal | `items.length` | Result |
|---|---|---|
| Manager | 3 | Tapping **Profile** → `items[3]` → **`RangeError` crash** |
| Creator | 4 | "Inbox" → `/c/earnings`, "Profile" → `/c/referrals` |
| Brand | 5 | "Profile" → `/b/discover` |

`ImBottomNavBar` asserts `items.length == 4` — the assert passes because it checks the literal
list, not the one that gets indexed.
- Derive the four `ImBottomNavItem`s from `items`, padding or truncating explicitly
- Drive `badgeCount` from `NotificationsCubit`, not the literal `2`
- Keep the assert meaningful, or relax it and handle 3/5-item navs

### 2.2 Make the FAB destination per-portal
`onFabTap: () => context.go('/b/campaigns/new')` fires in all three portals. A creator or admin
tapping `+` hits a brand-guarded route and lands on `/403`. Add a `fabPath` parameter to
`_PortalChrome` and set it per shell.

### 2.3 Use the real session identity
```dart
title: 'LuxeGlow'                                              // :39
title: isManager ? 'Meera Manager' : 'Ananya Sharma'           // :72
```
Every signed-in user sees "Ananya Sharma" in the profile chip and the "Profile (…)" menu item.
`SessionCubit` is already read two lines above for `isManagerContext` — pull the display name
and account-type label from there.

### 2.4 Fix the always-on notification badge
```dart
if (unread > 0 || true)                                        // :337
  Text(unread > 0 ? '$unread' : '3', ...)
```
`|| true` short-circuits the guard and the fallback is a literal `3`. Remove both.
While here: search, notifications, and messages `IconButton`s all have `onPressed: () {}` —
three dead controls in the primary chrome. Wire them or remove them.

### 2.5 Fix the compact-width header overflow
On `ImBreakpoint.compact` the pills hide but the 72px header still renders logo + 12px gap +
22px/w800 wordmark + `Spacer` + three 48px `IconButton`s + a profile chip with a 32px avatar and
two text lines. That exceeds 360px with no `Flexible` anywhere in the `Row` → `RenderFlex
overflowed`. Collapse to logo + profile below 600px.

### 2.6 Rebuild the navigation IA
Brand went 10 → 5 items, creator 9 → 4, manager 5 → 3. Eleven routes are now unreachable from any
nav surface: Shortlists, Applications, Briefs, Team, Company, Settings/Sessions (brand);
Onboarding, Applications, Referrals, KYC, Access, Settings (creator); Access, Settings (manager).

Three surviving entries were relabelled without repointing:

| Label | Routes to | Should be |
|---|---|---|
| Brand → "Analytics" | `/b/briefs` | Briefs |
| Brand → "Reports" | `/b/invoices` | Invoices |
| Creator → "Analytics" | `/c/referrals` | Referrals |

- Fix the three label/route mismatches
- Give the 11 orphans a home — **suggested default:** Settings/KYC/Access/Team/Company into the
  profile `PopupMenuButton`, the rest behind a "More" destination. ⚠️ **Needs product sign-off**
  before building; flag it rather than guessing.

---

# Phase 3 — Reconnect the dashboards *(blocker)*

`apps/monk/lib/features/dashboards/presentation/screens/{brand,creator}_dashboard_screen.dart`

Both still wrap in `BlocConsumer<DashboardCubit, DashboardState>`, but the builder reads **only
`state.failure`**. `grep "state\.[a-z]"` returns nothing else. Base read `state.brand` /
`state.profile` plus a loading branch:
```dart
// base
if (state.loading && state.brand == null) { ...skeleton... }
final d = state.brand;
```
Every figure, name, and avatar is now a literal — `'Good morning, LuxeGlow! 👋'`,
`'Allocated across 12 active campaigns'`, `'From 5 active brand collaborations'`.

### 3.1 Rebind `brand_dashboard_screen.dart` to `state.brand`
### 3.2 Rebind `creator_dashboard_screen.dart` to `state.profile`
### 3.3 Restore the loading branch on both (`ImSkeleton`/`ImSkeletonCard` already exist)
### 3.4 Verify against the manager dashboard
`creator_dashboard_screen.dart:731` still reads `state.manager` correctly — it survived the
rewrite and is the reference for what the other two should look like.

Where the redesign's layout needs a field the entity doesn't carry (trend deltas, sparkline
series, rank), either add it to the domain entity + mock seed or drop that element. Do not leave
a hardcoded number next to a live one.

---

# Phase 4 — Branding, assets, fonts

### 4.1 Remove the Collabify branding
Eight `'Collabify'` strings and two `∞` glyph blocks across `portal_shell.dart:170`,
`login_screen.dart` (`:73, :105, :200`), `register_screen.dart` (`:71, :103, :196`).
Per `docs/design/design_context.md`, **Collabify is the third-party product the screenshots came
from** — only its visual system was in scope, explicitly not its name or logo. Right now
`login_screen.dart` shows the `∞ Collabify` wordmark on the left hero and `MonkLogo` in the form
card on the right: two brands, one viewport. Restore `MonkLogo` / "Influencers Monk" throughout.

### 4.2 Replace the Unsplash hotlinks
18 `NetworkImage` / URL sites across `login`, `register`, both dashboards, and
`im_avatar_stack.dart`, all pointing at `images.unsplash.com`. Replace with seeded mock assets
under `apps/monk/assets/` (register them in `pubspec.yaml`).

### 4.3 Harden `ImAvatarStack`
- `DecorationImage(image: NetworkImage(...))` has no `onError`, no placeholder, no loading state —
  offline or on a 404 it renders bare `primary100` circles and throws once per frame
- Cap the overflow label at `99+`: the auth screens pass `overflowCount: 120`, rendered at
  `size * 0.35` ≈ 12.6px inside a 36px circle, which clips

### 4.4 Make the script font actually load
`ImTypography.greetingScript()` is correct (uses `GoogleFonts.caveat`) but **is never called**.
All four consumers instead do:
```dart
Theme.of(context).textTheme.displayLarge?.copyWith(fontFamily: 'Caveat', ...)
```
`'Caveat'` is not in `apps/monk/pubspec.yaml` (there is no `fonts:` section — only two logo
assets) and is not google_fonts-resolved, so Flutter silently falls back to Baloo2. The headline
feature of the creator dashboard renders in the wrong face.
- Route all four sites through `ImTypography.greetingScript()` —
  `login_screen.dart:88`, `register_screen.dart:86`, `brand_dashboard_screen.dart:88`,
  `creator_dashboard_screen.dart:113`

### 4.5 Bundle the fonts
`google_fonts` now fetches **three** families (Inter, Baloo2, Caveat) at runtime. On web that's
three FOUT reflows on first paint and a hard visual break offline. Vendor them into
`apps/monk/assets/fonts/` and declare them in `pubspec.yaml`.

### 4.6 Fix `web/index.html`
Still Flutter boilerplate: `<title>web</title>`, `content="A new Flutter project."`, no `lang`
attribute on `<html>` (an a11y requirement), no `theme-color`.

---

# Phase 5 — Tests and hygiene

### 5.1 Widget tests for the five new components
`TASKS.md` already specifies a verification command per task; none of the files exist.
Add to `apps/monk/test/core/widgets/`: `im_avatar_stack_test.dart`, `im_bottom_nav_bar_test.dart`,
`im_gamified_task_card_test.dart`, `im_goal_select_card_test.dart`, `im_rank_badge_test.dart`.

### 5.2 Shell routing tests
A table test over all four portals asserting bottom-nav index → route, that the manager portal
(3 items) does not throw, and that the FAB destination matches the portal. This is the regression
guard for §2.1/§2.2.

### 5.3 Golden coverage for the new components
Extend `im_widgets_golden_test.dart` across the three portal themes, matching the existing pattern.

### 5.4 Contrast assertions
Cheap unit tests asserting `borderStrong`-on-`surfaceCard` ≥ 3:1 and `danger600` distinguishable
from `secondary600`, so §1.1/§1.2 can't silently regress.

### 5.5 Correct and tick `TASKS.md`
It is entirely unchecked despite Phases 1–4 partly landing, and it points at paths that were never
created: `features/shell_homes/presentation/desktop_top_nav.dart` (work went into
`portal_shell.dart`) and `apps/mobile/lib/presentation/mobile_shell.dart` (never made).
Mark the real state and drop the `apps/web` mirroring task (Task 1.5) now that the fork is gone.

**Still unstarted from the original plan** — schedule or explicitly defer:
Task 2.4 (`im_status_chip.dart` untouched — only `status_colors.dart` changed),
2.5 (`im_stepper.dart` untouched), 3.2 (mobile shell),
4.3 / 4.4 / 4.5 (campaign create, discovery, earnings screens).

---

## Verification

Gate after every phase:
```bash
cd docs/gemini_design_opinion/monk-frontend/apps/monk
flutter analyze --no-pub     # 0 errors (base 65 → branch 16 → target 0)
flutter test                 # all green, incl. regenerated goldens
flutter run -d chrome
```

Manual pass, per portal (brand / creator / manager / admin):
1. Sign in from `/login` at >1024px and <600px — one brand mark, no overflow stripe.
2. Resize below 600px inside the shell: tap every bottom-nav item and the FAB. Destination must
   match the label; the **manager portal must not throw**; the FAB must stay inside the portal.
3. Load both dashboards against mocks — change a seed value in `core/mock/seed/` and confirm the
   dashboard changes. Throttle the network and confirm a skeleton appears.
4. With `unread == 0`, no notification badge anywhere.
5. Reach every previously-navigable route (Shortlists, Team, KYC, Access, Settings…) from the new IA.
6. Tab through any form — input borders visible at rest; destructive buttons clearly distinct
   from primary in **all three** portal themes.
7. Run offline once: no Unsplash 404 spam, fonts still correct, avatars degrade gracefully.

## Open questions to resolve before building

- **§2.6 nav IA** — where the 11 orphaned destinations live is a product decision, not a styling one.
- **§0.3 money units** — `estimatedBudget` is `double?` major units against `ImMoneyText`'s
  `int minorUnits` contract; needs a call on which side changes.
- **§1.3** — whether the admin dark-sidebar treatment (deleted with the `darkSidebar` flag) comes
  back, which decides whether `PortalThemeExtension` survives.
- **`status_colors.dart`** — `revisionRequested` moved from `warning` to the new `inProgress`
  semantic, losing its warning tone. That's a product call; confirm with whoever owns review flow.
