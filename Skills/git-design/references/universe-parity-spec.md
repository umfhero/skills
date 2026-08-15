# GitHub Universe Homepage Parity Spec

## Purpose

This document captures exact, implementation-relevant differences between:

1. Live target: https://githubuniverse.com/
2. Local demo: http://127.0.0.1:4173/git-design-demo/

It is written as a handoff spec for an implementation agent to produce a much closer reproduction.

## Audit Scope

- Viewport observed: desktop top fold and section-level structure from accessibility tree.
- Sources reviewed:
  - Live rendered DOM and accessibility snapshot.
  - Local rendered DOM and accessibility snapshot.
  - Local source files:
    - git-design-demo/index.html
    - Skills/git-design/assets/git-design.css
    - Skills/git-design/scripts/cursor-trail.js
- Date: 2026-08-15

## Executive Summary

The current demo captures part of the visual language (grid structure, green accents, mono metadata tone), but diverges in the most important areas:

- Hero system architecture (static synthetic art vs real video-led hero)
- Information architecture depth (many live modules missing)
- Navigation taxonomy and destination model
- Interaction model (live carousels/video controls/disclosure patterns missing)
- Content hierarchy and typographic weight distribution

## Side-by-Side Differences (Exact)

### 1) Header and Navigation

Target (githubuniverse.com):

- Brand: GitHub mark + Universe brand treatment.
- Primary links: Sessions, Speakers, Explore, Sponsors, FAQ.
- Utility: Sign in, Get passes.
- Link destinations are mostly external attendee portal or dedicated routes.

Demo (local):

- Brand: text mark N\*26.
- Primary links: Experience, Stories, Passes, Agenda, More.
- Utility: Sign in, Get passes.
- Links are mostly internal anchor jumps (#experience, #passes, #agenda).

Implementation gap:

- Taxonomy and IA intent mismatch.
- Brand lockup and visual identity mismatch.
- Destination model mismatch (portal routes vs one-page anchors).

### 2) Hero Architecture (Top Fold)

Target:

- Left pane is video-led hero with poster frame and play/pause behavior.
- Right pane includes date/location metadata and a large flagship H1 sentence.
- Hero H1 text: "GitHub's flagship developer event uniting humans, agents, and the world's code to build what's next."
- CTA: Get passes.

Demo:

- Left pane is synthetic dark perspective grid with custom text "build what's next."
- Right pane has short paragraph copy with lower visual priority.
- Main oversized H1 is separate top wordmark "NORTHSTAR'26", not the flagship sentence.
- CTA in hero is "Reserve a place".

Implementation gap:

- Core composition differs (video narrative vs abstract graphic).
- Headline hierarchy inverted (target H1 in hero details; demo H1 as giant standalone wordmark).
- CTA language and user flow differ.

### 3) Promo Ticker and Motion Controls

Target:

- Repeating promo banner message with dedicated animation pause control.
- Message variant observed: "Save $300 with Early Bird. Now - August 20".

Demo:

- Repeating ticker text exists but with generic message.
- No explicit user control for pause.

Implementation gap:

- Missing accessibility/interaction affordance for animation control.
- Missing target campaign semantics.

### 4) Experience Section Depth

Target:

- Section headline: "Universe is where builders become orchestrators".
- Three narrative tracks: dev.experience(), dev.learn(), dev.connect().
- Real media blocks and slider/gallery controls in dev.learn().

Demo:

- Two simplified narrative blocks: dev.experience() and dev.connect().
- Abstract visual placeholders (terminal/promo poster style).
- No section-level media carousel behavior.

Implementation gap:

- Content breadth and interaction complexity are reduced.
- Missing dev.learn() branch and associated controls.

### 5) Passes and Registration Mechanics

Target:

- Includes timeline milestones (Super Early Bird, Early Bird, etc).
- Pass options tabs: Individual, Group, Level up.
- Rich card structure for in-person and virtual variants with "What's included" disclosures.
- Real registration routes.

Demo:

- Tabs: Individual, Team, Virtual.
- Simple static card content and bullet lists.
- No timeline milestones, no disclosure groups.

Implementation gap:

- Pricing UX is substantially simplified.
- Commercial conversion path and urgency scaffolding missing.

### 6) Agenda and Program Granularity

Target:

- Multi-day program with specific time slots and event rows (oct27_day0 through oct30_day3).
- "See all sessions" CTA to attendee portal.

Demo:

- Minimal two-day narrative summary with generic copy.

Implementation gap:

- Missing schedule density and semantic timetable structure.

### 7) Mid/Lower-Page Conversion Modules

Target includes additional modules not represented in demo:

- "get-approval/" (download template)
- "shape-the-lineup/" voting section
- "2025-highlights/" playlist + selected video player
- Testimonial/story carousel
- Final conversion banner section

Demo:

- Ends earlier with simplified closing section and basic footer.

Implementation gap:

- Multiple high-value conversion and engagement blocks absent.

### 8) Footer and Compliance Surface

Target:

- Full legal/social footer, cookie management actions, external network links.
- Cookie preferences overlay observed in current live session.

Demo:

- Single-line disclaimer footer.

Implementation gap:

- Missing legal/compliance/utility surfaces.

### 9) Interaction Model

Target interactions observed:

- Video play/pause
- Slider previous/next controls
- Ticker pause control
- Tabbed pass chooser
- Expandable "What's included" groups

Demo interactions observed:

- Tabbed pass chooser
- Auto ticker
- Custom cursor trail effect

Implementation gap:

- Demo has non-target interaction (cursor trail) while lacking several target interactions.

### 10) Tone and Content Voice

Target voice:

- Product/event specific, conversion oriented, operationally detailed.

Demo voice:

- Generic concept copy and fictional event framing.

Implementation gap:

- Messaging intent differs (marketing funnel detail vs visual prototype).

## Source-Anchored Demo Evidence

Key demo evidence locations:

- Brand mark and nav labels: git-design-demo/index.html (header block)
- Standalone giant wordmark H1: git-design-demo/index.html (wordmark section)
- Synthetic hero art text: git-design-demo/index.html (hero-art section)
- Hero CTA copy: git-design-demo/index.html (hero details CTA)
- Simplified passes tabs/cards: git-design-demo/index.html (passes section)
- Simplified agenda block: git-design-demo/index.html (agenda section)
- Basic footer disclaimer: git-design-demo/index.html (footer)
- Constrained layout and typography tokens: Skills/git-design/assets/git-design.css
- Non-target pointer effect: Skills/git-design/scripts/cursor-trail.js

## Replication Blueprint (For Implementation Agent)

Build in this order to maximize parity quickly.

### Phase 1: Structural parity (must-have)

1. Replace top-of-page hero architecture with two-column video-first composition.
2. Move flagship sentence into hero right panel as primary H1.
3. Align nav labels and information architecture with target taxonomy.
4. Replace fictional event metadata with target-equivalent date/location pattern.

Done criteria:

- Header labels and hero block semantics match target pattern.
- Hero left media uses real video/poster component rather than synthetic placeholder.

### Phase 2: Interaction parity (must-have)

1. Add video control state (play/pause UI).
2. Add marquee/ticker pause control.
3. Add at least one carousel/slider module with prev/next controls.
4. Add expandable disclosure groups for pass inclusions.

Done criteria:

- Keyboard and pointer both work for controls.
- Motion controls expose visible state.

### Phase 3: Content module parity (must-have)

Implement missing high-value sections in this order:

1. Experience triad (dev.experience, dev.learn, dev.connect).
2. Save-your-seat timeline + richer pass tabs.
3. Agenda with multi-day timed schedule rows.
4. Approval download module.
5. Session voting module.
6. 2025 highlights video playlist.
7. Testimonial carousel.
8. Final conversion section + robust footer.

Done criteria:

- Section sequence and narrative journey align with target.
- Page depth approximates target and no longer feels abbreviated.

### Phase 4: Styling and rhythm parity (should-have)

1. Rebalance typography hierarchy so H1 weight matches hero-right usage, not standalone oversized wordmark.
2. Match spacing rhythm and border grid cadence between modules.
3. Replace symbolic text arrows with icon treatment closer to target control affordances.
4. Remove or disable non-target cursor trail unless explicitly retained as optional variant.

Done criteria:

- First screen impression resembles target composition before reading text.
- Visual rhythm remains consistent through mid and lower sections.

## Acceptance Checklist (Binary)

Use this for implementation QA.

Header and Hero

- [ ] Nav labels match target taxonomy (Sessions/Speakers/Explore/Sponsors/FAQ).
- [ ] Hero left is media player (video/poster), not abstract static artwork.
- [ ] Hero right contains date/location metadata and flagship H1 sentence treatment.
- [ ] Hero primary CTA is passes-focused.

Promo and Motion

- [ ] Ticker exists with pause control.
- [ ] Video has explicit play/pause control.
- [ ] At least one media carousel has previous/next controls.

Experience/Passes/Agenda

- [ ] Experience section includes dev.experience, dev.learn, dev.connect branches.
- [ ] Passes area includes timeline milestones and richer tab model.
- [ ] "What's included" disclosure behavior implemented.
- [ ] Agenda uses day-labeled schedule rows with times.

Lower Funnel

- [ ] Approval-download block exists.
- [ ] Session-vote block exists.
- [ ] Highlights playlist with selected player exists.
- [ ] Story/testimonial carousel exists.
- [ ] Footer includes legal/social utility depth.

## Recommended Non-Goals for First Parity Pass

- Pixel-perfect cloning of proprietary fonts/assets.
- Exact copy or trademarked media reuse.
- Third-party registration backend integration.

## Practical Notes for Agent Execution

- Keep the current code as baseline but treat it as scaffold, not final architecture.
- Prioritize semantic section parity first, then visual detail.
- If assets are unavailable, use neutral placeholders that preserve component behavior and dimensions.
- Maintain accessibility: controls must be keyboard reachable, stateful, and labeled.

## Final Verdict

Current demo is a good stylistic prototype but not yet a close homepage reproduction. The largest blockers are hero architecture, missing section depth, and interaction parity. Implementing the phased blueprint above will move it from "inspired by" to "structurally and behaviorally close."
