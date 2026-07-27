# Gap Remediation — Round 2 (Gemini UI Redesign)

## Execution summary (post-implementation update)

After this report was written, the round-2 task list below was largely executed directly
in the nested clone. Some findings turned out to be stale by the time fixes started (the
working tree was still being edited concurrently) — those are noted inline. Net result:

- **R2.0 (build gate):** turned out already clean (0 errors) once re-checked live — the
  4 `isDesktop` errors reported were a stale snapshot. `apps/web`'s deletion and all of
  round 1 + round 2's changes remain **uncommitted** — 403 deletions under `apps/web`,
  ~123 changed files under `apps/monk`. No commit was made without explicit user
  go-ahead; git log still ends at `72ec453`.
- **R2.1 (bottom-nav crash):** fixed for real. `ImBottomNavBar` is now genuinely variadic
  (2–5 items, FAB always centered) instead of hard-asserting exactly 4 — the manager
  portal's 3-item nav no longer crashes.
- **R2.2 (portal-blind menu):** fixed. Profile/settings now resolve per-portal via new
  `profilePath`/`settingsPath` shell params.
- **R2.3 (orphaned routes):** given a home via a "More" section appended to the profile
  `PopupMenuButton`, built from portal-specific `moreItems` lists (7 routes: onboarding/
  shortlists/applications/team for brand, onboarding/kyc/applications for creator).
  Placement is still a reasonable-default guess, not confirmed with product.
- **R2.4 (dashboards):** both screens now bind their remaining figures to
  `state.brand`/`state.profile`. Fabricated trend percentages and two unbacked stat cards
  (Total Followers, Brand Collabs) were dropped rather than left hardcoded — replaced with
  fields that actually exist (Pending Content, Invitations). Creator profile card shows
  the real session name; category/location were dropped (no backing field without a
  separate influencer-profile fetch — flagged in a code comment, not silently faked).
- **R2.5 (Collabify branding) / font routing (part of R2.8):** found already fully fixed
  by the time this session ran — another stale-snapshot case. Verified with a fresh
  `grep`, zero hits.
- **R2.6 (money units):** **not resolved** — `ImMoneyText.fromMajor` still does client-side
  `(majorUnits * 100).round()`. Still needs the product/eng call the original plan asked for.
- **R2.7 (design-system cleanup):** all sub-items closed — `PortalThemeExtension`'s dead
  `sidebarBg/Fg/Active` fields removed (kept `primary`/`primaryPressed`, still consumed by
  `im_stepper.dart`); all 16 raw hex literals replaced with new named tokens; `ImKpiCard`
  now forwards an `elevation` opt-out; all 44 golden-failure artifacts deleted from disk
  and the git index.
- **R2.8 (remaining branding/assets):** `web/index.html` and `web/manifest.json` fixed
  (title, description, `lang`, `theme-color`). Root README (nested clone) rewritten for
  `apps/monk`. The two genuinely unguarded `NetworkImage` sites (brand campaign-card logo,
  creator profile avatar) hardened. **Not done:** 13 remaining Unsplash hotlinks (they
  route through the already-hardened `ImAvatarStack`, so they're safe, just not local) and
  bundling fonts as local assets — both need real asset files this session couldn't produce.
- **R2.9 (tests):** **not done.** Ground zero, same as round 1. No longer blocked, though —
  the shell/dashboard behavior it should assert against is now correct.

`flutter analyze --no-pub`: 0 errors, 12 pre-existing info lints (unchanged).
`flutter test`: 174/174 passing after every change in this pass.

---

## Context

Round 1 of the remediation plan (Phases 0–5, full text preserved below the validation
report) was implemented on `feature/gemini-ui-redesign` in the nested clone at
`docs/gemini_design_opinion/monk-frontend/`. I validated the actual code against every
item in that plan using four read-only exploration passes (Phase 0, Phase 1, Phase 2+3,
Phase 4+5), each reading the real files rather than trusting the task tracker.

**Verdict: substantial progress, but the build is still broken and two blockers are only
half-fixed.** Of ~45 checked items: **~19 DONE**, **~14 PARTIALLY DONE**, **~11 NOT DONE**,
plus one **regression** (the fork deletion is uncommitted — `git checkout -- apps/web`
would silently undo Phase 0's biggest structural change) and one **new bug introduced by
the fix itself** (§P0-B below).

This document is the round-2 task list: close the remaining gaps. It does not repeat
round-1 items that are confirmed DONE.

---

## Validation Report (evidence)

### Phase 0 — Fork collapse / build

| Item | Status | Evidence |
|---|---|---|
| Delete `apps/web` | ⚠️ **UNCOMMITTED** | Gone from disk, but `git status` shows all 403 files as unstaged ` D` deletions. `git checkout -- apps/web` restores it in full. Not a durable retirement. |
| Port `mock_config.dart` / `im_platform_icon.dart` | ✅ DONE | Both exist; export added to `widgets.dart`. |
| `ImSpacing.space2`/`space6` | ✅ DONE | `tokens.dart:75,77`. |
| `ai_side_panel.dart` ImToast API | ✅ DONE | `message:`/`tone: ImToastTone.danger` at lines 46-56. |
| `schedule_publish_dialog.dart` `hint:` | ✅ DONE | Line 227-230. |
| `recommendations_rail.dart` ImMoneyText | ⚠️ **Open question answered badly** | Added `ImMoneyText.fromMajor({required double majorUnits, ...}) : minorUnits = (majorUnits * 100).round()` (`im_money_text.dart:14-19`). The plan explicitly said *"if it converts inline `(*100).round()`, that contradicts the widget's contract... do not silently multiply"* — this is exactly that, just moved into a named constructor. The domain entity `Recommendation.estimatedBudget` is still `double?` major units. Cosmetic naming, not a fix. |
| pubspec rename to `monk`, no `monk_web` imports | ✅ DONE | |
| `web-ci.yml` repointed to `apps/monk` | ✅ DONE (file not renamed) | Still named `web-ci.yml`, but paths/working-directory all say `apps/monk`. Cosmetic, low priority. |
| Root `README.md` updated | ❌ **NOT DONE** | Still documents only `apps/web`, references the now-deleted `apps/web/README.md`. |
| `flutter analyze --no-pub` = 0 errors | ✅ **DONE (re-verified live)** | Re-ran during round-2 execution: **0 errors, 12 info-level lints only.** The validation agent's report of 4 `isDesktop` errors was stale — the working tree was still being edited when that pass ran. Confirmed current state directly. |

### Phase 1 — Design system

| Item | Status | Evidence |
|---|---|---|
| `borderStrong` token + input borders | ✅ DONE | `tokens.dart:25`, `app_theme.dart:80,84`. `ImBorders.card` still `ink300`. `dividerColor` correctly re-tinted (`app_theme.dart:70`). |
| `danger600`/`danger100` off pink | ✅ DONE | Now `#DC2626`/`#FEE2E2`, no collision with `secondary600`. |
| `im_button.dart` hardcoded primary → theme | ✅ DONE | Lines 57, 84 now use `Theme.of(context).colorScheme.primary`. |
| `PortalThemeExtension` fate decided | ❌ **STILL HALF-WIRED** | One consumer only (`im_stepper.dart:29`). `portal_shell.dart` has zero references to it — admin dark-sidebar was not restored through this mechanism, and the extension was not removed either. Plan explicitly said *"do not leave it half-wired."* |
| 14 raw hex literals moved to tokens | ❌ **NOT DONE — grew to 16** | `status_colors.dart:65` (1), `im_rank_badge.dart:23,26,29` (3), `login_screen.dart:108`, `register_screen.dart:106` (1 each), `brand_dashboard_screen.dart:302,324` (2), `creator_dashboard_screen.dart` (8). `ImColors.onGradient90/80/60` tokens were added in `tokens.dart:27-29` but the screens still use the raw literal instead of referencing them. |
| `coral500`/`coral600` alias inversion | ✅ DONE | Correctly swapped. |
| `ImShadows.card` blur 40→24px | ✅ DONE | `tokens.dart:110-116`. |
| `ImCard` no-shadow opt-out used by `ImKpiCard` | ❌ **NOT DONE** | Opt-out mechanism (`elevation:` param) exists but is used **nowhere** in the codebase, including `ImKpiCard` itself. |
| Golden failure artifacts (44) deleted + gitignored | ⚠️ **4 of 44** | `.gitignore` entry added (done). Only the 4 `manager_context_bar_*` artifacts were removed; the other 40 (im_button/im_card/im_status_chip/im_stepper) are still tracked, just modified in place — not deleted. |
| `manager_context_bar` golden regenerated | ✅ DONE | PNG changed 3977→4168 bytes, consistent with regeneration. Other components' goldens untouched (fine, they weren't failing). |

### Phase 2 — Portal shell

| Item | Status | Evidence |
|---|---|---|
| Bottom-nav crash (manager) | ❌ **NOT FIXED — relocated, still crashes** | `onTap` is now bounds-checked (`if (i < items.length)`), but `ImBottomNavBar` still hard-asserts and indexes exactly 4 items (`im_bottom_nav_bar.dart:25`, `_buildNavItem(context,3)`). The manager portal builds a 3-item list and passes it straight in — this now fails the assert at build time (or throws `RangeError` on `items[3]` in release), a **render-time** crash instead of the original **tap-time** crash. Worse: it now always crashes for managers instead of only on one tap. |
| FAB destination per portal | ✅ DONE | `fabPath` per shell: `/b/campaigns/new`, `/c/marketplace`, `/a/dashboard`. |
| Real session identity | ✅ DONE | Reads `SessionCubit`, no more `'LuxeGlow'`/`'Ananya Sharma'` literals in the shell header. |
| Notification badge `\|\| true` bug | ✅ DONE | Bug removed, badge driven by real `NotificationsCubit` unread count. |
| Dead search/notifications/messages icons | ❌ **NOT DONE** | All three still `onPressed: () {}` (lines 263, 273, 302). |
| Compact-width header overflow | ✅ DONE | `isCompact` branch collapses wordmark, pills, icons, profile text. |
| Nav IA label/route mismatches (3) | ✅ DONE | Brand Briefs/Invoices, Creator Referrals all repointed correctly. |
| 11 orphaned routes given a home | ❌ **NOT DONE** | No "More" menu or drawer exists. `PopupMenuButton` still only has 3 items (profile/settings/logout), and **both are portal-blind**: `'profile'` always goes to `/c/dashboard`, `'settings'` always goes to `/a/settings/sessions`, regardless of which portal is active — a **new bug**, not in the original plan. Orphaned: `/b/onboarding`, `/b/shortlists`, `/b/applications`, `/b/settings/company`, `/b/settings/team`, `/c/onboarding`, `/c/settings/kyc`, `/c/applications`, `/c/settings/access` (9 of the 11 confirmed still unreachable). |

### Phase 3 — Dashboards

| Item | Status | Evidence |
|---|---|---|
| `brand_dashboard_screen.dart` reads `state.brand` | ⚠️ **PARTIAL — 1 of 5 KPIs bound** | Greeting name now real (`d?.brandId ?? 'Brand'`), but `'Allocated across 12 active campaigns'` and other KPI numbers (`48`, `4.2M`, `5.7%`) are still literal. Only `totalCampaigns` is bound. |
| `creator_dashboard_screen.dart` reads `state.profile` | ⚠️ **PARTIAL — profile fetched but never rendered** | `loadProfile()` is called and `state.profile` gates the loading skeleton, but the profile card still hardcodes `'Ananya Sharma ✔'`, `'Lifestyle & Beauty Creator'`, `'Mumbai, India'` and the flagged literal `'From 5 active brand collaborations'` verbatim. Stat cards (125,400 / 2.3M / 8.7% / 32) are also untouched literals. |
| Loading skeleton branch restored (both) | ✅ DONE | `if (state.loading && state.brand/profile == null)` present on both. |
| Manager dashboard unaffected / reference correct | ✅ DONE | `_ManagerBody` fully bound to `state.manager` — this is the pattern brand/creator still need to match. |

### Phase 4 — Branding, assets, fonts

| Item | Status | Evidence |
|---|---|---|
| Remove "Collabify" branding | ⚠️ **PARTIAL — shell fixed, auth screens not** | `portal_shell.dart` now correctly shows `MonkLogo`/"Influencers Monk". `login_screen.dart:73,105,200` and `register_screen.dart:71,103,196` **still say "Collabify"** — `MonkLogo` was added alongside the old strings, not instead of them. The `∞` glyph also still renders at `login_screen.dart:68` and `register_screen.dart:66`. |
| Replace Unsplash hotlinks (18) | ❌ **NOT DONE** | 16 remain: `recommendations_rail.dart:180`, `creator_dashboard_screen.dart` (5), `brand_dashboard_screen.dart` (5), `register_screen.dart` (3), `login_screen.dart` (3). |
| Harden `ImAvatarStack` | ✅ DONE | `errorBuilder` added; overflow capped at `99+`. |
| Route script font through `greetingScript()` | ⚠️ **PARTIAL — 2 of 4** | Both dashboards fixed; `login_screen.dart:88` and `register_screen.dart:86` still use raw `fontFamily: 'Caveat'`. |
| Bundle fonts locally | ❌ **NOT DONE** | No `fonts:` section in `pubspec.yaml`; `typography.dart` still calls `GoogleFonts.interTextTheme()/baloo2TextTheme()/caveat()/baloo2()` at runtime. |
| Fix `web/index.html` | ❌ **NOT DONE** | Still `<title>monk</title>` boilerplate-adjacent, generic meta description, no `lang` attribute, no `theme-color`. |

### Phase 5 — Tests and hygiene

| Item | Status | Evidence |
|---|---|---|
| 5 new widget test files | ❌ **NOT DONE** | `test/core/widgets/` doesn't exist. None of the 5 files exist anywhere in the repo. |
| Shell routing table test | ❌ **NOT DONE** | Only `test/router/guards_test.dart` exists (RBAC redirects) — nothing tests bottom-nav index→route or the manager-portal crash. |
| Golden coverage for 5 new components | ❌ **NOT DONE** | `im_widgets_golden_test.dart` still only covers `ImButton`/`ImCard`/`ImStatusChip`. |
| Contrast assertion tests | ❌ **NOT DONE** | No matches anywhere in `test/`. |
| `TASKS.md` corrected/ticked | ❌ **NOT DONE** | Still all `- [ ]` unchecked; describes paths (`desktop_top_nav.dart`, mobile shell) that don't match what was actually built. |

---

## Round 2 Task List

### R2.0 — Build gate ✅ already clean, commit is the only remaining gap
`flutter analyze --no-pub` is 0 errors / 12 info lints as of live re-verification — no code
fix needed here. What's still open: **nothing from round 1 has been committed** — `git log`
still ends at `72ec453`/`3d631b5` (pre-redesign), and `git status` shows 403 unstaged
deletions under `apps/web` plus 123 modified/added/deleted files under `apps/monk`. A stray
`git checkout`/`reset` right now would silently destroy all of round 1's work. Do not commit
without explicit user go-ahead — flag it once the round-2 fixes below land, and let the user
decide the commit boundary (round 1 + round 2 together, or split).

### R2.1 — Fix the bottom-nav crash for real
`ImBottomNavBar` hard-requires 4 items via both an assert and unconditional `_buildNavItem(context, 3)`
calls. Bounds-checking `onTap` didn't fix this — the widget still renders `items[3]` on build.
Either:
(a) pad the manager's 3-item list to 4 (e.g. a disabled/placeholder slot), or
(b) make `ImBottomNavBar` genuinely variadic (2–5 items, FAB always centered), or
(c) give the manager portal a different nav widget entirely.
Pick (b) unless there's a strong reason not to — it matches what the original plan asked for
("handle 3/5-item navs") rather than papering over a fixed-4 widget.

### R2.2 — Fix the portal-blind profile/settings menu (new bug)
`PopupMenuButton`'s `'profile'` and `'settings'` actions are hardcoded to `/c/dashboard` and
`/a/settings/sessions` regardless of active portal. Derive both routes from the current portal
prefix (`/b`, `/c`, `/a`) the same way `fabPath` already does per-shell.

### R2.3 — Give the 9 remaining orphaned routes a home
Per the original plan's suggested default: Settings/KYC/Access/Team/Company into the profile
menu, the rest behind a "More" destination. Still flagged as needing product sign-off on the
exact placement — build the mechanism, confirm placement before shipping.

### R2.4 — Finish reconnecting the dashboards to live data
- `brand_dashboard_screen.dart`: bind the remaining 4 KPI figures (currently `48`, `4.2M`,
  `5.7%`, and the `'Allocated across 12 active campaigns'` caption) to `state.brand` fields,
  extending the entity/mock seed if a field doesn't exist yet.
- `creator_dashboard_screen.dart`: `_buildCreatorProfileCard` and the 4 stat cards
  (125,400 / 2.3M / 8.7% / 32) need to actually read `state.profile` — it's fetched but
  currently unused in the render body. Use `_ManagerBody`'s binding as the template.

### R2.5 — Finish removing Collabify branding
`login_screen.dart` and `register_screen.dart` still say "Collabify" in 3 places each and
render the `∞` glyph. `portal_shell.dart` shows the correct pattern to copy.

### R2.6 — Resolve the money-units shim properly
`ImMoneyText.fromMajor` still does client-side `(majorUnits * 100).round()`, which the plan
called out as contradicting the widget's "no client-side fee math" contract. Either:
(a) change `Recommendation.estimatedBudget` to `int estimatedBudgetMinor` end-to-end
(entity + mock seed + any API mapping), or
(b) get explicit product/eng sign-off that client-side rounding is acceptable here and
document why in the widget's doc comment.
Don't leave it as an unremarked-upon named constructor.

### R2.7 — Remaining Phase 1 cleanup
- Decide `PortalThemeExtension`'s fate (restore admin dark-sidebar consumer, or delete the
  extension + `sidebarBg/Fg/Active` + `ImLayout.sidebarWidth`). Still undecided from round 1.
- Move the 16 raw hex literals (now including the `onGradient*` duplicates) onto the tokens
  that already exist for them.
- Wire `ImKpiCard` to pass `elevation: const []` so nested cards don't double-shadow.
- Delete the remaining 40 golden-failure artifacts under `test/goldens/failures/` (already
  gitignored going forward, but still tracked from before).

### R2.8 — Remaining Phase 4 cleanup
- Replace the 16 remaining Unsplash hotlinks with seeded local assets.
- Fix the last 2 raw-`Caveat` sites (`login_screen.dart:88`, `register_screen.dart:86`).
- Bundle Inter/Baloo2/Caveat as local font assets instead of runtime `google_fonts` calls.
- Fix `web/index.html` (`<title>`, meta description, `lang`, `theme-color`).
- Update root `README.md` to describe `apps/monk` (and drop the dead `apps/web/README.md` reference).

### R2.9 — Tests (all still ground-zero from round 1)
- 5 new widget test files under `test/core/widgets/`.
- Shell routing table test (bottom-nav index→route per portal; manager must not crash;
  FAB destination matches portal) — this is the regression guard for R2.1/R2.2.
- Golden coverage for the 5 new components across 3 portal themes.
- Contrast assertions (`borderStrong` vs `surfaceCard` ≥ 3:1; `danger600` vs `secondary600`).
- Correct and tick `TASKS.md` to match what's actually built.

---

## Verification (unchanged from round 1)

```bash
cd docs/gemini_design_opinion/monk-frontend/apps/monk
flutter analyze --no-pub     # 0 errors confirmed; keep it that way after each fix below
flutter test                 # all green, incl. regenerated goldens
flutter run -d chrome
```

Manual pass per portal (brand / creator / manager / admin) — same 7-step checklist as round 1,
with special attention to: manager bottom nav (still crashes), profile/settings menu routing
(new bug), and dashboard figures changing when mock seed values change.

## Open questions carried forward

- **R2.3 nav IA placement** — still needs product sign-off.
- **R2.6 money units** — still needs an engineering call on which side changes.
- **R2.7 `PortalThemeExtension`** — still needs a decision on admin dark-sidebar treatment.
- **`status_colors.dart` `revisionRequested`** severity — not re-checked this round, carry
  forward from round 1 if still unresolved.

---

<details>
<summary>Round 1 plan (original, for reference — collapsed)</summary>

See `docs/gemini_design_opinion/REMEDIATION_PLAN.md` in the project workspace for the full
original Phase 0–5 plan text this validation was checked against.

</details>
