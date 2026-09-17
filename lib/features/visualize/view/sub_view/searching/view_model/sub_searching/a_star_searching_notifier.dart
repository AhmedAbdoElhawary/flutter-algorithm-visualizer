part of 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';

class AStarSearchingNotifier extends SearchingNotifier {
  @override
  PFRule get rule => PFRule.cheapestFirst;

  @override
  List<PFStep> buildAlgorithm(PFGridInput grid) {
    final start = grid.start;
    final end = grid.end;

    if (start == end) {
      return [
        PFStep(visited: {start}, frontier: {}, path: [start], phase: PFPhase.found, metricA: 0, metricB: 0),
      ];
    }

    int heuristic(int encoded) =>
        (pfDecodeRow(encoded) - grid.endRow).abs() + (pfDecodeCol(encoded) - grid.endCol).abs();

    final steps = <PFStep>[];
    final gScore = <int, int>{start: 0};
    final parent = <int, int>{};
    final openSet = <int>{start};
    final closed = <int>{};

    int fOf(int cell) => (gScore[cell] ?? _kInfinity) + heuristic(cell);

    /// Lowest `f` wins; on a tie the cell closer to the goal wins, and on a
    /// further tie the lower encoded id — so expansion order never depends on
    /// set iteration order.
    int cheapest() {
      var best = openSet.first;
      for (final cell in openSet) {
        final df = fOf(cell) - fOf(best);
        if (df < 0) {
          best = cell;
        } else if (df == 0) {
          final dh = heuristic(cell) - heuristic(best);
          if (dh < 0 || (dh == 0 && cell < best)) best = cell;
        }
      }
      return best;
    }

    steps.add(PFStep(
      visited: {},
      frontier: {start},
      phase: PFPhase.exploring,
      metricA: 0,
      metricB: heuristic(start),
    ));

    while (openSet.isNotEmpty) {
      final current = cheapest();
      openSet.remove(current);
      closed.add(current);

      final g = gScore[current]!;

      if (current == end) {
        steps.add(PFStep(
          visited: Set.of(closed),
          frontier: Set.of(openSet),
          path: _buildPath(current, parent),
          phase: PFPhase.found,
          metricA: g,
          metricB: heuristic(current),
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
        if (closed.contains(next)) continue;
        final tentativeG = g + 1;
        if (tentativeG < (gScore[next] ?? _kInfinity)) {
          parent[next] = current;
          gScore[next] = tentativeG;
          openSet.add(next);
        }
      }

      steps.add(PFStep(
        visited: Set.of(closed),
        frontier: Set.of(openSet),
        phase: openSet.isEmpty ? PFPhase.exhausted : PFPhase.exploring,
        metricA: g,
        metricB: heuristic(current),
      ));
    }

    return steps;
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.aStarSearch,
    bestTimeComplexity: ONotationComplexity.eLogV,
    averageTimeComplexity: ONotationComplexity.eLogV,
    worstTimeComplexity: ONotationComplexity.eLogV,
    spaceComplexity: ONotationComplexity.vPlusE,
    stable: true,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get algorithmDescription => StringsManager.aStarDescription;

  @override
  List<String> get codeSnippet => const [
        'openSet = {start}', // 0
        'while openSet is not empty', // 1
        '  current = node with lowest fScore', // 2
        '  if current == goal return path', // 3
        '  for each neighbor', // 4
        '    tentativeG = g(current) + cost', // 5
        '    if tentativeG < g(neighbor)', // 6
        '      update scores and parent', // 7
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
