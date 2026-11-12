const { test } = require("node:test");
const assert = require("node:assert/strict");
const {
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
} = require("../lib.js");

const valid = { login: "octo-cat", name: "Octo Cat", emoji: "🐙", motto: "Ship it." };

test("validateEntry accepts a complete entry", () => {
  assert.deepEqual(validateEntry(valid), []);
  assert.deepEqual(validateEntry({ ...valid, effect: "hack" }), []);
});

test("validateEntry reports each problem", () => {
  const cases = [
    { entry: null, want: ["entry is not an object"] },
    { entry: { ...valid, login: "-bad" }, want: ["login is not a valid GitHub login"] },
    { entry: { ...valid, login: "two--hyphens" }, want: ["login is not a valid GitHub login"] },
    { entry: { ...valid, name: " " }, want: ["name is missing"] },
    { entry: { ...valid, emoji: "" }, want: ["emoji is missing"] },
    { entry: { ...valid, motto: undefined }, want: ["motto is missing"] },
    { entry: { ...valid, motto: "x".repeat(121) }, want: ["motto is longer than 120 characters"] },
    { entry: { ...valid, effect: "wobble" }, want: ["effect is not one of: hack"] },
  ];
  for (const { entry, want } of cases) {
    assert.deepEqual(validateEntry(entry), want);
  }
});

test("compareByLogin ignores case", () => {
  assert.equal(compareByLogin({ login: "alice" }, { login: "Bob" }), -1);
  assert.equal(compareByLogin({ login: "Bob" }, { login: "alice" }), 1);
  assert.equal(compareByLogin({ login: "ALICE" }, { login: "alice" }), 0);
});

test("findUnsorted finds the first entry out of order", () => {
  assert.equal(findUnsorted([]), -1);
  assert.equal(findUnsorted([{ login: "a" }, { login: "B" }, { login: "c" }]), -1);
  assert.equal(findUnsorted([{ login: "a" }, { login: "c" }, { login: "b" }]), 2);
  assert.equal(findUnsorted([{ login: "a" }, { login: "A" }]), 1, "duplicates count as unsorted");
});

// Repeats the given values, so a test can steer every "random" decision.
function sequence(...values) {
  let i = 0;
  return () => values[i++ % values.length];
}

test("glitchFrame keeps idle frames calm and tears burst frames apart", () => {
  const idle = glitchFrame(300, 150, false, () => 0.5);
  assert.equal(idle.slices.length, 0, "0.5 is above the chance of an idle slice");
  assert.equal(idle.blocks.length, 0);
  assert.ok(idle.split <= 2);

  const burst = glitchFrame(300, 150, true, () => 0.5);
  assert.ok(burst.split >= 4);
  assert.ok(burst.slices.length >= 4);
  assert.ok(burst.blocks.length >= 3);
});

test("glitchFrame is deterministic for a fixed random function", () => {
  const values = [0.1, 0.9, 0.4, 0.7, 0.2];
  assert.deepEqual(glitchFrame(300, 150, true, sequence(...values)), glitchFrame(300, 150, true, sequence(...values)));
});

test("glitchFrame stays inside the card and never covers most of it", () => {
  for (const [width, height] of [
    [300, 150],
    [20, 8],
    [1, 1],
  ]) {
    for (const value of [0, 0.25, 0.5, 0.75, 0.999]) {
      const { slices, blocks } = glitchFrame(width, height, true, sequence(value, 0.999 - value, 0.5));
      for (const slice of slices) {
        assert.ok(slice.y >= 0 && slice.y + slice.height <= height, `slice ${JSON.stringify(slice)}`);
      }
      for (const block of blocks) {
        assert.ok(block.dx >= 0 && block.dx + block.size <= width, `block ${JSON.stringify(block)}`);
        assert.ok(block.dy >= 0 && block.dy + block.size <= height, `block ${JSON.stringify(block)}`);
        assert.ok(block.sx >= 0 && block.sx + block.size <= width, `block ${JSON.stringify(block)}`);
        assert.ok(block.sy >= 0 && block.sy + block.size <= height, `block ${JSON.stringify(block)}`);
      }
    }
  }
  const { blocks } = glitchFrame(300, 150, true, () => 0.999);
  const area = blocks.reduce((sum, block) => sum + block.size ** 2, 0);
  assert.ok(area < 300 * 150 * 0.25, `squares cover ${area} px`);
});

test("glitchFrame plans nothing for a card without a size", () => {
  assert.deepEqual(glitchFrame(0, 0, true), { split: 0, slices: [], blocks: [] });
});

test("scrambleText replaces characters but keeps spaces and length", () => {
  const text = "Erst messen, dann meinen.";
  assert.equal(scrambleText(text, 0), text, "amount 0 changes nothing");
  const scrambled = scrambleText(text, 1, () => 0);
  assert.equal(scrambled.length, text.length);
  assert.equal(scrambled.split(" ").length, text.split(" ").length, "spaces stay");
  assert.ok(
    scrambled.split("").every((char, i) => char !== text[i] || char === " "),
    "amount 1 replaces every other character",
  );
});

test("scrambleText does not break characters outside the BMP", () => {
  assert.equal(
    scrambleText("🐙🐙", 0.5, () => 0.9),
    "🐙🐙",
  );
  assert.equal(Array.from(scrambleText("🐙🐙", 1, () => 0)).length, 2);
});

test("hexDump formats bytes as two-digit hex", () => {
  assert.equal(hexDump(2, sequence(0, 0.999)), "00 ff");
  assert.equal(hexDump(0), "");
});

test("wrapText wraps like a paragraph", () => {
  const measure = (text) => text.length;
  assert.deepEqual(wrapText("Erst messen, dann meinen.", 12, measure), ["Erst messen,", "dann meinen."]);
  assert.deepEqual(wrapText("kurz", 12, measure), ["kurz"]);
  assert.deepEqual(wrapText("a verylongwordindeed b", 5, measure), ["a", "verylongwordindeed", "b"]);
  assert.deepEqual(wrapText("", 12, measure), []);
});

test("calmBursts starts without a burst and plans the next one 1.2 to 3 s ahead", () => {
  assert.deepEqual(
    calmBursts(1000, () => 0),
    { burstEnd: 1000, nextBurst: 2200 },
  );
  assert.deepEqual(
    calmBursts(1000, () => 1),
    { burstEnd: 1000, nextBurst: 4000 },
  );
});

test("advanceBursts moves from calm to burst and back to calm", () => {
  const calm = { burstEnd: 1000, nextBurst: 2200 };
  assert.equal(
    advanceBursts(calm, 2199, () => 0),
    calm,
    "nothing changes before the burst is due",
  );

  const started = advanceBursts(calm, 2200, () => 0);
  assert.deepEqual(started, { burstEnd: 2320, nextBurst: 3520 }, "shortest burst and pause");
  assert.ok(2200 < started.burstEnd, "the burst is running");

  assert.equal(
    advanceBursts(started, 2319, () => 0),
    started,
    "the burst keeps running",
  );
  assert.ok(2320 >= started.burstEnd, "and then it is over");
  assert.deepEqual(
    advanceBursts(calm, 2200, () => 1),
    { burstEnd: 2600, nextBurst: 5600 },
    "longest burst and pause",
  );
});

test("scopeTrace spans the card and swings more during a burst", () => {
  const swing = (points) => Math.max(...points.map((p) => p.y)) - Math.min(...points.map((p) => p.y));
  const random = () => 0.5;
  const idle = scopeTrace(300, 150, 1234, false, random);
  const burst = scopeTrace(300, 150, 1234, true, random);
  assert.equal(idle[0].x, 0);
  assert.equal(idle.at(-1).x, 300);
  assert.ok(swing(burst) > swing(idle));
  assert.ok(
    idle.every((p) => Math.abs(p.y - 111) <= 150 * 0.05),
    "stays around 74 % of the height",
  );
  assert.deepEqual(scopeTrace(0, 0, 0, false, random), [{ x: 0, y: 0 }]);
});
