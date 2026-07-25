# Mock-Mode Audit — Monk Frontend

_Audit date: 2026-07-26 · Commit: `3d631b5` · Scope: `apps/web` offline demo (mock) mode_

## Context

Scope: offline demo ("mock") mode of the Flutter frontend only. Goal was to read the mock
layer, seed data, routing and business logic and report what works, what is broken, and what
is unreachable. Findings below are from static reading of `apps/web` (historically the only mock host).
**Update (2026-07-26):** offline mock mode is now hosted on **`apps/monk`** as well
(see §R1). Prefer `apps/monk` for the offline demo. Nothing was executed at audit time.
The second half is a prioritised fix list if you want the demo to be walkable end-to-end.

---

## 1. How mock mode is wired

| Piece | Location |
|---|---|
| Flag | `AppConfig.useMocks` ← `--dart-define=USE_MOCKS=true` (`core/network/api_client_factory.dart:40`) |
| Latency | `MOCK_LATENCY_MS`, default 150 ms, clamped 0–5000 (`core/mock/mock_config.dart`) |
| Swap point | `configureDependencies()` — one `if (appConfig.useMocks)` branch registers 29 mock repos vs. 33 HTTP repos (`core/di/injection.dart:139`) |
| In-memory DB | `MockSeedStore` — `collections` (lists), `singles` (records), account/token maps |
| Seeds | `seed/demo_accounts • seed_profiles • seed_marketplace • seed_fulfillment • seed_money • seed_platform` (~2 100 lines) |
| Demo UI | Persona dropdown on the login screen, shown only when `useMocks` (`login_screen.dart:160`) |

**Assessment of the design:** clean. Mocks implement the same domain repository interfaces, so
blocs/screens are untouched; `AppConfig` is the single switch; `MockIds` gives stable IDs for
deep links. This is the right shape.

**Run command (not documented anywhere — see §5):**

```bash
cd apps/web
flutter run -d chrome --dart-define=USE_MOCKS=true --dart-define=MOCK_LATENCY_MS=150
```

**Demo personas** (all share password `123456`, defined in `core/mock/mock_ids.dart`):

| Persona | Username | Role | Landing route |
|---|---|---|---|
| Arjun Creator | `creator` | influencer | `/c/dashboard` |
| Priya Brand | `brand` | brand_user | `/b/dashboard` |
| Meera Manager | `manager` | manager | `/c/roster` |
| Demo Admin | `admin` | admin | `/a/dashboard` |
| Alex Agency | `agency` | agency_operator | `/a/agency/briefs` |
| Fresh Brand | `newbrand` | brand_user | `/b/onboarding` |
| Fresh Creator | `newcreator` | influencer | `/c/onboarding` |

The legacy `demo.*@influencersmonk.local` addresses, the first names (`arjun`, `priya`, `meera`,
`alex`) and any `creator@…`-style address still resolve via the alias map in
`MockSeedStore.findAccountByEmail`.

---

## 2. Business logic quality

Genuinely good — the mocks are state machines, not canned JSON:

- **Negotiations** (`mock_negotiation_repository.dart`): round counting, max-rounds guard
  (`MAX_ROUNDS`), pending-offer supersession, accept → creates `CollaborationSnapshot` +
  flips application to `converted`, open/declined/cancelled locking.
- **Marketplace** (`mock_marketplace_repository.dart`): browseable-status filter, duplicate
  application guard (`DUPLICATE_APPLICATION`), closed-campaign guard (`CAMPAIGN_CLOSED`),
  collab-type permission check, cursor pagination, status-transition guards reusing the same
  `canBrandShortlist` / `canWithdraw` entity helpers the real repos use.
- **Payments**: `created → held → released`, refund guards (`ALREADY_RELEASED`), payout
  confirmation token check, `INSUFFICIENT_BALANCE`.
- **Errors**: typed `ValidationFailure` / `ConflictFailure` / `NotFoundFailure` / `AuthFailure`
  with backend-style `errorCode`s, so `ErrorPresenter` behaves as it will in production.
- **Seed graph is coherent**: campaigns in 5 statuses, applications in 6 statuses, a mid-review
  content submission with a failing disclosure check on v1, an accepted contract, a shipped
  barter, a held payment. Good demo material.

---

## 3. Bugs found

**B1 — Arjun's onboarding flag contradicts itself (regression from HEAD). — FIXED.**
`demo_accounts.dart:46` is now `influencerOnboardingComplete: true`, matching the seeded status;
the wizard also no longer redirects on load (see N7). Original finding below.

The last commit set `influencerOnboardingComplete: false` for `demo.creator1` (`demo_accounts.dart:46`),
but `seed_profiles.dart:272` still seeds `OnboardingStatus(profileId: inf-demo-1, completed: true)`.
On login `MockAuthRepository._applyAccountSession` sets the session flag to `false`, then
`AuthBloc._refreshOnboardingFlag()` immediately calls `loadOnboarding()`, finds the seeded
`completed: true` and flips it back. Net effect: the intended "force Arjun through onboarding"
never sticks, and the router bounces `/login → /c/dashboard → /c/onboarding → /c/dashboard`
mid-login. Fix one source of truth, not both.

**B2 — Seeded earnings are dead data (wrong store bag).**
`seed_money.dart:54` writes `store.putAll('earnings', [...])` → `collections['earnings']`.
`MockPaymentRepository._earningsMap()` reads `store.singles['earnings']` → always empty →
falls through to its own `_ensureFixtures` values. The Earnings screen therefore shows
₹12,750 / ₹2,500 / ₹1,000 instead of the seeded ₹21,250 / ₹18,500 / ₹72,000.

**B3 — Seeded payouts are unusable.** `seed_money.dart:64` stores bare `PayoutRequest` objects;
`confirmPayout` only recognises `Map` rows shaped `{'profileId':…, 'request':…}`, and no
`listPayouts` method exists on the repository at all. Both seeded payouts are unreachable and
`payout-demo-2` (the owner-confirmation demo) can never be confirmed.

**B4 — Three different earnings numbers.** `profile_dashboard` single (₹18,500 pending /
₹72,000 released), `seed_money` earnings, and `MockPaymentRepository` fixtures all disagree.
A viewer moving Dashboard → Earnings sees the figures change.

**B5 — Deep-link restore drops the return path.**
`configureDependencies` calls `session.hydrate()` (sets `hydrated: true`) *before* `AuthBloc`
fires `AuthRestoreRequested`, so the `if (!hydrated) return null` gate in `guards.dart:24` never
protects anything. Hard-refreshing `/c/marketplace` shows a login flash, redirects to
`/login?from=%2Fc%2Fmarketplace`, then — because `login_screen.dart:131` ignores `from` and
always uses `roleHomePath()` — lands on the dashboard. The `from` parameter is written but
never read anywhere in the codebase.

**B6 — Dead guard block.** `guards.dart:76-86` — the manager/no-profile branch has an empty
body containing only a comment. It compiles, does nothing, and reads as an implemented rule.

**B7 — Notification badge is permanently 0.** `NotificationsCubit.setStubUnread()` and
`markAllRead()` have zero call sites; the bell icon in `portal_shell.dart:151` is
`onPressed: () {}`.

**B8 — Fresh-creator persona dead-ends.** `demo.creator.fresh` has no `profileId`, so
`_resolveProfileId` falls back to the *user* id (`user-demo-creator-fresh`). After finishing
onboarding, every profile-scoped query (dashboard, marketplace applications, earnings) uses
that id, which matches nothing in the seed graph → empty states everywhere. Onboarding demo
works; nothing after it does.

**B9 — All demo state is lost on reload.** `MockSeedStore` is pure memory; only tokens go to
`SharedPreferences`. A browser refresh mid-demo silently resets every mutation while keeping
you logged in. Acceptable by design, but undocumented and surprising during a live demo.

**B10 — Password check is effectively bypassed.** `mock_auth_repository.dart:83` accepts the
account password *or* `Password123!` *or* `password` *or* `123456` for any account. Fine for a
demo; worth knowing it means the "wrong password" error path can't be demoed.

---

## 4. Navigation findings

**N1 — The creator can never reach their own fulfilment flow.**
`creator_applications_screen.dart` renders only *Accept invite / Decline / Withdraw / View
campaign*. There is no link to negotiation, contract, content submit, publish or barter. The
seeded `converted` application (`app-demo-5` → `collab-demo-1`, contract accepted, content
mid-review) is reachable only by typing the URL. The brand side has the same gap once an
application flips to `converted`.

**N2 — Whole feature clusters are routed but unreachable.** Registered in `app_router.dart`,
zero `context.go/push` call sites anywhere:

`/b|c|a/chat` · `/b|c/billing` · `/b|c|a/settings/notifications` · `/b|c/settings/data-erasure` ·
`/b|c/licensing/*` · `/b|c/disputes/file/*` · `/b|c/collaborations/:id/review-rating` ·
`/b/collaborations/:id/payments` · `/b|a/contracts/templates` · `/a/disputes` · `/a/referrals` ·
`/a/agency/kanban`

That is roughly a third of the route table only reachable by URL bar.

**N3 — Orphan widgets (built, never mounted).** `AiSidePanel`, `RecommendationsRail`,
`AnalyticsReportsScreen`, `PostMetricsScreen`, `SchedulePublishDialog`, `PublishJobStatusCard`,
`FraudWarningBanner`, `EsignStatusChip`, `ContractAmendmentDialog`,
`LicensingCollaborationTypeSelector`. Their blocs and mock repos are fully wired in DI — the
AI, fraud, recommendations, analytics and scheduled-publish features exist end-to-end but have
no UI entry point. Two of them (`AnalyticsReportsScreen`, `PostMetricsScreen`) are screens with
no route at all.

**N4 — Sidebar nav is thin vs. the route table.** Brand 10 items, Creator 9, Manager 5,
Admin 4 — none expose chat, billing, notification prefs, disputes, licensing or kanban.

**N5 — Chains that *do* work** (verify these in a demo):
Brand: `Applications → Start negotiation → Negotiation → Contract → Barter → Review content`.
Creator: `Marketplace → Detail → Apply → Applications`, and `Content submit → Publish URL`
if entered directly. Admin: `Dashboard → Verification → Detail`, `Dashboard → Agency briefs → Detail`.
Manager: `Roster → select profile → context bar → Exit`.

**N6 — Minor:** an authenticated user hitting `/` gets the marketing landing stub, not their
dashboard (`/` is in the `isPublic` list, so no redirect fires).

**N7 — The Onboarding nav item bounced to the dashboard. — FIXED.**
`OnboardingBloc._onStart` emitted `OnboardingPhase.completed` for an already-complete profile and
the wizard's listener treated any completed phase as "just finished", so `/c/onboarding` could
never be opened once done. `OnboardingState.justCompleted` now gates the redirect, and the wizard
renders a completed summary (verification chip + "Go to dashboard") when opened for review.

---

## 5. Repo-level risks

**R1 — `apps/monk` offline mock host — RESOLVED (2026-07-26).**
`apps/monk` now has `core/mock/**`, `AppConfig.useMocks` / `MOCK_LATENCY_MS`, DI registrars
for 29 mock repos (+ HTTP path includes referrals/analytics), login persona selector, B2–B4
seed money contract, and N7 onboarding `justCompleted`. Prefer:

```bash
cd apps/monk
flutter run -d chrome --dart-define=USE_MOCKS=true --dart-define=MOCK_LATENCY_MS=150
```

Historical note: monk was a fork of web with mock stripped; product work (logo, portal shell,
auth screens) landed on monk while mock lived only on web — dual-app drift risk remains until
web mock is retired or both stay in lockstep. Original finding context:
while HEAD's seed change landed in `apps/web`. The two `lib/` trees already differ in ~20 files.
Mock mode only works in `apps/web`; the app being actively developed cannot run offline.
**This is the highest-impact issue in the repo** — decide which app is canonical before
anything else.

**R2 — CI only covers `apps/web`** (`.github/workflows/web-ci.yml` path filter). `apps/monk`
has no gate.

**R3 — Zero test coverage of the mock layer.** 42 test files, none import `core/mock`. The
mock repos carry real state-machine logic (B1–B4 are exactly the class of bug tests catch).

**R4 — `USE_MOCKS` / `MOCK_LATENCY_MS` are undocumented.** `apps/web/README.md` lists only
`API_BASE_URL`, `ENVIRONMENT`, `SENTRY_DSN`. Nothing in the repo tells a new person how to
start the demo or what the demo passwords are.

---

## 6. Recommended fix order

**Decide first (blocking):** is `apps/monk` or `apps/web` canonical? Either port
`core/mock/` + the `useMocks` DI branch + login persona selector into `apps/monk`, or retire
`apps/monk` and move its logo/shell work into `apps/web`. Everything below should land in
whichever app wins.

1. ~~**B1** — remove the `inf-demo-1` entry from `seed_profiles.dart:272` (or revert the
   `demo_accounts` flag). One source of truth.~~ **Done** — reverted the `demo_accounts` flag;
   `newcreator` remains the walk-the-wizard persona.
2. **N1** — add status-aware actions to `creator_applications_screen.dart` and
   `brand_applications_screen.dart`: on `converted`, link to `/{c|b}/collaborations/<id>/contract`.
   Needs an application→collaboration link; today `CollaborationSnapshot` has neither
   `applicationId` nor `campaignId`, so add one field and set it in
   `MockNegotiationRepository.accept` and `seed_marketplace`.
3. **B2/B3/B4** — make `seed_money` write `singles['earnings']` as `Map<String, Earnings>` and
   `payouts` as the `{'profileId','request'}` row shape; add `listPayouts`; reconcile the three
   earnings figures to one set.
4. **B5** — move `hydrated: true` to after `AuthRestoreRequested` completes, and honour
   `?from=` in the login screen's success listener.
5. **N2/N3** — add nav entries (or dashboard quick-links) for chat, billing, notification prefs,
   disputes and licensing; mount `AiSidePanel` and `RecommendationsRail` in the portal shell;
   route `AnalyticsReportsScreen` and `PostMetricsScreen`. Delete anything you don't want.
6. **R4** — document `USE_MOCKS`, `MOCK_LATENCY_MS`, the seven personas and the `123456`
   password in `apps/web/README.md`.
7. **B6/B7** — delete the dead guard block; wire `setStubUnread` from seeded notifications or
   remove the badge.
8. **R3** — add bloc-level tests over the mock repos for the negotiation and payment state
   machines.
9. **B8/B9** — optional: give `demo.creator.fresh` a real seeded profile id so the post-onboarding
   demo has data; consider persisting `MockSeedStore` to `SharedPreferences` so refresh survives.

## 7. Verification

- `cd apps/web && flutter analyze && flutter test` (baseline before touching anything).
- `flutter run -d chrome --dart-define=USE_MOCKS=true` and walk each persona from the login
  dropdown; confirm Arjun lands on the dashboard (B1), Dashboard and Earnings agree (B2/B4),
  a converted application links into the contract (N1).
- Hard-refresh on `/c/marketplace` while logged in — should land back on `/c/marketplace`, not
  the dashboard (B5).
- Confirm every sidebar item and every dashboard quick-link resolves without hitting `/403`
  or `/404`.
