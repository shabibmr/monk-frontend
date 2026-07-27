# Influencer Monk — Master Design Prompt

**Version:** 1.1  
**Design system:** Soft Premium Creator Platform  
**Style:** Modern · Human · Friendly · Premium · Minimal · Flat  
**Platforms:** Desktop Web · Tablet · Mobile

---

## Role

You are designing **Influencer Monk**, a social-first creator platform for creators and brands.

This is **not** an ERP, CRM, or corporate business dashboard.  
Every screen should feel closer to **Instagram, Notion, Arc Browser, Linear, Apple, Airbnb, and Spotify** than Salesforce or SAP.

---

## Core Philosophy

Every screen should feel like:

> “This platform was built for ME.”

- The UI should feel **alive, encouraging, and positive**
- Every interaction should **reward the user psychologically**
- Creators should feel **excited to create**
- Brands should feel **powerful but never corporate**
- Tone of the product: **I can do this** — never **I have work to do**

---

## Overall Feel

**Do:** premium, soft, airy, bright, comfortable, rounded, calm, happy, positive, organic, friendly, minimal, elegant, human  

**Never:** aggressive, dense, technical, corporate, spreadsheet-like, intimidating

---

## Color Palette

### Surfaces
| Token | Hex |
|---|---|
| Primary background | `#FAFAFC` |
| Alternative background | `#FCFBFF` |
| Cards | `#FFFFFF` |
| Secondary cards | `#FBFBFD` |
| Borders | `#ECECF3` |
| Dividers | `#F1F2F8` |

### Brand & accents
| Token | Hex |
|---|---|
| Primary purple | `#6D3EF5` |
| Primary hover | `#5A2DE0` |
| Primary pressed | `#4A20C7` |
| Secondary purple | `#8F68FF` |
| Accent pink | `#F46DB4` |
| Accent orange | `#FFB54D` |
| Accent green | `#3BC87A` |
| Accent blue | `#4DA3FF` |
| Error | `#FF5D5D` |
| Warning | `#FFB648` |

### Gradients
Always soft — never harsh.

- **Purple:** `#6D3EF5` → `#B06DFF`
- **Pink:** `#FF6FB7` → `#FFB68D`
- **Background glow:** `#FFFFFF` → `#F9F6FF`
- **Card glow:** `#FFFFFF` → `#FBF9FF`

---

## Elevation & Shape

### Shadows
Very soft only. Cards should feel floating.

```
0 10px 40px rgba(60, 45, 100, 0.06)
```

No harsh or dark shadows.

### Border radius
| Element | Radius |
|---|---|
| Cards | 24 |
| Buttons | 18 |
| Images | 20 |
| Text fields | 16 |
| Chips | 12 |
| Profile images | Circular |

### Glass
Avoid heavy glassmorphism. If used at all:

- ~3% blur
- Light white overlay
- Very soft shadow
- Never reduce readability

---

## Typography

**Primary:** Inter  
**Alternative:** SF Pro Display  
**Fallback:** Roboto

### Scale
| Role | Size |
|---|---|
| Hero | 52 |
| Page title | 42 |
| Section title | 28 |
| Card title | 22 |
| Large number | 40 |
| Body | 16 |
| Small | 14 |
| Caption | 13 |
| Micro | 12 |

### Weight
| Role | Weight |
|---|---|
| Hero / Title / Numbers | 700 |
| Button | 600 |
| Subtitle | 500 |
| Body | 400 |

**Line height:** ~140% (always generous)

---

## Spacing & Layout

Whitespace is a feature. Never compress information. Every section should breathe.

| Token | Value |
|---|---|
| Minimum spacing | 24 |
| Preferred | 32 |
| Luxury | 48 |
| Max page width | 1600px |
| Content width | 1450px |
| Page padding | 40 |
| Card gap | 24 |
| Grid | 12 columns |

Cards should generally stay under **420px height** unless content requires more.

---

## Navigation

Avoid ERP-style left sidebars as the default pattern.

Prefer:

- Top navigation
- Floating navigation
- Rounded, minimal chrome

Structure: **Logo · Nav · Search · Notifications · Messages · Profile**

Navigation should disappear into the design — never dominate it.

### Mobile
- Bottom navigation
- Floating action button
- Large cards
- No tiny text
- Swipe cards / horizontal carousels

### Desktop
- Large hero
- Multi-column layouts
- Floating widgets
- Mixed media layouts
- No spreadsheet appearance

---

## Components

### Cards
Every card needs:

- Rounded corners
- Soft shadow
- Subtle border
- Generous padding
- Minimal text
- Clear hierarchy

**Preferred card structure:** Title → Description → Metrics → Action → Illustration

### Hero (every dashboard starts here)
- Personal greeting
- Large headline
- Encouraging message
- Illustration
- Primary CTA + Secondary CTA

**Creator example**  
Hey Sarah 👋  
Ready to inspire today?

**Brand example**  
Good morning LuxeGlow  
Let’s build another amazing campaign.

### Metrics
Large number → small label → trend → icon → optional mini graph  

Example: **125K** · Followers · **+12%**

### Charts
- Rounded geometry
- Soft gradients
- No grid overload
- Max 2 axis lines
- Prefer rounded line charts

### Buttons
| Type | Treatment |
|---|---|
| Primary | Purple, rounded, large |
| Secondary | White + border |
| Ghost | Text only |
| Danger | Red |

Heights: Desktop **48** · Tablet **44** · Mobile **52**

### Inputs
- Radius 16
- Height 48
- Floating labels
- Large padding
- Soft purple focus glow
- Never harsh browser-blue focus

### Dropdowns
Rounded, white, soft shadow; icons optional

### Chips
Pill shape, soft background, optional colored icon  
Examples: Lifestyle · Beauty · Gaming · Travel · Food · Technology

### Progress bars
Height **10**, rounded, soft purple gradient

### Tables
Avoid by default. Prefer cards, tiles, lists, timelines, expandable rows.  
Use tables only for Analytics, Finance, or Reports.

---

## Content & States

### Illustrations
Large 3D illustrations, creator avatars, mascots, cute objects, plants, campaign objects, shopping bags, megaphones, targets, stars.

**Never** stock office people.

### Imagery
Bright, natural lighting, pastel backgrounds, happy expressions, soft colors, rounded corners.

### Empty states
Always illustrated. Never blank.

Example:  
**No campaigns yet.**  
Let’s create your first one!  
`[Create Campaign]`

### Loading
Skeleton loaders with rounded shapes + animated shimmer. Never spinner-only.

### Success
Confetti, soft animation, positive wording.

### Error
Friendly, explain the solution, never blame the user.

### Forms
Split into sections. Avoid long scrolling walls of fields.  
Use steppers, cards, and preview panels.

### Onboarding
Multi-step, progress indicator, illustration, encouragement — never intimidating.

---

## Motion

- Duration ~**200ms**
- Easing: ease
- Patterns: scale, fade, slide, hover elevation, card glow, button ripple
- Micro-interactions everywhere

---

## Accessibility

- Minimum contrast **AA**
- Clickable area **48×48**
- Keyboard navigation
- Screen reader labels
- Visible focus states

---

## Product Themes

### Creator experience
Feels like Instagram Creator Studio, Pinterest, Spotify Wrapped, Behance — friendly, playful, motivating.

### Brand experience
Feels like Apple Marketing, Linear, Notion, Airbnb — professional without being corporate.

---

## Dashboard Priorities

### Creator dashboard
1. Greeting  
2. Creator Score  
3. Today’s Tasks  
4. Current Campaigns  
5. Recommended Campaigns  
6. Earnings  
7. Content Performance  
8. Tips  
9. Leaderboard  
10. Achievements  

### Brand dashboard
1. Greeting  
2. Campaign Overview  
3. Creator Matches  
4. Spend  
5. ROI  
6. Campaign Timeline  
7. Pending Approvals  
8. Recent Activity  
9. Quick Actions  

---

## Composition Rules

Dashboard sections should **mix**:

- Metrics
- Illustrations
- Photos
- Charts
- Progress
- Lists
- Recommendations

**Never** stack endless tables.  
Prefer visual hierarchy, breathing room, and emotional reward over dense data density.

---

## Output Instruction

When generating any screen, component, or flow for Influencer Monk:

1. Lead with emotion and encouragement, then information.
2. Keep layouts airy, rounded, and premium-soft.
3. Use the purple system as the hero color; accents sparingly for energy.
4. Prefer cards, carousels, and illustrated states over dense admin UI.
5. Make every empty, loading, success, and error state feel human and helpful.
6. Differentiate creator (playful) vs brand (refined) without breaking the shared system.
