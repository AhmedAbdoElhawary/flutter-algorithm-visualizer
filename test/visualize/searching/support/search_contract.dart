import 'dart:math' as math;

import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_grid_input.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a grid from ASCII art: `#` wall, `.` open, `S` start, `E` end.
/// Everything outside the drawn rows is a wall, so a pattern is a closed maze
/// and the search cannot wander into open space.
PFGridInput gridOf(List<String> rows) {
  expect(rows.length, lessThanOrEqualTo(kPFRows));

  final walls = List.generate(kPFRows, (_) => List.filled(kPFCols, true));
  int? startRow, startCol, endRow, endCol;

  for (int r = 0; r < rows.length; r++) {
    final row = rows[r];
    expect(row.length, lessThanOrEqualTo(kPFCols));
    for (int c = 0; c < row.length; c++) {
      switch (row[c]) {
        case '#':
          continue;
        case 'S':
          startRow = r;
          startCol = c;
        case 'E':
          endRow = r;
          endCol = c;
      }
      walls[r][c] = false;
    }
  }

  expect(startRow, isNotNull, reason: 'the pattern must contain an S');
  expect(endRow, isNotNull, reason: 'the pattern must contain an E');

  return PFGridInput(
    walls: walls,
    startRow: startRow!,
    startCol: startCol!,
    endRow: endRow!,
    endCol: endCol!,
  );
}

/// A full-size grid that is open everywhere except [walls].
PFGridInput openGrid({
  int startRow = 2,
  int startCol = 2,
  int endRow = 10,
  int endCol = 20,
  Set<int> walls = const {},
}) {
  final cells = List.generate(
    kPFRows,
    (r) => List.generate(kPFCols, (c) => walls.contains(pfEncode(r, c))),
  );
  return PFGridInput(
    walls: cells,
    startRow: startRow,
    startCol: startCol,
    endRow: endRow,
    endCol: endCol,
  );
}

/// A grid with randomly placed walls and markers, from a fixed seed so any
/// failure is reproducible.
PFGridInput seededGrid(int seed, {double wallChance = 0.28}) {
  final rng = math.Random(seed);
  final cells = List.generate(
    kPFRows,
    (_) => List.generate(kPFCols, (_) => rng.nextDouble() < wallChance),
  );

  int row = rng.nextInt(kPFRows);
  int col = rng.nextInt(kPFCols);
  int endRow = rng.nextInt(kPFRows);
  int endCol = rng.nextInt(kPFCols);
  if (row == endRow && col == endCol) endCol = (endCol + 1) % kPFCols;

  cells[row][col] = false;
  cells[endRow][endCol] = false;

  return PFGridInput(
    walls: cells,
    startRow: row,
    startCol: col,
    endRow: endRow,
    endCol: endCol,
  );
}

bool stepEquals(PFStep a, PFStep b) =>
    a.phase == b.phase &&
    a.metricA == b.metricA &&
    a.metricB == b.metricB &&
    sameCells(a.visited, b.visited) &&
    sameCells(a.frontier, b.frontier) &&
    _listEquals(a.path, b.path);

bool sameCells(Set<int> a, Set<int> b) => a.length == b.length && a.containsAll(b);

bool _listEquals(List<int>? a, List<int>? b) {
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Asserts clauses A1–A9 — the obligations every algorithm carries.
void expectUniversalClauses(List<PFStep> steps, PFGridInput grid, {required String label}) {
  expect(steps, isNotEmpty, reason: '$label: a run always produces at least one step');

  // A1 — the search begins from the marker the learner placed.
  if (grid.start != grid.end) {
    expect(steps.first.frontier, {grid.start}, reason: '$label: A1 first frontier is the start marker');
    expect(steps.first.visited, isEmpty, reason: '$label: A1 nothing is expanded yet');
  }

  for (int i = 0; i < steps.length; i++) {
    final step = steps[i];

    // A2 — visited and frontier are disjoint at every step.
    expect(
      step.visited.intersection(step.frontier),
      isEmpty,
      reason: '$label: A2 violated at step $i',
    );

    // A8 — nothing is ever off the grid or inside a wall.
    for (final cell in {...step.visited, ...step.frontier}) {
      final row = pfDecodeRow(cell);
      final col = pfDecodeCol(cell);
      expect(grid.inBounds(row, col), isTrue, reason: '$label: step $i has out-of-bounds cell');
      expect(grid.isWall(row, col), isFalse, reason: '$label: step $i marks a wall cell');
    }

    // A5 — only the final step is terminal, and only it carries a path.
    final isLast = i == steps.length - 1;
    if (!isLast) {
      expect(step.phase, PFPhase.exploring, reason: '$label: A5 step $i terminated early');
      expect(step.path, isNull, reason: '$label: A5 step $i carries a path');
    }
    expect(
      step.path != null,
      step.phase == PFPhase.found,
      reason: '$label: A5 path iff found, step $i',
    );

    // A4 — every step changes something visible.
    if (i > 0) {
      final prev = steps[i - 1];
      final changed = !sameCells(prev.visited, step.visited) ||
          !sameCells(prev.frontier, step.frontier) ||
          !_listEquals(prev.path, step.path);
      expect(changed, isTrue, reason: '$label: A4 step $i is identical to step ${i - 1}');
    }
  }

  final terminal = steps.last;
  expect(
    terminal.phase,
    isNot(PFPhase.exploring),
    reason: '$label: A5 the run must end on found or exhausted',
  );

  // A6 — the path is ordered, connected, wall-free, and spans the markers.
  final path = terminal.path;
  if (path != null) {
    expect(path.first, grid.start, reason: '$label: A6 path starts at the start marker');
    expect(path.last, grid.end, reason: '$label: A6 path ends at the end marker');
    for (int i = 0; i < path.length; i++) {
      final row = pfDecodeRow(path[i]);
      final col = pfDecodeCol(path[i]);
      expect(grid.isWall(row, col), isFalse, reason: '$label: A6 path crosses a wall at index $i');
      if (i > 0) {
        final prevRow = pfDecodeRow(path[i - 1]);
        final prevCol = pfDecodeCol(path[i - 1]);
        final manhattan = (row - prevRow).abs() + (col - prevCol).abs();
        expect(manhattan, 1, reason: '$label: A6 path jumps between index ${i - 1} and $i');
      }
    }
  }
}

/// A7 — two runs over an equal input produce element-wise equal step lists.
void expectDeterministic(
  List<PFStep> Function(PFGridInput grid) run,
  PFGridInput grid, {
  required String label,
}) {
  final first = run(grid);
  final second = run(gridCopy(grid));

  expect(second.length, first.length, reason: '$label: A7 run lengths differ');
  for (int i = 0; i < first.length; i++) {
    expect(stepEquals(first[i], second[i]), isTrue, reason: '$label: A7 step $i differs between runs');
  }
}

PFGridInput gridCopy(PFGridInput grid) => PFGridInput(
      walls: [for (final row in grid.walls) List<bool>.from(row)],
      startRow: grid.startRow,
      startCol: grid.startCol,
      endRow: grid.endRow,
      endCol: grid.endCol,
    );
