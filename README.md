<div align="center">

<!-- Logo: assets/logo/app-icon-512.png (see assets/logo/README.md for
     the full brand asset set — marks, lockups, favicons). It carries its
     own dark ground so it reads on both GitHub's light and dark themes. -->
<img src="assets/logo/app-icon-512.png" width="120" alt="AlgoDive"/>

# AlgoDive — Algorithm Visualizer

### Watch algorithms think.

An open-source Flutter app that turns sorting, pathfinding and 100 coding
challenges into something you can actually **see** — then lets you write the
code yourself, graded on-device, with no server and no internet.

[![CI](https://github.com/AhmedAbdoElhawary/flutter-algorithm-visualizer/actions/workflows/ci.yml/badge.svg)](https://github.com/AhmedAbdoElhawary/flutter-algorithm-visualizer/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.44.7-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)](#platform-support)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Stars](https://img.shields.io/github/stars/AhmedAbdoElhawary/flutter-algorithm-visualizer?style=social)](https://github.com/AhmedAbdoElhawary/flutter-algorithm-visualizer/stargazers)

**Coming soon to the stores**

<!-- TODO once published: replace the two shields below with the official badges.
     App Store  → https://developer.apple.com/app-store/marketing/guidelines/
     Play Store → https://play.google.com/intl/en_us/badges/                     -->
![App Store — coming soon](https://img.shields.io/badge/App_Store-coming_soon-000000?logo=apple&logoColor=white)
![Google Play — coming soon](https://img.shields.io/badge/Google_Play-coming_soon-414141?logo=googleplay&logoColor=white)

</div>

<p align="center"><img src="assets/preview/algodive-preview.png" width="800" alt="AlgoDive demo"/></p>

---

## Why AlgoDive

- **🧠 It runs your code — offline.** AlgoDive ships a handwritten interpreter
  (lexer → parser → AST → tree-walking evaluator). Your
  solution is parsed, executed and graded against real test cases **on the
  device**. No backend, no network, no cost per run.
- **👁️ Every frame explains itself.** Colors are *roles*, not static decoration.
- **🏗️ It is built like a shipping product, not a demo.** Three flavors, three
  isolated Firebase projects, tag-driven releases, and tests.

---

## Features

### 📊 Sorting visualizer

Six algorithms, step by step, with live complexity read-outs and playback
speeds. Every bar carries a **role** — comparing, swapping, target, done.

`Bubble` · `Selection` · `Insertion` · `Merge` · `Quick` · `Bucket`

<!-- ┌─────────────────────────────────────────────────────────────────┐
     │ SLOT 3 — SORTING GIF                                            │
     │ File : assets/screenshots/sorting.gif                           │
     │ Size : ~380 px wide (phone portrait) · under 5 MB               │
     │ Show : merge sort start to finish with the legend visible,      │
     │        then bump the speed control up to 5x.                    │
     └─────────────────────────────────────────────────────────────────┘ -->

### 🗺️ Pathfinding visualizer

A 30 × 24 grid you draw walls on with your finger. Watch the frontier expand
one cell per step, then watch the path get connected.

`BFS` · `DFS` · `A*`

<!-- ┌─────────────────────────────────────────────────────────────────┐
     │ SLOT 4 — PATHFINDING GIF   ⭐ your best-looking feature          │
     │ File : assets/screenshots/pathfinding.gif                       │
     │ Size : ~380 px wide · under 6 MB                                │
     │ Show : draw a wall maze with your finger, hit play on A*,       │
     │        let the path reveal all the way to the end.              │
     └─────────────────────────────────────────────────────────────────┘ -->

### ⌨️ Practice — 100 coding challenges

A from-scratch code editor runs Dart, JavaScript, and Python syntaxes.

<!-- ┌─────────────────────────────────────────────────────────────────┐
     │ SLOT 5 — EDITOR GIF                                             │
     │ File : assets/screenshots/editor.gif                            │
     │ Size : ~380 px wide · under 6 MB                                │
     │ Show : type (or paste) a solution, hit Run, land on             │
     │        "All tests passed" and the celebration screen.           │
     └─────────────────────────────────────────────────────────────────┘ -->

### 📈 Profile & progress & settings

A contribution-style heatmap, weekly activity chart, per-category breakdown,
difficulty progress, bookmarks, full practice history and settings.

<!-- ┌─────────────────────────────────────────────────────────────────┐
     │ SLOT 6 — PROFILE SHOTS (static PNGs are fine here)              │
     │ Files: assets/screenshots/profile-1.png, profile-2.png          │
     │ Size : ~280 px wide each, side by side                          │
     │ Show : the heatmap, then the weekly + category charts.          │
     └─────────────────────────────────────────────────────────────────┘ -->

---

## Getting started

### 1. Clone and install

```bash
git clone https://github.com/AhmedAbdoElhawary/flutter-algorithm-visualizer.git
cd flutter-algorithm-visualizer
flutter pub get
```

### 2. Create your local config files

This repo is **public**, so every credential and Firebase config file is
git-ignored on purpose. A fresh clone is missing them, and you create your own.

Only the **first row is required** to build — the rest are optional.

| File to create | Required? | What it is |
| --- | --- | --- |
| `android/app/src/dev/google-services.json` | ✅ **Required for Android** | Firebase config. The `google-services` Gradle plugin fails the build without it. |
| `ios/Runner/Firebase/dev/GoogleService-Info.plist` | ✅ Required for iOS | Same, for iOS. A build phase copies it into place per flavor. |
| `dart_define/dev.secret.json` | ➖ Optional | Sentry DSN. Without it, crash reporting is simply off. |
| `android/key.properties` | ➖ Optional | Release signing. Without it, release builds fall back to the debug key. |

<details>
<summary><b>How to create each one</b> (click to expand)</summary>

#### `google-services.json` — the only required file

1. Open the [Firebase console](https://console.firebase.google.com) → **Add project**
   (call it anything, the free Spark plan is enough).
2. Inside it, click **Add app → Android**.
3. Enter the package name exactly: `com.elhawary.algodive.dev`
4. Download the generated `google-services.json`.
5. Put it at `android/app/src/dev/google-services.json`.

In the Firebase console, enable **Authentication → Email/Password** and create a
**Cloud Firestore** database if you want sign-in and cloud sync to work.

> **Why isn't it committed?** It ties the build to *my* Firebase project. Yours
> should point at your own, and a public repo is the wrong place for either.

#### `GoogleService-Info.plist` — iOS only

Same flow, but choose **Add app → iOS** with bundle id `com.elhawary.algodive.dev`,
then save the file to `ios/Runner/Firebase/dev/GoogleService-Info.plist`.
`ios/scripts/firebase_config.sh` runs as an Xcode build phase and copies the
right flavor's plist into place automatically.

#### `dart_define/dev.secret.json` — optional

Create the file with this shape:

```json
{
  "SENTRY_DSN": "https://<your-key>@o0.ingest.sentry.io/<project>"
}
```

Leave it out entirely and the app runs fine — crash reporting is release-only
anyway. See [`dart_define/README.md`](dart_define/README.md) for why config is
split into committed selectors vs. git-ignored secrets, and why this project
deliberately does **not** use `flutter_dotenv`.

#### `android/key.properties` — optional, release builds only

```properties
storePassword=<your password>
keyPassword=<your password>
keyAlias=upload
storeFile=/absolute/path/to/your/upload-keystore.jks
```

Generate a keystore with:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Without this file, `flutter build apk --release` still works — it just falls
back to the debug signing key. **Never commit the keystore or this file.**

#### For the other flavors

Repeat step 1 with the matching package name and folder:

| Flavor | Package name | Config goes in |
| --- | --- | --- |
| `dev` | `com.elhawary.algodive.dev` | `android/app/src/dev/` |
| `staging` | `com.elhawary.algodive.staging` | `android/app/src/staging/` |
| `production` | `com.elhawary.algodive` | `android/app/src/production/` |

</details>

### 3. Run it

```bash
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_define/dev.json
```

That's it. No `.env`, no backend to start, no seed data.

VS Code and Android Studio run configurations are committed too, so you can
also just press **F5** and pick `dev (debug)`.

<details>
<summary><b>All three flavors</b></summary>

| Flavor | Entry point | Config | Application ID | Firebase project |
| --- | --- | --- | --- | --- |
| `dev` | `lib/main_dev.dart` | `dart_define/dev.json` | `com.elhawary.algodive.dev` | `algodive-dev` |
| `staging` | `lib/main_staging.dart` | `dart_define/staging.json` | `com.elhawary.algodive.staging` | `algodive-staging` |
| `production` | `lib/main_prod.dart` | `dart_define/prod.json` | `com.elhawary.algodive` | `algodive-prod` |

```bash
flutter run --flavor staging    -t lib/main_staging.dart --dart-define-from-file=dart_define/staging.json
flutter run --flavor production -t lib/main_prod.dart    --dart-define-from-file=dart_define/prod.json
```

Dev and staging installs carry a **ribbon on the launcher icon**, so you always
know which build you're holding.

</details>

<details>
<summary><b>Something went wrong?</b></summary>

| Symptom | Cause | Fix |
| --- | --- | --- |
| `File google-services.json is missing` | Step 2 was skipped | Create `android/app/src/dev/google-services.json` |
| `No matching client found for package name` | Package name typo in Firebase | It must be exactly `com.elhawary.algodive.dev` |
| `FlavorConfig has not been initialized` | Ran without `--dart-define-from-file` | Use the full run command above |
| `Flavor 'dev' is not supported` | Missing `--flavor dev` | Flavor **and** entry point are both required |
| Sign-in fails, everything else works | Firebase Auth not enabled | Enable Email/Password in the Firebase console |

</details>

---

## Under the hood

<details open>
<summary><b>Project structure</b></summary>

```
lib/
├── config/
├── core/
│   ├── flavor/
│   ├── monitoring/
│   ├── widgets/
│   ├── custom_packages/
│   │   └── custom_code_editor/
│   ├── resources/
│   └── storage/
└── features/
    ├── visualize/
    ├── challenge/
    ├── auth/
    ├── home/
```

Feature-first, with full clean-architecture layering (`data` → `domain` → `presentation`) on the mature slices and a
lighter MVVM shape on the simpler ones.

</details>

<details>
<summary><b>The interpreter — how offline grading works</b></summary>

`lib/core/custom_packages/custom_code_editor/src/execution/`

```
lexer.dart (271 L) → parser.dart (775 L) → ast.dart (256 L) → interpreter.dart (865 L)
```

A complete tree-walking interpreter with:

- **Closures** — functions capture their declaring scope
- **Non-local control flow** via internal return / break / continue signals
- **Line-accurate errors** — `InterpreterError` points at the offending line
- **Infinite-loop protection**, so a runaway `while (true)` can't freeze the app

Paired with a grading engine in `src/testcase/` that parses arbitrary literal
inputs and **constructs custom object shapes** — so a problem can hand your
function a real linked-list head or binary-tree root.

</details>

<details>
<summary><b>Release engineering</b></summary>

**Tags ship. Merges don't.**

| Tag | Environment | Flavor | Ships via |
| --- | --- | --- | --- |
| `v1.3.0-dev.2` | development | dev | `flutter build apk` → Firebase App Distribution |
| `v1.3.0-stag.1` | staging | staging | `flutter build apk` → Firebase App Distribution |
| `v1.3.0` | production | production | **Shorebird release** → App Distribution + GitHub Release |

The promotion ladder is `develop → staging → production`, enforced twice: by a
`merge-guard` CI job and by the release runbook. `production` never accepts a
merge from `develop` directly.

The deployment pipeline resolves the environment from the tag shape, proves with
`git merge-base --is-ancestor` that the tag really sits on its branch, runs
analyze + tests, **verifies the built APK is not debug-signed** via
`apksigner --print-certs`, and scrubs injected secrets with `if: always()`.
A production tag pauses for human approval before it builds.

Shorebird code push is enabled for production only, so a Dart-only bug fix can
reach users without waiting on a store review.

</details>

<details>
<summary><b>Testing</b></summary>

**40 test files · 347 tests · 81 groups** — unit, widget and contract tests.

```bash
flutter test --dart-define-from-file=dart_define/dev.json
```

A few worth opening:

| File | What it proves |
| --- | --- |
| `test/visualize/searching/search_role_contrast_test.dart` | Implements WCAG relative luminance **and** CIE ΔE\*ab from scratch to assert every grid role color is perceptually distinguishable |
| `test/visualize/searching/support/search_contract.dart` | One shared playback contract, run against BFS, DFS and A\* alike |
| `test/visualize/searching/search_role_test.dart` | Role mapping is a **total** function — no `default` case, no silent fallback |
| `test/challenge/editor/` | 8 files covering editor actions, layout, scroll, run, submission and contrast |

</details>

---

## Roadmap

### ✅ Live now

| Category | Algorithms |
| --- | --- |
| **Sorting** | Bubble · Selection · Insertion · Merge · Quick · Bucket |
| **Pathfinding** | BFS · DFS · A\* |
| **Practice** | 100 coding challenges with on-device grading |

### 🗓️ Planned

| Category         | Items                                                                          |
|------------------|--------------------------------------------------------------------------------|
| **Sorting**      | Heap Sort · Shell Sort · Radix Sort · Counting Sort                             |
| **Graphs**       | Dijkstra · Bellman-Ford · Topological sort                                     |
| **Mazes**        | Recursive division · Randomized Kruskal · Eller's · Aldous-Broder · Binary tree|
| **Trees**        | BST · AVL · Red-Black · Segment tree · B-Tree                                  |
| **Linked lists** | Singly · Doubly · Circular                                                     |
| **Later**        | Dynamic programming · String algorithms · side-by-side algorithm comparison    |

---

## Platform support

Android and iOS are the shipping targets. Android is fully wired for release;
iOS builds in CI as an unsigned smoke test while release signing is being set
up. Later, will be looking to others.

---

## Contributing

Contributions are genuinely welcome — especially **new algorithms**.

The four sorts under *"Built, not yet wired into the UI"* are the easiest
possible entry point: the algorithm is already written and tested, and all
that's missing is the card and the wiring.

**[CONTRIBUTING.md](CONTRIBUTING.md)** covers setup, the branch model, the
project's coding conventions, and a step-by-step walkthrough for adding a new
algorithm.

- 🐛 [Report a bug](https://github.com/AhmedAbdoElhawary/flutter-algorithm-visualizer/issues/new?template=bug_report.yml)
- 💡 [Request a feature](https://github.com/AhmedAbdoElhawary/flutter-algorithm-visualizer/issues/new?template=feature_request.yml)
- 🧮 [Request an algorithm](https://github.com/AhmedAbdoElhawary/flutter-algorithm-visualizer/issues/new?template=algorithm_request.yml)
- 🔒 [Security policy](SECURITY.md)
- 🤝 [Code of conduct](CODE_OF_CONDUCT.md)

---

## License

Licensed under the **Apache License 2.0** — see [LICENSE](LICENSE).

---

## Author

**Ahmed Abdo Elhawary** — [@AhmedAbdoElhawary](https://github.com/AhmedAbdoElhawary)

<div align="center">

**If AlgoDive helped you understand an algorithm, a ⭐ helps someone else find it.**

</div>
