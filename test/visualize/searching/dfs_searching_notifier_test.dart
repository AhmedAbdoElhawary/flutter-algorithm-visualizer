import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_grid_input.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_status_text.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/search_contract.dart';

List<PFStep> _run(PFGridInput grid) => DFSSearchingNotifier().buildAlgorithm(grid);

List<PFStep> _runBfs(PFGridInput grid) => BFSSearchingNotifier().buildAlgorithm(grid);

void main() {
  test('rule is newestFirst (D1)', () {
    expect(DFSSearchingNotifier().rule, PFRule.newestFirst);
  });

  group('universal clauses A1–A9', () {
    test('hold on an open grid, whatever the markers', () {
      for (final grid in [
        openGrid(),
        openGrid(startRow: 0, startCol: 0, endRow: kPFRows - 1, endCol: kPFCols - 1),
        openGrid(startRow: 23, startCol: 29, endRow: 0, endCol: 0),
      ]) {
        expectUniversalClauses(_run(grid), grid, label: 'dfs open');
      }
    });

    test('hold on 30 seeded random grids', () {
      for (int seed = 0; seed < 30; seed++) {
        final grid = seededGrid(seed);
        expectUniversalClauses(_run(grid), grid, label: 'dfs seed $seed');
      }
    });

    test('A7/D5: the fixed push order makes two runs element-wise equal', () {
      for (int seed = 0; seed < 5; seed++) {
        expectDeterministic(_run, seededGrid(seed), label: 'dfs seed $seed');
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
      expectUniversalClauses(steps, grid, label: 'dfs walled in');
    });
  });

  group('DFS clauses D1–D5', () {
    test('D1: expansion follows the most recently discovered cell — it dives, it does not fan out', () {
      final grid = openGrid(startRow: 12, startCol: 15, endRow: 23, endCol: 0);
      final steps = _run(grid);

      // Every dive from the middle of an open grid walks one row up at a time
      // until it reaches the top edge.
      for (int i = 1; i <= 12; i++) {
        final expanded = steps[i].visited.difference(steps[i - 1].visited);
        expect(expanded, hasLength(1), reason: 'step $i expands exactly one cell');
        expect(pfDecodeRow(expanded.single), 12 - (i - 1), reason: 'step $i should be one row further up');
        expect(pfDecodeCol(expanded.single), 15, reason: 'step $i should stay in the same column');
      }
    });

    test('D2: a pop of an already-visited cell appends no step', () {
      for (int seed = 0; seed < 10; seed++) {
        final grid = seededGrid(seed);
        final steps = _run(grid);

        // One seed step plus exactly one step per genuinely expanded cell.
        expect(
          steps.length,
          steps.last.visited.length + 1,
          reason: 'seed $seed: a skipped pop leaked a step',
        );
      }
    });

    test('D2: visited grows by exactly one cell per step', () {
      final grid = seededGrid(11);
      final steps = _run(grid);

      for (int i = 2; i < steps.length; i++) {
        expect(steps[i].visited.length, steps[i - 1].visited.length + 1, reason: 'step $i');
      }
    });

    test('D3: the path is valid but need not be the shortest', () {
      final grid = openGrid(startRow: 12, startCol: 15, endRow: 12, endCol: 16);
      final dfs = _run(grid).last;
      final bfs = _runBfs(grid).last;

      expect(dfs.phase, PFPhase.found);
      expect(bfs.path, hasLength(2));
      expect(dfs.path!.length, greaterThan(bfs.path!.length));
    });

    test('D4: metricA is the stack depth after the expansion, metricB is null', () {
      final grid = seededGrid(5);
      final steps = _run(grid);

      for (final step in steps) {
        expect(step.metricB, isNull);
        // The stack may hold a cell more than once, so depth is never below
        // the number of cells still waiting.
        expect(step.metricA, greaterThanOrEqualTo(step.frontier.length));
      }
    });
  });
}
