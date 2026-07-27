# Claude Design Opinion — Monk Visual Redesign

**Product:** Monk (Flutter) · **Target:** `apps/monk`
**Visual source:** `docs/design_samples/` — four reference screenshots

Migrating the Flutter UI from the current coral/teal/cream admin-portal look to the
violet/pink creator-platform system in the reference screenshots.

## Documents

| File | Purpose |
|---|---|
| [`design_context.md`](./design_context.md) | **The spec.** Tokens, type, elevation, layout, components, accessibility. What the product should look like. |
| [`IMPLEMENTATION_PLAN.md`](./IMPLEMENTATION_PLAN.md) | **The plan.** Phases, PR order, risks, test gates. How to get there. |
| [`TOKEN_MIGRATION.md`](./TOKEN_MIGRATION.md) | Current → target, per token, with the call sites each one breaks |
| [`SCREEN_INVENTORY.md`](./SCREEN_INVENTORY.md) | All 63 screens tiered by priority and effort |
| [`mockups/`](./mockups/) | **The visual contract.** Four working HTML screens. |

## Mockups

```bash
cd docs/claude_design_opinion/mockups && python -m http.server 8777
```

| Page | Demonstrates |
|---|---|
| [`brand-dashboard.html`](./mockups/brand-dashboard.html) | `ShellStyle.flat`, top-nav IA with account overflow, the five-column stat row, campaign carousel, chart |
| [`creator-dashboard.html`](./mockups/creator-dashboard.html) | `ShellStyle.floating`, Caveat hero greeting, `gradientDark` earnings panel, gamified tasks |
| [`creator-mobile.html`](./mockups/creator-mobile.html) | Mobile hero, circular quick actions, four-across stat tiles, tab bar + FAB |
| [`campaign-create.html`](./mockups/campaign-create.html) | Five-step stepper, two-column form, option cards, segmented control, right rail |

They are interactive — the carousel scrolls, the stepper advances, the account menu opens,
the tasks check off. `main.js` is vanilla with no dependencies.

**Invariant:** no hex literal outside `mockups/css/tokens.css` — the same rule `tokens.dart`
enforces in Dart.

```bash
grep -rn '#[0-9a-fA-F]\{6\}' css/ --exclude=tokens.css   # must return nothing
```

## Thesis

The architecture is already right — token classes, `PortalThemeExtension`, an `im_*` widget
library, portal shells, golden tests. Three things change: the **visual language** (palette,
type, radii, elevation), the **chrome** (264px nav sidebar → 72px top bar, the only
architectural change), and the **composition** of four screens. The other 59 inherit.

Sequence: **tokens → components → shell → screens**, with golden tests as the regression gate.

## Two things to know before starting

**1. The palette deliberately diverges from the screenshots.** Six colour pairs in the
reference art fail WCAG AA — `ink600` on `surface` measures 4.48:1, the green trend deltas
3.30:1 at 12px, white on `accentOrange500` 2.26:1. The targets are darkened, with the measured
ratio documented inline at each one. "It matches the mockup" is not a reason to revert them.

**2. Building the mockups already corrected the spec.** `gradientWarm` was specified as a
saturated pink→orange fill carrying white text. Rendered, it was unreadable — and the source
screenshots show a pale wash carrying dark ink. `tokens.css` has the corrected value;
`design_context.md` §1 does not yet. Fix the spec before Phase 1.

That second point is the argument for the mockups existing: the error would have cost a
component rebuild in Dart, and cost twenty minutes in CSS.

## Open decision

The mockup top bar holds 5 labelled items. Brand has 10 routes, creator 9. `brand-dashboard.html`
implements the recommendation — 5 primary, the settings-shaped remainder under the account
menu — but it needs product sign-off before `portal_shell.dart` is rewritten. It blocks only
the shell phase.

## Related

- Reference screenshots: `docs/design_samples/`
- Other opinions: `docs/gemini_design_opinion/`, `docs/grok_design_opinion/`
- Near-duplicate app left on the old theme: `apps/web/` (already drifted — see plan §9)
