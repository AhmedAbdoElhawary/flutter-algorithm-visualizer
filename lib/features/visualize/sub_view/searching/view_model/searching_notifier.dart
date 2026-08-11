import 'dart:async';
import 'dart:math' as math;

import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/algorithm_control_interface.dart';
import 'package:algorithm_visualizer/features/base/view_model/algorithm_description_interface.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'package:algorithm_visualizer/features/visualize/sub_view/searching/view_model/sub_searching/a_star_searching_notifier.dart';
part 'package:algorithm_visualizer/features/visualize/sub_view/searching/view_model/sub_searching/bfs_searching_notifier.dart';
part 'package:algorithm_visualizer/features/visualize/sub_view/searching/view_model/sub_searching/dfs_searching_notifier.dart';
part 'searching_state.dart';

const _kInfinity = 1 << 30;
const _kOrthogonalDirs = [(-1, 0), (0, 1), (1, 0), (0, -1)];
const _kReverseOrthogonalDirs = [(0, -1), (1, 0), (0, 1), (-1, 0)];

abstract class SearchingNotifier extends StateNotifier<SearchingState>
    implements AlgorithmDescriptionNotifier, AlgorithmControlInterface {
  SearchingNotifier() : super(SearchingState.initial());

  Timer? _timer;
  bool _erasingGesture = false;

  @override
  void dispose() {
    _clearTimer();
    super.dispose();
  }

  @override
  bool get backwardValidation => state.hasSteps && !state.isAtStart;
  @override
  bool get forwardValidation => state.hasSteps && !state.isAtEnd;

  @override
  bool get isPlaying => state.playing;

  @override
  PlaybackSpeed get getSpeed => state.speed;

  List<PFStep> buildAlgorithm(List<List<bool>> walls);

  bool _inBounds(int row, int col) => row >= 0 && row < kPFCells && col >= 0 && col < kPFCells;

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
    _timer = Timer.periodic(state.speed.stepSearchingDuration, (_) {
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

  // ── Start / End Point Methods (Now allow dragging & auto-reset steps) ──

  void setStartPoint(int row, int col) {
    if (row == state.endRow && col == state.endCol) return;
    if (state.walls[row][col]) return; // Cannot place on a wall
    _resetSteps();
    state = state.copyWith(startRow: row, startCol: col);
  }

  void setEndPoint(int row, int col) {
    if (row == state.startRow && col == state.startCol) return;
    if (state.walls[row][col]) return; // Cannot place on a wall
    _resetSteps();
    state = state.copyWith(endRow: row, endCol: col);
  }

  void setWall(int row, int col, {required bool isGestureStart}) {
    if (state.hasSteps) return;
    if (row == state.startRow && col == state.startCol) return;
    if (row == state.endRow && col == state.endCol) return;

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
      kPFCells,
      (r) => List.generate(kPFCells, (c) {
        if (r == state.startRow && c == state.startCol) return false;
        if (r == state.endRow && c == state.endCol) return false;
        return rng.nextDouble() < 0.30;
      }),
    );
    state = state.copyWith(walls: walls);
  }

  // ── Playback ───────────────────────────────────────────────────────────

  void _runAlgorithm() {
    _clearTimer();
    final steps = buildAlgorithm(state.walls);

    state = state.copyWith(steps: steps, stepIndex: 0, playing: true);
    _startTimer();
  }

  @override
  Future<void> togglePlay(BuildContext context) async {
    if (!state.hasSteps) {
      _runAlgorithm();
      return;
    }
    if (state.isAtEnd) {
      state = state.copyWith(stepIndex: 0, playing: true);
      _startTimer();
      return;
    }
    final playing = !isPlaying;
    state = state.copyWith(playing: playing);
    playing ? _startTimer() : _clearTimer();
  }

  @override
  void stepForward() {
    _clearTimer();
    if (state.steps == null || state.isAtEnd) return;
    state = state.copyWith(stepIndex: state.stepIndex + 1, playing: false);
  }

  @override
  void stepBackward() {
    _clearTimer();
    if (state.isAtStart) return;
    state = state.copyWith(stepIndex: state.stepIndex - 1, playing: false);
  }

  @override
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

  @override
  void changeSpeed(PlaybackSpeed speed) {
    state = state.copyWith(speed: _getNextSpeed(speed));
    if (isPlaying) _startTimer();
  }
}
