# Day-to-day — the simple version


day-to-day: [Runbook](https://claude.ai/code/artifact/3c3f1fce-3b74-4ea0-ade0-28de48ce424e?via=auto_preview)


Read this when you forget how any of it works. Everything here is "what do I
actually type." The deep technical versions live in [CICD.md](CICD.md) (the
pipeline) and [README.md](README.md) (flavors).

- [The 30-second picture](#the-30-second-picture)
- [Rule #1 — merges don't ship, tags ship](#rule-1--merges-dont-ship-tags-ship)
- [Running the app on your machine](#running-the-app-on-your-machine)
- [Which branch can merge into which](#which-branch-can-merge-into-which)
- [The four things you actually do](#the-four-things-you-actually-do)
- [Emergency — hotfix](#emergency--hotfix)
- [Monitoring — where to look when something breaks](#monitoring--where-to-look-when-something-breaks)
- [Where the builds land](#where-the-builds-land)
- [When CI goes red](#when-ci-goes-red)

---

## The 30-second picture

Everything comes in **threes**. One row = one whole environment.

| Branch | Flavor | App on your phone | Firebase project | Package name |
| --- | --- | --- | --- | --- |
| `develop` | `dev` | AlgoDive Dev | `algodive-dev` | `com.elhawary.algodive.dev` |
| `staging` | `staging` | AlgoDive Stag | `algodive-staging` | `com.elhawary.algodive.staging` |
| `production` | `production` | AlgoDive | `algodive-prod` | `com.elhawary.algodive` |

Because the package names differ, **all three can sit on one phone at once**.
That's the whole point of flavors.

---

## Rule #1 — merges don't ship, tags ship

**A merge never sends anything to testers. Only a pushed tag does.**

You can merge into `develop` all day. Nothing reaches anyone until you push a
tag. This is deliberate — it means merging is cheap and safe.

Tags look like this. One version line, the stage is a suffix:

```
v1.3.0-dev.1  →  v1.3.0-dev.2  →  v1.3.0-stag.1  →  v1.3.0
   develop           develop          staging      production
```

| Stage | Tag shape | Who approves | Changelog? |
| --- | --- | --- | --- |
| dev | `v1.3.0-dev.N` | nobody — automatic | no |
| staging | `v1.3.0-stag.N` | nobody — automatic | no |
| production | `v1.3.0` | **you**, a manual click | **yes**, and you approve the text |

---

## Running the app on your machine

Pick a flavor. You always need all three flags together.

```bash
# dev
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_define/dev.json

# staging
flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=dart_define/staging.json

# production
flutter run --flavor production -t lib/main_prod.dart --dart-define-from-file=dart_define/prod.json
```

**What each flag does:**

| Flag | Job |
| --- | --- |
| `--flavor dev` | picks the Gradle product flavor → package name, app name, icon |
| `-t lib/main_dev.dart` | picks the entry point (which `main()` runs) |
| `--dart-define-from-file=…` | injects config values (API URL, app name) |

Tests don't care which one you pass:

```bash
flutter test --dart-define-from-file=dart_define/dev.json
```

---

## Which branch can merge into which

| Into | Allowed from |
| --- | --- |
| `develop` | anything |
| `staging` | `develop`, `production` (back-merge), `hotfix/*` |
| `production` | `staging`, `hotfix/*` — **never `develop` directly** |

CI's `merge-guard` job blocks anything outside this table before it can merge.

**Also:** never commit directly on `develop`, `staging`, or `production`. They
only ever *receive* merges. `/atomic-commits` refuses to run if you're standing
on one.

---

## The four things you actually do

### A. Normal feature work

```bash
git checkout develop
git pull
git checkout -b feature/my-thing
# ... write code ...
```

Then run **`/atomic-commits`** — it makes one commit per changed file.

Push, open a PR into `develop`, merge it.

- CI runs analyze + test + a **dev**-flavor build (it builds whatever flavor the
  target branch ships).
- **Nothing ships.** That's correct and normal.

---

### B. "Let testers see this" → a dev build

While still on your feature branch, run **`/atomic-commits`** and answer
**yes** to the tag question.

It works out the next tag (e.g. `v1.0.1-dev.2`) and **prints** the commands —
it does not run them. Why: the tag must sit on a commit that's already on
`develop`, so it has to wait for your merge.

**After your PR merges into `develop`, run what it printed:**

```bash
git checkout develop
git pull
git tag v1.0.1-dev.2
git push origin v1.0.1-dev.2      # ← this is what ships
git checkout -                     # don't stay on develop
```

The tag push triggers `deploy.yml` → builds the dev flavor → uploads to
`algodive-dev` Firebase App Distribution → testers get it. No approval needed.

Release notes are generated automatically from the commits since the last dev
tag. You write nothing.

---

### C. "Ready for QA" → staging

Stand on `develop`, run **`/promote`**.

- It asks one thing: **tag `-stag.N` and promote, or cancel?**
- On yes: merges `develop → staging`, pushes the tag → staging build ships
  automatically to `algodive-staging`.
- No changelog. No `pubspec.yaml` bump. Those wait for production.

---

### D. "This is a real release" → production

Stand on `staging`, run **`/promote`**.

1. It asks: **MAJOR, MINOR, or PATCH?**
2. It **drafts a CHANGELOG entry for you** from the real commits.
3. It **shows you the draft and waits.** You can approve, ask for edits, or
   cancel.
4. Only after you approve: bumps `pubspec.yaml`, writes `CHANGELOG.md`, merges
   into `production`, tags `vX.Y.Z`, pushes.
5. GitHub Actions **pauses** on *"Waiting for review."*
   → **Actions** tab → the run → **Review deployments** → **Approve**.
6. It builds, ships to production testers, and creates a GitHub Release with
   your changelog text and the APK attached.

---

## Emergency — hotfix

Run **`/hotfix`** — it decides which of the two paths below applies by
looking at the diff, and drives whichever one fits. The manual steps are
here for reference.

```bash
git checkout production        # or staging, whichever is broken
git pull
git checkout -b hotfix/the-bug
# ... fix ...
```

**Then pick one:**

| Which branch is broken | The fix is | Path |
| --- | --- | --- |
| `production` | **Dart-only** (`lib/**`, assets, dart-defines) | Merge back into `production`, then run the **Patch (hotfix)** workflow (Actions → `Patch (hotfix)` → Run workflow → **from branch `production`**). Ships in minutes, **no reinstall** — users just close and reopen the app twice. Needs your approval, same as a release. |
| `production` | Touches native code (`android/`, `ios/`), adds a plugin with native code, or bumps Flutter | No patch possible. Merge back into `production` and cut a normal `vX.Y.Z` release, just urgently. |
| `develop` or `staging` | anything | **No patching.** Merge back and push a new `-dev.N` / `-stag.N` tag — it ships in minutes with no approval, which is already as fast as a patch. |

**Why only production can be patched:** dev and staging are built with plain
`flutter build` and are not patchable on purpose. They already ship in
minutes, so code push solves a problem they don't have. Only production —
where a full release is slow — gets the Shorebird path.

⚠️ **Either way, back-merge downward** so the fix isn't lost:

```
production  →  staging  →  develop
```

If you skip this, your next promote will silently undo the fix.

A patch is a shortcut for *speed*, never for the merge/back-merge discipline
above — it changes nothing about which branches need the fix.

---

## Monitoring — where to look when something breaks

Two browser tabs, one job each:

| Tool | What it's for | Look here for |
| --- | --- | --- |
| **Sentry** | crashes + errors + performance | "what broke", "for how many users", "is a screen slow" |
| **Firebase console → Analytics** | usage | "what are people actually doing", "which screens get opened" |

Each has **three projects**, one per flavor — same split as Firebase App
Distribution above. A dev crash never shows up mixed in with production
numbers.

⚠️ **Both are release-builds-only.** Running the app with `flutter run`
sends nothing — you already have the error in your console, and every event
sent would spend free quota. A *tester's* build reports normally, including
the dev flavor. The rule is "is this a real build on someone else's phone",
not "which flavor is it".

**Reading a crash in Sentry:** one card per distinct bug (not per
occurrence), showing how many times it happened and how many different
people hit it, plus the last things that user did before it broke.

**A patch doesn't erase old crash reports.** If a patch fixes a crash, the
old occurrences still show in Sentry's history — that's expected, it's a
record of what happened, not a live health bar.

---

## Where the builds land

All three go to **Firebase App Distribution**, each in its own project:

| Tag you push | Lands in | Testers get it |
| --- | --- | --- |
| `v1.3.0-dev.N` | `algodive-dev` | immediately |
| `v1.3.0-stag.N` | `algodive-staging` | immediately |
| `v1.3.0` | `algodive-prod` | after you click Approve |

Testers are reached through a Firebase **tester group** with the alias
`testers`. That group must exist in **each** of the three projects — it's
per-project, not shared.

App stores (Play / TestFlight) and iOS distribution are a **later phase**.

---

## When CI goes red

| Message | What it means | Fix |
| --- | --- | --- |
| `No matching client found for package name …` | that environment's `ANDROID_GOOGLE_SERVICES_JSON` is from the wrong Firebase project | replace it with the `google-services.json` whose package matches |
| `The APK package name '…' does not match your Firebase app's` | `FIREBASE_ANDROID_APP_ID` points at the wrong app | copy the App ID of the app with the *matching* package name |
| `failed to distribute to testers/groups: 404` | no tester group with alias `testers` in that project | create it: App Distribution → Testers & Groups → Add group |
| `… is empty for environment '…'` | secret set repo-wide but not on that Environment | add it under Settings → Environments |
| `'X' -> 'Y' is not allowed` | merge direction breaks the table above | retarget the PR |
| Deploy stuck on *"Waiting for review"* | expected on a production tag | Actions → run → Review deployments → Approve |
| `tag 'vX' is not on branch 'develop'` | you tagged a commit that isn't merged yet | merge first, then tag on `develop` |

More detail: [CICD.md#troubleshooting](CICD.md#troubleshooting) and
[PLAYBOOK.md](PLAYBOOK.md).

---

## One-time setup (already done — for reference)

- Three Firebase projects, each with an Android app whose package name matches
  its flavor exactly → [FIREBASE_CHECKLIST.md](FIREBASE_CHECKLIST.md)
- Three GitHub Environments (`development`, `staging`, `production`), each
  holding its own secrets under the same names → [CICD.md](CICD.md#one-time-setup)
- `production` Environment has **Required reviewers** on — that's what creates
  the manual approval gate.
