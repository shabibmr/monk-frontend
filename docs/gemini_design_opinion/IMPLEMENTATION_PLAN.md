# Implementation Plan — Flutter UI Redesign (`gemini_design_opinion`)

**Target Specification:** [`docs/gemini_design_opinion/design_context_2.md`](./design_context_2.md)  
**Target Codebase:** `apps/monk/` (Canonical Flutter App), `apps/web/`, `apps/mobile/`

---

## Executive Summary

This document outlines the step-by-step engineering roadmap to update the Flutter codebase from its legacy coral/teal look to the Soft Premium Creator System defined in `design_context_2.md`. 

The architecture of `apps/monk` (`ImColors`, `ImTypography`, `ImRadii`, `ImShadows`, `PortalThemeExtension`, `im_*.dart` widgets) already provides a clean abstraction layer. The migration will be executed token-first, component-second, and screen-third to eliminate visual debt without breaking existing business logic.

---

## Phase 1: Core Design Tokens & Theme Extension (PR 1)

### 1.1 `tokens.dart` Update (`apps/monk/lib/core/theme/tokens.dart`)
Replace legacy hex values in `ImColors`, update `ImRadii`, `ImShadows`, and add `ImBorders` & `ImGradients`.

```dart
abstract final class ImColors {
  // Brand & Accent Palette
  static const primary600 = Color(0xFF6D3FF0);
  static const primary500 = Color(0xFF8F68FF);
  static const primary100 = Color(0xFFEDE7FD);
  static const secondary600 = Color(0xFFEC4899);
  static const secondary100 = Color(0xFFFCE4F1);

  // Surfaces & Ink
  static const surface = Color(0xFFFAFAFC);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfaceSecondaryCard = Color(0xFFFBFBFD);
  static const ink900 = Color(0xFF1A1A2E);
  static const ink600 = Color(0xFF6B7280);
  static const ink300 = Color(0xFFECECF3);
  static const white = Color(0xFFFFFFFF);

  // Category Stat Chips
  static const accentLavenderBg = Color(0xFFEDE7FD);
  static const accentLavenderFg = Color(0xFF6D3FF0);
  static const accentPinkBg = Color(0xFFFCE7F3);
  static const accentPinkFg = Color(0xFFDB2777);
  static const accentAmberBg = Color(0xFFFEF3C7);
  static const accentAmberFg = Color(0xFFD97706);
  static const accentMintBg = Color(0xFFD1FAE5);
  static const accentMintFg = Color(0xFF059669);
  static const accentBlueBg = Color(0xFFDBEAFE);
  static const accentBlueFg = Color(0xFF2563EB);

  // Semantic Badges
  static const success600 = Color(0xFF059669);
  static const success100 = Color(0xFFD1FAE5);
  static const warning600 = Color(0xFFD97706);
  static const warning100 = Color(0xFFFEF3C7);
  static const danger600 = Color(0xFFDB2777);
  static const danger100 = Color(0xFFFCE7F3);
  static const info600 = Color(0xFF2563EB);
  static const info100 = Color(0xFFDBEAFE);
}

abstract final class ImRadii {
  static const radiusSm = 8.0;
  static const radiusMd = 16.0; // Was 12.0
  static const radiusLg = 24.0; // Was 20.0
  static const radiusFull = 999.0;
}

abstract final class ImShadows {
  static final card = [
    BoxShadow(
      color: const Color(0xFF3C2D64).withValues(alpha: 0.05),
      blurRadius: 40,
      offset: const Offset(0, 10),
    ),
  ];
  static final float = [
    BoxShadow(
      color: const Color(0xFF3C2D64).withValues(alpha: 0.12),
      blurRadius: 48,
      offset: const Offset(0, 14),
    ),
  ];
}

abstract final class ImBorders {
  static final card = Border.all(
    color: ImColors.ink300,
    width: 1.0,
  );
}

abstract final class ImGradients {
  static const gradientHero = LinearGradient(
    colors: [Color(0xFF6D3FF0), Color(0xFF9363F7), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientWarm = LinearGradient(
    colors: [Color(0xFFFF6FB7), Color(0xFFFF8A65), Color(0xFFFFB54D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientDark = LinearGradient(
    colors: [Color(0xFF231754), Color(0xFF1E1646), Color(0xFF0D0726)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

### 1.2 `typography.dart` Update
Integrate `greetingScript` handwritten font style and enable tabular figures on numbers:

```dart
abstract final class ImTypography {
  static TextStyle greetingScript({Color? color}) => GoogleFonts.caveat(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.2,
        color: color ?? ImColors.ink900,
      );

  static TextStyle kpiNumber({Color? color}) => GoogleFonts.baloo2(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: color ?? ImColors.ink900,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
```

---

## Phase 2: Core Component Redesign (PR 2)

### 2.1 Refactor Existing `im_*.dart` Components
- `im_button.dart`: Add `radiusMd` default, primary violet fill, and `ImButton.glass()` variant.
- `im_card.dart`: Apply `ImBorders.card` + `ImShadows.card` dual physics.
- `im_kpi_card.dart`: Add support for category chip color pairs and trend badges.
- `im_status_chip.dart`: Extend mapping for `In Progress`, `Live`, `Draft`, `Hot`, `New`, `Starts in X days`.

### 2.2 Add New Core Components
- `im_goal_select_card.dart`: Interactive form goal selection card with checkmark badge.
- `im_gamified_task_card.dart`: Task checklist widget with points badge.
- `im_bottom_nav_bar.dart`: Mobile bottom nav bar with center raised FAB.
- `im_rank_badge.dart`: Leaderboard rank medals (Gold, Silver, Bronze).
- `im_avatar_stack.dart`: Overlapping creator avatars display.

---

## Phase 3: Top & Navigation Chrome Overhaul (PR 3)

Replace ERP-style sidebar navigation on desktop with modern top navigation bar:
- White surface, `72px` height, `1px` bottom border (`#ECECF3`).
- Active items rendered in `primary100` fill + `primary600` text pill.
- Right utility buttons (Search, Notification Bell with counter badge `6`, Messages, User Profile menu).

---

## Phase 4: High-Traffic Screen Migration (PR 4 & PR 5)

### PR 4: Brand Dashboard & Campaign Creation Screen
- Update `brand_dashboard_screen.dart` with 3-column grid, Brand Score card (`gradientWarm`), 5 KPI stat tiles, and Active Campaigns carousel.
- Update `campaign_create_screen.dart` with 5-step stepper, goal selection grid, 3D target pro tip card, and live preview.

### PR 5: Creator Dashboard & Mobile Experience
- Update `creator_dashboard_screen.dart` with Ananya mascot hero card, influence score line chart, Brands carousel, gamified tasks, and dark velvet earnings panel.
- Update `apps/mobile/` creator home screen with single-column layout and floating FAB nav.

---

## Phase 5: Regression Testing & Golden Verification

1. Run `flutter test` across all unit/widget tests.
2. Update/generate Golden tests for `ImButton`, `ImCard`, `ImKpiCard`, `ImStatusChip`, `ImGoalSelectCard`.
3. Verify visual correctness against `docs/gemini_design_opinion/mockups/`.
