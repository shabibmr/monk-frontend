/* ============================================================================
   Monk redesign mockups — interaction layer
   Vanilla JS, no dependencies. Proves the interactions in design_context.md §6
   and §7; it is not a framework and is not meant to become one.

   Everything here is progressive: the pages render correctly with JS disabled.
   ========================================================================= */

(function () {
  'use strict';

  const $$ = (sel, root) => Array.from((root || document).querySelectorAll(sel));

  /* --- Carousel (§5.3) ----------------------------------------------------
     Chevrons disable at the scroll extents rather than wrapping, matching the
     spec's "hidden at scroll extents" rule. Keyboard-reachable by default
     because they are real <button>s.
     ---------------------------------------------------------------------- */
  function initCarousels() {
    $$('.carousel').forEach((carousel) => {
      const track = carousel.querySelector('.carousel__track');
      const prev = carousel.querySelector('.carousel__nav--prev');
      const next = carousel.querySelector('.carousel__nav--next');
      if (!track) return;

      const page = () => Math.max(track.clientWidth * 0.8, 240);

      function sync() {
        const max = track.scrollWidth - track.clientWidth - 1;
        if (prev) prev.disabled = track.scrollLeft <= 0;
        if (next) next.disabled = track.scrollLeft >= max;
      }

      if (prev) prev.addEventListener('click', () => track.scrollBy({ left: -page(), behavior: 'smooth' }));
      if (next) next.addEventListener('click', () => track.scrollBy({ left: page(), behavior: 'smooth' }));

      track.addEventListener('scroll', sync, { passive: true });
      window.addEventListener('resize', sync);
      sync();
    });
  }

  /* --- Account overflow menu (§5.1 IA decision) ---------------------------
     The five nav items that don't fit the bar live here. Closes on outside
     click and on Escape, and returns focus to the trigger — without that it
     is a keyboard trap.
     ---------------------------------------------------------------------- */
  function initMenus() {
    const menus = $$('[data-menu]');

    function closeAll(except) {
      menus.forEach((wrap) => {
        if (wrap === except) return;
        const panel = wrap.querySelector('.menu');
        const trigger = wrap.querySelector('[aria-haspopup]');
        if (panel) panel.dataset.open = 'false';
        if (trigger) trigger.setAttribute('aria-expanded', 'false');
      });
    }

    menus.forEach((wrap) => {
      const trigger = wrap.querySelector('[aria-haspopup]');
      const panel = wrap.querySelector('.menu');
      if (!trigger || !panel) return;

      trigger.addEventListener('click', (e) => {
        e.stopPropagation();
        const open = panel.dataset.open === 'true';
        closeAll(wrap);
        panel.dataset.open = open ? 'false' : 'true';
        trigger.setAttribute('aria-expanded', open ? 'false' : 'true');
      });

      panel.addEventListener('click', (e) => e.stopPropagation());
    });

    document.addEventListener('click', () => closeAll(null));
    document.addEventListener('keydown', (e) => {
      if (e.key !== 'Escape') return;
      const open = menus.find((w) => {
        const p = w.querySelector('.menu');
        return p && p.dataset.open === 'true';
      });
      closeAll(null);
      if (open) {
        const trigger = open.querySelector('[aria-haspopup]');
        if (trigger) trigger.focus();
      }
    });
  }

  /* --- Stepper (§5.6) -----------------------------------------------------
     Five real steps: Basic Info -> Creators -> Content -> Budget -> Review.
     Completed steps fill and check; upcoming steps stay outlined.
     ---------------------------------------------------------------------- */
  function initSteppers() {
    $$('[data-stepper]').forEach((stepper) => {
      const steps = $$('.step', stepper);
      const links = $$('.step__link', stepper);
      let current = Number(stepper.dataset.stepper) || 1;

      function render() {
        steps.forEach((step, i) => {
          const n = i + 1;
          const state = n < current ? 'done' : n === current ? 'active' : 'todo';
          step.dataset.state = state;
          const num = step.querySelector('.step__num');
          if (num) num.textContent = state === 'done' ? '✓' : String(n);
          if (state === 'active') step.setAttribute('aria-current', 'step');
          else step.removeAttribute('aria-current');
        });
        links.forEach((link, i) => { link.dataset.done = String(i + 1 < current); });
        document.dispatchEvent(new CustomEvent('stepchange', { detail: { step: current } }));
      }

      steps.forEach((step, i) => {
        step.addEventListener('click', () => { current = i + 1; render(); });
      });

      $$('[data-step-next]').forEach((btn) =>
        btn.addEventListener('click', () => { current = Math.min(current + 1, steps.length); render(); })
      );
      $$('[data-step-prev]').forEach((btn) =>
        btn.addEventListener('click', () => { current = Math.max(current - 1, 1); render(); })
      );

      render();
    });
  }

  /* --- Toggles: option cards, segmented controls, tasks, tabs ------------- */
  function initToggles() {
    // Selectable option cards — multi-select (campaign goals)
    $$('.optcard').forEach((card) => {
      card.addEventListener('click', () => {
        const on = card.getAttribute('aria-pressed') === 'true';
        card.setAttribute('aria-pressed', on ? 'false' : 'true');
      });
    });

    // Segmented control — single-select within its group
    $$('.segmented').forEach((group) => {
      const btns = $$('.segmented__btn', group);
      btns.forEach((btn) => {
        btn.addEventListener('click', () => {
          btns.forEach((b) => b.setAttribute('aria-pressed', String(b === btn)));
        });
      });
    });

    // Task checkboxes — update the "N/3 completed" footer and its progress bar
    $$('[data-tasklist]').forEach((list) => {
      const checks = $$('.task__check', list);
      const label = list.querySelector('[data-task-count]');
      const bar = list.querySelector('.progress__fill');

      function sync() {
        const done = checks.filter((c) => c.getAttribute('aria-checked') === 'true').length;
        if (label) label.textContent = done + '/' + checks.length + ' completed';
        if (bar) bar.style.width = (done / checks.length) * 100 + '%';
      }

      checks.forEach((check) => {
        check.addEventListener('click', () => {
          const on = check.getAttribute('aria-checked') === 'true';
          check.setAttribute('aria-checked', on ? 'false' : 'true');
          check.textContent = on ? '' : '✓';
          sync();
        });
      });
      sync();
    });

    // Mobile bottom tab bar
    $$('.tabbar').forEach((bar) => {
      const tabs = $$('.tab', bar);
      tabs.forEach((tab) => {
        tab.addEventListener('click', () => {
          tabs.forEach((t) => t.removeAttribute('aria-current'));
          tab.setAttribute('aria-current', 'page');
        });
      });
    });
  }

  /* --- Character counters (§7.2) -----------------------------------------
     Turns danger at 100%. The colour is a reinforcement, not the signal —
     the count itself is always readable (§9).
     ---------------------------------------------------------------------- */
  function initCounters() {
    $$('[data-counter]').forEach((input) => {
      const target = document.getElementById(input.dataset.counter);
      if (!target) return;
      const max = Number(input.getAttribute('maxlength')) || 0;

      function sync() {
        target.textContent = input.value.length + '/' + max;
        target.classList.toggle('counter--full', max > 0 && input.value.length >= max);
      }
      input.addEventListener('input', sync);
      sync();
    });
  }

  function init() {
    initCarousels();
    initMenus();
    initSteppers();
    initToggles();
    initCounters();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
