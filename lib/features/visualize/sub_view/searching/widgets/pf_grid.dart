import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/card_container.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/helper/search_role.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/view_model/grid_scroll_lock.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/widgets/end_point.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/widgets/pf_grid_painter.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/widgets/start_point.dart';
import 'package:flutter/material.dart';
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
  late AnimationController _controller;

  final Map<int, double> _wallAnimations = {};
  final Map<int, double> _frontierAnimations = {};
  final Map<int, double> _visitedAnimations = {};
  final Map<int, double> _pathAnimations = {};

  _DragMode _dragMode = _DragMode.none;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 365),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
  void _syncStamps(Map<int, double> stamps, Set<int> previous, Set<int> next, double now) {
    stamps.removeWhere((id, _) => !next.contains(id));
    for (final id in next.difference(previous)) {
      stamps[id] = now;
    }
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

      for (int r = 0; r < kPFRows; r++) {
        for (int c = 0; c < kPFCols; c++) {
          final pW = prev?.walls[r][c] ?? false;
          final nW = next.walls[r][c];
          final encoded = pfEncode(r, c);
          if (!pW && nW) {
            _wallAnimations[encoded] = now;
          } else if (pW && !nW) {
            _wallAnimations.remove(encoded);
          }
        }
      }

      _syncStamps(
        _frontierAnimations,
        prev?.currentStep?.frontier ?? {},
        next.currentStep?.frontier ?? {},
        now,
      );
      _syncStamps(
        _visitedAnimations,
        prev?.currentStep?.visited ?? {},
        next.currentStep?.visited ?? {},
        now,
      );
      _syncStamps(
        _pathAnimations,
        prev?.currentStep?.path?.toSet() ?? {},
        next.currentStep?.path?.toSet() ?? {},
        now,
      );
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
                    CustomPaint(
                      size: Size(constraints.maxWidth, gridHeight),
                      painter: PFGridPainter(
                        walls: walls,
                        step: step,
                        isDark: context.isThemeDark,
                        wallColor: context.getColor(searchRoleColor(SearchRole.wall)),
                        pathColor: context.getColor(searchRoleColor(SearchRole.path)),
                        searcherColor: context.getColor(searchRoleColor(SearchRole.frontier)),
                        searcherFinishedColor: context.getColor(searchRoleColor(SearchRole.visited)),
                        gridLineColor: context.getColor(ThemeEnum.borderSubtle),
                        wallAnimations: _wallAnimations,
                        frontierAnimations: _frontierAnimations,
                        visitedAnimations: _visitedAnimations,
                        pathAnimations: _pathAnimations,
                        repaint: _controller,
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
                        midColor: context.getColor(ThemeEnum.textBright),
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
