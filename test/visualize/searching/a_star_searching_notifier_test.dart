import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_grid_input.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_status_text.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/search_contract.dart';

List<PFStep> _run(PFGridInput grid) => AStarSearchingNotifier().buildAlgorithm(grid);

List<PFStep> _runBfs(PFGridInput grid) => BFSSearchingNotifier().buildAlgorithm(grid);

int _manhattan(int cell, PFGridInput grid) =>
    (pfDecodeRow(cell) - grid.endRow).abs() + (pfDecodeCol(cell) - grid.endCol).abs();

/// The one cell [steps] `[i]` expanded.
int _expandedAt(List<PFStep> steps, int i) => steps[i].visited.difference(steps[i - 1].visited).single;

void main() {
  test('rule is cheapestFirst (S2)', () {
    expect(AStarSearchingNotifier().rule, PFRule.cheapestFirst);
  });

  group('universal clauses A1–A9', () {
    test('hold on an open grid, whatever the markers', () {
      for (final grid in [
        openGrid(),
        openGrid(startRow: 0, startCol: 0, endRow: kPFRows - 1, endCol: kPFCols - 1),
        openGrid(startRow: 23, startCol: 29, endRow: 0, endCol: 0),
      ]) {
        expectUniversalClauses(_run(grid), grid, label: 'a* open');
      }
    });

    test('hold on 30 seeded random grids', () {
      for (int seed = 0; seed < 30; seed++) {
        final grid = seededGrid(seed);
        expectUniversalClauses(_run(grid), grid, label: 'a* seed $seed');
      }
    });

    test('A7/S3: the explicit tie-break makes two runs element-wise equal', () {
      for (int seed = 0; seed < 5; seed++) {
        expectDeterministic(_run, seededGrid(seed), label: 'a* seed $seed');
      }
    });

    test('A9: start equal to goal returns one found step whose path is the start', () {
      final grid = openGrid(startRow: 4, startCol: 4, endRow: 4, endCol: 4);
      final steps = _run(grid);

      expect(steps, hasLength(1));
      expect(steps.single.phase, PFPhase.found);
      expect(steps.single.path, [grid.start]);
    });

    test('a walled-in start ends exhausted with no path', () {
      final grid = gridOf([
        '#####',
        '##S##',
        '#####',
        '#E###',
      ]);
      final steps = _run(grid);

      expect(steps.last.phase, PFPhase.exhausted);
      expect(steps.where((s) => s.phase == PFPhase.exhausted), hasLength(1));
      expectUniversalClauses(steps, grid, label: 'a* walled in');
    });
  });

  group('A* clauses S1–S8', () {
    test('S1/S8: metricB is the Manhattan distance from the expanded cell to the placed end marker', () {
      for (final grid in [
        openGrid(startRow: 3, startCol: 3, endRow: 9, endCol: 11),
        openGrid(startRow: 20, startCol: 25, endRow: 1, endCol: 2),
        seededGrid(4),
      ]) {
        final steps = _run(grid);
        expect(steps.first.metricB, _manhattan(grid.start, grid), reason: 'seed step');

        for (int i = 1; i < steps.length; i++) {
          expect(steps[i].metricB, _manhattan(_expandedAt(steps, i), grid), reason: 'step $i');
        }
      }
    });

    test('S2/S4: on an open grid every expansion sits on an optimal route — g + h is the goal cost', () {
      final grid = openGrid(startRow: 3, startCol: 3, endRow: 9, endCol: 11);
      final optimal = _manhattan(grid.start, grid);
      final steps = _run(grid);

      for (final step in steps) {
        expect(step.metricA + step.metricB!, optimal);
      }
      expect(steps.first.metricA, 0, reason: 'S4: g(start) is zero');
    });

    test('S3: ties break on lower f, then lower h, then lower encoded id', () {
      final grid = gridOf([
        'S..',
        '.#.',
        '..E',
      ]);
      final steps = _run(grid);

      final expanded = [for (int i = 1; i < steps.length; i++) _expandedAt(steps, i)];

      // (0,1) and (1,0) tie on f and on h, so the lower id wins; from there
      // (0,2) beats (1,0) on the lower h even though f still ties.
      expect(expanded, [
        pfEncode(0, 0),
        pfEncode(0, 1),
        pfEncode(0, 2),
        pfEncode(1, 2),
        pfEncode(2, 2),
      ]);
    });

    test('S5: a closed cell is never reopened — visited only ever grows', () {
      for (int seed = 0; seed < 10; seed++) {
        final steps = _run(seededGrid(seed));
        for (int i = 1; i < steps.length; i++) {
          expect(steps[i].visited.containsAll(steps[i - 1].visited), isTrue, reason: 'seed $seed step $i');
          expect(steps[i].visited.length, steps[i - 1].visited.length + 1, reason: 'seed $seed step $i');
        }
      }
    });

    test('S7: the goal is in visited on the terminal step', () {
      final grid = openGrid(startRow: 3, startCol: 3, endRow: 9, endCol: 11);
      final steps = _run(grid);

      expect(steps.last.phase, PFPhase.found);
      expect(steps.last.visited.contains(grid.end), isTrue);
    });
  });

  group('cross-algorithm (SC-001, SC-002, S6, B3)', () {
    test('over 100 seeded grids A* and BFS agree on the shortest-path length', () {
      int solvable = 0;

      for (int seed = 0; seed < 100; seed++) {
        final grid = seededGrid(seed);
        final bfs = _runBfs(grid).last;
        final aStar = _run(grid).last;

        expect(aStar.phase, bfs.phase, reason: 'seed $seed: the two disagree on solvability');

        if (bfs.phase != PFPhase.found) continue;
        solvable++;

        expect(aStar.path!.length, bfs.path!.length, reason: 'seed $seed: A* path is not shortest');
        expectUniversalClauses(_runBfs(grid), grid, label: 'bfs seed $seed');
        expectUniversalClauses(_run(grid), grid, label: 'a* seed $seed');
      }

      expect(solvable, greaterThan(10),
          reason: 'the seeded set must contain solvable grids to be meaningful');
    });
  });
}
