# Code Review — Flutter UI Redesign (`gemini_design_opinion`)

**Reviewed:** `docs/gemini_design_opinion/monk-frontend/` @ `c91ded8`, branch `feature/gemini-ui-redesign`
**Base:** `72ec453` (local `main`)
**Scope of change:** 77 files, +2825 / −821. Touches `apps/monk` theme + widgets + shell + 4 screens, `apps/web/lib/core/theme/tokens.dart`, `apps/mobile` theme, and 24 golden PNGs.
**Date:** 2026-07-26

---

## Verdict

The token layer and the new component primitives are solid work and are close to mergeable. The three commits above them — shell, auth, dashboards — are **prototype-grade**: they hardcode demo data, drop live BLoC bindings, and introduce navigation bugs that crash or misroute. They should not merge as-is.

Recommendation: **split the branch.** Land commit `d75e1f7` (tokens + components) after the fixes in §2; rework `0303ff0` and `c91ded8` (auth + shell + dashboards) before they go anywhere near `main`.

| Area | State |
|---|---|
| Design tokens (`tokens.dart`) | Good — ship after §2.1, §2.2 |
| Typography | Good, but `greetingScript` is dead code (§3.1) |
| New components (5 widgets) | Good, minor fixes |
| `ImButton` / `ImCard` / `ImKpiCard` refactor | Regressions — §2.3, §2.4 |
| Portal shell rewrite | **Blocker** — §1.2, §1.3, §1.4 |
| Auth screens | Works, but brand-confused (§1.1) |
| Dashboards | **Blocker** — §1.1 |
| Tests | 1 golden failing, 44 failure artifacts committed (§4) |

One genuine, unadvertised win: `apps/monk` did not compile before this branch. Base `flutter analyze` reports **65 errors**; the branch reports **16**, and introduces **zero new ones**. The new `ImColors.ink400/500/700/800/100` tokens incidentally fixed 49 pre-existing `undefined_getter` errors in `ai_side_panel`, `fraud_warning_banner`, `publish_job_status_card`, and `recommendations_rail`. The remaining 16 (missing `ImSpacing.space2`/`space6`, and `ImMoneyText`/`ImToast`/`ImTextField` signature mismatches) are pre-existing and still block a build — see §5.

---

## 1. Blockers

### 1.1 Both dashboards were disconnected from their data source

`brand_dashboard_screen.dart` and `creator_dashboard_screen.dart` still wrap themselves in `BlocConsumer<DashboardCubit, DashboardState>`, but the builder now reads **only `state.failure`**. Every number, name, and avatar on both screens is a literal.

Base (`apps/monk` @ `72ec453`):
```dart
if (state.loading && state.brand == null) { ... }
final d = state.brand;          // ← real data
```
Branch:
```dart
builder: (context, state) {
  final isDesktop = ...;
  ...
  Text('Good morning, LuxeGlow! 👋', ...)      // brand_dashboard_screen.dart:86
  Text('Hey Ananya! 👋', ...)                  // creator_dashboard_screen.dart:111
  const Text('Allocated across 12 active campaigns', ...)
  const Text('From 5 active brand collaborations', ...)
```
`grep "state\.[a-z]"` across both files returns only `state.failure` hits. The loading state was dropped too — no skeleton, no spinner. The manager dashboard (`creator_dashboard_screen.dart:731`) is the only one still bound to `state.manager`.

These screens are now static mockups wearing a Cubit. Rebinding them is the single largest piece of remaining work in this branch.

### 1.2 Mobile bottom nav navigates to the wrong routes, and crashes for managers

`portal_shell.dart:463-475` passes a **hardcoded const 4-item list** to `ImBottomNavBar`, but wires `onTap` to a **different** list:

```dart
bottomNavigationBar: bp == ImBreakpoint.compact
  ? ImBottomNavBar(
      currentIndex: index.clamp(0, 3),
      onTap: (i) => context.go(items[i].path),   // ← `items`, the portal nav
      onFabTap: () => context.go('/b/campaigns/new'),
      items: const [                              // ← unrelated literals
        ImBottomNavItem(icon: Icon(Icons.home_outlined),  label: 'Home'),
        ImBottomNavItem(icon: Icon(Icons.work_outline),   label: 'Campaigns'),
        ImBottomNavItem(icon: Icon(Icons.chat_bubble_outline), label: 'Inbox', badgeCount: 2),
        ImBottomNavItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    )
  : null,
```

Consequences per portal:

| Portal | `items.length` | Result |
|---|---|---|
| Manager (`_managerNav`) | 3 | Tapping **Profile** → `items[3]` → **`RangeError` crash** |
| Creator (`_creatorNav`) | 4 | Labels lie: "Inbox" → `/c/earnings`, "Profile" → `/c/referrals` |
| Brand (`_nav`) | 5 | Labels lie: "Profile" → `/b/discover` |

`ImBottomNavBar` even asserts `items.length == 4` — the assert passes because it's checking the literal list, not the one that gets indexed.

The FAB routes to `/b/campaigns/new` in **all three portals**. A creator or admin tapping `+` hits a brand-guarded route and gets bounced to `/403`.

**Fix:** derive the bottom-nav items from `items`, pad/truncate to 4 explicitly, and make the FAB destination a `_PortalChrome` parameter.

### 1.3 The shell hardcodes demo persona names as the account label

```dart
// portal_shell.dart:39
_PortalChrome(title: 'LuxeGlow', subtitle: 'Brand Account', ...)

// portal_shell.dart:72
title: isManager || session.isManagerContext ? 'Meera Manager' : 'Ananya Sharma',
subtitle: isManager || session.isManagerContext ? 'Manager Account' : 'Creator Account',
```

Every signed-in user sees "Ananya Sharma" in the top-right profile chip and in the "Profile (…)" menu item. `SessionCubit` is already read two lines above for `isManagerContext`; the real display name is available. This is a mockup value that escaped into the shell.

### 1.4 Notification badge is permanently on, with a fake count

```dart
// portal_shell.dart:337
if (unread > 0 || true)
  ...
  Text(unread > 0 ? '$unread' : '3', ...)
```

`|| true` short-circuits the guard, and the fallback renders a literal `3`. Users with zero notifications see a red "3" badge forever. Same pattern in the bottom nav (`badgeCount: 2`, hardcoded).

Also: the search, notifications, and messages `IconButton`s in the header all have `onPressed: () {}` — three dead controls in the primary chrome.

---

## 2. Design-system regressions

### 2.1 `ink300` at `#ECECF3` fails non-text contrast as a form-field border

`ink300` moved from `#B9C2C6` → `#ECECF3`, and it is simultaneously the card hairline, the divider, **and** every `OutlineInputBorder` side in `app_theme.dart`. Against `#FFFFFF` that is roughly **1.1:1** — WCAG 2.2 SC 1.4.11 requires **3:1** for UI component boundaries. Every text field in the app now has a functionally invisible border in its resting state, and `dividerColor` was also changed from `ink300.withValues(alpha: 0.4)` to full-strength `ink300`, which is *lighter* than what it replaced.

`#ECECF3` is right for a card hairline. It is not right for an input boundary. Introduce a separate `borderStrong` token (≥ `#9CA3AF`) for `inputDecorationTheme` and keep `ink300` for decorative rules.

### 2.2 `danger` is now the same pink as `secondary`

```dart
static const secondary600 = Color(0xFFEC4899);   // brand pink
static const danger600     = Color(0xFFDB2777);  // error
static const danger100     = Color(0xFFFCE7F3);
static const secondary100  = Color(0xFFFCE4F1);  // ΔE ≈ 1
static const accentPinkFg  = Color(0xFFDB2777);  // === danger600
```

Error states, the creator portal's brand accent, and the "Hot" category chip are now the same hue. `ImButton(variant: destructive)` in the influencer portal is indistinguishable from a primary action. `statusChipColors(danger)` and `accentPink` are byte-identical. Error affordance should not share a family with a brand accent — move `danger` to a red (`#DC2626` or similar) or accept that destructive actions lose their visual warning.

### 2.3 `ImButton` hardcodes `primary600`, killing the three-portal theme

```dart
// im_button.dart:53
case ImButtonVariant.primary:
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: ImColors.primary600,   // ← literal, not colorScheme.primary
```
Same for `tertiary` (`foregroundColor: ImColors.primary600`). Previously these inherited from `elevatedButtonTheme`, which `_build()` derives from the per-portal `primary`. Now every primary button in the influencer portal is violet instead of pink, and every one in admin is violet instead of `#4C1D95`.

The rest of `PortalThemeExtension` is collateral damage: after the shell rewrite, `context.portalTheme` is referenced in **exactly one file** (`im_stepper.dart:29`). `sidebarBg`, `sidebarFg`, `sidebarActive`, and `ImLayout.sidebarWidth` are now dead — as is the `admin()` dark-sidebar treatment, since `darkSidebar` was deleted without replacement. Either delete the extension or restore the buttons to read `Theme.of(context).colorScheme.primary`. Prefer the latter.

### 2.4 `ImCard` now stamps a 40px blur shadow on all 68 call sites

```dart
boxShadow: elevation ?? ImShadows.card,   // 0 10px 40px rgba(60,45,100,.05)
```
Every `ImCard` — including nested ones, list rows, and `ImKpiCard` — gets an unconditional large-radius shadow plus a border. Two concerns:

1. **Nesting.** `ImKpiCard` is an `ImCard`; dashboards place `ImKpiCard`s inside `ImCard` sections. Stacked 40px blurs read as mud.
2. **Web perf.** Large-blur `BoxShadow` is a per-frame raster cost on CanvasKit. 68 sites × a 40px blur on a scrolling dashboard is measurable. Consider `blurRadius: 24` and an `elevation: const []` opt-out for nested use.

Also note the default padding changed `16 → 24` and radius `12 → 24` for every existing consumer. That is intentional per spec, but it silently re-laid-out ~68 screens that nobody in this branch looked at.

### 2.5 "Never raw hex" invariant abandoned

`tokens.dart` still carries the rule in its header comment. The branch breaks it in 8 places outside the theme directory and 6 inside it:

| File | Values |
|---|---|
| `app_theme.dart` | `0xFF5B2FD6`, `0xFFD93688`, `0xFF4C1D95`, `0xFF3B0764`, `0xFF2E1065` |
| `status_colors.dart` | `0xFF7C3AED` |
| `im_rank_badge.dart` | `0xFFF59E0B`, `0xFF94A3B8`, `0xFFD97706` (gold/silver/bronze) |
| `creator_dashboard_screen.dart` | `0xFFA78BFA`, `0xFFFEF9C3`, `0xFFFDE047`, `0xFF713F12`, `0xFFF59E0B`, `0xE6FFFFFF` |
| `brand_dashboard_screen.dart` | `0xCCFFFFFF`, `0x99FFFFFF` |
| `login/register_screen.dart` | `0xE6FFFFFF` |

The `primaryPressed` / admin values belong in `ImColors`. The white-alpha values (`0xE6FFFFFF` etc.) want an `onGradient` / `inkInverse` token set, since they appear on gradient panels in four files.

### 2.6 Legacy aliases invert one mapping and flatten portal identity

```dart
static const coral500 = primary600;   // was the LIGHTER coral
static const coral600 = primary500;   // was the DARKER coral  ← inverted
static const teal700  = primary600;
static const teal100  = primary100;
static const cream50  = surface;
```
`coral500`/`coral600` had a light→dark relationship; the aliases reverse it, so any existing hover/pressed pair built on them now gets *lighter* on press. More broadly, `coral*` and `teal*` both collapse to the same violet — any screen that used coral-vs-teal to distinguish two things now shows one color. The aliases keep the code compiling, which is their job, but they are a migration crutch: they need a tracked removal task, not permanence.

---

## 3. Correctness and polish

### 3.1 `Caveat` font is never loaded — the script styling silently doesn't apply

`ImTypography.greetingScript()` correctly uses `GoogleFonts.caveat`, but **nothing calls it**. All four consumer sites instead do:

```dart
Theme.of(context).textTheme.displayLarge?.copyWith(fontFamily: 'Caveat', fontSize: 38, ...)
```

`'Caveat'` is not declared in `apps/monk/pubspec.yaml` (`fonts:` section doesn't exist; only two logo assets are registered) and is not resolved by `google_fonts`. Flutter falls back to the default family with no error. The headline feature of the creator dashboard — the handwritten greeting — renders in Baloo2. Replace the four `copyWith` calls with `ImTypography.greetingScript()`.

Separately: `google_fonts` now pulls **three** families (Inter, Baloo2, Caveat) over the network at runtime on web. That's three FOUT reflows on first paint and a hard visual break offline. For a web-first product these should be bundled as assets.

### 3.2 Unsplash hotlinks as production image sources

18 `NetworkImage` / URL sites across `login`, `register`, both dashboards, and `im_avatar_stack`, all pointing at `images.unsplash.com`. Beyond being mock data in shipped code: `ImAvatarStack` uses `DecorationImage(image: NetworkImage(...))` with **no `onError`, no placeholder, no loading state** — offline or on a 404 the avatars render as bare `primary100` circles with a console exception per frame.

### 3.3 Brand identity is contradictory on the auth screens

`login_screen.dart` shows the `∞ Collabify` wordmark on the left hero panel and `MonkLogo` inside the form card on the right — two different brands, same viewport. Body copy reads "Welcome back to Collabify." and "Join thousands of top creators & brands collaborating seamlessly on Collabify."

Per `docs/design/design_context.md`, **Collabify is the third-party product the screenshots came from**; only its visual system was to be adopted, explicitly not its name or logo. The shell has the same problem (`portal_shell.dart:170`). All 8 "Collabify" strings and both `∞` glyph blocks need to become `MonkLogo` / "Influencers Monk".

### 3.4 The 72px top bar will overflow on mobile

On `ImBreakpoint.compact` the nav pills are hidden, but the header still renders: 36px logo + 12px gap + "Collabify" at 22px/w800 + `Spacer` + three 48px `IconButton`s + a profile chip containing a 32px avatar and two lines of text. That is comfortably over 360px with no `Flexible` anywhere in the `Row` — expect a `RenderFlex overflowed` yellow-stripe on phones. Collapse the header to logo + profile on compact.

### 3.5 Navigation was reduced by relabeling, not by IA work

`BrandShell._nav` went 10 → 5 and `CreatorShell._creatorNav` 9 → 4, but the removed destinations' routes still exist and are now unreachable from any nav surface: Shortlists, Applications, Briefs, Team, Company, Settings/Sessions (brand); Onboarding, Applications, Referrals, KYC, Access, Settings (creator). Manager lost Access and Settings.

Worse, three surviving entries were given labels that don't match their destinations:

| Label | Routes to | Should be |
|---|---|---|
| Brand → "Analytics" | `/b/briefs` | Briefs |
| Brand → "Reports" | `/b/invoices` | Invoices |
| Creator → "Analytics" | `/c/referrals` | Referrals |

If the target IA really is 4–5 top-level items, the overflow needs a home (profile menu, "More" sheet, or a settings sub-nav) and the labels need to match their routes.

### 3.6 Smaller items

- `ImAvatarStack` — `overflowCount: 120` is passed on the auth screens; the `+120` label is rendered at `size * 0.35` = 12.6px inside a 36px circle. It will clip. Cap the displayed value at `99+`.
- `ImBottomNavBar` — the 52px FAB is `Positioned(top: 0)` inside a 72px `Stack` with `clipBehavior: Clip.none`; it overhangs the bar. Tap targets on the four items are ~44px tall but the FAB has no `Semantics` label and no tooltip.
- `ImButton.glass` — `BackdropFilter` is expensive on web and the variant hardcodes white text, so it is only usable on a dark/gradient ground. Currently unused anywhere. Consider dropping it until there's a call site.
- `ImRankBadge` — the default (rank > 3) branch renders `ink600` on `ink300` = `#6B7280` on `#ECECF3` ≈ 4.6:1. Passes for text but it's a badge; verify at the 12px size it ships at.
- `ImKpiCard` — label demoted `labelLarge` → `bodySmall`, and the layout changed Column → Row with an optional 48px icon. Any existing caller that sizes KPI tiles at a fixed narrow width (the dashboards use `SizedBox(width: 180)` patterns) will now be cramped. Audit the ~10 non-dashboard call sites.
- `status_colors.dart` — `revisionRequested`, `shortlisting`, and `inProgress` moved from `warning` to the new `inProgress` semantic. Reasonable, but `revisionRequested` losing its warning tone is a product decision, not a styling one. Confirm with whoever owns the review flow.

---

## 4. Tests and repo hygiene

- **One golden test fails on the branch.** `manager_context_bar_golden_test.dart` — `ManagerContextBar` gained `fontWeight: FontWeight.bold` and the golden wasn't regenerated with the others. `flutter test test/goldens` → `+10 -1`.
- **44 golden *failure artifacts* are committed** under `apps/monk/test/goldens/failures/` (`*_isolatedDiff.png`, `*_maskedDiff.png`, `*_masterImage.png`, `*_testImage.png`). These are `flutter test` scratch output. Delete them and add `test/goldens/failures/` to `.gitignore`.
- **No tests were added.** `TASKS.md` specifies a verification command for each of the 10 component tasks (`flutter test .../im_goal_select_card_test.dart` etc.). None of those files exist. The five new widgets and the rewritten shell have zero coverage; the golden suite still only covers Button/Card/StatusChip/Stepper/ManagerContextBar.
- **`TASKS.md` is entirely unchecked** despite Phases 1, 2 (partial), 3 (partial), and 4 (partial) having landed. It also points at file paths that don't exist and weren't used — `features/shell_homes/presentation/desktop_top_nav.dart` (the work went into `portal_shell.dart`) and `apps/mobile/lib/presentation/mobile_shell.dart` (never created).

**Not done from the stated plan:** Task 2.4 (`im_status_chip.dart` itself is untouched — only `status_colors.dart` changed), Task 2.5 (`im_stepper.dart` untouched), Task 3.2 (mobile shell), Tasks 4.3 / 4.4 / 4.5 (campaign create, discovery, earnings).

---

## 5. Multi-app fallout

The repo has three Flutter apps sharing a duplicated design system. This branch changed them unevenly:

| App | What changed | Result |
|---|---|---|
| `apps/monk` | tokens + theme + widgets + shell + 4 screens | The intended target. Still 16 pre-existing analyzer errors — **does not build**. |
| `apps/web` | `core/theme/tokens.dart` **only** | Half-migrated: violet palette, but `app_theme.dart`, all 13 `im_*` widgets, and `portal_shell.dart` are still the old design reading through the legacy aliases. It renders as old-layout-in-new-colors. |
| `apps/mobile` | `tokens.dart` + `mobile_theme.dart` | Tokens updated; there is no mobile shell to apply them to. |

Two things worth deciding before more work lands:

1. **`apps/monk` doesn't compile, on either branch.** The 16 remaining errors are all pre-existing and all small — missing `ImSpacing.space2`/`space6` tokens, and four widgets calling `ImMoneyText` / `ImToast` / `ImTextField` with the wrong parameter names. Fixing them is under an hour and it's a prerequisite for verifying any of this visually. The branch got the error count from 65 → 16 for free; finishing the job is the obvious next step.

2. **`apps/monk` vs `apps/web`.** The last three commits on `main` before this branch all landed in `apps/web`, and `a43a15f` was specifically "verify web release build" — `apps/web` is the app that builds and ships. This redesign targets `apps/monk`. Either the fork gets collapsed first, or every change here has to be made twice. That decision should come before Phase 4 continues.

---

## Recommended sequence

1. Fix the 16 pre-existing analyzer errors in `apps/monk` so the app can actually be run and looked at.
2. Decide `apps/monk` vs `apps/web` — collapse the fork or declare one canonical.
3. Land `d75e1f7` (tokens + components) with these fixes: `borderStrong` token for inputs (§2.1), `danger` off pink (§2.2), `ImButton` reading `colorScheme.primary` (§2.3), hex literals moved into `ImColors` (§2.5), `coral500`/`coral600` alias inversion corrected (§2.6). Regenerate the `manager_context_bar` golden, delete `test/goldens/failures/`, gitignore it.
4. Rework the shell (`c91ded8`): bottom-nav item/route unification and FAB per-portal destination (§1.2), real session name (§1.3), notification badge guard (§1.4), compact-header overflow (§3.4), nav label/route alignment plus a home for the 11 orphaned destinations (§3.5).
5. Rebind both dashboards to `DashboardState` and restore loading states (§1.1).
6. De-Collabify: 8 strings, 2 glyph blocks, restore `MonkLogo` (§3.3). Replace Unsplash hotlinks with seeded mock assets or an asset placeholder (§3.2). Route the greeting through `ImTypography.greetingScript()` and bundle the three fonts (§3.1).
7. Add the widget tests `TASKS.md` already specifies, then check the boxes.
