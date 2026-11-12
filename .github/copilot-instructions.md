# Copilot instructions

This repository is the playground of a Git & GitHub workshop: a static page
("Teamwand") in plain HTML, CSS and JavaScript, opened from `file://`, with no
build step and no backend. `AGENTS.md` holds the rules; follow it.

## Code review

The authors are workshop participants learning the pull-request flow. Write
review comments in German, short, friendly and concrete.

Comment on:

- an entry in `team.js` that changes or removes someone else's entry;
- markup built from data with `innerHTML`, `insertAdjacentHTML` or
  `document.write` instead of `document.createElement` and `textContent`;
- an ES module, `fetch`, an external script or a CDN in `index.html`;
- new logic outside `lib.js`, or a new function in `lib.js` without a test in
  `test/`;
- an `eslint-disable` comment or a loosened lint rule;
- an edit to `version.js`, `version.txt`, `CHANGELOG.md` or
  `.release-please-manifest.json`, which release-please owns.

Do not comment on what CI already checks: formatting, ESLint, html-validate, the
sort order and line format of `team.js` and the PR title. A one-line entry in
`team.js` that passes CI needs no comment.
