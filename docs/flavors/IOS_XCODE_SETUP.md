# iOS — per-flavor Xcode setup

**Status: done.** `project.pbxproj` and the 3 shared schemes were generated
with the `xcodeproj` Ruby gem (the same library CocoaPods/fastlane use to
edit Xcode projects programmatically) rather than by hand in the Xcode GUI —
safer than text-editing the `.pbxproj` file directly, with the same end
result. Recorded here so the next person knows what exists and why, and can
redo it the same way if the project file ever needs to be regenerated.

## What exists now

**12 build configurations** on the `Runner` target — the original `Debug` /
`Release` / `Profile` (kept, default to the production identity, used by
CI's schemeless smoke build) plus 9 flavored ones (`Debug-dev`,
`Release-dev`, `Profile-dev`, and the same for `staging` / `production`),
each pointed at its matching `ios/Flutter/<Config>-<flavor>.xcconfig`. The
same 9 names exist on `RunnerTests` too (no xcconfig needed there — tests
aren't flavored) and at the project level, matching what Xcode's own
"Duplicate Configuration" does.

**3 shared schemes** — `dev`, `staging`, `production` — under
`ios/Runner.xcodeproj/xcshareddata/xcschemes/`, generated from the existing
`Runner.xcscheme` with each action's `buildConfiguration` swapped to the
matching flavor (e.g. the `dev` scheme's Launch/Test/Analyze actions use
`Debug-dev`, Profile uses `Profile-dev`, Archive uses `Release-dev`).
`flutter run --flavor dev` finds the `dev` scheme automatically by name.

**One Run Script build phase**, `Firebase config (per flavor)`, added to the
`Runner` target as the **first** build phase — before Sources, Frameworks,
and Resources. It runs `ios/scripts/firebase_config.sh`, which reads
`$CONFIGURATION` and copies `ios/Runner/Firebase/<flavor>/GoogleService-Info.plist`
on top of `ios/Runner/GoogleService-Info.plist` — see that script for the
exact logic. "Based on dependency analysis" is off (`always_out_of_date`), so
it runs on every build. It also declares that plist as its **output path**
(`$(SRCROOT)/Runner/GoogleService-Info.plist`).

That output declaration isn't optional — this was the second real bug this
ran into. `ios/Runner/GoogleService-Info.plist` is git-ignored *and* already
registered as a Copy Bundle Resources input (it was added to the project
before this work, presumably by hand once). Xcode's build system validates
every build phase's declared inputs **before running anything** — phase
*order* doesn't help here, because the check isn't "did an earlier phase run
yet," it's "does this input exist on disk, or is it declared as some phase's
output." Without the output declaration, a completely fresh clone (where the
git-ignored file doesn't exist yet) fails immediately with:

```
Build input file cannot be found: '.../ios/Runner/GoogleService-Info.plist'.
Did you forget to declare this file as an output of a script phase...?
```

— which is literally Xcode telling you the fix. Verified by deleting the
file and rebuilding from nothing, for both `dev` and `staging`.

**Bundle ids fixed** — the base `Runner` target was still the Flutter
template default `com.example.algorithmVisualizer`; now `com.elhawary.algodive`
(matching the production identity, since the base configs stay in play for
the schemeless build). `RunnerTests` likewise moved from
`com.example.algorithmVisualizer.RunnerTests` to
`com.elhawary.algodive.RunnerTests`.

**One xcconfig bug fixed** — `Profile-dev.xcconfig`, `Profile-staging.xcconfig`
and `Profile-production.xcconfig` all `#include`d a `Profile.xcconfig` that
never existed anywhere in the repo (silent build failure waiting to happen).
Changed to `#include "Release.xcconfig"`, matching how the base (unflavored)
`Profile` configuration already resolves — Flutter's default template has no
separate `Profile.xcconfig`; Profile reuses Release's settings.

**A real pitfall this ran into, worth knowing:** the base `Debug`/`Release`/
`Profile` configurations had `PRODUCT_BUNDLE_IDENTIFIER` and
`ASSETCATALOG_COMPILER_APPICON_NAME` set as *inline* build settings (not just
via xcconfig). Duplicating a configuration copies its inline settings too —
and an inline setting always wins over one from an `#include`d xcconfig. So
the first pass silently gave every flavor the production bundle id and icon,
despite each flavor's own `.xcconfig` saying otherwise. Fix: those two keys
were deleted from the 9 flavor-specific configs' inline settings so the
xcconfig value actually applies. If you ever duplicate a configuration by
hand again, check for this — anything set inline on the config you duplicated
silently shadows the same key from an included xcconfig.

## Now unnecessary: `scripts/run_ios.sh`

That script existed as a stand-in for exactly this Run Script phase, back
when Xcode wasn't wired for flavors. Now that the real build phase does the
copy automatically, `scripts/run_ios.sh` duplicates it — safe to delete.
Plain `flutter run --flavor <dev|staging|production>` is enough.

## Verify

```bash
flutter build ios --debug --no-codesign --flavor dev        -t lib/main_dev.dart     --dart-define-from-file=dart_define/dev.json
flutter build ios --debug --no-codesign --flavor staging    -t lib/main_staging.dart --dart-define-from-file=dart_define/staging.json
flutter build ios --debug --no-codesign --flavor production -t lib/main_prod.dart    --dart-define-from-file=dart_define/prod.json
```

**Done and verified for real** — all three built successfully
(`✓ Built build/ios/iphoneos/Runner.app`), including a fresh-clone
simulation (deleting the git-ignored `ios/Runner/GoogleService-Info.plist`
first) for `dev` and `staging`.

The script's own `echo "Firebase: using ..."` line does **not** show up in
`flutter build`'s default-verbosity output — don't rely on the build log.
Verify the actual bundled config instead (Xcode converts it to binary plist
format, so `grep` on it won't work either):

```bash
plutil -p build/ios/iphoneos/Runner.app/GoogleService-Info.plist | grep -i "project_id\|bundle_id"
```

Confirmed matching per flavor: `com.elhawary.algodive.dev` / `algodive-dev`,
`com.elhawary.algodive.staging` / `algodive-staging`,
`com.elhawary.algodive` / `algodive-prod`.

**A third, unrelated bug surfaced while verifying**: `sentry_flutter`
8.14.2's Swift code called a `sentry-cocoa` API that was renamed at cocoa
version 8.56.0 (`image(byAddress:)` → `imageByAddress(_:)`, when that class
was rewritten from Objective-C to pure Swift). Since `sentry_flutter`
declared an unbounded `from: "8.46.0"` dependency, Swift Package Manager
kept resolving the newest 8.x and broke **every** iOS build regardless of
flavor — this predated the flavor work entirely, and it turned out to have
an Android twin (see below). First worked around by pinning `sentry-cocoa`
to `8.55.1`; superseded by the real fix — upgrading `sentry_flutter` itself
(see the Android section). After any Package.resolved change, run
`flutter clean` once — a stale precompiled module cache will otherwise
reject the changed framework with a "modified since... was built" error.

**A fourth bug, this time on Android**: `sentry_flutter` 8.14.2's own
`android/build.gradle` hardcoded `kotlinOptions { languageVersion = "1.6" }`
— rejected outright by this project's Kotlin (2.3.20), which requires 2.0+.
No 8.x patch exists (8.14.2 is the newest). Fixed by upgrading
`sentry_flutter` to `^9.29.0`, whose `android/build.gradle` drops the
`languageVersion` override entirely. That release also pins `sentry-cocoa`
to an **exact** `8.58.4` (its Swift code matches that cocoa version's new
API), so `Package.resolved`'s `8.55.1` workaround was reverted back to
`8.58.4` in both files — a version bump replaces the pin, it doesn't stack
with it. Also bumped `pubspec.yaml`'s `environment.sdk` floor to `3.5.0`
(9.x's own minimum). Checked `lib/core/monitoring/` against 9.x's breaking
changes first — none of the removed/renamed APIs are used there, and
`flutter analyze` came back clean. Verified with a real build on both
platforms after the upgrade.

## Commit

```bash
git add ios/Runner.xcodeproj/project.pbxproj \
        ios/Runner.xcodeproj/xcshareddata/xcschemes/ \
        ios/Flutter/Profile-dev.xcconfig ios/Flutter/Profile-staging.xcconfig ios/Flutter/Profile-production.xcconfig \
        ios/scripts/firebase_config.sh \
        ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved \
        ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
git rm scripts/run_ios.sh   # only once you've deleted it
```

Then switch the iOS job in `.github/workflows/ci.yml` to a flavored build —
its comment already notes where.
