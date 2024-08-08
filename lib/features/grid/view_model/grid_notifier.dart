import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'grid_notifier_state.dart';

final gridNotifierProvider =
    StateNotifierProvider<GridNotifierCubit, GridNotifierState>(
  (ref) => GridNotifierCubit(),
);

class GridNotifierCubit extends StateNotifier<GridNotifierState> {
  GridNotifierCubit() : super(GridNotifierState());

  void updateGridLayout(BoxConstraints constraints) {
    const int numSquares = 20;

    // [gridSize] it's square, so the height is the same of width. Size(value,value) => value
    final double gridSize = (constraints.maxWidth < constraints.maxHeight)
        ? constraints.maxWidth / numSquares
        : constraints.maxHeight / numSquares;

    final columnCrossAxisCount = (constraints.maxWidth / gridSize).floor();
    final rowMainAxisCount = (constraints.maxHeight / gridSize).floor();

    final count = columnCrossAxisCount * rowMainAxisCount;
    state = state.copyWith(
        columnCrossAxisCount: columnCrossAxisCount,
        rowMainAxisCount: rowMainAxisCount,
        gridCount: count,
        gridSize: gridSize);
  }
}

extension GridNotifierCubitHelper on WidgetRef {
  int get watchGridCount =>
      watch(gridNotifierProvider.select((it) => it.gridCount));
  int get watchColumnCrossAxisCount =>
      watch(gridNotifierProvider.select((it) => it.columnCrossAxisCount));
  int get watchRowMainAxisCount =>
      watch(gridNotifierProvider.select((it) => it.rowMainAxisCount));
  double get watchGridSize =>
      watch(gridNotifierProvider.select((it) => it.gridSize));
}
