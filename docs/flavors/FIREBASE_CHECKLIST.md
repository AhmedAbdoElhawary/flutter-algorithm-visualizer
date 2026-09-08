# Firebase — the 6 files to create

You create **3 Firebase projects** (one per flavor) and download **6 config
files**. Nothing in this repo needs editing afterwards — the folders and the
build wiring already exist.

## In the Firebase console (3 projects)

| Flavor | Suggested project id | Android app package name | iOS app bundle id |
| --- | --- | --- | --- |
| dev | `algodive-dev` | `com.elhawary.algodive.dev` | `com.elhawary.algodive.dev` |
| staging | `algodive-staging` | `com.elhawary.algodive.staging` | `com.elhawary.algodive.staging` |
| production | `algodive` (existing) | `com.elhawary.algodive` | `com.elhawary.algodive` |

For each project: **Add app → Android**, use the package name above → download
`google-services.json`. **Add app → iOS**, use the bundle id above → download
`GoogleService-Info.plist`. Enable Crashlytics / Analytics / Remote Config on
each project as needed (no code change per flavor — data is isolated by
project).

## Where each file goes

| # | File | Save it exactly here |
| --- | --- | --- |
| 1 | `google-services.json` (dev) | `android/app/src/dev/google-services.json` |
| 2 | `google-services.json` (staging) | `android/app/src/staging/google-services.json` |
| 3 | `google-services.json` (production) | `android/app/src/production/google-services.json` |
| 4 | `GoogleService-Info.plist` (dev) | `ios/Runner/Firebase/dev/GoogleService-Info.plist` |
| 5 | `GoogleService-Info.plist` (staging) | `ios/Runner/Firebase/staging/GoogleService-Info.plist` |
| 6 | `GoogleService-Info.plist` (production) | `ios/Runner/Firebase/production/GoogleService-Info.plist` |

Each target folder has a `PLACE_..._HERE.md` reminder. All 6 files are
git-ignored.

## After dropping the files in

```bash
# Android — build each flavor to confirm google-services picks up the right file
flutter build apk --debug --flavor dev        -t lib/main_dev.dart     --dart-define-from-file=dart_define/dev.json
flutter build apk --debug --flavor staging    -t lib/main_staging.dart --dart-define-from-file=dart_define/staging.json
flutter build apk --debug --flavor production -t lib/main_prod.dart    --dart-define-from-file=dart_define/prod.json
```

A wrong/missing file fails with
`No matching client found for package name 'com.elhawary.algodive.<suffix>'`.

- You can now delete the legacy `android/app/google-services.json` once all
  three `src/<flavor>/` files exist (keep it if CI still relies on it as a
  fallback — see `.github/workflows/ci.yml`).
- `lib/firebase_options.dart` is no longer used at runtime and can be deleted
  (it is git-ignored anyway).

## iOS

The plists only take effect once the Xcode build configurations, schemes and
the "Firebase config (per flavor)" Run Script phase exist —
see **[IOS_XCODE_SETUP.md](IOS_XCODE_SETUP.md)**. After that:

```bash
flutter build ios --debug --no-codesign --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_define/dev.json
# build log prints: "Firebase: using dev GoogleService-Info.plist (CONFIGURATION=Debug-dev)"
```

## CI

CI injects config from GitHub Actions secrets instead of the checked-out files:

| Secret | Written to | Used by |
| --- | --- | --- |
| `GOOGLE_SERVICES_JSON` | `android/app/google-services.json` | fallback for every Android flavor build |
| `GOOGLE_SERVICE_INFO_PLIST` | `ios/Runner/GoogleService-Info.plist` + `ios/Runner/Firebase/production/GoogleService-Info.plist` | iOS build |

For per-flavor isolation in CI, add `GOOGLE_SERVICES_JSON_DEV` etc. and write
them to `android/app/src/dev/google-services.json` in the workflow.
