part of 'grid_notifier.dart';

enum GridStatus {
  empty,
  wall,
  startPoint,
  targetPoint,
  searcher,
  path,
}

final class GridNotifierState {
  final int columnCrossAxisCount;
  final int rowMainAxisCount;
  final int gridCount;
  final double screenWidth;
  final double screenHeight;
  final List<GridStatus> gridData;
  final int currentTappedIndex;

  /// [gridSize] it's square, so the height is the same of width. Size(value,value) => value
  final double gridSize;

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
    List<GridStatus>? gridData,
    int? currentTappedIndex,
  }) {

    return GridNotifierState(
      columnCrossAxisCount: columnCrossAxisCount!=this.columnCrossAxisCount?(columnCrossAxisCount ?? this.columnCrossAxisCount):this.columnCrossAxisCount,
      rowMainAxisCount: rowMainAxisCount!=this.rowMainAxisCount?(rowMainAxisCount ?? this.rowMainAxisCount):this.rowMainAxisCount,
      gridSize: gridSize!=this.gridSize?(gridSize ?? this.gridSize):this.gridSize,
      gridCount: gridCount!=this.gridCount?(gridCount ?? this.gridCount):this.gridCount,
      screenHeight: screenHeight!=this.screenHeight?(screenHeight ?? this.screenHeight):this.screenHeight,
      screenWidth: screenWidth!=this.screenWidth?(screenWidth ?? this.screenWidth):this.screenWidth,
      gridData: gridData!=this.gridData?(gridData ?? this.gridData):this.gridData,
      currentTappedIndex: currentTappedIndex!=this.currentTappedIndex?(currentTappedIndex ?? this.currentTappedIndex):this.currentTappedIndex,
    );
  }
}
