---
name: pixel-design
description: Apply a retro 8 bit pixel art visual system to web UI, built on flat high contrast colour blocks, hard ink borders, zero blur offset shadows, hand drawn pixel sprite icons and stepped animation. Use this skill whenever the user asks for a pixel, retro, 8 bit, arcade, blocky, neobrutalist or codedex style look, mentions Pixel Design by name, or asks to build, restyle or theme a page, component, landing page or dashboard where a blocky retro direction is wanted or already in use. Also use it when extending an existing pixel themed project to a new page or component, so the palette, shadow formulas and icons stay consistent instead of being reinvented. Framework agnostic, works with plain CSS, CSS modules, Tailwind or styled components.
---

# Pixel Design

A complete visual system for interfaces that read as retro game UI rather than
generic AI SaaS. The point of the system is that every surface obeys the same
small set of formulas, so a page built months apart from another still looks
like it came from the same hand.

## The core idea

Flat, high contrast colour blocks with hard black ink borders and offset
shadows, in the spirit of 8 bit game UI. Nothing is soft. No smooth colour
gradients as decoration, no blurred glows, no pill shaped buttons, no drop
shadow haze. Iconography is genuine pixel art, hand authored as inline SVG
rectangles, never a Unicode glyph or a smooth vector icon set.

The three things that carry the whole look, in order of importance:

1. **The hard shadow.** `Npx Npx 0 <colour>` with zero blur radius, always.
2. **The ink border.** A solid 2px border in near black on every card, button,
   input and badge.
3. **The small radius.** 4px to 8px everywhere. Never a pill, never fully square.

Get those three right and the rest is detail.

## Before you build

Check whether the project already has this system in place. Look for a token
block with hard shadow custom properties, or existing `box-shadow: Npx Npx 0`
declarations. If it exists, read the existing values and reuse them exactly
rather than introducing a parallel set. Consistency beats your improvements
here, and a second slightly different navy is the fastest way to make a themed
project look sloppy.

If nothing exists yet, start from `assets/pixel-design.css`. Copy it into the
project as a stylesheet or translate the token block into whatever the project
uses, then build on top of it. Do not paraphrase the values from memory.

Tokens belong on `:root`, not scoped to a page wrapper. Every page in the
project should be able to use them, and scoping them to one page guarantees a
painful refactor when the second page adopts the theme.

## Palette

Full table with usage notes lives in `references/css-recipes.md`. The working set:

| Token           | Value                   | Use                                    |
| --------------- | ----------------------- | -------------------------------------- |
| `--pd-bg`       | `#f6f7fb`               | Page background                        |
| `--pd-surface`  | `#ffffff`               | Card and panel fills                   |
| `--pd-ink`      | `#0b1130`               | Text, borders, shadows, dark fills     |
| `--pd-line`     | `rgba(11, 17, 32, .08)` | Hairline dividers                      |
| `--pd-muted`    | `#5c6478`               | Body copy                              |
| `--pd-blue`     | `#3561dc`               | Accent 1, links                        |
| `--pd-violet`   | `#6258e9`               | Accent 2, primary brand accent         |
| `--pd-pink`     | `#c2469e`               | Accent 3, secondary flourish           |
| `--pd-cyan`     | `#1f9db8`               | Accent 4, used sparingly               |
| `--pd-green`    | `#1f9d6e`               | Success and completed states           |

Surfaces are white or the page background. Never a gradient wash. Accents are
used at full saturation as flat fills or as shadow colours, never blended into
each other.

Three further muted tiers (`#7d8499`, `#8991aa`, `#98a0b3`) exist for secondary,
tertiary and faintest labels. Use them to build hierarchy through weight and
tone rather than through size alone.

## The formulas

Every card like or interactive element uses one of three scales. Pick by the
element's physical size, not by importance.

```css
/* Small: buttons, badges, inputs, chips */
border: 2px solid var(--pd-ink);
border-radius: 5px;
box-shadow: 3px 3px 0 var(--pd-ink);

/* Medium: cards, panels, list rows */
border: 2px solid var(--pd-ink);
border-radius: 6px;
background: var(--pd-surface);
box-shadow: 4px 4px 0 var(--pd-ink);

/* Large: hero showcase elements, consoles, feature panels */
border: 2px solid var(--pd-ink);
border-radius: 8px;
box-shadow: 7px 7px 0 var(--pd-ink);
```

The shadow colour can be an accent instead of ink for one or two elements per
page, which is how you signal the primary action without reaching for a
gradient. If everything has a coloured shadow, nothing does.

## Pressed buttons

Interactive elements press in physically. The shadow shrinks and the element
moves toward it by the same amount, so the total footprint stays constant and
nothing reflows.

```css
.pd-button {
  box-shadow: 5px 5px 0 var(--pd-violet);
  transition: transform .1s ease, box-shadow .1s ease;
}
.pd-button:hover,
.pd-button:focus-visible {
  transform: translate(2px, 2px);
  box-shadow: 3px 3px 0 var(--pd-violet);
}
.pd-button:active {
  transform: translate(5px, 5px);
  box-shadow: 0 0 0 var(--pd-violet);
}
```

Match the translate distance to the shadow reduction exactly. If they drift
apart the button appears to slide rather than depress, which is the single most
common way this system is implemented badly.

## No gradients, with one exception

Do not use `linear-gradient` or `radial-gradient` as a decorative colour wash.
That means no gradient button fills, no gradient blobs or glows, no
`background-clip: text` gradient headings. Replace each with a flat colour.

The one sanctioned use is a hairline grid texture, which is what replaces
ambient glow in a section that needs atmosphere:

```css
background-color: rgba(98, 88, 233, .05);
background-image:
  linear-gradient(rgba(11, 17, 32, .07) 1px, transparent 1px),
  linear-gradient(90deg, rgba(11, 17, 32, .07) 1px, transparent 1px);
background-size: 16px 16px;
```

This is a technical pattern of thin lines rather than a colour to colour blend,
so it reads as graph paper rather than as generic. A functional loading skeleton
shimmer is also exempt, since that is a universal UX convention rather than
decoration.

## Pixel art icons

Draw icons as a grid of `<rect>` elements on a small viewBox, typically 7x7 to
8x9, rendered with `shapeRendering="crispEdges"` so they stay blocky rather than
antialiased. Use `fill="currentColor"` for single tone sprites so they inherit
surrounding text colour, and explicit per rect fills for multi tone mascots.

Keep every icon in one shared file and import it everywhere. Rotate an existing
sprite with a CSS transform rather than drawing a new direction, so an arrow
pointing up is the right arrow at `rotate(-90deg)`.

Ready to use sprites and full authoring guidance are in
`references/pixel-icons.md`, with a React component file at
`assets/PixelIcons.tsx` and plain HTML snippets at `assets/pixel-icons.html`.

Two placements for decorative sparks:

- **Spacious section** with generous padding: sit the spark inside the
  container's own padding with a positive offset such as `top: 32px; right: 28px`,
  so it never reaches the content.
- **Dense card** with tight padding: perch the spark outside the corner instead,
  with a small negative offset such as `top: -14px; right: -10px`, sized up a
  little from the icon default. This guarantees no overlap however tightly the
  card is packed.

Both need `position: relative` on the container and `position: absolute` on the
spark.

## Animation

Retro pixel animation is stepped, not eased. Use `steps()` for any looping
decorative animation, so a twinkle snaps between two states rather than
breathing smoothly.

```css
@keyframes pd-twinkle {
  50% { opacity: .4; transform: scale(.75); }
}
@media (prefers-reduced-motion: no-preference) {
  .pd-spark { animation: pd-twinkle 1.4s steps(2) infinite; }
}
```

Always gate looping animation behind `prefers-reduced-motion: no-preference`.
State transitions on hover and focus can stay eased and short, since those are
responses to input rather than ambient motion.

## Typography

The source system did not pin typefaces down, so treat this as the default
rather than as law, and follow the project's existing choice if it has one.

Set body copy in a neutral geometric or grotesque sans at normal weight, and
reserve a genuine pixel face for the wordmark, eyebrow labels and small numeric
callouts only. A pixel face at body size is unreadable and it is the fastest way
to make the theme feel like a costume. Silkscreen and Press Start 2P are the
common free pixel faces, and both need generous letter spacing and a size floor
of about 10px to stay legible.

Uppercase, letter spaced, small labels do a lot of work in this system. They
carry the arcade register without needing a novelty face everywhere.

## Copy rules

No hyphens, en dashes or em dashes anywhere in visible text, including
`aria-label` and `title` attributes. Rephrase with a comma, with "and", or as two
sentences. This applies only to text a reader sees, not to class names, file
paths or code.

Write labels as the thing the reader controls, in sentence case, active voice.
An action keeps the same name through a flow, so a button reading "Start run"
leads to a state reading "Run started".

## Common failure modes

**Partial override of a shared component.** When a shared component has a dark
base style and you override it for a light page, override every colour property
together, meaning `color`, `background`, `border` and any child colours, not
only the ones that visibly differ at a glance. Overriding background alone and
leaving an inherited near white `color` produces invisible white on white text,
and it is a bug that ships easily because it looks fine in the dark context you
copied it from.

**A shared header nested inside a padded page wrapper.** A header meant to run
edge to edge gets squeezed inward when the outer element carries horizontal
padding. Keep the outermost page element unpadded and give padding to an inner
content wrapper, so the header can size itself independently.

**Reinvented values.** A 3px border here and a 5px shadow there, or a second
navy that is one hex digit off. Pull from the tokens every time.

**Decoration that does not obey the rules.** A soft shadow on one hover state, a
pill shaped badge in a footer, a Unicode arrow left in a link. These are what
make the system read as approximate rather than authored.

## Finishing check

Before calling the work done, sweep for these:

- Any `box-shadow` or `filter: drop-shadow` with a non zero blur used decoratively
- Any `linear-gradient` or `radial-gradient` that is not the hairline grid
- Any `border-radius` above 8px, or `9999px` pills
- Any Unicode arrow, sparkle, tick or star glyph standing in for an icon
- Any hyphen or dash in visible copy
- Focus states visible on every interactive element
- Looping animation gated behind reduced motion
- The page at 380px wide, since hard shadows and 2px borders eat horizontal
  space faster than soft styling does

## Reference files

- `references/css-recipes.md` for the full palette table and component by
  component CSS, covering nav, hero, cards, tables, forms, progress bars,
  badges, footers and the grid texture.
- `references/pixel-icons.md` for icon authoring, the sprite set and placement.
- `references/adoption.md` for applying the system to an existing codebase,
  including scoping strategy, framework notes for Tailwind and CSS modules, and
  a page by page rollout order.
- `assets/pixel-design.css` as a drop in stylesheet with tokens and base
  components.
- `assets/PixelIcons.tsx` and `assets/pixel-icons.html` for the sprites.
