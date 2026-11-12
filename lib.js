// Pure functions of the Teamwand. They run in the browser (as window.Teamwand)
// and in Node (via require) so that `npm test` can check them in CI.
(function (root) {
  "use strict";

  // GitHub logins: letters, digits and single hyphens, at most 39 characters.
  const LOGIN_PATTERN = /^[A-Za-z0-9](?:[A-Za-z0-9]|-(?=[A-Za-z0-9])){0,38}$/;
  const MAX_MOTTO_LENGTH = 120;

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

  const api = { validateEntry, compareByLogin, findUnsorted };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = api;
  } else {
    root.Teamwand = api;
  }
})(typeof window !== "undefined" ? window : globalThis);
