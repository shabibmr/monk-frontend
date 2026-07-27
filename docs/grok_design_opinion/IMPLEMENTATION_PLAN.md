# Implementation Plan: Soft Premium UI Redesign

**Version:** 1.0  
**Author:** Grok design opinion  
**Date:** 2026-07-26  
**Source design:** [`docs/design/design_context2.md`](../design/design_context2.md) (Soft Premium Creator Platform v1.1)  
**Target apps:** `apps/monk` (canonical), `apps/web` (mirror), `apps/mobile` (follow-up)

---

## 1. Executive summary

### Goal

Evolve Influencer Monk’s Flutter UI from a **muted coral/teal admin portal** into a **soft, premium, social-first creator platform** that feels closer to Instagram, Notion, Linear, Airbnb, and Spotify than Salesforce.

Every screen should communicate:

> “This platform was built for ME.”

Tone: alive, encouraging, positive. Creators feel excited to create; brands feel powerful but never corporate.

### What is already good

| Strength | Location |
|---|---|
| Centralized design tokens | `apps/monk/lib/core/theme/tokens.dart` |
| Portal-aware theming (brand / influencer / admin) | `app_theme.dart` + `PortalThemeExtension` |
| Shared component library (`ImButton`, `ImCard`, `ImKpiCard`, …) | `apps/monk/lib/core/widgets/` |
| Responsive shells (compact bottom nav + desktop sidebar) | `portal_shell.dart` |
| Inter + display face setup | `typography.dart` (Inter + Baloo2) |
| Golden tests for core widgets | `apps/monk/test/goldens/` |
| Clean feature layering (presentation / domain / data) | `apps/monk/lib/features/*` |

### What must change

| Current (today) | Target (design_context2) |
|---|---|
| Coral `#F08A7A` + teal `#2E5A6B` + cream `#F7F5EE` | Purple `#6D3EF5` + soft surfaces `#FAFAFC` / `#FCFBFF` + accent pink/orange/green/blue |
| Left ERP-style sidebar (264px) as default desktop chrome | Top / floating navigation; sidebar demoted or removed for brand/creator |
| Card radius 12, button radius 12, hard borders | Card 24, button 18, soft shadow + subtle border |
| Content max width 1200 | Content ~1450, page max 1600, page padding 40 |
| Dense KPI `Wrap` of small cards | Hero greeting → metrics → campaigns → recommendations; airy multi-column |
| Spinner-only loading on dashboards | Skeleton loaders with rounded shimmer |
| Empty states: text + optional button in stroke bubble | Illustrated empty states with encouragement + CTA |
| Touch target 44 | Min clickable 48×48; button heights 48/44/52 (desktop/tablet/mobile) |
| Baloo2 for display + KPI | Inter primary scale expanded (hero 52 … micro 12); optional SF Pro; Baloo2 optional only if product wants rounded display moments |
| Brand/creator differentiated by teal vs coral | Shared purple system; creator = more playful accents; brand = refined accents; admin = deeper purple chrome |

### Non-goals

- Backend / API contract changes  
- New product features unless required for layout (e.g. greeting needs display name, which already exists in session)  
- Dark mode (not specified in design_context2)  
- Replacing domain/bloc logic  
- Full illustration library production (plan for placeholders + asset pipeline)  
- Rewriting tests that assert business logic (only UI/goldens/visual)

### Success criteria

1. **Token compliance:** No feature screen hardcodes legacy coral/teal/cream hex; all colors come from `ImColors` / `Theme` / `PortalThemeExtension`.  
2. **Chrome:** Brand and Creator desktop shells use top or floating nav; no dense full-height ERP sidebar as primary pattern.  
3. **Dashboards:** Brand and Creator homes implement the priority section lists from design_context2 (greeting, score/overview, tasks/campaigns, metrics, recommendations).  
4. **Components:** Core `im_*` widgets match radius, shadow, type, and button/input specs; goldens updated and green.  
5. **States:** Loading = skeletons; empty = illustrated + CTA; errors = friendly copy (no blame).  
6. **Accessibility:** AA contrast on primary text/buttons; 48×48 minimum hit targets; visible focus rings (soft purple, not browser blue).  
7. **Parity:** `apps/web` receives the same token/component changes as `apps/monk` (or is explicitly deferred with a freeze note).

---

## 2. Current architecture snapshot

### 2.1 App layout

```
apps/
  monk/          # Full multi-portal Flutter app (recommended source of truth)
  web/           # Near-duplicate of monk (theme + widgets + features mirrored)
  mobile/        # Slimmer app; separate tokens + MobileTheme (coral/teal)
packages/
  api_client/    # Unchanged by this redesign
  shared/        # Enums/status only — status chip mapping touches status_colors.dart, not packages
```

### 2.2 Theme stack (`apps/monk`)

| File | Role |
|---|---|
| `core/theme/tokens.dart` | `ImColors`, `ImSpacing`, `ImRadii`, `ImDurations`, `ImLayout`, `ImShadows` |
| `core/theme/typography.dart` | `ImTypography.textTheme()`, `kpiNumber()` |
| `core/theme/app_theme.dart` | `AppTheme.brand/influencer/admin()`, `PortalThemeExtension` |
| `core/theme/status_colors.dart` | EntityStatus → semantic chip colors |

### 2.3 Component library

| Widget | File | Design impact |
|---|---|---|
| `ImButton` | `im_button.dart` | Variants, height, radius 18, weight 600 |
| `ImCard` | `im_card.dart` | Radius 24, soft shadow, border `#ECECF3`, padding |
| `ImKpiCard` | `im_kpi_card.dart` | Large number → label → trend → icon chip |
| `ImTextField` | `im_text_field.dart` | Radius 16, height 48, floating label, purple focus glow |
| `ImStatusChip` | `im_status_chip.dart` | Soft pill, semantic accents |
| `ImSkeleton` | `im_skeleton.dart` | Rounded + shimmer (replace cream lerp with purple-tint surface) |
| `ImEmptyState` | `im_empty_state.dart` | Illustration slot + encouraging copy |
| `ImStepper` | `im_stepper.dart` | Soft purple completed steps (remove hard-coded teal) |
| `ImBubbleCard` | `im_bubble_card.dart` | Brand/creator tint → new accent tokens |
| `MonkLogo` | `monk_logo.dart` | May need light/dark variants for top nav |

### 2.4 Shells & routing

- `BrandShell`, `CreatorShell`, `AdminShell` in `core/router/shells/portal_shell.dart`  
- Desktop: **left sidebar** (`ImLayout.sidebarWidth = 264`)  
- Compact: `AppBar` + `NavigationBar` with **all** nav items (can overflow on mobile)  
- Content constrained to `ImLayout.contentMaxWidth = 1200`

### 2.5 High-traffic screens (priority redesign)

| Portal | Screen | Path (approx.) | Current UI shape |
|---|---|---|---|
| Brand | `brand_dashboard_screen.dart` | `/b/dashboard` | Title + Wrap of ImKpiCards |
| Creator | `creator_dashboard_screen.dart` | `/c/dashboard` | Same pattern |
| Brand | `campaign_create_screen.dart` | create flow | Multi-step form (uses stepper) |
| Brand | `campaign_list_screen.dart` | `/b/campaigns` | List/cards |
| Creator | marketplace screens | `/c/marketplace` | Discovery/list |
| Auth | login / register / landing | public | Forms on cream background |
| Admin | `admin_dashboard_screen.dart` | `/a/dashboard` | Stub/minimal |

~60+ presentation screens/pages exist under `features/`; most inherit look from tokens + `im_*` widgets and will improve automatically once foundations land.

---

## 3. Gap analysis (design_context2 vs codebase)

### 3.1 Color

| Token role | design_context2 | Current | Action |
|---|---|---|---|
| Primary bg | `#FAFAFC` | cream50 `#F7F5EE` | Replace |
| Alt bg | `#FCFBFF` | — | Add |
| Cards | `#FFFFFF` | white | Keep |
| Secondary cards | `#FBFBFD` | cream100 | Add / map |
| Borders | `#ECECF3` | ink300 @ 40% | Dedicated border token |
| Dividers | `#F1F2F8` | ink300 @ 40% | Dedicated divider token |
| Primary | `#6D3EF5` | teal700 / coral600 | Replace as system primary |
| Primary hover/pressed | `#5A2DE0` / `#4A20C7` | teal800 / coral500 | Add |
| Secondary purple | `#8F68FF` | — | Add |
| Accent pink | `#F46DB4` | coral family | Replace coral role |
| Accent orange / green / blue | `#FFB54D` / `#3BC87A` / `#4DA3FF` | partial | Add |
| Error / warning | `#FF5D5D` / `#FFB648` | danger/warning | Update hex |
| Gradients | soft purple / pink / bg glow / card glow | none centralized | Add `ImGradients` |

### 3.2 Elevation & shape

| Element | Target radius | Current | Action |
|---|---|---|---|
| Cards | 24 | 12 (`radiusMd`) | Raise card radius; split tokens by role |
| Buttons | 18 | 12 | New button radius token |
| Images | 20 | 20 (`radiusLg`) | Align |
| Text fields | 16 | 8 (`radiusSm`) | Raise |
| Chips | 12 | full pill (OK for status) | Chip radius 12 or keep pill for status |
| Profile images | circular | partial | Ensure avatars use circle |
| Shadow | `0 10px 40px rgba(60,45,100,0.06)` | ink @ 10%, blur 16 | Soft purple-tinted shadow |

### 3.3 Typography

| Role | Target size | Current | Action |
|---|---|---|---|
| Hero | 52 / 700 | displayLarge 32 Baloo | Expand scale |
| Page title | 42 / 700 | — | Add |
| Section title | 28 / 700 | headline 24 | Add / remap |
| Card title | 22 | titleMedium 16 | Add |
| Large number | 40 / 700 | kpiNumber 40 Baloo | Keep size; prefer Inter or keep display face for numbers only |
| Body / small / caption / micro | 16 / 14 / 13 / 12 | 16 / 14 / — / 12 | Add caption 13; line height ~1.4 |

**Font decision (recommended):**  
- Primary UI: **Inter** (already via `google_fonts`)  
- Fallback: Roboto / system  
- SF Pro Display is Apple-platform only — use `fontFamilyFallback` on Apple targets if desired; do not block web on SF Pro  
- **Baloo2:** optional for playful creator hero only; default plan uses Inter for all roles to match design_context2’s “Primary: Inter” unless product explicitly wants Baloo for KPI numbers

### 3.4 Spacing & layout

| Token | Target | Current | Action |
|---|---|---|---|
| Min spacing | 24 | 4–16 common on screens | Raise default page padding |
| Preferred | 32 | space32 exists | Prefer 24/32 over 8/12 for sections |
| Luxury | 48 | space48 exists | Hero gaps |
| Max page width | 1600 | — | Add |
| Content width | 1450 | 1200 | Raise |
| Page padding | 40 | 16 on dashboards | Raise |
| Card gap | 24 | 12 | Raise |
| Card max height guidance | ~420 | unbounded | Soft guideline for designers/implementers |

### 3.5 Navigation

| Aspect | Target | Current | Gap severity |
|---|---|---|---|
| Desktop pattern | Top / floating, minimal chrome | Full left sidebar with 8–10 items | **High** |
| Structure | Logo · Nav · Search · Notifications · Messages · Profile | Logo + vertical list; no search/messages in chrome | **High** |
| Mobile | Bottom nav + FAB; large cards; carousels | Bottom `NavigationBar` with **all** items (too many) | **High** |
| Admin | May keep denser chrome | Dark sidebar | Medium — admin can retain refined sidebar |

### 3.6 Components & motion

| Pattern | Target | Current |
|---|---|---|
| Hero | Greeting + headline + CTA + illustration | Plain `Text('Brand dashboard')` |
| Metrics | Number → label → trend → icon → mini graph | Label → number only |
| Charts | Soft gradients, max 2 axis lines, rounded | Custom paint; functional but not soft-premium |
| Buttons | Primary purple, secondary white+border, ghost, danger; h 48/44/52 | M3 Elevated/Outlined/Text; height 44 |
| Inputs | Floating labels, soft purple focus | Static label above field |
| Progress | Height 10, purple gradient | Varies |
| Tables | Avoid; cards/lists first | Some analytics screens denser |
| Loading | Skeleton shimmer | Many `CircularProgressIndicator`s |
| Motion | ~200ms ease; scale/fade/slide/elevation | `ImDurations.hover 150`, `panel 250` — close |

---

## 4. Design principles for implementers

When touching any screen during this migration:

1. **Emotion first, data second** — greeting and encouragement before dense metrics.  
2. **Whitespace is a feature** — never compress to “fit more admin data.”  
3. **Purple is the hero color** — accents (pink, orange, green, blue) sparingly for energy and metric chips.  
4. **Cards, carousels, illustrated states** over tables and endless lists.  
5. **Human states** — empty, loading, success, error always designed.  
6. **Creator vs brand** — same system; creator more playful (pink/orange accents, confetti-ready success); brand more refined (purple primary, restrained accents).  
7. **Never invent hex in feature code** — only tokens / theme.

---

## 5. Token migration strategy

Detailed map: [`TOKEN_MIGRATION.md`](./TOKEN_MIGRATION.md).

### 5.1 Recommended approach: **replace values + expand names**

Preserve call-site ergonomics where possible, but **do not keep misleading names** (`coral500`, `teal700`) as long-term API.

**Phase A — dual-write (one PR):**

1. Introduce the full Soft Premium palette under clear names (`primary600`, `surface`, `border`, accents, gradients).  
2. Map deprecated aliases:

```dart
// Temporary compatibility (remove in PR after call-site sweep)
@Deprecated('Use ImColors.primary600')
static const teal700 = primary600;
@Deprecated('Use ImColors.accentPink')
static const coral500 = accentPink;
// etc.
```

3. Update `AppTheme`, widgets, status colors, goldens to new tokens.  
4. Grep-sweep feature files for `ImColors.teal*`, `coral*`, `cream*`.  
5. Delete aliases in a follow-up PR once CI is clean.

### 5.2 New token modules (proposed shape)

```
tokens.dart
  ImColors        // surfaces, brand, accents, semantic
  ImGradients     // purple, pink, backgroundGlow, cardGlow
  ImSpacing       // add space40 if needed for page padding
  ImRadii         // role-based: card, button, image, field, chip
  ImShadows       // card (soft purple), float (hover)
  ImDurations     // motion 200ms ease
  ImLayout        // contentMaxWidth 1450, pageMaxWidth 1600, pagePadding 40, touchTarget 48
```

### 5.3 Portal theming

| Portal | Primary | Chrome notes |
|---|---|---|
| Brand | `#6D3EF5` | Refined; secondary white buttons; accents sparingly |
| Creator (influencer) | `#6D3EF5` primary; accent pink for highlights | Playful chips, warmer gradients on hero |
| Admin | Deep purple / pressed `#4A20C7` chrome | Optional slim sidebar or same top nav with denser tools |

Keep `PortalThemeExtension` but expand fields if needed: `accent`, `heroGradient`, `navPillBg`.

### 5.4 apps/web and apps/mobile

| App | Strategy |
|---|---|
| `apps/monk` | **Canonical** — implement first |
| `apps/web` | Mirror token/widget/shell PRs in lockstep (same files) **or** freeze web UI work until monk lands, then bulk sync |
| `apps/mobile` | Separate token port of Soft Premium into `apps/mobile/lib/theme/tokens.dart` + `mobile_theme.dart`; bottom nav + FAB pattern is already closer to design |

**Recommendation:** Treat `apps/monk` as source of truth. After each foundation PR, either copy theme/widget diffs to `apps/web` in the same PR (if CI covers both) or open a paired “web sync” PR immediately after.

---

## 6. Component redesign plan

### 6.1 Foundation components (must land before screen work)

| Component | Changes | New API (if any) |
|---|---|---|
| **ImCard** | Radius 24, shadow `ImShadows.card`, border `ImColors.border`, padding default 24, optional `variant: elevated / secondary / glow` | `variant`, `maxHeight` optional |
| **ImButton** | Radius 18; heights by breakpoint; primary/secondary/ghost/danger; weight 600; soft press scale optional | Map tertiary → ghost |
| **ImTextField** | Height 48, radius 16, larger padding, floating label (or keep external label but style to match), focus glow purple | Consider `floatingLabel: true` default later |
| **ImKpiCard** | Large number, small label, optional trend (+12%), optional icon chip color, optional mini sparkline slot | `trendPercent`, `icon`, `accent` |
| **ImSkeleton / ImSkeletonCard** | Shimmer on surface secondary; radius match cards; never spinner-only in dashboards | Keep API |
| **ImEmptyState** | Illustration widget slot, title, body, primary CTA; remove bare stroke-only bubble as sole treatment | `illustration`, `title`, `message` |
| **ImStatusChip** | Soft pills; updated semantic hex; optional colored icon | Unchanged entity mapping |
| **ImStepper** | Remove hard-coded teal; use theme primary; soft connectors | Unchanged steps API |
| **ImBubbleCard** | Soft accent backgrounds from new palette | — |

### 6.2 New components to add

| Component | Purpose | Used by |
|---|---|---|
| `ImHeroHeader` | Greeting + headline + subtitle + primary/secondary CTAs + illustration | Dashboards, landing |
| `ImMetricTile` | Icon chip + label + number + trend (stat row) | Dashboards |
| `ImSectionHeader` | Section title + optional action link | Everywhere |
| `ImChip` / `ImCategoryChip` | Lifestyle, Beauty, Gaming… category pills | Discovery, onboarding |
| `ImProgressBar` | Height 10, rounded, purple gradient fill | Campaigns, onboarding |
| `ImAvatar` / `ImAvatarStack` | Circular profile images + +N overflow | Campaign cards, chat |
| `ImTopNav` | Logo · primary links · search · notifications · messages · profile | Shell |
| `ImFloatingNav` | Optional floating bar variant for desktop | Shell alternative |
| `ImBottomNav` | 4–5 items + center FAB | Mobile shell |
| `ImPageScaffold` | Max width, page padding 40, optional background glow | Screens |
| `ImQuickActionGrid` | Icon tiles for quick actions | Brand dashboard |
| `ImCarousel` | Horizontal card carousel with optional chevrons | Campaigns, recommendations |
| `ImSuccessOverlay` | Soft confetti / check animation (lightweight) | Post-create, onboarding complete |

### 6.3 Motion tokens

```dart
// Align to design_context2
static const Duration interaction = Duration(milliseconds: 200);
static const Curve ease = Curves.ease; // or easeOutCubic for panels
// Patterns: fade, slide, scale, elevation on hover (web)
```

Use `AnimatedContainer` / `AnimatedOpacity` sparingly; prefer consistent 200ms on buttons, cards hover (web), nav pills.

### 6.4 Charts

Update `MetricsChartCard` and any custom painters:

- Soft gradient under line  
- Max 2 axis lines  
- No heavy grid  
- Rounded line joints  
- Primary purple stroke  

---

## 7. Navigation & shell redesign

### 7.1 Problem

Current desktop left sidebar lists **10 brand items** and **9 creator items**. That reads as ERP and dominates content. Mobile bottom nav dumps **all** routes into `NavigationBar`, which is unusable at that count.

### 7.2 Target information architecture

**Primary nav (always visible):**

| Brand | Creator | Admin |
|---|---|---|
| Dashboard | Dashboard | Dashboard |
| Discover | Marketplace | Verification |
| Campaigns | Applications | Agency |
| Applications | Earnings | — |
| More ▾ | More ▾ | Settings |

**“More” / overflow:** Briefs, Invoices, Team, Company, Settings, KYC, Referrals, Access, etc.

**Chrome actions (right cluster):** Search · Notifications · Messages (if chat live) · Profile avatar menu (includes Sign out).

### 7.3 Desktop layout

```
┌──────────────────────────────────────────────────────────────────────┐
│ Logo   Dashboard  Discover  Campaigns  …   🔍   🔔   💬   [Avatar]   │  ← floating or sticky top bar
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│                     Page content (max ~1450)                         │
│                     padding 40, airy sections                        │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

Implementation notes:

- Replace `_PortalChrome` desktop `Row(sidebar + content)` with `Column(topNav + content)`.  
- Optional: keep a **collapsible secondary rail** only for admin or multi-level campaign tools — not default for brand/creator.  
- Top bar: white / glass-light (~3% blur max if used), soft shadow, height ~72.  
- Active nav: soft purple pill (`primary` @ 8–12% fill) + purple label.  
- Background: `ImColors.surface` with optional subtle background glow gradient at top.

### 7.4 Mobile layout

```
┌─────────────────────┐
│ Large cards / hero  │
│ carousels           │
├─────────────────────┤
│  🏠  🔎  [＋]  💬  👤 │  ← 4 items + center FAB
└─────────────────────┘
```

- **Creator FAB:** e.g. “Find campaigns” / apply  
- **Brand FAB:** “Create campaign”  
- Overflow destinations via Profile or a “More” sheet  
- Large touch targets (52 height buttons); no tiny captions  

### 7.5 Search & notifications

Wire top-nav icons even if features are thin:

- Notifications → existing cubit unread badge (already on compact shell)  
- Search → route to Discover/Marketplace with focus, or a simple command-style modal  
- Messages → chat if available; else hide until ready  

### 7.6 Manager context bar

Restyle `ManagerContextBar` from coral100 strip to soft purple/pink tint with clear “Acting as …” messaging; keep exit action prominent.

---

## 8. Dashboard composition plans

### 8.1 Creator dashboard priorities (design_context2)

| # | Section | Implementation notes |
|---|---|---|
| 1 | Greeting | `ImHeroHeader` — “Hey {name} 👋 / Ready to inspire today?” |
| 2 | Creator Score | Large number card + optional gradient / mini ring |
| 3 | Today’s Tasks | Card list / checklist (may use invitations + pending content) |
| 4 | Current Campaigns | Horizontal carousel |
| 5 | Recommended Campaigns | Carousel or grid from marketplace recommendations |
| 6 | Earnings | Metric tiles + optional soft chart |
| 7 | Content Performance | Chart card restyled |
| 8 | Tips | Encouraging tip card (illustration) |
| 9 | Leaderboard | Optional later if data exists |
| 10 | Achievements | Optional later if data exists |

**Data reality check:** `DashboardCubit` / profile dashboard entity currently exposes invitations, pending content, earnings, etc. Map existing fields first; stub sections with illustrated empty states rather than inventing fake metrics. Leaderboard/achievements can be **v2** behind feature flags or static motivational placeholders only if product agrees.

### 8.2 Brand dashboard priorities

| # | Section | Implementation notes |
|---|---|---|
| 1 | Greeting | “Good morning {brand} / Let’s build another amazing campaign.” |
| 2 | Campaign Overview | Active campaigns + status chips |
| 3 | Creator Matches | Discovery shortlist teaser |
| 4 | Spend | KPI + trend |
| 5 | ROI | From metrics if available; else soft empty |
| 6 | Campaign Timeline | Horizontal timeline / list |
| 7 | Pending Approvals | Actionable list cards |
| 8 | Recent Activity | Timeline list |
| 9 | Quick Actions | Create campaign, Discover, Invoices |

**Replace** the current `Wrap` of many equal KPI cards with:

1. Hero  
2. 4–5 primary metric tiles with accent icon chips  
3. Main content + optional right rail (Quick Actions, Spend chart) on desktop  

### 8.3 Layout breakpoints

| Breakpoint | Behavior |
|---|---|
| Compact (&lt; 600) | Single column; bottom nav + FAB; horizontal carousels |
| Medium (600–1024) | Single/two column; top nav collapses to fewer items |
| Expanded (&gt; 1024) | Multi-column + optional right rail; full top nav |

Reuse `breakpointOf` / `ImLayout.compactBreakpoint` / `mediumBreakpoint`; verify values still fit.

---

## 9. Screen-level rollout

Full inventory: [`SCREEN_INVENTORY.md`](./SCREEN_INVENTORY.md).

### Priority tiers

| Tier | Scope | Rationale |
|---|---|---|
| **P0** | Tokens, theme, core `im_*`, shells, goldens | Unblocks everything |
| **P1** | Brand + Creator dashboards, auth landing/login/register | First impression |
| **P2** | Campaign list/create/detail, marketplace, discovery, applications | Core loops |
| **P3** | Onboarding wizards, earnings/payments, content review, briefs | High engagement |
| **P4** | Analytics, billing, contracts, licensing, chat, admin tools | Dense / secondary |
| **P5** | Mobile app theme + screens; polish motion, illustrations, confetti | Follow-up |

### Auth & onboarding

- Landing: soft premium hero, purple CTAs, no corporate stock feel  
- Login/register: airy form card, radius 16 inputs, encouraging microcopy  
- Onboarding (brand + influencer): multi-step with `ImStepper`, progress, illustration per step, never long field walls — split sections into cards  

### Forms (esp. campaign create)

- Keep bloc logic  
- Visual: two-column desktop fields, right rail tip + live preview (as design_context.md samples suggest)  
- Stepper restyle only; no state machine rewrite  

### Lists that look like tables

Prefer card rows with avatar, title, status chip, primary action. Keep true tables only for Analytics / Finance / Reports.

---

## 10. Content, illustration, and copy

### 10.1 Illustrations

Need asset pipeline under e.g. `apps/monk/assets/illustrations/`:

| Asset set | Usage |
|---|---|
| Hero creator / brand | Dashboard heroes |
| Empty campaigns / empty earnings / empty applications | Empty states |
| Success confetti or soft check | Success states |
| Mascot / cute objects (optional) | Onboarding |

**Never** stock office people photos.

Until final art lands: use soft gradient placeholders + simple custom painters / Lottie (if dependency approved) / SVG via `flutter_svg` (if approved). Plan one PR for asset wiring separate from token PR.

### 10.2 Copy guidelines

| State | Pattern |
|---|---|
| Empty | “No campaigns yet. Let’s create your first one!” + CTA |
| Error | Explain fix; never blame (“We couldn’t load this — try again”) |
| Success | Positive wording; optional confetti |
| Loading | Prefer skeleton; avoid “Loading…” walls |

### 10.3 Imagery

Rounded 20px images; bright, soft colors; circular avatars.

---

## 11. Accessibility & quality bar

| Requirement | Implementation check |
|---|---|
| Contrast AA | Primary purple on white; text ink on surfaces; verify accent chips |
| 48×48 hit targets | `ImLayout.touchTarget = 48`; button min sizes |
| Keyboard nav | Top nav focus order; focus rings on buttons/inputs |
| Screen readers | Labels on icon-only nav actions |
| Visible focus | Soft purple glow, not harsh blue |
| Reduced motion | Respect `MediaQuery.disableAnimations` for confetti/shimmer if feasible |

---

## 12. Phased implementation plan

### Phase 0 — Alignment (0.5–1 day)

- Confirm `apps/monk` as canonical; decide web sync policy  
- Confirm font policy (Inter-only vs Baloo for numbers)  
- Confirm desktop nav: top bar vs floating  
- Confirm illustration approach (placeholder vs commission)  
- Point token comments at `docs/design/design_context2.md`

### Phase 1 — Design foundation (PR-1)

**Scope:** tokens, typography, AppTheme, status colors, shadows, gradients  

**Files (monk):**

- `lib/core/theme/tokens.dart`  
- `lib/core/theme/typography.dart`  
- `lib/core/theme/app_theme.dart`  
- `lib/core/theme/status_colors.dart`  

**Acceptance:**

- App compiles; ThemeData uses new scaffold/surfaces  
- Temporary aliases for old color names if needed  
- Unit tests that reference colors still pass or updated  

### Phase 2 — Component library (PR-2)

**Scope:** all existing `im_*` widgets + export barrel  

**Acceptance:**

- Golden tests updated (`flutter test --update-goldens` then review)  
- No hard-coded teal/coral inside widgets  
- Buttons/cards/inputs match radius/height/shadow  

### Phase 3 — New primitives (PR-3)

**Scope:** `ImHeroHeader`, `ImMetricTile`, `ImSectionHeader`, `ImProgressBar`, `ImAvatar(Stack)`, `ImPageScaffold`, `ImChip`, `ImCarousel`, `ImQuickActionGrid`  

**Acceptance:**

- Widget-level tests or goldens for each  
- Documented in this folder or short widget catalog comment  

### Phase 4 — Shell & navigation (PR-4)

**Scope:** rewrite `_PortalChrome` / shells  

**Acceptance:**

- Desktop: top nav structure  
- Mobile: limited bottom destinations + FAB + overflow  
- Notifications badge preserved  
- Manager bar restyled  
- Router paths unchanged  

### Phase 5 — P1 screens (PR-5a brand dashboard, PR-5b creator dashboard, PR-5c auth)

**Acceptance:**

- Visual match to design philosophy (not pixel-perfect mockups unless samples dictate)  
- Skeletons on load; illustrated empties  
- No business logic regressions  

### Phase 6 — P2 core loops (campaigns, marketplace, discovery, applications)

Multiple PRs by feature folder; each: visual pass only + shared components.

### Phase 7 — P3/P4 remaining features

Sweep for:

- Raw `CircularProgressIndicator` → skeleton where page-level  
- Dense tables → card lists where appropriate  
- Legacy color references  
- Padding &lt; 16 on page roots → 24–40  

### Phase 8 — apps/web sync

Mirror theme, widgets, shells, and high-traffic screens. Or single “sync from monk” PR if structure remains parallel.

### Phase 9 — apps/mobile Soft Premium

Port tokens to mobile theme; align auth + earnings + campaign inbox screens; bottom nav + FAB.

### Phase 10 — Polish

- Real illustrations  
- Micro-interactions  
- Success confetti  
- Chart soft styling  
- Performance pass (shader warm-up, image cache)  
- Accessibility audit  

---

## 13. PR plan (DAG)

Each PR should be independently reviewable and mergeable.

```
PR-1  Design tokens + ThemeData
  └─► PR-2  Core im_* component restyle + goldens
        ├─► PR-3  New design primitives
        │     └─► PR-4  Portal shell / navigation chrome
        │           ├─► PR-5a Brand dashboard composition
        │           ├─► PR-5b Creator dashboard composition
        │           └─► PR-5c Auth + landing visual pass
        │                 ├─► PR-6a Campaigns visual pass
        │                 ├─► PR-6b Marketplace + discovery
        │                 └─► PR-6c Applications + earnings
        │                       └─► PR-7  Feature sweep (onboarding, content, analytics…)
        └─► PR-2w (optional parallel) web theme/widgets sync after PR-2
PR-8  apps/web full shell + dashboard sync (depends PR-4, PR-5*)
PR-9  apps/mobile token + chrome pass
PR-10 Illustration assets + empty/success polish
```

### PR checklist (every UI PR)

- [ ] Uses tokens only (no new raw hex in features)  
- [ ] Works compact + expanded  
- [ ] Loading / empty / error states considered  
- [ ] Goldens updated if components changed  
- [ ] `dart analyze` clean on touched packages  
- [ ] No domain/bloc behavior change unless required for greeting name etc.  
- [ ] Screenshot or short notes for reviewers  

---

## 14. Testing strategy

### 14.1 Golden tests (primary visual gate)

Existing:

- `test/goldens/im_widgets_golden_test.dart`  
- `test/goldens/im_stepper_golden_test.dart`  
- `test/goldens/manager_context_bar_golden_test.dart`  

Actions:

1. Update `goldenTheme()` helper to new Soft Premium colors (remove teal/coral).  
2. Regenerate PNGs after intentional redesign.  
3. Add goldens for: `ImHeroHeader`, `ImMetricTile`, top nav compact strip, button variants.  

### 14.2 Widget / bloc tests

- Do **not** assert exact colors in bloc tests.  
- Update any test that pumps UI and expects old strings only if copy changes.  
- Router/guard tests should remain green (shell rewrite must keep routes).  

### 14.3 Manual QA matrix

| Persona | Flow | Check |
|---|---|---|
| Brand | Login → dashboard → create campaign → list | Hero, top nav, form softness |
| Creator | Login → dashboard → marketplace → apply | Playful accents, FAB, carousels |
| Manager | Roster → act-as → dashboard | Context bar |
| Admin | Dashboard → verification | Acceptable density; not coral/teal |
| Mobile width | Resize web / use device | Bottom nav, no overflow |
| A11y | Keyboard tab through top nav | Focus visible |

### 14.4 Regression risks

| Risk | Mitigation |
|---|---|
| Golden churn across OS | Run goldens in CI container; document update command |
| apps/web drift | Paired PRs or monorepo script to diff theme folders |
| Hard-coded teal in features | Repo-wide grep in CI (optional lint) |
| Too many bottom nav items | Explicit primary destination list in shell |
| Breaking ImButton API | Keep constructors; map variants |

---

## 15. File-level change map (foundation)

### Theme

| Path | Change type |
|---|---|
| `apps/monk/lib/core/theme/tokens.dart` | **Rewrite values + expand API** |
| `apps/monk/lib/core/theme/typography.dart` | **Expand scale; Inter-first** |
| `apps/monk/lib/core/theme/app_theme.dart` | **Portal colors; component themes** |
| `apps/monk/lib/core/theme/status_colors.dart` | **Semantic hex update** |

### Widgets

| Path | Change type |
|---|---|
| `apps/monk/lib/core/widgets/im_*.dart` | Restyle |
| `apps/monk/lib/core/widgets/widgets.dart` | Export new widgets |
| New `im_hero_header.dart`, etc. | Add |

### Shell

| Path | Change type |
|---|---|
| `apps/monk/lib/core/router/shells/portal_shell.dart` | **Major layout rewrite** |

### Features (representative)

| Path | Change type |
|---|---|
| `features/dashboards/.../brand_dashboard_screen.dart` | **Composition rewrite** |
| `features/dashboards/.../creator_dashboard_screen.dart` | **Composition rewrite** |
| `features/auth/presentation/screens/*` | Visual pass |
| `features/campaigns/presentation/screens/*` | Visual pass |
| `features/marketplace/**`, `discovery/**` | Visual pass |
| Many screens with `CircularProgressIndicator` | Skeleton swap |

### Tests

| Path | Change type |
|---|---|
| `test/goldens/*` | Update themes + images |
| Feature widget tests | Fix finders if structure changes |

### Docs

| Path | Change type |
|---|---|
| `tokens.dart` header comment | Point to `design_context2.md` |
| This folder | Living plan |

---

## 16. Engineering conventions during migration

1. **No drive-by refactors** outside the visual scope of the PR.  
2. **Prefer extending `im_*`** over one-off decoration in screens.  
3. **Feature screens compose primitives**; they should not re-implement card shadows.  
4. **Deprecate, don’t big-bang rename** colors if it reduces risk — but delete aliases within 1–2 PRs.  
5. **Copy stays product-owned** — designers/PMs should review greeting strings.  
6. **Mock mode** continues to work; redesign is presentation-only.  

---

## 17. Effort estimate (rough)

| Phase | Effort (eng days) |
|---|---|
| Phase 0 alignment | 0.5 |
| Phase 1 tokens/theme | 1–2 |
| Phase 2 components + goldens | 2–3 |
| Phase 3 new primitives | 2–3 |
| Phase 4 shell/nav | 2–4 |
| Phase 5 dashboards + auth | 3–5 |
| Phase 6 core loops | 4–6 |
| Phase 7 feature sweep | 5–8 |
| Phase 8 web sync | 2–4 |
| Phase 9 mobile | 2–4 |
| Phase 10 polish + a11y | 2–4 |
| **Total** | **~26–43 eng days** |

Can be parallelized after PR-2 (multiple feature owners).

---

## 18. Risks & open questions

### Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Sidebar removal breaks power users | Medium | Keep “More” menu; optional compact side rail setting later |
| Incomplete data for full dashboard wishlist | Medium | Progressive sections + quality empty states |
| Dual app (monk/web) doubles work | High | Canonical app + sync policy |
| Golden flakiness | Medium | Single CI platform; careful font loading (offline golden theme already avoids google_fonts network) |
| Accent overload | Low | Enforce “one hero gradient per screen” |
| Contrast of soft purple on soft bg | Medium | AA checks on buttons/text |

### Open questions for product/design

1. Is **Baloo2** still desired for KPI numbers, or full Inter as design_context2 states?  
2. Should **admin** keep a dark sidebar for tool density?  
3. Are **Messages** and **Search** required in v1 chrome, or icon placeholders?  
4. Illustration source: internal, vendor, or abstract shapes?  
5. Is `apps/web` still shipping independently, or is `apps/monk` the only production client?  
6. Do we rename product framing in UI from any “Collabify” sample copy to **Influencer Monk** consistently?  
7. Mobile app (`apps/mobile`) in same release train or later?

---

## 19. Definition of done (program-level)

- [ ] `design_context2` palette and radii are the live token values in `apps/monk`  
- [ ] Brand & Creator desktop: top/floating nav, no default ERP sidebar  
- [ ] Mobile: primary bottom destinations + FAB  
- [ ] Brand & Creator dashboards: hero + airy sections (not only KPI wrap)  
- [ ] Core components match Soft Premium specs; goldens green  
- [ ] Loading/empty/error states humanized on P0–P2 screens  
- [ ] Legacy coral/teal/cream references removed (or only behind deprecated aliases scheduled for deletion)  
- [ ] `apps/web` synced or explicitly deferred in writing  
- [ ] Accessibility spot-check documented  
- [ ] This plan updated with any decisions from open questions  

---

## 20. Suggested first week

| Day | Deliverable |
|---|---|
| 1 | Phase 0 decisions; PR-1 tokens + theme drafted |
| 2 | PR-1 merged; PR-2 components started |
| 3 | PR-2 goldens updated; PR-3 primitives scaffolded |
| 4 | PR-4 shell prototype (top nav desktop + compact bottom) |
| 5 | PR-5a brand dashboard vertical slice behind same tokens |

After week 1, stakeholders can **see** the Soft Premium system on real routes and course-correct before the full feature sweep.

---

## 21. Appendix — design_context2 quick reference for engineers

### Colors (ship these)

- Surfaces: `#FAFAFC`, `#FCFBFF`, `#FFFFFF`, `#FBFBFD`, borders `#ECECF3`, dividers `#F1F2F8`  
- Primary purple: `#6D3EF5` / hover `#5A2DE0` / pressed `#4A20C7`  
- Accents: pink `#F46DB4`, orange `#FFB54D`, green `#3BC87A`, blue `#4DA3FF`  
- Error `#FF5D5D`, warning `#FFB648`  

### Radii

Cards 24 · Buttons 18 · Images 20 · Fields 16 · Chips 12 · Avatars circle  

### Shadow

`0 10px 40px rgba(60, 45, 100, 0.06)`  

### Type (Inter)

52 / 42 / 28 / 22 / 40 / 16 / 14 / 13 / 12 — weights 700 / 600 / 500 / 400 — line height ~140%  

### Spacing

Min 24 · Preferred 32 · Luxury 48 · Page pad 40 · Content 1450 · Max 1600  

### Motion

~200ms ease  

### Dashboard emotion

Lead with greeting and encouragement; mix metrics, illustrations, charts, progress, lists; never endless tables.

---

*End of implementation plan. Companion files: `TOKEN_MIGRATION.md`, `SCREEN_INVENTORY.md`.*
