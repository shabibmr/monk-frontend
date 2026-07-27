/**
 * Soft Premium mockups — ambient backgrounds + interaction helpers
 */
(function () {
  "use strict";

  /** Decorative background scene (orbs, grid, floating graphics) */
  function injectBgScene() {
    if (document.querySelector(".bg-scene")) return;
    document.body.classList.add("has-bg-scene");

    const skipFaces = document.body.dataset.bgFaces === "0";
    const base = document.body.dataset.bgAssetBase || "assets/chars";

    const scene = document.createElement("div");
    scene.className = "bg-scene";
    scene.setAttribute("aria-hidden", "true");
    scene.innerHTML = `
      <div class="bg-scene__orb bg-scene__orb--1"></div>
      <div class="bg-scene__orb bg-scene__orb--2"></div>
      <div class="bg-scene__orb bg-scene__orb--3"></div>
      <div class="bg-scene__orb bg-scene__orb--4"></div>
      <div class="bg-scene__grid"></div>
      <div class="bg-scene__ring bg-scene__ring--1"></div>
      <div class="bg-scene__ring bg-scene__ring--2"></div>
      <div class="bg-scene__shape bg-scene__shape--sq"></div>
      <div class="bg-scene__shape bg-scene__shape--circ"></div>
      <div class="bg-scene__shape bg-scene__shape--pill"></div>
      <div class="bg-scene__shape bg-scene__shape--diamond"></div>
      <span class="bg-scene__spark bg-scene__spark--1">✦</span>
      <span class="bg-scene__spark bg-scene__spark--2">✧</span>
      <span class="bg-scene__spark bg-scene__spark--3">✦</span>
      <span class="bg-scene__spark bg-scene__spark--4">★</span>
      <span class="bg-scene__spark bg-scene__spark--5">✧</span>
      <span class="bg-scene__spark bg-scene__spark--6">✦</span>
      <span class="bg-scene__dot bg-scene__dot--a"></span>
      <span class="bg-scene__dot bg-scene__dot--b"></span>
      <span class="bg-scene__dot bg-scene__dot--c"></span>
      <span class="bg-scene__dot bg-scene__dot--d"></span>
      <span class="bg-scene__dot bg-scene__dot--e"></span>
      <div class="bg-scene__wave">
        <svg viewBox="0 0 1440 180" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="waveGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#8F68FF" stop-opacity="0.12"/>
              <stop offset="100%" stop-color="#F46DB4" stop-opacity="0.06"/>
            </linearGradient>
          </defs>
          <path fill="url(#waveGrad)" d="M0,80 C240,140 480,20 720,70 C960,120 1200,40 1440,90 L1440,180 L0,180 Z"/>
          <path fill="none" stroke="rgba(109,62,245,0.12)" stroke-width="2"
            d="M0,100 C300,40 500,150 720,100 C940,50 1140,130 1440,80"/>
        </svg>
      </div>
      <img class="bg-scene__graphic bg-scene__graphic--mascot" src="${base}/monk-mascot.svg" alt="" />
      <img class="bg-scene__graphic bg-scene__graphic--shopper" src="${base}/shopper-mascot.svg" alt="" />
      ${
        skipFaces
          ? ""
          : `
      <img class="bg-scene__graphic bg-scene__graphic--face bg-scene__graphic--face-1" src="${base}/ananya.svg" alt="" />
      <img class="bg-scene__graphic bg-scene__graphic--face bg-scene__graphic--face-2" src="${base}/kai.svg" alt="" />
      <img class="bg-scene__graphic bg-scene__graphic--face bg-scene__graphic--face-3" src="${base}/megha.svg" alt="" />
      `
      }
    `;
    document.body.prepend(scene);

    // Soft inner decoration for mobile phone frame
    const phone = document.querySelector(".phone");
    if (phone && !phone.querySelector(".phone__bg-deco")) {
      const deco = document.createElement("div");
      deco.className = "phone__bg-deco";
      deco.setAttribute("aria-hidden", "true");
      deco.innerHTML = `<div class="orb orb-1"></div><div class="orb orb-2"></div>`;
      phone.insertBefore(deco, phone.firstChild);
    }
  }

  injectBgScene();

  // Toast helper
  function toast(message) {
    let el = document.querySelector(".toast");
    if (!el) {
      el = document.createElement("div");
      el.className = "toast";
      document.body.appendChild(el);
    }
    el.textContent = message;
    el.classList.add("is-visible");
    clearTimeout(el._t);
    el._t = setTimeout(() => el.classList.remove("is-visible"), 2400);
  }

  // Goal / chip multi-select
  document.querySelectorAll("[data-select-group]").forEach((group) => {
    const multi = group.dataset.multi === "true";
    group.querySelectorAll("[data-select]").forEach((item) => {
      item.addEventListener("click", () => {
        if (!multi) {
          group.querySelectorAll("[data-select]").forEach((i) => i.classList.remove("is-selected"));
        }
        item.classList.toggle("is-selected");
      });
    });
  });

  // Gender / chip exclusive select
  document.querySelectorAll("[data-chip-group]").forEach((group) => {
    group.querySelectorAll(".chip--outline").forEach((chip) => {
      chip.addEventListener("click", () => {
        group.querySelectorAll(".chip--outline").forEach((c) => c.classList.remove("is-selected"));
        chip.classList.add("is-selected");
      });
    });
  });

  // Carousel arrows
  document.querySelectorAll("[data-carousel]").forEach((wrap) => {
    const track = wrap.querySelector(".carousel");
    if (!track) return;
    wrap.querySelectorAll("[data-carousel-dir]").forEach((btn) => {
      btn.addEventListener("click", () => {
        const dir = btn.dataset.carouselDir === "prev" ? -1 : 1;
        track.scrollBy({ left: dir * 260, behavior: "smooth" });
      });
    });
  });

  // Demo buttons
  document.querySelectorAll("[data-toast]").forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      toast(btn.dataset.toast || "Done!");
    });
  });

  // Task checkboxes
  document.querySelectorAll("[data-task]").forEach((row) => {
    const box = row.querySelector("[data-task-toggle]");
    if (!box) return;
    box.addEventListener("click", () => {
      row.classList.toggle("is-done");
      box.textContent = row.classList.contains("is-done") ? "✓" : "";
      const progress = document.querySelector("[data-task-progress]");
      if (progress) {
        const total = document.querySelectorAll("[data-task]").length;
        const done = document.querySelectorAll("[data-task].is-done").length;
        progress.textContent = `${done}/${total} completed`;
        const bar = document.querySelector("[data-task-bar]");
        if (bar) bar.style.width = `${(done / total) * 100}%`;
      }
    });
  });

  // Character counters
  document.querySelectorAll("[data-count-for]").forEach((input) => {
    const target = document.querySelector(input.dataset.countFor);
    if (!target) return;
    const max = Number(input.getAttribute("maxlength") || 0);
    const update = () => {
      target.textContent = max ? `${input.value.length}/${max}` : String(input.value.length);
    };
    input.addEventListener("input", update);
    update();
  });

  // Live campaign preview name
  const nameInput = document.querySelector("#campaign-name");
  const namePreview = document.querySelector("[data-preview-name]");
  if (nameInput && namePreview) {
    nameInput.addEventListener("input", () => {
      namePreview.textContent = nameInput.value.trim() || "Campaign Name";
    });
  }

  // Form save demo
  const saveBtn = document.querySelector("[data-save-continue]");
  if (saveBtn) {
    saveBtn.addEventListener("click", (e) => {
      e.preventDefault();
      toast("Saved — continuing to Creators step ✨");
    });
  }

  // Mobile frame time
  const clock = document.querySelector("[data-clock]");
  if (clock) {
    const tick = () => {
      const d = new Date();
      clock.textContent = d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", hour12: false });
    };
    tick();
    setInterval(tick, 30000);
  }

  // Expose toast for inline handlers if needed
  window.MonkMock = { toast };
})();
