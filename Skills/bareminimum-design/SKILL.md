---
name: bareminimum-design
description: "Foundational, clean starter design system that eradicates AI slop design traits and enforces robust UI/UX structure for new and existing projects. Enforces strict bans on tiny fonts (<14px), mini-titles/kickers above headings, purple/violet gradients, dark-mode neon glows, identical 3-card grids, and oversized icon tiles. Provides curated, production-ready alternatives including Lucide icons, clear typographic hierarchies, authentic layout flows, and performant motion. Use this skill at the inception of any web application, site, tool, or UI component to prevent vibe-coded AI aesthetic defaults."
---

# Bareminimum-Design

Build clean, honest, and robust user interfaces from day one. This skill serves as the starter baseline for all projects: it strips away the recognizable visual and structural tells of AI-generated web interfaces while supplying a bare-bones, highly functional design foundation that supports any product direction.

The goal is not to force a narrow artistic theme, but to guarantee that the very first iteration of your project never looks like generic AI slop or lazy "vibe coding."

---

## Quick Reference Links

- [references/anti-slop-catalog.md](references/anti-slop-catalog.md) — Exhaustive catalog of 66+ AI slop patterns from [impeccable.style/slop](https://impeccable.style/slop/) and [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) mapped to quality design alternatives.
- [references/foundations.md](references/foundations.md) — Core tokens, typographic scales, Lucide icon patterns, and layout architectures.
- [assets/bareminimum.css](assets/bareminimum.css) — Lightweight drop-in stylesheet with baseline resets, anti-slop typography floors, and neutral tokens.

---

## The Non-Negotiable Bans

Every AI-generated interface relies on the same predictable tropes. These are strictly banned:

### 1. Typography Bans
- **NO mini-titles / kickers / uppercase eyebrows above headings** (e.g. `FEATURES` or `OVERVIEW` floating in tiny tracked uppercase over an `h2`). Fold the context into the heading or breadcrumb.
- **NO tiny functional fonts**: Zero body copy below 16px (`1rem`). Zero secondary or functional text below 12px (`0.75rem`).
- **NO flat type hierarchy**: Font size steps between heading levels and body copy must maintain a multiplier of at least 1.25x.
- **NO italic serif display headlines** ("*Beautifully crafted*") used as an instant substitute for taste.
- **NO all-caps body text** or paragraphs wider than 75 characters (`max-width: 68ch`).

### 2. Color & Surface Bans
- **NO purple-to-blue or violet gradients**: Violet/cyan gradients on buttons, text, cards, or hero backgrounds are the universal signature of AI templates.
- **NO dark mode glowing neon boxes**: Saturated `box-shadow` glows and neon borders on dark surfaces look like toy hackathon projects.
- **NO radial background halos or decorative spotlights**: Do not place blurry gradient orbs behind cards or hero sections.
- **NO glassmorphism blur stacks**: Avoid `backdrop-filter: blur()` cards layered over colorful gradient backgrounds.
- **NO side-tab border stripes**: Never attach a thick 3px–4px colored border to the left side of a rounded card.
- **NO hairline border + diffuse shadow combinations**: Commit to a crisp 1px neutral border OR a subtle realistic shadow, never both simultaneously.

### 3. Layout & Structure Bans
- **NO identical 3-card feature grids**: The default AI template of 3 identical vertical cards with icon + heading + 2 lines of text is banned. Use asymmetric 2-column splits, editorial rivers, or structured data tables.
- **NO Cardocalypse (nested cards)**: Never nest cards inside cards inside cards. Flatten the container hierarchy using whitespace and 1px dividers.
- **NO hero metric templates**: Stop using the standard oversized number + small label + 3 floating gradient stat boxes.
- **NO modal abuse**: Never trap multi-step forms, large tables, or settings inside a scrolling popup modal. Use dedicated pages or slide-over drawers.

### 4. Icon & Graphic Bans
- **NO massive icon tiles stacked above headings**: Do not place a 48px rounded gradient square with an icon directly atop an `<h3>`.
- **NO crude hand-drawn SVGs or shape-assembled clip art**: If real illustration or product photography is unavailable, ship clean typography and data without placeholder graphics.
- **NO emoji as icons or bullet points**: Use real SVG vector icons.

### 5. Motion Bans
- **NO bounce or elastic easing**: Interface elements must never wobble, bounce, or overshoot. Use smooth cubic ease-out curves (`cubic-bezier(0.16, 1, 0.3, 1)`).
- **NO animating layout properties**: Never animate `width`, `height`, `margin`, or `padding`. Animate only hardware-accelerated `transform` and `opacity`.
- **NO auto-scrolling marquees** or pulsing dots on static elements.

### 6. Copy & Microcopy Bans
- **NO SaaS marketing buzzwords**: Ban "streamline", "empower", "supercharge", "seamless", "game-changer", "delve", "unlock", "revolutionary".
- **NO dangling "-ing" filler clauses**: Ban phrases like "ensuring optimal results" or "fostering seamless collaboration".
- **NO negative parallelism**: Ban "Not just X, but Y" and "It's not about speed, it's about control".
- **NO Rule of Three compulsion**: State the actual number of features or points that exist; never artificially force a set of 3.

---

## Predefined Quality Alternatives

Replace AI defaults with these battle-tested standards:

### 1. Curated Lucide Icons
Standardize on [Lucide](https://lucide.dev/) stroke icons:
- **Sizes**: 16px (`1rem`) for buttons and compact controls; 20px (`1.25rem`) for navigation, headers, and list items.
- **Stroke**: Consistent `1.75px` or `2.0px`.
- **Placement**: Integrated **inline** beside headings or controls using `display: flex; align-items: center; gap: 0.5rem;`. Never floating in isolated square tiles.

### 2. Solid, Grounded Surfaces
- **Light Theme**: Solid `#ffffff` base, `#f8f9fa` inset panels, `#ffffff` raised cards with a crisp `1px solid #e5e7eb` boundary.
- **Dark Theme**: Solid `#0f1117` base, `#181b23` cards with `1px solid #2d3342` borders. Depth comes from slightly lighter surface fills, not neon glow.
- **Single Intentional Accent**: Choose one solid primary color for interactive actions (e.g. `#2563eb`).

### 3. Purposeful Layouts
- **2-Column Split Hero**: Factual proposition + primary action on the left; authentic product artifact, interactive demo, or real code block on the right.
- **Editorial Rivers**: Alternating horizontal bands pairing feature mechanics with component previews, separated by 1px rules.
- **Data-Dense Tables**: Crisp tabular layouts with clear column hierarchy, sortable headers, and inline action buttons.

---

## Pre-Flight Anti-Slop Checklist

Before delivering or approving any UI work, verify every item on this checklist:

- [ ] **No tiny text**: Is all body text $\ge$ 16px? Is all secondary text $\ge$ 12px?
- [ ] **No mini-titles/kickers**: Are all headings free from floating uppercase tags above them?
- [ ] **No purple/violet gradients**: Are buttons, cards, and backgrounds solid and intentional?
- [ ] **No glowing cards**: Is dark mode free from colored box-shadows and neon halos?
- [ ] **No 3-card clones**: Does the layout use split columns, data rows, or varied composition instead of identical feature boxes?
- [ ] **No icon tile stacks**: Are icons integrated inline with text rather than floating in rounded squares above titles?
- [ ] **Uniform Lucide icons**: Are all icons from Lucide with matched stroke widths (1.75px–2px)?
- [ ] **No card nesting**: Are cards flat without nested cards inside cards?
- [ ] **Performant motion**: Do transitions use `transform`/`opacity` with smooth ease-out curves? Is bounce easing completely absent?
- [ ] **Reduced motion supported**: Does `@media (prefers-reduced-motion: reduce)` disable non-essential motion?
- [ ] **Factual microcopy**: Are buzzwords ("streamline", "empower", "game-changer") and dangling "-ing" puffery eliminated?
- [ ] **Optimal line length**: Are reading passages constrained to 65–75 characters (`max-width: 68ch`)?

---

## Scoring Rubric

Rate the initial UI draft 1–10 on each dimension:

| Dimension | Question |
| :--- | :--- |
| **Authenticity** | Does this look like a thoughtfully designed product rather than a generated template? |
| **Legibility** | Is typography crisp, readable, well-spaced, and free from undersized text? |
| **Surface Restraint** | Are surfaces solid, grounded, high-contrast, and free from purple gradients or neon glows? |
| **Structural Variety** | Does the layout fit the specific content rather than forcing a 3-box clone? |
| **Copy Quality** | Is the microcopy direct, factual, human, and buzzword-free? |

**Score below 40/50: Refactor against the Non-Negotiable Bans before proceeding.**

