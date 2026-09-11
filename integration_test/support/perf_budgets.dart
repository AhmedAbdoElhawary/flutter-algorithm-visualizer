/// Single source of truth for every performance threshold in this feature.
///
/// No other file may redefine one of these values (see data-model.md).
library;

/// 60 FPS frame budget in milliseconds (1000 / 60).
const double frameBudgetMs = 16.67;

/// Target frames per second.
const int targetFps = 60;

/// Steady-state frames may exceed [frameBudgetMs] this many times: zero.
const int maxOverBudgetFramesSteadyState = 0;

/// Warm-up allowance: at most this many over-budget frames (SC-011).
const int warmupMaxOverBudgetFrames = 5;

/// Warm-up allowance: no single warm-up frame may exceed this (SC-011).
const double warmupMaxSingleFrameMs = 100;

/// Warm-up allowance: steady state must be reached within this duration (SC-011).
const double warmupMaxDurationMs = 500;

/// A tab switch must complete within this many milliseconds (SC-006).
const double tabSwitchMaxMs = 300;

/// Minimum required rebuild-count reduction, before vs after (SC-004).
const double rebuildReductionMin = 0.80;

/// Duration of one continuous scroll pass, in seconds (SC-001).
const int scrollPassDurationSec = 10;

/// Minutes to soak the device before a "warm" thermal-state run (SC-008).
const int warmDeviceSoakMinutes = 10;

/// Golden image comparison tolerance: zero, exact match only (FR-009c, SC-007).
const int goldenPixelTolerance = 0;
