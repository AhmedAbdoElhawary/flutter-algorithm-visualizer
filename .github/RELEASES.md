# Releases

Everything AlgoDive ships comes from a tag, and every tag is made by CI after a
pull request merges. Nothing here is a convention you are trusted to follow —
rulesets refuse the shortcuts outright.

Publishing to the store for the **first** time is a separate, one-time list:
see `PLAY_LAUNCH.md`.

## The two locks

| What | Enforced by |
| --- | --- |
| No direct push to `develop`, `staging` or `production` | one branch ruleset per branch, `bypass_actors` empty |
| No moving or deleting a `v*` tag | the `version-tags` ruleset, `bypass_actors` empty |

The definitions live in `.github/rulesets/`; `.github/rulesets/apply.sh` pushes
them to GitHub.

So don't do this. GitHub cannot block it on a personal repo, but it skips the
PR and `ci-ok`, and a dev or staging tag ships to testers with no review:

```bash
git checkout develop
git tag -a v1.0.1-dev.16 -m "..."
git push origin v1.0.1-dev.16   # not blocked, but never do it
```

## The ladder

```
feature/x ──PR──► develop ──PR──► staging ──PR──► production
             │              │               │
          ci.yml         ci.yml          ci.yml
             │              │               │
        release: tag?   always tag      always tag
        → v1.0.1-dev.16 → v1.0.1-stag.1 → v1.0.1 + GitHub Release
             └──────────────┴───────────────┴──► deploy.yml
```

One version line runs through all three stages; the stage is a suffix:

| Tag | Environment | Flavor | Firebase project |
| --- | --- | --- | --- |
| `v1.3.0-dev.2` | development | dev | algodive-dev |
| `v1.3.0-stag.1` | staging | staging | algodive-staging |
| `v1.3.0` | production | production | algodive-prod |

## PR into `develop`

`ci.yml` runs `merge-guard`, `release-commit-guard`, `quality`, `build-android`,
`build-ios`, and rolls them up into **`ci-ok`** — the one required status check.
Red `ci-ok`, no merge button.

A merge into `develop` ships **nothing** unless the PR carries a release marker:
one commit whose *subject* is the tag and whose *body* is the tag message.

```bash
git commit --allow-empty -F - <<'EOF'
release: v1.0.1-dev.16

- fixed the path-finding grid painter
- dropped the unused Sentry crash reporter
EOF
```

`release-commit-guard` checks it **before** the merge: right shape, non-empty
body, at most one per PR, not a tag that already exists. A typo fails the PR
rather than failing after it has landed.

After the merge, `release-on-merge.yml` reads the PR's commits through the API
(so a squash merge cannot lose the marker), creates the annotated tag on the
merge commit, and calls `deploy.yml`.

## PR into `staging`

No marker commit — one is an error here. Every merge ships.

The version line comes from the newest `v*-dev.*` tag reachable from the merge
commit, and the `-stag.N` counter is bumped from the highest existing one. The
tag message is the PR title plus the commits since the previous staging tag, so
give the promotion PR a real title.

## PR into `production`

No marker commit either. The version comes from the **top `CHANGELOG.md`
entry** (`tool/changelog_release_notes.py --field version`), and that entry's
body becomes the tag message, the GitHub Release body and the Play notes.

This means a production PR must bump `CHANGELOG.md` first. If it doesn't,
`release-on-merge.yml` stops with *tag already exists* — which is the intended
outcome, not a bug.

`deploy.yml` then pauses at the `production` environment's **Required
reviewers** prompt. Approve it under the run's "Review deployments" and it
builds through Shorebird, uploads symbols to Sentry, and creates the GitHub
Release with the `.aab` attached.

It stops there. Nothing uploads to Google Play — you download that `.aab` and
upload it yourself. `PLAY_LAUNCH.md` covers the first one.

## Why deploy is *called*, not triggered

A tag pushed with `GITHUB_TOKEN` deliberately does not fire another workflow's
`on: push`. So `deploy.yml` is a reusable workflow (`on: workflow_call`) and
`release-on-merge.yml` calls it with the tag it just created. Its `on: push:
tags` trigger is kept as break-glass only.

## Hotfixes

`hotfix/*` may PR straight into `staging` or `production` — see `merge-guard`
in `ci.yml` for the full merge table. A hotfix merge into `production` creates
no tag, because it does not bump the CHANGELOG; the Shorebird code-push patch
in `.github/workflows/patch.yml` is what actually ships it. Details in the
`hotfix` skill.

Back-merge afterwards (`production → staging → develop`), by PR, or the next
release reintroduces the bug.

## Doing it by hand

Don't. Use the `promote` and `hotfix` skills — they drive exactly this flow.
