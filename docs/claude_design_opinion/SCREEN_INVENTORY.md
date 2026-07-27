# Screen Inventory

Companion to [`IMPLEMENTATION_PLAN.md`](./IMPLEMENTATION_PLAN.md) Phases 4–5.

**63 screens** across 29 features, serving **80 routes** in
`apps/monk/lib/core/router/app_router.dart`. Paths below are relative to
`apps/monk/lib/features/`.

## Tiers

| Tier | Meaning | Work |
|---|---|---|
| **1** | Mockup-backed or first-impression | Real composition work against a mockup |
| **2** | High-traffic, dense, or structurally dated | Composition pass — hero/section rhythm, card shapes, empty + loading states |
| **3** | Long-tail settings, admin, wizards | Inherits Phase 1–2 tokens. Smoke-check only. |

Effort is relative (S / M / L), not hours.

---

## Tier 1 — 6 screens

| Screen | Portal | Route | Mockup | Effort |
|---|---|---|---|---|
| `dashboards/…/brand_dashboard_screen.dart` | Brand | `/b/dashboard` | `brand-dashboard.html` | **L** |
| `dashboards/…/creator_dashboard_screen.dart` | Creator | `/c/dashboard` | `creator-dashboard.html` | **L** |
| `campaigns/…/campaign_create_screen.dart` | Brand | `/b/campaigns/new` | `campaign-create.html` | **L** |
| *(compact branch of `core/router/shells/portal_shell.dart`)* | All | — | `creator-mobile.html` | **M** |
| `auth/…/login_screen.dart` | — | `/login` | none | S |
| `auth/…/register_screen.dart` | — | `/register` | none | S |

`campaign_create_screen.dart` is a **visual pass only** — `campaign_form_bloc.dart` state
shape is unaffected.

## Tier 2 — 21 screens

Composition pass. These carry the most traffic after the dashboards, and most predate the
current card language.

| Screen | Portal | Route | Effort | Notes |
|---|---|---|---|---|
| `marketplace/…/marketplace_screen.dart` | Creator | `/c/marketplace` | **L** | Card grid — reuse `im_campaign_carousel_card` |
| `marketplace/…/marketplace_detail_screen.dart` | Creator | `/c/marketplace/:id` | M | Hero + avatar stack |
| `discovery/…/discovery_screen.dart` | Brand | `/b/discover` | **L** | Creator card grid, filters, empty state |
| `discovery/…/shortlists_screen.dart` | Brand | `/b/shortlists` | M | |
| `campaigns/…/campaign_list_screen.dart` | Brand | `/b/campaigns` | M | Status chips throughout |
| `campaigns/…/campaign_detail_screen.dart` | Brand | `/b/campaigns/:id` | **L** | Progress, avatar stack, chart |
| `marketplace/…/brand_applications_screen.dart` | Brand | `/b/applications` | M | |
| `marketplace/…/creator_applications_screen.dart` | Creator | `/c/applications` | M | |
| `payments/…/earnings_screen.dart` | Creator | `/c/earnings` | **L** | `gradientDark` chart panel |
| `payments/…/invoices_screen.dart` | Both | `/b/invoices`, `/c/invoices` | M | Tabular figures, `en_IN` |
| `payments/…/collab_payments_screen.dart` | Brand | `/b/collaborations/:id/payments` | M | |
| `chat/…/chat_thread_screen.dart` | All | `/b/chat`, `/c/chat`, `/a/chat` | M | |
| `negotiations/…/negotiation_screen.dart` | Both | `/b/negotiations/:id`, `/c/…` | M | Consumes `im_bubble_card` — verify recolor |
| `content/…/content_submit_screen.dart` | Creator | `/c/collaborations/:id/content` | M | File uploader |
| `content/…/content_review_screen.dart` | Brand | `/b/collaborations/:id/review` | M | |
| `analytics/…/analytics_reports_screen.dart` | Both | `/c/metrics` | M | Chart spec §11 |
| `analytics/…/post_metrics_screen.dart` | Creator | — | S | |
| `shell_homes/…/admin_dashboard_screen.dart` | Admin | `/a/dashboard` | M | No mockup — follows brand |
| `auth/…/landing_screen.dart` | — | `/` | M | Marketing surface |
| `onboarding_influencer/…/onboarding_wizard_screen.dart` | Creator | `/c/onboarding/:step` | M | Reuses `im_stepper` |
| `onboarding_brand/…/brand_onboarding_screen.dart` | Brand | `/b/onboarding` | M | Reuses `im_stepper` |

## Tier 3 — 36 screens

Inherit Phase 1–2 tokens. Smoke-check that nothing broke; no composition work planned.

**Auth (4)** — `forgot_password_screen`, `reset_password_screen`, `verify_email_screen`,
`sessions_screen` · `/password/forgot`, `/password/reset`, `/*/settings/sessions`

**Settings & profile (8)** — `notification_preferences_screen`, `profile_edit_screen`,
`profile_access_screen`, `connected_accounts_screen`, `company_profile_screen`,
`team_members_screen`, `data_erasure_status_screen`, `kyc_screen`

**Manager (3)** — `manager_roster_screen` (`/c/roster`), `manager_earnings_screen`,
`manager_invite_accept_screen`. The manager context bar is Phase 1 (`warning100`) and is
golden-tested.

**Admin & agency (7)** — `verification_queue_screen`, `verification_detail_screen`,
`agency_kanban_screen`, `agency_briefs_screen`, `admin_referrals_screen` ×2 (see below),
`billing_portal_screen`

**Briefs & contracts (4)** — `brief_create_screen`, `brief_list_screen`, `contract_screen`,
`contract_templates_screen`

**Licensing, disputes, barter, publish (6)** — `licensing_deal_wizard_screen`,
`licensing_grant_delivery_screen`, `dispute_filing_screen`, `barter_screen`,
`publish_url_screen`, `manual_metrics_screen`

**Referrals & reviews (4)** — `referrals_screen`, `referral_rewards_screen` ×2,
`leave_review_screen`

## Housekeeping found while inventorying

Not redesign work, but worth a cleanup PR — flagging rather than silently fixing:

- **Duplicate referral screens.** `referrals/presentation/pages/admin_referrals_screen.dart`
  and `referrals/presentation/screens/admin_referrals_screen.dart` both exist, as do two
  `referral_rewards_screen.dart`. One pair is likely dead. Resolve before styling either,
  or the work gets done twice.
- **`pages/` vs `screens/` is inconsistent** across features (`analytics`, `chat`, `billing`,
  `agency`, `notifications` use `pages/`; everything else uses `screens/`). Cosmetic, but it
  makes the inventory harder to keep accurate.

## Coverage

| Tier | Screens | Share |
|---|---|---|
| 1 | 6 | 10% |
| 2 | 21 | 33% |
| 3 | 36 | 57% |
| **Total** | **63** | |

Just over half the app is expected to need no composition work at all. That ratio is the
plan's main cost control — if Tier 3 screens start needing real work, the token and component
phases didn't do their job, and that's the signal to stop and fix them rather than absorb the
cost 36 times.
