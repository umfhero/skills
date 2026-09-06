# Bareminimum-Design Foundations

This reference provides the structural building blocks for starting any project cleanly. It defines the typography, expansive canvas architecture, full-bleed headers, proper button controls, project-tailored color palettes, purposeful animations, and Lucide icon patterns.

---

## 1. Canvas & Layout Architecture

Never cram desktop content into a narrow, squished column that leaves huge empty voids on wide screens.

### Expansive 1440px Container
- **Standard Width**: `max-width: 1440px;` with fluid responsive horizontal padding (`padding: 0 max(1.5rem, 3.5vw);`).
- Allows 2-column heroes, data grids, and editorial flows to breathe naturally across high-resolution displays.

### Full-Bleed Edge-to-Edge Masthead
- **Rule**: The header must span the **full viewport width** from left edge to right edge:
```html
<header class="site-header">
  <div class="bm-header-fluid">
    <a href="/" class="brand-link">...</a>
    <nav class="header-nav">...</nav>
  </div>
</header>
```
- Pin the brand identity on the far left and navigation/actions on the far right (`justify-content: space-between; padding-left: max(1.5rem, 3vw); padding-right: max(1.5rem, 3vw);`).

---

## 2. Heading Purity (Strict Ban on Mini-Titles & Badges Above Headings)

> [!CAUTION]
> **Strict Ban**: NEVER place any mini-title, tag, badge, pill, or uppercase kicker above an `<h1>` or `<h2>`.
> - **WRONG**:
>   ```html
>   <!-- AI SLOP TELL: Badge/kicker floating over heading -->
>   <div class="badge">Limited Release • 40 Servings</div>
>   <h1>Unicorn Strawberry Pre-Workout</h1>
>   ```
> - **RIGHT**:
>   ```html
>   <!-- QUALITY: Heading is the primary visual anchor -->
>   <h1>Unicorn Strawberry High-Potency Pre-Workout</h1>
>   <p class="hero-lead">Limited batch release of 40 clinical servings...</p>
>   ```
> Supporting metadata or badges must sit **below** the heading or inside contextual description blocks.

---

## 3. Real, Tactile Button Controls

Interactive selectors (dose selectors, frequency toggles, size options, tier switches) must never look like raw text links or squished border outlines. They must be built as **proper, distinct, tactile buttons**.

### Proper Toggle Button Pattern
```html
<div class="bm-button-group" role="group" aria-label="Serving size">
  <button type="button" class="bm-toggle-btn is-active" aria-pressed="true">
    <svg class="bm-icon" viewBox="0 0 24 24"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
    <span>1 Scoop (Focus)</span>
  </button>
  <button type="button" class="bm-toggle-btn" aria-pressed="false">
    <svg class="bm-icon" viewBox="0 0 24 24"><path d="M13 2 3 14h9l-1 8 10-12h-9l1-8z"/></svg>
    <span>2 Scoops (Clinical Peak)</span>
  </button>
</div>
```

---

## 4. Typographic System

Use a clear, mathematically consistent type scale with a minimum 1.25 multiplier between tiers.

| Token | Size | Line Height | Weight | Intended Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `--bm-text-3xl` | 2.75rem (44px) | 1.15 | 750 / 700 | Main page title / primary hero statement |
| `--bm-text-2xl` | 2.0rem (32px) | 1.2 | 650 | Major section heading (`<h2>`) |
| `--bm-text-xl` | 1.5rem (24px) | 1.25 | 600 | Sub-section header (`<h3>`) |
| `--bm-text-lg` | 1.25rem (20px) | 1.35 | 600 | Card title, panel header, modal title |
| `--bm-text-base` | 1.0rem (16px) | 1.55–1.65 | 400 | **Baseline body copy**, articles, paragraphs |
| `--bm-text-sm` | 0.875rem (14px) | 1.4 | 500 / 400 | Buttons, input fields, navigation links, table cells |
| `--bm-text-xs` | 0.75rem (12px) | 1.4 | 500 | **Strict Floor**: timestamps, badges, small table captions |

---

## 5. Project-Tailored Color Scheme Methodology

Never pick random colors, and **avoid harsh, jarring high-contrast buttons** that feel disconnected from the canvas. Every project must derive a cohesive, tailored palette directly from the subject matter, brand personality, and physical material of the product.

### The 5-Token Harmonic Family
1. **Canvas & Surfaces (`--bm-bg`, `--bm-surface`, `--bm-surface-raised`)**:
   - Clean, refined tonal steps.
   - Light: `#fafafa` canvas, `#ffffff` raised cards, `#f4f4f5` secondary wells. Clean and soft, never sterile cold gray or muddy yellow.
   - Dark: `#111215` deep tone canvas, `#18191e` card wells, `#1f2026` raised interactive planes.
2. **Project Brand Anchor (`--bm-accent`)**:
   - Derived directly from the subject:
     - *Strawberry/Berry product*: Ripe ruby / coral red (`#e11d48` or `#f43f5e`) with strawberry cream accents (`#fff1f2`).
     - *Clean tech / Infrastructure*: Sapphire or deep cyan slate.
     - *Audio/Hardware*: Matte carbon slate (`#1e293b`) with amber or titanium accents.
3. **Harmonic Action Button (`--bm-button`)**:
   - Harmonizes with the surface palette. Avoid stark black rectangular blocks that look like warning alerts.
   - Use the brand anchor with subtle 1px elevation (`transform: translateY(-1px)` on hover, `translateY(1px)` on active click).
4. **Ink Hierarchy (`--bm-ink`, `--bm-ink-muted`, `--bm-ink-subtle`)**:
   - High contrast without harsh pure `#000000`: `#18181b` for primary text, `#52525b` for descriptions, `#71717a` for secondary metadata.
5. **Crisp Structural Rules (`--bm-border`, `--bm-border-strong`)**:
   - Soft, measured borders (`#e4e4e7` in light, `#27272a` in dark).

---

## 6. Purposeful, High-Taste Animation

The anti-slop standard bans cartoonish bounce/elastic physics, auto-scrolling marquees, and layout property thrashing (`width`, `height`). It **encourages purposeful animations that enhance user orientation and tactile feedback**:

1. **Mount & Reveal Stagger**:
   - Subtle upward settle (`opacity: 0` + `translateY(12px)` $\rightarrow$ `opacity: 1` + `translateY(0)`).
   - Duration: 250ms–350ms with `cubic-bezier(0.16, 1, 0.3, 1)`.
   - Stagger child elements by 60ms for an editorial cadence.
2. **Tactile Button Press**:
   - Hover: `transform: translateY(-1px); box-shadow: var(--bm-shadow-md);`
   - Active (click): `transform: translateY(1px); box-shadow: var(--bm-shadow-sm);`
3. **Interactive Metric & State Toggles**:
   - Dynamic calculators (e.g. 1 scoop vs 2 scoops, model selector, frequency toggle).
   - Smooth numeric and progress transitions.
4. **Always respect `@media (prefers-reduced-motion: reduce)`**.
