import 'dart:async';
import 'dart:math' as math;

import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_page_view_model.dart';
import 'package:algorithm_visualizer/features/searching/base/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/searching/base/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'package:algorithm_visualizer/features/searching/star/view_model/a_star_searching_notifier.dart';
part 'package:algorithm_visualizer/features/searching/bfs/view_model/bfs_searching_notifier.dart';
part 'package:algorithm_visualizer/features/searching/dfs/view_model/dfs_searching_notifier.dart';
part 'searching_state.dart';

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
