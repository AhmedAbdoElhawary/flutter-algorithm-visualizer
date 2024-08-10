import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'grid_notifier_state.dart';

class GridNotifierCubit extends StateNotifier<GridNotifierState> {
  GridNotifierCubit() : super(GridNotifierState());
  final int columnSquares = 20;
  static const Duration scaleAppearDurationForWall = Duration(milliseconds: 700);

  bool isTapDown = false;

  void updateGridLayout(Size size) {
    final screenWidth = size.width;
    final screenHeight = size.height;

    final double gridSize =
        (screenWidth < screenHeight) ? screenWidth / columnSquares : screenHeight / columnSquares;

    final columnCrossAxisCount = (screenWidth / gridSize).floor();
    final rowMainAxisCount = (screenHeight / gridSize).floor();

    final count = columnCrossAxisCount * rowMainAxisCount;

    final tempState = state.copyWith(
      columnCrossAxisCount: columnCrossAxisCount,
      rowMainAxisCount: rowMainAxisCount,
      gridCount: count,
      gridSize: gridSize,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
    );

    final gridData = _addDefaultTwoPoints(addState: tempState);

    state = tempState.copyWith(gridData: gridData);

    debugPrint("screen constraints updated ===========> "
        "width: $screenWidth,,"
        "height: $screenHeight,,");
  }

  List<GridStatus> _addDefaultTwoPoints({required GridNotifierState addState}) {
    final gridData = List<GridStatus>.filled(addState.gridCount, GridStatus.empty);

    final isHeightTaller = addState.screenHeight > addState.screenWidth;

    return isHeightTaller
        ? _twoPointersForHeight(addState: addState, gridStatus: gridData)
        : _twoPointersForWidth(addState: addState, gridStatus: gridData);
  }

  List<GridStatus> _twoPointersForHeight({
    required List<GridStatus> gridStatus,
    required GridNotifierState addState,
  }) {
    final centerColumn = addState.columnCrossAxisCount ~/ 2;

    final topRow = addState.rowMainAxisCount ~/ 8;
    final bottomRow = addState.rowMainAxisCount ~/ 1.2;

    final topCenterIndex = (topRow) * addState.columnCrossAxisCount + centerColumn;

    final bottomCenterIndex = (bottomRow) * addState.columnCrossAxisCount + centerColumn;

    gridStatus[topCenterIndex] = GridStatus.startPoint;
    gridStatus[bottomCenterIndex] = GridStatus.targetPoint;
    return gridStatus;
  }

  List<GridStatus> _twoPointersForWidth({
    required List<GridStatus> gridStatus,
    required GridNotifierState addState,
  }) {
    final centerRow = addState.rowMainAxisCount ~/ 2;

    final rightRow = addState.columnCrossAxisCount ~/ 1.2;
    final leftRow = addState.columnCrossAxisCount ~/ 8;

    final leftCenterIndex = centerRow * addState.columnCrossAxisCount + (leftRow);
    final rightCenterIndex = centerRow * addState.columnCrossAxisCount + (rightRow);

    gridStatus[leftCenterIndex] = GridStatus.startPoint;
    gridStatus[rightCenterIndex] = GridStatus.targetPoint;

    return gridStatus;
  }

  // todo: make another way. it's not efficient for watch
  void clearTheGrid() {
    final grids = _addDefaultTwoPoints(addState: state);

    state = state.copyWith(gridData: grids, currentTappedIndex: -1);
  }

  void onPointerDownOnGrid(PointerDownEvent event) {
    isTapDown = true;
  }

  void onPointerUpOnGrid(PointerUpEvent event) {
    isTapDown = false;
  }

  void onFingerMoveOnGrid(PointerMoveEvent event) {
    final dx = event.localPosition.dx;
    final dy = event.localPosition.dy;
    final index = _getIndex(addState: state, screenHeight: dy, screenWidth: dx);

    // to handle multi calls from listener widget
    if (index == state.currentTappedIndex) return;

    if (index >= 0 && index < state.gridData.length) {
      final updatedGridData = List<GridStatus>.from(state.gridData);
      final currentGrid = updatedGridData[index];
      if (currentGrid == GridStatus.wall) {
        updatedGridData[index] = GridStatus.empty;
      } else if (currentGrid == GridStatus.empty) {
        updatedGridData[index] = GridStatus.wall;
      }

      state = state.copyWith(gridData: updatedGridData, currentTappedIndex: index);
    }
  }

  int _getIndex({
    required GridNotifierState addState,
    required double screenWidth,
    required double screenHeight,
  }) {
    final selectedColumn = (screenWidth / addState.gridSize).floor();
    final selectedRow = (screenHeight / addState.gridSize).floor();

    final index = selectedRow * addState.columnCrossAxisCount + selectedColumn;

    return index;
  }

  void generateMaze() {
    final gridData = List<GridStatus>.from(state.gridData);

    // Clear the maze but keep start and target points
    for (int i = 0; i < gridData.length; i++) {
      if (gridData[i] != GridStatus.startPoint && gridData[i] != GridStatus.targetPoint) {
        gridData[i] = GridStatus.empty;
      }
    }

    // Start the division from the full grid
    _recursiveDivision(gridData, 0, state.rowMainAxisCount, 0, state.columnCrossAxisCount);
  }

  Future<void> _recursiveDivision(
      List<GridStatus> gridData, int rowStart, int rowEnd, int colStart, int colEnd) async {
    if (rowEnd - rowStart < 2 || colEnd - colStart < 2) return; // Avoid too small segments

    bool divideVertically = Random().nextBool();

    if (divideVertically) {
      int splitCol = Random().nextInt(colEnd - colStart - 1) + colStart + 1;
      for (int row = rowStart; row < rowEnd; row++) {
        if (row == rowStart || row == rowEnd - 1) continue; // Skip the boundary
        gridData[row * state.columnCrossAxisCount + splitCol] = GridStatus.wall;
        state = state.copyWith(gridData: List<GridStatus>.from(gridData));
        await Future.delayed(const Duration(milliseconds: 10)); // Delay for animation
      }

      // Open a passage
      int passageAt = Random().nextInt(rowEnd - rowStart) + rowStart;
      gridData[passageAt * state.columnCrossAxisCount + splitCol] = GridStatus.empty;

      await _recursiveDivision(gridData, rowStart, rowEnd, colStart, splitCol);
      await _recursiveDivision(gridData, rowStart, rowEnd, splitCol + 1, colEnd);
    } else {
      int splitRow = Random().nextInt(rowEnd - rowStart - 1) + rowStart + 1;
      for (int col = colStart; col < colEnd; col++) {
        if (col == colStart || col == colEnd - 1) continue; // Skip the boundary
        gridData[splitRow * state.columnCrossAxisCount + col] = GridStatus.wall;
        state = state.copyWith(gridData: List<GridStatus>.from(gridData));
        await Future.delayed(const Duration(milliseconds: 10)); // Delay for animation
      }

      // Open a passage
      int passageAt = Random().nextInt(colEnd - colStart) + colStart;
      gridData[splitRow * state.columnCrossAxisCount + passageAt] = GridStatus.empty;

      await _recursiveDivision(gridData, rowStart, splitRow, colStart, colEnd);
      await _recursiveDivision(gridData, splitRow + 1, rowEnd, colStart, colEnd);
    }
  }
}
