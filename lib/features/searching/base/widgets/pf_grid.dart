import 'package:algorithm_visualizer/features/searching/base/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/searching/base/widgets/pf_grid_painter.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/searching_notifier.dart';

class PFGrid extends ConsumerWidget {
  const PFGrid({required this.instance, super.key});
  final StateNotifierProvider<SearchingNotifier, SearchingState> instance;

  void _handleCellEvent(
    WidgetRef ref,
    Offset localPosition,
    double cellSize, {
    required bool isGestureStart,
  }) {
    final col = (localPosition.dx / cellSize).floor().clamp(0, kPFCells - 1);
    final row = (localPosition.dy / cellSize).floor().clamp(0, kPFCells - 1);
    ref.read(instance.notifier).setWall(row, col, isGestureStart: isGestureStart);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(instance);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: LayoutBuilder(builder: (context, constraints) {
        final cellSize = constraints.maxWidth / kPFCells;
        final gridHeight = cellSize * kPFCells;

        return GestureDetector(
          onTapDown: (d) => _handleCellEvent(ref, d.localPosition, cellSize, isGestureStart: true),
          onPanStart: (d) => _handleCellEvent(ref, d.localPosition, cellSize, isGestureStart: true),
          onPanUpdate: (d) => _handleCellEvent(ref, d.localPosition, cellSize, isGestureStart: false),
          child: Container(
            width: constraints.maxWidth,
            height: gridHeight,
            decoration: BoxDecoration(
              color: context.isDark ? const Color(0xFF060C1A) : const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CustomPaint(
                size: Size(constraints.maxWidth, gridHeight),
                painter: PFGridPainter(
                  walls: state.walls,
                  step: state.currentStep,
                  isDark: context.isDark,
                  accent: context.accent,
                  accentGreen: context.accentGreen,
                  accentYellow: context.accentYellow,
                  accentBlue: context.accentBlue,
                  accentRed: context.accentRed,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
