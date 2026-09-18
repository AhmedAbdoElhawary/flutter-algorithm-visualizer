import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_grid_input.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_status_text.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/search_contract.dart';

List<PFStep> _run(PFGridInput grid) => BFSSearchingNotifier().buildAlgorithm(grid);

void main() {
  test('rule is oldestFirst (B1)', () {
    expect(BFSSearchingNotifier().rule, PFRule.oldestFirst);
  });

  group('universal clauses A1–A9', () {
    test('hold on an open grid, whatever the markers', () {
      for (final grid in [
        openGrid(),
        openGrid(startRow: 0, startCol: 0, endRow: kPFRows - 1, endCol: kPFCols - 1),
        openGrid(startRow: 23, startCol: 29, endRow: 0, endCol: 0),
      ]) {
        expectUniversalClauses(_run(grid), grid, label: 'bfs open');
      }
    });

    test('hold on 30 seeded random grids', () {
      for (int seed = 0; seed < 30; seed++) {
        final grid = seededGrid(seed);
        expectUniversalClauses(_run(grid), grid, label: 'bfs seed $seed');
      }
    });

    test('A7: two runs on an equal input are element-wise equal', () {
      for (int seed = 0; seed < 5; seed++) {
        expectDeterministic(_run, seededGrid(seed), label: 'bfs seed $seed');
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
      expect(steps.last.path, isNull);
      expect(steps.where((s) => s.phase == PFPhase.exhausted), hasLength(1));
      expectUniversalClauses(steps, grid, label: 'bfs walled in');
    });
  });

  group('BFS clauses B2–B4', () {
    test('B2: a cell enters visited only when it is expanded, never when enqueued', () {
      final grid = openGrid(startRow: 5, startCol: 5, endRow: 5, endCol: 12);
      final steps = _run(grid);

      // The step after the seed expands exactly one cell — the start.
      expect(steps[1].visited, {grid.start});
      // Its four neighbours are discovered but still waiting.
      expect(steps[1].frontier, hasLength(4));
      expect(steps[1].frontier.contains(grid.start), isFalse);
    });

    test('B2: visited grows by exactly one cell per step', () {
      final grid = seededGrid(7);
      final steps = _run(grid);

      for (int i = 2; i < steps.length; i++) {
        expect(steps[i].visited.length, steps[i - 1].visited.length + 1, reason: 'step $i');
      }
    });

    test('B3: the path is a shortest path on a grid with a known answer', () {
      // A straight corridor forced around a single block.
      final grid = gridOf([
        'S....',
        '####.',
        'E....',
      ]);
      final steps = _run(grid);

      expect(steps.last.phase, PFPhase.found);
      expect(steps.last.path, hasLength(11));
    });

    test('B3: on an open grid the path is the Manhattan distance plus one', () {
      final grid = openGrid(startRow: 3, startCol: 3, endRow: 9, endCol: 11);
      final steps = _run(grid);

      expect(steps.last.path, hasLength((9 - 3) + (11 - 3) + 1));
    });

    test('B4: metricA is the queue length after the expansion, metricB is null', () {
      final grid = seededGrid(3);
      final steps = _run(grid);

      for (final step in steps) {
        expect(step.metricB, isNull);
        expect(step.metricA, step.frontier.length);
      }
    });
  });
}
