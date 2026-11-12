#!/usr/bin/env bash
# Creates and prepares the workshop playground repository. Safe to re-run:
# existing repo content, labels, ruleset and issues are left alone.
#
#   scripts/setup-playground.sh participants.txt [--repo OWNER/NAME] [--team TEAM_SLUG]
#
# participants.txt: one GitHub login per line, `#` starts a comment. The order
# sets the review ring: everyone reviews the next person in the list.
set -euo pipefail

here=$(cd "$(dirname "$0")/.." && pwd)
root=$(git -C "$here" rev-parse --show-toplevel)
repo=MeKo-Christian/workshop-teamwand
team=""
participants_file=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) repo=$2; shift 2 ;;
    --team) team=$2; shift 2 ;;
    -h | --help) sed -n '2,9p' "$0"; exit 0 ;;
    *) participants_file=$1; shift ;;
  esac
done

[[ -n "$participants_file" && -f "$participants_file" ]] || {
  echo "usage: $0 participants.txt [--repo OWNER/NAME] [--team TEAM_SLUG]" >&2
  exit 1
}
mapfile -t participants < <(sed -e 's/#.*//' -e 's/[[:space:]]//g' "$participants_file" | grep -v '^$')
[[ ${#participants[@]} -ge 2 ]] || { echo "need at least two participants for the review ring" >&2; exit 1; }
owner=${repo%%/*}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

echo "==> repository $repo"
if ! gh repo view "$repo" >/dev/null 2>&1; then
  gh repo create "$repo" --private --description "Playground for the MeKo Git & GitHub workshop"
fi

if [[ -z "$(gh api "repos/$repo/commits?per_page=1" --jq '.[0].sha' 2>/dev/null || true)" ]]; then
  echo "==> pushing the baseline"
  # The baseline is this checkout as committed (no .git, no node_modules).
  mkdir "$work/baseline"
  git -C "$root" archive HEAD | tar -x -C "$work/baseline"
  git -C "$work/baseline" init -q -b main
  git -C "$work/baseline" add -A
  git -C "$work/baseline" commit -q -m "chore: initial playground"
  git -C "$work/baseline" tag workshop-baseline
  git -C "$work/baseline" remote add origin "https://github.com/$repo.git"
  git -C "$work/baseline" push -q origin main workshop-baseline
  # The first release marks the baseline, so release-please starts counting here.
  gh release create 0.1.0 -R "$repo" --target main --title "0.1.0" --notes "Workshop baseline"
fi

echo "==> repository settings (squash only, PR title as commit title)"
gh api -X PATCH "repos/$repo" --silent \
  -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
  -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY \
  -F delete_branch_on_merge=true -F allow_update_branch=true \
  -F has_issues=true -F has_wiki=false -F has_projects=false

echo "==> labels"
gh label create eintrag -R "$repo" --color 7ab929 --description "Workshop: your own entry on the wall" --force
gh label create bonus -R "$repo" --color 1d76db --description "Workshop: optional feature for fast finishers" --force
gh label create feature -R "$repo" --color a2eeef --description "New feature" --force
gh label create demo -R "$repo" --color d4c5f9 --description "Workshop: trainer demo, not for review" --force

echo "==> ruleset on main"
# Create the ruleset, or update it in place when a previous run already made it,
# so rules added to this script (e.g. Copilot review) also reach existing repos.
ruleset_id=$(gh api "repos/$repo/rulesets" --jq '.[] | select(.name == "main") | .id')
if [[ -n "$ruleset_id" ]]; then
  ruleset_method=PUT
  ruleset_url="repos/$repo/rulesets/$ruleset_id"
else
  ruleset_method=POST
  ruleset_url="repos/$repo/rulesets"
fi
gh api -X "$ruleset_method" "$ruleset_url" --silent --input - <<'JSON'
{
"name": "main",
"target": "branch",
"enforcement": "active",
"conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
"rules": [
  { "type": "deletion" },
  { "type": "non_fast_forward" },
  {
    "type": "pull_request",
    "parameters": {
      "required_approving_review_count": 1,
      "dismiss_stale_reviews_on_push": false,
      "require_code_owner_review": false,
      "require_last_push_approval": false,
      "required_review_thread_resolution": true,
      "allowed_merge_methods": ["squash"]
    }
  },
  {
    "type": "copilot_code_review",
    "parameters": { "review_on_push": false, "review_draft_pull_requests": false }
  },
  {
    "type": "required_status_checks",
    "parameters": {
      "strict_required_status_checks_policy": false,
      "required_status_checks": [{ "context": "test" }, { "context": "test-pr-title" }]
    }
  }
]
}
JSON

echo "==> access"
if [[ -n "$team" ]]; then
  gh api -X PUT "orgs/$owner/teams/$team/repos/$repo" --silent -f permission=push
fi
for login in "${participants[@]}"; do
  gh api -X PUT "repos/$repo/collaborators/$login" --silent -f permission=push
done

echo "==> issues"
# Only open issues count: reset-playground.sh closes the previous run's issues,
# and the next run needs them again.
existing=$(gh issue list -R "$repo" --state open --limit 500 --json title --jq '.[].title')

# create_issue FILE [LOGIN REVIEWER]: frontmatter `title:` and `labels:`, body below.
create_issue() {
  local file=$1 login=${2:-} reviewer=${3:-} title labels body
  title=$(sed -n 's/^title: *"\(.*\)"$/\1/p' "$file")
  labels=$(sed -n 's/^labels: *\[\(.*\)\]$/\1/p' "$file" | tr -d ' ')
  body=$(awk 'f>=2 {print} /^---$/ {f++}' "$file")
  title=${title//\{\{login\}\}/$login}
  body=${body//\{\{login\}\}/$login}
  body=${body//\{\{reviewer\}\}/$reviewer}
  if grep -qxF "$title" <<<"$existing"; then
    echo "   exists: $title"
    return
  fi
  local args=(-R "$repo" --title "$title" --body "$body" --label "$labels")
  [[ -n "$login" ]] && args+=(--assignee "$login")
  gh issue create "${args[@]}"
}

count=${#participants[@]}
for i in "${!participants[@]}"; do
  create_issue "$here/issues/01-hallo-wand.md" "${participants[$i]}" "${participants[$(((i + 1) % count))]}"
done
for file in "$here"/issues/1[0-9]-*.md; do
  create_issue "$file"
done

echo "==> demo branches for the trainer"
git clone -q "https://github.com/$repo.git" "$work/demo"
cd "$work/demo"
if ! git ls-remote --exit-code --heads origin demo/konflikt-a >/dev/null; then
  for pair in "a:demo-ada:Ada Lovelace:🧮:Erst denken, dann rechnen." "b:demo-alan:Alan Turing:🤖:Kann eine Maschine reviewen?"; do
    IFS=: read -r suffix login name emoji motto <<<"$pair"
    git switch -q -c "demo/konflikt-$suffix" workshop-baseline
    # Both demo logins sort before every real one, so both branches insert at
    # the same line: merging the second one conflicts. `[ ]` keeps this line
    # from reading as a keep-sorted directive to treefmt.
    sed -i "s|  // keep-sorted[ ]start|&\n  { login: \"$login\", name: \"$name\", emoji: \"$emoji\", motto: \"$motto\" },|" team.js
    git commit -q -am "feat: add $login to the team wall"
    git push -q origin "demo/konflikt-$suffix"
  done
  git switch -q -c demo/rote-ci workshop-baseline
  # `var` and an unused variable: ESLint turns the PR red.
  sed -i 's|  function render() {|  var greeting = "Hallo Teamwand";\n\n&|' app.js
  git commit -q -am "feat: greet the team"
  git push -q origin demo/rote-ci
fi

echo "==> draft pull requests for the demo branches"
# Drafts on purpose: CI runs, the AI reviewers skip drafts. "Ready for review"
# during the demo starts the reviewers live.
# demo_pr BRANCH TITLE BODY: skipped when the branch already has an open PR.
demo_pr() {
  if [[ -n "$(gh pr list -R "$repo" --head "$1" --state open --json number --jq '.[].number')" ]]; then
    echo "   exists: $1"
    return
  fi
  gh pr create -R "$repo" --draft --base main --head "$1" --title "$2" --label demo \
    --body "$3 Trainer-Demo: nicht reviewen."
}
demo_pr demo/rote-ci "feat: greet the team" \
  "Etappe 4 (Checks): \`var\` und eine unbenutzte Variable in \`app.js\`, ESLint macht die CI rot."
demo_pr demo/konflikt-a "feat: add demo-ada to the team wall" \
  "Etappe 6 (Merge-Konflikt), Teil A: fügt an derselben Zeile von \`team.js\` ein wie \`demo/konflikt-b\`."
demo_pr demo/konflikt-b "feat: add demo-alan to the team wall" \
  "Etappe 6 (Merge-Konflikt), Teil B: nach dem Merge von A den Konflikt lösen, beide Einträge behalten."

echo
echo "Done: https://github.com/$repo"
echo "Review ring:"
for i in "${!participants[@]}"; do
  echo "   @${participants[$i]} -> reviewed by @${participants[$(((i + 1) % count))]}"
done
