# Gemini Design Opinion — Soft Premium UI Redesign

**Source of truth:** [`docs/gemini_design_opinion/design_context_2.md`](./design_context_2.md)  
**Design system:** Soft Premium Creator Platform  
**Product:** Influencers Monk (Flutter Web, Desktop & Mobile)

This folder contains Gemini's canonical implementation strategy, token migration guide, screen inventory, and interactive HTML/CSS/JS prototype mockups for transforming the Flutter application UI from the legacy coral/teal/cream palette into the soft, vibrant, purple-led creator platform.

---

## 📁 Document Registry

| File | Description |
|---|---|
| [`design_context_2.md`](./design_context_2.md) | Canonical v2.0 design context specification (tokens, typography, surface physics, component specs). |
| [`IMPLEMENTATION_PLAN.md`](./IMPLEMENTATION_PLAN.md) | 5-phase engineering implementation plan, architecture, PR breakdown, and regression testing strategy. |
| [`TOKEN_MIGRATION.md`](./TOKEN_MIGRATION.md) | Exact token-by-token migration map from legacy `ImColors` to `design_context_2.md`. |
| [`SCREEN_INVENTORY.md`](./SCREEN_INVENTORY.md) | Screen inventory across all 29 feature modules with redesign priority matrix. |
| [`mockups/`](./mockups/index.html) | Interactive HTML/CSS/JS prototype suite demonstrating live components and screens. |

---

## 🎨 Interactive Prototypes

Launch the HTML/CSS/JS mockups by opening [`docs/gemini_design_opinion/mockups/index.html`](./mockups/index.html) in any modern browser:

- 📊 [**Brand Dashboard Prototype**](./mockups/brand-dashboard.html) — 3-column desktop layout, Brand Score card, 5 KPI stat tiles, Active Campaigns carousel, spend overview chart.
- 👩‍🎤 [**Creator Dashboard Prototype**](./mockups/creator-dashboard.html) — Creator profile & mascot hero card, influence score chart, 4 stat tiles, Brands carousel, gamified task list, dark earnings panel.
- ✨ [**Campaign Create Form Prototype**](./mockups/campaign-create.html) — 5-step form stepper, interactive goal cards grid, 3D target pro tip card, live campaign preview.

---

## 💡 Core Design Thesis

1. **Human & Inspiring over Corporate**: Every screen leads with emotion and encouragement before data density.
2. **Signature Purple System**: Anchored around `#6D3FF0` (Primary Violet) and `#EC4899` (Secondary Pink) with multi-stop gradients for focal cards.
3. **Dual Surface Physics**: White cards use a dual-layer treatment: a `1px solid #ECECF3` hairline stroke paired with an ultra-soft spread shadow (`0 10px 40px rgba(60, 45, 100, 0.05)`).
4. **3-Tier Typography**: Combines `Baloo2` display headlines, `Caveat`/`Satisfy` handwritten script accents for creator greetings (*"Hey Ananya!"*), `Inter` body text, and tabular figures for metrics.
