---
name: git-design
description: "Build or restyle web experiences in the editorial, code-aware visual language of GitHub Universe: pale gray gridlined surfaces, Mona Sans inspired typography, oversized black display type, green action blocks, monospaced labels, low-radius panels, scroll-led editorial layouts, and accessible interactive canvas cursor trails. Use when the user asks for Git-Design, GitHub Universe inspired styling, a GitHub event landing page, a developer-conference homepage, or a precise recreation of that homepage's layout and effects. Framework agnostic, works with HTML/CSS/JS, React, Next.js, Tailwind, and CSS modules."
---

# Git-Design

Create a crisp, code-native event site. The system is deliberately quiet: a pale gray canvas, near-black type, hairline grid rules, very little rounding, and one saturated green used for calls to action and small signal marks. Use scale, composition, and motion rather than gradients or a pile of decorative cards.

Do not copy GitHub trademarks, event wordmarks, photography, videos, or live-site source. Recreate the visual grammar with original content and assets. Do not imply GitHub endorsement.

## Start here

1. Inspect the host project before adding styles. Reuse its tokens and component conventions where they do not conflict.
2. Copy `assets/git-design.css` into the project, or translate its tokens and component rules faithfully.
3. Read `references/universe-parity-spec.md` first when the user requests close GitHub Universe homepage parity; treat its acceptance checklist as mandatory.
4. Read `references/homepage-blueprint.md` for measured layout values and `references/motion-and-icons.md` before adding motion or icon affordances.
5. Copy `assets/universe-parity.css` and initialize `scripts/universe-interactions.js` for the complete homepage pattern. Use `scripts/cursor-trail.js` only as an optional variant; the parity build leaves it disabled because it is not a target interaction.

## Non-negotiable visual rules

- Use `Mona Sans` where licensed and available. Otherwise use the fallbacks in the asset. Use a mono face only for operational labels, dates, filenames, code-like headings, and ticks.
- Set body copy at 16px / 1.5. Use 16px navigation, 18–20px lead copy, 28–40px section headings, and a fluid 72–160px hero wordmark. Keep display weight unusually light for its size, normally 425–460; use 500–550 for controls.
- Use `#e9edec` for the page, `#000` for ink, `#08872b` for primary green, `#f2f5f3` for inset gray, and `#b6bfb8` for structural rules. Keep any additional palette color subordinate to these.
- Compose with a centred 616px editorial column at desktop, bounded by vertical grid lines. Let full-bleed bands (nav, ticker, dividers) escape the column. At smaller widths, use 16px gutters and remove the outer grid rails rather than squeezing the content.
- Prefer square or 4–8px radius geometry, 1px gray rules, and frequent horizontal dividers. Do not use soft shadows, glass, floating cards, blur, gradient text, or pill controls.
- Use green once per viewport as an action block or small square marker. A large green CTA is a rectangle, not a rounded button.
- Use simple, single-color SVG line icons with 16px or 20px viewboxes. Prefer an explicit arrow-up-right, chevron, pause/play, person, and close icon. Align the icon with the text's optical centre; do not substitute emoji or Unicode arrows.

## Page architecture

Build in this order. Keep the rhythm even if the content changes:

1. A 72–74px desktop masthead with 1px dividers between logo, nav items, account control, and primary CTA. On phone widths, use a 62px logo-plus-menu header: hide navigation, account, and green header CTA rather than compressing them.
2. A full-width oversized wordmark band with a bottom rule.
3. At >=1012px, a full-bleed, ruled 50/50 split hero: media on the left and metadata, supporting copy, decor, and a 78–80px green action on the right. Below that breakpoint, stack the hero in the 616px editorial column with media first.
4. A 92–96px horizontal ticker as a section break.
5. Alternating left/right editorial river sections, each using a mono eyebrow, large heading, prose, a 78–80px outlined action, and a purposefully cropped visual.
6. One data-dense interactive section such as tickets, an agenda, or a tabbed information panel. Its active state is white; inactive states are `#f2f5f3`.
7. An agenda, media gallery, quote carousel, or similar content-heavy closing sequence. Finish with an atmospheric CTA canvas and a structured footer.

Use the dimensions and responsive change points in `references/homepage-blueprint.md`; do not attempt to reproduce the page by eye alone.

## Interaction and motion

Motion should make an editorial page feel alive, not behave like a game UI.

- Keep standard UI hover transitions at 200ms, normally `ease-in-out`; navigation fill transitions can use 400ms.
- On a primary button, shift its arrow 2–4px diagonally on hover. On outlined actions, shift the arrow right. Preserve `:focus-visible` at all times.
- Animate the ticker with a linear, continuously translating duplicated track. Pause on hover and focus within. Avoid motion if `prefers-reduced-motion: reduce` is active.
- Reveal items once on entry with 300–500ms opacity / translate transitions. Never hide essential content behind a scroll effect.
- For the cursor treatment, use the supplied canvas module's short green particle tail inside `.gd-trail-area`; it follows pointer velocity, fades naturally, deactivates for coarse pointers and reduced motion, and is `pointer-events: none`.
- Use the same canvas technique for an abstract footer field. Do not reproduce the site’s 3D Mona model or source media; make a simple field of dots, lines, or blocks instead.

## Implementation requirements

- Keep the canvas behind interactive content and make it an `aria-hidden` decoration.
- Use semantic `header`, `nav`, `main`, `section`, `footer`, real buttons for controls, labels for video controls, and meaningful `alt` text. Canvas never conveys required information.
- Honour `prefers-reduced-motion` by disabling tickers, reveal motion, and cursor simulation. Ensure the static visual still holds together.
- Test 375px, 768px, 1012px, 1280px, and a wide desktop viewport. Test keyboard focus, 200% zoom, and a touch device; cursor effects must be optional.
- Use original copy, media, brand marks, and implementation. Do not fetch or bundle GitHub Universe assets into a deliverable unless the user owns a licence for them.

## Finishing check

- The primary action is obvious without using more than one dominant green element.
- The content column, rules, and hero media share the same horizontal alignment.
- Display type looks light and expansive, not bold and compressed.
- Metadata is visibly monospaced and uses deliberate spacing, not letter-spaced body copy.
- Every visual effect has a static reduced-motion fallback.
- Mobile has no horizontal overflow and no mandatory pointer interaction.

## Resources

- `assets/git-design.css` contains the token set, layout primitives, masthead, hero, actions, ticker, river, tabs, and accessibility fallbacks.
- `assets/universe-parity.css` contains the complete parity components for media, experience, tickets, agenda, lower-funnel modules, carousels, and footer.
- `scripts/universe-interactions.js` initializes the accessible media, ticker, carousel, tab, playlist, and mobile-menu controls.
- `scripts/cursor-trail.js` exports `createCursorTrail(canvas, options)` for an independent, accessible canvas tail.
- `references/homepage-blueprint.md` contains the observed 2026 layout, spacing, typographic, palette, and responsive measurements.
- `references/motion-and-icons.md` contains interaction recipes, canvas implementation guidance, icon geometry, and motion limits.
- `references/universe-parity-spec.md` is the source of truth for full-homepage replication scope and acceptance QA.
