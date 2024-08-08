import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'grid_notifier_state.dart';

class GridNotifierCubit extends StateNotifier<GridNotifierState> {
  GridNotifierCubit() : super(GridNotifierState());
  final int columnSquares = 20;
  bool isTapDown = false;

  void updateGridLayout(BoxConstraints constraints) {
    // [gridSize] it's square, so the height is the same of width. Size(value,value) => value
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;

    final double gridSize = (screenWidth < screenHeight)
        ? screenWidth / columnSquares
        : screenHeight / columnSquares;

    final columnCrossAxisCount = (screenWidth / gridSize).floor();
    final rowMainAxisCount = (screenHeight / gridSize).floor();

    final count = columnCrossAxisCount * rowMainAxisCount;

    state = state.copyWith(
      columnCrossAxisCount: columnCrossAxisCount,
      rowMainAxisCount: rowMainAxisCount,
      gridCount: count,
      gridSize: gridSize,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      gridData: List<bool>.filled(count, false),
    );

    debugPrint("screen constraints updated ===========> "
        "width: $screenWidth,,"
        "height: $screenHeight,,");
  }

  // todo: make another way. it's not efficient for watch
  void clearTheGrid() {
    state = state.copyWith(
        gridData: List<bool>.filled(state.gridCount, false),
        currentTappedIndex: -1);
  }

  void onPointerDownOnGrid(PointerDownEvent event) {
    isTapDown = true;
  }

  void onPointerUpOnGrid(PointerUpEvent event) {
    isTapDown = false;
  }

  void onPointerMoveOnGrid(PointerMoveEvent event) {
    final dx = event.localPosition.dx;
    final dy = event.localPosition.dy;

    final selectedColumn = (dx / state.gridSize).floor();
    final selectedRow = (dy / state.gridSize).floor();

    final index = selectedRow * state.columnCrossAxisCount + selectedColumn;

    // to handle multi calls from listener widget
    if (index == state.currentTappedIndex) return;

    if (index >= 0 && index < state.gridData.length) {
      final updatedGridData = List<bool>.from(state.gridData);
      updatedGridData[index] = !updatedGridData[index];

      state =
          state.copyWith(gridData: updatedGridData, currentTappedIndex: index);
    }
  }
}
