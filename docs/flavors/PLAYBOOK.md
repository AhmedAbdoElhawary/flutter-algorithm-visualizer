# Flavor playbook — day-to-day situations

Concrete commands and file paths for things you'll actually do. Assumes the
one-time setup ([README](README.md), [IOS_XCODE_SETUP](IOS_XCODE_SETUP.md),
[FIREBASE_CHECKLIST](FIREBASE_CHECKLIST.md)) is done.

Shipping a build (branch → flavor → Firebase App Distribution) is its own
guide: **[CICD.md](CICD.md)**. Short version: merge to `develop` / `staging` /
`production` and the matching flavor is built and distributed automatically
(production waits for your approval). Write the tester-facing notes in
`CHANGELOG.md` — the top block is what ships.

Shorthand used below:

```
DEV="--flavor dev        -t lib/main_dev.dart     --dart-define-from-file=dart_define/dev.json"
STG="--flavor staging    -t lib/main_staging.dart --dart-define-from-file=dart_define/staging.json"
PRD="--flavor production  -t lib/main_prod.dart    --dart-define-from-file=dart_define/prod.json"
```

---

## 1. Run a flavor locally — device vs emulator

```bash
flutter devices                       # list ids
flutter run $DEV                      # only device connected
flutter run $DEV -d <device-id>       # pick one
flutter run $DEV -d emulator-5554     # Android emulator
flutter run $DEV -d "iPhone 15"       # iOS simulator (name or udid)
```

Real iOS device: open `ios/Runner.xcworkspace` once, select the `dev` scheme +
your device, set a signing team on the **Runner** target for **all** `*-dev`
configs, run once from Xcode to trust it, then `flutter run $DEV` works.

All three flavors install side by side (distinct application ids) — no need to
uninstall between switches.

---

## 2. Debug a flavor in an IDE

**VS Code** — `.vscode/launch.json` already has `dev (debug)`,
`dev (profile)`, `staging (debug)`, `production (debug)`,
`production (release)`. Run and Debug panel → pick one → F5. Add a variant by
copying an entry and changing `program` + `args`.

**Android Studio / IntelliJ** — `.idea/runConfigurations/{dev,staging,production}.xml`
are committed and show up in the run-config dropdown. New one: **Edit
Configurations → + → Flutter**, Dart entrypoint `lib/main_<flavor>.dart`,
Additional args `--flavor <flavor> --dart-define-from-file=dart_define/<flavor>.json`.

---

## 3. Add a new flavor (`qa`, `hotfix`, …)

Full ordered checklist is in [README.md → Adding a 4th flavor](README.md#adding-a-4th-flavor).
Short version — every file that changes:

- `lib/core/flavor/flavor.dart` (enum + `bannerLabel`)
- `dart_define/<name>.json`
- `lib/main_<name>.dart`
- `android/app/build.gradle.kts` (`create("<name>") { … }`)
- `android/app/src/<name>/` (+ `google-services.json`)
- `ios/Flutter/{Debug,Release,Profile}-<name>.xcconfig`
- Xcode: configs + scheme (IOS_XCODE_SETUP steps 1–3)
- `ios/Runner/Firebase/<name>/` (+ plist)
- `flutter_launcher_icons-<name>.yaml` + entry in `generate_ribbon_icons.dart`
- `.vscode/launch.json`, `.idea/runConfigurations/<name>.xml`
- `.gitignore` (2 lines)
- CI

---

## 4. New package that needs native setup

Does it need per-flavor handling? Decision:

| The package… | Per-flavor work? |
| --- | --- |
| pure Dart / Flutter plugin with no config file | **No.** `flutter pub add`, done for all flavors. |
| needs an API key in code | Put the key in `dart_define/<flavor>.secret.json` (3 files) + read it in `FlavorConfig`. |
| Android: needs a manifest entry / permission | Add to `android/app/src/main/AndroidManifest.xml` (shared) unless it must differ per flavor → `android/app/src/<flavor>/AndroidManifest.xml` (manifest-merger combines them). |
| Android: needs a `values` resource that differs per flavor | `android/app/src/<flavor>/res/values/…` |
| iOS: needs an `Info.plist` key | Add to `ios/Runner/Info.plist` with `$(SOME_VAR)`, define `SOME_VAR` in each `ios/Flutter/*-<flavor>.xcconfig` (and the base `Debug/Release.xcconfig`). |
| iOS: needs a URL scheme / entitlement per flavor | URL scheme → `Info.plist` via xcconfig var. Entitlements → separate `Runner-<flavor>.entitlements` + `CODE_SIGN_ENTITLEMENTS` in the xcconfig. |
| ships its own `google-services`-style plugin (e.g. another analytics SDK) | Mirror the Firebase pattern: per-flavor file under `android/app/src/<flavor>/` and a copy-script build phase on iOS. |

After any native change: `flutter clean && flutter pub get`, then build **each**
flavor once (`flutter build apk --debug $DEV`, `$STG`, `$PRD`).

---

## 5. New Firebase service (Remote Config, FCM, Performance, …)

1. **Enable it in all 3 Firebase projects** (dev, staging, production consoles)
   — same service, three times.
2. **FCM / anything needing an APNs key or extra plist keys**: re-download all
   6 config files (they may gain fields) and replace them in
   `android/app/src/<flavor>/` and `ios/Runner/Firebase/<flavor>/`.
3. `flutter pub add firebase_<service>` (applies to every flavor).
4. Wire it in `lib/bootstrap.dart` (runs for every flavor) or behind a
   `FlavorConfig.instance.flavor` check if a flavor should opt out.
5. iOS push: add the **Push Notifications** capability to the Runner target for
   every `*-<flavor>` configuration; upload an APNs key to each Firebase project.
6. Build all three flavors; verify data lands in the **matching** Firebase
   project (dev events in the dev project, etc.).

No per-flavor Dart config object is needed — isolation comes from each flavor
bundling its own `google-services.json` / `GoogleService-Info.plist`.

---

## 6. Hotfix straight from `production`

Normal flow is `develop → staging → production`. For an urgent fix:

```bash
git checkout production && git pull
git checkout -b hotfix/<short-desc>
# ... fix ...
flutter build appbundle --release $PRD          # sanity check locally
git commit -am "hotfix: <desc>"
git push -u origin hotfix/<short-desc>
# PR hotfix/<short-desc> -> production, review, merge (manual approval gate)
```

Then **forward-merge** so the fix isn't lost:

```bash
git checkout staging && git pull && git merge --no-ff production && git push
git checkout develop && git pull && git merge --no-ff staging    && git push
```

Bump `version:` in `pubspec.yaml` (patch, e.g. `1.4.2+43 → 1.4.3+44`) in the
hotfix branch — the store rejects a re-used build number.

---

## 7. A merge to `staging` / `production` fails CI

1. Open the failed run: **Actions** tab → the run → the red job.
2. Common causes & fixes:
   - **`No matching client found for package name …`** — that environment's
     `ANDROID_GOOGLE_SERVICES_JSON` secret is from the wrong Firebase project.
     Replace it with the `google-services.json` whose package matches
     `com.elhawary.algodive[.suffix]`.
   - **`… is empty for environment '…'`** — the secret is set repo-wide but not
     on that GitHub Environment. Add it under Settings → Environments.
   - **`APK is debug-signed`** — that environment's `ANDROID_KEYSTORE_*` secrets
     are missing/wrong, so Gradle fell back to the debug key. Re-add (see §9).
   - **`flutter analyze` errors** — reproduce locally: `flutter analyze lib test`.
   - **Firebase upload `401` / `403` / `not found`** — `FIREBASE_TOKEN` is
     stale (regenerate with `firebase login:ci`), or its account can't reach
     that project, or `FIREBASE_ANDROID_APP_ID` is from the wrong project.
     See [CICD.md](CICD.md#troubleshooting).
   - **Production deploy stuck** on *"Waiting for review"* — expected; approve it
     under the run's **Review deployments** prompt.
3. Fix on a branch, PR it, re-merge. To just re-run after a flaky failure:
   **Actions → run → "Re-run failed jobs"**.
4. `git revert -m 1 <merge-commit>` if you need the branch green *now* and the
   fix will take a while.

---

## 8. Rotate / replace a signing key or a Firebase config file

**Android upload key**

```bash
keytool -genkey -v -keystore upload-keystore-new.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
```

- If the app is already on Play with **Play App Signing**: upload the new
  upload cert in Play Console → *Setup → App integrity → Upload key
  certificate* (export it with `keytool -export -rfc -alias upload -file upload_cert.pem -keystore upload-keystore-new.jks`).
- Replace `upload-keystore.jks`, update `android/key.properties`
  (`storePassword`/`keyPassword`/`storeFile`), update the GitHub secrets used by
  release CI. Never commit either file (both are git-ignored).
- `flutter build appbundle --release $PRD` and check
  `keytool -printcert -jarfile build/app/outputs/bundle/productionRelease/app-production-release.aab`.

**Firebase config file** — download the fresh file from the console and
overwrite it in place:

- Android: `android/app/src/<flavor>/google-services.json`
- iOS: `ios/Runner/Firebase/<flavor>/GoogleService-Info.plist`
- Update the CI secret(s). `flutter clean`, rebuild that flavor, confirm the
  `project_id` / `BUNDLE_ID` inside the new file is right before shipping.

**iOS certs / provisioning** — regenerate in the Apple Developer portal, update
whatever the CI uses (Fastlane match repo or the base64 cert/profile secrets).
Bump nothing in the repo.

---

## 9. Onboard a new developer

```bash
git clone <repo> && cd algorithm-visualizer
flutter pub get
```

Then they need the un-committed files:

| File | From |
| --- | --- |
| `android/app/src/dev/google-services.json` (+ staging, production) | Firebase console, or a teammate's secure share |
| `ios/Runner/Firebase/dev/GoogleService-Info.plist` (+ staging, production) | same |
| `android/key.properties` + `upload-keystore.jks` | **only** if they build production release — from the team secret store |
| `dart_define/*.secret.json` | if any exist — from the team secret store |

To run all three flavors they only strictly need the **dev** Firebase files:

```bash
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_define/dev.json
```

iOS: `open ios/Runner.xcworkspace`, set their personal signing team on the
Runner target for the `*-dev` configs, run the `dev` scheme once.

---

## 10. Troubleshooting

**Installs with the wrong name / icon / Firebase project**

- Almost always a missing `--flavor` or wrong `-t`. All three flags must agree:
  `--flavor dev` + `-t lib/main_dev.dart` + `dart_define/dev.json`.
- Stale build: `flutter clean`, delete the app from the device, rebuild.
- Wrong icon on iOS only: the build config's `ASSETCATALOG_COMPILER_APPICON_NAME`
  isn't inheriting from the `.xcconfig` — re-check IOS_XCODE_SETUP step 2.
- Wrong Firebase project at runtime: print
  `FirebaseApp.instance.options.projectId` (or check
  `Firebase.app().options`) — if it's not the flavor's project, the wrong
  `google-services.json` / plist was bundled. Android: is the file in
  `src/<flavor>/`? iOS: did the Run Script phase run (grep the build log for
  `Firebase: using`)?

**A flavor won't build**

| Error | Fix |
| --- | --- |
| `Product Flavor <x> contains custom resource values, but the feature is disabled` | `buildFeatures { resValues = true }` is missing in `android/app/build.gradle.kts`. |
| `No matching client found for package name 'com.elhawary.algodive.dev'` | Add that package as an app in the dev Firebase project, or fix `android/app/src/dev/google-services.json`. |
| iOS `Building for iOS, but scheme "dev" not found` | Xcode schemes not created/shared — IOS_XCODE_SETUP steps 1–3, tick **Shared**. |
| iOS `error: .../Firebase/dev/GoogleService-Info.plist not found` | Drop the file in per FIREBASE_CHECKLIST, or the Run Script phase is matching the wrong `$CONFIGURATION`. |
| `FlavorConfig has not been initialized` at startup | The app was launched from `lib/main.dart` — use a `main_<flavor>.dart`. |
| App name shows `@string/app_name` literally | `resValue("string","app_name",…)` missing for that flavor, or a duplicate `app_name` in `src/main/res/values/strings.xml`. |
| Icons unchanged after editing base art | Re-run **both** `dart run tool/flavor_icons/generate_ribbon_icons.dart` **and** `dart run flutter_launcher_icons -f flutter_launcher_icons-dev.yaml`, then `flutter clean`. |

**Reset everything**

```bash
flutter clean
rm -rf build/ .dart_tool/
cd ios && rm -rf Pods Podfile.lock && pod install --repo-update && cd ..
flutter pub get
flutter run $DEV
```
