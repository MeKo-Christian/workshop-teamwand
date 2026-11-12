// Renders window.TEAM as cards. DOM nodes are built with textContent, never
// innerHTML, so an entry cannot inject markup into the page.
(function () {
  "use strict";

  // Cards with an effect get a button that stops and restarts the motion, so
  // nobody has to watch it (WCAG 2.2.2). `onToggle` gets true when it runs again.
  function createEffectToggle(card, onToggle) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "effect-toggle";
    button.setAttribute("aria-label", "Bewegung anhalten");
    button.setAttribute("aria-pressed", "false");
    button.title = "Bewegung anhalten";
    button.textContent = "⏸️";
    button.addEventListener("click", () => {
      const paused = card.classList.toggle("card--paused");
      button.setAttribute("aria-pressed", String(paused));
      button.title = paused ? "Bewegung fortsetzen" : "Bewegung anhalten";
      button.textContent = paused ? "▶️" : "⏸️";
      onToggle(!paused);
    });
    return button;
  }

  const HACK_FRAME_MS = 1000 / 24;
  const HACK_BACKGROUND = "#05080d";
  const HACK_TEXT = [
    { selector: ".emoji", color: "#ffffff", scrambles: false },
    { selector: ".name", color: "#ffffff", scrambles: true },
    { selector: ".login", color: "#a8e6ff", scrambles: false },
    { selector: ".motto", color: "#d7e3e8", scrambles: true },
  ];

  function createLayer() {
    const canvas = document.createElement("canvas");
    return { canvas, ctx: canvas.getContext("2d") };
  }

  // Reads where the browser put the card's texts. A canvas cannot copy DOM
  // content, so the effect redraws them at the same positions.
  function measureHackText(card) {
    const origin = card.getBoundingClientRect();
    return HACK_TEXT.map(({ selector, color, scrambles }) => {
      const element = card.querySelector(selector);
      const box = element.getBoundingClientRect();
      const style = window.getComputedStyle(element);
      return {
        text: element.textContent,
        x: box.left - origin.left - card.clientLeft,
        y: box.top - origin.top - card.clientTop,
        width: box.width,
        height: box.height,
        font: `${style.fontStyle} ${style.fontWeight} ${style.fontSize} ${style.fontFamily}`,
        color,
        scrambles,
      };
    });
  }

  // Hacker glitch drawn on a canvas over the card. The real text stays in the DOM
  // (invisible, see .card--hack-live) for screen readers and the login link. The
  // canvas is decoration, so it is hidden from screen readers and lets clicks
  // through. Returns the function that switches the effect on and off.
  function createHackEffect(card) {
    const screen = createLayer();
    if (!screen.ctx) {
      return () => {};
    }
    screen.canvas.className = "hack-canvas";
    screen.canvas.setAttribute("aria-hidden", "true");
    card.prepend(screen.canvas);

    const { glitchFrame, calmBursts, advanceBursts, scopeTrace, scrambleText, hexDump, wrapText } = window.Teamwand;
    const motion = window.matchMedia("(prefers-reduced-motion: reduce)");
    const text = createLayer();
    const channels = ["#ff0000", "#00ff00", "#0000ff"].map((color) => ({ color, ...createLayer() }));
    const frame = createLayer();
    const hex = createLayer();
    const scanlines = createLayer();
    const layers = [screen, text, ...channels, frame, hex, scanlines];

    let width = 0;
    let height = 0;
    let scale = 1;
    let items = [];
    let enabled = true;
    let onScreen = false;
    let request = 0;
    let lastFrame = 0;
    let bursts = calmBursts(0);
    let scrambled = false;
    let frameCount = 0;

    // Draws the texts, then derives one layer per color channel from them: the
    // layers add up to the original colors when they are aligned.
    function drawText(amount) {
      const ctx = text.ctx;
      ctx.clearRect(0, 0, width, height);
      ctx.textBaseline = "middle";
      for (const item of items) {
        ctx.font = item.font;
        ctx.fillStyle = item.color;
        // +1: the login's box is exactly as wide as its text; rounding must not wrap it.
        const lines = wrapText(item.text, item.width + 1, (line) => ctx.measureText(line).width);
        const lineHeight = item.height / Math.max(lines.length, 1);
        lines.forEach((line, i) => {
          const shown = item.scrambles && amount > 0 ? scrambleText(line, amount) : line;
          ctx.fillText(shown, item.x, item.y + lineHeight * (i + 0.5));
        });
      }
      for (const channel of channels) {
        const c = channel.ctx;
        c.globalCompositeOperation = "source-over";
        c.fillStyle = channel.color;
        c.fillRect(0, 0, width, height);
        c.globalCompositeOperation = "multiply";
        c.drawImage(text.canvas, 0, 0, width, height);
        c.globalCompositeOperation = "destination-in";
        c.drawImage(text.canvas, 0, 0, width, height);
      }
      scrambled = amount > 0;
    }

    function drawBackdrops() {
      hex.ctx.clearRect(0, 0, width, height);
      hex.ctx.font = "10px monospace";
      hex.ctx.fillStyle = "#3dff9e";
      hex.ctx.textBaseline = "top";
      const bytes = Math.ceil(width / 18);
      for (let y = 0; y < height; y += 13) {
        hex.ctx.fillText(hexDump(bytes), 4, y);
      }
      scanlines.ctx.clearRect(0, 0, width, height);
      scanlines.ctx.fillStyle = "rgba(0, 0, 0, 0.28)";
      for (let y = 0; y < height; y += 3) {
        scanlines.ctx.fillRect(0, y, width, 1);
      }
    }

    function layout() {
      width = card.clientWidth;
      height = card.clientHeight;
      if (!width || !height) {
        return;
      }
      scale = Math.min(window.devicePixelRatio || 1, 2);
      for (const layer of layers) {
        layer.canvas.width = Math.round(width * scale);
        layer.canvas.height = Math.round(height * scale);
        layer.ctx.setTransform(scale, 0, 0, scale, 0, 0);
      }
      items = measureHackText(card);
      drawText(0);
      drawBackdrops();
    }

    // A faint oscilloscope trace, because this is the card of "Erst messen".
    function drawTrace(ctx, now, burst) {
      ctx.strokeStyle = "rgba(61, 255, 158, 0.4)";
      ctx.lineWidth = 1;
      ctx.beginPath();
      for (const { x, y } of scopeTrace(width, height, now, burst)) {
        ctx.lineTo(x, y);
      }
      ctx.stroke();
    }

    function render(now) {
      bursts = advanceBursts(bursts, now);
      const burst = now < bursts.burstEnd;
      frameCount++;
      if (burst && frameCount % 3 === 0) {
        drawText(0.35);
      } else if (!burst && scrambled) {
        drawText(0);
      }

      const plan = glitchFrame(width, height, burst);
      const f = frame.ctx;
      f.globalCompositeOperation = "source-over";
      f.fillStyle = HACK_BACKGROUND;
      f.fillRect(0, 0, width, height);

      const scroll = (now / 60) % height;
      f.globalAlpha = 0.14;
      f.drawImage(hex.canvas, 0, scroll, width, height);
      f.drawImage(hex.canvas, 0, scroll - height, width, height);
      f.globalAlpha = 1;
      drawTrace(f, now, burst);

      // Chromatic aberration: red and blue drift apart around green.
      f.globalCompositeOperation = "lighter";
      channels.forEach((channel, i) => {
        f.drawImage(channel.canvas, (i - 1) * plan.split, burst ? (i - 1) * 2 : 0, width, height);
      });

      const ctx = screen.ctx;
      ctx.drawImage(frame.canvas, 0, 0, width, height);
      for (const slice of plan.slices) {
        const sy = slice.y * scale;
        const sh = slice.height * scale;
        ctx.drawImage(frame.canvas, 0, sy, frame.canvas.width, sh, slice.dx, slice.y, width, slice.height);
      }
      for (const block of plan.blocks) {
        const size = block.size * scale;
        ctx.drawImage(
          frame.canvas,
          block.sx * scale,
          block.sy * scale,
          size,
          size,
          block.dx,
          block.dy,
          block.size,
          block.size,
        );
        if (block.tint) {
          ctx.globalAlpha = 0.35;
          ctx.fillStyle = block.tint;
          ctx.fillRect(block.dx, block.dy, block.size, block.size);
          ctx.globalAlpha = 1;
        }
      }
      ctx.drawImage(scanlines.canvas, 0, 0, width, height);
      ctx.fillStyle = "rgba(120, 255, 220, 0.05)";
      ctx.fillRect(0, ((now / 25) % (height + 20)) - 20, width, 20);
    }

    function tick(now) {
      request = window.requestAnimationFrame(tick);
      if (width && height && now - lastFrame >= HACK_FRAME_MS) {
        lastFrame = now;
        render(now);
      }
    }

    // The loop only runs while somebody can see it.
    function update() {
      const live = enabled && !motion.matches;
      card.classList.toggle("card--hack-live", live);
      screen.canvas.hidden = !live;
      const run = live && onScreen && !document.hidden;
      if (run && !request) {
        bursts = calmBursts(window.performance.now());
        request = window.requestAnimationFrame(tick);
      } else if (!run && request) {
        window.cancelAnimationFrame(request);
        request = 0;
      }
    }

    new ResizeObserver(layout).observe(card);
    new IntersectionObserver(([entry]) => {
      onScreen = entry.isIntersecting;
      update();
    }).observe(card);
    motion.addEventListener("change", update);
    document.addEventListener("visibilitychange", update);
    update();

    return (on) => {
      enabled = on;
      update();
    };
  }

  function createCard(entry) {
    const card = document.createElement("li");
    card.className = "card";
    if (entry.effect) {
      card.classList.add(`card--${entry.effect}`);
    }

    const emoji = document.createElement("div");
    emoji.className = "emoji";
    emoji.textContent = entry.emoji;

    const name = document.createElement("p");
    name.className = "name";
    name.textContent = entry.name;

    const login = document.createElement("a");
    login.className = "login";
    login.href = `https://github.com/${encodeURIComponent(entry.login)}`;
    login.textContent = `@${entry.login}`;

    const motto = document.createElement("p");
    motto.className = "motto";
    motto.textContent = entry.motto;

    card.append(emoji, name, login, motto);

    if (entry.effect === "hack") {
      card.append(createEffectToggle(card, createHackEffect(card)));
    }
    return card;
  }

  function render() {
    const wall = document.getElementById("wall");
    const visible = window.TEAM;
    wall.replaceChildren(...visible.map(createCard));

    document.getElementById("version").textContent = `Version ${window.APP_VERSION}`;
  }

  render();
})();
