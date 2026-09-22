# Rulesets

GitHub rulesets are configured on the server, not in this repo. These files are
the source of truth for what they should say, so a change is reviewable in a PR
and recoverable if a ruleset is ever deleted by hand.

What they enforce:

- `develop.json`, `staging.json`, `production.json` — no direct push, no force
  push, no deletion. The only way in is a pull request whose `ci-ok` check
  passed. `bypass_actors` is empty, so this applies to the repo owner too.
- `version-tags.json` — nobody may move or delete a `v*` tag. Creating one is
  not blocked: on a personal repo GitHub refuses the GitHub Actions app as a
  bypass actor, so blocking creation would also block
  `.github/workflows/release-on-merge.yml`.

All four are applied.

## Order

Apply them **after** the workflow changes are merged into `develop`, not before.
`ci-ok` only exists in the new `ci.yml`, so a PR opened from a branch that
predates it can never report that check and would be blocked forever.

1. `gh auth refresh -h github.com -s workflow` — the current token has no
   `workflow` scope, so it cannot push anything under `.github/workflows/`.
2. Merge the CI/CD PR into `develop`.
3. Run `./apply.sh`.
4. Rebase any still-open PR onto `develop` so it picks up `ci-ok`.

Apply them (needs a token with `repo` scope):

```bash
./apply.sh
```

`apply.sh` creates a ruleset that does not exist yet and updates one that does,
matching on the `name` field.
