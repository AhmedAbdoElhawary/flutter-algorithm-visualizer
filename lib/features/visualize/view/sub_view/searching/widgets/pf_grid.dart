import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
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

/// How long each kind of cell animation runs, in wall-clock milliseconds.
///
/// These mirror the divisors in `PFGridPainter.paint` — change one and the
/// grid keeps ticking past the end of the motion, or stops before it finishes.
const double _kWallAnimMs = 500;
const double _kSearcherAnimMs = 1500;
const double _kPathAnimMs = 500;

class _PFGridState extends ConsumerState<PFGrid> with SingleTickerProviderStateMixin {
  /// Drives the painter, and only while there is motion to draw.
  ///
  /// This used to be an `AnimationController` with `duration: Duration(days:
  /// 365)` started in `initState` and never stopped. Paired with the painter's
  /// `shouldRepaint => true`, that repainted all 720 cells of the grid sixty
  /// times a second for as long as the screen existed — while paused, while
  /// idle, while scrolled out of sight. It was a battery drain, not just jank.
  ///
  /// A [Ticker] says what is actually wanted here: not an animation with a
  /// value anyone reads, just a request to be called back each frame. It is
  /// started when a cell animation begins and stopped once the last one lands.
  late final Ticker _ticker;

  /// Bumped once per frame; this is what the painter listens to.
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);

  /// Wall-clock ms at which nothing on the canvas is moving any more.
  ///
  /// Every animation is a timestamp plus a fixed duration, so the instant the
  /// last one finishes is known the moment it starts — no polling needed.
  double _settleAt = 0;

  final Map<int, double> _wallAnimations = {};
  final Map<int, double> _frontierAnimations = {};
  final Map<int, double> _visitedAnimations = {};
  final Map<int, double> _pathAnimations = {};

  _DragMode _dragMode = _DragMode.none;

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

  /// Keeps the ticker alive until [until], starting it if it had settled.
  ///
  /// Stopping is safe to do mid-flight: a cell whose stamp has expired clamps
  /// to `t = 1.0` in the painter, which is its finished state — exactly what
  /// the last painted frame already showed. So a stopped grid and a grid still
  /// ticking past the end of its animations look identical.
  void _keepTickingUntil(double until) {
    if (until > _settleAt) _settleAt = until;
    if (!_ticker.isActive) _ticker.start();
  }

  (int row, int col) _cellAt(Offset localPosition, double cellSize) => (
        (localPosition.dy / cellSize).floor().clamp(0, kPFRows - 1),
        (localPosition.dx / cellSize).floor().clamp(0, kPFCols - 1),
      );

  void _handleGestureStart(Offset localPosition, double cellSize) {
    final (row, col) = _cellAt(localPosition, cellSize);
    final state = ref.read(widget.instance);

    if (row == state.startRow && col == state.startCol) {
      _dragMode = _DragMode.start;
    } else if (row == state.endRow && col == state.endCol) {
      _dragMode = _DragMode.end;
    } else {
      _dragMode = _DragMode.wall;
      ref.read(widget.instance.notifier).setWall(row, col, isGestureStart: true);
    }
  }

  void _handleGestureUpdate(Offset localPosition, double cellSize) {
    final (row, col) = _cellAt(localPosition, cellSize);

    if (_dragMode == _DragMode.start) {
      ref.read(widget.instance.notifier).setStartPoint(row, col);
    } else if (_dragMode == _DragMode.end) {
      ref.read(widget.instance.notifier).setEndPoint(row, col);
    } else if (_dragMode == _DragMode.wall) {
      ref.read(widget.instance.notifier).setWall(row, col, isGestureStart: false);
    }
  }

  /// Stamps for cells that are no longer in a set are dropped, so stepping
  /// backward or resetting settles the display on the earlier state instead of
  /// leaving motion behind.
  ///
  /// Returns how many stamps it added, so the caller knows whether a new
  /// animation just started and the ticker has to be woken.
  int _syncStamps(Map<int, double> stamps, Set<int> previous, Set<int> next, double now) {
    stamps.removeWhere((id, _) => !next.contains(id));
    final added = next.difference(previous);
    for (final id in added) {
      stamps[id] = now;
    }
    return added.length;
  }

  @override
  Widget build(BuildContext context) {
    final walls = ref.watch(widget.instance.select((s) => s.walls));
    final step = ref.watch(widget.instance.select((s) => s.currentStep));
    final markers = ref.watch(
      widget.instance.select((s) => (s.startRow, s.startCol, s.endRow, s.endCol)),
    );
    final (startRow, startCol, endRow, endCol) = markers;

    ref.listen(widget.instance, (prev, next) {
      final now = DateTime.now().millisecondsSinceEpoch.toDouble();

      _wallAnimations.removeWhere((_, v) => now - v > 500);
      _frontierAnimations.removeWhere((_, v) => now - v > 1500);
      _visitedAnimations.removeWhere((_, v) => now - v > 1500);
      _pathAnimations.removeWhere((_, v) => now - v > 500);

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
      if (wallsAdded) _keepTickingUntil(now + _kWallAnimMs);

      final frontierAdded = _syncStamps(
        _frontierAnimations,
        prev?.currentStep?.frontier ?? {},
        next.currentStep?.frontier ?? {},
        now,
      );
      final visitedAdded = _syncStamps(
        _visitedAnimations,
        prev?.currentStep?.visited ?? {},
        next.currentStep?.visited ?? {},
        now,
      );
      if (frontierAdded > 0 || visitedAdded > 0) {
        _keepTickingUntil(now + _kSearcherAnimMs);
      }

      final nextPath = next.currentStep?.path;
      final pathAdded = _syncStamps(
        _pathAnimations,
        prev?.currentStep?.path?.toSet() ?? {},
        nextPath?.toSet() ?? {},
        now,
      );
      if (pathAdded > 0) {
        /// The path draws itself out one cell at a time, so the last cell only
        /// *starts* after the whole stagger has run — the grid has to keep
        /// ticking for the walk plus one cell's pop.
        _keepTickingUntil(
          now + (nextPath?.length ?? 0) * kPathStaggerMs + _kPathAnimMs,
        );
      }
    });

    return HorizontalPadding(
      padding: 16,
      // The card's outline eats a pixel or so on each side, so the cell size is
      // measured inside it — otherwise the painter divides a narrower box by
      // kPFCols and the cells stop being square.
      child: CardContainer(
        surface: CdSurface.outlined,
        clip: true,
        padding: EdgeInsets.zero,
        child: LayoutBuilder(builder: (context, constraints) {
          final cellSize = constraints.maxWidth / kPFCols;
          final gridHeight = cellSize * kPFRows;

          // Pointer-down fires before touch slop is exceeded, so the page has
          // already swapped its physics by the time the gesture arena would
          // otherwise hand the drag to the enclosing Scrollable.
          return Listener(
            onPointerDown: (_) => ref.read(gridScrollLockProvider.notifier).lock(),
            onPointerUp: (_) => ref.read(gridScrollLockProvider.notifier).release(),
            onPointerCancel: (_) => ref.read(gridScrollLockProvider.notifier).release(),
            child: GestureDetector(
              onTapDown: (d) => _handleGestureStart(d.localPosition, cellSize),
              onPanStart: (d) => _handleGestureStart(d.localPosition, cellSize),
              onPanUpdate: (d) => _handleGestureUpdate(d.localPosition, cellSize),
              child: SizedBox(
                width: constraints.maxWidth,
                height: gridHeight,
                child: Stack(
                  children: [
                    /// The grid is the one thing on this page that repaints
                    /// per frame while an algorithm runs. Its own layer keeps
                    /// the controls, the legend and the surrounding card from
                    /// being dragged into every one of those repaints.
                    RepaintBoundary(
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, gridHeight),
                        painter: PFGridPainter(
                          walls: walls,
                          step: step,
                          isDark: context.isThemeDark,
                          wallColor: context.getColor(searchRoleColor(SearchRole.wall)),
                          pathColor: context.getColor(searchRoleColor(SearchRole.path)),
                          searcherColor: context.getColor(searchRoleColor(SearchRole.frontier)),
                          searcherFinishedColor:
                              context.getColor(searchRoleColor(SearchRole.visited)),
                          gridLineColor: context.getColor(ThemeEnum.hairline),
                          wallAnimations: _wallAnimations,
                          frontierAnimations: _frontierAnimations,
                          visitedAnimations: _visitedAnimations,
                          pathAnimations: _pathAnimations,
                          repaint: _frame,
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: startCol * cellSize,
                      top: startRow * cellSize,
                      width: cellSize,
                      height: cellSize,
                      child: PFStartPointWidget(
                        size: cellSize,
                        color: context.getColor(searchRoleColor(SearchRole.start)),
                      ),
                    ),
                    PositionedDirectional(
                      start: endCol * cellSize,
                      top: endRow * cellSize,
                      width: cellSize,
                      height: cellSize,
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
            ),
          );
        }),
      ),
    );
  }
}
