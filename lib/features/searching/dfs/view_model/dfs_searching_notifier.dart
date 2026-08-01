part of 'package:algorithm_visualizer/features/searching/base/view_model/searching_notifier.dart';

class DFSSearchingNotifier extends SearchingNotifier {
  @override
  List<PFStep> buildAlgorithm(List<List<bool>> walls) {
    final steps = <PFStep>[];
    final visited = <int>{};
    final discovered = <int>{};
    final parent = <int, int>{};
    final start = pfEncode(kPFStartRow, kPFStartCol);
    final end = pfEncode(kPFEndRow, kPFEndCol);

    final stack = <int>[start];
    discovered.add(start);

    steps.add(PFStep(
      visited: {},
      frontier: {start},
      description: 'DFS: stack initialized with start ($kPFStartRow, $kPFStartCol)',
    ));

    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (visited.contains(current)) continue;
      visited.add(current);
      final row = pfDecodeRow(current);
      final col = pfDecodeCol(current);

      if (current == end) {
        final path = _buildPath(current, parent);
        steps.add(PFStep(
          visited: Set.from(visited),
          frontier: Set.from(stack),
          path: path,
          description: '✓ DFS found a path! Length: ${path.length - 1} steps (may not be shortest)',
        ));
        return steps;
      }

      for (final (dr, dc) in _kReverseOrthogonalDirs) {
        final nextRow = row + dr;
        final nextCol = col + dc;
        if (!_inBounds(nextRow, nextCol) || walls[nextRow][nextCol]) continue;
        final next = pfEncode(nextRow, nextCol);
        if (discovered.contains(next)) continue;
        discovered.add(next);
        parent[next] = current;
        stack.add(next);
      }

      steps.add(PFStep(
        visited: Set.from(visited),
        frontier: Set.from(stack),
        description: 'DFS: popped ($row, $col) — stack depth: ${stack.length}',
      ));
    }

    steps.add(PFStep(
      visited: Set.from(visited),
      frontier: {},
      description: '✗ No path — all reachable cells exhausted',
    ));
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
  String get description => StringsManager.depthFirstSearchDescription;

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
  int codeLineForStep(SortingStep step) {
    final pfStep = step as PFStep;
    final desc = pfStep.description;

    if (desc.startsWith('DFS: stack initialized')) return 0;
    if (desc.startsWith('✓')) return 3;
    if (desc.startsWith('✗')) return 1;
    if (desc.contains('popped')) return 2;

    return 4;
  }
}
