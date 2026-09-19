import 'dart:async';
import 'dart:math' as math;

import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/base/view_model/algorithm_control_interface.dart';
import 'package:algorithm_visualizer/features/base/view_model/algorithm_description_interface.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_grid_input.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_status_text.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/sub_searching/a_star_searching_notifier.dart';
part 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/sub_searching/bfs_searching_notifier.dart';
part 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/sub_searching/dfs_searching_notifier.dart';
part 'searching_state.dart';

const _kInfinity = 1 << 30;
const _kOrthogonalDirs = [(-1, 0), (0, 1), (1, 0), (0, -1)];
const _kReverseOrthogonalDirs = [(0, -1), (1, 0), (0, 1), (-1, 0)];

abstract class SearchingNotifier extends Notifier<SearchingState>
    implements AlgorithmDescriptionNotifier, AlgorithmControlInterface {
  Timer? _timer;

  bool _erasingGesture = false;
  final Set<int> _strokeToggled = {};
  int? _strokeLastCell;

  @override
  SearchingState build() {
    /// The provider is auto-disposing now (see [BaseViewModel.searchingCards]),
    /// so leaving the visualize tab tears this notifier down. The timer stops
    /// with it, and [isDisposed] lets the view — which holds a direct reference
    /// so it can pause from `dispose()` — know not to touch it any more.
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _clearTimer();
    });

    return SearchingState.initial();
  }

  bool _disposed = false;

  /// Whether this notifier has been torn down.
  bool get isDisposed => _disposed;

  @override
  bool get backwardValidation => state.hasSteps && !state.isAtStart;
  @override
  bool get forwardValidation => state.hasSteps && !state.isAtEnd;

  @override
  bool get isPlaying => state.playing;

  @override
  PlaybackSpeed get getSpeed => state.speed;

  /// How this algorithm chooses the next cell — what the explanation line teaches.
  PFRule get rule;

  List<PFStep> buildAlgorithm(PFGridInput grid);

  /// Walks the parent chain backward from [end], then reverses it, so the
  /// result runs start → end in reveal order.
  List<int> _buildPath(int end, Map<int, int> parent) {
    final path = <int>[];
    int? node = end;
    while (node != null) {
      path.add(node);
      node = parent[node];
    }
    return path.reversed.toList();
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

  /// Every edit clears a displayed result before it is applied, so the grid
  /// never shows a path that belongs to a different maze.
  void _clearResultBeforeEdit() {
    if (state.hasSteps) _resetSteps();
  }

  // ── Start / End markers ────────────────────────────────────────────────

  bool get markersMovable => !state.hasSteps;

  List<List<bool>>? _wallsWithout(int row, int col) {
    if (!state.walls[row][col]) return null;
    final walls = [for (final r in state.walls) List<bool>.from(r)];
    walls[row][col] = false;
    return walls;
  }

  void setStartPoint(int row, int col) {
    if (!markersMovable) return;
    if (!state.gridInput.inBounds(row, col)) return;
    if (row == state.endRow && col == state.endCol) return;
    state = state.copyWith(startRow: row, startCol: col, walls: _wallsWithout(row, col));
  }

  void setEndPoint(int row, int col) {
    if (!markersMovable) return;
    if (!state.gridInput.inBounds(row, col)) return;
    if (row == state.startRow && col == state.startCol) return;
    state = state.copyWith(endRow: row, endCol: col, walls: _wallsWithout(row, col));
  }

  // ── Walls ──────────────────────────────────────────────────────────────

  bool get wallsEditable => !state.playing;

  void setWall(int row, int col, {required bool isGestureStart}) {
    if (!wallsEditable) return;
    if (!state.gridInput.inBounds(row, col)) return;

    if (isGestureStart) {
      _erasingGesture = state.walls[row][col];
      _strokeToggled.clear();
      _strokeLastCell = null;
    }

    final cells = _strokeCells(_strokeLastCell, row, col);
    _strokeLastCell = pfEncode(row, col);

    final wantWall = !_erasingGesture;
    List<List<bool>>? updatedWalls;

    for (final cell in cells) {
      if (!_strokeToggled.add(cell)) continue;

      final cellRow = pfDecodeRow(cell);
      final cellCol = pfDecodeCol(cell);
      if (cellRow == state.startRow && cellCol == state.startCol) continue;
      if (cellRow == state.endRow && cellCol == state.endCol) continue;
      if (state.walls[cellRow][cellCol] == wantWall) continue;

      updatedWalls ??= [for (final r in state.walls) List<bool>.from(r)];
      updatedWalls[cellRow][cellCol] = wantWall;
    }

    if (updatedWalls == null) return;
    _clearResultBeforeEdit();
    state = state.copyWith(walls: updatedWalls);
  }

  List<int> _strokeCells(int? from, int row, int col) {
    if (from == null) return [pfEncode(row, col)];

    int fromRow = pfDecodeRow(from);
    int fromCol = pfDecodeCol(from);
    final deltaRow = (row - fromRow).abs();
    final deltaCol = (col - fromCol).abs();
    final stepRow = fromRow < row ? 1 : -1;
    final stepCol = fromCol < col ? 1 : -1;
    int error = deltaCol - deltaRow;

    final cells = <int>[];
    while (true) {
      cells.add(pfEncode(fromRow, fromCol));
      if (fromRow == row && fromCol == col) break;
      final doubleError = error * 2;
      if (doubleError > -deltaRow) {
        error -= deltaRow;
        fromCol += stepCol;
      }
      if (doubleError < deltaCol) {
        error += deltaCol;
        fromRow += stepRow;
      }
    }
    return cells;
  }

  void clearWalls() {
    _clearResultBeforeEdit();
    state = state.copyWith(walls: SearchingState.emptyWalls());
  }

  void randomizeWalls() {
    _clearResultBeforeEdit();
    final rng = math.Random();
    final walls = List.generate(
      kPFRows,
      (r) => List.generate(kPFCols, (c) {
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
    final steps = buildAlgorithm(state.gridInput);

    state = state.copyWith(steps: steps, stepIndex: 0, playing: true);
    _startTimer();
  }

  @override
  Future<void> togglePlay() async {
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
  void stepForward() => _stepTo(state.stepIndex + 1);

  @override
  void stepBackward() => _stepTo(state.stepIndex - 1);

  /// One shared path for all three algorithms — playback behaves identically
  /// whichever one is selected.
  void _stepTo(int index) {
    _clearTimer();
    final steps = state.steps;
    if (steps == null) {
      state = state.copyWith(playing: false);
      return;
    }
    state = state.copyWith(stepIndex: index.clamp(0, steps.length - 1), playing: false);
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
