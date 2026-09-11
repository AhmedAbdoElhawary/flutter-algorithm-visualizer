# Phase 1 Data Model: Render Performance

**Feature**: 001-render-performance-60fps | **Date**: 2026-09-11

This feature has no user-facing domain entities — it changes rendering, not data. The entities below are the **measurement records** the harnesses produce and compare, which is what FR-015 through FR-021 and SC-001 through SC-011 are actually asserted against.

---

## Budget constants

The single source of truth for every threshold in this feature. Derived from the spec; no other file may redefine them.

| Constant | Value | Source |
|---|---|---|
| `frameBudgetMs` | `16.67` | FR-001, FR-002 — 60 FPS |
| `targetFps` | `60` | FR-001 |
| `maxOverBudgetFramesSteadyState` | `0` | SC-001, SC-002 |
| `p99FrameTimeMs` | `< 16.67` | SC-003 |
| `warmupMaxOverBudgetFrames` | `5` | SC-011 |
| `warmupMaxSingleFrameMs` | `100` | SC-011 |
| `warmupMaxDurationMs` | `500` | SC-011 |
| `tabSwitchMaxMs` | `300` | SC-006 |
| `rebuildReductionMin` | `0.80` | SC-004 |
| `scrollPassDurationSec` | `10` | SC-001 |
| `warmDeviceSoakMinutes` | `10` | SC-008 |
| `goldenPixelTolerance` | `0` | FR-009c, SC-007 — exact |

---

## Entity: FrameSample

One rendered frame. The atom of every performance measurement.

| Field | Type | Notes |
|---|---|---|
| `frameIndex` | int | 0-based position within the scenario run |
| `buildTimeMs` | double | UI-thread build+layout cost |
| `rasterTimeMs` | double | GPU raster cost — where blur cost lands |
| `totalTimeMs` | double | The figure compared against `frameBudgetMs` |
| `phase` | enum | `warmup` \| `steadyState` — see state transitions below |

**Validation**: all times `>= 0`. `phase` must be assigned by the same rule in every run (FR-021) — a sample may never be silently dropped, only classified.

---

## Entity: ScenarioReport

The result of driving one screen or animation once.

| Field | Type | Notes |
|---|---|---|
| `scenarioId` | string | Stable id, e.g. `scroll.practice`, `sorting.run.fast10.maxSize` |
| `screen` | enum | `home` \| `visualize` \| `code` \| `practice` \| `profile` |
| `device` | string | Must read `oppo-a5i` for a gating run |
| `buildMode` | enum | `profile` \| `release` — a `debug` value invalidates the run (FR-001) |
| `samples` | FrameSample[] | Every frame captured |
| `steadyState` | FrameStats | The pass/fail figures |
| `warmup` | FrameStats | Reported, never discarded (FR-020) |
| `capturedAt` | ISO-8601 | |
| `gitSha` | string | Ties the numbers to a commit |

---

## Entity: FrameStats

Aggregates over a set of `FrameSample`s. Computed twice per scenario — once for `warmup`, once for `steadyState`.

| Field | Type | Notes |
|---|---|---|
| `frameCount` | int | |
| `avgFrameTimeMs` | double | FR-015 |
| `worstFrameTimeMs` | double | FR-015 |
| `p90FrameTimeMs` | double | |
| `p99FrameTimeMs` | double | SC-003 gate |
| `overBudgetFrameCount` | int | Frames exceeding `frameBudgetMs` — SC-001/SC-002 gate |
| `overBudgetPercent` | double | Derived |

---

## Entity: PerformanceBaseline

A committed `ScenarioReport` set that later runs are compared against (FR-016, FR-017).

| Field | Type | Notes |
|---|---|---|
| `label` | enum | `before` \| `after` |
| `reports` | ScenarioReport[] | One per scenario |
| `gitSha` | string | |

**Critical constraint**: the `before` baseline **must be captured on an unmodified tree**, before the first optimisation commit. Once rendering code changes, the original numbers are unrecoverable.

**Regression rule (FR-017)**: a later run regresses if, for any scenario, `steadyState.overBudgetFrameCount` increases, or `steadyState.p99FrameTimeMs` rises above the budget.

---

## Entity: RebuildCountRecord

Backs SC-004. Hardware-independent, so it is captured in a widget test rather than on-device (research R8).

| Field | Type | Notes |
|---|---|---|
| `subjectId` | string | e.g. `sorting.singleBarSwap` |
| `triggerDescription` | string | The one isolated state change applied |
| `rebuildCount` | int | Widgets whose `build` ran in response |
| `label` | enum | `before` \| `after` |

**Pass rule**: `after.rebuildCount <= before.rebuildCount * (1 - rebuildReductionMin)`.

**Counting rule**: the same instrumentation and the same subtree boundary before and after — otherwise the comparison is meaningless (SC-004's "counted the same way").

---

## Entity: GoldenSurface

One pixel-identity reference. Enumerated in full in [contracts/golden-inventory.md](./contracts/golden-inventory.md).

| Field | Type | Notes |
|---|---|---|
| `surfaceId` | string | e.g. `glass.card.dark` |
| `theme` | enum | `light` \| `dark` — both required for every surface (FR-009b) |
| `goldenPath` | string | Committed PNG under `test/golden/goldens/` |

**Pass rule**: exact match. `goldenPixelTolerance` is `0` — a golden needing an update is a **failed change**, not a golden to re-record, unless approved under FR-009a (FR-009c).

---

## State transitions: warmup → steadyState

The one piece of genuine state in this model, and the thing FR-021 insists must be defined identically across every run.

```text
   run starts
       │
       ▼
 ┌───────────┐   first N frames, or until frames stay
 │  warmup   │   within budget for a stable window
 └───────────┘
       │  transition recorded once, never re-entered
       ▼
 ┌─────────────┐
 │ steadyState │  ← the ONLY phase that gates pass/fail
 └─────────────┘
```

**Rules**:
- The transition rule is a constant, applied identically to every scenario and every build (FR-021). It may not be tuned per-screen to make a number pass.
- `warmup` samples are **classified, never discarded** (FR-020). They are reported against the SC-011 allowance.
- Steady state is entered exactly once per run.

---

## What this feature does *not* model

- No user-facing domain entities, no persistence, no network shapes. Data and network behaviour are explicitly out of scope.
- No new app state. The sorting notifier's existing state is read differently (more narrowly), never restructured.
