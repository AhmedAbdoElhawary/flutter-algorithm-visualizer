part of 'package:algorithm_visualizer/features/visualize/sub_view/searching/view_model/searching_notifier.dart';

class AStarSearchingNotifier extends SearchingNotifier {
  @override
  SearchingState build() => SearchingState.initial();

  @override
  List<PFStep> buildAlgorithm(List<List<bool>> walls) {
    final steps = <PFStep>[];
    final start = pfEncode(kPFStartRow, kPFStartCol);
    final end = pfEncode(kPFEndRow, kPFEndCol);

    int heuristic(int encoded) => (pfDecodeRow(encoded) - kPFEndRow).abs() + (pfDecodeCol(encoded) - kPFEndCol).abs();

    final gScore = <int, int>{start: 0};
    final fScore = <int, int>{start: heuristic(start)};
    final parent = <int, int>{};
    final openSet = <int>{start};
    final closed = <int>{};

    steps.add(PFStep(
      visited: {},
      frontier: {start},
      statusText: 'A*: start h=${heuristic(start)}, f=${heuristic(start)}',
    ));

    while (openSet.isNotEmpty) {
      final current = openSet.reduce(
        (a, b) => (fScore[a] ?? _kInfinity) <= (fScore[b] ?? _kInfinity) ? a : b,
      );

      if (current == end) {
        final path = _buildPath(current, parent);
        steps.add(PFStep(
          visited: Set.from(closed),
          frontier: Set.from(openSet),
          path: path,
          statusText: '✓ A* found optimal path! Length: ${path.length - 1} steps',
        ));
        return steps;
      }

      openSet.remove(current);
      closed.add(current);

      final row = pfDecodeRow(current);
      final col = pfDecodeCol(current);
      final g = gScore[current]!;

      for (final (dr, dc) in _kOrthogonalDirs) {
        final nextRow = row + dr;
        final nextCol = col + dc;
        if (!_inBounds(nextRow, nextCol) || walls[nextRow][nextCol]) continue;
        final next = pfEncode(nextRow, nextCol);
        if (closed.contains(next)) continue;
        final tentativeG = g + 1;
        if (tentativeG < (gScore[next] ?? _kInfinity)) {
          parent[next] = current;
          gScore[next] = tentativeG;
          fScore[next] = tentativeG + heuristic(next);
          openSet.add(next);
        }
      }

      steps.add(PFStep(
        visited: Set.from(closed),
        frontier: Set.from(openSet),
        statusText:
            'A*: visited ($row, $col) g=$g h=${heuristic(current)} f=${g + heuristic(current)}, open: ${openSet.length}',
      ));
    }

    steps.add(PFStep(
      visited: Set.from(closed),
      frontier: {},
      statusText: '✗ No path — search space exhausted',
    ));
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
  int codeLineForStep(SortingStep step) {
    final pfStep = step as PFStep;
    final desc = pfStep.statusText;

    if (desc.startsWith('A*: start')) return 0;
    if (desc.startsWith('✓')) return 3;
    if (desc.startsWith('✗')) return 1;
    if (desc.contains('visited')) return 2;

    return 4;
  }
}
