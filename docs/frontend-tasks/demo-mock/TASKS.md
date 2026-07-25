# Tasks: Add Mock Mode to `apps/monk`

**Plan:** approved (session plan.md)  
**Target app:** `apps/monk`  
**Source of truth:** current `apps/web/lib/core/mock/**` working tree (not an old commit alone)  
**Related:** `docs/mock-mode-audit.md`  
**Status:** PR1 complete (phases 0–I)  

**Done when:**

```bash
cd apps/monk
flutter run -d chrome --dart-define=USE_MOCKS=true --dart-define=MOCK_LATENCY_MS=150
```

…shows persona selector, runs offline with all 29 mock repos, short usernames work, B1/B2–B4/N7 correct.

---

## Conventions

- Mark tasks `[x]` when done.
- Do not scatter `useMocks` outside DI + login chrome.
- Skip / do not port `mock_config.dart` (thin wrapper).
- Prefer extracted DI registrars over a mega `injection.dart`.
- Personas (canonical):

| Label | Username | Password | Landing |
|---|---|---|---|
| Creator (Arjun) | `creator` | `123456` | `/c/dashboard` |
| Brand (Priya) | `brand` | `123456` | `/b/dashboard` |
| Manager (Meera) | `manager` | `123456` | `/c/roster` |
| Admin | `admin` | `123456` | `/a/dashboard` |
| Agency (Alex) | `agency` | `123456` | `/a/agency/briefs` |
| Fresh Brand | `newbrand` | `123456` | `/b/onboarding` |
| Fresh Creator | `newcreator` | `123456` | `/c/onboarding` |

Legacy `demo.*@influencersmonk.local` / first-name aliases must still resolve via `MockSeedStore`.

---

## Phase 0 — Freeze & inventory

- [x] **T0.1** Confirm `apps/monk/lib/core/mock/` is still absent.
- [x] **T0.2** Inventory `apps/web/lib/core/mock/**` (expect ~37 dart files). Note any uncommitted WIP (short usernames, B1, aliases).
- [x] **T0.3** Verify domain `*_repository.dart` interfaces match between web and monk (0 content diffs).
- [x] **T0.4** Confirm monk `AppConfig` has no `useMocks` / `mockLatencyMs` yet.
- [x] **T0.5** Confirm monk lacks onboarding `justCompleted` (N7 still open on monk).
- [x] **T0.6** Note monk HTTP DI missing `ReferralsRepository` + `AnalyticsRepository`.

**Exit:** freeze notes written (this file or PR description); safe to copy.

---

## Phase A — Config flag

**File:** `apps/monk/lib/core/network/api_client_factory.dart`

- [x] **T-A.1** Add fields to `AppConfig`:
  - `useMocks` (default `false`)
  - `mockLatencyMs` (default `150`)
- [x] **T-A.2** Wire `fromEnvironment()`:
  - `bool.fromEnvironment('USE_MOCKS', defaultValue: false)`
  - `int.fromEnvironment('MOCK_LATENCY_MS', defaultValue: 150)`
- [x] **T-A.3** Pass both through the `AppConfig` constructor / `const` return.

**Acceptance:**

- No defines → `useMocks == false`.
- `--dart-define=USE_MOCKS=true` → `useMocks == true`.

---

## Phase B — Copy mock layer

**Source:** `apps/web/lib/core/mock/**` (working tree)  
**Dest:** `apps/monk/lib/core/mock/**`

- [x] **T-B.1** Create `apps/monk/lib/core/mock/` tree.
- [x] **T-B.2** Copy core:
  - [ ] `mock_ids.dart` (short usernames + `contactEmail*` + `demoPassword`)
  - [ ] `mock_seed_store.dart` (`_emailAliases`, local-part resolution)
  - [ ] **Skip** `mock_config.dart` (or delete after copy)
- [x] **T-B.3** Copy all seed files:
  - [ ] `seed/demo_accounts.dart`
  - [ ] `seed/seed_profiles.dart`
  - [ ] `seed/seed_marketplace.dart`
  - [ ] `seed/seed_fulfillment.dart`
  - [ ] `seed/seed_money.dart` (will fix in Phase C)
  - [ ] `seed/seed_platform.dart`
- [x] **T-B.4** Copy all 29 mock repositories under `repositories/`:
  - [ ] `mock_auth_repository.dart`
  - [ ] `mock_influencer_repository.dart`
  - [ ] `mock_brand_repository.dart`
  - [ ] `mock_kyc_repository.dart`
  - [ ] `mock_manager_repository.dart`
  - [ ] `mock_discovery_repository.dart`
  - [ ] `mock_campaign_repository.dart`
  - [ ] `mock_brief_repository.dart`
  - [ ] `mock_marketplace_repository.dart`
  - [ ] `mock_negotiation_repository.dart`
  - [ ] `mock_contract_repository.dart`
  - [ ] `mock_licensing_repository.dart`
  - [ ] `mock_dispute_repository.dart`
  - [ ] `mock_barter_repository.dart`
  - [ ] `mock_content_repository.dart`
  - [ ] `mock_publish_repository.dart`
  - [ ] `mock_payment_repository.dart`
  - [ ] `mock_dashboard_repository.dart`
  - [ ] `mock_review_repository.dart`
  - [ ] `mock_agency_repository.dart`
  - [ ] `mock_chat_repository.dart`
  - [ ] `mock_notification_preferences_repository.dart`
  - [ ] `mock_ai_repository.dart`
  - [ ] `mock_fraud_repository.dart`
  - [ ] `mock_billing_repository.dart`
  - [ ] `mock_recommendations_repository.dart`
  - [ ] `mock_referrals_repository.dart`
  - [ ] `mock_analytics_repository.dart`
- [x] **T-B.5** Spot-check imports resolve under monk (`features/...`, `package:monk_shared/...`).
- [x] **T-B.6** Verify B1 after copy: Arjun `influencerOnboardingComplete: true` matches seeded `OnboardingStatus(completed: true)`.

**Acceptance:** tree present; no monk-only widgets overwritten.

---

## Phase C — Seed contract fixes (B2 / B3 / B4)

**Primary file:** `apps/monk/lib/core/mock/seed/seed_money.dart`  
**Consumer:** `mock_payment_repository.dart`  
**Also check:** dashboard seed in `seed_profiles.dart` / platform seeds for earnings figures

### B2 — Earnings bag

- [x] **T-C.1** Stop writing earnings via `store.putAll('earnings', [...])` (collections).
- [x] **T-C.2** Write `store.singles['earnings'] = <String, Earnings>{ MockIds.influencer1: Earnings(...) }` matching `_earningsMap()`.

### B3 — Payouts shape

- [x] **T-C.3** Seed payouts as map rows: `{ 'profileId': MockIds.influencer1, 'request': PayoutRequest(...) }` (not bare `PayoutRequest`).
- [x] **T-C.4** Confirm `confirmPayout` can find `payout-demo-2` + token `mock-payout-confirm-token`.
- [x] **T-C.5** If UI needs listing and domain allows, add `listPayouts` on mock (only if interface/UI requires).

### B4 — Single numberset

- [x] **T-C.6** Pick one canonical earnings triple (pending / available / withdrawn) and document in `seed_money.dart` header comment.
- [x] **T-C.7** Align profile dashboard seed + `seed_money` + `_ensureFixtures` fallbacks to that set.

### B8 decision (document or fix)

- [x] **T-C.8** Either:
  - (a) document `newcreator` as onboarding-only, **or**
  - (b) assign a real `profileId` after mock onboarding complete and seed minimal rows.

**Optional same change on web:**

- [x] **T-C.9** Push B2–B4 fixes back to `apps/web/lib/core/mock/seed/seed_money.dart` so source stays honest.

**Acceptance:** Earnings screen shows seeded figures; dashboard agrees; payout confirm works for seeded owner-confirm row.

---

## Phase D — DI wiring

### Extract registrars

- [x] **T-D.1** Create `apps/monk/lib/core/di/register_mock_repositories.dart`
  - Signature e.g. `void registerMockRepositories(GetIt getIt, {required MockSeedStore store, required AppConfig config})`
  - Register `MockSeedStore` singleton
  - Register all **29** mock repository lazy singletons (see list in Phase B)
- [x] **T-D.2** Create `apps/monk/lib/core/di/register_http_repositories.dart`
  - Move existing HTTP/data-source registrations from `injection.dart`
  - **Add missing:**
    - [ ] `AnalyticsRemoteDataSource` + `AnalyticsRepository` → `AnalyticsRepositoryImpl`
    - [ ] `ReferralsRepository` → `ReferralsRepositoryImpl`
    - [ ] `ReferralRewardsBloc` factory if GetIt-resolved anywhere

### Orchestrator

- [x] **T-D.3** Slim `apps/monk/lib/core/di/injection.dart`:
  1. Register core: `AppConfig`, prefs, `TokenStore`, `SessionCubit`, `NotificationsCubit`, `MonkApiClient`
  2. `if (appConfig.useMocks) { store = MockSeedStore(...)..initialize(); registerMock... } else { registerHttp... }`
  3. Shared bloc factories (`AuthBloc`, `ChatBloc`, `AiBloc`, `FraudBloc`, `BillingBloc`, `RecommendationsBloc`, `AgencyConsoleBloc`, `NotificationPreferencesBloc`, `SchedulePublishBloc`, `ReferralRewardsBloc`, …)
  4. `await session.hydrate()`
- [x] **T-D.4** Keep `injection.dart` scannable (orchestration only; avoid 400-line paste of web).
- [x] **T-D.5** Ensure mock path does **not** skip AI/fraud/billing — mock repos exist for all of them.

**Acceptance:**

- `useMocks=true` → `getIt<AuthRepository>()` is mock; same for all 29.
- `useMocks=false` → HTTP path works; referrals/analytics resolvable.

---

## Phase E — Login persona UI

**Files:**

- `apps/monk/lib/features/auth/presentation/screens/login_screen.dart`
- `apps/monk/lib/features/auth/presentation/widgets/mock_demo_persona_selector.dart` (preferred extract)

- [x] **T-E.1** Create `MockDemoPersonaSelector` widget:
  - Dropdown of 7 personas using `MockIds.email*` short names
  - On change: fill email + `MockIds.demoPassword`
  - Helper text listing short names + shared password
- [x] **T-E.2** In `LoginScreen`:
  - Keep existing **MonkLogo** + layout
  - `final useMocks = getIt<AppConfig>().useMocks`
  - `if (useMocks) MockDemoPersonaSelector(...)` above email field
- [x] **T-E.3** When `useMocks == false`, no selector chrome.

**Acceptance:** mock off = current login; mock on = selector fills `creator` / `123456` etc. and sign-in works offline.

---

## Phase F — Co-port N7 (onboarding `justCompleted`)

**Source (web WIP):**

- `features/onboarding_influencer/presentation/bloc/onboarding_state.dart`
- `.../bloc/onboarding_bloc.dart`
- `.../screens/onboarding_wizard_screen.dart`
- `test/features/onboarding/onboarding_bloc_test.dart` (if present on web)

**Dest:** same paths under `apps/monk/`

- [x] **T-F.1** Add `justCompleted` to `OnboardingState` (+ `copyWith` / props).
- [x] **T-F.2** Bloc: already-complete profile emits completed **without** `justCompleted`; finish flow sets `justCompleted: true`.
- [x] **T-F.3** Wizard listener: redirect only when `phase == completed && justCompleted`.
- [x] **T-F.4** Wizard body: already-complete → `_CompletedSummary` (verification chip + go to dashboard).
- [x] **T-F.5** Port / update unit tests for the new flag.

**Acceptance:** open `/c/onboarding` for complete creator shows summary, no bounce loop.

---

## Phase G — Documentation

- [x] **T-G.1** Replace boilerplate in `apps/monk/README.md` with:
  - Offline demo command (`USE_MOCKS`, `MOCK_LATENCY_MS`)
  - API mode command (`API_BASE_URL`)
  - Personas table + password `123456`
  - Alias note (legacy emails / first names)
  - Caveats: B9 memory reset on reload; B10 multi-password accept
- [x] **T-G.2** Update `docs/mock-mode-audit.md` §R1: monk now hosts offline mock (or dual until web retired).
- [x] **T-G.3** Optional: VS Code / launch.json config “Monk · Mock Mode”.
- [x] **T-G.4** Keep this `TASKS.md` checkboxes in sync as work lands.

---

## Phase H — Tests (minimum)

**Dir:** `apps/monk/test/core/mock/`

- [x] **T-H.1** `mock_auth_repository_test.dart` — login `creator` success; bad password fails; session flags for Arjun vs `newcreator`.
- [x] **T-H.2** `mock_seed_store_alias_test.dart` — short names + legacy email aliases + local-part resolve.
- [x] **T-H.3** `mock_payment_earnings_test.dart` — **B2 regression**: seeded earnings readable via payment repo (not fixture fallback only).
- [x] **T-H.4** `mock_negotiation_repository_test.dart` — accept creates collab; max-rounds / supersede if easy to assert.
- [x] **T-H.5** DI smoke test — `configureDependencies(config: AppConfig(..., useMocks: true))` registers mock auth without throw (`SharedPreferences.setMockInitialValues({})`).

**Acceptance:** `cd apps/monk && flutter test` green for new files.

---

## Phase I — Verification

- [x] **T-I.1** `cd apps/monk && flutter pub get`
- [x] **T-I.2** `flutter analyze` — no new errors
- [x] **T-I.3** `flutter test`
- [x] **T-I.4** Manual: `flutter run -d chrome --dart-define=USE_MOCKS=true`
  - [ ] `creator` → dashboard, marketplace data, earnings == dashboard
  - [ ] `brand` → brand dashboard / applications
  - [ ] `manager` → roster + context bar
  - [ ] `admin` → admin dashboard
  - [ ] `agency` → agency briefs
  - [ ] `newbrand` → `/b/onboarding`
  - [ ] `newcreator` → `/c/onboarding`; re-open shows summary (N7)
- [x] **T-I.5** Manual regression: run **without** `USE_MOCKS` — HTTP wiring still works; no crash on GetIt referrals/analytics.

---

## Out of scope (follow-up tasks — do not block PR1)

Track here so nothing is forgotten; implement in later PRs.

### PR2 — deeper tests

- [ ] **F-2.1** Broader negotiation / marketplace / payment state-machine coverage

### PR3 — demo polish

- [ ] **F-3.1** **B5** Honour `?from=` on login; fix hydrate race if needed
- [ ] **F-3.2** **B7** Wire notification badge / `setStubUnread` from seed
- [ ] **F-3.3** **B6** Delete dead manager guard block if present in monk
- [ ] **F-3.4** **B8** Full post-onboarding seed for `newcreator` (if deferred in C)
- [ ] **F-3.5** **N1** Converted application → collaboration/contract deep links
- [ ] **F-3.6** **N2–N4** Nav entries / mount orphan panels (chat, billing, AI rail, …)

### PR4 — repo health

- [ ] **F-4.1** CI workflow path filter for `apps/monk`
- [ ] **F-4.2** Dual-app policy: monk = offline demo host; reduce web mock drift
- [ ] **F-4.3** Optional later: extract domain + mock package (only after domain leaves app)

---

## Suggested PR1 file checklist

### Create

```
apps/monk/lib/core/mock/**                                    # from web WIP
apps/monk/lib/core/di/register_mock_repositories.dart
apps/monk/lib/core/di/register_http_repositories.dart
apps/monk/lib/features/auth/presentation/widgets/mock_demo_persona_selector.dart
apps/monk/test/core/mock/*.dart
```

### Modify

```
apps/monk/lib/core/network/api_client_factory.dart
apps/monk/lib/core/di/injection.dart
apps/monk/lib/features/auth/presentation/screens/login_screen.dart
apps/monk/lib/features/onboarding_influencer/presentation/bloc/onboarding_state.dart
apps/monk/lib/features/onboarding_influencer/presentation/bloc/onboarding_bloc.dart
apps/monk/lib/features/onboarding_influencer/presentation/screens/onboarding_wizard_screen.dart
apps/monk/test/features/onboarding/onboarding_bloc_test.dart   # if exists
apps/monk/README.md
docs/mock-mode-audit.md                                       # R1 note
docs/frontend-tasks/demo-mock/TASKS.md                        # this file
```

### Optional same PR

```
apps/web/lib/core/mock/seed/seed_money.dart                   # B2–B4 parity
```

---

## Execution order (strict)

1. Phase 0 inventory  
2. Phase A config  
3. Phase B copy  
4. Phase C seed fixes  
5. Phase D DI  
6. Phase E login  
7. Phase F N7  
8. Phase G docs  
9. Phase H tests  
10. Phase I verify  

Do not start Phase E/F before D compiles. Do not mark Phase I done until persona walk passes.

---

## Progress log

| Date | Note |
|---|---|
| 2026-07-26 | TASKS.md created from approved plan; implementation not started |
| 2026-07-26 | PR1 implemented on apps/monk: mock layer, AppConfig, DI registrars, login selector, B2–B4, N7, README, tests green |
