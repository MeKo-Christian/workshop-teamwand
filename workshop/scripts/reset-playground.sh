#!/usr/bin/env bash
# Brings the playground back to the baseline after a workshop run. Nothing is
# force-pushed: the reset goes through a normal pull request, which still
# needs an approval. Files that release-please owns, the workshop/ folder and the
# justfile keep their current state, so versions keep counting up across runs.
#
#   scripts/reset-playground.sh [--repo OWNER/NAME]
#
# Afterwards, re-run setup-playground.sh with the next participant list.
set -euo pipefail

repo=MeKo-Christian/workshop-teamwand
[[ "${1:-}" == --repo ]] && repo=$2

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

echo "==> closing open workshop pull requests and issues"
gh pr list -R "$repo" --state open --json number,headRefName \
  --jq '.[] | select(.headRefName | startswith("release-please--") | not) | .number' |
  while read -r number; do
    gh pr close "$number" -R "$repo" --delete-branch --comment "Workshop beendet – danke fürs Mitmachen!"
  done
for label in eintrag bonus; do
  gh issue list -R "$repo" --state open --label "$label" --json number --jq '.[].number' |
    while read -r number; do
      gh issue close "$number" -R "$repo" --reason "not planned"
    done
done
for branch in demo/konflikt-a demo/konflikt-b demo/rote-ci; do
  gh api -X DELETE "repos/$repo/git/refs/heads/$branch" --silent 2>/dev/null || true
done

echo "==> reset pull request"
git clone -q "https://github.com/$repo.git" "$work/repo"
cd "$work/repo"
branch="chore/reset-workshop-$(date +%F)"
git switch -q -c "$branch"
git rm -rq .
git checkout workshop-baseline -- .
# workshop/ and the justfile are trainer tooling that was added after the
# baseline tag: keep them.
for owned in version.js version.txt CHANGELOG.md .release-please-manifest.json workshop justfile; do
  git checkout origin/main -- "$owned" 2>/dev/null || true
done
if git diff --cached --quiet; then
  echo "main already matches the baseline"
  exit 0
fi
git commit -q -m "chore: reset workshop playground"
git push -q origin "$branch"
gh pr create -R "$repo" --head "$branch" --title "chore: reset workshop playground" \
  --body "Setzt die Teamwand auf den Stand von \`workshop-baseline\` zurück (außer den Dateien von release-please, \`workshop/\` und dem \`justfile\`)."
