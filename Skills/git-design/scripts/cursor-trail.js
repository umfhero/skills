/** Draw an optional, accessible pointer trail. Call the returned function on unmount. */
export function createCursorTrail(canvas, options = {}) {
  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)');
  const fine = window.matchMedia('(pointer: fine)');
  if (reduced.matches || !fine.matches || !(canvas instanceof HTMLCanvasElement)) return () => {};
  const ctx = canvas.getContext('2d'); if (!ctx) return () => {};
  const color = options.color || '#08872b', maximum = options.maxParticles || 32, particles = [];
  let frame = 0, previous = null, bounds = null;
  const resize = () => { bounds = canvas.getBoundingClientRect(); const ratio = Math.min(devicePixelRatio || 1, 2); canvas.width = Math.max(1, Math.round(bounds.width * ratio)); canvas.height = Math.max(1, Math.round(bounds.height * ratio)); ctx.setTransform(ratio, 0, 0, ratio, 0, 0); };
  const draw = () => { frame = 0; ctx.clearRect(0, 0, bounds.width, bounds.height); ctx.fillStyle = color; for (let i = particles.length - 1; i >= 0; i -= 1) { const p = particles[i]; p.life -= .035; p.x += p.dx; p.y += p.dy; if (p.life <= 0) { particles.splice(i, 1); continue; } ctx.globalAlpha = p.life * .72; ctx.fillRect(Math.round(p.x), Math.round(p.y), Math.ceil(p.size * p.life), Math.ceil(p.size * p.life)); } ctx.globalAlpha = 1; if (particles.length) frame = requestAnimationFrame(draw); };
  const move = event => { if (!bounds) resize(); const x = event.clientX - bounds.left, y = event.clientY - bounds.top; if (x < 0 || y < 0 || x > bounds.width || y > bounds.height) return; const speed = previous ? Math.hypot(x - previous.x, y - previous.y) : 0; previous = { x, y }; for (let i = 0, count = Math.max(1, Math.min(4, Math.round(speed / 18))); i < count; i += 1) particles.push({ x, y, dx: (Math.random() - .5) * 1.5, dy: (Math.random() - .5) * 1.5, life: 1, size: 2 + Math.random() * 4 }); particles.splice(0, Math.max(0, particles.length - maximum)); if (!frame) frame = requestAnimationFrame(draw); };
  const observer = new ResizeObserver(resize), parent = canvas.parentElement; observer.observe(canvas); resize(); parent?.addEventListener('pointermove', move, { passive: true });
  return () => { parent?.removeEventListener('pointermove', move); observer.disconnect(); if (frame) cancelAnimationFrame(frame); ctx.clearRect(0, 0, bounds?.width || 0, bounds?.height || 0); };
}
