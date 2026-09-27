import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/pf_grid_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _wall = Color(0xFF000001);
const _path = Color(0xFF000002);
const _searcher = Color(0xFF000003);
const _visited = Color(0xFF000004);
const _trail0 = Color(0xFF000005);
const _trail1 = Color(0xFF000006);
const _size = Size(kPFCols * 10, kPFRows * 10);

PFGridPainter _painter({
  Set<(int, int)> walls = const {},
  PFStep? step,
  int? searcherCell,
  int? searcherFrom,
  double searcherMoveAt = 0,
  Map<int, double> wallAnimations = const {},
  Map<int, double> visitedAnimations = const {},
  double? pathStartAt,
}) {
  return PFGridPainter(
    walls: List.generate(kPFRows, (r) => List.generate(kPFCols, (c) => walls.contains((r, c)))),
    step: step,
    isDark: false,
    searcherCell: searcherCell,
    searcherFrom: searcherFrom,
    searcherMoveAt: searcherMoveAt,
    searcherJumpMs: kSearcherJumpMs,
    pathEmptyMs: kBasePathEmptyMs,
    pathPopMs: kBasePathPopMs,
    pathCellMs: kBasePathEmptyMs + kBasePathPopMs,
    wallColor: _wall,
    pathColor: _path,
    searcherColor: _searcher,
    trail0Color: _trail0,
    trail1Color: _trail1,
    visitedColor: _visited,
    gridLineColor: const Color(0xFF000007),
    wallAnimations: wallAnimations,
    visitedAnimations: visitedAnimations,
    pathStartAt: pathStartAt,
    repaint: ValueNotifier(0),
  );
}

/// Notes the colour of every filled cell. Grid lines are strokes, so they are left out.
class _FillColors implements Canvas {
  final colors = <int>[];

  // Paint keeps a colour as 32 bits, so compare those and not the float channels.
  void _add(Paint paint) {
    if (paint.style == PaintingStyle.fill) colors.add(paint.color.toARGB32());
  }

  @override
  void drawRect(Rect rect, Paint paint) => _add(paint);

  @override
  void drawRRect(RRect rrect, Paint paint) => _add(paint);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

List<int> _fills(PFGridPainter painter) {
  final canvas = _FillColors();
  painter.paint(canvas, _size);
  return canvas.colors;
}

void main() {
  test('settled walls, visited cells and the path each get their colour', () {
    final painter = _painter(
      walls: {(0, 0)},
      step: PFStep(
        visited: {pfEncode(1, 1)},
        frontier: const {},
        path: [pfEncode(2, 2)],
        phase: PFPhase.found,
        metricA: 0,
      ),
      pathStartAt: 0,
    );

    expect(_fills(painter), [_wall, _visited, _path].map((color) => color.toARGB32()));
  });

  test('the searcher cell is filled with the searcher colour', () {
    final cell = pfEncode(4, 4);
    final painter = _painter(
      step: PFStep(visited: {cell}, frontier: const {}, phase: PFPhase.exploring, metricA: 0),
      searcherCell: cell,
    );

    expect(_fills(painter), [_searcher.toARGB32()]);
  });

  test('cells in the middle of their animations still paint', () {
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final path = [pfEncode(5, 5), pfEncode(5, 6), pfEncode(5, 7)];
    final painter = _painter(
      walls: {(0, 0)},
      step: PFStep(
        visited: {pfEncode(1, 1), pfEncode(1, 2), pfEncode(1, 3), ...path},
        frontier: const {},
        path: path,
        phase: PFPhase.found,
        metricA: 0,
      ),
      searcherCell: pfEncode(1, 3),
      searcherFrom: pfEncode(1, 2),
      searcherMoveAt: now,
      wallAnimations: {pfEncode(0, 0): now},
      visitedAnimations: {pfEncode(1, 1): now - 100, pfEncode(1, 2): now - 700, pfEncode(5, 7): now},
      pathStartAt: now,
    );

    expect(
      _fills(painter),
      [
        _wall,
        _trail0, // released 100ms ago, still near the first trail colour
        _trail1, // released 700ms ago, settling
        _searcher,
        // the first path cell is cleared for its turn and paints nothing
        _visited, // the second path cell's turn has not come, so it still shows as searched
        _trail0,
      ].map((color) => color.toARGB32()),
    );
  });

  test('always repaints, since the animations run on the clock', () {
    expect(_painter().shouldRepaint(_painter()), isTrue);
  });
}
