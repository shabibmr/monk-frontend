# Flutter UI Redesign Execution Tasks (`gemini_design_opinion`)

**Target Branch:** `feature/gemini-ui-redesign`  
**Specification:** [`docs/gemini_design_opinion/design_context_2.md`](./design_context_2.md)  
**Implementation Plan:** [`docs/gemini_design_opinion/IMPLEMENTATION_PLAN.md`](./IMPLEMENTATION_PLAN.md)

---

## 📌 Phase 1: Core Design Tokens & Theme Foundations (PR 1)

- [ ] **Task 1.1: Update `ImColors` Palette**
  - **File:** `apps/monk/lib/core/theme/tokens.dart`
  - **Changes:** Replace legacy hex values with `primary600` (`#6D3FF0`), `primary500` (`#8F68FF`), `primary100` (`#EDE7FD`), `secondary600` (`#EC4899`), `surface` (`#FAFAFC`), `surfaceCard` (`#FFFFFF`), `ink900` (`#1A1A2E`), `ink600` (`#6B7280`), `ink300` (`#ECECF3`). Add 5 category stat chip pairs (`accentLavender`, `accentPink`, `accentAmber`, `accentMint`, `accentBlue`).
  - **Verification:** `flutter test apps/monk/test/core/theme/`

- [ ] **Task 1.2: Update `ImRadii`, `ImShadows`, `ImBorders`, and `ImGradients`**
  - **File:** `apps/monk/lib/core/theme/tokens.dart`
  - **Changes:** Set `radiusMd = 16.0`, `radiusLg = 24.0`. Add `ImShadows.card` (`0 10px 40px rgba(60,45,100,0.05)`), `ImShadows.float`, `ImBorders.card` (`1px solid #ECECF3`), and multi-stop gradients (`gradientHero`, `gradientWarm`, `gradientDark`, `gradientFAB`).
  - **Verification:** `flutter analyze apps/monk`

- [ ] **Task 1.3: Update `ImTypography` & Tabular Number Formatting**
  - **File:** `apps/monk/lib/core/theme/typography.dart`
  - **Changes:** Integrate `GoogleFonts.caveat` (`greetingScript`), `GoogleFonts.baloo2` (`displayLarge`, `headlineMedium`), `GoogleFonts.inter` (`bodyLarge`, `titleMedium`), and add `fontFeatures: [FontFeature.tabularFigures()]` for `kpiNumber` and `kpiNumberHero`.
  - **Verification:** `flutter analyze apps/monk`

- [ ] **Task 1.4: Update Theme Extension & AppTheme**
  - **File:** `apps/monk/lib/core/theme/app_theme.dart`
  - **Changes:** Update `PortalThemeExtension` to re-anchor brand portal to `#6D3FF0`, creator portal to `#EC4899`, and admin to `#4C1D95`.
  - **Verification:** `flutter test apps/monk/test`

- [ ] **Task 1.5: Mirror Tokens to Web & Mobile Theme Files**
  - **Files:** `apps/web/lib/core/theme/tokens.dart`, `apps/mobile/lib/theme/mobile_theme.dart`
  - **Changes:** Apply identical design tokens to maintain multi-app parity.
  - **Verification:** `flutter analyze apps/web apps/mobile`

---

## 🎨 Phase 2: Core Component Library Redesign (`im_*.dart`) (PR 2)

- [ ] **Task 2.1: Refactor `im_button.dart`**
  - **File:** `apps/monk/lib/core/widgets/im_button.dart`
  - **Changes:** Set default height to `44.0`, default radius to `radiusMd` (16.0), primary fill to `primary600`. Add glassmorphic factory `ImButton.glass()` with frosted backdrop blur.
  - **Verification:** `flutter test apps/monk/test/core/widgets/im_button_test.dart`

- [ ] **Task 2.2: Refactor `im_card.dart`**
  - **File:** `apps/monk/lib/core/widgets/im_card.dart`
  - **Changes:** Enforce dual surface physics: `ImBorders.card` hairline stroke + `ImShadows.card` ambient spread shadow + `radiusLg` (24.0).
  - **Verification:** `flutter test apps/monk/test/core/widgets/im_card_test.dart`

- [ ] **Task 2.3: Refactor `im_kpi_card.dart`**
  - **File:** `apps/monk/lib/core/widgets/im_kpi_card.dart`
  - **Changes:** Support 5 category chip color pairs (`accentLavender`, `accentPink`, `accentAmber`, `accentMint`, `accentBlue`), trend delta badges, and tabular figure KPI numbers.
  - **Verification:** `flutter test apps/monk/test/core/widgets/im_kpi_card_test.dart`

- [ ] **Task 2.4: Refactor `im_status_chip.dart`**
  - **File:** `apps/monk/lib/core/widgets/im_status_chip.dart`
  - **Changes:** Extend semantic badge mapping: `In Progress` (`#EDE7FD`/`#7C3AED`), `Live` (`#D1FAE5`/`#059669`), `Draft` (`#FEF3C7`/`#D97706`), `Hot` (`#FCE7F3`/`#DB2777`), `New` (`#DBEAFE`/`#2563EB`), `Starts in X days` (`#EDE7FD`/`#6D3FF0`).
  - **Verification:** `flutter test apps/monk/test/core/widgets/im_status_chip_test.dart`

- [ ] **Task 2.5: Refactor `im_stepper.dart`**
  - **File:** `apps/monk/lib/core/widgets/im_stepper.dart`
  - **Changes:** Restyle into 5-step numbered circle indicators connected by hairline progress links. Active step = solid `primary600`.
  - **Verification:** `flutter test apps/monk/test/core/widgets/im_stepper_test.dart`

- [ ] **Task 2.6: Create `im_goal_select_card.dart`**
  - **File:** `apps/monk/lib/core/widgets/im_goal_select_card.dart`
  - **Changes:** Build interactive form goal selection card (2×3 grid support, `2px` purple border when active, checkmark badge, tinted icon chip).
  - **Verification:** `flutter test apps/monk/test/core/widgets/im_goal_select_card_test.dart`

- [ ] **Task 2.7: Create `im_gamified_task_card.dart`**
  - **File:** `apps/monk/lib/core/widgets/im_gamified_task_card.dart`
  - **Changes:** Build gamified task checklist item with circular check control, task title, subtext, points badge (`+10 pts`), and progress counter.
  - **Verification:** `flutter test apps/monk/test/core/widgets/im_gamified_task_card_test.dart`

- [ ] **Task 2.8: Create `im_bottom_nav_bar.dart`**
  - **File:** `apps/monk/lib/core/widgets/im_bottom_nav_bar.dart`
  - **Changes:** Build mobile bottom navigation bar with 4 standard tab items + floating center FAB (`+`) with `gradientFAB` fill and glow shadow.
  - **Verification:** `flutter test apps/monk/test/core/widgets/im_bottom_nav_bar_test.dart`

- [ ] **Task 2.9: Create `im_rank_badge.dart`**
  - **File:** `apps/monk/lib/core/widgets/im_rank_badge.dart`
  - **Changes:** Build circular position medals for top creators — Gold (`#F59E0B`), Silver (`#94A3B8`), Bronze (`#D97706`).
  - **Verification:** `flutter test apps/monk/test/core/widgets/im_rank_badge_test.dart`

- [ ] **Task 2.10: Create `im_avatar_stack.dart`**
  - **File:** `apps/monk/lib/core/widgets/im_avatar_stack.dart`
  - **Changes:** Build overlapping avatar stack widget with 2px white border rings and trailing `+N` count overflow chip.
  - **Verification:** `flutter test apps/monk/test/core/widgets/im_avatar_stack_test.dart`

---

## 🏛 Phase 3: Navigation Chrome & Layout Shells (PR 3)

- [ ] **Task 3.1: Redesign Desktop Top Navigation Header**
  - **File:** `apps/monk/lib/features/shell_homes/presentation/desktop_top_nav.dart`
  - **Changes:** Replace left sidebar with fixed `72px` top nav bar, white surface, active `primary100` pill, and right utility items (Search, Bell with badge `6`, Messages, User Profile dropdown).
  - **Verification:** `flutter test apps/monk/test/features/shell_homes/`

- [ ] **Task 3.2: Redesign Mobile Navigation Shell**
  - **File:** `apps/mobile/lib/presentation/mobile_shell.dart`
  - **Changes:** Integrate `ImBottomNavBar` with floating center FAB button.
  - **Verification:** `flutter test apps/mobile/test/`

---

## 🚀 Phase 4: High-Traffic Screen Migrations (PR 4 & PR 5)

- [ ] **Task 4.1: Redesign Brand Dashboard Screen**
  - **File:** `apps/monk/lib/features/dashboards/presentation/brand_dashboard_screen.dart`
  - **Changes:** Build 3-column desktop layout, greeting hero card with 3D illustration asset slot, Brand Score card (`gradientWarm`), 5 KPI stat tiles, Active Campaigns carousel, and Spend Overview chart.
  - **Verification:** `flutter test apps/monk/test/features/dashboards/`

- [ ] **Task 4.2: Redesign Creator Dashboard Screen**
  - **File:** `apps/monk/lib/features/dashboards/presentation/creator_dashboard_screen.dart`
  - **Changes:** Build creator profile hero card (`greetingScript` font, Ananya mascot hero slot), Influence Score chart, 4 stat tiles, Brands carousel, gamified task list, and dark velvet earnings panel (`gradientDark`).
  - **Verification:** `flutter test apps/monk/test/features/dashboards/`

- [ ] **Task 4.3: Redesign Campaign Creation Screen**
  - **File:** `apps/monk/lib/features/campaigns/presentation/campaign_create_screen.dart`
  - **Changes:** Integrate 5-step stepper, 2×3 `ImGoalSelectCard` grid, 3D target pro tip card, and live preview card.
  - **Verification:** `flutter test apps/monk/test/features/campaigns/`

- [ ] **Task 4.4: Redesign Creator Discovery Screen**
  - **File:** `apps/monk/lib/features/discovery/presentation/creator_discovery_screen.dart`
  - **Changes:** Apply category filter pills, creator cards grid with avatar stack, and `primary600` action buttons.
  - **Verification:** `flutter test apps/monk/test/features/discovery/`

- [ ] **Task 4.5: Redesign Earnings Screen**
  - **File:** `apps/monk/lib/features/payments/presentation/earnings_screen.dart`
  - **Changes:** Apply `gradientDark` panel styling, glowing line chart, and tabular Indian Rupee formatting (`₹1,42,300`).
  - **Verification:** `flutter test apps/monk/test/features/payments/`

---

## 🧪 Phase 5: Verification & Golden Tests (PR 6)

- [ ] **Task 5.1: Execute Unit & Widget Test Suite**
  - **Command:** `flutter test` across `apps/monk`, `apps/web`, `apps/mobile`
  - **Criteria:** All tests pass with zero regressions.

- [ ] **Task 5.2: Generate Golden Tests for Core Widgets**
  - **Command:** `flutter test --update-goldens`
  - **Criteria:** Verify pixel-perfect alignment against HTML mockups in `docs/gemini_design_opinion/mockups/`.
