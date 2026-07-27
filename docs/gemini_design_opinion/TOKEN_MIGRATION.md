# Token Migration Map — Current vs Target (`gemini_design_opinion`)

**Target Specification:** [`docs/gemini_design_opinion/design_context_2.md`](./design_context_2.md)  
**File Modified:** `apps/monk/lib/core/theme/tokens.dart` (and web/mobile mirrors)

---

## 1. Color Token Mapping (`ImColors`)

| Legacy Token | Legacy Hex | New Target Token | New Target Hex | Visual Role |
|---|---|---|---|---|
| `coral500` | `#F08A7A` | `primary600` | `#6D3FF0` | Primary buttons, active nav pills, focus ring |
| `coral600` | `#E06A57` | `primary500` | `#8F68FF` | Lighter primary accent, hover states |
| `coral100` | `#FBE3DE` | `primary100` | `#EDE7FD` | Active nav pill fill, selected card background |
| `teal700` | `#2E5A6B` | `secondary600` | `#EC4899` | Secondary accent, notification dot highlight |
| `teal800` | `#20414E` | `secondary600` | `#EC4899` | Secondary brand color |
| `teal100` | `#DCE8EC` | `secondary100` | `#FCE4F1` | Tinted secondary background fills |
| `cream50` | `#F7F5EE` | `surface` | `#FAFAFC` | App canvas background |
| `cream100` | `#EFEDE4` | `surfaceSecondaryCard` | `#FBFBFD` | Secondary nested card background |
| `ink900` | `#1D2B32` | `ink900` | `#1A1A2E` | Headings, primary text, high-contrast KPI numbers |
| `ink600` | `#5A6B72` | `ink600` | `#6B7280` | Body text, secondary labels |
| `ink300` | `#B9C2C6` | `ink300` | `#ECECF3` | Hairline borders, dividers, disabled states |
| `success600` | `#2E7D5B` | `success600` | `#059669` | Positive trend %, "Live" badge |
| `success100` | `#DBEEE5` | `success100` | `#D1FAE5` | Mint stat chip background |
| `warning600` | `#B97A1B` | `warning600` | `#D97706` | Warning badge text |
| `warning100` | `#F7E9D2` | `warning100` | `#FEF3C7` | Amber stat chip background |
| `danger600` | `#C24E3A` | `danger600` | `#DB2777` | Negative trend %, "Hot" badge |
| `danger100` | `#F6DEDA` | `danger100` | `#FCE7F3` | Pink stat chip background |
| `info600` | `#3A6EA5` | `info600` | `#2563EB` | Information badge text |
| `info100` | `#DEE9F4` | `info100` | `#DBEAFE` | Blue stat chip background |

---

## 2. New Category Stat Chip Tokens

| Token Pair Name | Background Hex | Icon/Text Hex | Category Usage |
|---|---|---|---|
| `accentLavender` | `#EDE7FD` | `#6D3FF0` | Active Campaigns / Followers |
| `accentPink` | `#FCE7F3` | `#DB2777` | Creators Collaborating / Total Reach |
| `accentAmber` | `#FEF3C7` | `#D97706` | Total Reach / Engagement Rate |
| `accentMint` | `#D1FAE5` | `#059669` | Engagement Rate / Brand Collabs |
| `accentBlue` | `#DBEAFE` | `#2563EB` | Total Spend / Earnings |

---

## 3. Radii Scale Mapping (`ImRadii`)

| Token | Legacy Value | New Target Value | Element Usage |
|---|---|---|---|
| `radiusSm` | `8.0` | `8.0` | Badges, small tags |
| `radiusMd` | `12.0` | `16.0` | Buttons, text fields, goal cards |
| `radiusLg` | `20.0` | `24.0` | Cards, hero containers, floating panels |
| `radiusFull` | `999.0` | `999.0` | Pill buttons, avatars, nav chips |

---

## 4. Shadow & Surface Physics Mapping (`ImShadows`)

| Token | Legacy Spec | New Target Spec | Surface Behavior |
|---|---|---|---|
| `ImShadows.card` | Border only (`ink300`) | `0 10px 40px rgba(60,45,100,0.05)` + `1px solid #ECECF3` | Default resting card |
| `ImShadows.float` | `0 4px 16px rgba(0,0,0,0.10)` | `0 14px 48px rgba(60,45,100,0.12)` | Floating card on hover |
