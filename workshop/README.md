# Workshop: Git & GitHub

A hands-on workshop for 4–8 participants, 90–120 minutes. The participants
run a whole delivery flow on a shared playground repository, the
"Teamwand". Everyone makes **one change** (their own entry on the wall), and
the group walks it through the flow **together, stage by stage**: short
explanation, do it, short debrief, next stage.

feature branch → conventional commits → pull request via `gh` → CI (format,
lint, tests, PR title) → optional AI review → human review → squash merge → GitHub Pages →
release-please PR → merge → new version on the page.

One GitHub Pages site serves the whole flow: every merge to `main` updates it
(stage 6, "Merge & Deployment"), and merging the release PR shows the new
version in the footer (stage 7, "Release"). The deck mentions once that real
projects usually split this into staging and prod.

**No prior Git knowledge is assumed.** The deck explains clone, `main`,
branch, commit, pull request and CI as they come up. Participants need a
GitHub account (with the repository invitation accepted), Git, an editor such
as VS Code and a browser. An AI assistant (Copilot, Claude Code, …) is
optional. **No local toolchain is needed**: the playground is plain HTML and
JavaScript that opens from `file://`, and CI is the quality gate.

## Contents

| Path                              | What                                                                               |
| --------------------------------- | ---------------------------------------------------------------------------------- |
| `../`                             | The repository itself is the playground and its baseline (`workshop-baseline` tag) |
| `issues/01-hallo-wand.md`         | The entry issue, one per participant (`{{login}}`, `{{reviewer}}`)                 |
| `issues/1x-*.md`                  | Bonus feature issues for fast finishers and later practice                         |
| `scripts/setup-playground.sh`     | Creates the repo, settings, ruleset, access, issues, demo branches                 |
| `scripts/reset-playground.sh`     | Closes leftovers and opens a reset PR back to the baseline                         |
| `spickzettel.md`                  | Participant cheat sheet: commands and prompts per stage (German)                   |
| `slides/git-workshop-handout.typ` | Participant handout, 4 pages, take-aways only (PDF next to it)                     |
| `slides/git-workshop.typ`         | Deck (German, PDF next to it), see [Slides](#slides)                               |

## Preparation

| When     | What                                                                                                                                                                                                                                                     |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ≥ 1 week | Run `workshop/scripts/setup-playground.sh participants.txt` from a checkout of this repository (see below). For a new repository, enable GitHub Pages with "GitHub Actions" as source and allow GitHub Actions to create pull requests (release-please). |
| ≥ 1 week | Copilot review (ruleset rule) needs Copilot on the account or organisation that owns the repository.                                                                                                                                                     |
| ≥ 2 days | Dry run with a second account: one entry PR end to end, the three demo branches, one release. See the checklist below.                                                                                                                                   |
| 1 day    | Send the handout (`workshop/slides/git-workshop-handout.pdf`) and the cheat sheet. Ask everyone to run `gh auth status` and to accept the repository invitation, if GitHub sent one.                                                                     |
| Day of   | Open the repo, the Actions tab and the GitHub Pages site in browser tabs. Have the review ring printed by the setup script at hand.                                                                                                                      |

`participants.txt` holds one GitHub login per line; include yourself if you
want to take part in the review ring. The order defines the review ring:
everyone reviews the next person in the list.

```sh
scripts/setup-playground.sh participants.txt            # MeKo-Christian/workshop-teamwand
scripts/setup-playground.sh participants.txt --repo my-org/teamwand --team ai-workshop   # an org repo, also grant a team
```

### What the setup script configures

- Private repository, baseline pushed to `main`, tag `workshop-baseline`,
  release `0.1.0` (release-please counts from there).
- Squash merge only, PR title and body become the commit, branches are
  deleted after merge, "Update branch" button enabled.
- Ruleset `main`: pull request required, **1 approval**, all review threads
  resolved, squash only, required checks `test` and `test-pr-title`, no force
  push, no deletion, Copilot code review once per PR (`copilot_code_review`,
  not on push, not on drafts). The AI reviews are advisory.
- Write access for each participant (and optionally a team).
- One entry issue per participant, assigned, with their reviewer named; the
  bonus issues; labels `eintrag`, `bonus`, `feature`, `demo`.
- Demo branches for the trainer: `demo/konflikt-a`, `demo/konflikt-b` (both
  insert at the same line of `team.js`) and `demo/rote-ci` (`var` and an
  unused variable, so ESLint fails), each with a **draft** pull request
  labelled `demo`. CI runs on the drafts; the AI reviewers skip them until you
  click "Ready for review" during the demo, so their comments arrive live.
  For the conflict demo, get `demo/konflikt-a` approved and merged, then show
  the conflict on `demo/konflikt-b`.

### CI and AI reviewers

| Workflow               | What                                                                   | Blocks merge |
| ---------------------- | ---------------------------------------------------------------------- | ------------ |
| `test.yaml` · `test`   | Prettier, ESLint, html-validate, `node --test` (incl. `team.js` order) | yes          |
| `test-pr-title.yml`    | Conventional-Commits PR title                                          | yes          |
| Copilot (ruleset rule) | GitHub Copilot, instructions in `.github/copilot-instructions.md`      | no           |
| `pr-auto-assign`       | Assigns the PR to its author                                           | –            |
| `pages.yaml`           | Deploys the page to GitHub Pages on every push to `main`               | –            |
| `release-please.yaml`  | Keeps the release PR open; merging it publishes a release              | –            |

The ruleset requires all review threads resolved, so Stage 4 is a real
exercise in answering and resolving bot comments.

Deliberately not included: `pr-auto-rebase` (it would resolve the Stage 6
conflicts before anyone sees them) and Dependabot (bump PRs would mix into the
participants' queue).

## Agenda (~115 min)

One pass through the whole flow, cut into seven stages. Each stage has a
section slide with the stage bar, at most one or two short explanation slides
and an exercise slide with a time box. Each exercise slide has two columns: on
the left the **git commands and clicks on github.com**, on the right the
same steps as **prompts for an AI assistant**, plus one thing to check by
yourself. Participants pick either column. Wait at the end of each stage
until everyone is through; whoever is fast reviews a neighbour's state or
helps.

| Min     | Stage                  | What happens                                                                                                                             |
| ------- | ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| 0–15    | Intro                  | Agenda, the flow on one slide, the Teamwand repo in the browser, "Was ihr braucht": check `git --version`, `git config`, invite.         |
| 15–25   | 1 · Klonen             | Two slides on GitHub vs. local copy (both independent; issues, PRs and CI exist only on GitHub). `git clone`, `git log`, issue.          |
| 25–40   | 2 · Branch & Commit    | `main`, branch and commit explained. `git switch -c`, edit `team.js`, `git add`, `git commit`, **no push**. Branch not on GitHub.        |
| 40–50   | 3 · Push & PR          | What a PR is; PR title = changelog entry. `git push -u`, "Compare & pull request"; participants check title and body first.              |
| 50–65   | 4 · Checks             | What CI checks. Demo `demo/rote-ci` if nobody's CI is red. Answer and resolve comments (Copilot, if enabled).                            |
| 65–75   | 5 · Review             | Request the reviewer named in the issue, read the other PR, optionally `git fetch` + `git switch`; approve in the browser.               |
| 75–90   | 6 · Merge & Deployment | Merge one after the other. Neighbouring entries conflict; if none do, demo `demo/konflikt-a`/`-b`. Watch the Pages site, `git pull`.     |
| 90–105  | 7 · Release            | Read the release PR together, approve (not the trainer), merge, check the version in the footer of the Pages site. Rollback = revert PR. |
| 105–115 | Wrap-up                | What would you take into your own project? Point to the bonus issues.                                                                    |

### Bonus issues

For fast finishers during stages 5–6, or as practice after the workshop. Same
flow, but with logic in `lib.js` and a test.

| Issue            | Touches                                     | Collides with                                                                |
| ---------------- | ------------------------------------------- | ---------------------------------------------------------------------------- |
| 11 Suchfeld      | `lib.js`, `app.js` `render()`, `index.html` | 15 (both change the `visible` line in `render()`)                            |
| 12 Zufall        | `lib.js`, `app.js`, `style.css`             | –                                                                            |
| 13 Zähler        | `lib.js`, `app.js` `render()`, `index.html` | lightly with 11/15                                                           |
| 14 Dark Mode     | `style.css` only                            | –                                                                            |
| 15 Sortierung    | `lib.js`, `app.js` `render()`, `index.html` | 11                                                                           |
| 16 Motto-Prüfung | `lib.js`, tests, maybe `team.js`            | can turn CI red for everyone's entries: a real "behaviour change" discussion |

## Fallbacks

- **AI review does not show up.** Copilot skips drafts; check the PR's
  reviewers. Carry on; the human review is what the ruleset requires.
- **Merge blocked by unresolved threads.** Intended: answer and resolve the
  AI comments. If time runs out, an admin can switch off
  `required_review_thread_resolution` in the ruleset.
- **The page does not update.** Check the `pages` run in the Actions tab;
  GitHub Pages needs a minute after it.
- **Release PR has no checks.** release-please opens it with the built-in
  `GITHUB_TOKEN`, which does not start other workflows. Close and reopen the
  PR, or push an empty commit to its branch.
- **Someone has no write access.** They accept the invitation at
  <https://github.com/MeKo-Christian/workshop-teamwand/invitations>.

## Dry-run checklist

- [ ] A PR with the title `Update team.js` fails `test-pr-title`.
- [ ] The PR from `demo/rote-ci` fails `test`.
- [ ] An unsorted entry in `team.js` fails `test` with a readable message.
- [ ] Copilot comments once, in German.
- [ ] Merging without an approval is blocked; the author cannot approve.
- [ ] After a merge, the change is on <https://meko-christian.github.io/workshop-teamwand/>.
- [ ] The release-please PR exists and lists the merged PR titles.
- [ ] After merging it, the Pages site shows the new version in the footer.
- [ ] `scripts/reset-playground.sh` closes the leftovers and its PR restores the baseline.

## After the workshop

```sh
scripts/reset-playground.sh   # closes PRs and issues, opens the reset PR
```

Approve and merge the reset PR (it is a `chore:`, so it does not trigger a
release on its own). For the next run, call `setup-playground.sh` again with
the new participant list.

## Slides

`slides/` holds the deck and the handout as Typst sources with their PDFs. The
PDFs are committed. The sources need [Typst](https://typst.app) and
[just](https://just.systems), and the font Proxima Nova, which is commercial
and therefore not in this repository: put the font files into
`slides/fonts/` (see the README there), `just` points Typst at it.

```sh
just slides          # rebuild deck and handout
just slides-watch    # rebuild the deck on every change
just present         # present in pdfpc; extra arguments go to pdfpc
```

`just present` shows the committed PDF, so run `just slides` first after
editing the sources.

Rebuild and commit the PDFs together with every change to the sources. `workshop/` is trainer material: entry PRs of participants never touch it.

## Changing the playground

This repository is the baseline. Change it through a normal PR. The
`workshop-baseline` tag marks the clean state that `scripts/reset-playground.sh`
restores; move it only when the baseline itself changes (for example a new
feature in the app that every run should start with), after a reset, so no
participant entries end up in it:

```sh
git tag -f workshop-baseline <merge-sha> && git push -f origin workshop-baseline
```

`workshop/` and the `justfile` are not part of that restore: the reset script
keeps them as they are on `main`.

To serve the page locally instead of opening it from `file://`, run `just dev`
(needs [just](https://just.systems) and Python), then open
<http://localhost:8000>.
