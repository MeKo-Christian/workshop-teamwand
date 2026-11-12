const { test } = require("node:test");
const assert = require("node:assert/strict");
const { validateEntry, compareByLogin, findUnsorted } = require("../lib.js");

const valid = { login: "octo-cat", name: "Octo Cat", emoji: "🐙", motto: "Ship it." };

test("validateEntry accepts a complete entry", () => {
  assert.deepEqual(validateEntry(valid), []);
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
