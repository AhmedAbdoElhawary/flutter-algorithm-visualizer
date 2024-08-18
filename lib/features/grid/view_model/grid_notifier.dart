import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'grid_notifier_state.dart';

class GridNotifierCubit extends StateNotifier<GridNotifierState> {
  GridNotifierCubit() : super(GridNotifierState());
  final int columnSquares = 20;
  static const Duration scaleAppearDurationForWall = Duration(milliseconds: 700);
  static const Duration clearDuration = Duration(microseconds: 10);
  static const Duration drawFindingPathDuration = Duration(milliseconds: 2);
  static const Duration drawSearcherDuration = Duration(milliseconds: 2);

  int tapDownIndex = -1;

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
    debugPrint("2222222222222 ----------------------> ${DateTime.now().second}");

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

  Future<void> _clearTheGrid({required GridNotifierState addState}) async {
    for (int i = 0; i < addState.gridCount; i++) {
      final grid = addState.gridData[i];
      if (grid == GridStatus.targetPoint || grid == GridStatus.startPoint) continue;
      addState.gridData[i] = GridStatus.empty;
      state = addState.copyWith(gridData: addState.gridData);

      await Future.delayed(clearDuration);
    }
  }

  void clearTheGrid() {
    _clearTheGrid(addState: state);

    state = state.copyWith(currentTappedIndex: -1);
  }

  void onPointerDownOnGrid(PointerDownEvent event) {
    tapDownIndex = _getIndex(addState: state, localPosition: event.localPosition);
  }

  void onPointerUpOnGrid(PointerUpEvent event) {
    tapDownIndex = -1;
  }

  void onFingerMoveOnGrid(PointerMoveEvent event) {
    final index = _getIndex(addState: state, localPosition: event.localPosition);

    /// to handle multi calls from listener widget
    if (index == state.currentTappedIndex) return;

    if (index >= 0 && index < state.gridData.length) {
      final updatedGridData = List<GridStatus>.from(state.gridData);
      final currentGrid = updatedGridData[index];

      if (updatedGridData[tapDownIndex] == GridStatus.startPoint) {
        updatedGridData[tapDownIndex] = GridStatus.empty;
        updatedGridData[index] = GridStatus.startPoint;
        tapDownIndex = index;
      } else if (updatedGridData[tapDownIndex] == GridStatus.targetPoint) {
        updatedGridData[tapDownIndex] = GridStatus.empty;
        updatedGridData[index] = GridStatus.targetPoint;
        tapDownIndex = index;
      } else if (currentGrid == GridStatus.empty) {
        updatedGridData[index] = GridStatus.wall;
      } else if (currentGrid == GridStatus.wall) {
        updatedGridData[index] = GridStatus.empty;
      }

      state = state.copyWith(gridData: updatedGridData, currentTappedIndex: index);
    }
  }

  int _getIndex({
    required GridNotifierState addState,
    required Offset localPosition,
  }) {
    final screenWidth = localPosition.dx;
    final screenHeight = localPosition.dy;

    final selectedColumn = (screenWidth / addState.gridSize).floor();
    final selectedRow = (screenHeight / addState.gridSize).floor();

    final index = selectedRow * addState.columnCrossAxisCount + selectedColumn;

    return index;
  }

  Future<void> performBFS() async {
    final gridData = List<GridStatus>.from(state.gridData);
    final startPointIndex = gridData.indexOf(GridStatus.startPoint);
    final targetPointIndex = gridData.indexOf(GridStatus.targetPoint);

    if (startPointIndex == -1 || targetPointIndex == -1) return;

    final queue = Queue<int>();
    final Set<int> visited = <int>{};
    final previous = List<int?>.filled(gridData.length, null);

    queue.add(startPointIndex);
    visited.add(startPointIndex);

    final cross = state.columnCrossAxisCount;

    final up = -cross;
    final down = cross;
    const left = -1;
    const right = 1;

    final directions = [
      up, // up
      down, // down
      left, // left
      right, // right
    ];

    while (queue.isNotEmpty) {
      final currentIndex = queue.removeFirst();

      if (currentIndex == targetPointIndex) {
        _tracePath(previous, currentIndex);
        return;
      }

      for (final direction in directions) {
        final neighborIndex = currentIndex + direction;

        final isFirstLeftInRowIndex = neighborIndex % cross == 0;
        final isEndRightInRowIndex = neighborIndex % (cross - 1) == 0;

        if (direction == right && isFirstLeftInRowIndex) continue; // to avoid exist the boundaries
        if (direction == left && isEndRightInRowIndex) continue; // to avoid exist the boundaries

        if (neighborIndex >= 0 &&
            neighborIndex < gridData.length &&
            !visited.contains(neighborIndex) &&
            gridData[neighborIndex] != GridStatus.wall) {
          visited.add(neighborIndex);
          previous[neighborIndex] = currentIndex;
          queue.add(neighborIndex);
        }
      }

      // for marking the current grid as visited
      if (gridData[currentIndex] != GridStatus.startPoint &&
          gridData[currentIndex] != GridStatus.targetPoint) {
        gridData[currentIndex] = GridStatus.searcher;
        state = state.copyWith(gridData: List<GridStatus>.from(gridData));
        await Future.delayed(drawSearcherDuration);
      }
    }
  }

  Future<void> _tracePath(List<int?> previous, int currentIndex) async {
    final gridData = List<GridStatus>.from(state.gridData);
    int? traceIndex = currentIndex;

    while (traceIndex != null) {
      if (gridData[traceIndex] != GridStatus.startPoint && gridData[traceIndex] != GridStatus.targetPoint) {
        gridData[traceIndex] = GridStatus.path;
        state = state.copyWith(gridData: gridData);
        await Future.delayed(drawSearcherDuration);
      }
      traceIndex = previous[traceIndex];
    }
  }
}
