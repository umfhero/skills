# CSS recipes

Read this when building a component that is not already covered by
`assets/pixel-design.css`, or when translating the system into a different
styling approach.

Contents: palette table, scale selection, component recipes, responsive notes.

## Full palette

| Token              | Value                   | Use                                              |
| ------------------ | ----------------------- | ------------------------------------------------ |
| `--pd-bg`          | `#f6f7fb`               | Page background                                  |
| `--pd-surface`     | `#ffffff`               | Card and panel fills                             |
| `--pd-ink`         | `#0b1130`               | Primary text, borders, shadows, dark fills       |
| `--pd-ink-alt`     | `#0c1231`               | Alternate dark fill, primary button              |
| `--pd-line`        | `rgba(11, 17, 32, .08)` | Hairline dividers, table row rules               |
| `--pd-heading`     | `#151a33`               | Emphasised numbers and headings inside cards     |
| `--pd-heading-soft`| `#232a45`               | Secondary heading tone                           |
| `--pd-muted`       | `#5c6478`               | Body and paragraph copy                          |
| `--pd-muted-2`     | `#7d8499`               | Secondary labels                                 |
| `--pd-muted-3`     | `#8991aa`               | Tertiary labels, small print                     |
| `--pd-muted-4`     | `#98a0b3`               | Faintest labels, placeholders                    |
| `--pd-blue`        | `#3561dc`               | Accent 1, links, primary tint                    |
| `--pd-violet`      | `#6258e9`               | Accent 2, primary brand accent, progress fill    |
| `--pd-pink`        | `#c2469e`               | Accent 3, secondary flourish                     |
| `--pd-cyan`        | `#1f9db8`               | Accent 4, used rarely                            |
| `--pd-green`       | `#1f9d6e`               | Success and completed states                     |
| `--pd-green-deep`  | `#178a53`               | Deeper success tone, text on light green         |

The four muted tiers exist so hierarchy comes from tone rather than from
shrinking type. A card with a 30px heading, 16px body in `--pd-muted` and an
11px uppercase label in `--pd-muted-3` reads correctly without any extra
decoration.

Accents are used as flat fills, as shadow colours, or as text. They are never
blended into each other and never used as a background wash behind body copy.

## Choosing a scale

Pick by physical footprint, not by hierarchy. A small important button still
gets the small shadow, and its importance is carried by the dark fill and the
accent shadow colour instead.

| Scale  | Radius | Border | Shadow  | Applies to                              |
| ------ | ------ | ------ | ------- | --------------------------------------- |
| Small  | 5px    | 2px    | 3px 3px | Buttons, badges, inputs, chips, avatars |
| Medium | 6px    | 2px    | 4px 4px | Cards, list rows, panels, table wrapper |
| Large  | 8px    | 2px    | 7px 7px | Hero consoles, feature panels, modals   |

Badges can drop to a 4px radius and a 2px shadow, since at that size a 3px
shadow starts to look like a second badge.

## Nav header

The header runs edge to edge, so it is a direct child of an unpadded page
element with its own inner wrapper for the content. A hairline bottom border
rather than a shadow, since a shadow on a full width bar looks like a mistake.

```css
.pd-nav {
  border-bottom: var(--pd-border) solid var(--pd-ink);
  background: var(--pd-surface);
}
.pd-nav__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding-block: 14px;
}
```

Build the header once as a shared component and render it on every page. Two
implementations styled to look alike will drift within a month.

## Hero

Open with the most characteristic thing in the subject's world rather than a
big number and a gradient. In this system the natural hero device is a large
panel using the 7px shadow with a mascot sprite perched on its corner, since
that is the one place the pixel art gets to be full size.

```css
.pd-hero { position: relative; padding-block: clamp(48px, 9vw, 88px); }
.pd-hero__panel {
  position: relative;
  border: var(--pd-border) solid var(--pd-ink);
  border-radius: var(--pd-radius-lg);
  background: var(--pd-surface);
  box-shadow: var(--pd-shadow-lg);
}
.pd-hero__mascot { position: absolute; top: -26px; right: -14px; }
```

## Stat row

Equal cards in a grid, each with a large number in `--pd-heading` and an
uppercase label beneath in `--pd-muted-3`. Resist adding an icon to every stat,
since four sparks in a row stops reading as decoration and starts reading as
noise.

```css
.pd-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 18px;
}
```

## Table

Ink coloured header row with white uppercase labels, hairline row rules, and
the whole table wrapped in a bordered container with `overflow: hidden` so the
rows clip to the radius. Do not put a border on every cell, since the grid of
2px lines fights the shadow language.

## Progress bar

Ink border, page background as the track, flat accent as the fill, small
radius, no inner shadow and no stripe animation. Switch the fill to
`--pd-green` at completion rather than adding a tick inside the bar.

## Empty and loading states

An empty state is a bordered card with a mascot sprite, one line saying what
goes here, and the action that fills it. A loading state uses `.pd-skeleton`,
which keeps the ink border so the layout does not jump when content arrives.

## Responsive notes

Hard shadows and 2px borders consume more horizontal room than soft styling, so
check every layout at 380px. Two adjustments usually suffice:

```css
@media (max-width: 640px) {
  :root {
    --pd-shadow-lg: 5px 5px 0 var(--pd-ink);
    --pd-gutter: 18px;
  }
}
```

Reducing the large shadow at small widths keeps a full bleed panel from
appearing to hang off the screen edge. Keep the small and medium shadows as
they are, since those are what make the theme legible at a glance.

## Dark mode

Not part of the source system. If a project needs it, invert deliberately
rather than mechanically: the shadow colour cannot stay near black on a near
black background, so it becomes a mid tone or an accent, and the border becomes
a light ink. Test this properly before shipping, since a straight token swap
makes every element lose its edge.
