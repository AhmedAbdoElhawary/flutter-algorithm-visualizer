import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'grid_notifier_state.dart';

class GridNotifierCubit extends StateNotifier<GridNotifierState> {
  GridNotifierCubit() : super(GridNotifierState());
  final int columnSquares = 20;
  bool isTapDown = false;

  void updateGridLayout(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;

    final double gridSize = (screenWidth < screenHeight)
        ? screenWidth / columnSquares
        : screenHeight / columnSquares;

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
    final gridData =
        List<GridStatus>.filled(addState.gridCount, GridStatus.empty);

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

    final topCenterIndex =
        (topRow) * addState.columnCrossAxisCount + centerColumn;

    final bottomCenterIndex =
        (bottomRow) * addState.columnCrossAxisCount + centerColumn;

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

    final leftCenterIndex =
        centerRow * addState.columnCrossAxisCount + (leftRow);
    final rightCenterIndex =
        centerRow * addState.columnCrossAxisCount + (rightRow);

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

      state =
          state.copyWith(gridData: updatedGridData, currentTappedIndex: index);
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
}
