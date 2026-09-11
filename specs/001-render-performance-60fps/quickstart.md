# Quickstart: Validating Render Performance

**Feature**: 001-render-performance-60fps | **Date**: 2026-09-11

How to run the two harnesses and read a pass/fail. This is a validation guide — implementation lives in `tasks.md`.

---

## Prerequisites

**1. The Oppo A5i, connected and recognised.**

```bash
flutter devices
```

**What it does:** lists attached devices. The A5i must appear. Every gating number in this feature comes from this device — an emulator will not do, because emulated GPUs do not represent blur cost.

**Device id**: `d657602c` (Oppo A5i, model `CPH2773`, Android 14 / API 34). Use this id wherever `<a5i-device-id>` appears below.

**2. `integration_test` added to `dev_dependencies`.**

```bash
flutter pub add --dev integration_test --sdk=flutter
```

**What it does:** adds the Flutter SDK's integration-test package. It is dev-only and never ships in the app.

**3. A launchable flavor.** `lib/main.dart` is not launchable in this project — use a flavor entry point (`lib/main_dev.dart`, `lib/main_staging.dart`, or `lib/main_prod.dart`).

---

## Order matters — read this first

The **"before" captures must happen on an unmodified tree**, before the first optimisation commit.

Once rendering code changes, the original appearance and the original frame numbers are gone. There is no way to recover them later. If you skip this step, FR-009 and FR-016 become permanently unverifiable.

```text
1. Record goldens          (unmodified tree)
2. Record "before" perf    (unmodified tree)
3. Device screenshots      (unmodified tree)
   ─────────── only now start optimising ───────────
4. Fix root causes, re-running goldens after each
5. Record "after" perf and compare
```

---

## Step 1 — Record the golden references

```bash
flutter test test/golden --update-goldens
```

**What it does:** renders each of the 28 surfaces in [contracts/golden-inventory.md](./contracts/golden-inventory.md) and writes the reference PNGs to `test/golden/goldens/`.

**Expected outcome:** 28 PNGs created and committed. Run the command a second time *without* `--update-goldens` — it must pass with zero differences. If it does not, a golden is non-deterministic and must be fixed before proceeding (see the determinism rules in the inventory contract).

> ⚠️ After this point, `--update-goldens` is effectively banned. A golden that needs updating is a **failed change** (FR-009c), not a golden to re-record.

---

## Step 2 — Capture the "before" performance baseline

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/perf_driver.dart \
  --profile --flavor dev -d <a5i-device-id> \
  --dart-define-from-file=dart_define/dev.json
```

> ⚠️ **`--flavor dev` is required.** This project has no unflavored build — omitting it makes Gradle build a variant the tool then can't find, and the build fails after several minutes with "Gradle build failed to produce an .apk file." Always pair a flavor with its matching `--dart-define-from-file` (`dev.json` for `dev`, etc.).

**What it does:** drives each scenario on the device in profile mode and writes a report matching [contracts/perf-report.schema.json](./contracts/perf-report.schema.json).

> ⚠️ **It must be `flutter drive`, not `flutter test`.** `watchPerformance` accumulates timings in memory (`reportData`); only the driver's `responseDataCallback` writes them to disk. Running `flutter test integration_test/...` executes the scenario, reports a green pass, and produces **no file at all** — which would silently lose the irreplaceable "before" capture.

**Expected outcome:** a `before` report committed alongside the spec. Expect it to **fail** the gates — that is the point. It documents the problem you are fixing.

Check the report records `"device": "oppo-a5i"` and `"buildMode": "profile"`. A `debug` value invalidates the whole run.

> ⚠️ **Move the report immediately — `build/` is gitignored.** `writeResponseData` (the driver's default `responseDataCallback`) writes to `build/integration_response_data.json`. That path is inside `.gitignore`, and `flutter clean` deletes it outright. Copy it to `specs/001-render-performance-60fps/baselines/before.json` (or `after.json` in Step 4) and commit it from there — do not leave the irreplaceable "before" capture sitting only in `build/`.

---

## Step 3 — Device screenshot backstop

Capture all five main screens, both themes, on the A5i. Store them in `baselines/screenshots-before/`.

**Why:** goldens render on the host test renderer and cannot prove the device GPU's blur output is unchanged. This one-time comparison is the backstop.

**How the comparison is made (once, after the last optimisation — task T059):**

```bash
python3 tool/compare_screenshots.py \
  specs/001-render-performance-60fps/baselines/screenshots-before \
  specs/001-render-performance-60fps/baselines/screenshots-after \
  --diff-dir /tmp/shot-diffs
```

**What it does:** crops the top 4% of each image (the status-bar clock and battery icon change between captures and are not app pixels), then compares the rest pixel by pixel. It prints a differing-pixel count per pair and exits non-zero if any pair is over tolerance.

Use identical filenames in both directories — pairs are matched by name, and a file present in only one side is reported, not skipped.

**Detection is exact and free; explanation is not.** A pair reporting `0 px` is proven unchanged and **must not be opened by a person or a model** — that is the whole point of the script. Only pairs the script flags get looked at, and then the `--diff-dir` heatmap is what you look at first: it is downscaled and shows only where the pixels moved.

> **Two pairs will always flag, and that is expected.** The Home particle ticker and the aurora background are mid-animation at capture time, so their device screenshots never match exactly. Judge those two by eye against the *design*, not against a pixel count. Every other pair should report `0 px`.

---

## Step 4 — Validate after each fix

Run these three after **every** optimisation change, not just at the end:

```bash
# 1. Nothing looks different
flutter test test/golden

# 2. Nothing behaves differently
flutter test

# 3. Something got faster
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/perf_driver.dart --profile --flavor dev -d <a5i-device-id> \
  --dart-define-from-file=dart_define/dev.json
```

**Expected outcome:** goldens pass with zero pixel difference, all 7 existing unit tests still pass, and frame numbers improve.

**If a golden fails:** the change altered appearance. Revert or fix the change — do not re-record the golden.

---

## Step 5 — Rebuild-count check (SC-004)

```bash
flutter test test/visualize/sorting/rebuild_count_test.dart
```

**What it does:** applies one isolated state change (a single bar swap) and counts how many widgets rebuilt.

**Expected outcome:** the "after" count is at most **20%** of the "before" count. This test needs no device — rebuild counts are hardware-independent.

---

## Reading a pass

A run passes when **all** of these hold:

| Gate | Requirement | Spec |
|---|---|---|
| Steady-state over-budget frames | `0` on all five screens | SC-001 |
| Sorting run | `0` dropped frames at fastest speed, max array size | SC-002 |
| 99th-percentile frame time | `< 16.67 ms` on every target screen | SC-003 |
| Rebuild count | reduced by `>= 80%` | SC-004 |
| Idle screens | zero rendering work (Home's ambient ticker excepted — see research R6) | SC-005 |
| Tab switch | `< 300 ms`, no over-budget frames | SC-006 |
| Goldens | 28/28 pass, zero pixel difference | SC-007 |
| Warm device | targets hold after a 10-minute soak | SC-008 |
| Existing tests | all 7 still pass | SC-009 |
| Warm-up allowance | `<= 5` over-budget frames, none `> 100 ms`, settled within `500 ms` | SC-011 |

---

## Troubleshooting

**Goldens differ on a machine that didn't change any code.**
Font loading or device pixel ratio is drifting. Check `google_fonts` is not fetching over the network during tests, and that each golden pins its surface size.

**`screen.home` golden never matches twice.**
The particle `Ticker` in `movable_pins.dart` is still running. Pump to a fixed elapsed time or stub it.

**Frame numbers swing wildly between runs.**
The device is thermally throttling, or another app is competing. Let it cool, close background apps, and note `thermalState` in the report. A deliberate warm run is a separate, labelled measurement (SC-008) — not a substitute for the cold one.

**Grouped blur looks wrong where the nav bar overlaps content.**
Expected, and documented: overlapping backdrop filters must not share a backdrop key. The floating nav bar must be excluded from any page-content `BackdropGroup` (research R3).

---

## If the target proves unreachable

If the A5i cannot hit 60 FPS with appearance held pixel-identical, **do not lower the blur or drop glass layers to make the number pass.** FR-009a governs: report the shortfall with measurements attached, and get explicit approval before any visual change.

Surfacing this early is why Steps 1–3 come first.
