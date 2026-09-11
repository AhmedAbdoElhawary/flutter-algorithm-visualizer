# Implementation Plan: Render Performance — Smooth 60 FPS Across the App

**Branch**: `001-render-performance-60fps` | **Date**: 2026-09-11 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-render-performance-60fps/spec.md`

## Summary

The app drops frames on all five main tab screens. Profiling the code surfaced four concrete, independent root causes — every one of them fixable **without changing a single pixel**:

1. **N backdrop blurs in a scrolling list.** `ProblemTile` wraps every Practice-list row in a `GlassContainer`, and each `GlassContainer` is a `BackdropFilter`. Ten visible rows means ten separate backdrop reads and save-layers per frame. Flutter 3.44.7 ships `BackdropGroup` / `BackdropFilter.grouped` for exactly this case, and its documentation states the grouped result is "visually identical to multiple blurs".
2. **An unbounded per-pixel loop in the background painter.** `_AuroraPainter` draws the dot grid with one `drawCircle` per grid cell (~6,800 calls on a 720×1600 screen) plus two full-screen `MaskFilter.blur` radial bands — and sits in a `Stack` with **no `RepaintBoundary`**, so it repaints whenever anything above it repaints. The whole app contains only **2** `RepaintBoundary` widgets today.
3. **O(N²) rebuilds in the sorting view.** `_ShowUpSortingListState.build` calls `ref.watch(...positions[item.id])` *inside* its `List.generate` loop, so the parent subscribes to all N bar positions. One bar moving rebuilds all N bars.
4. **A permanently-blurred nav bar over every tab.** The floating `GlassContainer` nav sits in a `Stack` above scrolling content, forcing a backdrop re-read on every scrolled frame.

The approach is: **measure first, fix by evidence, prove nothing changed.** Build the golden suite and capture the "before" numbers before touching any rendering code (a hard sequencing constraint — once the code changes, the original appearance and timings are unrecoverable), then fix the four causes in priority order, re-measuring after each.

## Technical Context

**Language/Version**: Dart 3.12.2 / Flutter 3.44.7 (stable). Project SDK constraint `>=3.5.0 <4.0.0`.

**Primary Dependencies**: `flutter_riverpod` ^3.4.2 (state), `go_router` ^17.5.0 (`StatefulShellRoute` for the five tabs), `flutter_screenutil` ^5.9.3 (sizing), `fl_chart` ^1.2.0 (Profile charts), `google_fonts` ^8.2.1.

**Storage**: `get_storage` (local) + `cloud_firestore` (remote). **Not touched by this feature.**

**Testing**: `flutter_test` today (7 test files, all unit/provider — no visual and no performance tests). This feature adds two new harnesses: `integration_test` (Flutter SDK package, needs adding to `dev_dependencies`) for frame timings, and `matchesGoldenFile` golden tests for the pixel-identity gate.

**Target Platform**: Android is the gating platform. Baseline device **Oppo A5i**, release/profile build. iOS and desktop must not regress but are not measured for pass/fail.

**Project Type**: Flutter mobile app (multi-flavor: dev / staging / production).

**Performance Goals**: 60 FPS sustained (16.67 ms budget). Zero over-budget frames in steady state on all five main screens and through a full sorting run. Warm-up excluded from the gate but measured against the SC-011 allowance.

**Constraints**:
- **Pixel-identical appearance is a hard constraint** (FR-009). No cheaper blur, no dropped glass layers, no simplified background.
- Golden references and "before" timings **must be captured before the first optimisation commit**.
- No CI gating on hosted runners — they have no real GPU, so their frame numbers are meaningless (FR-019).

**Scale/Scope**: 5 main tab screens + ~11 secondary screens. 24 `GlassContainer` call sites. ~47 unscoped state-watch call sites vs 53 scoped. 2 `RepaintBoundary` widgets app-wide.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| # | Principle | Verdict | Notes |
|---|-----------|---------|-------|
| I | Widget classes, not function builders | **PASS** | New widgets (`AuroraGroundCached`, grouped-blur wrappers, per-bar `Consumer` widgets) are all `StatelessWidget`/`ConsumerWidget` classes. No private `_buildX()` helpers. |
| II | Core adaptive Text & Padding only | **PASS** | This work adds no user-facing text. Any padding introduced uses the directional adaptive widgets. Note: `GlassContainer.padding` is a *parameter*, not a raw `Padding` widget — unchanged. |
| III | Responsive sizing via ScreenUtil | **PASS** | No new hard-coded dimensions. Blur sigmas stay as the existing `CdBlur` constants — unchanged values, since changing them would break FR-009. |
| IV | Theme colors via ThemeEnum only | **PASS** | Caching must not freeze a resolved `Color`. Cache keys include the resolved theme colours so a light/dark switch invalidates the cache (FR-012). |
| V | Centralized strings via StringsManager | **PASS** | No new user-facing strings. Test/report identifiers are not user-facing copy. |
| VI | Scoped state watching (`.select()`) | **PASS — and directly advanced** | Root cause 3 is a Principle VI violation in `sorting_view.dart`. FR-005a/b/c scope the cleanup to profiling-implicated sites; FR-005c forbids introducing new broad watches. |
| VII | Consistency with existing code (NON-NEGOTIABLE) | **PASS with one declared addition** | See Complexity Tracking — `integration_test` is a new dev dependency. It is a first-party Flutter SDK package, dev-only, never shipped. Declared here rather than introduced silently. |

**Additional project rules checked:**

- **Public repo / secrets**: this feature adds no configuration and no credentials. Golden PNGs and performance JSON contain no sensitive data. No `.env`. **PASS**
- **Flavors**: measurement runs against an existing flavor entry point (`main_dev.dart` or `main_prod.dart`); `lib/main.dart` is not launchable and is not used. No flavor configuration is modified. **PASS**
- **Commit attribution**: no AI-attribution trailers. **PASS**

**Gate result: PASS.** One declared deviation, recorded in Complexity Tracking. No unjustified violations.

## Project Structure

### Documentation (this feature)

```text
specs/001-render-performance-60fps/
├── plan.md              # This file
├── research.md          # Phase 0 output — root-cause analysis & technique decisions
├── data-model.md        # Phase 1 output — measurement record shapes & budgets
├── quickstart.md        # Phase 1 output — how to run the harnesses
├── contracts/
│   ├── perf-report.schema.json   # Machine-readable performance output contract
│   └── golden-inventory.md       # The exact golden surface list (FR-009b)
├── checklists/
│   └── requirements.md  # Spec quality checklist (complete)
└── tasks.md             # Created by /speckit-tasks — NOT by this command
```

### Source Code (repository root)

```text
lib/
├── core/widgets/custom_widgets/
│   └── glass_card.dart              # GlassContainer, GlassTrack, AuroraGround, _AuroraPainter
│                                    # → root causes 1, 2 and 4 all live here
├── features/
│   ├── base/view/
│   │   └── base_navigation.dart     # Floating glass nav over every tab (root cause 4)
│   ├── challenge/presentation/
│   │   ├── view/challenge_page.dart         # SliverList of glass tiles (root cause 1)
│   │   └── widgets/challenges/problem_tile.dart
│   ├── visualize/
│   │   ├── sub_view/sorting/view/sorting_view.dart   # O(N²) rebuilds (root cause 3)
│   │   └── widgets/grid_squares_view.dart            # Second per-cell painter loop
│   ├── home/view/
│   │   ├── home_page.dart
│   │   └── movable_pins.dart        # Continuous particle Ticker — see research R6
│   └── profile/presentation/        # fl_chart widgets + heatmap
│
test_driver/                         # NEW — REQUIRED to get timings onto disk (FR-022)
└── integration_test.dart            # integrationDriver(responseDataCallback:) writes the JSON
│
integration_test/                    # NEW — automated frame-timing harness
├── perf_driver.dart                 # Timeline capture entry point
├── support/
│   ├── perf_budgets.dart            # Single source of truth for every threshold
│   ├── perf_models.dart             # FrameSample, FrameStats
│   ├── perf_report.dart             # ScenarioReport, PerformanceBaseline
│   ├── phase_classifier.dart        # warm-up → steady-state rule (FR-021)
│   └── compare_baselines.dart       # Regression check (FR-017)
└── scenarios/
    ├── scroll_main_screens_test.dart
    ├── sorting_run_test.dart
    └── tab_switch_test.dart
│
test/
├── golden/                          # NEW — pixel-identity gate (FR-009b)
│   ├── support/golden_harness.dart  # Determinism rules
│   ├── glass_container_golden_test.dart
│   ├── aurora_ground_golden_test.dart
│   ├── main_screens_golden_test.dart
│   └── goldens/                     # Reference PNGs, committed
├── perf/perf_report_schema_test.dart          # NEW — schema conformance
├── visualize/sorting/rebuild_count_test.dart  # NEW — SC-004 metric
└── (7 existing unit/provider tests, unchanged)
│
.github/workflows/ci.yml             # MODIFIED — exclude goldens on Linux (FR-019a),
                                     # run them on macOS (FR-019b)
```

**Two structural facts worth stating plainly** (both surfaced by cross-artifact analysis, not by the original design pass):

1. **`test_driver/` is not optional.** `IntegrationTestWidgetsFlutterBinding.watchPerformance` accumulates results in `reportData` **in memory**. Running `flutter test integration_test/...` on a device executes the scenario but never writes a report. Getting JSON onto disk requires `flutter drive` with a driver that calls `integrationDriver(responseDataCallback: ...)`. Without this file, the irreversible "before" capture silently produces nothing.
2. **`ci.yml` must change before goldens are committed.** The PR quality gate runs `flutter test` on `ubuntu-latest` (ci.yml:78) while goldens are recorded on macOS. Golden PNGs are platform-specific — font rasterisation differs — so committing 28 goldens without excluding them from that job turns every PR red.

**Structure Decision**: The existing `lib/` feature-first layout is kept exactly as-is — this feature modifies widgets in place rather than restructuring. Two new top-level test directories are added: `integration_test/` (required by convention; the Flutter tool only recognises performance/e2e tests there) and `test/golden/` (grouped under the existing `test/` root, matching the current per-feature subdirectory convention).

## Complexity Tracking

> Filled because Constitution Check Principle VII requires declaring new packages rather than introducing them silently.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| New dev dependency: `integration_test` (Flutter SDK package) | FR-015 requires an automated suite producing machine-readable per-screen frame timings, and FR-017 requires regression detection against committed baselines. `integration_test` + `IntegrationTestWidgetsFlutterBinding.watchPerformance` is the only first-party way to capture real on-device frame timings. | Manual DevTools profiling alone was explicitly rejected in clarification Q1 — it is not repeatable and cannot gate a regression. A third-party benchmarking package would be a *larger* Principle VII deviation than a first-party SDK package that ships with Flutter and is dev-only. |
| Two new test directories (`integration_test/`, `test/golden/`) | The repo has no visual or performance test infrastructure (7 test files, all unit). Both harnesses are net-new. | Reusing `test/` for integration tests does not work — the Flutter tool requires `integration_test/` for on-device runs. |

**Not a deviation**: `BackdropGroup` / `BackdropFilter.grouped` are core `flutter/widgets` APIs already present in the pinned Flutter 3.44.7 (verified at `packages/flutter/lib/src/widgets/basic.dart:469`). No dependency change; no new architecture.

## Phase 0 — Research

Complete. See [research.md](./research.md) for the full root-cause analysis and the decision record for each technique (R1–R8), including the one genuinely open risk: whether the Oppo A5i can sustain grouped real-time blur at 60 FPS while staying pixel-identical.

## Phase 1 — Design & Contracts

Complete. Artifacts:

- [data-model.md](./data-model.md) — the measurement record shapes (frame samples, per-screen reports, baselines, rebuild counts) and the budget constants.
- [contracts/perf-report.schema.json](./contracts/perf-report.schema.json) — the machine-readable performance report contract that FR-015/FR-017 compare against.
- [contracts/golden-inventory.md](./contracts/golden-inventory.md) — the exact, enumerated golden surface list satisfying FR-009b.
- [quickstart.md](./quickstart.md) — how to run both harnesses and interpret a pass/fail.

### Post-Design Constitution Re-Check

Re-evaluated after the Phase 1 design was written:

| Risk surfaced in design | Resolution | Verdict |
|---|---|---|
| Caching the aurora could freeze a theme colour, breaking IV and FR-012 | Cache key includes all four resolved `ThemeEnum` colours + size + dot spacing; a theme switch changes the key and invalidates. Covered by a dedicated golden in both themes. | **PASS** |
| Grouped blur could visually merge overlapping surfaces (Flutter docs explicitly warn) | The floating nav bar overlaps page content, so it is **excluded** from the list's `BackdropGroup` and keeps its own independent backdrop key. Recorded as a design rule in research R3. | **PASS** |
| Splitting the sorting list into per-bar `Consumer` widgets could add function-builder style code, breaking I | Each bar becomes a named `ConsumerWidget` class, not an inline builder closure. | **PASS** |
| Golden tests run on the host renderer, not the device GPU — they cannot alone prove on-device pixels | Spec already records this: goldens are the gate, a one-time A5i device screenshot comparison is the backstop. Both are in the task scope. | **PASS** |

**Post-design gate result: PASS.** No new violations. The single declared deviation (`integration_test`) is unchanged.

## Key Risk

Sustaining 60 FPS with real-time backdrop blur on entry-level Android hardware **while holding appearance pixel-identical** is the demanding combination flagged in the spec. The plan front-loads this: the "before" measurement and a narrow grouped-blur spike on the Practice list happen early, so if the A5i cannot reach the target with blur intact, it surfaces before the bulk of the work is committed — and FR-009a then governs what happens next (report with measurements, do not silently degrade).
