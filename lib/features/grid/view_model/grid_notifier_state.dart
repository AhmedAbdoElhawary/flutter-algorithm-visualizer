part of 'grid_notifier.dart';

final class GridNotifierState {
  final int columnCrossAxisCount;
  final int rowMainAxisCount;
  final int gridCount;
  final double gridSize;

  GridNotifierState({
    this.columnCrossAxisCount = 0,
    this.rowMainAxisCount = 0,
    this.gridCount = 0,
    this.gridSize = 0,
  });
  GridNotifierState copyWith({
    int? columnCrossAxisCount,
    int? rowMainAxisCount,
    int? gridCount,
    double? gridSize,
  }) {
    return GridNotifierState(
      columnCrossAxisCount: columnCrossAxisCount ?? this.columnCrossAxisCount,
      rowMainAxisCount: rowMainAxisCount ?? this.rowMainAxisCount,
      gridSize: gridSize ?? this.gridSize,
      gridCount: gridCount ?? this.gridCount,
    );
  }
}
