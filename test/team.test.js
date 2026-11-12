// Checks the real data in team.js, so a broken or unsorted entry turns CI red.
const { test } = require("node:test");
const assert = require("node:assert/strict");
const { validateEntry, findUnsorted } = require("../lib.js");

globalThis.window = {};
require("../team.js");
const team = globalThis.window.TEAM;

test("team.js defines a non-empty list", () => {
  assert.ok(Array.isArray(team) && team.length > 0);
});

test("every entry is valid", () => {
  for (const entry of team) {
    assert.deepEqual(validateEntry(entry), [], `entry ${JSON.stringify(entry)}`);
  }
});

test("entries are sorted by login, without duplicates", () => {
  const index = findUnsorted(team);
  assert.equal(index, -1, index === -1 ? "" : `"${team[index].login}" must come before "${team[index - 1].login}"`);
});
