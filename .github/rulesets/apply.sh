#!/usr/bin/env bash
# Push the ruleset definitions in this directory to GitHub. Creates what is
# missing, updates what is already there, matched on the ruleset name.
set -euo pipefail

repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner)"
here="$(cd "$(dirname "$0")" && pwd)"

existing="$(gh api "/repos/$repo/rulesets" --jq '.[] | [.name, (.id|tostring)] | @tsv')"

for file in "$here"/*.json; do
  name="$(jq -r .name "$file")"
  id="$(printf '%s\n' "$existing" | awk -F'\t' -v n="$name" '$1 == n {print $2}')"
  if [ -n "$id" ]; then
    echo "updating '$name' ($id)"
    gh api --silent -X PUT "/repos/$repo/rulesets/$id" --input "$file"
  else
    echo "creating '$name'"
    gh api --silent -X POST "/repos/$repo/rulesets" --input "$file"
  fi
done

echo
gh api "/repos/$repo/rulesets" --jq '.[] | "\(.name)\t\(.target)\t\(.enforcement)"'
