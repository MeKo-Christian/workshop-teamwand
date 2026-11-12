// Pure functions of the Teamwand. They run in the browser (as window.Teamwand)
// and in Node (via require) so that `npm test` can check them in CI.
(function (root) {
  "use strict";

  // GitHub logins: letters, digits and single hyphens, at most 39 characters.
  const LOGIN_PATTERN = /^[A-Za-z0-9](?:[A-Za-z0-9]|-(?=[A-Za-z0-9])){0,38}$/;
  const MAX_MOTTO_LENGTH = 120;
  // Optional card effects; each one has a .card--<effect> rule in style.css.
  const CARD_EFFECTS = ["hack"];
  // Neon colors of the displaced squares in the "hack" effect.
  const GLITCH_TINTS = ["#00f0ff", "#ff2bd6", "#9dff00"];
  const GLITCH_GLYPHS = Array.from("#$%&@!?<>/01");

  // Returns a list of problems with one Teamwand entry; empty means valid.
  function validateEntry(entry) {
    const errors = [];
    if (!entry || typeof entry !== "object") {
      return ["entry is not an object"];
    }
    if (typeof entry.login !== "string" || !LOGIN_PATTERN.test(entry.login)) {
      errors.push("login is not a valid GitHub login");
    }
    if (typeof entry.name !== "string" || entry.name.trim() === "") {
      errors.push("name is missing");
    }
    if (typeof entry.emoji !== "string" || entry.emoji.trim() === "") {
      errors.push("emoji is missing");
    }
    if (typeof entry.motto !== "string" || entry.motto.trim() === "") {
      errors.push("motto is missing");
    } else if (entry.motto.length > MAX_MOTTO_LENGTH) {
      errors.push(`motto is longer than ${MAX_MOTTO_LENGTH} characters`);
    }
    if (entry.effect !== undefined && !CARD_EFFECTS.includes(entry.effect)) {
      errors.push(`effect is not one of: ${CARD_EFFECTS.join(", ")}`);
    }
    return errors;
  }

  // Orders entries by login, ignoring case, like GitHub does.
  function compareByLogin(a, b) {
    const left = a.login.toLowerCase();
    const right = b.login.toLowerCase();
    if (left < right) return -1;
    if (left > right) return 1;
    return 0;
  }

  // Returns the index of the first entry that is out of order, or -1.
  function findUnsorted(team) {
    for (let i = 1; i < team.length; i++) {
      if (compareByLogin(team[i - 1], team[i]) >= 0) {
        return i;
      }
    }
    return -1;
  }

  // Plans one frame of the "hack" effect: how far the color channels split, which
  // horizontal slices shift and which squares get copied elsewhere. Idle frames
  // barely move; burst frames tear the card apart. The squares stay small, so a
  // burst never turns into a full-card flash (WCAG 2.3.1).
  function glitchFrame(width, height, burst, random = Math.random) {
    if (width <= 0 || height <= 0) {
      return { split: 0, slices: [], blocks: [] };
    }
    const between = (min, max) => Math.round(min + random() * (max - min));
    const split = burst ? between(4, 12) : between(1, 2);

    let sliceCount = random() < 0.12 ? 1 : 0;
    if (burst) {
      sliceCount = between(4, 9);
    }
    const slices = [];
    for (let i = 0; i < sliceCount; i++) {
      const sliceHeight = Math.min(height, burst ? between(2, Math.max(2, height * 0.12)) : between(1, 3));
      const reach = burst ? Math.max(1, width * 0.15) : 6;
      slices.push({ y: between(0, height - sliceHeight), height: sliceHeight, dx: between(-reach, reach) });
    }

    const blocks = [];
    const blockCount = burst ? between(3, 8) : 0;
    for (let i = 0; i < blockCount; i++) {
      const limit = Math.min(width, height);
      const size = Math.min(limit, between(6, Math.max(6, limit * 0.16)));
      blocks.push({
        sx: between(0, width - size),
        sy: between(0, height - size),
        dx: between(0, width - size),
        dy: between(0, height - size),
        size,
        tint: random() < 0.5 ? GLITCH_TINTS[Math.floor(random() * GLITCH_TINTS.length)] : null,
      });
    }
    return { split, slices, blocks };
  }

  // A burst schedule that starts calm, for when the "hack" animation (re)starts.
  // Without it, the time spent paused would trigger a burst on the first frame.
  function calmBursts(now, random = Math.random) {
    return { burstEnd: now, nextBurst: now + 1200 + random() * 1800 };
  }

  // Returns the schedule to use at time `now` (ms): unchanged until the next burst
  // is due, then with a burst of 120-400 ms and a pause of 1.2-3 s after it. A burst
  // is running while now < burstEnd.
  function advanceBursts(schedule, now, random = Math.random) {
    if (now < schedule.nextBurst) {
      return schedule;
    }
    return calmBursts(now + 120 + random() * 280, random);
  }

  // Points of the oscilloscope trace in the "hack" effect, at time `now` (ms): two
  // sine waves multiplied, plus noise. A burst makes it swing and jitter more.
  function scopeTrace(width, height, now, burst, random = Math.random) {
    const base = height * 0.74;
    const amplitude = height * (burst ? 0.2 : 0.05);
    const jitter = burst ? 10 : 1.5;
    const points = [];
    for (let x = 0; x <= width; x += 3) {
      const wave = Math.sin(x * 0.07 + now * 0.006) * Math.sin(x * 0.013 - now * 0.002);
      points.push({ x, y: base + wave * amplitude + (random() - 0.5) * jitter });
    }
    return points;
  }

  // Replaces about `amount` (0 to 1) of the characters with glitch glyphs. Spaces
  // stay, so the words keep their shape and the text stays recognizable.
  function scrambleText(text, amount, random = Math.random) {
    return Array.from(text)
      .map((char) => {
        if (/\s/.test(char) || random() >= amount) {
          return char;
        }
        return GLITCH_GLYPHS[Math.floor(random() * GLITCH_GLYPHS.length)];
      })
      .join("");
  }

  // Random bytes as a line of a hex dump, e.g. "de ad be ef".
  function hexDump(bytes, random = Math.random) {
    return Array.from({ length: bytes }, () =>
      Math.floor(random() * 256)
        .toString(16)
        .padStart(2, "0"),
    ).join(" ");
  }

  // Breaks text into lines no wider than maxWidth, as the browser does for a
  // paragraph. `measure` returns a string's width. A word wider than maxWidth
  // gets a line of its own.
  function wrapText(text, maxWidth, measure) {
    const lines = [];
    let line = "";
    for (const word of text.split(/\s+/).filter(Boolean)) {
      const candidate = line ? `${line} ${word}` : word;
      if (line && measure(candidate) > maxWidth) {
        lines.push(line);
        line = word;
      } else {
        line = candidate;
      }
    }
    return line ? [...lines, line] : lines;
  }

  const api = {
    validateEntry,
    compareByLogin,
    findUnsorted,
    glitchFrame,
    calmBursts,
    advanceBursts,
    scopeTrace,
    scrambleText,
    hexDump,
    wrapText,
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = api;
  } else {
    root.Teamwand = api;
  }
})(typeof window !== "undefined" ? window : globalThis);
