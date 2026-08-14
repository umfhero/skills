# Adopting the system in an existing project

Read this when applying the theme to a codebase that already has a different
look, or when extending it to a new page in a project that has it partially.

## Scoping strategy

Put the tokens on `:root` and the component classes wherever the project keeps
its global styles. Scoping tokens to a page wrapper such as `.home-page` works
until the second page adopts the theme, at which point every value has to move
and every reference has to be checked. Tokens are global by nature.

Component styles can be scoped per page during a gradual rollout, as long as
the tokens are not. A shared component's styles should be scoped to that
component rather than to a page, so it renders identically wherever it mounts.

## Rollout order

Do it page by page rather than all at once, and pick the order by how contained
each page is.

1. **The marketing or landing page.** Usually self contained, high visibility,
   and it establishes the palette in a place where mistakes are cheap.
2. **A simple authenticated page**, such as a profile or settings page. This is
   where shared components between light and dark contexts first bite, so it
   surfaces the real problems early.
3. **The dense application pages** last, since they have the most components and
   the most existing styling to unpick.

Leave a page fully on the old theme rather than half converted. A half converted
page looks broken, whereas an unconverted page just looks like it is next in the
queue.

## Shared components across light and dark contexts

The most common real bug. A component with a dark base style gets an override
for the light theme, the override sets `background` and `border-radius`, and
the base rule's near white `color` stays in place, producing invisible white on
white text. It ships because it looks fine in the dark context it was copied
from and nobody clicks it in the light one.

When overriding a shared component for a new context, override every colour
related property together: `color`, `background`, `border`, and the colours of
every child element, not only the ones that visibly differ at a glance.

A stronger fix where the project allows it: give the component its own tokens,
so the context sets `--component-fg` and `--component-bg` and the component
never hardcodes a colour at all.

## Layout gotcha, headers and padding

A shared header meant to run edge to edge gets squeezed inward if the page's
outermost element carries horizontal padding. Keep that element unpadded and
give padding to an inner content wrapper. Then the header, as a direct child of
the unpadded element, sizes itself independently of the page content.

## Framework notes

**Plain CSS or a global stylesheet.** Use `assets/pixel-design.css` directly.

**CSS modules.** Tokens still go in the global stylesheet on `:root`. Translate
the component classes into the module, keeping the same names so the mapping is
obvious. Do not redefine the tokens inside the module.

**Tailwind.** Extend the theme rather than writing the formulas inline
everywhere, so the values stay in one place:

```js
// tailwind.config
theme: {
  extend: {
    colors: { ink: "#0b1130", violet: "#6258e9", /* ... */ },
    borderRadius: { pd: "6px", "pd-lg": "8px" },
    boxShadow: {
      pd: "4px 4px 0 #0b1130",
      "pd-lg": "7px 7px 0 #0b1130",
      "pd-sm": "3px 3px 0 #0b1130",
    },
  },
}
```

Then a card is `border-2 border-ink rounded-pd bg-white shadow-pd`. Define the
pressed button as a component class rather than repeating the hover and active
transforms, since getting the translate and the shadow reduction to match is
the part people get wrong.

**Styled components or CSS in JS.** Export the formulas as shared fragments and
compose them, rather than writing the border, radius and shadow triple by hand
in each component.

## Framework specific link gotcha

Some deployment targets need native navigation rather than a router's link
component. If a codebase already carries an eslint disable comment saying so on
one file, that constraint applies to every new internal link, including inside
a newly extracted shared header. Copying nav markup from an old page carries the
old bug along with it, and a brand logo that silently fails to navigate is easy
to miss in review.

Check how existing internal links are written before adding new ones.

## Audit checklist for a converted page

- Tokens referenced, no hardcoded hex values outside the token block
- No blurred decorative shadow, no `filter: drop-shadow`
- No gradient except the hairline grid texture and the loading skeleton
- No radius above 8px anywhere
- No Unicode glyph used as an icon
- No hyphen or dash in visible copy including `aria-label` and `title`
- Shared components checked in the new context with real content
- Keyboard focus visible on every interactive element
- Reduced motion respected
- Checked at 380px wide
