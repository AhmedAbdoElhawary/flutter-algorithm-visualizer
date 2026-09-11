---

description: "Task list for feature implementation"
---

# Tasks: Render Performance — Smooth 60 FPS Across the App

**Input**: Design documents from `/specs/001-render-performance-60fps/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/)

**Tests**: Test tasks ARE included and are NOT optional here. The spec explicitly requires them as deliverables — golden tests (FR-009b/c/d), the automated performance suite (FR-015), and a rebuild-count measurement (SC-004). They are the feature, not a support activity.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Exact file paths are included in every task

## Path Conventions

Flutter mobile app. Source in `lib/`, unit + golden tests in `test/`, on-device performance tests in `integration_test/`. Paths below are repository-relative and match [plan.md](./plan.md)'s structure section.

---

## ⚠️ Read before starting: one deliberate reorder

The spec ranks User Story 4 (measurement) as **P4**, reasoning that it "depends on the optimisations existing first". The plan then established a **hard sequencing constraint** that contradicts a literal reading of that priority: golden references and the "before" baseline **must be captured on an unmodified tree**. Once rendering code changes, the original appearance and timings are unrecoverable, and FR-009 / FR-016 become permanently unverifiable.

**Resolution**: User Story 4 is split.

| Half | Where it lives | Why |
|---|---|---|
| Building the harnesses + capturing "before" | **Phase 2 (Foundational, blocking)** | Physically must precede any optimisation |
| Comparing before/after, documenting gains, regression guard | **Phase 6 (US4, P4)** | Genuinely depends on the optimisations existing |

This is a reorder of execution, not of value. US4's *delivered value* is still last.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Tooling and directories. No production code is touched.

- [X] T001 Add the Flutter SDK `integration_test` package to `dev_dependencies` in `pubspec.yaml` via `flutter pub add --dev integration_test --sdk=flutter`, then verify `flutter pub get` succeeds
- [X] T002 [P] Create the on-device test directory `integration_test/scenarios/` with a `.gitkeep`, per plan.md structure
- [X] T003 [P] Create the golden test directories `test/golden/` and `test/golden/goldens/` with a `.gitkeep`, per plan.md structure
- [X] T004 Confirm the Oppo A5i is attached and recognised by running `flutter devices`, and record its device id in `specs/001-render-performance-60fps/quickstart.md` under Prerequisites (replacing the `<a5i-device-id>` placeholder)
- [X] T005 [P] Confirm a profile-mode build of an existing flavor entry point launches on the A5i (`flutter run --profile -t lib/main_dev.dart`); `lib/main.dart` is NOT launchable and must not be used as a run target
- [X] T005a Create the driver entry point `test_driver/integration_test.dart` calling `integrationDriver(responseDataCallback: ...)` to write captured timings to disk as JSON (FR-022). **Without this file the performance run produces no report** — `watchPerformance` accumulates results in `reportData` in memory only, and `flutter test integration_test/...` never flushes them
- [X] T005b Modify `.github/workflows/ci.yml` line 78 to exclude golden tests from the Linux quality job: `flutter test -x golden --dart-define-from-file=dart_define/dev.json` (FR-019a). Golden PNGs are platform-specific and the runner is `ubuntu-latest` while goldens are recorded on macOS — without this, committing goldens in T016 turns **every PR red**
- [X] T005c Add a golden job to `.github/workflows/ci.yml` running on `macos-latest` with `flutter test -t golden`, so the FR-009d permanent guard still fires on every pull request (FR-019b). Excluding goldens from CI entirely would silently defeat the guard the feature exists to create
- [X] T005d Verify FR-019 holds after T005b/T005c: the **performance** suite is not gated in CI on hosted runners — only the golden suite runs there. Hosted runners have no real GPU, so their frame numbers are meaningless

**Checkpoint**: Tooling ready, CI protected, and the report write-path exists. No source file has been modified.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build both harnesses and capture every "before" artifact **on an unmodified tree**.

**⚠️ CRITICAL — IRREVERSIBLE ORDERING**: No task in Phase 3 or later may begin until this entire phase is complete and committed. Once a rendering file changes, the original appearance and frame numbers cannot be recovered.

### Measurement model & contract

- [X] T006 [P] Create the budget constants in `integration_test/support/perf_budgets.dart` with the exact values from data-model.md: `frameBudgetMs = 16.67`, `targetFps = 60`, `maxOverBudgetFramesSteadyState = 0`, `warmupMaxOverBudgetFrames = 5`, `warmupMaxSingleFrameMs = 100`, `warmupMaxDurationMs = 500`, `tabSwitchMaxMs = 300`, `rebuildReductionMin = 0.80`, `scrollPassDurationSec = 10`, `warmDeviceSoakMinutes = 10`, `goldenPixelTolerance = 0`. This file is the single source of truth — no other file may redefine a threshold
- [X] T007 [P] Create the `FrameSample` and `FrameStats` models in `integration_test/support/perf_models.dart` per data-model.md. `FrameSample` fields: `frameIndex` (int, 0-based), `buildTimeMs`, `rasterTimeMs`, `totalTimeMs` (all double, `>= 0`), `phase` (enum `warmup` | `steadyState`). `FrameStats` fields: `frameCount`, `avgFrameTimeMs`, `worstFrameTimeMs`, `p90FrameTimeMs`, `p99FrameTimeMs`, `overBudgetFrameCount`, `overBudgetPercent` (0–100), `durationMs`
- [X] T008 [P] Create the `ScenarioReport` and `PerformanceBaseline` models in `integration_test/support/perf_report.dart` per data-model.md, with JSON serialization matching `contracts/perf-report.schema.json` exactly — `schemaVersion` const `"1.0.0"`, `label` enum `before`|`after`, `buildMode` enum `profile`|`release` (a `debug` value must throw and invalidate the run), `gitSha` matching `^[0-9a-f]{7,40}$`, `thermalState` enum `cold`|`warm` defaulting to `cold`
- [X] T009 Implement the warm-up → steady-state classifier in `integration_test/support/phase_classifier.dart` satisfying FR-021: one constant transition rule applied identically to every scenario and build, steady state entered exactly once per run, and warm-up samples **classified, never discarded** (FR-020). The rule must not be tunable per-screen
- [X] T010 Add a schema-conformance test in `test/perf/perf_report_schema_test.dart` asserting a serialized `PerformanceBaseline` validates against `specs/001-render-performance-60fps/contracts/perf-report.schema.json`

### Golden harness (determinism first)

- [X] T011 Create the golden determinism harness in `test/golden/support/golden_harness.dart` enforcing the five rules from `contracts/golden-inventory.md`: pump to a fixed settled frame (no mid-transition capture), seeded fixture content only, one fixed surface size + device pixel ratio per golden so ScreenUtil resolves identically, a stubbed/fixed-elapsed ticker, and no network font fetch from `google_fonts`
- [X] T011a Add `@Tags(['golden'])` to the top of every file in `test/golden/` so the T005b exclusion and the T005c macOS job can select them. A golden file missing this tag will run on the Linux job and fail — verify by running `flutter test -x golden` locally and confirming zero golden tests execute
- [X] T012 [US4] Write the component golden tests in `test/golden/glass_container_golden_test.dart` covering surfaces 1–6 of `contracts/golden-inventory.md` (`glass.recessed`, `glass.card`, `glass.floating`, `glass.card.noTopShadow`, `glass.card.animated`, `glass.track`) in **both light and dark themes** — 12 goldens
- [X] T013 [P] [US4] Write the background golden tests in `test/golden/aurora_ground_golden_test.dart` covering surfaces 7–9 (`aurora.ground`, `glass.on.aurora`, `glass.grouped.list`) in **both themes** — 6 goldens. Surface 9 is the R3 acceptance golden that proves grouped blur is visually identical to separate blurs
- [X] T014 [US4] Write the screen golden tests (screen.code skipped — CodeEditorPage is commented out; documented gap) in `test/golden/main_screens_golden_test.dart` covering surfaces 10–14 (Home, Visualize, Code, Practice, Profile) in **both themes** — 10 goldens. `screen.home` must stub or fix-elapse the `movable_pins.dart` particle `Ticker` or it will never match twice
- [X] T015 [US4] Record all 28 golden reference PNGs (26 recorded; screen.code x2 skipped, documented gap) to `test/golden/goldens/` via `flutter test test/golden --update-goldens`, then re-run **without** the flag and confirm a clean pass. Any non-deterministic golden must be fixed now — not later
- [X] T016 [US4] Commit the 28 goldens. From this commit forward `--update-goldens` is banned: per FR-009c a golden needing an update is a **failed change**, not a golden to re-record

### Performance harness

- [X] T017 [US4] Create the timeline-capture entry point in `integration_test/perf_driver.dart` using `IntegrationTestWidgetsFlutterBinding.watchPerformance`, writing a report conforming to `contracts/perf-report.schema.json`
- [X] T018 [P] [US4] Implement the scroll scenarios in `integration_test/scenarios/scroll_main_screens_test.dart` — one 10-second continuous scroll pass per screen, scenario ids `scroll.home`, `scroll.visualize`, `scroll.code`, `scroll.practice`, `scroll.profile`
- [X] T018a [P] [US4] Add a worst-case list scenario (uses real 100-problem dataset) to `integration_test/scenarios/scroll_main_screens_test.dart` seeded with the **maximum** problem-list length, scenario id `scroll.practice.maxItems`, satisfying FR-004's "regardless of how many problems the list contains". A list smooth at 20 items and janky at 200 does not pass
- [X] T019 [P] [US4] Implement the sorting scenario in `integration_test/scenarios/sorting_run_test.dart` — a complete run at the maximum supported array size for **every** `PlaybackSpeed` value (`slow` 900ms, `normal` 300ms, `fast3` 150ms, `fast5` 100ms, `fast10` 50ms per FR-003 and the widened SC-002), scenario ids `sorting.run.<speed>.maxSize`. `fast10` is the stress case but all five are gated
- [X] T020 [P] [US4] Implement the tab-switch scenario in `integration_test/scenarios/tab_switch_test.dart` — tap through all five `StatefulShellBranch` tabs in sequence, recording `tabSwitchMs` per transition, scenario id `tabswitch.sequence`

### Capture the irreplaceable "before" state

- [ ] T021 [US4] Run the full suite on the A5i in profile mode and commit the result as `specs/001-render-performance-60fps/baselines/before.json`. Verify it records `"device": "oppo-a5i"` and `"buildMode": "profile"`. It is EXPECTED to fail the gates — that is the documented problem
- [ ] T022 [US4] Capture device screenshots of all five main screens in both themes on the A5i and commit them to `specs/001-render-performance-60fps/baselines/screenshots-before/` as the on-device backstop to the host-renderer goldens. Use stable, descriptive filenames — T059 matches the "after" set by filename
- [ ] T023 [P] [US4] Record the "before" rebuild count for a single isolated sorting-bar swap in `test/visualize/sorting/rebuild_count_test.dart`, committing the baseline number. Per SC-004 the same instrumentation and subtree boundary must be used before and after, or the comparison is meaningless

**Checkpoint**: Both harnesses exist, all 28 goldens are locked, and the irreplaceable "before" state is committed. Optimisation may now begin.

---

## Phase 3: User Story 1 - Scroll the main screens without stutter (Priority: P1) 🎯 MVP

**Goal**: All five main tab screens scroll at 60 FPS with zero over-budget frames in steady state.

**Independent Test**: Fling-scroll each of the five screens on the A5i while recording frame timings; every screen delivers zero over-budget steady-state frames. Delivers value even if no other story ships.

**⚠️ Run `flutter test test/golden` after EVERY task in this phase.** A golden failure means the change altered appearance — revert or fix it; do not re-record.

### Spike first (de-risks the whole feature)

- [ ] T024 [US1] Spike `BackdropGroup` on the Practice list only: wrap the `SliverList.builder` in `lib/features/challenge/presentation/view/challenge_page.dart` in a `BackdropGroup` and switch `ProblemTile`'s glass to a grouped backdrop, then measure on the A5i. **This is the feature's key risk gate** — if grouped blur cannot reach 60 FPS here with appearance intact, stop and invoke FR-009a (report with measurements, seek approval) rather than lowering blur

### Root cause 2 — the aurora background (affects all five screens)

- [ ] T025 [US1] Wrap `AuroraGround`'s painter in a `RepaintBoundary` in `lib/core/widgets/custom_widgets/glass_card.dart` so it occupies its own layer and stops repainting when content above it changes
- [ ] T026 [US1] Cache the `_AuroraPainter` dot-grid and band composition into a `ui.Picture`/`ui.Image` in `lib/core/widgets/custom_widgets/glass_card.dart`, replayed instead of re-running ~6,800 `drawCircle` calls per paint. **The cache key MUST include all five resolved values plus size** — `base`, `indigo`, `cyan`, `dot`, `dotSpacing`, `size` — exactly the tuple the existing `shouldRepaint` already compares
- [ ] T027 [US1] Verify the aurora cache invalidates on a light/dark theme switch by running `flutter test test/golden` (surfaces `aurora.ground` and `glass.on.aurora`, both themes). Caching on size alone would freeze one theme's background into the other and violate Constitution Principle IV and FR-012

### Root cause 1 — many blurs in the Practice list

- [ ] T028 [US1] Promote the T024 spike to the real implementation: add an opt-in grouped-backdrop mode to `GlassContainer` in `lib/core/widgets/custom_widgets/glass_card.dart` using `BackdropFilter.grouped`. It MUST stay opt-in — applying it blindly to overlapping surfaces produces a visible rendering fault
- [ ] T029 [US1] Adopt the grouped mode in `lib/features/challenge/presentation/widgets/challenges/problem_tile.dart`, preserving every existing visual parameter (`fillCardTheme: ThemeEnum.glassCardFill2`, `depth: GlassDepth.card`, `durationForAnimation: 200ms`, `borderRadius: 12`, `allowCardTopShadow: !expanded`)
- [ ] T030 [US1] Verify the grouped-blur acceptance golden `glass.grouped.list` still passes with **zero** pixel difference (SC-007), proving the engine's grouped result is visually identical to N separate blurs

### Root cause 4 — the floating nav bar

- [ ] T031 [US1] Explicitly EXCLUDE the floating nav `GlassContainer` in `lib/features/base/view/base_navigation.dart` from any page-content `BackdropGroup`, giving it its own independent backdrop key. Per the Flutter API docs, overlapping backdrop filters sharing a key render "as if only one filter is applied in the overlapping regions" — the nav overlaps scrolling content on all five tabs
- [ ] T032 [US1] Add a code comment in `lib/features/base/view/base_navigation.dart` recording WHY the nav is excluded, so a future refactor does not helpfully "optimise" it into the group and introduce a visual fault
- [ ] T032a [US1] Audit every one of the five main screens and confirm at most **2** independent backdrop-blur surfaces render simultaneously — one shared content group plus the independent nav bar (FR-008a). Record the per-screen count in `specs/001-render-performance-60fps/baselines/RESULTS.md`; any screen exceeding 2 must be reported

### Per-screen isolation

- [ ] T033 [P] [US1] Profile the Home screen on the A5i with DevTools and add `RepaintBoundary` isolation where the timeline shows repaint cascades, in `lib/features/home/view/home_page.dart`
- [ ] T034 [P] [US1] Profile and isolate the Profile screen in `lib/features/profile/presentation/view/profile_page.dart`, paying attention to the `fl_chart` widgets and the heatmap
- [ ] T035 [P] [US1] Profile and isolate the Visualize screen in `lib/features/visualize/view/visualize_page.dart`
- [ ] T036 [P] [US1] Profile and isolate the Code screen in `lib/features/challenge/presentation/view/code_editor_page.dart`
- [ ] T037 [US1] Narrow any broad `ref.watch(...)` that profiling proves is over-rebuilding on these five screens to `ref.watch(provider.select(...))` per FR-005a and Constitution Principle VI. Do NOT refactor watch sites profiling did not implicate — those are recorded as debt in T060

### Validate the story

- [ ] T038 [US1] Re-run the performance suite on the A5i and confirm SC-001 (zero steady-state over-budget frames on all five screens across a 10-second scroll pass) and SC-003 (99th-percentile frame time below 16.67 ms on every target screen)
- [ ] T039 [US1] Confirm SC-005: screens at rest produce zero repeated frames. Home is excepted per research R6 — its ambient particle ticker is deliberate motion, but must stay inside its `RepaintBoundary` and remain paused when backgrounded

**Checkpoint**: Scrolling is smooth on all five screens. This is a shippable MVP on its own.

---

## Phase 4: User Story 2 - Watch a sorting run at full smoothness (Priority: P2)

**Goal**: A complete sorting run holds 60 FPS at every playback speed and at the maximum array size.

**Independent Test**: Run a full sort at `fast10` with the maximum array size while recording frame timings; zero dropped frames for the whole run.

### Root cause 3 — the O(N²) rebuild

- [ ] T040 [US2] Extract each sorting bar into a **named `ConsumerWidget` class** in `lib/features/visualize/sub_view/sorting/view/sorting_view.dart`. Constitution Principle I forbids function-style builders — this must be a widget class with a `const` constructor, not an inline closure
- [ ] T041 [US2] Move the per-bar `ref.watch(widget.instance.select((state) => state.positions[item.id]))` OUT of the parent's `List.generate` loop at `sorting_view.dart:259` and INTO the new per-bar widget, so the parent no longer subscribes to all N bar positions. This is the direct cause of the reported "junk frames when bars change places"
- [ ] T042 [US2] Narrow `_BuildItem`'s `ref.watch(instance.select((state) => ... state.list[index]))` at `sorting_view.dart:324` so a bar watches only the fields it renders (value, `sortedStatus`) rather than the whole item object
- [ ] T043 [US2] Add `RepaintBoundary` isolation per bar in `lib/features/visualize/sub_view/sorting/view/sorting_view.dart` so one bar's `AnimatedPositionedDirectional` movement does not repaint its neighbours
- [ ] T044 [US2] Verify the rebuild-count reduction in `test/visualize/sorting/rebuild_count_test.dart`: `after.rebuildCount <= before.rebuildCount * 0.20` (SC-004's 80% reduction), using the same instrumentation and subtree boundary as the T023 baseline

### Root cause 5 — the second painter loop

- [ ] T045 [US2] Profile `GridSquaresPainter` in `lib/features/visualize/widgets/grid_squares_view.dart` on the A5i during a sort — its nested `for` loops at lines 119–120 run per cell over width × height while the animation plays
- [ ] T046 [US2] Apply `RepaintBoundary` and/or picture caching to `lib/features/visualize/widgets/grid_squares_view.dart` if T045 shows it consuming frame budget, keyed on its existing `shouldRepaint` inputs so output stays identical

### Validate the story

- [ ] T047 [US2] Re-run the sorting scenarios and confirm SC-002: zero dropped steady-state frames across a complete run at the maximum array size for **all five** playback speeds (`slow`, `normal`, `fast3`, `fast5`, `fast10`)
- [ ] T048 [US2] Verify manual step forward/backward updates the screen within one frame with no visible delay (US2 acceptance scenario 4)
- [ ] T049 [US2] Run `flutter test -t golden` and `flutter test` — appearance unchanged with zero pixel difference (SC-007) and all 7 existing unit tests still pass (SC-009, FR-010), including the three sorting notifier tests

**Checkpoint**: Sorting and scrolling are both smooth.

---

## Phase 5: User Story 3 - Open screens and switch tabs instantly (Priority: P3)

**Goal**: Tab switches and screen opens complete with no freeze and no dropped frames.

**Independent Test**: Time first-paint and time-to-interactive for each tab from both a cold and a repeat switch on the A5i.

- [ ] T050 [US3] Run the tab-switch scenario on the A5i and record which transitions exceed the 300 ms budget or drop frames, using `integration_test/scenarios/tab_switch_test.dart`
- [ ] T051 [US3] Fix what T050 implicates in `lib/features/base/view/base_navigation.dart` and the relevant tab's entry widget — expected to be largely resolved already by the Phase 3 aurora and blur work, so measure before changing anything
- [ ] T052 [US3] Verify a returned-to tab does not redo work its state has not invalidated (US3 acceptance scenario 3), given `go_router`'s `StatefulShellRoute` already preserves branch state
- [ ] T053 [US3] Confirm SC-006: tab switching completes in under 300 ms with no over-budget frames during the transition
- [ ] T054 [US3] Verify rapid sequential tapping through all five tabs leaves the app responsive with no dropped frames (US3 acceptance scenario 2)

**Checkpoint**: All three user-facing performance stories are complete.

---

## Phase 6: User Story 4 - Prove and protect the gains (Priority: P4)

**Goal**: The improvement is documented in real numbers and a future regression is detectable.

**Independent Test**: Run the suite on a clean checkout and confirm it produces per-screen metrics comparable against the committed baselines.

> Harness construction and the "before" capture were completed in Phase 2 — see the reorder note at the top of this file. This phase delivers the comparison and the guard.

- [ ] T055 [US4] Capture the "after" baseline on the A5i and commit it as `specs/001-render-performance-60fps/baselines/after.json`
- [ ] T056 [US4] Write the before/after comparison in `specs/001-render-performance-60fps/baselines/RESULTS.md` covering all five main screens plus the sorting animation with concrete figures, satisfying FR-016 and SC-010
- [ ] T057 [US4] Implement the regression check in `integration_test/support/compare_baselines.dart` per FR-017: a run regresses if, for any scenario, `steadyState.overBudgetFrameCount` increases OR `steadyState.p99FrameTimeMs` rises above the budget
- [ ] T058 [US4] Confirm warm-up is reported and never silently discarded (FR-020), and that the figures sit inside the SC-011 allowance — at most 5 over-budget frames, none exceeding 100 ms, steady state reached within 500 ms
- [ ] T059 [US4] Capture device screenshots on the A5i after optimisation into `baselines/screenshots-after/` and diff them against `screenshots-before/` from T022 with `python3 tool/compare_screenshots.py <before> <after> --diff-dir <tmp>` — the one-time on-device backstop that host-renderer goldens cannot provide. Pairs reporting `0 px` are proven unchanged and MUST NOT be opened by a person or a model; inspect only flagged pairs, starting from the heatmap. Home and the aurora animate and will always flag — judge those two against the design. Record the per-pair counts in `baselines/RESULTS.md`
- [ ] T060 [US4] Inventory the remaining unscoped `ref.watch(...)` call sites (roughly 47 at spec time versus 53 scoped) into `specs/001-render-performance-60fps/followup-debt.md` with counts and locations, per FR-005b. These are recorded as a deliberate later decision, NOT refactored in this feature

**Checkpoint**: The gains are proven in numbers and guarded against regression.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: The edge cases and cross-cutting guarantees the spec requires.

- [ ] T061 [P] Verify SC-008 on a thermally warm device: soak the A5i for 10 minutes of continuous use, then re-run the suite with `thermalState: "warm"` and confirm the targets still hold
- [ ] T062 [P] Verify the OS reduce-motion setting still behaves exactly as before (FR-011), and that the reduced path is at least as smooth as the full path
- [ ] T063 [P] Verify light/dark theme switching takes effect immediately with no stale cached colour or background (FR-012), exercising the T026 aurora cache specifically
- [ ] T064 [P] Verify backgrounding mid-animation runs no animation work while hidden and produces no burst of dropped frames on resume, including the `movable_pins.dart` ticker's `WidgetsBindingObserver` path
- [ ] T065 [P] Verify scrolling while a sort is running keeps both smooth with neither starving the other (spec Edge Cases — rapid input)
- [ ] T066 [P] Verify the secondary screens have not regressed (FR-014): problem detail, code editor, celebration, bookmarks, practice history, and the auth screens
- [ ] T067 [P] Verify graceful degradation on a device weaker than the A5i — smooth-but-slower motion rather than unpredictable stutter, and no crash or hang
- [ ] T068 [P] Verify a 90/120 Hz display is not capped or visibly harmed by the 60 FPS target (spec Edge Cases — high-refresh displays)
- [ ] T069 Run the full `quickstart.md` validation end to end and confirm every gate in its "Reading a pass" table
- [ ] T070 Verify Constitution compliance across the whole diff: widget classes not function builders (I), adaptive Text/Padding (II), ScreenUtil sizing (III), `ThemeEnum` colours with no raw `Color`/`withOpacity` (IV), `StringsManager` strings (V), scoped `.select()` watching (VI), surrounding-code consistency (VII)
- [ ] T070a Verify FR-005c specifically by diffing this feature's branch against `develop` and confirming **zero net-new** unscoped `ref.watch(...)` call sites were introduced — compare counts before and after rather than asserting it by inspection
- [ ] T071 [P] Document the grouped-backdrop opt-in and the nav-bar exclusion rule in `AGENTS.md` so future contributors do not reintroduce per-tile blurs or merge the nav into a backdrop group
- [ ] T072 Confirm no commit in this feature carries an AI-attribution trailer, and that no secrets or `.env` files were introduced — this repository is PUBLIC

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1. **BLOCKS EVERYTHING.** Irreversible: the "before" artifacts cannot be captured after optimisation begins
- **Phase 3 (US1, P1)**: Depends on Phase 2 complete and committed
- **Phase 4 (US2, P2)**: Depends on Phase 2. Independent of US1 — different files
- **Phase 5 (US3, P3)**: Depends on Phase 2. Best measured after US1, since the aurora and blur fixes likely resolve most of it
- **Phase 6 (US4, P4)**: Depends on US1/US2/US3 being complete — it compares against them
- **Phase 7 (Polish)**: Depends on all desired stories being complete

### User Story Dependencies

- **US1 (P1)**: Independent. Touches `glass_card.dart`, `challenge_page.dart`, `problem_tile.dart`, `base_navigation.dart`, the five screen files
- **US2 (P2)**: Independent of US1. Touches `sorting_view.dart` and `grid_squares_view.dart` only
- **US3 (P3)**: Independent, but measure after US1 to avoid fixing something US1 already fixed
- **US4 (P4)**: Depends on the others existing — it is the proof, not the change

### Critical path

```text
T001 → T006..T009 → T011 → T012..T016 (goldens locked)
                         → T017..T020 → T021..T023 (before captured)
                                              ↓
                                    ┌─────────┴─────────┐
                                  US1 (T024..T039)   US2 (T040..T049)
                                    └─────────┬─────────┘
                                         US3 (T050..T054)
                                              ↓
                                         US4 (T055..T060)
                                              ↓
                                      Polish (T061..T072)
```

**T024 is the risk gate.** It spikes grouped blur on the Practice list before the bulk of the work is committed. If the A5i cannot hold 60 FPS there with appearance intact, FR-009a governs — report with measurements, do not silently degrade.

### Within Each User Story

- Measure before changing — several tasks exist specifically to profile first
- Shared component fixes (`glass_card.dart`) before per-screen adoption
- Run `flutter test test/golden` after every change in Phases 3–5
- Story complete and validated before moving to the next priority

### Parallel Opportunities

- **Phase 1**: T002, T003, T005 in parallel
- **Phase 2**: T006, T007, T008 in parallel (different files); then T013 alongside T012; then T018, T019, T020 in parallel; T023 alongside T021/T022
- **Phase 3**: T033–T036 in parallel (four different screen files)
- **Phase 7**: T061–T068 and T071 all in parallel
- **Across stories**: US1 and US2 touch disjoint files and can run in parallel if staffed

---

## Parallel Example: Phase 2 measurement model

```bash
# Three independent model files, no shared edits:
Task: "Create budget constants in integration_test/support/perf_budgets.dart"
Task: "Create FrameSample and FrameStats models in integration_test/support/perf_models.dart"
Task: "Create ScenarioReport and PerformanceBaseline models in integration_test/support/perf_report.dart"
```

## Parallel Example: Phase 3 per-screen isolation

```bash
# Four different screen files, no shared edits:
Task: "Profile and isolate Home in lib/features/home/view/home_page.dart"
Task: "Profile and isolate Profile in lib/features/profile/presentation/view/profile_page.dart"
Task: "Profile and isolate Visualize in lib/features/visualize/view/visualize_page.dart"
Task: "Profile and isolate Code in lib/features/challenge/presentation/view/code_editor_page.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Complete Phase 1 (Setup)
2. Complete Phase 2 (Foundational) — **do not skip; it is irreversible**
3. Run T024, the risk gate. If grouped blur cannot hit the target with appearance intact, stop and invoke FR-009a
4. Complete Phase 3 (US1)
5. **STOP and VALIDATE**: confirm SC-001, SC-003, SC-005 and 28/28 goldens
6. Shippable — scrolling is the most frequent interaction in the app

### Incremental Delivery

1. Setup + Foundational → both harnesses exist, "before" locked
2. US1 → smooth scrolling everywhere → validate → ship (MVP)
3. US2 → smooth sorting → validate → ship
4. US3 → instant tab switches → validate → ship
5. US4 → the numbers that prove it → ship
6. Polish → edge cases and guardrails

### If the target proves unreachable

Do **not** lower blur sigma, drop glass layers, or flatten the aurora to make a number pass. FR-009a governs: report the shortfall with measurements attached and get explicit approval before any visual change. T024 exists to surface this early.

---

## Notes

- **[P]** = different files, no dependencies
- **[Story]** label maps each task to a user story for traceability
- Phase 2 is irreversible — the "before" state cannot be recaptured later
- A failing golden means the change altered appearance: fix the change, never re-record the golden (FR-009c)
- `--update-goldens` is banned after T016
- Commit after each task or logical group; no AI-attribution trailers (repo convention)
- Every threshold lives in `perf_budgets.dart` — never hard-code one at a call site
