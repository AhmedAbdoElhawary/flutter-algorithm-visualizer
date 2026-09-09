# Monitoring setup — what I did, and what you still need to do

Simple version. Two lists: **what changed in the code**, and **what only
you can do** (accounts, buttons, secrets).

---

## The three decisions

| Tool | How it's split | Runs in |
| --- | --- | --- |
| **Sentry** | **3 separate projects** — one per flavor | release builds only |
| **Firebase Analytics** | **3 separate projects** — already the case | release builds only |
| **Shorebird** | **production flavor only** | production releases only |

### Why "release builds only" matters

This is keyed on **how the app was compiled**, not which flavor it is:

| Situation | Reports? | Why |
| --- | --- | --- |
| You running the app on your machine (`flutter run`) | ❌ No | The error is already in your console. Sending it just burns free quota. |
| Profile-mode build | ❌ No | Same reason. |
| A **tester** installing a dev build from Firebase | ✅ Yes | You can't see their console. This is the case that matters. |
| A real user on production | ✅ Yes | Obviously. |

So the `dev` flavor **does** report — as long as it's a real release build on
someone else's phone. That's the point.

### Why Shorebird is production-only

Dev and staging already ship in minutes: push a `-dev.N` tag, no approval,
done. Code push solves a problem those two don't have. Production is the only
place where waiting for a full release actually costs you something.

**Consequence:** dev and staging builds are **not patchable**, on purpose.
Only production can receive a hotfix patch.

---

## What changed in the code

| File | What it does now |
| --- | --- |
| **`lib/core/monitoring/monitoring.dart`** ⭐ **new** | The single on/off switch for everything. One `isEnabled = kReleaseMode` constant decides it all. Also holds every Sentry setting in one place. |
| `lib/bootstrap.dart` | Went back to being short and readable — it lists boot steps and hands monitoring to `Monitoring`. Catches every crash via `runZonedGuarded` + Flutter's two error hooks. |
| `lib/core/monitoring/crash_reporter.dart` | The "report a crash" button. App code calls this, never Sentry directly — so the vendor stays swappable. |
| `lib/core/monitoring/sentry_crash_reporter.dart` | The real Sentry version, plus a quota cap: max 3 reports of the same bug per app session. |
| `lib/core/monitoring/analytics_service.dart` | The "log an event" button. Same idea. |
| `lib/core/flavor/flavor_config.dart` | Learned one new value: `sentryDsn` — which Sentry project this flavor reports to. |
| `dart_define/dev.json` / `staging.json` / `prod.json` | Each got `"SENTRY_DSN": ""` — **empty until you fill it in**. |
| `lib/config/routes/route_app.dart` | Every screen change is tracked automatically. The observer list comes from `Monitoring`, so it's empty (and safe) when monitoring is off. |
| `.github/workflows/deploy.yml` | Production builds via **Shorebird**; dev/staging via plain `flutter build`. |
| `.github/workflows/patch.yml` | **New.** A manual button: hotfix production. Requires your approval, same as a release. |
| `.claude/skills/hotfix/SKILL.md` | **New.** Ask me `/hotfix` and I'll work out patch-vs-full-release for you. |
| `docs/flavors/RELEASES.md`, `CICD.md` | Updated with the monitoring + hotfix flow. |

**Nothing was removed.** The old `debugPrint` Firebase logger stays — it's a
local dev tool, separate from remote reporting.

Verified: `flutter analyze` clean, all 143 tests pass.

### Sentry settings applied (the "best practices" part)

All in one place, in `monitoring.dart`:

| Setting | Value | Why |
| --- | --- | --- |
| `sendDefaultPii` | **false** | No emails, usernames or IPs. You have `firebase_auth`, so real emails are in memory — opted out explicitly. |
| `environment` | flavor name | Works even with separate projects, and keeps events meaningful if you ever merge them. |
| `release` | *auto-detected* | Read from the real build's version + package name, so it can't drift out of sync with `pubspec.yaml`. |
| `enableAutoSessionTracking` | **true** | Gives "crash-free users per release" — the number to watch after shipping. |
| `tracesSampleRate` | 1.0 dev/staging, **0.2** production | Full detail where volume is tiny; a fifth in production so the free quota goes to errors, not performance spans. |
| `beforeSend` | quota cap | Max 3 of the same error type per session. Deliberately **not** `sampleRate`, which would distort the "N users affected" count. |

---

## What you still need to do

I can't create accounts for you. In order:

### 1. Sentry — 3 projects

1. [sentry.io](https://sentry.io) → sign up free.
2. Create **3 projects**, platform = **Flutter**:
   | Flavor | Sentry project name |
   | --- | --- |
   | dev | `algodive-dev` |
   | staging | `algodive-staging` |
   | production | **`algodive`** — no suffix |

   Production carries the plain name, matching how the app itself is named
   (`AlgoDive Dev` / `AlgoDive Stag` / `AlgoDive`).
3. Each shows a **DSN** (`https://...@...ingest.sentry.io/...`). Copy each one.
4. ⚠️ **Do not put these in the repo — it is public.** Add each as a GitHub
   **Environment** secret named `SENTRY_DSN`:

   GitHub → **Settings → Environments** → pick the environment → **Add secret**

   | Environment | Value |
   | --- | --- |
   | `development` | dev project DSN |
   | `staging` | staging project DSN |
   | `production` | prod project DSN |

   Same secret name in all three, different value — exactly like
   `ANDROID_GOOGLE_SERVICES_JSON` already works. CI writes it into a
   git-ignored `dart_define/<flavor>.secret.json` at build time and deletes it
   after.
5. In **each** Sentry project: **Settings → Spike Protection → ON**.
   (Stops one runaway bug from eating the whole month's free quota.)

**Do you need the DSN locally? No.** Monitoring is release-only, so normal
`flutter run` work never uses it. If you ever want to test a local release
build, create `dart_define/dev.secret.json` yourself (git-ignored) — see
[dart_define/README.md](../../dart_define/README.md).

### 2. Firebase — check Analytics is on

You already have the 3 projects. Note the dev/staging Firebase project names
match the Sentry project names above exactly (`algodive-dev` /
`algodive-staging`) — they are two different systems that happen to share a
name; production does not (`algodive-prod` here vs `algodive` in Sentry).
Just confirm, for each of `algodive-dev` / `algodive-staging` / `algodive-prod`:

**Project settings → Integrations → Google Analytics → enabled.**

Some projects get created without it. That's the whole step.

### 3. Shorebird — production only

1. Install the CLI from [docs.shorebird.dev](https://docs.shorebird.dev).
2. In the project folder:
   ```bash
   shorebird login
   shorebird init
   ```
   `init` detects your flavors and writes `shorebird.yaml`. **Commit it.**
   (It will list all three flavors — that's fine. Only production is ever
   released or patched through Shorebird.)
3. Get a CI token. `shorebird login:ci` is **removed** — create it in the
   console instead: **console.shorebird.dev → Account → API Keys → Create
   API Key**. Copy it immediately, it's shown only once.
4. GitHub → **Settings → Environments → production → Add secret**:
   - Name: `SHOREBIRD_TOKEN`
   - Value: the API key
   - This lives under the **production environment**, not repo-level —
     `deploy.yml` and `patch.yml` both run their Shorebird steps with
     `environment: production`.

### 4. Google Play — when you're ready

Nothing yet. Tell me when you open the account — the pipeline is already
built so the **first** production upload is Shorebird-made and therefore
patchable. A build made the plain way can never be patched, so that order
matters.

---

## How to check it worked

Monitoring is off in debug, so `flutter run` proves nothing. You need a
**release** build:

```bash
flutter build apk --release --flavor dev -t lib/main_dev.dart \
  --dart-define-from-file=dart_define/dev.json
```

Install that APK, make it crash (ask me to add a temporary crash button), then:

1. **Sentry `algodive-dev`** → the crash should appear within ~30 seconds,
   tagged `environment: dev`.
2. **Firebase console → Analytics → DebugView** → open a few screens, watch
   `screen_view` events arrive.

If either doesn't show up, tell me and I'll debug it.
