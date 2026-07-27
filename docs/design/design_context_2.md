# Design Context v2.0 — "Influencers Monk" Soft Premium Creator Platform

Source: Reference screenshots in `docs/design_samples/` (`brands_home_page.png`, `campaign_create_form.png`, `creator_home_page.png`, `creator_home_page_mobile.png`), master philosophy spec `docs/design_context2.md`, and visual design audit.

This document serves as the canonical design specification for the "Influencers Monk" visual redesign. It translates all visual elements from the reference screenshots into production-ready tokens, typography rules, surface physics, and component specifications across:

- `apps/monk/lib/core/theme/tokens.dart` (`ImColors`, `ImSpacing`, `ImRadii`, `ImDurations`, `ImLayout`, `ImShadows`)
- `apps/monk/lib/core/theme/typography.dart` (`ImTypography`)
- `apps/monk/lib/core/theme/app_theme.dart` (`AppTheme`, `PortalThemeExtension`)
- `apps/monk/lib/core/widgets/` (`im_*.dart` component library)
- Mirrored equivalents in `apps/web/lib/core/theme/` and `apps/web/lib/core/widgets/`
- `apps/mobile/lib/theme/mobile_theme.dart`

---

## 1. Color System & Design Tokens (`ImColors`)

The palette shifts from legacy muted coral/teal to a vibrant, warm violet/magenta SaaS system. Colors preserve existing token names in `ImColors` for seamless drop-in code compatibility while updating underlying values.

### 1.1 Core Palette
| Token (`ImColors`) | Hex | Usage / Location |
|---|---|---|
| `primary600` | `#6D3FF0` | Primary buttons, active nav pills, focus rings, primary icons |
| `primary500` | `#8F68FF` | Lighter primary accent, hover states, gradient start |
| `primary100` | `#EDE7FD` | Active nav pill fill, selected card background, soft purple chips |
| `secondary600` | `#EC4899` | Secondary accent — notification dots, logo mark gradient, badge highlights |
| `secondary100` | `#FCE4F1` | Tinted secondary background fills |
| `surface` | `#FAFAFC` | App canvas background (light lavender-tinted off-white) |
| `surfaceCard` | `#FFFFFF` | Primary card & panel background |
| `surfaceSecondaryCard` | `#FBFBFD` | Secondary nested card backgrounds |
| `ink900` | `#1A1A2E` | Headings, primary text, high-contrast KPI numbers |
| `ink600` | `#6B7280` | Body copy, secondary labels, inactive nav icons |
| `ink300` | `#ECECF3` | Hairline borders, dividers, disabled states |

### 1.2 Category Stat Chip Palette (Icon Chip BG / Icon Color Pairs)
In stat rows and dashboard tiles, each KPI category uses a distinct pastel container background with a rich, saturated icon:

| Chip Token Pair | Background Hex | Icon/Text Hex | Usage Example |
|---|---|---|---|
| `accentLavender` | `#EDE7FD` | `#6D3FF0` | Active Campaigns / Followers Icon Chip |
| `accentPink` | `#FCE7F3` | `#DB2777` | Creators Collaborating / Total Reach Icon Chip |
| `accentAmber` | `#FEF3C7` | `#D97706` | Total Reach / Engagement Rate Icon Chip |
| `accentMint` | `#D1FAE5` | `#059669` | Engagement Rate / Brand Collabs Icon Chip |
| `accentBlue` | `#DBEAFE` | `#2563EB` | Total Spend / Earnings Icon Chip |

### 1.3 Comprehensive Semantic Status Matrix
Status badges use dedicated background/foreground pairs to convey clear semantic states:

| Status Token | Background Hex | Text/Icon Hex | Example Usage |
|---|---|---|---|
| `statusInProgress` | `#EDE7FD` (Lavender100) | `#7C3AED` (Purple600) | "In Progress" campaign pill |
| `statusLive` | `#D1FAE5` (Mint100) | `#059669` (Green600) | "Live" active campaign pill |
| `statusDraft` / `statusWarning` | `#FEF3C7` (Amber100) | `#D97706` (Amber600) | "Draft" campaign pill, warnings |
| `statusHot` / `statusDanger` | `#FCE7F3` (Pink100) | `#DB2777` (Pink600) | "Hot" brand campaign pill, errors |
| `statusNew` / `statusInfo` | `#DBEAFE` (Blue100) | `#2563EB` (Blue600) | "New" campaign pill, notifications |
| `statusScheduled` | `#EDE7FD` (Lavender100) | `#6D3FF0` (Purple600) | "Starts in 3 days" upcoming pill |

### 1.4 Signature Multi-Stop Gradients
Gradients are used purposefully on high-impact focal points (maximum 1-2 hero surfaces per screen):

- **`gradientHero`**: `#6D3FF0 → #9363F7 → #EC4899` (135° linear) — Creator desktop/mobile hero card background.
- **`gradientWarm`**: `#FF6FB7 → #FF8A65 → #FFB54D` (135° linear) — Brand Score card, Pro Tip callout card.
- **`gradientDark`**: `#231754 → #1E1646 → #0D0726` (135° linear) — Earnings Overview panel (creator right rail).
- **`gradientGlassPill`**: `rgba(255, 255, 255, 0.25) → rgba(255, 255, 255, 0.10)` (180° linear) with `backdrop-filter: blur(12px)` — Translucent hero CTA (`View insights >`).
- **`gradientFAB`**: `#8F68FF → #6D3FF0 → #EC4899` (135° linear) — Floating action button on mobile bottom nav.

---

## 2. Typography & Expressive Font System (`ImTypography`)

The product uses a 3-tier font strategy balancing approachability, legibility, and numeric clarity:

1. **Display Face (`Baloo2`)**: Soft, geometric-rounded sans used for primary page titles, dashboard greeting headlines, and hero KPI numbers.
2. **Handwritten Script Accent (`Caveat` / `Satisfy`)**: Expressive, human handwritten script face used specifically for personal greeting accents (*"Hey Ananya! 👋"*, *"Let's create magic today"*).
3. **Body & UI Face (`Inter`)**: Clean, neutral sans for body copy, labels, form controls, table data, and UI chrome.
4. **Tabular Numerals**: Enforced across all metrics and financial figures (`fontFeatures: [FontFeature.tabularFigures()]`) to prevent layout jitter when numbers update.

### Type Scale Specification
| Style Name | Font Family | Size / Weight / Line Height | Usage |
|---|---|---|---|
| `greetingScript` | Caveat / Satisfy | 36px / Regular (400) / 1.2 | Personal creator greeting ("Hey Ananya! 👋") |
| `displayLarge` | Baloo2 | 32px / Bold (700) / 1.2 | Dashboard hero titles ("Good morning, LuxeGlow!") |
| `headlineMedium` | Baloo2 | 24px / SemiBold (600) / 1.2 | Section titles ("Your Active Campaigns") |
| `titleMedium` | Inter | 16px / SemiBold (600) / 1.4 | Card titles, list headers |
| `bodyLarge` | Inter | 16px / Regular (400) / 1.5 | Standard body copy |
| `bodyMedium` | Inter | 14px / Regular (400) / 1.5 | Field descriptions, subtext |
| `labelLarge` | Inter | 14px / SemiBold (600) / 1.4 | Buttons, active tab labels, form labels |
| `bodySmall` | Inter | 12px / Regular (400) / 1.4 | Captions, timestamps, helper text |
| `kpiNumber` | Inter / Baloo2 | 40px / Bold (700) / 1.1, Tabular | Dashboard KPI numbers ("₹12.4L", "8.6", "4.2M") |
| `kpiNumberHero` | Baloo2 | 56px / Bold (700) / 1.1, Tabular | Mobile hero influence score ("8,742") |

---

## 3. Spacing, Radii & Dual Surface Physics

### 3.1 Spacing Scale (`ImSpacing`)
- `space4`: 4.0
- `space8`: 8.0
- `space12`: 12.0
- `space16`: 16.0
- `space24`: 24.0 (Default card internal padding)
- `space32`: 32.0 (Section gaps)
- `space48`: 48.0 (Hero container padding)
- `space64`: 64.0 (Major layout block separation)

### 3.2 Radii Scale (`ImRadii`)
- `radiusSm`: `8.0` — Small badges, tag pills
- `radiusMd`: `16.0` — Buttons, text fields, goal cards (**updated from 12.0**)
- `radiusLg`: `24.0` — Cards, hero containers, floating panels (**updated from 20.0**)
- `radiusFull`: `999.0` — Avatars, pill buttons, nav chips

### 3.3 Dual Surface Physics (Hairline Border + Ambient Spread Shadow)
Cards do not rely solely on flat color or heavy borders. They combine a light hairline stroke with a soft multi-layered shadow:

```dart
abstract final class ImShadows {
  /// Default card resting shadow
  static final card = [
    BoxShadow(
      color: const Color(0xFF3C2D64).withValues(alpha: 0.05),
      blurRadius: 40,
      spreadRadius: 0,
      offset: const Offset(0, 10),
    ),
  ];

  /// Floating/Hover elevated shadow
  static final float = [
    BoxShadow(
      color: const Color(0xFF3C2D64).withValues(alpha: 0.12),
      blurRadius: 48,
      spreadRadius: 0,
      offset: const Offset(0, 14),
    ),
  ];
}

abstract final class ImBorders {
  /// Hairline border for surface cards
  static final cardBorder = Border.all(
    color: const Color(0xFFECECF3),
    width: 1.0,
  );
}
```

---

## 4. 3D Illustration & Visual Anchor Strategy

3D assets act as primary emotional anchors across key user journeys:

1. **Brand Dashboard Hero**: 3D Shopping Bag + Bullseye Target + Potted Plant cluster.
2. **Creator Dashboard Hero**: 3D Animated Female Creator Mascot ("Ananya") in purple hoodie with glasses.
3. **Campaign Create Form (Pro Tip)**: Floating 3D Target/Dartboard with purple dart and sparkles.
4. **Creator Pro Tip Card**: 3D Hugging/Smiling Emoji with starburst accents.

### Implementation Guidelines
- **Density**: Maximum 1 major 3D illustration per viewport.
- **Sizing**: Hero illustrations must fit within `140px - 200px` height boundaries.
- **Fallbacks**: When 3D assets are loading or unavailable, degrade gracefully to high-quality vector illustrations with matching color gradients.

---

## 5. Layout Architecture

### 5.1 Desktop Dashboard Layout (3-Column Grid)
- **Top Navigation Bar**: Fixed `72px` height, white background, `1px` bottom border (`#ECECF3`). Active nav item uses `primary100` fill (`#EDE7FD`) with `primary600` (`#6D3FF0`) text and icon.
- **Main Column (~68% width)**:
  - Row 1: Greeting Hero Card + Brand/Influence Score Card.
  - Row 2: 4-5 KPI Stat Tiles.
  - Row 3: Horizontal Card Carousel ("Your Active Campaigns" / "Brands that love your vibe").
  - Row 4: Split lists (Top Performing Creators / Recent Activity).
- **Right Rail (~32% width, max 420px)**:
  - Section 1: Quick Actions grid (4 circular icon chips).
  - Section 2: Spend/Earnings Overview Chart Card (with smooth area line chart).
  - Section 3: Upcoming Campaigns / Gamified Today's Tasks.
  - Section 4: Pro Tip Callout Card (`gradientWarm`).

### 5.2 Multi-Step Form Layout (`campaign_create_screen.dart`)
- **Step Header**: 5-step horizontal stepper (1. Basic Info → 2. Creators → 3. Content → 4. Budget → 5. Review). Numbered 32px circles connected by hairline progress links. Active step is solid `primary600` with white text.
- **Form Body**: 2-column input grid on desktop, single-column on mobile.
- **Right Rail Context**: Floating "Pro Tip" card (`gradientWarm` with 3D dartboard), live Campaign Preview card (with "Draft" orange pill), and "What's next?" step roadmap.

### 5.3 Mobile Flow Layout (`creator_home_page_mobile.png`)
- **Single Column Stack**: Mobile header → Hero score card (`gradientHero`) → Quick Actions horizontal scroll → 2×2 Stat Grid → Active Campaign card → Gamified task list.
- **Bottom Navigation Bar**: Fixed `64px` height with circular notch for center raised floating action button (`gradientFAB`).

---

## 6. Component Specifications & Token API (`im_*.dart`)

### 6.1 `im_button.dart`
- **Primary Button**: Solid `primary600` fill, white label text (`labelLarge`), `radiusMd` (16px), 44px min height.
- **Secondary Button**: White fill, `1px solid ink300` border, `ink900` text.
- **Glass Pill Button**: `gradientGlassPill` fill, `1px solid rgba(255,255,255,0.4)` border, `backdrop-filter: blur(12px)`, white text (`View insights >`).

### 6.2 `im_goal_select_card.dart` (New Component)
Interactive option tiles for form selections (e.g., Campaign Goals grid):
- **Unselected State**: White card fill, `1px solid ink300` border, `radiusMd`, tinted icon chip + label.
- **Selected State**: `primary100` tint fill, `2px solid primary600` border, checkmark icon badge in top-right corner.

### 6.3 `im_gamified_task_card.dart` (New Component)
Task checklist widget with gamified progress tracking:
- Circular checkbox control (green check when completed).
- Task title + subtitle.
- Points reward chip (`+10 pts` / `+25 pts` in mint green).
- Footer progress indicator (`2/3 completed`).

### 6.4 `im_bottom_nav_bar.dart` (New Component)
Mobile bottom bar:
- White surface background with soft top shadow.
- Active item in `primary600`, inactive in `ink600`.
- Center raised circular FAB (`+`) with `gradientFAB` fill and purple glow shadow.

### 6.5 `im_rank_badge.dart` (New Component)
Leaderboard rank indicator:
- Rank 1: Gold `#F59E0B` circular badge with crown/star.
- Rank 2: Silver `#94A3B8` circular badge.
- Rank 3: Bronze `#D97706` circular badge.

### 6.6 `im_avatar_stack.dart` (New Component)
Overlapping creator avatar display:
- 28px - 32px circular images with `2px` solid white border.
- Overlap offset: `-8px` horizontal margin.
- Trailing `+N` overflow indicator chip in soft gray fill.

---

## 7. Currency & Localization Formatting

All financial metrics follow regional Indian Rupee (INR) formatting with tabular figure alignment:
- Standard format: `₹12,42,300` (Lakhs separator rule).
- Compact format: `₹12.4L` (Lakhs), `₹2.5Cr` (Crores).
- Range format: `₹2.5L - ₹4L`.

---

## 8. Page-Level Component Mapping Matrix

| Screen Component | Location | Widget File | Required Spec Updates |
|---|---|---|---|
| Dashboard Greeting Hero | `brand_dashboard_screen.dart` | `im_hero_card.dart` | Add `greetingScript` font, 3D illustration asset slot, dual action buttons |
| Brand / Influence Score Card | Both Dashboards | `im_kpi_card.dart` | Apply `gradientWarm` background, mini line chart overlay |
| KPI Stat Row (5 tiles) | Both Dashboards | `im_kpi_card.dart` | Support category chip color pairs (§1.2) + tabular figures |
| Campaign Carousel | Both Dashboards | `im_campaign_card.dart` | Add avatar stack overlay, status pill overlay, progress bar |
| Quick Actions Grid | Dashboards & Mobile | `im_quick_action_tile.dart` | Circular tinted icon chips + label below |
| Earnings Overview Panel | Creator Dashboard | `im_chart_card.dart` | Apply `gradientDark` panel styling + purple glowing area line chart |
| Multi-Step Form | `campaign_create_screen.dart` | `im_stepper.dart` | Update 5-step numbered circle layout + goal selection grid |
| Mobile Navigation | Mobile App | `im_bottom_nav_bar.dart` | Implement floating center FAB + 4-tab bar |

---

## 9. Codebase Sync & Implementation Roadmap

1. **Tokens Pass**: Update `ImColors`, `ImSpacing`, `ImRadii`, `ImShadows` in `apps/monk/lib/core/theme/tokens.dart`.
2. **Typography Pass**: Add `greetingScript` and tabular font features in `apps/monk/lib/core/theme/typography.dart`.
3. **Core Widgets Pass**: Extend `im_button.dart`, `im_card.dart`, `im_status_chip.dart`, and add `im_goal_select_card.dart`, `im_avatar_stack.dart`, `im_gamified_task_card.dart`.
4. **Screen Integration**: Apply theme tokens across `brand_dashboard_screen.dart`, `creator_dashboard_screen.dart`, and `campaign_create_screen.dart`.
