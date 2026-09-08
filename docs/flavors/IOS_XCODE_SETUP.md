# iOS — one-time Xcode setup

Everything version-controllable is already in the repo (`.xcconfig` files,
`AppIcon-*` sets, `ios/scripts/firebase_config.sh`, base bundle id fixed to
`com.elhawary.algodive`). What's left can only be done in the Xcode GUI because
it edits `ios/Runner.xcodeproj/project.pbxproj` and the scheme files. Budget
~15 minutes, once.

Open the workspace:

```bash
open ios/Runner.xcworkspace
```

---

## 1. Create 9 build configurations

Project navigator → **Runner** (the project, top of the list) → **Info** tab →
**Configurations**.

You currently have `Debug`, `Release`, `Profile`. For each flavor duplicate the
matching base config and rename:

| Duplicate this | Rename the copy to |
| --- | --- |
| Debug   | `Debug-dev` |
| Release | `Release-dev` |
| Profile | `Profile-dev` |
| Debug   | `Debug-staging` |
| Release | `Release-staging` |
| Profile | `Profile-staging` |
| Debug   | `Debug-production` |
| Release | `Release-production` |
| Profile | `Profile-production` |

(Use the **+** under the Configurations list → "Duplicate 'Debug' Configuration",
then double-click to rename.)

You should end up with 12 configurations total.

---

## 2. Point each configuration at its `.xcconfig`

Still in **Configurations**, expand each new row. It has two lines: **Runner**
(the project) and **Runner** (the target). Set the file for **both** lines of
each row (click the dropdown → "Other…" is not needed, the files are already in
`ios/Flutter/`):

| Configuration | `.xcconfig` file |
| --- | --- |
| `Debug-dev` | `Flutter/Debug-dev.xcconfig` |
| `Release-dev` | `Flutter/Release-dev.xcconfig` |
| `Profile-dev` | `Flutter/Profile-dev.xcconfig` |
| `Debug-staging` | `Flutter/Debug-staging.xcconfig` |
| … | … (same pattern) |
| `Profile-production` | `Flutter/Profile-production.xcconfig` |

Each file already sets `FLUTTER_TARGET`, `PRODUCT_BUNDLE_IDENTIFIER`,
`PRODUCT_NAME=Runner`, `APP_DISPLAY_NAME`, and
`ASSETCATALOG_COMPILER_APPICON_NAME` (`AppIcon-dev` / `AppIcon-staging` /
`AppIcon-production`).

> Leave the original `Debug` / `Release` / `Profile` pointed at
> `Flutter/Debug.xcconfig` / `Flutter/Release.xcconfig`. They default to the
> production identity and the plain `AppIcon` set, so a schemeless build (CI's
> current iOS job, `flutter test`) still works.

---

## 3. Create 3 schemes

**Product → Scheme → Manage Schemes… → +**  (or duplicate the `Runner` scheme
three times).

Create schemes named exactly **`dev`**, **`staging`**, **`production`**. For
each, click **Edit…** and set the build configuration per action:

| Action | dev scheme | staging scheme | production scheme |
| --- | --- | --- | --- |
| Run | `Debug-dev` | `Debug-staging` | `Debug-production` |
| Test | `Debug-dev` | `Debug-staging` | `Debug-production` |
| Profile | `Profile-dev` | `Profile-staging` | `Profile-production` |
| Analyze | `Debug-dev` | `Debug-staging` | `Debug-production` |
| Archive | `Release-dev` | `Release-staging` | `Release-production` |

Tick **Shared** for all three (so they land in
`ios/Runner.xcodeproj/xcshareddata/xcschemes/` and get committed). You can
delete the old `Runner` scheme or leave it.

`flutter run --flavor dev` maps `dev` → the `dev` scheme automatically.

---

## 4. Add the Firebase Run Script build phase

Target **Runner** → **Build Phases** → **+ → New Run Script Phase**.

- Name it **`Firebase config (per flavor)`**.
- Script body:
  ```sh
  "${SRCROOT}/scripts/firebase_config.sh"
  ```
- Drag it to run **after** "[CP] Embed Pods Frameworks" and **before**
  "[CP] Copy Pods Resources" / the Flutter "Thin Binary" phase.
- Untick **"Based on dependency analysis"** (so it runs every build).

The script picks `dev` / `staging` / `production` from `$CONFIGURATION` and
copies `ios/Runner/Firebase/<flavor>/GoogleService-Info.plist` into place. It
`exit 1`s with a clear message if the file is missing.

---

## 5. `CFBundleDisplayName`

Already done in the repo: `ios/Runner/Info.plist` uses
`<string>$(APP_DISPLAY_NAME)</string>`, and every `.xcconfig` (including the
base ones) defines `APP_DISPLAY_NAME`. Nothing to do — just don't revert it.

---

## 6. Verify

```bash
flutter build ios --debug --no-codesign --flavor dev        -t lib/main_dev.dart     --dart-define-from-file=dart_define/dev.json
flutter build ios --debug --no-codesign --flavor staging    -t lib/main_staging.dart --dart-define-from-file=dart_define/staging.json
flutter build ios --debug --no-codesign --flavor production -t lib/main_prod.dart    --dart-define-from-file=dart_define/prod.json
```

- Build log shows `Firebase: using <flavor> GoogleService-Info.plist`.
- On device: dev app is **"AlgoDive Dev"**, bundle id
  `com.elhawary.algodive.dev`, red DEV ribbon icon; the three flavors install
  side by side.

## 7. Commit

```bash
git add ios/Runner.xcodeproj/project.pbxproj \
        ios/Runner.xcodeproj/xcshareddata/xcschemes/
git commit -m "ios: per-flavor build configs, schemes and Firebase build phase"
```

Then switch the iOS job in `.github/workflows/ci.yml` to the flavored command
noted in its comment.

---

## If you'd rather automate it

`flutter_flavorizr` can generate steps 1–4 from a `pubspec.yaml` block, but it
also rewrites `lib/main.dart`, `Info.plist` and `android/app/build.gradle.kts`,
which would clobber the custom bootstrap / Firebase wiring here. If you go that
route, run it on a clean branch with only the iOS processors
(`-p ios:xcconfig,ios:buildTargets,ios:schema`) and diff carefully before
merging.
