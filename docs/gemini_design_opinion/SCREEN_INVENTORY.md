# Screen Inventory & Redesign Matrix (`gemini_design_opinion`)

**Target Specification:** [`docs/gemini_design_opinion/design_context_2.md`](./design_context_2.md)  
**Location:** `apps/monk/lib/features/`

---

## Screen Migration Matrix

| Feature Module | Key Screens | Priority | Target Composition |
|---|---|---|---|
| `dashboards` | `brand_dashboard_screen.dart`, `creator_dashboard_screen.dart` | **P0 (Critical)** | 3-column desktop layout, greeting hero card with 3D illustration, Brand/Influence score card, 5 KPI stat tiles, Active Campaigns carousel, spend chart card. |
| `campaigns` | `campaign_create_screen.dart`, `campaign_list_screen.dart` | **P0 (Critical)** | 5-step numbered stepper, 2×3 interactive goal cards grid, 3D target pro tip card, live campaign preview panel. |
| `shell_homes` | `portal_shell.dart`, `mobile_shell.dart` | **P0 (Critical)** | Top nav chrome (`72px`, white surface, purple active pill) for desktop; bottom nav (`64px`) with center raised FAB for mobile. |
| `auth` | `login_screen.dart`, `register_screen.dart` | **P1 (High)** | Centered card on `#FAFAFC`, purple primary CTA, 3D mascot/logo anchor, floating form inputs with soft purple focus ring. |
| `discovery` | `creator_discovery_screen.dart` | **P1 (High)** | Filter chip pills, grid of creator cards with avatar ring accents, follower reach metrics, and "Invite" action button. |
| `briefs` | `brief_detail_screen.dart` | **P1 (High)** | Soft card layout, deliverable checklist, budget summary, status pill badges. |
| `payments` | `earnings_screen.dart`, `payout_screen.dart` | **P1 (High)** | Dark purple panel (`gradientDark`), glowing violet line chart, tabular INR currency values (`₹1,42,300`). |
| `chat` | `conversation_screen.dart` | **P2 (Medium)** | Clean bubble interface, online status indicators, attachment previews with `radiusMd`. |
| `analytics` | `analytics_overview_screen.dart` | **P2 (Medium)** | Soft gradient line/bar charts, minimal gridlines, metric stat tiles. |
| `onboarding_brand` | `brand_onboarding_screen.dart` | **P2 (Medium)** | Multi-step wizard, progress bar, encouraging subtext, company logo drop zone. |
| `onboarding_influencer` | `influencer_onboarding_screen.dart` | **P2 (Medium)** | Social account connection tiles, niche tag chips (Lifestyle, Beauty, Gaming), score calculator. |
