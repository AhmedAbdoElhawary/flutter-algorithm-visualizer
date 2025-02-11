import 'dart:collection';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'grid_notifier_state.dart';

class MazeDirection {
  final int rowDelta;
  final int colDelta;

  const MazeDirection._(this.rowDelta, this.colDelta);

  static const up = MazeDirection._(-1, 0);
  static const down = MazeDirection._(1, 0);
  static const left = MazeDirection._(0, -1);
  static const right = MazeDirection._(0, 1);
}

class SearchingNotifier extends StateNotifier<GridNotifierState> {
  SearchingNotifier() : super(GridNotifierState());
  final int columnSquares = 40;
  static const Duration scaleAppearDurationForWall = Duration(milliseconds: 700);
  static const Duration clearDuration = Duration(microseconds: 1);
  static const Duration drawFindingPathDuration = Duration(milliseconds: 2);
  static const Duration drawSearcherDuration = Duration(milliseconds: 5);
  static const Duration mazeDuration = Duration(milliseconds: 10);

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

  void generateMaze() async {
    final gridData = List<GridStatus>.from(state.gridData);

    // Clear the maze but keep start and target points
    for (int i = 0; i < gridData.length; i++) {
      if (gridData[i] != GridStatus.startPoint && gridData[i] != GridStatus.targetPoint) {
        gridData[i] = GridStatus.empty;
      }
    }

    // Random starting point
    final random = Random();
    int startRow = (random.nextInt(state.rowMainAxisCount - 2) ~/ 2) * 2 + 1;
    int startCol = (random.nextInt(state.columnCrossAxisCount - 2) ~/ 2) * 2 + 1;

    await _cravePassage(startRow, startCol, gridData);

    state = state.copyWith(gridData: gridData);
  }

  Future<void> _cravePassage(int row, int col, List<GridStatus> gridData) async {
    final directions = [MazeDirection.up, MazeDirection.down, MazeDirection.left, MazeDirection.right];
    directions.shuffle();

    for (final direction in directions) {
      final newRow = row + direction.rowDelta * 2;
      final newCol = col + direction.colDelta * 2;

      final currentGrid = gridData[newRow * state.columnCrossAxisCount + newCol];
      if (_isValidCell(newRow, newCol) &&
          currentGrid == GridStatus.empty &&
          currentGrid != GridStatus.startPoint &&
          currentGrid != GridStatus.targetPoint) {
        gridData[(row + direction.rowDelta) * state.columnCrossAxisCount + (col + direction.colDelta)] =
            GridStatus.wall;
        gridData[newRow * state.columnCrossAxisCount + newCol] = GridStatus.wall;

        state = state.copyWith(gridData: List.from(gridData));

        await Future.delayed(mazeDuration);

        await _cravePassage(newRow, newCol, gridData);
      }
    }
  }

  bool _isValidCell(int row, int col) {
    return row > 0 && col > 0 && row < state.rowMainAxisCount && col < state.columnCrossAxisCount;
  }
}
