# Flavors — full reference

Three flavors: `dev`, `staging`, `production`. Each is a complete environment
(own name, own application id / bundle id, own launcher icon, own Firebase
project).

- [Folder & file layout](#folder--file-layout)
- [How a flavor is selected](#how-a-flavor-is-selected)
- [Environment config (`--dart-define-from-file`)](#environment-config)
- [Launcher icons](#launcher-icons)
- [Firebase](#firebase)
- [Signing](#signing)
- [Run / build commands](#run--build-commands)
- [Branch → environment map](#branch--environment-map)
- [Adding a 4th flavor (e.g. `qa`)](#adding-a-4th-flavor)

---

## Folder & file layout

```
dart_define/
  dev.json  staging.json  prod.json        # non-secret env selectors, committed

lib/
  main.dart                                # thin, throws — never launch this
  main_dev.dart  main_staging.dart  main_prod.dart
  bootstrap.dart                           # shared boot: FlavorConfig + Firebase + runApp
  core/flavor/
    flavor.dart                            # Flavor enum
    flavor_config.dart                     # runtime config, reads --dart-define values
    flavor_banner.dart                     # in-app corner ribbon (dev/staging only)

android/app/
  build.gradle.kts                         # flavorDimensions "environment" + productFlavors
  src/dev/  src/staging/  src/production/   # per-flavor google-services.json + generated res/
  src/main/                                # shared code & resources

ios/
  Flutter/
    Debug.xcconfig  Release.xcconfig                       # base (+ APP_DISPLAY_NAME default)
    {Debug,Release,Profile}-dev.xcconfig                   # per-flavor overrides
    {Debug,Release,Profile}-staging.xcconfig
    {Debug,Release,Profile}-production.xcconfig
  Runner/Firebase/{dev,staging,production}/GoogleService-Info.plist   # you drop these in
  scripts/firebase_config.sh                               # copies the right plist at build time
  Runner/Assets.xcassets/AppIcon{,-dev,-staging}.appiconset/

flutter_launcher_icons-{dev,staging,production}.yaml       # per-flavor icon config
tool/flavor_icons/
  base/app_icon.png                        # 1024×1024 source artwork
  generate_ribbon_icons.dart               # overlays the DEV/STAGING ribbon
  generated/{dev,staging,production}.png    # ribboned / clean sources for flutter_launcher_icons
```

---

## How a flavor is selected

1. You pass `--flavor <name>` + `-t lib/main_<name>.dart` + `--dart-define-from-file=dart_define/<name>.json`.
2. `--flavor` selects the **native** flavor: Android `productFlavor` (Gradle),
   iOS build configuration `Debug-<name>` / `Release-<name>` (Xcode). That
   decides applicationId/bundle id, app name, launcher icon, and which
   `google-services.json` / `GoogleService-Info.plist` is bundled.
3. The entry point builds a `FlavorConfig` from the `--dart-define` values and
   passes it to `bootstrap()`, which calls `FlavorConfig.initialize(...)` then
   `Firebase.initializeApp()` (no options — it reads the bundled native file).
4. Anything in Dart reads `FlavorConfig.instance` (`.flavor`, `.appName`,
   `.apiBaseUrl`, `.showFlavorBanner`).

If `FlavorConfig` is never initialized (someone shipped `lib/main.dart`), the
app throws at startup — deliberately loud.

---

## Environment config

Per-flavor values live in `dart_define/<flavor>.json` and are read at compile
time via `String.fromEnvironment` inside `FlavorConfig.fromEnvironment()`.

```json
// dart_define/dev.json
{
  "FLAVOR": "dev",
  "APP_NAME": "AlgoDive Dev",
  "API_BASE_URL": "https://dev.api.algodive.app"
}
```

- These files hold **no secrets** — only a flavor name, a display name, and a
  public base URL — so they are committed.
- Need a real secret (API key, token)? Put it in `dart_define/<flavor>.secret.json`
  (git-ignored — see `.gitignore`) and pass **both** files:
  `--dart-define-from-file=dart_define/dev.json --dart-define-from-file=dart_define/dev.secret.json`.
  In CI, write the secret file from a GitHub Actions secret in a step before the build.
- Add a new key: add it to all three JSON files, then read it in
  `FlavorConfig.fromEnvironment()` and expose it as a field.

---

## Launcher icons

Base artwork: `tool/flavor_icons/base/app_icon.png` (1024×1024). Two steps:

```bash
# 1. overlay the ribbon → tool/flavor_icons/generated/{dev,staging,production}.png
dart run tool/flavor_icons/generate_ribbon_icons.dart

# 2. fan out to every density / idiom
dart run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml
#   (this auto-processes every flutter_launcher_icons-*.yaml it finds)
```

Output:
- Android → `android/app/src/<flavor>/res/mipmap-*` + `drawable-*` + `values/colors.xml`
- iOS → `ios/Runner/Assets.xcassets/AppIcon-dev.appiconset`,
  `AppIcon-staging.appiconset`, `AppIcon-production.appiconset` (clean). The
  flavor `.xcconfig` files set `ASSETCATALOG_COMPILER_APPICON_NAME` to the
  matching set. The original `AppIcon.appiconset` stays as the fallback for
  schemeless builds.

`production` is always the clean, un-badged icon. Ribbon colour / position /
text are constants at the top of `generate_ribbon_icons.dart`.

> Note: `flutter_launcher_icons` 0.14 does not emit `ic_launcher_round.png`.
> dev/staging round icons therefore fall back to the un-badged `src/main`
> version on the few launchers that still request the legacy round icon;
> the adaptive icon (`mipmap-anydpi-v26`) is badged.

---

## Firebase

Native config files are the source of truth (no `firebase_options.dart` at
runtime). `Firebase.initializeApp()` is called with no arguments.

- **Android**: `com.google.gms.google-services` (v4.4.4, declared in
  `android/settings.gradle.kts`) resolves `android/app/src/<flavor>/google-services.json`
  automatically, falling back to `android/app/google-services.json`. That
  version **does** support per-flavor resolution.
- **iOS**: `ios/scripts/firebase_config.sh` runs as a build phase, reads
  `$CONFIGURATION` (`Debug-dev`, `Release-staging`, …) and copies the matching
  `ios/Runner/Firebase/<flavor>/GoogleService-Info.plist` to
  `ios/Runner/GoogleService-Info.plist` + into the built `.app`.
- Crashlytics / Analytics / Remote Config need no per-flavor Dart code — each
  flavor points at its own Firebase project, so data is isolated once the files
  are in place.

The exact 6 files to create → **[FIREBASE_CHECKLIST.md](FIREBASE_CHECKLIST.md)**.

---

## Signing

`android/app/build.gradle.kts`:

- No flavor pins a `signingConfig`. Every flavor inherits the build type's
  config: a `--release` build is signed with `release` when
  `android/key.properties` exists, and falls back to `debug` when it doesn't
  (fresh clone, PR CI) so it still compiles.
- `flutter run --flavor <x>` uses the **debug** build type → the debug key,
  always. Signing only matters for `--release`.
- In CI (`deploy.yml`) each environment injects **its own** keystore: the job
  decodes `ANDROID_KEYSTORE_BASE64` to `android/app/release.jks` and writes
  `android/key.properties` from the keystore secrets, before `flutter build`,
  then deletes both afterwards. So dev/staging/production release APKs are each
  signed with a different, per-environment key.
- `android/key.properties`, `*.jks`, `*.keystore` are git-ignored. Locally you
  only need them to make a `--release` build; a debug run never does.

Android CI delivery is live — see **[CICD.md](CICD.md)** for the technical
reference, or **[RELEASES.md](RELEASES.md)** for the short day-to-day version.
iOS signing (per build configuration in Xcode / `ExportOptions.plist`) and iOS
distribution are still a later phase.

---

## Run / build commands

| | dev | staging | production |
|---|---|---|---|
| run | `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_define/dev.json` | `flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=dart_define/staging.json` | `flutter run --flavor production -t lib/main_prod.dart --dart-define-from-file=dart_define/prod.json` |
| apk | `flutter build apk --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_define/dev.json` | …`staging`… | …`production`… |
| appbundle | `flutter build appbundle --release --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_define/dev.json` | … | … |
| ios | `flutter build ios --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_define/dev.json` *(needs the Xcode schemes — see IOS_XCODE_SETUP.md)* | … | … |

Tests: `flutter test --dart-define-from-file=dart_define/dev.json` (any flavor
file works; `FlavorConfig` also has a safe fallback if none is passed).

---

## Branch → environment map

Implemented in `.github/workflows/deploy.yml`. Full guide: **[CICD.md](CICD.md)**.

| Branch       | GitHub Environment | Flavor       | Firebase project    | Deploy target |
| ------------ | ------------------ | ------------ | ------------------- | ------------- |
| `develop`    | `development`       | `dev`        | `algo-dive-dev`     | Firebase App Distribution — automatic |
| `staging`    | `staging`          | `staging`    | `algo-dive-staging` | Firebase App Distribution — automatic |
| `production` | `production`       | `production` | `algo-dive-prod`    | Firebase App Distribution — after a required-reviewer approval |

- **Push/merge** to one of these branches → `deploy.yml` builds that flavor's
  release APK and uploads it to that flavor's Firebase project.
- **Pull requests** into these branches → `.github/workflows/ci.yml` runs
  analyze + test + a smoke build (no secrets).
- iOS distribution and the app stores are a later phase — see CICD.md.

---

## Adding a 4th flavor

Say `qa`, app name "AlgoDive QA", suffix `.qa`. Touch these, in order:

1. **`lib/core/flavor/flavor.dart`** — add `qa` to the `Flavor` enum + its
   `bannerLabel`.
2. **`dart_define/qa.json`** — copy `dev.json`, set `FLAVOR`, `APP_NAME`, `API_BASE_URL`.
3. **`lib/main_qa.dart`** — copy `lib/main_dev.dart`.
4. **`android/app/build.gradle.kts`** — add a `create("qa") { … }` block in
   `productFlavors` (dimension, `applicationIdSuffix = ".qa"`,
   `versionNameSuffix`, `resValue("string", "app_name", "AlgoDive QA")`). No
   `signingConfig` line — flavors inherit the build type's.
5. **`android/app/src/qa/`** — create the folder; drop `google-services.json`
   for the qa Firebase Android app (`com.elhawary.algodive.qa`).
6. **iOS `.xcconfig`** — add `ios/Flutter/{Debug,Release,Profile}-qa.xcconfig`
   (copy the dev ones, change `FLUTTER_TARGET`, `PRODUCT_BUNDLE_IDENTIFIER`,
   `APP_DISPLAY_NAME`, `ASSETCATALOG_COMPILER_APPICON_NAME=AppIcon-qa`).
7. **iOS Xcode** — duplicate the `*-dev` build configurations to `*-qa`, point
   each at the new `.xcconfig`, create a `qa` scheme. See IOS_XCODE_SETUP.md.
8. **`ios/Runner/Firebase/qa/`** — create the folder; drop the qa
   `GoogleService-Info.plist`. `firebase_config.sh` already matches `*-qa`
   via its `*-<name>` fallback — add an explicit `*-qa|*Qa) FLAVOR="qa" ;;`
   case only if you want it distinct from production's default branch.
9. **`flutter_launcher_icons-qa.yaml`** + a `('qa.png', 'QA')` entry in
   `tool/flavor_icons/generate_ribbon_icons.dart`, then rerun both icon commands.
10. **`.vscode/launch.json`** + **`.idea/runConfigurations/qa.xml`** — copy an
    existing entry.
11. **`.gitignore`** — add `/android/app/src/qa/google-services.json` and
    `/ios/Runner/Firebase/qa/GoogleService-Info.plist`.
12. **CI** — add `qa` wherever `dev`/`staging` appear.
