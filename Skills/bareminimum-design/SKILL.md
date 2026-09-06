---
name: bareminimum-design
description: "Foundational, clean starter design system that eradicates AI slop design traits and enforces robust UI/UX structure for new and existing projects. Enforces strict bans on tiny fonts (<14px), mini-titles/kickers above headings, purple/violet gradients, dark-mode neon glows, identical 3-card grids, and oversized icon tiles. Enforces cohesive, project-derived color palettes (avoiding harsh jarring button contrast), clean light/dark surface systems, curated Lucide icons, and purposeful, high-taste animations. Use this skill at the inception of any web application, site, tool, or UI component to prevent vibe-coded AI aesthetic defaults."
---

# Bareminimum-Design

Build clean, honest, and robust user interfaces from day one. This skill serves as the starter baseline for all projects: it strips away the recognizable visual and structural tells of AI-generated web interfaces while supplying a bare-bones, highly functional design foundation that supports any product direction.

The goal is not to force a narrow artistic theme, but to guarantee that the very first iteration of your project never looks like generic AI slop or lazy "vibe coding."

---

## Quick Reference Links

- [references/anti-slop-catalog.md](references/anti-slop-catalog.md) — Exhaustive catalog of 66+ AI slop patterns from [impeccable.style/slop](https://impeccable.style/slop/) and [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) mapped to quality design alternatives.
- [references/foundations.md](references/foundations.md) — Core tokens, typographic scales, project-tailored color methodologies, purposeful animations, Lucide icon patterns, and layout architectures.
- [assets/bareminimum.css](assets/bareminimum.css) — Lightweight drop-in stylesheet with baseline resets, anti-slop typography floors, refined light/dark palettes, and animation helpers.

---

## Core Design Principles

### 1. Project-Tailored, Cohesive Color Palette
- **Derive colors directly from the project concept**: Never pick random defaults. A strawberry product uses ripe berry ruby/coral (`#e11d48`) and soft strawberry cream (`#fff1f2`); an enterprise cloud tool uses deep slate and sapphire.
- **No jarring button contrast**: Avoid harsh, stark black or neon warning blocks that feel detached from the page. Action buttons must belong to the project's harmonic color family with subtle tactile depth.
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

### 3. Non-Negotiable Visual & Typography Bans
- **NO mini-titles / kickers / uppercase eyebrows above headings**: Fold context into the heading or breadcrumb.
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
- [ ] **No tiny text**: Is all body text $\ge$ 16px? Is all secondary text $\ge$ 12px?
- [ ] **No mini-titles/kickers**: Are all headings free from floating uppercase tags above them?
- [ ] **No purple/violet gradients**: Are buttons, cards, and backgrounds solid and intentional?
- [ ] **No glowing cards**: Is dark mode free from colored box-shadows and neon halos?
- [ ] **No 3-card clones**: Does the layout use split columns, data rows, or varied composition instead of identical feature boxes?
- [ ] **Inline Lucide icons**: Are icons from Lucide, sized 16px–20px, and aligned inline with text?
- [ ] **Reduced motion supported**: Does `@media (prefers-reduced-motion: reduce)` disable non-essential motion?
- [ ] **Factual microcopy**: Are buzzwords ("supercharge", "revolutionary", "seamless") eliminated?

---

## Scoring Rubric

Rate the initial UI draft 1–10 on each dimension:

| Dimension | Question |
| :--- | :--- |
| **Color Harmony** | Does the palette fit the product identity with cohesive, tactile buttons? |
| **Animation Quality** | Are animations purposeful, performant, and free from bounce or layout thrash? |
| **Legibility** | Is typography crisp, readable, well-spaced, and free from undersized text? |
| **Surface Restraint** | Are surfaces clean, grounded, and free from purple gradients or neon glows? |
| **Structural Variety** | Does the layout fit the specific content rather than forcing a 3-box clone? |

**Score below 40/50: Refactor against the Core Design Principles before proceeding.**
