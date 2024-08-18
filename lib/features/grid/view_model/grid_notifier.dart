import 'dart:collection';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'grid_notifier_state.dart';

class GridNotifierCubit extends StateNotifier<GridNotifierState> {
  GridNotifierCubit() : super(GridNotifierState());
  final int columnSquares = 20;
  static const Duration scaleAppearDurationForWall = Duration(milliseconds: 700);
  static const Duration clearDuration = Duration(microseconds: 10);
  static const Duration drawFindingPathDuration = Duration(milliseconds: 2);
  static const Duration drawSearcherDuration = Duration(milliseconds: 5);

  int tapDownIndex = -1;
  GridStatus tapDownGridStatus = GridStatus.empty;

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

  Future<void> _clearTheGrid({required GridNotifierState addState, bool keepWall = false}) async {
    final elements = addState.gridData;

    for (int i = 0; i < elements.length; i++) {
      final grid = addState.gridData[i];

      if (grid == GridStatus.targetPoint || grid == GridStatus.startPoint) continue;
      if (grid == GridStatus.wall && keepWall) continue;

      addState.gridData[i] = GridStatus.empty;
      state = addState.copyWith(gridData: addState.gridData);

      await Future.delayed(clearDuration);
    }
  }

  void clearTheGrid({bool keepWall = false}) {
    _clearTheGrid(addState: state, keepWall: keepWall);

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
        updatedGridData[tapDownIndex] = tapDownGridStatus;
        tapDownGridStatus = updatedGridData[index];
        updatedGridData[index] = GridStatus.startPoint;
        tapDownIndex = index;
      } else if (updatedGridData[tapDownIndex] == GridStatus.targetPoint) {
        updatedGridData[tapDownIndex] = tapDownGridStatus;
        tapDownGridStatus = updatedGridData[index];
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
        if (!_isValidNeighbor(currentIndex, neighborIndex, direction, cross, gridData)) {
          continue;
        }

        if (!visited.contains(neighborIndex)) {
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

  Future<void> performDijkstra() async {
    final gridData = List<GridStatus>.from(state.gridData);
    final startPointIndex = gridData.indexOf(GridStatus.startPoint);
    final targetPointIndex = gridData.indexOf(GridStatus.targetPoint);

    if (startPointIndex == -1 || targetPointIndex == -1) return;

    final distance = List<double>.filled(gridData.length, double.infinity);
    final previous = List<int?>.filled(gridData.length, null);
    final visited = List<bool>.filled(gridData.length, false);
    final cross = state.columnCrossAxisCount;

    distance[startPointIndex] = 0;

    // priority queue to get the minimum distance vertex
    final pq = PriorityQueue<int>((a, b) => distance[a].compareTo(distance[b]));
    pq.add(startPointIndex);

    final directions = [
      -cross, // up
      cross, // down
      -1, // left
      1, // right
    ];

    while (pq.isNotEmpty) {
      final currentIndex = pq.removeFirst();

      // Mark the current node as visited
      visited[currentIndex] = true;

      // If we reached the target, we trace back the path
      if (currentIndex == targetPointIndex) {
        _tracePath(previous, currentIndex);
        return;
      }

      for (final direction in directions) {
        final neighborIndex = currentIndex + direction;

        if (!_isValidNeighbor(currentIndex, neighborIndex, direction, cross, gridData)) {
          continue;
        }

        final tentativeDistance = distance[currentIndex] + 1; // Assume weight of 1 for each move

        if (tentativeDistance < distance[neighborIndex]) {
          distance[neighborIndex] = tentativeDistance;
          previous[neighborIndex] = currentIndex;
          pq.add(neighborIndex);

          // Visualize the search process
          if (gridData[neighborIndex] != GridStatus.startPoint &&
              gridData[neighborIndex] != GridStatus.targetPoint) {
            gridData[neighborIndex] = GridStatus.searcher;
            state = state.copyWith(gridData: List<GridStatus>.from(gridData));
            await Future.delayed(drawSearcherDuration);
          }
        }
      }
    }
  }

  bool _isValidNeighbor(
      int currentIndex, int neighborIndex, int direction, int cross, List<GridStatus> gridData) {
    final isFirstLeftInRowIndex = neighborIndex % cross == 0;
    final isEndRightInRowIndex = (neighborIndex + 1) % cross == 0;

    if (direction == 1 && isFirstLeftInRowIndex) return false; // avoid exiting the boundaries
    if (direction == -1 && isEndRightInRowIndex) return false; // avoid exiting the boundaries

    return neighborIndex >= 0 &&
        neighborIndex < gridData.length &&
        gridData[neighborIndex] != GridStatus.wall;
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
      return _recursiveVerticalDivision(gridData, rowStart, rowEnd, colStart, colEnd);
    } else {
      return _recursiveHorizontalDivision(gridData, rowStart, rowEnd, colStart, colEnd);
    }
  }

  Future<void> _recursiveVerticalDivision(
      List<GridStatus> gridData, int rowStart, int rowEnd, int colStart, int colEnd) async {
    if (rowEnd - rowStart < 2 || colEnd - colStart < 2) return;

    int splitCol = Random().nextInt(colEnd - colStart - 1) + colStart + 1;
    for (int row = rowStart; row < rowEnd; row++) {
      if (row == rowStart || row == rowEnd - 1) continue; // Skip the boundary
      final index = row * state.columnCrossAxisCount + splitCol;
      final grid = gridData[index];
      if (grid == GridStatus.startPoint || grid == GridStatus.targetPoint) return;
      gridData[index] = GridStatus.wall;
      state = state.copyWith(gridData: List<GridStatus>.from(gridData));
      await Future.delayed(const Duration(milliseconds: 10));
    }

    // Open a passage
    int passageAt = Random().nextInt(rowEnd - rowStart) + rowStart;
    gridData[passageAt * state.columnCrossAxisCount + splitCol] = GridStatus.empty;

    await _recursiveDivision(gridData, rowStart, rowEnd, colStart, splitCol);
    await _recursiveDivision(gridData, rowStart, rowEnd, splitCol + 1, colEnd);
  }

  Future<void> _recursiveHorizontalDivision(
      List<GridStatus> gridData, int rowStart, int rowEnd, int colStart, int colEnd) async {
    if (rowEnd - rowStart < 2 || colEnd - colStart < 2) return;

    int splitRow = Random().nextInt(rowEnd - rowStart - 1) + rowStart + 1;
    for (int col = colStart; col < colEnd; col++) {
      if (col == colStart || col == colEnd - 1) continue; // Skip the boundary

      final index = splitRow * state.columnCrossAxisCount + col;
      final grid = gridData[index];
      if (grid == GridStatus.startPoint || grid == GridStatus.targetPoint) return;
      gridData[index] = GridStatus.wall;

      state = state.copyWith(gridData: List<GridStatus>.from(gridData));
      await Future.delayed(const Duration(milliseconds: 10));
    }

    // Open a passage
    int passageAt = Random().nextInt(colEnd - colStart) + colStart;
    gridData[splitRow * state.columnCrossAxisCount + passageAt] = GridStatus.empty;

    await _recursiveDivision(gridData, rowStart, splitRow, colStart, colEnd);
    await _recursiveDivision(gridData, splitRow + 1, rowEnd, colStart, colEnd);
  }
}
