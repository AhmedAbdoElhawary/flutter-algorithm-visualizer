import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/search_role.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/grid_scroll_lock.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/end_point.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/pf_grid_painter.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/start_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/searching_notifier.dart';

enum _DragMode { none, start, end, wall }

class PFGrid extends ConsumerStatefulWidget {
  const PFGrid({required this.instance, super.key});
  final NotifierProvider<SearchingNotifier, SearchingState> instance;

  @override
  ConsumerState<PFGrid> createState() => _PFGridState();
}

class _PFGridState extends ConsumerState<PFGrid> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  final ValueNotifier<int> _frame = ValueNotifier<int>(0);

  double _settleAt = 0;

  final Map<int, double> _wallAnimations = {};
  final Map<int, double> _visitedAnimations = {};
  final Map<int, double> _pathAnimations = {};

  _DragMode _dragMode = _DragMode.none;

  Offset? _markerAt;

  int? _searcherFrom;
  double _searcherMoveAt = 0;

  int? _searcherCell(SearchingState? state) {
    if (state == null) return null;
    final steps = state.steps;
    if (steps == null || state.stepIndex == 0) return null;
    final step = steps[state.stepIndex];
    if (step.phase != PFPhase.exploring) return null;
    final expanded = step.visited.difference(steps[state.stepIndex - 1].visited);
    return expanded.length == 1 ? expanded.first : null;
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      _frame.value++;
      if (_nowMs() >= _settleAt) _ticker.stop();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  static double _nowMs() => DateTime.now().millisecondsSinceEpoch.toDouble();

  void _keepTickingUntil(double until) {
    if (until > _settleAt) _settleAt = until;
    if (!_ticker.isActive) _ticker.start();
  }

  (int row, int col) _cellAt(Offset localPosition, double cellSize) => (
        (localPosition.dy / cellSize).floor().clamp(0, kPFRows - 1),
        (localPosition.dx / cellSize).floor().clamp(0, kPFCols - 1),
      );

  /// How many cells away `row`/`col` is from `markerRow`/`markerCol`, using
  /// the larger of the row/column gap so a diagonal touch counts the same as
  /// a straight one.
  int _cellDistance(int row, int col, int markerRow, int markerCol) =>
      (row - markerRow).abs() > (col - markerCol).abs() ? (row - markerRow).abs() : (col - markerCol).abs();

  void _handleGestureStart(Offset localPosition, double cellSize) {
    final (row, col) = _cellAt(localPosition, cellSize);
    final notifier = ref.read(widget.instance.notifier);
    final state = ref.read(widget.instance);

    final startDistance = _cellDistance(row, col, state.startRow, state.startCol);
    final endDistance = _cellDistance(row, col, state.endRow, state.endCol);
    final nearStart = startDistance <= kMarkerGrabRadius;
    final nearEnd = endDistance <= kMarkerGrabRadius;

    if ((nearStart || nearEnd) && notifier.markersMovable) {
      // Both markers could claim an overlapping touch; give it to whichever is closer.
      _dragMode = nearStart && (!nearEnd || startDistance <= endDistance) ? _DragMode.start : _DragMode.end;
      setState(() => _markerAt = localPosition);
      return;
    }
    if (nearStart || nearEnd || !notifier.wallsEditable) {
      _dragMode = _DragMode.none;
      return;
    }
    _dragMode = _DragMode.wall;
    notifier.setWall(row, col, isGestureStart: true);
  }

  void _handleGestureUpdate(Offset localPosition, double cellSize) {
    switch (_dragMode) {
      case _DragMode.start:
      case _DragMode.end:
        setState(() => _markerAt = localPosition);
      case _DragMode.wall:
        final (row, col) = _cellAt(localPosition, cellSize);
        ref.read(widget.instance.notifier).setWall(row, col, isGestureStart: false);
      case _DragMode.none:
        break;
    }
  }

  void _handleGestureEnd(double cellSize) {
    final at = _markerAt;
    if (at != null) {
      final (row, col) = _cellAt(at, cellSize);
      final notifier = ref.read(widget.instance.notifier);
      if (_dragMode == _DragMode.start) notifier.setStartPoint(row, col);
      if (_dragMode == _DragMode.end) notifier.setEndPoint(row, col);
      setState(() => _markerAt = null);
    }
    _dragMode = _DragMode.none;
  }

  int _syncStamps(Map<int, double> stamps, Set<int> previous, Set<int> next, double now) {
    stamps.removeWhere((id, _) => !next.contains(id));
    final added = next.difference(previous);
    for (final id in added) {
      stamps[id] = now;
    }
    return added.length;
  }

  Widget _markerSlot({
    required _DragMode mode,
    required int row,
    required int col,
    required double cellSize,
    required double gridWidth,
    required double gridHeight,
    required Widget child,
  }) {
    final at = _dragMode == mode ? _markerAt : null;
    return Positioned(
      left: at != null ? (at.dx - cellSize / 2).clamp(0.0, gridWidth - cellSize) : col * cellSize,
      top: at != null ? (at.dy - cellSize / 2).clamp(0.0, gridHeight - cellSize) : row * cellSize,
      width: cellSize,
      height: cellSize,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final walls = ref.watch(widget.instance.select((s) => s.walls));
    final step = ref.watch(widget.instance.select((s) => s.currentStep));
    final markers = ref.watch(
      widget.instance.select((s) => (s.startRow, s.startCol, s.endRow, s.endCol)),
    );
    final (startRow, startCol, endRow, endCol) = markers;
    final state = ref.watch(widget.instance);
    final searcherCell = _searcherCell(state);

    // Never longer than one playback step, or the searcher would be asked to
    // leave a cell it has not reached yet.
    final stepMs = state.speed.stepSearchingDuration.inMilliseconds.toDouble();
    final jumpMs = stepMs < kSearcherJumpMs ? stepMs : kSearcherJumpMs;

    ref.listen(widget.instance, (prev, next) {
      final now = DateTime.now().millisecondsSinceEpoch.toDouble();

      // A stamp is only worth keeping while its animation is still running.
      _wallAnimations.removeWhere((_, v) => now - v > kWallPopMs);
      _visitedAnimations.removeWhere((_, v) => now - v > kReleaseTotalMs);
      final prevPathLength = prev?.currentStep?.path?.length ?? 0;
      _pathAnimations.removeWhere((_, v) => now - v > prevPathLength * kPathCellMs);

      var wallsAdded = false;
      for (int r = 0; r < kPFRows; r++) {
        for (int c = 0; c < kPFCols; c++) {
          final pW = prev?.walls[r][c] ?? false;
          final nW = next.walls[r][c];
          final encoded = pfEncode(r, c);
          if (!pW && nW) {
            _wallAnimations[encoded] = now;
            wallsAdded = true;
          } else if (pW && !nW) {
            _wallAnimations.remove(encoded);
          }
        }
      }
      if (wallsAdded) _keepTickingUntil(now + kWallPopMs);

      final visited = next.currentStep?.visited ?? const <int>{};
      _visitedAnimations.removeWhere((id, _) => !visited.contains(id));

      final leftBehind = _searcherCell(prev);
      final searcher = _searcherCell(next);
      if (leftBehind != searcher) {
        _searcherFrom = leftBehind;
        _searcherMoveAt = now;
        // The slide needs the ticker even when nothing is released behind it,
        // which is what stepping backward looks like.
        if (leftBehind != null) _keepTickingUntil(now + kSearcherJumpMs);
      }
      if (leftBehind != null && leftBehind != searcher && visited.contains(leftBehind)) {
        _visitedAnimations[leftBehind] = now;
        _keepTickingUntil(now + kReleaseTotalMs);
      }
      if (searcher != null) _visitedAnimations.remove(searcher);

      final nextPath = next.currentStep?.path;
      final pathAdded = _syncStamps(
        _pathAnimations,
        prev?.currentStep?.path?.toSet() ?? {},
        nextPath?.toSet() ?? {},
        now,
      );
      if (pathAdded > 0) {
        _keepTickingUntil(now + (nextPath?.length ?? 0) * kPathCellMs);
      }
    });

    return HorizontalPadding(
      padding: 16,
      child: CardContainer(
        surface: CdSurface.outlined,
        clip: true,
        padding: EdgeInsets.zero,
        child: LayoutBuilder(builder: (context, constraints) {
          final cellSize = constraints.maxWidth / kPFCols;
          final gridHeight = cellSize * kPFRows;

          return Listener(
            onPointerDown: (e) {
              ref.read(gridScrollLockProvider.notifier).lock();
              _handleGestureStart(e.localPosition, cellSize);
            },
            onPointerMove: (e) => _handleGestureUpdate(e.localPosition, cellSize),
            onPointerUp: (_) {
              ref.read(gridScrollLockProvider.notifier).release();
              _handleGestureEnd(cellSize);
            },
            onPointerCancel: (_) {
              ref.read(gridScrollLockProvider.notifier).release();
              _handleGestureEnd(cellSize);
            },
            child: SizedBox(
              width: constraints.maxWidth,
              height: gridHeight,
              child: Stack(
                children: [
                  RepaintBoundary(
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, gridHeight),
                      painter: PFGridPainter(
                        walls: walls,
                        step: step,
                        isDark: context.isThemeDark,
                        searcherCell: searcherCell,
                        searcherFrom: _searcherFrom,
                        searcherMoveAt: _searcherMoveAt,
                        searcherJumpMs: jumpMs,
                        wallColor: context.getColor(searchRoleColor(SearchRole.wall)),
                        pathColor: context.getColor(searchRoleColor(SearchRole.path)),
                        searcherColor: context.getColor(searchRoleColor(SearchRole.searcher)),
                        trail0Color: context.getColor(ThemeEnum.searchTrail0),
                        trail1Color: context.getColor(ThemeEnum.searchTrail1),
                        visitedColor: context.getColor(searchRoleColor(SearchRole.visited)),
                        gridLineColor: context.getColor(ThemeEnum.hairline),
                        wallAnimations: _wallAnimations,
                        visitedAnimations: _visitedAnimations,
                        pathAnimations: _pathAnimations,
                        repaint: _frame,
                      ),
                    ),
                  ),
                  _markerSlot(
                    mode: _DragMode.start,
                    row: startRow,
                    col: startCol,
                    cellSize: cellSize,
                    gridWidth: constraints.maxWidth,
                    gridHeight: gridHeight,
                    child: PFStartPointWidget(
                      size: cellSize,
                      color: context.getColor(searchRoleColor(SearchRole.start)),
                    ),
                  ),
                  _markerSlot(
                    mode: _DragMode.end,
                    row: endRow,
                    col: endCol,
                    cellSize: cellSize,
                    gridWidth: constraints.maxWidth,
                    gridHeight: gridHeight,
                    child: PFEndPointWidget(
                      size: cellSize,
                      outerColor: context.getColor(searchRoleColor(SearchRole.end)),
                      midColor: ColorManager.inkPrimaryDk,
                      innerColor: context.getColor(searchRoleColor(SearchRole.end)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
