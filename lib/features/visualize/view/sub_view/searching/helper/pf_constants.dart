import 'dart:math' as math;

const int kPFCols = 30;
const int kPFRows = 24;

const int kPFStartRow = 12;
const int kPFStartCol = 5;
const int kPFEndRow = 12;
const int kPFEndCol = 25;

/// A wall popping in under the finger that drew it.
const double kWallPopMs = 500;

/// How long the searcher takes to slide from the cell it just left to the cell
/// it is now standing on. It never changes shape or colour — this slide is its
/// only motion.
///
/// At playback time the grid caps this to one step interval, so a fast run
/// never asks the searcher to leave a cell it has not reached yet.
const double kSearcherJumpMs = 30;

/// How small the circle it snaps back to is, as a fraction of the cell.
const double kReleaseStartScale = 0.25;

/// How far past full size it grows before settling. 1.0 removes the overshoot.
const double kReleaseOvershootScale = 1.35;

/// Circle → overshoot square. The corners round off over this same stretch, so
/// it is a square by the time it stops growing.
const double kReleaseGrowMs = 500;

/// Overshoot square → normal square.
const double kReleaseSettleMs = 250;

/// trail0 → trail1 (the first mid tone).
const double kReleaseTrailMs = 500;

/// trail1 → visited (where the cell finally rests).
const double kReleaseVisitedMs = 900;

/// The whole release: the longer of the two tracks above, since the cell is
/// only settled once *both* have finished. Computed, so retuning either track
/// cannot leave the ticker stopping early.
final double kReleaseTotalMs = math.max(
  kReleaseGrowMs + kReleaseSettleMs,
  kReleaseTrailMs + kReleaseVisitedMs,
);

// --- The answer -------------------------------------------------------------

/// How long each successive path cell waits before its own turn, so the path
/// draws itself out from start to end instead of appearing at once.
const int kPathStaggerMs = 30;

/// How long one path cell takes to turn from the colour it already had into
/// the path colour. It never changes size: the answer is tinted onto the grid
/// that found it, not popped in over a hole where that grid used to be.
const double kPathTintMs = 400;

/// How small a wall starts before it springs out to full size.
const double kPopStartScale = 0.1;

// --- Grid lines -------------------------------------------------------------

/// The line around an empty cell.
const double kGridLineWidth = 1;

/// The line around a cell that carries a fill. Thinner on purpose: at full
/// strength a coloured cell is boxed in and the search reads as separate
/// tiles, where at half it reads as one spreading shape.
const double kFilledGridLineWidth = 1;

int pfEncode(int row, int col) => row * kPFCols + col;
int pfDecodeRow(int encoded) => encoded ~/ kPFCols;
int pfDecodeCol(int encoded) => encoded % kPFCols;
