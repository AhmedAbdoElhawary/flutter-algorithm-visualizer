# CI/CD — how releases actually happen

Plain-language guide to the automated pipeline. **A merge never ships
anything — only a pushed tag does.** For the day-to-day flow in the simplest
form, see [RELEASES.md](RELEASES.md) — this file is the technical reference
underneath it.

- [The mental model](#the-mental-model)
- [The tag scheme](#the-tag-scheme)
- [The everyday flow](#the-everyday-flow)
- [Promote a build](#promote-a-build)
- [What the pipeline does, step by step](#what-the-pipeline-does-step-by-step)
- [Merge-direction rules](#merge-direction-rules)
- [One-time setup](#one-time-setup)
- [Common tasks](#common-tasks)
- [Troubleshooting](#troubleshooting)
- [Not covered yet](#not-covered-yet)

---

## The mental model

Everything lines up in threes. A branch maps to a flavor, a flavor maps to its
own Firebase project, and each gets its own locked box of secrets in GitHub.
But **the branch alone ships nothing** — a build ships only when a matching
tag is pushed.

| Branch | Tag shape | GitHub Environment | Flavor | Firebase project | Package name | Who approves |
| --- | --- | --- | --- | --- | --- | --- |
| `develop` | `v<x.y.z>-dev.<n>` | `development` | dev | `algo-dive-dev` | `com.elhawary.algodive.dev` | nobody — automatic |
| `staging` | `v<x.y.z>-stag.<n>` | `staging` | staging | `algo-dive-staging` | `com.elhawary.algodive.staging` | nobody — automatic |
| `production` | `v<x.y.z>` | `production` | production | `algo-dive-prod` | `com.elhawary.algodive` | **you** (required reviewer) |

Two GitHub Actions workflows:

- **`.github/workflows/ci.yml`** — runs on **pull requests** into `develop` /
  `staging` / `production`. Analyze, test, a debug build, and a
  [merge-direction check](#merge-direction-rules). No secrets, no upload. This
  is the gate before a merge.
- **`.github/workflows/deploy.yml`** — runs on **push of a `v*` tag**.
  Analyze + test again, then build the release APK for the flavor that tag
  belongs to and upload it to that flavor's Firebase project. This is the
  thing that ships. It always builds the exact commit the tag points at —
  never "whatever is newest on the branch."

The isolation is real: a `deploy.yml` run for a `-dev.` tag only ever sees the
`development` environment's secrets. It cannot read the staging or production
keystore, Firebase token, or Firebase config even if someone edited the
workflow to try.

---

## The tag scheme

One version number runs through all three stages; the stage is a suffix:

```
v1.3.0-dev.1  →  v1.3.0-dev.2  →  v1.3.0-stag.1  →  v1.3.0
   develop           develop          staging      production
```

- **`-dev.N`** and **`-stag.N`** tags: the counter bumps automatically, no
  question asked — *unless* it's the first dev tag after a production
  release, which asks once for MAJOR/MINOR/PATCH to set the new base number.
- **Plain `vX.Y.Z`** (no suffix): only created at a production promotion.
  This is the only tag that bumps `pubspec.yaml` and writes a `CHANGELOG.md`
  entry — and that entry needs your explicit approval before it's written.

The `.claude/skills/atomic-commits` and `.claude/skills/promote` skills create
these tags for you — see [RELEASES.md](RELEASES.md).

---

## The everyday flow

1. Branch off `develop` as `feature/<something>`.
2. Open a PR into `develop`. `ci.yml` runs the merge-direction check, analyze,
   test, and a smoke build.
3. Merge. **Nothing ships yet** — a merge alone never triggers `deploy.yml`.
4. When you want testers to see it, run `/atomic-commits` (or ask to tag a dev
   build) on `develop`. It pushes the next `v<x.y.z>-dev.<n>` tag, which
   triggers `deploy.yml` to build the **dev** flavor and push it to
   `algo-dive-dev` → App Distribution automatically.

---

## Promote a build

Use the `/promote` skill (`.claude/skills/promote`). Full walkthrough in
[RELEASES.md](RELEASES.md); short version:

1. **`develop` → `staging`.** Computes the next `-stag.N` tag, asks *tag and
   promote, or cancel* — merges, tags, pushes. `deploy.yml` builds **staging**
   and ships to `algo-dive-staging` automatically.
2. **`staging` → `production`.** Asks MAJOR/MINOR/PATCH, drafts a
   `CHANGELOG.md` entry from the commits since the last release, **shows it
   to you and waits for approval** (edit or cancel are both fine), then on
   approval bumps `pubspec.yaml`, merges, tags `vX.Y.Z`, and pushes.
   `deploy.yml` starts, but the **Build & distribute (Android)** job stops on
   *"Waiting for review"*. Open the run in the **Actions** tab, click
   **Review deployments**, tick `production`, **Approve and deploy**. The job
   then builds, uploads to `algo-dive-prod`, and creates a GitHub Release with
   the changelog text and the APK attached. Reject it and nothing ships.

---

## What the pipeline does, step by step

`deploy.yml` has five jobs, triggered by a pushed `v*` tag:

1. **Resolve target** — parses the tag name (`-dev.`, `-stag.`, or plain) to
   decide the environment, flavor, entry point (`lib/main_<flavor>.dart`),
   dart-define file, and the base version (`--build-name`).
2. **Guard** — confirms the tagged commit is actually reachable from the
   branch that tag shape claims (a `-dev.` tag must be on `develop`, etc.).
   Fails the whole run if not — a mismatched tag/branch pair ships nothing.
3. **Analyze & test** — `flutter analyze` and
   `flutter test --dart-define-from-file=...`. No secrets. If this fails, nothing
   is built.
4. **Build & distribute (Android)** — runs *in* the resolved environment, so it
   has that environment's secrets (and, for production, waits for approval):
   - writes the environment's `ANDROID_GOOGLE_SERVICES_JSON` to
     `android/app/src/<flavor>/google-services.json`;
   - decodes `ANDROID_KEYSTORE_BASE64` to `android/app/release.jks` and writes
     `android/key.properties` from the four keystore secrets;
   - builds release notes: production reads the top block of `CHANGELOG.md`
     (`tool/changelog_release_notes.py`); dev/staging get an auto-generated
     list of commit subjects since the previous tag in that same stage
     (`tool/changelog_release_notes.py --auto-since-previous-tag <tag>`);
   - `flutter build apk --release --flavor <flavor> -t <target>
     --dart-define-from-file=<file> --build-name <x.y.z>
     --build-number <run number>`;
   - checks the APK is signed with the real key, not the debug key;
   - uploads the APK to Firebase App Distribution
     (`wzieba/Firebase-Distribution-Github-Action`) using
     `FIREBASE_ANDROID_APP_ID` + `FIREBASE_TOKEN`, to the tester groups in
     `FIREBASE_TESTER_GROUPS` (default `testers`), with the release notes;
   - deletes the keystore and `key.properties` from the runner.
5. **Release (production tags only)** — creates a GitHub Release named after
   the tag, body = the `CHANGELOG.md` entry, with the APK attached.

The Gradle side (`android/app/build.gradle.kts`): flavors no longer pin a
signing config, so any `--release` build is signed with `release` when
`key.properties` exists and falls back to `debug` when it doesn't. `flutter run`
is unaffected — it uses the debug build type.

---

## Merge-direction rules

Enforced by the `merge-guard` job in `ci.yml` on every pull request (and
double-checked by `/promote` before it merges anything):

| Into | Allowed from |
| --- | --- |
| `develop` | anything |
| `staging` | `develop`, `production` (back-merge), `hotfix/*` |
| `production` | `staging`, `hotfix/*` — **never `develop` directly** |

A `hotfix/*` branch taken from `staging` or `production` may merge straight
back into the branch it was cut from — skipping the normal ladder for
emergencies. Back-merge the fix downward afterward so it isn't lost on the
next promotion.

`merge-guard` must be marked a **required status check** on `staging` and
`production` in **Settings → Branches** for this to actually block a bad
merge in the GitHub UI — see [One-time setup](#one-time-setup).

---

## One-time setup

Do this once per environment. Nothing here is in the repo — it all lives in
GitHub and Firebase.

### 1. GitHub Environments

**Settings → Environments** → create `development`, `staging`, `production`.

On **`production`** only: enable **Required reviewers** and add yourself. Leave
the other two open.

Add these **secrets** to **each** environment (same names, different values):

| Secret | What it is |
| --- | --- |
| `ANDROID_GOOGLE_SERVICES_JSON` | that project's `google-services.json`, pasted as raw text |
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 release.jks` (macOS: `base64 -i release.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `ANDROID_KEY_ALIAS` | key alias |
| `ANDROID_KEY_PASSWORD` | key password |
| `FIREBASE_TOKEN` | `firebase login:ci` token (below). Same value in all three environments. |
| `FIREBASE_ANDROID_APP_ID` | the `1:...:android:...` App ID from that Firebase project's settings |

Optional: a repo or environment **variable** `FIREBASE_TESTER_GROUPS`, e.g.
`qa,internal`. Unset means `testers`.

### 2. One release keystore per flavor

```bash
keytool -genkeypair -v -keystore dev-release.jks -alias dev-upload \
  -keyalg RSA -keysize 2048 -validity 10000
# repeat: staging-release.jks / staging-upload, prod-release.jks / prod-upload
base64 -i dev-release.jks | pbcopy   # paste into development → ANDROID_KEYSTORE_BASE64
```

Keep the `.jks` files in the team secret store. `*.jks` is git-ignored — never
commit them.

### 3. Each Firebase project (dev / staging / prod)

- Confirm the **Android app** is registered with the package name from the table
  above. Its `google-services.json` is the `ANDROID_GOOGLE_SERVICES_JSON` secret.
- Grab **Project settings → General → App ID** for `FIREBASE_ANDROID_APP_ID`.
- **App Distribution → Testers & Groups** → create a group named `testers`
  (or whatever you put in `FIREBASE_TESTER_GROUPS`) and add people.
- Make sure **App Distribution** is enabled for the project (open the
  App Distribution page once in the console).

### 4. One Firebase CI token (once, for all three)

```bash
npm i -g firebase-tools
firebase login:ci        # opens a browser, then prints a token
```

Paste that token into `FIREBASE_TOKEN` in **all three** environments. It's tied
to the Google account that ran the command and works for every project that
account can access, so one token is enough. Whoever's account it is must stay a
member of all three Firebase projects.

### 5. Branch protection for the merge-direction check

**Settings → Branches** → add rules for `staging` and `production`: require a
pull request, and under **required status checks** add `merge-guard` (from
`ci.yml`). Without this, `ci.yml` still runs and turns red on a disallowed
merge, but the merge button stays clickable — the required check is what
actually blocks it.

### 6. First run

Push a trivial commit to `develop`, then push a `v0.0.1-dev.1` tag on it
(`git tag v0.0.1-dev.1 && git push origin v0.0.1-dev.1`). Watch
**Actions → Deploy**. It should build `com.elhawary.algodive.dev` and the
build should appear in `algo-dive-dev` → App Distribution for the `testers`
group.

---

## Common tasks

**Add a tester** — Firebase console → App Distribution → Testers & Groups → add
them to the `testers` group of that project. No code change.

**Change which groups get a build** — set the `FIREBASE_TESTER_GROUPS` variable
(repo-wide, or per environment) to a comma list.

**Re-send the current build** — re-run the deploy job: **Actions → the run →
Re-run jobs**. Or in the Firebase console, open the release and *Send to
testers* again.

**Roll back** — Firebase console → App Distribution → pick the previous release
→ *Distribute again*. Then land a real fix through the normal flow.

**Rotate a keystore** — generate a new `.jks`, update
`ANDROID_KEYSTORE_BASE64` + the three password/alias secrets in that
environment. If the app is already on Play with Play App Signing, also upload the
new upload certificate in Play Console. See PLAYBOOK.md §8.

**Rotate the Firebase token** — run `firebase login:ci` again and replace
`FIREBASE_TOKEN` in all three environments. Run `firebase logout` on the old
session if you want the previous token invalidated.

**Change the Flutter version** — both workflows pin `flutter-version: 3.44.7`
under every `subosito/flutter-action` step. Bump that string (in `ci.yml` and
`deploy.yml`) when the team's local Flutter moves.

---

## Troubleshooting

| Symptom | Cause / fix |
| --- | --- |
| Pushed to `develop`/`staging`/`production` but nothing happened in Actions | Expected — a merge alone never ships. Push a `v*` tag (via `/atomic-commits` or `/promote`) to trigger `deploy.yml`. |
| `deploy.yml does not recognize tag '…'` | The tag doesn't match `v<x.y.z>-dev.<n>`, `v<x.y.z>-stag.<n>`, or `v<x.y.z>`. Delete it and re-tag with the right shape. |
| `tag '…' is not on branch '…'` (guard job) | The tag's stage (`-dev.`/`-stag.`/plain) doesn't match the branch it was actually pushed on top of — e.g. a `-dev.` tag on a commit not reachable from `develop`. Re-tag the right commit. |
| A PR merge button is disabled with a failing `merge-guard` check | That source→target pair isn't in the [merge-direction table](#merge-direction-rules) (e.g. `develop → production` directly). Route it through the allowed path instead. |
| Deploy job stuck on *"Waiting for review"* | Expected on a plain `vX.Y.Z` (production) tag. Actions → run → **Review deployments** → approve. |
| `ANDROID_GOOGLE_SERVICES_JSON is empty for environment '…'` | The secret isn't set on that environment (setting it repo-wide is not enough). |
| `No matching client found for package name 'com.elhawary.algodive.dev'` | The `google-services.json` in that environment's secret is from the wrong Firebase project — it must contain that flavor's package. |
| `APK is debug-signed` | Keystore secrets missing or wrong for that environment, so Gradle fell back to the debug key. Re-check `ANDROID_KEYSTORE_*`. |
| Firebase upload: `Requested entity was not found` / `app not found` | `FIREBASE_ANDROID_APP_ID` is from the wrong project, or the token's account isn't a member of that project. |
| Firebase upload: `401` / `Failed to authenticate` | `FIREBASE_TOKEN` is stale or empty for that environment — regenerate with `firebase login:ci` and update all three. |
| Firebase upload: `403` / `permission denied` | The token's Google account lacks access to that Firebase project, or App Distribution isn't enabled on it. |
| `expected APK not found at build/app/outputs/flutter-apk/app-<flavor>-release.apk` | The `flutter build` step failed earlier, or the flavor name changed — the file is `app-<flavor>-release.apk`. |
| Testers didn't get an email | They're not in the group named in `FIREBASE_TESTER_GROUPS` (default `testers`), or they haven't accepted the App Distribution invite yet. |
| Version shows `1.0.0-dev+123` and that looks odd | Normal — `-dev` / `-staging` is the Gradle `versionNameSuffix`, `123` is the CI run number. |
| Wrong flavor built | `deploy.yml` picks the flavor from the tag shape in the **Resolve target** job — check that job's log. |

---

## Not covered yet

- **iOS distribution.** iOS still builds `--no-codesign` in `ci.yml` for
  verification only. Shipping signed iOS builds needs an Apple distribution
  certificate, one provisioning profile per bundle id, and registered tester
  device UDIDs — that's the phase where a small `ios/fastlane/` setup with
  `match` earns its place.
- **Play Store / TestFlight / App Store** submission.
- **Crashlytics** symbol upload (dSYMs, R8 mapping) — no `firebase_crashlytics`
  dependency yet.
