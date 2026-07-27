# Screen Inventory & Redesign Priority

Inventory of presentation screens in `apps/monk` for the Soft Premium UI redesign (`design_context2.md`).  
Priorities: **P0** foundation · **P1** first impression · **P2** core loops · **P3** engagement · **P4** dense/secondary · **P5** mobile/polish.

---

## How to use this inventory

For each screen during implementation:

1. Apply shared tokens/components (automatic after P0).  
2. Fix layout density (padding 24–40, card gaps 24).  
3. Replace spinner-only loading with skeletons where page-level.  
4. Upgrade empty states to illustrated + CTA.  
5. Prefer cards/lists over tables unless Analytics/Finance/Reports.  
6. Match portal tone: creator playful vs brand refined.

**Legend**

| Priority | Meaning |
|---|---|
| P1 | Must look Soft Premium in first stakeholder demo |
| P2 | Core daily workflows |
| P3 | Important but after core loops |
| P4 | Acceptable with token inheritance + light pass |
| — | Mostly inherits; sweep only |

---

## Shells & chrome (P0 / P4)

| Surface | File | Priority | Redesign notes |
|---|---|---|---|
| Brand / Creator / Admin shells | `core/router/shells/portal_shell.dart` | **P0** | Top/floating nav desktop; limited bottom nav + FAB mobile; overflow “More”; search/notif/profile cluster |
| Manager context bar | same file (`ManagerContextBar`) | **P0** | Soft accent bar; clear acting-as copy |
| Page width constraint | shell + new `ImPageScaffold` | **P0** | contentMaxWidth 1450, page padding 40 |

---

## Dashboards (P1)

| Screen | File | Priority | Target composition |
|---|---|---|---|
| Brand dashboard | `features/dashboards/.../brand_dashboard_screen.dart` | **P1** | Hero greeting → campaign overview metrics → matches → spend/ROI → timeline → pending approvals → activity → quick actions |
| Creator dashboard | `features/dashboards/.../creator_dashboard_screen.dart` | **P1** | Hero → creator score → tasks → current campaigns carousel → recommended → earnings → performance → tips |
| Manager dashboard body | inside creator dashboard (`_ManagerBody`) | **P1** | Roster-oriented metrics with refined cards |
| Manual metrics | `.../manual_metrics_screen.dart` | P3 | Form in cards; soft inputs |
| Admin dashboard | `features/shell_homes/.../admin_dashboard_screen.dart` | P2 | Refined admin home; avoid ERP density |

**Current debt:** both brand/creator dashboards are title + `Wrap` of `ImKpiCard` + spinner loading. Highest visual ROI rewrite.

---

## Auth (P1)

| Screen | File | Priority | Notes |
|---|---|---|---|
| Landing | `features/auth/.../landing_screen.dart` | **P1** | Marketing-soft hero, purple CTAs, human imagery |
| Login | `login_screen.dart` | **P1** | Centered card, soft fields, encouraging errors |
| Register | `register_screen.dart` | **P1** | Same system; clear role choice if present |
| Forgot password | `forgot_password_screen.dart` | P2 | Lightweight |
| Reset password | `reset_password_screen.dart` | P2 | Lightweight |
| Verify email | `verify_email_screen.dart` | P2 | Illustrated waiting state |
| Sessions | `sessions_screen.dart` | P3 | Card list of sessions |
| Error screens | `error_screens.dart` | P2 | Friendly, solution-oriented |

---

## Campaigns (P2)

| Screen | File | Priority | Notes |
|---|---|---|---|
| Campaign list | `campaign_list_screen.dart` | **P2** | Card grid/list; status chips; filters as chips |
| Campaign create | `campaign_create_screen.dart` | **P2** | Multi-step + stepper; section cards; optional preview rail |
| Campaign detail | `campaign_detail_screen.dart` | **P2** | Hero summary; tabs as pills; no spreadsheet feel |

---

## Marketplace & discovery (P2)

| Screen | File | Priority | Notes |
|---|---|---|---|
| Marketplace | `marketplace_screen.dart` | **P2** | Large cards, carousels, category chips |
| Marketplace detail | `marketplace_detail_screen.dart` | **P2** | Media-forward, soft CTAs |
| Brand applications | `brand_applications_screen.dart` | **P2** | Applicant cards + chips |
| Creator applications | `creator_applications_screen.dart` | **P2** | Status-forward cards |
| Discovery | `discovery_screen.dart` | **P2** | Creator cards, filters as chips |
| Shortlists | `shortlists_screen.dart` | P3 | Card collections |
| Demographics card widget | `creator_demographics_card.dart` | P3 | Soft metrics |

---

## Earnings, payments, billing (P2–P4)

| Screen | File | Priority | Notes |
|---|---|---|---|
| Earnings | `payments/.../earnings_screen.dart` | **P2** | Large numbers, soft charts, empty illustrated |
| Collab payments | `collab_payments_screen.dart` | P3 | Card timeline preferred over table |
| Invoices | `invoices_screen.dart` | P3 | Finance: table OK if softened |
| Billing portal | `billing/.../billing_portal_screen.dart` | P4 | Plans as cards |
| Manager earnings | `manager/.../manager_earnings_screen.dart` | P3 | Refined metrics |

---

## Onboarding (P3)

| Screen | File | Priority | Notes |
|---|---|---|---|
| Influencer onboarding wizard | `onboarding_wizard_screen.dart` | **P3** | Multi-step, progress, illustration, encouragement |
| Connected accounts | `connected_accounts_screen.dart` | P3 | Platform cards |
| Profile edit | `profile_edit_screen.dart` | P3 | Grouped form sections |
| Referrals (influencer) | `onboarding_influencer/.../referrals_screen.dart` | P3 | Share card |
| Brand onboarding | `brand_onboarding_screen.dart` | **P3** | Same stepper language |
| Company profile | `company_profile_screen.dart` | P3 | Section cards |
| Team members | `team_members_screen.dart` | P3 | People cards |
| Brand invite accept | `brand_invite_accept_screen.dart` | P3 | Friendly accept state |

---

## Content, contracts, negotiations (P3)

| Screen | File | Priority | Notes |
|---|---|---|---|
| Content review | `content_review_screen.dart` | P3 | Media + soft actions |
| Content submit | `content_submit_screen.dart` | P3 | Uploader in card |
| Contract | `contract_screen.dart` | P3 | Readable document chrome |
| Contract templates | `contract_templates_screen.dart` | P4 | Cards |
| Negotiation | `negotiation_screen.dart` | P3 | Thread + offer cards |
| Barter | `barter_screen.dart` | P4 | Status card |
| Publish URL | `publish_url_screen.dart` | P3 | Simple success-friendly form |
| Leave review | `leave_review_screen.dart` | P3 | Delightful rating UI |

---

## Briefs, agency, admin tools (P3–P4)

| Screen | File | Priority | Notes |
|---|---|---|---|
| Brief list | `brief_list_screen.dart` | P3 | Cards |
| Brief create | `brief_create_screen.dart` | P3 | Sectioned form |
| Agency briefs | `agency_briefs_screen.dart` | P4 | Ops density OK with soft chrome |
| Agency kanban | `agency_kanban_screen.dart` | P4 | Keep kanban; soft columns/cards |
| Verification queue | `verification_queue_screen.dart` | P4 | Admin list → card rows |
| Verification detail | `verification_detail_screen.dart` | P4 | Clear decision CTAs |
| KYC | `kyc_screen.dart` | P3 | Calm, trustworthy form |
| Admin referrals | `referrals/.../admin_referrals_screen.dart` | P4 | Soft table/cards |
| Referral rewards | `referral_rewards_screen.dart` | P3 | Reward celebration potential |

---

## Analytics (P4 — tables allowed)

| Screen | File | Priority | Notes |
|---|---|---|---|
| Analytics reports | `analytics_reports_screen.dart` | P4 | Soften chrome; charts per design (rounded, max 2 axes) |
| Post metrics | `post_metrics_screen.dart` | P4 | Metric cards + chart |
| Metrics chart card | `metrics_chart_card.dart` | P3 | Soft gradients, no grid overload |
| Export status dialog | `export_status_dialog.dart` | P4 | Soft dialog |

---

## Chat, notifications, manager (P3–P4)

| Screen | File | Priority | Notes |
|---|---|---|---|
| Chat thread | `chat_thread_screen.dart` | P3 | Bubbles soft; circular avatars |
| Notification preferences | `notification_preferences_screen.dart` | P4 | Grouped toggles in cards |
| Manager roster | `manager_roster_screen.dart` | P3 | People cards |
| Manager invite accept | `manager_invite_accept_screen.dart` | P3 | Friendly |
| Profile access | `profile_access_screen.dart` | P4 | Permissions as cards |

---

## Disputes, licensing, fraud (P4)

| Screen | File | Priority | Notes |
|---|---|---|---|
| Dispute filing | `dispute_filing_screen.dart` | P4 | Calm, non-aggressive error reds |
| Data erasure status | `data_erasure_status_screen.dart` | P4 | Status timeline |
| Licensing deal wizard | `licensing_deal_wizard_screen.dart` | P4 | Stepper + sections |
| Licensing grant delivery | `licensing_grant_delivery_screen.dart` | P4 | Delivery cards |
| Fraud warning banner | `fraud_warning_banner.dart` | P4 | Visible but not panic-UI |

---

## AI panel (P4)

| Widget | File | Priority | Notes |
|---|---|---|---|
| AI side panel | `ai_side_panel.dart` | P4 | Soft panel; uses ink tokens — migrate to new ink/surface |

---

## apps/mobile (P5)

| Screen | File | Priority | Notes |
|---|---|---|---|
| Auth | `apps/mobile/.../mobile_auth_screen.dart` | P5 | Port Soft Premium tokens |
| Campaign inbox | `mobile_campaign_inbox_screen.dart` | P5 | Large cards, bottom nav |
| Earnings | `mobile_earnings_screen.dart` | P5 | Large numbers |
| Theme | `mobile_theme.dart` + `tokens.dart` | P5 | Full palette port |

---

## Component-only work (no route)

| Component | Priority | Depends on |
|---|---|---|
| All `im_*` core widgets | P0 | Tokens |
| New hero/metric/nav primitives | P0–P1 | Tokens |
| Chart soft styling | P3 | Tokens + MetricsChartCard |
| Illustration empty states | P1+ | Asset pipeline |

---

## Suggested sprint slicing

### Sprint A — Foundations

- Tokens, theme, components, goldens, shell  

### Sprint B — First impression

- Brand dashboard, Creator dashboard, Landing, Login, Register  

### Sprint C — Money & campaigns

- Campaign list/create/detail, Marketplace, Applications, Earnings  

### Sprint D — Growth & trust

- Onboarding wizards, Discovery, KYC, Content submit/review  

### Sprint E — Ops & depth

- Analytics, Agency, Admin verification, Billing, Licensing, Disputes  

### Sprint F — Clients

- apps/web sync, apps/mobile Soft Premium, illustration polish  

---

## Tracking template (copy per PR)

```markdown
### Screen: <name>
- Priority: P?
- Portal: brand | creator | admin | public
- Loading: skeleton | spinner (justify)
- Empty: illustrated? CTA?
- Nav context: top | bottom | none
- Tokens only: yes/no
- Screenshots: before/after
- Residual debt:
```

---

## Counts (approx.)

| Bucket | Screens/pages |
|---|---|
| Total inventoried routes/screens | ~60+ |
| P1 | ~6–8 |
| P2 | ~12–15 |
| P3 | ~15–20 |
| P4 | remainder |
| P5 mobile | 3 screens + theme |

Most P3–P4 screens improve **automatically** when P0 components ship; this inventory is for intentional composition passes, not for rebuilding every page from scratch.
