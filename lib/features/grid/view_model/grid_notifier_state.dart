part of 'grid_notifier.dart';

final class GridNotifierState {
  final int columnCrossAxisCount;
  final int rowMainAxisCount;
  final int gridCount;
  final double gridSize;
  final double screenWidth;
  final double screenHeight;
  final List<bool> gridData;
  final int currentTappedIndex;

  GridNotifierState({
    this.columnCrossAxisCount = 0,
    this.rowMainAxisCount = 0,
    this.gridCount = 0,
    this.gridSize = 0,
    this.screenWidth = 0,
    this.screenHeight = 0,
    this.gridData = const [],
    this.currentTappedIndex = 0,
  });

  GridNotifierState copyWith({
    int? columnCrossAxisCount,
    int? rowMainAxisCount,
    int? gridCount,
    double? gridSize,
    double? screenWidth,
    double? screenHeight,
    List<bool>? gridData,
    int? currentTappedIndex,
  }) {
    return GridNotifierState(
      columnCrossAxisCount: columnCrossAxisCount ?? this.columnCrossAxisCount,
      rowMainAxisCount: rowMainAxisCount ?? this.rowMainAxisCount,
      gridSize: gridSize ?? this.gridSize,
      gridCount: gridCount ?? this.gridCount,
      screenHeight: screenHeight ?? this.screenHeight,
      screenWidth: screenWidth ?? this.screenWidth,
      gridData: gridData ?? this.gridData,
      currentTappedIndex: currentTappedIndex ?? this.currentTappedIndex,
    );
  }
}
