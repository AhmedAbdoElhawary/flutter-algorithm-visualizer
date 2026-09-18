part of 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';

class DFSSearchingNotifier extends SearchingNotifier {
  @override
  PFRule get rule => PFRule.newestFirst;

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
    final visited = <int>{};
    final parent = <int, int>{};

    // Each entry carries the cell that pushed it, so the parent chain is
    // recorded at expansion time — a cell can sit on the stack more than once
    // and only the branch actually expanded may claim it.
    final stack = <(int cell, int? from)>[(start, null)];

    Set<int> frontierOf() => {for (final entry in stack) entry.$1}..removeAll(visited);

    steps.add(PFStep(visited: {}, frontier: {start}, phase: PFPhase.exploring, metricA: stack.length));

    while (stack.isNotEmpty) {
      final (current, from) = stack.removeLast();
      if (visited.contains(current)) continue;
      visited.add(current);
      if (from != null) parent[current] = from;

      if (current == end) {
        steps.add(PFStep(
          visited: Set.of(visited),
          frontier: frontierOf(),
          path: _buildPath(current, parent),
          phase: PFPhase.found,
          metricA: stack.length,
        ));
        return steps;
      }

      final row = pfDecodeRow(current);
      final col = pfDecodeCol(current);
      for (final (dr, dc) in _kReverseOrthogonalDirs) {
        final nextRow = row + dr;
        final nextCol = col + dc;
        if (!grid.inBounds(nextRow, nextCol) || grid.isWall(nextRow, nextCol)) continue;
        final next = pfEncode(nextRow, nextCol);
        if (visited.contains(next)) continue;
        stack.add((next, current));
      }

      final frontier = frontierOf();
      steps.add(PFStep(
        visited: Set.of(visited),
        frontier: frontier,
        phase: frontier.isEmpty ? PFPhase.exhausted : PFPhase.exploring,
        metricA: stack.length,
      ));
    }

    return steps;
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.dFS,
    bestTimeComplexity: ONotationComplexity.vPlusE,
    averageTimeComplexity: ONotationComplexity.vPlusE,
    worstTimeComplexity: ONotationComplexity.vPlusE,
    spaceComplexity: ONotationComplexity.vPlusE,
    stable: false,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get algorithmDescription => StringsManager.depthFirstSearchDescription;

  @override
  List<String> get codeSnippet => const [
        'push(start)', // 0
        'while stack is not empty', // 1
        '  current = pop()', // 2
        '  if current == goal return path', // 3
        '  for each neighbor', // 4
        '    if not discovered', // 5
        '      push(neighbor)', // 6
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
