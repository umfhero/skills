---
name: bareminimum-design
description: "Foundational, clean starter design system that eradicates AI slop design traits and enforces robust UI/UX structure for new and existing projects. Enforces strict bans on tiny fonts (<14px), mini-titles/kickers above headings, purple/violet gradients, dark-mode neon glows, identical 3-card grids, and oversized icon tiles. Enforces cohesive, project-derived color palettes (avoiding harsh jarring button contrast), clean light/dark surface systems, curated Lucide icons, and purposeful, high-taste animations. Use this skill at the inception of any web application, site, tool, or UI component to prevent vibe-coded AI aesthetic defaults."
description: "Foundational, clean starter design system that eradicates AI slop design traits and enforces robust UI/UX structure for new and existing projects. Enforces strict bans on tiny fonts (<14px), mini-titles/kickers above headings, purple/violet gradients, dark-mode neon glows, identical 3-card grids, and oversized icon tiles. Enforces cohesive project-derived color palettes, expansive modern page widths (1440px), full-bleed edge-to-edge headers, proper tactile toggle buttons, curated Lucide icons, and purposeful animations. Use this skill at the inception of any web application, site, tool, or UI component to prevent vibe-coded AI aesthetic defaults."
---

# Bareminimum-Design

Build clean, honest, and robust user interfaces from day one. This skill serves as the starter baseline for all projects: it strips away the recognizable visual and structural tells of AI-generated web interfaces while supplying a bare-bones, highly functional design foundation that supports any product direction.

The goal is not to force a narrow artistic theme, but to guarantee that the very first iteration of your project never looks like generic AI slop or lazy "vibe coding."

---

## Quick Reference Links

- [references/anti-slop-catalog.md](references/anti-slop-catalog.md) — Exhaustive catalog of 66+ AI slop patterns from [impeccable.style/slop](https://impeccable.style/slop/) and [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) mapped to quality design alternatives.
- [references/foundations.md](references/foundations.md) — Core tokens, typographic scales, project-tailored color methodologies, purposeful animations, Lucide icon patterns, and layout architectures.
- [assets/bareminimum.css](assets/bareminimum.css) — Lightweight drop-in stylesheet with baseline resets, anti-slop typography floors, refined light/dark palettes, and animation helpers.
- [assets/bareminimum.css](assets/bareminimum.css) — Lightweight drop-in stylesheet with baseline resets, anti-slop typography floors, expansive width (1440px), fluid edge-to-edge header classes, refined palettes, and animation helpers.

---

## Core Design Principles
## Core Non-Negotiable Rules

### 1. Project-Tailored, Cohesive Color Palette
- **Derive colors directly from the project concept**: Never pick random defaults. A strawberry product uses ripe berry ruby/coral (`#e11d48`) and soft strawberry cream (`#fff1f2`); an enterprise cloud tool uses deep slate and sapphire.
- **No jarring button contrast**: Avoid harsh, stark black or neon warning blocks that feel detached from the page. Action buttons must belong to the project's harmonic color family with subtle tactile depth.
### 1. STRICT BAN: No Mini-Titles, Badges, Pills, or Kickers Above Headings
- **The heading must be the first element the reader's eye encounters.**
- **NEVER** place any tracked uppercase tag, category label, flavor pill, release badge, or kicker above the `<h1>` or `<h2>` (e.g. do NOT put `<div class="tag">Limited Release</div><h1>Title</h1>`).
- Category names, badges, or version tags belong **below** the heading or woven naturally into the lead paragraph.

### 2. Expansive Modern Canvas Width (Never Constricted)
- **NO cramped narrow containers**: Avoid squeezing desktop content into a 1100px–1200px box stranded in the center of a wide monitor.
- Use a modern generous max-width of **`1440px`** with fluid responsive side padding (`padding: 0 max(1.5rem, 3.5vw)`).

### 3. Full-Bleed Edge-to-Edge Headers
- The masthead header must span the **full viewport width** from left to right (use `.bm-header-fluid`).
- Pin the brand identity on the far left and navigation/actions on the far right, avoiding huge empty voids on the sides.

### 4. Real, Tactile Buttons for All Controls
- Toggles, switches, and option selectors (e.g. 1 Scoop vs 2 Scoops, Monthly vs Annual) must be **proper, distinct buttons** (`.bm-toggle-btn` inside `.bm-button-group`), with dedicated padding, solid hover effects, and crisp active states.
- Never output flimsy inline text with raw borders or squished pills as interactive selectors.
- Primary actions use the project's cohesive brand color with tactile hover/press states (`translateY(-1px)` hover, `translateY(1px)` active).

### 5. Project-Tailored, Cohesive Color Palette
- **Derive colors directly from the project concept**: A strawberry product uses ripe berry ruby (`#e11d48`) and strawberry cream (`#fff1f2`); an enterprise tool uses deep slate and sapphire.
- **No jarring button contrast**: Avoid stark black or alarming neon alert blocks that feel detached from the canvas. Action buttons must harmonize with the project palette.
- **Clean Light / Dark Palettes**:
  - *Light*: Soft zinc/stone neutrals (`#fafafa` canvas, `#ffffff` raised cards, `#f4f4f5` wells) with soft borders (`#e4e4e7`).
  - *Dark*: Deep zinc/slate steps (`#111215` canvas, `#18191e` cards, `#1f2026` active planes) with soft borders (`#27272a`). Zero muddy grays, zero harsh `#000000`.

### 2. Purposeful Animations That Make Sense
- **No tacky bounce or elastic overshoots**: Never use rubber-band or bouncy dialog animations.
- **No layout property thrash**: Never animate `width`, `height`, `margin`, or `padding`. Animate only hardware-accelerated `transform` and `opacity`.
- **Use animations where they enhance function & feel**:
  - Staggered mount reveals (`opacity` + subtle 8px `translateY`, 250ms–350ms, ease-out).
  - Tactile button presses (`translateY(-1px)` on hover, `translateY(1px)` on active click).
  - Dynamic interactive metric transitions (e.g. dosage toggles, sliders, tab pills).
  - Always respect `@media (prefers-reduced-motion: reduce)`.
### 6. Purposeful Animations That Make Sense
- **No tacky bounce or elastic overshoots**: Interface motion must settle cleanly.
- **No layout property thrash**: Animate only `transform` and `opacity` with smooth ease-out curves (`cubic-bezier(0.16, 1, 0.3, 1)`).
- **Use animations where they enhance function & feel**: Staggered entrance on mount, tactile button feedback, and dynamic interactive metric transitions.

### 3. Non-Negotiable Visual & Typography Bans
- **NO mini-titles / kickers / uppercase eyebrows above headings**: Fold context into the heading or breadcrumb.
### 7. Non-Negotiable Bans
- **NO tiny functional fonts**: Zero body copy below 16px (`1rem`). Zero secondary or functional text below 12px (`0.75rem`).
- **NO flat type hierarchy**: Font size steps between heading levels and body copy must maintain a multiplier of at least 1.25x.
- **NO purple-to-blue or violet gradients**: Banned on buttons, text, cards, and backgrounds.
- **NO dark mode glowing neon boxes**: Saturated `box-shadow` glows and neon borders are banned.
- **NO identical 3-card feature grids**: Use asymmetric 2-column splits, editorial rivers, or structured data tables.
- **NO Cardocalypse (nested cards)**: Flatten container depth with whitespace and dividers.
- **NO massive icon tiles stacked above headings**: Use standard [Lucide](https://lucide.dev/) icons (16px–20px) aligned inline with text.
- **NO marketing buzzwords or dangling "-ing" puffery**: State literal facts and capabilities.

---

## Pre-Flight Anti-Slop Checklist

Before delivering or approving any UI work, verify every item on this checklist:

- [ ] **Cohesive Project Palette**: Is the color palette specifically tailored to the project's identity, with buttons that feel integrated rather than jarringly high-contrast?
- [ ] **Clean Light/Dark Surfaces**: Are the surface steps clean and refined (zinc/slate), avoiding muddy tones or pitch-black smearing?
- [ ] **Purposeful Motion**: Are animations used where they make sense (staggered mount, tactile hover/active, interactive state changes) with zero bounce easing?
- [ ] **No kicker / badge above H1**: Is the heading the very first element at the top of the content block?
- [ ] **Full-bleed header**: Does the header navigation span edge-to-edge across the screen?
- [ ] **Generous container width**: Is the layout container set to 1440px rather than a narrow squished box?
- [ ] **Proper button controls**: Are selectors and toggles built with proper, tactile button styling rather than raw outlines?
- [ ] **Cohesive Project Palette**: Is the color palette tailored to the project, with buttons that feel integrated?
- [ ] **Clean Light/Dark Surfaces**: Are surface steps clean (zinc/slate), avoiding muddy tones or pitch-black smearing?
- [ ] **Purposeful Motion**: Are animations smooth (staggered mount, tactile hover/active, interactive state changes) with zero bounce?
- [ ] **No tiny text**: Is all body text $\ge$ 16px? Is all secondary text $\ge$ 12px?
- [ ] **No mini-titles/kickers**: Are all headings free from floating uppercase tags above them?
- [ ] **No purple/violet gradients**: Are buttons, cards, and backgrounds solid and intentional?
- [ ] **No glowing cards**: Is dark mode free from colored box-shadows and neon halos?
- [ ] **No 3-card clones**: Does the layout use split columns, data rows, or varied composition instead of identical feature boxes?
- [ ] **No 3-card clones**: Does the layout use split columns, data rows, or varied composition?
- [ ] **Inline Lucide icons**: Are icons from Lucide, sized 16px–20px, and aligned inline with text?
- [ ] **Reduced motion supported**: Does `@media (prefers-reduced-motion: reduce)` disable non-essential motion?
- [ ] **Factual microcopy**: Are buzzwords ("supercharge", "revolutionary", "seamless") eliminated?

---

## Scoring Rubric

Rate the initial UI draft 1–10 on each dimension:

| Dimension | Question |
| :--- | :--- |
| **Header & Canvas Scope** | Is the header full-bleed and the page container wide (1440px) and expansive? |
| **Heading Purity** | Is the main heading 100% free of mini-titles, tags, or kickers above it? |
| **Control Quality** | Are all interactive options styled as real, tactile, properly padded buttons? |
| **Color Harmony** | Does the palette fit the product identity with cohesive, tactile buttons? |
| **Animation Quality** | Are animations purposeful, performant, and free from bounce or layout thrash? |
| **Legibility** | Is typography crisp, readable, well-spaced, and free from undersized text? |
| **Surface Restraint** | Are surfaces clean, grounded, and free from purple gradients or neon glows? |
| **Structural Variety** | Does the layout fit the specific content rather than forcing a 3-box clone? |

**Score below 40/50: Refactor against the Core Design Principles before proceeding.**
**Score below 40/50: Refactor against the Core Non-Negotiable Rules before proceeding.**
