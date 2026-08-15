# Motion and icons

## Cursor field

The homepage exposes a pointer-led decorative treatment around major sections and a WebGL canvas in its hero and close. Recreate the feeling independently with a 2D canvas, not the original 3D model or source code.

Use `scripts/cursor-trail.js` as follows:

```html
<section class="gd-trail-area">
  <canvas class="gd-trail" aria-hidden="true"></canvas>
  <!-- section content -->
</section>
<script type="module">
  import { createCursorTrail } from './cursor-trail.js';
  createCursorTrail(document.querySelector('.gd-trail'));
</script>
```

The module emits a small #08872b, square-pixel tail whose density responds to pointer velocity. It never captures input, uses no personal data, clips device pixel ratio to 2, and returns a teardown function. It exits on coarse pointers and `prefers-reduced-motion: reduce`.

For richer abstract backgrounds, layer three deliberate ingredients: a static block or line grid, one slow low-contrast drift, and the pointer tail. Keep the field behind content and never make a pointer gesture necessary to understand or use the section.

## Motion recipes

| Element | Motion | Timing |
| --- | --- | --- |
| Green primary CTA | Background darkens; arrow shifts 3px right/up | 200ms ease-in-out |
| Outline action | Border/field becomes white; arrow shifts 4px right | 200ms ease-in-out |
| Nav link | White background fill | 400ms |
| Ticker | Duplicated text track translates left | 20–28s linear, infinite |
| Content reveal | Opacity 0→1, `translateY(16px)→0` | 300–500ms ease-out, once |
| Quote carousel | Crossfade current slide | 250–300ms ease-out |

Gate ticking, revealing, cursors, and carousel auto-advance behind `prefers-reduced-motion: no-preference`. Pausing an ambient ticker on hover/focus is a nice refinement. For a video panel, default to a poster and a labeled play button; never auto-play audible video.

## Icon rules

Use a 16px icon in a normal navigation action and 20px on the 78px CTA. Use an SVG with `fill="none"`, `stroke="currentColor"`, `stroke-width="1.5"` or `2`, `stroke-linecap="round"`, and `stroke-linejoin="round"`. This keeps all icons single-color, compact, and optically similar to Octicons without importing GitHub's icon set.

```html
<svg aria-hidden="true" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
  <path d="M3 13 13 3M6 3h7v7" />
</svg>
```

Use the explicit, accessible control label on the button or link, not a title tag on decorative SVG. For an icon-only button, give the button an `aria-label` and retain a visible focus treatment.

## Avoid

- Blob gradients, glass blur, neon glow, soft card shadows, or springy overshoot.
- A custom cursor that hides the platform cursor, responds poorly to touch, or prevents selection.
- More than one motion system in a viewport. If canvas is present, keep all other decoration near-static.
- Reusing GitHub's marks, mascot, event wordmarks, public videos, or WebGL model in a delivered project without rights.
