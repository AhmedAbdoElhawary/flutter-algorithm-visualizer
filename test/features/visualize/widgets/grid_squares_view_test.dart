import 'package:algorithm_visualizer/features/visualize/widgets/grid_squares_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('calculateSizeForPerfectGrid', () {
    test('keeps the width and makes the height a whole number of squares', () {
      final size = GridSquaresPainter.calculateSizeForPerfectGrid(defaultSize: const Size(140, 95), squareSize: 14);

      expect(size.width, 140);
      expect(size.height % 10, closeTo(0, 1e-9), reason: 'each square is 140 / 14 = 10 wide');
    });

    test('a height already on a square line stays the same', () {
      final size = GridSquaresPainter.calculateSizeForPerfectGrid(defaultSize: const Size(140, 100), squareSize: 14);

      expect(size.height, 100);
    });

    test('a short box grows to the next square line', () {
      final size = GridSquaresPainter.calculateSizeForPerfectGrid(defaultSize: const Size(140, 95), squareSize: 14);

      expect(size.height, 100);
    });

    test('a tall box shrinks to the last square line', () {
      final size = GridSquaresPainter.calculateSizeForPerfectGrid(defaultSize: const Size(140, 205), squareSize: 14);

      expect(size.height, 200);
    });
  });

  testWidgets('sizes itself to a perfect grid and draws its child on top', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: SizedBox(
          width: 140,
          child: GridSquaresView(estimatedHeight: 95, squareSize: 14, child: Text('bars')),
        ),
      ),
    );

    expect(tester.getSize(find.byType(GridSquaresView)), const Size(140, 100));
    expect(find.text('bars'), findsOneWidget);
  });

  testWidgets('keeps the given height when a perfect grid is not wanted', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: SizedBox(
          width: 140,
          child: GridSquaresView(
            makeThemPerfectGrids: false,
            estimatedHeight: 95,
            squareSize: 14,
            child: SizedBox(),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(GridSquaresView)), const Size(140, 95));
  });

  test('repaints only when something it draws changes', () {
    const painter = GridSquaresPainter(backgroundColor: Colors.black, borderColor: Colors.white, height: 100);

    expect(painter.shouldRepaint(painter), isFalse);
    expect(
      painter.shouldRepaint(
        const GridSquaresPainter(backgroundColor: Colors.black, borderColor: Colors.white, height: 120),
      ),
      isTrue,
    );
    expect(
      painter.shouldRepaint(
        const GridSquaresPainter(backgroundColor: Colors.red, borderColor: Colors.white, height: 100),
      ),
      isTrue,
    );
  });
}
