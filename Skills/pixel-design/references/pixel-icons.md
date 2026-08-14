# Pixel icons

Read this when adding a sprite that is not already in the set, or when deciding
where a decorative spark goes.

## Why hand authored

An icon font or a smooth vector set drops straight back into generic territory,
because the curves and the optical sizing are exactly what the rest of the
system removes. A sprite drawn as rectangles on a 7x7 grid cannot be mistaken
for Lucide or Heroicons, and it takes about five minutes to draw.

## Authoring rules

Work on a small viewBox, typically 7x7 to 8x9. A larger grid tempts you into
detail that stops reading as pixel art, and every rect should be at least 1
unit, never fractional.

Set `shapeRendering="crispEdges"` so the browser does not antialias the rect
edges into soft grey. Without it the sprite looks blurred at odd sizes and the
whole effect collapses.

Use `fill="currentColor"` for single tone sprites, so an icon inside a link
picks up the link colour and an icon inside a dark button turns white without
a second class. Multi tone sprites such as a mascot set an explicit `fill` per
rect, pulled from the palette tokens rather than invented.

Mark decorative sprites `aria-hidden="true"` and `focusable="false"`. If a
sprite is the only content of a button, put the label in `aria-label` on the
button instead, and remember the no dashes copy rule applies to that attribute.

Keep every sprite in one shared file. Redrawing a check mark locally because
importing felt like effort is how a project ends up with three subtly different
ticks.

## Rotate, do not redraw

`PixelArrow` points right. Every other direction is a CSS transform on the same
component:

```css
.pd-arrow--up    { transform: rotate(-90deg); }
.pd-arrow--down  { transform: rotate(90deg); }
.pd-arrow--left  { transform: rotate(180deg); }
```

This matters more than it sounds. Four hand drawn arrows will not be pixel
identical to each other, and the inconsistency is visible when two sit near
each other.

## Sizing

Sprites are drawn on a tiny grid, so they scale by integer multiples cleanly and
badly at anything else. Prefer sizes that are a whole multiple of the viewBox
where you can, meaning an 8 unit sprite at 8, 16, 24 or 32 pixels. In practice
11 and 12 pixel inline icons look fine because they sit next to text, but a
large decorative sprite should be sized on the multiple.

## Spark placement

Sparks are the one purely decorative element in the system, so they need to
stay out of the way of content. Two placements, chosen by how much padding the
container has.

**Spacious section**, meaning generous padding of 40px or more. Sit the spark
inside the container's own padding with a positive offset, so it never reaches
as far as the content.

```css
.pd-section { position: relative; padding: 56px 40px; }
.pd-section .pd-spark { position: absolute; top: 32px; right: 28px; }
```

**Dense card**, meaning tight padding of around 20px. Perch the spark outside
the card corner with a small negative offset, sized up a little from the icon
default. This guarantees no overlap regardless of how tightly the card is
packed, and it is the same technique the mascot uses on a hero panel corner.

```css
.pd-card { position: relative; padding: 20px; }
.pd-card .pd-spark { position: absolute; top: -14px; right: -10px; width: 18px; height: 18px; }
```

One spark per card at most, and not on every card in a grid. The spark marks
the thing worth looking at first.

## Animation

Stepped, never eased, and always gated behind reduced motion:

```css
@keyframes pd-twinkle {
  50% { opacity: .4; transform: scale(.75); }
}
@media (prefers-reduced-motion: no-preference) {
  .pd-spark { animation: pd-twinkle 1.4s steps(2) infinite; }
}
```

`steps(2)` snaps between two states, which is what makes it read as a sprite
animation rather than a CSS effect. If a sprite needs more life, add frames by
raising the step count rather than by easing.

## Larger sprite packs

Do not fetch external binary assets automatically. If a project wants richer
sprites or animation later, Kenney.nl is CC0 public domain, free and needs no
attribution, which makes it a good source to hand pick from deliberately rather
than something to wire up unprompted.
