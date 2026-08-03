part of 'package:algorithm_visualizer/features/searching/base/view_model/searching_notifier.dart';

class BFSSearchingNotifier extends SearchingNotifier {
  @override
  List<PFStep> buildAlgorithm(List<List<bool>> walls) {
    final steps = <PFStep>[];
    final visited = <int>{};
    final parent = <int, int>{};
    final start = pfEncode(kPFStartRow, kPFStartCol);
    final end = pfEncode(kPFEndRow, kPFEndCol);

    visited.add(start);
    final queue = <int>[start];

    steps.add(PFStep(
      visited: {start},
      frontier: {start},
      description: 'BFS: queue initialized with start ($kPFStartRow, $kPFStartCol)',
    ));

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final row = pfDecodeRow(current);
      final col = pfDecodeCol(current);

      if (current == end) {
        final path = _buildPath(current, parent);
        steps.add(PFStep(
          visited: Set.from(visited),
          frontier: Set.from(queue),
          path: path,
          description: '✓ BFS found shortest path! Length: ${path.length - 1} steps',
        ));
        return steps;
      }

      for (final (dr, dc) in _kOrthogonalDirs) {
        final nextRow = row + dr;
        final nextCol = col + dc;
        if (!_inBounds(nextRow, nextCol) || walls[nextRow][nextCol]) continue;
        final next = pfEncode(nextRow, nextCol);
        if (visited.contains(next)) continue;
        visited.add(next);
        parent[next] = current;
        queue.add(next);
      }

      steps.add(PFStep(
        visited: Set.from(visited),
        frontier: Set.from(queue),
        description: 'BFS: dequeued ($row, $col) — queue size: ${queue.length}',
      ));
    }

    steps.add(PFStep(
      visited: Set.from(visited),
      frontier: {},
      description: '✗ No path — all reachable cells explored',
    ));
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
  String get description => StringsManager.breadthFirstSearchDescription;

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
  int codeLineForStep(SortingStep step) {
    final pfStep = step as PFStep;
    final desc = pfStep.description;

    if (desc.startsWith('BFS: queue initialized')) return 0;
    if (desc.startsWith('✓')) return 3;
    if (desc.startsWith('✗')) return 1;
    if (desc.contains('dequeued')) return 2;

    return 4;
  }
}
