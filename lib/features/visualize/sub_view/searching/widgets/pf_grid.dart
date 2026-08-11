import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/widgets/end_point.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/widgets/pf_grid_painter.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/widgets/start_point.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/searching_notifier.dart';

final Color kGridDarkBg = const Color(0xFF060C1A);
final Color kGridLightBg = const Color(0xFFF0F4FF);

final Color kWallGridColor = ColorManager.wallBlack;
final Color kPathGridColor = ColorManager.light2Yellow;

final Color kSearcherStartColor = ColorManager.darkBlue;
final Color kSearcherMediumColor = ColorManager.mediumBlue;
final Color kSearcherFinishedColor = ColorManager.finishedSearcherBlue;

final Color kStartPointIconColor = ColorManager.white;
final Color kTargetOuterColor = ColorManager.darkPurple;
final Color kTargetMidColor = ColorManager.white;
final Color kTargetInnerColor = ColorManager.darkPurple;

enum _DragMode { none, start, end, wall }

class PFGrid extends ConsumerStatefulWidget {
  const PFGrid({required this.instance, super.key});
  final StateNotifierProvider<SearchingNotifier, SearchingState> instance;

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

  void _handleGestureStart(Offset localPosition, double cellSize, SearchingState state) {
    final col = (localPosition.dx / cellSize).floor().clamp(0, kPFCells - 1);
    final row = (localPosition.dy / cellSize).floor().clamp(0, kPFCells - 1);

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
    final col = (localPosition.dx / cellSize).floor().clamp(0, kPFCells - 1);
    final row = (localPosition.dy / cellSize).floor().clamp(0, kPFCells - 1);

    if (_dragMode == _DragMode.start) {
      ref.read(widget.instance.notifier).setStartPoint(row, col);
    } else if (_dragMode == _DragMode.end) {
      ref.read(widget.instance.notifier).setEndPoint(row, col);
    } else if (_dragMode == _DragMode.wall) {
      ref.read(widget.instance.notifier).setWall(row, col, isGestureStart: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.instance);

    ref.listen(widget.instance, (prev, next) {
      final now = DateTime.now().millisecondsSinceEpoch.toDouble();

      _wallAnimations.removeWhere((_, v) => now - v > 500);
      _frontierAnimations.removeWhere((_, v) => now - v > 1500);
      _visitedAnimations.removeWhere((_, v) => now - v > 1500);
      _pathAnimations.removeWhere((_, v) => now - v > 500);

      for (int r = 0; r < kPFCells; r++) {
        for (int c = 0; c < kPFCells; c++) {
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

      final prevF = prev?.currentStep?.frontier.toSet() ?? {};
      final nextF = next.currentStep?.frontier.toSet() ?? {};
      if (nextF.length < prevF.length && nextF.isEmpty) {
        _frontierAnimations.clear();
      } else {
        for (final id in nextF.difference(prevF)) {
          _frontierAnimations[id] = now;
        }
      }

      final prevV = prev?.currentStep?.visited.toSet() ?? {};
      final nextV = next.currentStep?.visited.toSet() ?? {};
      if (nextV.length < prevV.length && nextV.isEmpty) {
        _visitedAnimations.clear();
      } else {
        for (final id in nextV.difference(prevV)) {
          _visitedAnimations[id] = now;
        }
      }

      final prevP = prev?.currentStep?.path?.toSet() ?? {};
      final nextP = next.currentStep?.path?.toSet() ?? {};
      if (nextP.length < prevP.length && nextP.isEmpty) {
        _pathAnimations.clear();
      } else {
        for (final id in nextP.difference(prevP)) {
          _pathAnimations[id] = now;
        }
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: LayoutBuilder(builder: (context, constraints) {
        final cellSize = constraints.maxWidth / kPFCells;
        final gridHeight = cellSize * kPFCells;

        return GestureDetector(
          onTapDown: (d) => _handleGestureStart(d.localPosition, cellSize, state),
          onPanStart: (d) => _handleGestureStart(d.localPosition, cellSize, state),
          onPanUpdate: (d) => _handleGestureUpdate(d.localPosition, cellSize),
          child: Container(
            width: constraints.maxWidth,
            height: gridHeight,
            decoration: BoxDecoration(
              color: context.isDark ? kGridDarkBg : kGridLightBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(constraints.maxWidth, gridHeight),
                    painter: PFGridPainter(
                      walls: state.walls,
                      step: state.currentStep,
                      isDark: context.isDark,
                      wallAnims: _wallAnimations,
                      frontierAnims: _frontierAnimations,
                      visitedAnims: _visitedAnimations,
                      pathAnims: _pathAnimations,
                      repaint: _controller,
                    ),
                  ),
                  PositionedDirectional(
                    start: state.startCol * cellSize,
                    // - 2.5: to center the start point
                    top: state.startRow * cellSize - 2.5,
                    width: cellSize,
                    height: cellSize,
                    child: PFStartPointWidget(size: cellSize),
                  ),
                  PositionedDirectional(
                    // - 1.5: to center the start point

                    start: state.endCol * cellSize - 1.5,
                    // - 1: to center the start point

                    top: state.endRow * cellSize - 1,
                    width: cellSize,
                    height: cellSize,
                    child: PFEndPointWidget(size: cellSize),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
