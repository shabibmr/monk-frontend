# Token Migration Map

Maps the **current** Influencer Monk Flutter tokens (`apps/monk/lib/core/theme/tokens.dart` and related) to **Soft Premium Creator Platform** tokens from `docs/design/design_context2.md`.

---

## 1. Color migration

### 1.1 Surfaces

| Role | New token name | Hex | Old token / usage | Notes |
|---|---|---|---|---|
| Primary background | `surface` | `#FAFAFC` | `cream50` (`#F7F5EE`) | Scaffold background |
| Alternative background | `surfaceAlt` | `#FCFBFF` | — | Optional page glow areas |
| Card | `surfaceCard` | `#FFFFFF` | `white` | Keep `white` as alias |
| Secondary card | `surfaceCardSecondary` | `#FBFBFD` | `cream100` (approx) | Nested panels |
| Border | `border` | `#ECECF3` | `ink300` @ 0.4 alpha on cards | Prefer solid border token |
| Divider | `divider` | `#F1F2F8` | `dividerColor` via ink300 | Theme `dividerColor` |
| White | `white` | `#FFFFFF` | `white` | Unchanged |

### 1.2 Brand & accents

| Role | New token name | Hex | Old token | Notes |
|---|---|---|---|---|
| Primary | `primary600` or `primary` | `#6D3EF5` | `teal700` (brand), `coral600` (creator) | Single hero purple system |
| Primary hover | `primaryHover` | `#5A2DE0` | `teal800` / `coral500` | Buttons, links |
| Primary pressed | `primaryPressed` | `#4A20C7` | ad hoc | Pressed state |
| Secondary purple | `primarySoft` / `secondaryPurple` | `#8F68FF` | — | Gradients, soft fills |
| Primary tint 100 | `primary100` | derive e.g. `#EDE7FD` or lighten | `teal100` / `coral100` | Nav pill, selected chip |
| Accent pink | `accentPink` | `#F46DB4` | `coral500` | Creator energy, badges |
| Accent orange | `accentOrange` | `#FFB54D` | — | Warm callouts, warning-adjacent |
| Accent green | `accentGreen` | `#3BC87A` | `success600` (partial) | Trends, success accents |
| Accent blue | `accentBlue` | `#4DA3FF` | `info600` (partial) | Info chips |

### 1.3 Semantic

| Role | New hex (design_context2) | Old | Token names to keep |
|---|---|---|---|
| Error | `#FF5D5D` | `danger600` `#C24E3A` | `danger600` / `danger100` (retint 100) |
| Warning | `#FFB648` | `warning600` `#B97A1B` | `warning600` / `warning100` |
| Success | prefer `#3BC87A` or keep strong green | `success600` `#2E7D5B` | Align success with accent green family |
| Info | `#4DA3FF` family | `info600` `#3A6EA5` | Align with accent blue |

**Semantic 100 tints:** generate soft pastel backgrounds for chips (do not use harsh fills). Example approach: primary at ~10–12% opacity on white, or fixed hexes from design_context.md if product prefers those.

### 1.4 Text / ink

design_context2 does not list ink hexes explicitly. Recommended (compatible with soft purple UI):

| Role | Proposed | Old | Notes |
|---|---|---|---|
| Primary text | `ink900` `#1A1A2E` or keep `#1D2B32` | `ink900` | Slightly cooler purple-black optional |
| Secondary text | `ink600` `#6B7280` range | `ink600` | Labels, meta |
| Disabled / hairline | `ink300` | `ink300` | Prefer `border` for borders |

### 1.5 Deprecated aliases (temporary)

| Deprecated | Maps to | Remove after |
|---|---|---|
| `coral500`, `coral600`, `coral100` | `accentPink` / primary soft tints | Call-site sweep |
| `teal700`, `teal800`, `teal100` | `primary` / `primaryPressed` / `primary100` | Call-site sweep |
| `cream50`, `cream100` | `surface` / `surfaceCardSecondary` | Call-site sweep |

### 1.6 Gradients (`ImGradients`)

| Name | Stops | Usage |
|---|---|---|
| `purple` | `#6D3EF5` → `#B06DFF` | Primary CTA fill (optional), progress |
| `pink` | `#FF6FB7` → `#FFB68D` | Creator hero accents |
| `backgroundGlow` | `#FFFFFF` → `#F9F6FF` | Page top background |
| `cardGlow` | `#FFFFFF` → `#FBF9FF` | Featured cards |

Use **at most one strong gradient hero surface per screen**.

### 1.7 PortalThemeExtension mapping

| Portal | primary | primaryPressed | sidebarBg (legacy) | New chrome |
|---|---|---|---|---|
| brand | `#6D3EF5` | `#4A20C7` | was cream100 | Top nav white; active pill primary100 |
| influencer | `#6D3EF5` | `#4A20C7` | was cream100 | Same; accent pink for highlights |
| admin | `#4A20C7` or deep | `#3A1A9E` | was teal800 | Optional deep chrome; not coral |

If top nav ships, `sidebarBg` / `sidebarFg` / `sidebarActive` may become `navBg` / `navFg` / `navActive` — migrate field names carefully with ThemeExtension copyWith.

---

## 2. Radii migration

| Role | New | Old token | Old value |
|---|---|---|---|
| Chip / small control | `radiusChip = 12` | `radiusSm = 8` | Raise chips to 12 |
| Button | `radiusButton = 18` | `radiusMd = 12` | New |
| Text field | `radiusField = 16` | `radiusSm` on inputs | New |
| Image | `radiusImage = 20` | `radiusLg = 20` | Keep |
| Card / large panel | `radiusCard = 24` | `radiusLg = 20` / `radiusMd` | Raise |
| Pill / avatar | `radiusFull = 999` | `radiusFull` | Unchanged |

**Suggested API:**

```dart
abstract final class ImRadii {
  static const chip = 12.0;
  static const button = 18.0;
  static const field = 16.0;
  static const image = 20.0;
  static const card = 24.0;
  static const full = 999.0;

  // Temporary aliases
  static const radiusSm = chip;
  static const radiusMd = field; // or button — document choice
  static const radiusLg = card;
  static const radiusFull = full;
}
```

Prefer **role names** in new code (`ImRadii.card`) over sm/md/lg.

---

## 3. Spacing migration

| Token | Value | Status |
|---|---|---|
| space4 | 4 | Keep (icon gaps) |
| space8 | 8 | Keep |
| space12 | 12 | Keep |
| space16 | 16 | Keep but **not** default page padding |
| space24 | 24 | **Minimum section spacing** |
| space32 | 32 | **Preferred section spacing** |
| space40 | 40 | **Add** — page padding |
| space48 | 48 | Luxury / hero |
| space64 | 64 | Keep |

| Layout token | New | Old |
|---|---|---|
| `pagePadding` | 40 | (screens used 16) |
| `cardGap` | 24 | 12 common |
| `contentMaxWidth` | 1450 | 1200 |
| `pageMaxWidth` | 1600 | — |
| `touchTarget` | 48 | 44 |
| `sidebarWidth` | deprecate or admin-only | 264 |
| `topNavHeight` | ~72 | — |
| `bottomNavHeight` | ~64 | — |
| `buttonHeightDesktop` | 48 | — |
| `buttonHeightTablet` | 44 | — |
| `buttonHeightMobile` | 52 | — |

---

## 4. Shadow migration

| Token | Spec | Old |
|---|---|---|
| `ImShadows.card` | `offset (0, 10)`, blur `40`, color `Color.fromRGBO(60, 45, 100, 0.06)` | `float` ink900 @ 0.10 blur 16 |
| `ImShadows.float` | Slightly stronger for hover | was only float |
| Border-as-elevation | Prefer shadow + white card on `surface` | Cards used 1px ink border heavily |

Cards: **soft shadow + subtle `border`**, not harsh dark shadow.

---

## 5. Typography migration

### 5.1 Scale

| Role | Size | Weight | Map from current TextTheme |
|---|---|---|---|
| Hero | 52 | 700 | extend beyond `displayLarge` |
| Page title | 42 | 700 | new / `displayMedium` |
| Section title | 28 | 700 | above `headlineMedium` 24 |
| Card title | 22 | 700 | above `titleMedium` 16 |
| Large number | 40 | 700 | `kpiNumber` |
| Body | 16 | 400 | `bodyLarge` |
| Small | 14 | 400 | `bodyMedium` |
| Caption | 13 | 400 | new |
| Micro | 12 | 400 | `bodySmall` |
| Button | 16 or 14 | 600 | `labelLarge` |
| Subtitle | — | 500 | use for section subtitles |

Line height: **~1.4** (design “140%”). Current theme uses 1.5 in places — slightly tighten toward 1.4 for titles if needed; keep body readable.

### 5.2 Families

| Role | design_context2 | Implementation |
|---|---|---|
| Primary | Inter | `GoogleFonts.inter` (existing) |
| Alternative | SF Pro Display | Platform font fallback on Apple only |
| Fallback | Roboto | Theme `fontFamilyFallback` |

**Baloo2:** currently used for display + KPI. Decision tracked in IMPLEMENTATION_PLAN open questions. Default recommendation: **Inter for all**, optional Baloo only for creator playful moments.

### 5.3 Offline goldens

`goldenTheme()` must not depend on network fonts. Continue constructing `ThemeData` with explicit sizes/colors without `GoogleFonts` in golden helpers, matching production metrics as closely as possible.

---

## 6. Duration / motion

| Token | New | Old |
|---|---|---|
| interaction | 200ms | hover 150ms |
| panel | 200–250ms | panel 250ms |
| curve | `Curves.ease` or `easeOutCubic` | `easeOutCubic` |

---

## 7. Status chip colors

Update `statusChipColors` backgrounds/foregrounds to new semantic hexes. Mapping from `EntityStatus` → `StatusSemantic` **stays** in `status_colors.dart`; only the color pairs change.

| Semantic | bg approach | fg |
|---|---|---|
| ink | `surfaceCardSecondary` / soft gray | `ink600` |
| info | soft blue tint | `accentBlue` / info |
| warning | soft orange tint | `warning` / accent orange |
| success | soft green tint | `accentGreen` |
| danger | soft red tint | `danger` |

---

## 8. Call-site sweep checklist

After new tokens land, grep and replace:

```
ImColors.coral500
ImColors.coral600
ImColors.coral100
ImColors.teal700
ImColors.teal800
ImColors.teal100
ImColors.cream50
ImColors.cream100
```

Known hotspots:

- `portal_shell.dart` (manager bar coral100)
- `im_stepper.dart` (teal700 hard-coded)
- `im_bubble_card.dart` (teal100 / coral100)
- `im_skeleton.dart` (cream lerp)
- `analytics/*` (teal for chips)
- Golden helpers in `test/goldens/`
- `apps/web` mirror files
- `apps/mobile/lib/theme/tokens.dart`

Also search for raw Material blues on focus rings and replace with primary purple focus.

---

## 9. Suggested final `ImColors` sketch

```dart
abstract final class ImColors {
  // Surfaces
  static const surface = Color(0xFFFAFAFC);
  static const surfaceAlt = Color(0xFFFCFBFF);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfaceCardSecondary = Color(0xFFFBFBFD);
  static const border = Color(0xFFECECF3);
  static const divider = Color(0xFFF1F2F8);
  static const white = Color(0xFFFFFFFF);

  // Brand
  static const primary = Color(0xFF6D3EF5);
  static const primaryHover = Color(0xFF5A2DE0);
  static const primaryPressed = Color(0xFF4A20C7);
  static const primarySoft = Color(0xFF8F68FF);
  static const primary100 = Color(0xFFEDE7FD); // soft tint; adjust if needed

  // Accents
  static const accentPink = Color(0xFFF46DB4);
  static const accentOrange = Color(0xFFFFB54D);
  static const accentGreen = Color(0xFF3BC87A);
  static const accentBlue = Color(0xFF4DA3FF);

  // Ink
  static const ink900 = Color(0xFF1A1A2E);
  static const ink600 = Color(0xFF6B7280);
  static const ink300 = Color(0xFFD1D5DB);

  // Semantic
  static const success600 = Color(0xFF3BC87A);
  static const success100 = Color(0xFFE3F9ED);
  static const warning600 = Color(0xFFFFB648);
  static const warning100 = Color(0xFFFFF4E0);
  static const danger600 = Color(0xFFFF5D5D);
  static const danger100 = Color(0xFFFFE8E8);
  static const info600 = Color(0xFF4DA3FF);
  static const info100 = Color(0xFFE5F2FF);
}
```

Exact `*100` tints may be tuned during implementation for AA contrast with `*600` text.

---

## 10. Migration PR order (token-specific)

1. **Add** new tokens + gradients + layout constants.  
2. **Point** `AppTheme` at new tokens (scaffold, ColorScheme, input/button themes).  
3. **Retarget** widgets off old names.  
4. **Alias** old names → new (deprecated).  
5. **Sweep** features + web + mobile.  
6. **Delete** aliases.  
7. **Update** goldens and docs comments.

Never leave production code depending on deprecated aliases longer than one release cycle.
