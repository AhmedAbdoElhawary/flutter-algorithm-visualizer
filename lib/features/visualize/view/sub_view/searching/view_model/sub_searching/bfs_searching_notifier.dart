part of 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';

class BFSSearchingNotifier extends SearchingNotifier {
  @override
  PFRule get rule => PFRule.oldestFirst;

  @override
  List<PFStep> buildAlgorithm(PFGridInput grid) {
    final start = grid.start;
    final end = grid.end;

    if (start == end) {
      return [
        PFStep(visited: {start}, frontier: {}, path: [start], phase: PFPhase.found, metricA: 0),
      ];
    }

    final steps = <PFStep>[];
    final discovered = <int>{start};
    final visited = <int>{};
    final parent = <int, int>{};
    final queue = <int>[start];

    steps.add(PFStep(visited: {}, frontier: {start}, phase: PFPhase.exploring, metricA: queue.length));

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      visited.add(current);

      if (current == end) {
        steps.add(PFStep(
          visited: Set.of(visited),
          frontier: queue.toSet(),
          path: _buildPath(current, parent),
          phase: PFPhase.found,
          metricA: queue.length,
        ));
        return steps;
      }

      final row = pfDecodeRow(current);
      final col = pfDecodeCol(current);
      for (final (dr, dc) in _kOrthogonalDirs) {
        final nextRow = row + dr;
        final nextCol = col + dc;
        if (!grid.inBounds(nextRow, nextCol) || grid.isWall(nextRow, nextCol)) continue;
        final next = pfEncode(nextRow, nextCol);
        if (!discovered.add(next)) continue;
        parent[next] = current;
        queue.add(next);
      }

      steps.add(PFStep(
        visited: Set.of(visited),
        frontier: queue.toSet(),
        phase: queue.isEmpty ? PFPhase.exhausted : PFPhase.exploring,
        metricA: queue.length,
      ));
    }

    return steps;
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.bFS,
    bestTimeComplexity: ONotationComplexity.vPlusE,
    averageTimeComplexity: ONotationComplexity.vPlusE,
    worstTimeComplexity: ONotationComplexity.vPlusE,
    spaceComplexity: ONotationComplexity.vPlusE,
    stable: true,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get algorithmDescription => StringsManager.breadthFirstSearchDescription;

  @override
  List<String> get codeSnippet => const [
        'enqueue(start)', // 0
        'while queue is not empty', // 1
        '  current = dequeue()', // 2
        '  if current == goal return path', // 3
        '  for each neighbor', // 4
        '    if not visited', // 5
        '      mark visited', // 6
        '      enqueue(neighbor)', // 7
      ];

  @override
  int codeLineForStep(SortStep step) {
    final pfStep = step as PFStep;

    switch (pfStep.phase) {
      case PFPhase.found:
        return 3;
      case PFPhase.exhausted:
        return 1;
      case PFPhase.exploring:
        return 2;
    }
  }
}
