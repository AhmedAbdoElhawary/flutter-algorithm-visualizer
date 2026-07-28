import 'dart:async';
import 'dart:math' as math;

import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_page_view_model.dart';
import 'package:algorithm_visualizer/features/searching/pathfinding/models/pf_step.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pf_constants.dart';
import '../models/searching_state.dart';

const _kInfinity = 1 << 30;
const _kOrthogonalDirs = [(-1, 0), (0, 1), (1, 0), (0, -1)];
// Push order reversed so DFS explores up/right first (top-right biased).
const _kReverseOrthogonalDirs = [(0, -1), (1, 0), (0, 1), (-1, 0)];

abstract class SearchingNotifier extends StateNotifier<SearchingState> implements AlgorithmNotifier {
  SearchingNotifier() : super(SearchingState.initial());

  Timer? _timer;

  /// Whether the current wall-drawing gesture is erasing or drawing walls.
  /// Decided once per gesture (on tap-down / pan-start) and reused for every
  /// cell touched during that same drag — mirrors the original UX.
  bool _erasingGesture = false;

  @override
  void dispose() {
    _clearTimer();
    super.dispose();
  }

  List<PFStep> buildAlgorithm(List<List<bool>> walls);

  bool _inBounds(int row, int col) => row >= 0 && row < kPFRows && col >= 0 && col < kPFCols;

  Set<int> _buildPath(int end, Map<int, int> parent) {
    final path = <int>{};
    int? node = end;
    while (node != null) {
      path.add(node);
      node = parent[node];
    }
    return path;
  }

  void _clearTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    _clearTimer();
    _timer = Timer.periodic(state.speed.stepDuration, (_) {
      final steps = state.steps;
      if (steps == null || state.stepIndex >= steps.length - 1) {
        state = state.copyWith(playing: false);
        _clearTimer();
        return;
      }
      state = state.copyWith(stepIndex: state.stepIndex + 1);
    });
  }

  void _resetSteps() {
    _clearTimer();
    state = state.copyWith(stepIndex: 0, playing: false, clearSteps: true);
  }

  void setWall(int row, int col, {required bool isGestureStart}) {
    if (state.hasSteps) return;
    if (row == kPFStartRow && col == kPFStartCol) return;
    if (row == kPFEndRow && col == kPFEndCol) return;

    if (isGestureStart) {
      _erasingGesture = state.walls[row][col];
    }
    final wantWall = !_erasingGesture;
    if (state.walls[row][col] == wantWall) return;

    final updatedWalls = [for (final r in state.walls) List<bool>.from(r)];
    updatedWalls[row][col] = wantWall;
    state = state.copyWith(walls: updatedWalls);
  }

  void clearWalls() {
    _resetSteps();
    state = state.copyWith(walls: SearchingState.emptyWalls());
  }

  void randomizeWalls() {
    _resetSteps();
    final rng = math.Random();
    final walls = List.generate(
      kPFRows,
      (r) => List.generate(kPFCols, (c) {
        if (r == kPFStartRow && c == kPFStartCol) return false;
        if (r == kPFEndRow && c == kPFEndCol) return false;
        return rng.nextDouble() < 0.30;
      }),
    );
    state = state.copyWith(walls: walls);
  }

  // ── Playback ───────────────────────────────────────────────────────────

  void runAlgorithm() {
    _clearTimer();
    final steps = buildAlgorithm(state.walls);

    state = state.copyWith(steps: steps, stepIndex: 0, playing: true);
    _startTimer();
  }

  void togglePlay() {
    if (!state.hasSteps) {
      runAlgorithm();
      return;
    }
    if (state.isAtEnd) {
      state = state.copyWith(stepIndex: 0, playing: true);
      _startTimer();
      return;
    }
    final playing = !state.playing;
    state = state.copyWith(playing: playing);
    playing ? _startTimer() : _clearTimer();
  }

  void stepForward() {
    _clearTimer();
    if (state.steps == null || state.isAtEnd) return;
    state = state.copyWith(stepIndex: state.stepIndex + 1, playing: false);
  }

  void stepBackward() {
    _clearTimer();
    if (state.isAtStart) return;
    state = state.copyWith(stepIndex: state.stepIndex - 1, playing: false);
  }

  void reset() => _resetSteps();

  PlaybackSpeed _getNextSpeed(PlaybackSpeed speed) {
    return speed == PlaybackSpeed.slow
        ? PlaybackSpeed.normal
        : speed == PlaybackSpeed.normal
            ? PlaybackSpeed.fast3
            : speed == PlaybackSpeed.fast3
                ? PlaybackSpeed.fast5
                : speed == PlaybackSpeed.fast5
                    ? PlaybackSpeed.fast10
                    : PlaybackSpeed.slow;
  }

  void setNextSpeed(PlaybackSpeed speed) {
    state = state.copyWith(speed: _getNextSpeed(speed));
    if (state.playing) _startTimer();
  }
}

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

class AStarSearchingNotifier extends SearchingNotifier {
  @override
  List<PFStep> buildAlgorithm(List<List<bool>> walls) {
    final steps = <PFStep>[];
    final start = pfEncode(kPFStartRow, kPFStartCol);
    final end = pfEncode(kPFEndRow, kPFEndCol);

    int heuristic(int encoded) =>
        (pfDecodeRow(encoded) - kPFEndRow).abs() + (pfDecodeCol(encoded) - kPFEndCol).abs();

    final gScore = <int, int>{start: 0};
    final fScore = <int, int>{start: heuristic(start)};
    final parent = <int, int>{};
    final openSet = <int>{start};
    final closed = <int>{};

    steps.add(PFStep(
      visited: {},
      frontier: {start},
      description: 'A*: start h=${heuristic(start)}, f=${heuristic(start)}',
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
          description: '✓ A* found optimal path! Length: ${path.length - 1} steps',
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
        description:
            'A*: visited ($row, $col) g=$g h=${heuristic(current)} f=${g + heuristic(current)}, open: ${openSet.length}',
      ));
    }

    steps.add(PFStep(
      visited: Set.from(closed),
      frontier: {},
      description: '✗ No path — search space exhausted',
    ));
    return steps;
  }

  static final algorithmComplexity = AlgorithmComplexity(
    name: StringsManager.aStarSearch,
    bestTimeComplexity: ONotationComplexity.eLogV,
    averageTimeComplexity: ONotationComplexity.eLogV,
    worstTimeComplexity: ONotationComplexity.eLogV,
    spaceComplexity: ONotationComplexity.vPlusE,
  );

  @override
  AlgorithmComplexity get algoComplexity => algorithmComplexity;

  @override
  String get description => StringsManager.aStarDescription;

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
    final desc = pfStep.description;

    if (desc.startsWith('A*: start')) return 0;
    if (desc.startsWith('✓')) return 3;
    if (desc.startsWith('✗')) return 1;
    if (desc.contains('visited')) return 2;

    return 4;
  }
}
