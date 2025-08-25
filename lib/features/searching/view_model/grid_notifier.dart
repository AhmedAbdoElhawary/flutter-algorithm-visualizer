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

  /// [_gridSquareSize]
  final double _gridSquareSize = 24;
  static const Duration scaleAppearDurationForWall = Duration(milliseconds: 700);
  static const Duration clearDuration = Duration(microseconds: 1);
  static const Duration drawFindingPathDuration = Duration(milliseconds: 2);
  static const Duration drawSearcherDuration = Duration(milliseconds: 5);
  static const Duration mazeDuration = Duration(milliseconds: 10);

  int tapDownIndex = -1;
  GridStatus tapDownGridStatus = GridStatus.empty;

  /// [_isBuildingGrid] if build maze or search or even clear grid
  bool _isBuildingGrid = false;
  bool _isSearched = false;
  void updateGridLayout(Size size) {
    final screenWidth = size.width;
    final screenHeight = size.height;

    final columnCrossAxisCount = (screenWidth / _gridSquareSize).floor();
    final rowMainAxisCount = (screenHeight / _gridSquareSize).floor();

    final count = columnCrossAxisCount * rowMainAxisCount;

    final tempState = state.copyWith(
      columnCrossAxisCount: columnCrossAxisCount,
      rowMainAxisCount: rowMainAxisCount,
      gridCount: count,
      gridSize: _gridSquareSize,
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

  Future<void> clearTheGrid({bool keepWall = false, bool clearAnyway = false}) async {
    if (!clearAnyway && _isBuildingGrid) return;
    _isBuildingGrid = true;

    await _clearTheGrid(addState: state, keepWall: keepWall);

    state = state.copyWith(currentTappedIndex: -1);

    _isSearched = false;
    _isBuildingGrid = false;
  }

  void onPointerDownOnGrid(PointerDownEvent event) {
    if (_isBuildingGrid) return;
    _isBuildingGrid = true;

    tapDownIndex = _getIndex(addState: state, localPosition: event.localPosition);
    _isBuildingGrid = false;
  }

  void onPointerUpOnGrid(PointerUpEvent event) {
    if (_isBuildingGrid) return;
    _isBuildingGrid = true;

    tapDownIndex = -1;

    _isBuildingGrid = false;
  }

  void onFingerMoveOnGrid(PointerMoveEvent event) {
    if (_isBuildingGrid) return;
    _isBuildingGrid = true;

    final index = _getIndex(addState: state, localPosition: event.localPosition);

    /// to handle multi calls from listener widget
    if (index == state.currentTappedIndex) {
      _isBuildingGrid = false;

      return;
    }

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

    _isBuildingGrid = false;
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
    if (_isBuildingGrid) return;
    _isBuildingGrid = true;

    if (_isSearched) await clearTheGrid(keepWall: true, clearAnyway: true);

    final gridData = List<GridStatus>.from(state.gridData);
    final startPointIndex = gridData.indexOf(GridStatus.startPoint);
    final targetPointIndex = gridData.indexOf(GridStatus.targetPoint);

    if (startPointIndex == -1 || targetPointIndex == -1) {
      _isBuildingGrid = false;
      return;
    }

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
        _isBuildingGrid = false;
        _isSearched = true;

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

    _isBuildingGrid = false;
    _isSearched = true;
  }

  Future<void> performDijkstra() async {
    if (_isBuildingGrid) return;
    _isBuildingGrid = true;
    if (_isSearched) await clearTheGrid(keepWall: true, clearAnyway: true);

    final gridData = List<GridStatus>.from(state.gridData);
    final startPointIndex = gridData.indexOf(GridStatus.startPoint);
    final targetPointIndex = gridData.indexOf(GridStatus.targetPoint);

    if (startPointIndex == -1 || targetPointIndex == -1) {
      _isBuildingGrid = false;
      return;
    }

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
        _isBuildingGrid = false;
        _isSearched = true;
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
    _isBuildingGrid = false;
    _isSearched = true;
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

  Future<void> performAStar() async {
    if (_isBuildingGrid) return;
    _isBuildingGrid = true;
    if (_isSearched) await clearTheGrid(keepWall: true, clearAnyway: true);

    final gridData = List<GridStatus>.from(state.gridData);
    final startPointIndex = gridData.indexOf(GridStatus.startPoint);
    final targetPointIndex = gridData.indexOf(GridStatus.targetPoint);

    if (startPointIndex == -1 || targetPointIndex == -1) {
      _isBuildingGrid = false;

      return;
    }

    final cross = state.columnCrossAxisCount;

    final gScore = List<double>.filled(gridData.length, double.infinity);
    final fScore = List<double>.filled(gridData.length, double.infinity);
    final previous = List<int?>.filled(gridData.length, null);
    final visited = <int>{};

    gScore[startPointIndex] = 0;
    fScore[startPointIndex] = _heuristic(startPointIndex, targetPointIndex, cross);

    // priority queue based on fScore (g + h)
    final pq = PriorityQueue<int>((a, b) => fScore[a].compareTo(fScore[b]));
    pq.add(startPointIndex);

    final directions = [
      -cross, // up
      cross, // down
      -1, // left
      1, // right
    ];

    while (pq.isNotEmpty) {
      final currentIndex = pq.removeFirst();

      if (currentIndex == targetPointIndex) {
        await _tracePath(previous, currentIndex);
        _isBuildingGrid = false;
        _isSearched = true;

        return;
      }

      visited.add(currentIndex);

      for (final direction in directions) {
        final neighborIndex = currentIndex + direction;

        if (!_isValidNeighbor(currentIndex, neighborIndex, direction, cross, gridData)) {
          continue;
        }

        if (visited.contains(neighborIndex)) continue;

        final tentativeG = gScore[currentIndex] + 1; // weight = 1

        if (tentativeG < gScore[neighborIndex]) {
          gScore[neighborIndex] = tentativeG;
          fScore[neighborIndex] = tentativeG + _heuristic(neighborIndex, targetPointIndex, cross);
          previous[neighborIndex] = currentIndex;

          if (!pq.contains(neighborIndex)) {
            pq.add(neighborIndex);
          }

          // visualize
          if (gridData[neighborIndex] != GridStatus.startPoint &&
              gridData[neighborIndex] != GridStatus.targetPoint) {
            gridData[neighborIndex] = GridStatus.searcher;
            state = state.copyWith(gridData: List<GridStatus>.from(gridData));
            await Future.delayed(drawSearcherDuration);
          }
        }
      }
    }
    _isBuildingGrid = false;
    _isSearched = true;
  }

  double _heuristic(int index, int targetIndex, int cross) {
    // Manhattan distance
    final x1 = index % cross;
    final y1 = index ~/ cross;
    final x2 = targetIndex % cross;
    final y2 = targetIndex ~/ cross;

    return ((x1 - x2).abs() + (y1 - y2).abs()).toDouble();
  }

  void generateRecursiveBacktrackerMaze() async {
    if (_isBuildingGrid) return;
    _isBuildingGrid = true;
    if (_isSearched) await clearTheGrid(clearAnyway: true);

    final gridData = List<GridStatus>.from(state.gridData);

    // Clear the maze but keep start and target points
    for (int i = 0; i < gridData.length; i++) {
      if (gridData[i] != GridStatus.startPoint && gridData[i] != GridStatus.targetPoint) {
        gridData[i] = GridStatus.empty;
      }
    }

    // 🔹 Draw outer border walls
    await _drawBorders(gridData);

    // 🔹 Force the second border inside as a corridor (always empty)
    _makeSafeCorridor(gridData);

    final random = Random();
    int startRow = (random.nextInt((state.rowMainAxisCount - 3) ~/ 2) * 2) + 2; // >= 2
    int startCol = (random.nextInt((state.columnCrossAxisCount - 3) ~/ 2) * 2) + 2; // >= 2

    await _drawWalls(startRow, startCol, gridData);

    state = state.copyWith(gridData: gridData);
    _isBuildingGrid = false;
    _isSearched = true;
  }

  Future<void> _drawBorders(List<GridStatus> gridData) async {
    // Top & bottom rows
    for (int c = 0; c < state.columnCrossAxisCount; c++) {
      for (final r in [0, state.rowMainAxisCount - 1]) {
        final idx = r * state.columnCrossAxisCount + c;
        if (gridData[idx] != GridStatus.startPoint && gridData[idx] != GridStatus.targetPoint) {
          gridData[idx] = GridStatus.wall;
          state = state.copyWith(gridData: List.from(gridData));
          await Future.delayed(mazeDuration);
        }
      }
    }

    // Left & right columns
    for (int r = 1; r < state.rowMainAxisCount - 1; r++) {
      for (final c in [0, state.columnCrossAxisCount - 1]) {
        final idx = r * state.columnCrossAxisCount + c;
        if (gridData[idx] != GridStatus.startPoint && gridData[idx] != GridStatus.targetPoint) {
          gridData[idx] = GridStatus.wall;
          state = state.copyWith(gridData: List.from(gridData));
          await Future.delayed(mazeDuration);
        }
      }
    }
  }

  /// Make the second layer inside the borders always a safe corridor (roads).
  void _makeSafeCorridor(List<GridStatus> gridData) {
    for (int r = 1; r < state.rowMainAxisCount - 1; r++) {
      for (int c = 1; c < state.columnCrossAxisCount - 1; c++) {
        if (r == 1 || r == state.rowMainAxisCount - 2 || c == 1 || c == state.columnCrossAxisCount - 2) {
          final idx = r * state.columnCrossAxisCount + c;
          if (gridData[idx] != GridStatus.startPoint && gridData[idx] != GridStatus.targetPoint) {
            gridData[idx] = GridStatus.empty; // always keep clear
          }
        }
      }
    }
  }

  Future<void> _drawWalls(int row, int col, List<GridStatus> gridData) async {
    final directions = [MazeDirection.up, MazeDirection.down, MazeDirection.left, MazeDirection.right];
    directions.shuffle();

    for (final direction in directions) {
      final newRow = row + direction.rowDelta * 2;
      final newCol = col + direction.colDelta * 2;

      if (_isValidCell(newRow, newCol) &&
          gridData[newRow * state.columnCrossAxisCount + newCol] == GridStatus.empty) {
        final betweenRow = row + direction.rowDelta;
        final betweenCol = col + direction.colDelta;

        final betweenIdx = betweenRow * state.columnCrossAxisCount + betweenCol;
        final newIdx = newRow * state.columnCrossAxisCount + newCol;

        if (gridData[betweenIdx] != GridStatus.startPoint && gridData[betweenIdx] != GridStatus.targetPoint) {
          gridData[betweenIdx] = GridStatus.wall;
        }

        if (gridData[newIdx] != GridStatus.startPoint && gridData[newIdx] != GridStatus.targetPoint) {
          gridData[newIdx] = GridStatus.wall;
        }

        state = state.copyWith(gridData: List.from(gridData));
        await Future.delayed(mazeDuration);

        await _drawWalls(newRow, newCol, gridData);
      }
    }
  }

  bool _isValidCell(int row, int col) {
    // must be inside the "safe corridor"
    return row > 1 && col > 1 && row < state.rowMainAxisCount - 2 && col < state.columnCrossAxisCount - 2;
  }

  // Recursive Division Maze Generation
  Future<void> generateRecursiveDivisionMaze() async {
    if (_isBuildingGrid) return;
    _isBuildingGrid = true;
    if (_isSearched) await clearTheGrid(clearAnyway: true);

    final gridData = List<GridStatus>.from(state.gridData);

    // Step 1: Start with all empty
    for (int i = 0; i < gridData.length; i++) {
      if (gridData[i] != GridStatus.startPoint && gridData[i] != GridStatus.targetPoint) {
        gridData[i] = GridStatus.empty;
      }
    }

    // Step 2: Add outer borders as walls
    for (int r = 0; r < state.rowMainAxisCount; r++) {
      for (int c = 0; c < state.columnCrossAxisCount; c++) {
        if (r == 0 || c == 0 || r == state.rowMainAxisCount - 1 || c == state.columnCrossAxisCount - 1) {
          if (gridData[r * state.columnCrossAxisCount + c] != GridStatus.startPoint &&
              gridData[r * state.columnCrossAxisCount + c] != GridStatus.targetPoint) {
            gridData[r * state.columnCrossAxisCount + c] = GridStatus.wall;
            state = state.copyWith(gridData: List.from(gridData));
            await Future.delayed(mazeDuration);
          }
        }
      }
    }

    state = state.copyWith(gridData: List.from(gridData));

    await _divide(1, 1, state.rowMainAxisCount - 2, state.columnCrossAxisCount - 2, gridData);

    state = state.copyWith(gridData: gridData);
    _isBuildingGrid = false;
    _isSearched = true;
  }

  Future<void> _divide(int row, int col, int height, int width, List<GridStatus> gridData) async {
    if (height < 2 || width < 2) return;

    final random = Random();
    final horizontal = random.nextBool();

    if (horizontal) {
      // Horizontal wall
      int wallRow = row + (random.nextInt(height ~/ 2)) * 2 + 1;
      int passageCol = col + (random.nextInt(width ~/ 2)) * 2;

      for (int c = col; c < col + width; c++) {
        if (c == passageCol) continue;
        if (gridData[wallRow * state.columnCrossAxisCount + c] != GridStatus.startPoint &&
            gridData[wallRow * state.columnCrossAxisCount + c] != GridStatus.targetPoint) {
          gridData[wallRow * state.columnCrossAxisCount + c] = GridStatus.wall;
          state = state.copyWith(gridData: List.from(gridData));
          await Future.delayed(mazeDuration); // 🔹 Delay for each cell
        }
      }

      await _divide(row, col, wallRow - row, width, gridData);
      await _divide(wallRow + 1, col, row + height - wallRow - 1, width, gridData);
    } else {
      // Vertical wall
      int wallCol = col + (random.nextInt(width ~/ 2)) * 2 + 1;
      int passageRow = row + (random.nextInt(height ~/ 2)) * 2;

      for (int r = row; r < row + height; r++) {
        if (r == passageRow) continue;
        if (gridData[r * state.columnCrossAxisCount + wallCol] != GridStatus.startPoint &&
            gridData[r * state.columnCrossAxisCount + wallCol] != GridStatus.targetPoint) {
          gridData[r * state.columnCrossAxisCount + wallCol] = GridStatus.wall;
          state = state.copyWith(gridData: List.from(gridData));
          await Future.delayed(mazeDuration); // 🔹 Delay for each cell
        }
      }

      await _divide(row, col, height, wallCol - col, gridData);
      await _divide(row, wallCol + 1, height, col + width - wallCol - 1, gridData);
    }
  }
}
