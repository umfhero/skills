# Bareminimum-Design Foundations

This reference provides the structural building blocks for starting any project cleanly. It defines the typography, spacing, surface colors, Lucide icon patterns, and layout architectures that replace AI templates.

---

## 1. Typographic System

Use a clear, mathematically consistent type scale with a minimum 1.25 multiplier between tiers. Never allow body copy or interactive controls to dip below legible thresholds.

### Scale & Tokens

| Token            | Size            | Line Height | Weight    | Intended Purpose                                           |
| :--------------- | :-------------- | :---------- | :-------- | :--------------------------------------------------------- |
| `--bm-text-3xl`  | 2.5rem (40px)   | 1.15–1.2    | 700 / 650 | Main page title / primary hero statement                   |
| `--bm-text-2xl`  | 2.0rem (32px)   | 1.2         | 650       | Major section heading (`<h2>`)                             |
| `--bm-text-xl`   | 1.5rem (24px)   | 1.25        | 600       | Sub-section header (`<h3>`)                                |
| `--bm-text-lg`   | 1.25rem (20px)  | 1.35        | 600       | Card title, panel header, modal title                      |
| `--bm-text-base` | 1.0rem (16px)   | 1.55–1.65   | 400       | **Baseline body copy**, articles, paragraphs               |
| `--bm-text-sm`   | 0.875rem (14px) | 1.4         | 500 / 400 | Buttons, input fields, navigation links, table cells       |
| `--bm-text-xs`   | 0.75rem (12px)  | 1.4         | 500       | **Strict Floor**: timestamps, badges, small table captions |

> [!IMPORTANT]
> **Strict Font Rules**:
>
> 1. **No body text below 16px** (`1rem`) on desktop or mobile.
> 2. **No functional text below 12px** anywhere in the product.
> 3. **Never place mini-titles / kickers / uppercase tags above headings**. If the category or section name is needed, incorporate it into the heading or breadcrumb:
>    - _AI Slop_: `<span class="uppercase tracking-widest text-xs">Analytics</span><h2>User Growth</h2>`
>    - _Quality_: `<h2>User Growth Analytics</h2>` or `<nav aria-label="Breadcrumb">Analytics</nav><h2>User Growth</h2>`

---

## 2. Palette & Surface Elevation

Build depth using solid, physical surface steps and crisp 1px borders rather than diffuse shadows, glowing cards, or purple-to-cyan gradients.

### Light Theme

- **Canvas Base**: `#ffffff` (Clean white)
- **Secondary Surface / Page Inset**: `#f8f9fa` or `#f3f4f6`
- **Raised Cards & Panels**: `#ffffff` with `border: 1px solid #e5e7eb`
- **Primary Ink**: `#111827` (Near black, 14:1 contrast on white)
- **Muted Ink (Secondary labels)**: `#4b5563` (7:1 contrast on white)
- **Subtle Ink (Timestamps, placeholders)**: `#6b7280` (4.6:1 contrast on white - WCAG AA compliant)
- **Primary Action Accent**: `#2563eb` (Solid sapphire) or brand-specific hue (must meet 4.5:1 on background)

### Dark Theme

- **Canvas Base**: `#0f1117` (Deep slate, avoid pure #000000 to prevent harsh OLED smearing)
- **Raised Panels & Cards**: `#181b23` with `border: 1px solid #2d3342`
- **Hover / Active Planes**: `#1f232d`
- **Primary Ink**: `#f9fafb` (Off-white)
- **Muted Ink**: `#9ca3af`
- **Subtle Ink**: `#6b7280`
- **Glow Ban**: Zero colored `box-shadow` or neon border halos. Elevation in dark mode comes from slightly lighter surface fills (`#181b23` on top of `#0f1117`), not shadows.

---

## 3. Lucide Iconography System

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
    <path d="M5 12h14M12 5v14" />
  </svg>
  <span>Create Project</span>
</button>
```

#### B. In Card / Section Headers (Side-by-Side, Not Stacked)

```html
<!-- Quality: Icon aligns with heading text, no floating gradient tile -->
<div
  style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.5rem;"
>
  <svg class="bm-icon" style="color: var(--bm-accent);" viewBox="0 0 24 24">
    <!-- Lucide: ShieldCheck -->
    <path
      d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"
    />
    <path d="m9 12 2 2 4-4" />
  </svg>
  <h3 style="margin: 0; font-size: var(--bm-text-lg);">Automated Compliance</h3>
</div>
<p style="color: var(--bm-ink-muted);">
  Runs policy scans on every commit and flags discrepancies before deployment.
</p>
```

#### Curated Lucide Icon Mapping

- **Navigation & Hierarchy**: `Folder`, `FileText`, `Layers`, `Home`, `Compass`, `ChevronRight`
- **Actions & Controls**: `Plus`, `Trash2`, `Edit3`, `Copy`, `ExternalLink`, `Download`, `Upload`, `Search`, `SlidersHorizontal` (Filters)
- **Status & Feedback**: `CheckCircle2`, `AlertCircle`, `Info`, `Clock`, `ShieldCheck`, `Lock`

---

## 4. Anti-Slop Layout Architectures

Rather than defaulting to the standard AI template (Centered Hero + 3-card icon grid + 3 metric boxes), use these functional layout structures:

### Architecture A: The 2-Column Split Hero (Landing / Introduction)

- **Left Column (55%)**:
  - Direct, confident `<h1>` (e.g. "Continuous Database Migrations for Postgres").
  - Factual explanation paragraph (max 2–3 sentences, no buzzwords).
  - Primary action button + secondary documentation link.
  - Contextual detail (e.g. "Compatible with Postgres 12+ and Supabase").
- **Right Column (45%)**:
  - An authentic interactive preview: a real SQL snippet, a live schema diff table, or an interactive configuration preview. Never a generic floating purple card.

### Architecture B: The Editorial River (Feature Showcase)

- Staggered horizontal bands replacing identical vertical card grids:
  - Row 1: Left: Feature description + technical spec bullet points. Right: High-fidelity component preview or screenshot.
  - Row 2: Left: Live interactive sandbox / terminal output. Right: Feature description + configuration explanation.
- Each band is separated by a clean 1px divider rule (`#e5e7eb`).

### Architecture C: The Data-Dense Workspace (Web App / Dashboard)

- **Top Bar**: Search input, active workspace selector, user profile.
- **Main Area**:
  - Filter bar: Clean search, dropdown tags, date range selector.
  - Data Table: Semantic `<table>` with bold column headers, alternating or cleanly ruled rows, status tags, and action buttons.
  - Detail Drawer / Side Sheet: Selecting a row opens a slide-over pane with deep metadata, avoiding modal dialog traps.

---

## 5. Microcopy and Product Voice Guidelines

Translate human writing principles directly into product text:

1. **Be Literal**: Describe the software's exact mechanical output.
   - _AI Slop_: "Supercharge your team's workflow with our next-gen collaborative ecosystem."
   - _Quality_: "Real-time collaborative markdown editor with branch-based review."
2. **Never Pad Feature Lists**:
   - Do not force 3 features when there are 2. Do not arbitrarily inflate copy with filler words ("seamlessly", "effortlessly", "holistic").
3. **No Dangling Participial Clauses**:
   - Cut trailing phrases like "enabling you to focus on what matters most", "ensuring high performance", or "fostering team synergy".
4. **Action-Oriented Empty States**:
   - State what is missing and provide the button to create it:
   - _AI Slop_: "No data found. Dive into your analytics journey by creating an entry today!"
   - _Quality_: "No active deployments. Select 'Deploy Branch' to launch your first environment."
