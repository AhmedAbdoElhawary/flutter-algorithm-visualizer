import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';

/// The complete, immutable input to a search: the walls plus both of the
/// learner's markers.
///
/// Passing this object is the only way an algorithm learns where to search —
/// reading [kPFStartRow] and friends inside an algorithm is a contract
/// violation.
///
/// Invariants the caller guarantees: neither marker sits on a wall, and
/// [start] and [end] are different cells.
class PFGridInput {
  const PFGridInput({
    required this.walls,
    required this.startRow,
    required this.startCol,
    required this.endRow,
    required this.endCol,
  });

  /// [kPFRows] rows of [kPFCols] columns.
  final List<List<bool>> walls;
  final int startRow;
  final int startCol;
  final int endRow;
  final int endCol;

  int get start => pfEncode(startRow, startCol);
  int get end => pfEncode(endRow, endCol);

  bool inBounds(int row, int col) => row >= 0 && row < kPFRows && col >= 0 && col < kPFCols;

  bool isWall(int row, int col) => inBounds(row, col) && walls[row][col];
}
