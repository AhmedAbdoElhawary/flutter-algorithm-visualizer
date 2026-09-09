# Firebase — the 6 files to create

You create **3 Firebase projects** (one per flavor) and download **6 config
files**. Nothing in this repo needs editing afterwards — the folders and the
build wiring already exist.

## In the Firebase console (3 projects)

| Flavor | Suggested project id | Android app package name | iOS app bundle id |
| --- | --- | --- | --- |
| dev | `algodive-dev` | `com.elhawary.algodive.dev` | `com.elhawary.algodive.dev` |
| staging | `algodive-staging` | `com.elhawary.algodive.staging` | `com.elhawary.algodive.staging` |
| production | `algodive-prod` | `com.elhawary.algodive` | `com.elhawary.algodive` |

`dev` and `staging` live in one Google account; `production` lives in a
**separate** Google account. Switch accounts with `firebase logout` +
`firebase login` (or `firebase login:add` to hold both) before touching the
other project — see [CICD.md](CICD.md) for the CI-side implication
(`FIREBASE_TOKEN` needs two values, not one).

For each project: **Add app → Android**, use the package name above → download
`google-services.json`. **Add app → iOS**, use the bundle id above → download
`GoogleService-Info.plist`. Enable Analytics / Remote Config on each project
as needed (no code change per flavor — data is isolated by project).
Crashlytics is not used — this app reports crashes through Sentry
(`lib/core/monitoring/sentry_crash_reporter.dart`).

## Where each file goes

| # | File | Save it exactly here |
| --- | --- | --- |
| 1 | `google-services.json` (dev) | `android/app/src/dev/google-services.json` |
| 2 | `google-services.json` (staging) | `android/app/src/staging/google-services.json` |
| 3 | `google-services.json` (production) | `android/app/src/production/google-services.json` |
| 4 | `GoogleService-Info.plist` (dev) | `ios/Runner/Firebase/dev/GoogleService-Info.plist` |
| 5 | `GoogleService-Info.plist` (staging) | `ios/Runner/Firebase/staging/GoogleService-Info.plist` |
| 6 | `GoogleService-Info.plist` (production) | `ios/Runner/Firebase/production/GoogleService-Info.plist` |

All 6 files are git-ignored.

## After dropping the files in

```bash
# Android — build each flavor to confirm google-services picks up the right file
flutter build apk --debug --flavor dev        -t lib/main_dev.dart     --dart-define-from-file=dart_define/dev.json
flutter build apk --debug --flavor staging    -t lib/main_staging.dart --dart-define-from-file=dart_define/staging.json
flutter build apk --debug --flavor production -t lib/main_prod.dart    --dart-define-from-file=dart_define/prod.json
```

A wrong/missing file fails with
`No matching client found for package name 'com.elhawary.algodive.<suffix>'`.

- You can delete the legacy `android/app/google-services.json` once all three
  `src/<flavor>/` files exist — CI no longer falls back to it (see below).
- `lib/firebase_options.dart` is no longer used at runtime and can be deleted
  (it is git-ignored anyway).

## iOS

Xcode is wired for flavors — see
**[IOS_XCODE_SETUP.md](IOS_XCODE_SETUP.md)** for exactly what exists. A
Run Script build phase (`ios/scripts/firebase_config.sh`) copies the right
`ios/Runner/Firebase/<flavor>/GoogleService-Info.plist` into place
automatically on every build, keyed off which scheme/configuration you're
building — you never hand-edit the top-level plist yourself:

```bash
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_define/dev.json
```

## CI

CI injects config from GitHub Actions secrets instead of the checked-out files:

| Secret | Scope | Written to | Used by |
| --- | --- | --- | --- |
| `ANDROID_GOOGLE_SERVICES_JSON` | per-environment (dev/staging/production hold different values) | `android/app/src/<flavor>/google-services.json` | `build-android` — a real, flavor-correct APK build |
| `GOOGLE_SERVICE_INFO_PLIST` | repo-level (one value, currently the production plist) | `ios/Runner/GoogleService-Info.plist` + `ios/Runner/Firebase/production/GoogleService-Info.plist` | `build-ios` — still a schemeless, production-only smoke build in CI even though Xcode itself now supports flavors (see [IOS_XCODE_SETUP.md](IOS_XCODE_SETUP.md)); switching `ci.yml` to a flavored build is a follow-up, not done yet |

The `quality` job (analyze + test) needs neither — it's pure Dart, no native
build.
