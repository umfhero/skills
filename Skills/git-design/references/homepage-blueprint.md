# Homepage blueprint

This is an implementation reference derived from the public 2026 homepage at a 958px rendered viewport. Treat it as a measured layout system, not source material to copy.

## Foundations

| Property | Observed value | Use |
| --- | ---: | --- |
| Page background | `#e9edec` | Default canvas |
| Ink | `#000000` | Type, icon strokes |
| Primary green | `#08872b` | CTA fill and small status square |
| Soft inset | `#f2f5f3` | Inactive tabs and muted fields |
| Border | `#b6bfb8` | 1px structural edge |
| Editorial column | 616px | Media, main detail sections, CTA |
| Desktop rail offsets | 171px / 787px | At 958px viewport, content column edges |
| Header | 72px | 56px at mobile |
| Ticker | 96px | Full viewport divider |
| Large CTA | 78–80px | Standard large action height |

The site uses `Mona Sans` (variable, approximately 200–900) as the sans and `Mona Sans Mono` for system-style labels. A direct fallback stack is appropriate when those fonts are unavailable. Body copy is 16px. Interface controls are typically 16px at weight 500–550. The visible event/title type is a light 425–460 weight with tight negative tracking at display sizes.

## Hero

1. Put the 72px masthead at the top. Divide logo, nav items, account action, and green CTA with vertical 1px rules.
2. Use a massive display word or original event name in a 72–160px fluid range. It hugs the header and its baseline nearly fills a 158px band at the measured viewport.
3. At >=1012px, make the hero full-bleed inside 24px page rails. It is a 50/50 grid: its media occupies the left column and its information panel occupies the right. At 1440px the visible hero is about 1,390 × 567px, with 695px per half. Do not constrain this desktop hero to the 616px editorial column.
4. In the right half, give metadata its own 96px ruled row, use a 14–16px mono face, and end it with a 10px green square. Give the supporting copy a generous, flexible middle area; one original abstract decoration may sit in its bottom-right without obscuring the message. Finish with a 24px inset and a 78px green CTA.
5. Below 1012px, stack media, metadata, copy, and CTA in that order inside the 616px editorial column. At 958px, the measured media is 616 × 347px. At true phone widths, use 16px page gutters and scale the wordmark until it remains fully visible.

At 958px the hero section runs from y=230 to y=915 (685px). Use this as rhythm, not a fixed requirement. The important relationship is full-width display type, then constrained media and content.

## Main sequence

The public page is roughly 13,250px high at this viewport. Its content cadence is:

| Vertical sequence | Pattern |
| --- | --- |
| 0–915 | Masthead, title band, hero media, metadata, CTA |
| 915–1,011 | Full-width duplicated text ticker |
| 1,011–3,833 | Three alternating editorial river stories |
| 3,833–6,230 | Tickets / pricing or registration interaction |
| 6,230–6,601 | Download / approval utility callout |
| 6,601–8,368 | Agenda with day-selector rows |
| 8,368–9,357 | Community vote / interactive story |
| 9,357–9,744 | Abstract divider visual |
| 9,744–11,338 | Media carousel / video gallery |
| 11,338–12,239 | Testimonials / quote carousel |
| 12,239–end | Canvas-backed closing CTA and footer |

For the editorial river, retain a 616px inner width, 48px or more between text and visual, 80–96px section padding, and alternate which half contains the visual on desktop. Collapse to one column below 1012px. Sections use rules and generous breathing room rather than card shadows.

## Typography scale

| Role | Mobile | Desktop | Weight / line height |
| --- | ---: | ---: | --- |
| Display event name | 56–96px | 112–160px | 425, .86–1 |
| Large featured heading | 32px | 40px | 425, 1.15–1.2 |
| Section heading | 28px | 32px | 440–460, 1.2 |
| Lead | 18px | 20px | 475–500, 1.3–1.35 |
| Body / controls | 16px | 16px | 400–550, 1.5 |
| Mono metadata | 14px | 16px | 500, 1.5 |

## Responsive rules

- At <768px: masthead is about 62px; show the event mark and a 24px hamburger only. Hide desktop navigation, account control, and its green CTA. Make hero media edge-to-edge, then use 20–24px inner insets for metadata, copy, and the action. Remove decorative vertical rails. Scale or condense the wordmark, never clip it.
- At 768–1011px: preserve the content column where it fits but stack the editorial stories.
- At >=1012px: restore 72px nav, grid rails, 616px editorial column, and alternating two-column stories.
- Do not force a 616px column at viewport widths below 648px. Use `min(616px, 100% - 32px)`.

## Color discipline

The green is structural, not a gradient endpoint. Use a white-on-green CTA, a small square mark, or occasionally an active data state. Do not add green glows, green shadow haze, or green gradient backgrounds. The visual identity comes from the contrast of almost-black type against the soft gray page, with thin gray rules making a measured technical grid.
