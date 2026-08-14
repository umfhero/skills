/**
 * Pixel Design sprite set.
 *
 * Keep every sprite in this one file and import from it. Reuse a sprite by
 * rotating it with CSS rather than drawing a second direction, so PixelArrow at
 * rotate(-90deg) is the up arrow and rotate(180deg) is the left arrow.
 *
 * shapeRendering="crispEdges" is what stops the browser antialiasing the rects
 * into soft grey edges, which is the whole point.
 */

type IconProps = { className?: string; size?: number };

export function PixelArrow({ className = "", size = 11 }: IconProps) {
  return (
    <svg
      className={`pd-icon pd-arrow ${className}`.trim()}
      viewBox="0 0 8 8"
      width={size}
      height={size}
      fill="currentColor"
      aria-hidden="true"
      focusable="false"
      shapeRendering="crispEdges"
    >
      <rect x="1" y="3" width="5" height="2" />
      <rect x="4" y="1" width="1" height="1" />
      <rect x="5" y="2" width="1" height="1" />
      <rect x="6" y="3" width="1" height="2" />
      <rect x="5" y="5" width="1" height="1" />
      <rect x="4" y="6" width="1" height="1" />
    </svg>
  );
}

export function PixelSpark({ className = "", size = 12 }: IconProps) {
  return (
    <svg
      className={`pd-icon pd-spark ${className}`.trim()}
      viewBox="0 0 7 7"
      width={size}
      height={size}
      fill="currentColor"
      aria-hidden="true"
      focusable="false"
      shapeRendering="crispEdges"
    >
      <rect x="3" y="0" width="1" height="7" />
      <rect x="0" y="3" width="7" height="1" />
      <rect x="1" y="1" width="1" height="1" />
      <rect x="5" y="1" width="1" height="1" />
      <rect x="1" y="5" width="1" height="1" />
      <rect x="5" y="5" width="1" height="1" />
    </svg>
  );
}

export function PixelCheck({ className = "", size = 12 }: IconProps) {
  return (
    <svg
      className={`pd-icon pd-check ${className}`.trim()}
      viewBox="0 0 8 8"
      width={size}
      height={size}
      fill="currentColor"
      aria-hidden="true"
      focusable="false"
      shapeRendering="crispEdges"
    >
      <rect x="0" y="4" width="1" height="1" />
      <rect x="1" y="5" width="1" height="1" />
      <rect x="2" y="6" width="1" height="1" />
      <rect x="3" y="5" width="1" height="1" />
      <rect x="4" y="4" width="1" height="1" />
      <rect x="5" y="3" width="1" height="1" />
      <rect x="6" y="2" width="1" height="1" />
      <rect x="7" y="1" width="1" height="1" />
    </svg>
  );
}

/**
 * Multi tone sprites set an explicit fill per rect instead of inheriting
 * currentColor, since the whole point is that they have their own palette.
 * Pull the values from the design tokens rather than inventing new ones.
 */
export function PixelMascot({ className = "", size = 44 }: IconProps) {
  return (
    <svg
      className={`pd-icon pd-mascot ${className}`.trim()}
      viewBox="0 0 8 9"
      width={size}
      height={size * (9 / 8)}
      aria-hidden="true"
      focusable="false"
      shapeRendering="crispEdges"
    >
      <rect x="2" y="0" width="4" height="1" fill="#0b1130" />
      <rect x="1" y="1" width="6" height="4" fill="#6258e9" />
      <rect x="2" y="2" width="1" height="1" fill="#ffffff" />
      <rect x="5" y="2" width="1" height="1" fill="#ffffff" />
      <rect x="3" y="4" width="2" height="1" fill="#0b1130" />
      <rect x="1" y="5" width="6" height="1" fill="#0b1130" />
      <rect x="2" y="6" width="4" height="2" fill="#3561dc" />
      <rect x="1" y="8" width="2" height="1" fill="#0b1130" />
      <rect x="5" y="8" width="2" height="1" fill="#0b1130" />
    </svg>
  );
}
