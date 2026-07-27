# Grok Design Opinion — Soft Premium UI Redesign

**Source of truth:** [`docs/design/design_context2.md`](../design/design_context2.md)  
**Design system:** Soft Premium Creator Platform  
**Product:** Influencer Monk (Flutter)

This folder holds the implementation plan for migrating the Flutter UI from the current coral/teal/cream “admin-portal” look to the soft, purple-led, human creator platform defined in the master design prompt.

## Documents

| File | Purpose |
|---|---|
| [`IMPLEMENTATION_PLAN.md`](./IMPLEMENTATION_PLAN.md) | Full plan: gap analysis, tokens, components, navigation, screens, phases, PR DAG, testing, risks |
| [`TOKEN_MIGRATION.md`](./TOKEN_MIGRATION.md) | Current → target token map and rename strategy |
| [`SCREEN_INVENTORY.md`](./SCREEN_INVENTORY.md) | Screen inventory with redesign priority and target composition |
| [`mockups/`](./mockups/) | **Interactive HTML/CSS/JS Soft Premium mockups** (open in a browser) |

## HTML mockups

Open [`mockups/index.html`](./mockups/index.html) in a browser (no build step).

| Mockup | File | What it shows |
|---|---|---|
| Gallery | `mockups/index.html` | Entry page + design swatches |
| Brand dashboard | `mockups/brand-dashboard.html` | Top nav, hero, metrics, campaigns, rail |
| Creator dashboard | `mockups/creator-dashboard.html` | Playful creator home + tasks + earnings |
| Creator mobile | `mockups/creator-mobile.html` | Phone frame, bottom nav + FAB |
| Create campaign | `mockups/campaign-create.html` | Stepper, soft form, preview rail |
| Login | `mockups/login.html` | Auth split layout, purple focus |
| Characters | `mockups/characters.html` | Avatar cast, mascots, sizes, stacks |

Shared assets:

- `mockups/css/tokens.css` — design_context2 tokens  
- `mockups/css/base.css` — nav, layout  
- `mockups/css/components.css` — cards, buttons, metrics, forms  
- `mockups/js/main.js` — carousels, chips, toasts, task toggles  
- `mockups/css/avatars.css` — character sizes, stacks, figures  
- `mockups/css/backgrounds.css` — ambient page backgrounds (orbs, grid, waves, floating graphics)  
- `mockups/assets/chars/*.svg` — creator faces, brand mark, mascots  
- `mockups/js/main.js` — injects background scene + UI interactions  

**Quick open (Windows):**

```powershell
start docs/grok_design_opinion/mockups/index.html
```

## Related references

- Design system: `docs/design/design_context2.md`
- Earlier Collabify-oriented notes: `docs/design/design_context.md`
- Visual samples: `docs/design_samples/`
- Canonical app (recommended): `apps/monk/`
- Near-duplicate web app: `apps/web/`
- Mobile shell: `apps/mobile/`

## Quick thesis

The codebase already has the right **architecture** (token classes, `AppTheme` portals, `im_*` widgets, portal shells). What must change is the **visual language** (palette, radii, elevation, type scale), **chrome** (sidebar → top/floating nav), and **page composition** (heroes, airy cards, illustrated states instead of dense KPI wraps and spinner-only loading).

Implementation should be **token-first, component-second, high-traffic screens third**, with golden tests as the regression gate.
