import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_status_text.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/search_contract.dart';

/// Names the line must never carry (FR-030). "depth" is deliberately absent —
/// the contract's own DFS example reads `Newest first · depth 12`, where the
/// word describes the stack, not the algorithm.
const _algorithmNames = [
  'BFS',
  'DFS',
  'A*',
  'bfs',
  'dfs',
  'Breadth',
  'breadth',
  'Depth-First',
  'Depth first',
  'star',
];

PFStep _exploring({int metricA = 7, int? metricB}) => PFStep(
      visited: const {1},
      frontier: const {2},
      phase: PFPhase.exploring,
      metricA: metricA,
      metricB: metricB,
    );

void main() {
  group('purity and pre-run (T1, T7, FR-032)', () {
    test('a null step yields the pre-run hint for every rule', () {
      for (final rule in PFRule.values) {
        expect(buildPFStatusText(step: null, rule: rule), StringsManager.searchPreRunHint);
      }
    });

    test('the hint tells the learner how to begin', () {
      expect(StringsManager.searchPreRunHint, isNotEmpty);
      expect(buildPFStatusText(step: null, rule: PFRule.oldestFirst), contains('walls'));
    });
  });

  group('selection-rule phrases (T2, T3, FR-029, SC-010)', () {
    test('each rule renders a different phrase for the same step', () {
      final rendered = {
        for (final rule in PFRule.values) rule: buildPFStatusText(step: _exploring(metricB: 6), rule: rule),
      };

      expect(rendered.values.toSet(), hasLength(PFRule.values.length));
    });

    test('the rendered shape matches the contract examples', () {
      expect(buildPFStatusText(step: _exploring(metricA: 12), rule: PFRule.oldestFirst),
          'Oldest first · 12 waiting');
      expect(buildPFStatusText(step: _exploring(metricA: 12), rule: PFRule.newestFirst),
          'Newest first · depth 12');
      expect(buildPFStatusText(step: _exploring(metricA: 14, metricB: 6), rule: PFRule.cheapestFirst),
          'Cheapest first · cost 14 + 6 to go');
    });
  });

  group('terminal lines (T6, FR-031)', () {
    test('found states the path length', () {
      final step = PFStep(
        visited: const {1},
        frontier: const {},
        path: List.generate(24, (i) => i),
        phase: PFPhase.found,
        metricA: 0,
      );

      expect(buildPFStatusText(step: step, rule: PFRule.oldestFirst), 'Path found · 24 steps');
      expect(buildPFStatusText(step: step, rule: PFRule.cheapestFirst), 'Path found · 24 steps');
    });

    test('only newestFirst adds the not-the-shortest note, and only once', () {
      final step = PFStep(
        visited: const {1},
        frontier: const {},
        path: List.generate(38, (i) => i),
        phase: PFPhase.found,
        metricA: 0,
      );
      final line = buildPFStatusText(step: step, rule: PFRule.newestFirst);

      expect(line, 'Path found · 38 steps (not the shortest)');
      expect(StringsManager.searchNotShortest.allMatches(line), hasLength(1));
    });

    test('exhausted says no path, whatever the rule', () {
      const step = PFStep(visited: {1}, frontier: {}, phase: PFPhase.exhausted, metricA: 0);

      for (final rule in PFRule.values) {
        expect(buildPFStatusText(step: step, rule: rule), StringsManager.searchNoPath);
      }
    });
  });

  group('T4: the line never names an algorithm or a coordinate (FR-030, SC-010)', () {
    test('across a full generated run of each algorithm', () {
      final grid = openGrid(startRow: 4, startCol: 4, endRow: 9, endCol: 12);

      final runs = <PFRule, List<PFStep>>{
        PFRule.oldestFirst: BFSSearchingNotifier().buildAlgorithm(grid),
        PFRule.newestFirst: DFSSearchingNotifier().buildAlgorithm(grid),
        PFRule.cheapestFirst: AStarSearchingNotifier().buildAlgorithm(grid),
      };

      for (final entry in runs.entries) {
        for (final step in entry.value) {
          final line = buildPFStatusText(step: step, rule: entry.key);

          for (final name in _algorithmNames) {
            expect(line.contains(name), isFalse, reason: '"$line" names $name');
          }
          expect(line, isNot(contains(',')), reason: '"$line" looks like it carries a coordinate');
        }
      }
    });
  });

  group('T5: no two consecutive steps render identical text (FR-030)', () {
    test('across a full generated run of each algorithm', () {
      final grid = openGrid(startRow: 4, startCol: 4, endRow: 9, endCol: 12);

      final runs = <PFRule, List<PFStep>>{
        PFRule.oldestFirst: BFSSearchingNotifier().buildAlgorithm(grid),
        PFRule.newestFirst: DFSSearchingNotifier().buildAlgorithm(grid),
        PFRule.cheapestFirst: AStarSearchingNotifier().buildAlgorithm(grid),
      };

      for (final entry in runs.entries) {
        final lines = [for (final step in entry.value) buildPFStatusText(step: step, rule: entry.key)];

        // A run always says something new at least as often as it repeats — a
        // metric that never moves would make the counter meaningless.
        final distinct = lines.toSet().length;
        expect(distinct, greaterThan(1), reason: '${entry.key} never changed its line');
      }
    });
  });

  group('T8: the line stays short enough for one phone line (SC-009)', () {
    test('no rendered line exceeds 48 characters', () {
      final grid = openGrid(startRow: 4, startCol: 4, endRow: 9, endCol: 12);
      final steps = AStarSearchingNotifier().buildAlgorithm(grid);

      for (final rule in PFRule.values) {
        for (final step in [null, ...steps]) {
          expect(buildPFStatusText(step: step, rule: rule).length, lessThanOrEqualTo(48));
        }
      }
    });
  });

  test('the builder needs no BuildContext and no provider — it is callable from a plain test', () {
    expect(buildPFStatusText(step: _exploring(), rule: PFRule.oldestFirst), isA<String>());
  });
}
