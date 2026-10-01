import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_grid_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final walls = List.generate(kPFRows, (_) => List.filled(kPFCols, false))..[3][4] = true;
  final grid = PFGridInput(walls: walls, startRow: 1, startCol: 2, endRow: 20, endCol: 29);

  test('start and end are encoded cells', () {
    expect(grid.start, pfEncode(1, 2));
    expect(grid.end, pfEncode(20, 29));
  });

  test('inBounds covers exactly the grid', () {
    expect(grid.inBounds(0, 0), isTrue);
    expect(grid.inBounds(kPFRows - 1, kPFCols - 1), isTrue);
    expect(grid.inBounds(-1, 0), isFalse);
    expect(grid.inBounds(0, -1), isFalse);
    expect(grid.inBounds(kPFRows, 0), isFalse);
    expect(grid.inBounds(0, kPFCols), isFalse);
  });

  test('isWall is true only for a wall inside the grid', () {
    expect(grid.isWall(3, 4), isTrue);
    expect(grid.isWall(3, 5), isFalse);
    expect(grid.isWall(-1, 4), isFalse, reason: 'off the grid is not a wall, and must not throw');
    expect(grid.isWall(kPFRows, 4), isFalse);
  });
}
