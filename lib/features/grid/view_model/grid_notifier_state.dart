part of 'grid_notifier.dart';

final class GridNotifierInitial {
  final int columnCrossAxisCount;
  final int rowMainAxisCount;
  final int gridCount;
  final int gridSize;

  GridNotifierInitial({
    required this.columnCrossAxisCount,
    required this.rowMainAxisCount,
    required this.gridCount,
    required this.gridSize,
  });
  GridNotifierInitial copyWith({
    int? columnCrossAxisCount,
    int? rowMainAxisCount,
    int? gridCount,
    int? gridSize,
  }) {
    return GridNotifierInitial(
      columnCrossAxisCount: columnCrossAxisCount ?? this.columnCrossAxisCount,
      rowMainAxisCount: rowMainAxisCount ?? this.rowMainAxisCount,
      gridSize: gridSize ?? this.gridSize,
      gridCount: gridCount ?? this.gridCount,
    );
  }
}
