# AGENTS.md

Rules for AI agents (and humans) working in this repository. The AI reviewer
checks pull requests against this file.

This is the playground of a Git & GitHub workshop: a static page
("Teamwand") in plain HTML, CSS and JavaScript. There is no build step and no
backend. The page must keep working when `index.html` is opened via `file://`.

## Workflow

- Never commit to `main`. Every change goes through a feature branch and a pull
  request; the ruleset on `main` enforces this.
- Branch names: `<type>/<issue-number>-<short-description>`, e.g.
  `feat/12-suchfeld`.
- One issue per pull request. Keep pull requests small; do not mix unrelated
  changes.
- PR titles follow Conventional Commits: `type(scope): description`, with type
  `feat`, `fix`, `docs`, `style`, `refactor`, `test` or `chore`. The PR title
  becomes the squash commit on `main` and the line in the changelog, so it must
  describe the change for a reader of the changelog.
- Put `Closes #<issue>` in the PR body.
- Every pull request needs one approval by another person. An author cannot
  approve their own pull request.
- A red check is fixed in the same branch: read the log
  (`gh run view --log-failed`), fix, push again.

## Code

- `index.html` loads classic scripts in a fixed order: `version.js`, `team.js`,
  `lib.js`, `app.js`. No ES modules, no `fetch`, no external scripts or CDNs.
- Logic that can be tested (filtering, sorting, validation, formatting) goes
  into `lib.js` as a pure function and gets a test in `test/`. `app.js` only
  wires it to the DOM.
- Build DOM nodes with `document.createElement` and `textContent`. Never use
  `innerHTML`, `insertAdjacentHTML` or `document.write` with data.
- `team.js`: one entry per line, sorted by login (case-insensitive). Add your
  own entry at its sorted position; never change other people's entries.
- Do not edit `version.js`, `version.txt`, `CHANGELOG.md` or
  `.release-please-manifest.json`; release-please owns them.
- `workshop/` is trainer material (deck, handout, setup scripts). An entry PR never touches it.
- Do not disable lint rules (`eslint-disable`) to get CI green; fix the code.

## Checks

CI (`.github/workflows/test.yaml`) runs on every push: Prettier, ESLint,
html-validate and `node --test` (job `test`). `test-pr-title` checks the PR
title. With Node installed, run the same locally:

```sh
npm ci
npm run format   # fixes formatting
npm run check    # format check, lint, tests
```

AI reviewers (for example GitHub Copilot, when the ruleset requests it) are
advisory: answer every comment, fix what is right, decline what is not, and
resolve the thread. Only a human approval counts.

## Delivery

- A merge to `main` deploys to GitHub Pages (`pages.yaml`):
  https://meko-christian.github.io/workshop-teamwand/
- release-please keeps a release PR open. Merging it publishes a release; the
  page footer then shows the new version.
