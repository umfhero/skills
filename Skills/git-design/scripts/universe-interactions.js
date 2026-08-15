export function initUniverseParity(root = document) {
  const q = (selector, scope = root) => scope.querySelector(selector);
  const qa = (selector, scope = root) => [...scope.querySelectorAll(selector)];

  const menu = q('[data-menu-toggle]');
  const mobileNav = q('[data-mobile-nav]');
  if (menu && mobileNav) {
    menu.addEventListener('click', () => {
      const open = menu.getAttribute('aria-expanded') !== 'true';
      menu.setAttribute('aria-expanded', String(open));
      menu.setAttribute('aria-label', open ? 'Close navigation' : 'Open navigation');
      mobileNav.hidden = !open;
    });
    qa('a', mobileNav).forEach(link => link.addEventListener('click', () => {
      menu.setAttribute('aria-expanded', 'false');
      menu.setAttribute('aria-label', 'Open navigation');
      mobileNav.hidden = true;
    }));
  }

  qa('[data-media-control]').forEach(button => {
    const stage = button.closest('[data-media-stage], [data-highlight-player]');
    const video = stage ? q('video', stage) : null;
    if (!stage) return;
    button.addEventListener('click', async () => {
      const playing = stage.classList.toggle('is-playing');
      button.setAttribute('aria-pressed', String(playing));
      button.setAttribute('aria-label', playing ? 'Pause video' : 'Play video');
      q('[data-control-label]', button).textContent = playing ? 'Pause' : 'Play';
      if (video?.currentSrc) {
        try { if (playing) await video.play(); else video.pause(); } catch { stage.classList.toggle('is-playing', false); }
      }
    });
  });

  qa('[data-ticker-toggle]').forEach(button => {
    const ticker = button.closest('[data-ticker]');
    button.addEventListener('click', () => {
      const paused = ticker.classList.toggle('is-paused');
      button.setAttribute('aria-pressed', String(paused));
      button.setAttribute('aria-label', paused ? 'Play announcement ticker' : 'Pause announcement ticker');
      q('[data-control-label]', button).textContent = paused ? 'Play' : 'Pause';
    });
  });

  qa('[data-carousel]').forEach(carousel => {
    const slides = qa('[data-slide]', carousel);
    const status = q('[data-carousel-status]', carousel);
    let index = Math.max(0, slides.findIndex(slide => !slide.hidden));
    const show = next => {
      index = (next + slides.length) % slides.length;
      slides.forEach((slide, slideIndex) => {
        const active = slideIndex === index;
        slide.hidden = !active;
        slide.setAttribute('aria-hidden', String(!active));
      });
      if (status) status.textContent = `${index + 1} / ${slides.length}`;
    };
    q('[data-prev]', carousel)?.addEventListener('click', () => show(index - 1));
    q('[data-next]', carousel)?.addEventListener('click', () => show(index + 1));
    show(index);
  });

  qa('[role="tablist"]', root).forEach(tablist => {
    const tabs = qa('[role="tab"]', tablist);
    const activate = tab => {
      tabs.forEach(item => {
        const active = item === tab;
        item.setAttribute('aria-selected', String(active));
        item.tabIndex = active ? 0 : -1;
        const panel = root.getElementById(item.getAttribute('aria-controls'));
        if (panel) panel.hidden = !active;
      });
    };
    tabs.forEach((tab, index) => {
      tab.addEventListener('click', () => activate(tab));
      tab.addEventListener('keydown', event => {
        if (!['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(event.key)) return;
        event.preventDefault();
        const nextIndex = event.key === 'Home' ? 0 : event.key === 'End' ? tabs.length - 1 : (index + (event.key === 'ArrowRight' ? 1 : -1) + tabs.length) % tabs.length;
        tabs[nextIndex].focus(); activate(tabs[nextIndex]);
      });
    });
  });

  qa('[data-playlist-button]').forEach(button => {
    button.addEventListener('click', () => {
      const playlist = button.closest('[data-playlist]');
      const player = q('[data-highlight-player]', playlist);
      qa('[data-playlist-button]', playlist).forEach(item => item.setAttribute('aria-pressed', String(item === button)));
      player.dataset.tone = button.dataset.tone;
      q('[data-highlight-title]', player).textContent = button.dataset.title;
      q('[data-highlight-meta]', player).textContent = button.dataset.meta;
    });
  });
}
