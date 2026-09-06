# Bareminimum-Design Foundations

This reference provides the structural building blocks for starting any project cleanly. It defines the typography, spacing, project-tailored color palettes, purposeful animations, Lucide icon patterns, and layout architectures.

---

## 1. Typographic System

Use a clear, mathematically consistent type scale with a minimum 1.25 multiplier between tiers. Never allow body copy or interactive controls to dip below legible thresholds.

### Scale & Tokens

| Token | Size | Line Height | Weight | Intended Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `--bm-text-3xl` | 2.5rem (40px) | 1.15–1.2 | 700 / 650 | Main page title / primary hero statement |
| `--bm-text-2xl` | 2.0rem (32px) | 1.2 | 650 | Major section heading (`<h2>`) |
| `--bm-text-xl` | 1.5rem (24px) | 1.25 | 600 | Sub-section header (`<h3>`) |
| `--bm-text-lg` | 1.25rem (20px) | 1.35 | 600 | Card title, panel header, modal title |
| `--bm-text-base` | 1.0rem (16px) | 1.55–1.65 | 400 | **Baseline body copy**, articles, paragraphs |
| `--bm-text-sm` | 0.875rem (14px) | 1.4 | 500 / 400 | Buttons, input fields, navigation links, table cells |
| `--bm-text-xs` | 0.75rem (12px) | 1.4 | 500 | **Strict Floor**: timestamps, badges, small table captions |

> [!IMPORTANT]
> **Strict Font Rules**:
> 1. **No body text below 16px** (`1rem`) on desktop or mobile.
> 2. **No functional text below 12px** anywhere in the product.
> 3. **Never place mini-titles / kickers / uppercase tags above headings**. Fold category names directly into the heading or breadcrumb.

---

## 2. Project-Tailored Color Scheme Methodology

Never pick random colors, and **avoid harsh, jarring high-contrast buttons** that feel disconnected from the canvas. Every project must derive a cohesive, tailored palette directly from the subject matter, brand personality, and physical material of the product.

### The 5-Token Harmonic Family
1. **Canvas & Surfaces (`--bm-bg`, `--bm-surface`, `--bm-surface-raised`)**:
   - Clean, refined tonal steps.
   - Light: `#fafafa` canvas, `#ffffff` raised cards, `#f4f4f5` secondary wells. Clean and soft, never sterile cold gray or muddy yellow.
   - Dark: `#111215` deep tone canvas, `#18191e` card wells, `#1f2026` raised interactive planes. Clean zinc/slate depth, never harsh eye-straining `#000000` or washed-out gray.
2. **Project Brand Anchor (`--bm-accent`)**:
   - Derived directly from the subject:
     - *Strawberry/Berry product*: Ripe ruby / coral red (`#e11d48` or `#f43f5e`) with strawberry cream accents (`#fff1f2`).
     - *Clean tech / Infrastructure*: Sapphire or deep cyan slate.
     - *Cyber/Security*: Deep emerald or crisp obsidian with amber accents.
     - *Fitness/Performance*: Electric berry, clean citrus, or carbon slate.
3. **Harmonic Action Button (`--bm-button`)**:
   - Must harmonize with the surface palette. Avoid stark black rectangular blocks that look like warning alerts.
   - Use the brand anchor with subtle 1px elevation (`transform: translateY(-1px)` on hover, `translateY(1px)` on active click).
4. **Ink Hierarchy (`--bm-ink`, `--bm-ink-muted`, `--bm-ink-subtle`)**:
   - High contrast without harsh pure `#000000`: `#18181b` for primary text, `#52525b` for readable descriptions, `#71717a` for secondary metadata.
5. **Crisp Structural Rules (`--bm-border`, `--bm-border-strong`)**:
   - Soft, measured borders (`#e4e4e7` in light, `#27272a` in dark).

---

## 3. Purposeful, High-Taste Animation

The anti-slop standard bans cartoonish bounce/elastic physics, auto-scrolling marquees, and layout property thrashing (`width`, `height`). It **encourages purposeful animations that enhance user orientation and tactile feedback**:

### Where Animation Makes Sense:
1. **Mount & Reveal Stagger**:
   - Subtle upward settle (`opacity: 0` + `translateY(10px)` $\rightarrow$ `opacity: 1` + `translateY(0)`).
   - Duration: 250ms–350ms with `cubic-bezier(0.16, 1, 0.3, 1)`.
   - Stagger child elements by 50ms–80ms for an editorial cadence.
2. **Tactile Button Press**:
   - Hover: `transform: translateY(-1px); box-shadow: var(--bm-shadow-md);`
   - Active (click): `transform: translateY(1px); box-shadow: var(--bm-shadow-sm);`
   - Fast, snappy transition (`150ms`).
3. **Interactive Metric & State Toggles**:
   - Dynamic calculators (e.g. 1 scoop vs 2 scoops in preworkout, monthly vs annual pricing, volume switches).
   - Transitions in progress bars or numbers using smooth CSS transitions.
4. **Interactive Tabs & Filters**:
   - Sliding pill switches (`.bm-pill-switch`) where the active highlight transitions smoothly between tabs.
5. **Product Visual Inspection**:
   - Gentle, purposeful hover elevation (subtle depth or glow shift, never a jarring 1.08x scale or rotational wobble).

---

## 4. Lucide Iconography System

Replace giant, floating, rounded gradient icon boxes with [Lucide](https://lucide.dev/) icons integrated directly into the typographic rhythm.

### Sizing and Stroke Conventions
- **Standard Stroke Width**: Always `1.75px` or `2.0px` (`stroke-width="2"`). Do not use thin hairline 1px or heavy 3px strokes.
- **Bounding Box Standards**:
  - `16px` (`size-4` / `1rem`): Inside buttons, inline links, table action rows, compact form controls.
  - `20px` (`size-5` / `1.25rem`): Navigation sidebars, section list headers, standard card titles.
  - `24px` (`size-6` / `1.5rem`): Major page headers, empty-state illustrations, standalone toolbar actions.

### Implementation Patterns

#### A. Inside Buttons (Inline Optical Alignment)
```html
<button class="bm-button">
  <svg class="bm-icon" viewBox="0 0 24 24">
    <!-- Lucide: Plus -->
    <path d="M5 12h14M12 5v14"/>
  </svg>
  <span>Create Project</span>
</button>
```

#### B. In Card / Section Headers (Side-by-Side, Not Stacked)
```html
<div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.5rem;">
  <svg class="bm-icon" style="color: var(--bm-accent);" viewBox="0 0 24 24">
    <!-- Lucide: Zap -->
    <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
  </svg>
  <h3 style="margin: 0; font-size: var(--bm-text-lg);">Clinical Formulation</h3>
</div>
<p style="color: var(--bm-ink-muted);">Fully transparent ingredient doses backed by peer-reviewed athletic performance trials.</p>
```

---

## 5. Anti-Slop Layout Architectures

Rather than defaulting to the standard AI template (Centered Hero + 3-card icon grid + 3 metric boxes), use these functional layout structures:

### Architecture A: The 2-Column Split Hero (Landing / Introduction)
- **Left Column (55%)**:
  - Direct, confident `<h1>` (e.g. "Unicorn Strawberry High-Performance Pre-Workout").
  - Factual explanation paragraph (max 2–3 sentences, no buzzwords).
  - Primary action button + secondary formula link.
  - Contextual specs summary.
- **Right Column (45%)**:
  - Authentic interactive preview: live scoop selector, nutritional breakdown, or interactive bottle/tub schematic.

### Architecture B: The Editorial River (Feature Showcase)
- Staggered horizontal bands pairing feature mechanics with component previews, separated by clean 1px rules.

### Architecture C: The Data-Dense Workspace (Web App / Supplement Facts Table)
- Clean, semantic tabular breakdown of active ingredients, exact milligram dosages, and clinical purposes.
