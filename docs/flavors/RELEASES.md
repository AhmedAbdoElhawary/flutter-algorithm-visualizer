# Releases — the simple version

Read this when you forget how shipping works. Full technical details live in
[CICD.md](CICD.md); this page is just "what do I actually do."

## The one rule

**A merge never ships anything. Only a tag ships.**

You can merge into `develop` all day — nothing reaches testers until you push
a tag.

## The three tags

```
v1.3.0-dev.1   →   v1.3.0-dev.2   →   v1.3.0-stag.1   →   v1.3.0
   develop            develop           staging       production
```

| Stage | Tag looks like | Who approves | Changelog? |
| --- | --- | --- | --- |
| dev | `v1.3.0-dev.N` | nobody, automatic | no |
| staging | `v1.3.0-stag.N` | nobody, automatic | no |
| production | `v1.3.0` | **you**, manual click | **yes, and you approve the text** |

## Day 1 — normal work

```
feature/x  →  PR  →  develop
```

- CI runs tests, you merge.
- **Nothing ships.** That's normal.

## Day 2 — "let testers see this"

Run `/atomic-commits` while on `develop`, say **yes** to the tag question.

- It figures out the next `-dev.N` tag and pushes it.
- CI builds the dev flavor and sends it to Firebase automatically.
- Release notes = auto list of commits since the last dev tag.
- **You answer nothing else.** No version, no changelog.

## Day 3 — "ready for QA"

Run `/promote` while on `develop`.

- Two choices only: **tag it (`-stag.N`) and promote**, or **cancel**.
- Merges into `staging`, pushes the tag → staging build ships automatically.
- Still no changelog, still no pubspec bump.

## Day 4 — "this is a real release"

Run `/promote` while on `staging`.

1. It asks: **MAJOR, MINOR, or PATCH?** (or cancel)
2. It **writes a CHANGELOG draft for you**, based on the real commits.
3. It **shows you the draft and waits.** You can:
   - **Approve** → it proceeds
   - **Ask for edits** → it redrafts, shows you again
   - **Cancel** → nothing happens
4. Only after your approval: `pubspec.yaml` bumps, `CHANGELOG.md` is written,
   it merges into `production`, tags `vX.Y.Z`, pushes.
5. GitHub Actions pauses on **"Waiting for review."** Go to
   **Actions → the run → Review deployments → Approve**.
6. It builds, ships to production testers, and creates a GitHub Release with
   your changelog text and the APK attached.

## Emergencies — hotfix

Branch `hotfix/x` off whichever branch is broken (`staging` or `production`),
fix it, merge straight back into that same branch — skips the normal ladder.
**Then remember to back-merge the fix down** (production → staging → develop)
so it isn't lost next time you promote.

## Who can merge into what

| Into | Allowed from |
| --- | --- |
| `develop` | anything |
| `staging` | `develop`, `production` (back-merge), `hotfix/*` |
| `production` | `staging`, `hotfix/*` — **never `develop` directly** |

CI blocks anything outside this table before it can be merged.
