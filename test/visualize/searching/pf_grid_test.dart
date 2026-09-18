import 'package:algorithm_visualizer/config/themes/app_theme.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/grid_scroll_lock.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/pf_grid.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/pf_grid_painter.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/start_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

const _surface = Size(430, 932);

final _provider = NotifierProvider<SearchingNotifier, SearchingState>(BFSSearchingNotifier.new);

class _Harness {
  _Harness(this.container);
  final ProviderContainer container;

  SearchingNotifier get notifier => container.read(_provider.notifier);
  SearchingState get state => container.read(_provider);
  bool get locked => container.read(gridScrollLockProvider);
}

Future<_Harness> _pump(
  WidgetTester tester, {
  Size surface = _surface,
  TextDirection textDirection = TextDirection.ltr,
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: _surface,
        builder: (context, _) => MaterialApp(
          theme: AppTheme.dark,
          home: Directionality(
            textDirection: textDirection,
            child: Scaffold(
              body: SingleChildScrollView(child: PFGrid(instance: _provider)),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();

  return _Harness(container);
}

/// The grid's own canvas — the page holds several other [CustomPaint]s (the
/// card outline, the two markers), so matching on the painter type is the only
/// reliable way to reach it.
final _gridCanvas = find.byWidgetPredicate((w) => w is CustomPaint && w.painter is PFGridPainter);

PFGridPainter _painter(WidgetTester tester) =>
    tester.widget<CustomPaint>(_gridCanvas).painter as PFGridPainter;

/// The top-left corner of the grid box in global coordinates.
Offset _gridOrigin(WidgetTester tester) => tester.getTopLeft(_gridCanvas);

void main() {
  group('geometry G1–G3 (FR-034, FR-035, FR-036, SC-011)', () {
    testWidgets('the rendered box is 0.8 of its width, with square cells', (tester) async {
      await _pump(tester);

      final box = tester.getSize(_gridCanvas);
      final cellSize = box.width / kPFCols;

      // The grid sits inside the page's side padding, so its width is whatever
      // the layout hands it — what must hold is the shape it makes of that.
      expect(box.width, lessThan(_surface.width));
      expect(box.height, closeTo(box.width * 0.8, 0.01), reason: 'G1: the box is 0.8 of its width');
      expect(box.height, closeTo(cellSize * kPFRows, 0.01), reason: 'G2: height is kPFRows cells');
      expect(box.width / kPFCols, closeTo(box.height / kPFRows, 0.01),
          reason: 'G2: cells must be square on both axes');
    });

    testWidgets('a tap lands on the cell under the finger, corners included', (tester) async {
      final harness = await _pump(tester);
      final cellSize = tester.getSize(_gridCanvas).width / kPFCols;
      final origin = _gridOrigin(tester);

      // Four corners plus one interior cell, each tapped at its own centre.
      const targets = [(0, 0), (0, kPFCols - 1), (kPFRows - 1, 0), (kPFRows - 1, kPFCols - 1), (7, 13)];

      for (final (row, col) in targets) {
        await tester.tapAt(origin + Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize));
        await tester.pump();

        expect(harness.state.walls[row][col], isTrue, reason: 'tap at ($row, $col) missed');
      }
    });

    testWidgets('no overflow at a small phone size', (tester) async {
      await _pump(tester, surface: const Size(320, 640));

      expect(tester.takeException(), isNull);
    });
  });

  group('scroll-lock lifecycle L1–L7 (FR-017, SC-006, SC-007)', () {
    testWidgets('L1/L2: pointer down locks the page and pointer up releases it', (tester) async {
      final harness = await _pump(tester);
      final centre = tester.getCenter(_gridCanvas);

      expect(harness.locked, isFalse);

      final gesture = await tester.startGesture(centre);
      await tester.pump();
      expect(harness.locked, isTrue);

      await gesture.up();
      await tester.pump();
      expect(harness.locked, isFalse);
    });

    testWidgets('L3: the lock holds for vertical, horizontal and diagonal strokes alike', (tester) async {
      final harness = await _pump(tester);
      final centre = tester.getCenter(_gridCanvas);

      for (final delta in [const Offset(0, 60), const Offset(60, 0), const Offset(50, 50)]) {
        final gesture = await tester.startGesture(centre);
        await tester.pump();
        expect(harness.locked, isTrue, reason: 'lock lost at pointer down for $delta');

        await gesture.moveBy(delta);
        await tester.pump();
        expect(harness.locked, isTrue, reason: 'lock lost mid-stroke for $delta');

        await gesture.up();
        await tester.pump();
        expect(harness.locked, isFalse, reason: 'lock not released after $delta');
      }
    });

    testWidgets('L4: a cancelled pointer releases the lock, or the page freezes forever', (tester) async {
      final harness = await _pump(tester);
      final centre = tester.getCenter(_gridCanvas);

      final gesture = await tester.startGesture(centre);
      await tester.pump();
      expect(harness.locked, isTrue);

      await gesture.cancel();
      await tester.pump();
      expect(harness.locked, isFalse);
    });

    testWidgets('L5: a pointer starting outside the grid never locks', (tester) async {
      final harness = await _pump(tester);
      final below = tester.getBottomLeft(_gridCanvas) + const Offset(20, 40);

      final gesture = await tester.startGesture(below);
      await tester.pump();
      expect(harness.locked, isFalse);

      await gesture.moveBy(const Offset(0, -60));
      await tester.pump();
      expect(harness.locked, isFalse);

      await gesture.up();
    });
  });

  group('dragging the markers', () {
    Offset cellCentre(WidgetTester tester, int row, int col) {
      final cellSize = tester.getSize(_gridCanvas).width / kPFCols;
      return _gridOrigin(tester) + Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize);
    }

    testWidgets('a marker pressed and dragged lands on the cell it was let go over',
        (tester) async {
      final harness = await _pump(tester);
      final (row, col) = (harness.state.startRow, harness.state.startCol);

      // Touch slop is wider than a cell, so the drag has to survive the finger
      // leaving the pressed cell before the gesture is even recognised.
      final gesture = await tester.startGesture(cellCentre(tester, row, col));
      await tester.pump();
      await gesture.moveTo(cellCentre(tester, row, col + 4));
      await tester.pump();
      await gesture.moveTo(cellCentre(tester, row + 3, col + 4));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect((harness.state.startRow, harness.state.startCol), (row + 3, col + 4));
      // Dragging a marker is not drawing: nothing may be left behind it.
      expect(harness.state.walls.expand((r) => r).where((w) => w), isEmpty);
    });

    testWidgets('a marker rubs out a wall it is dropped on', (tester) async {
      final harness = await _pump(tester);
      final (row, col) = (harness.state.startRow, harness.state.startCol);

      await tester.tapAt(cellCentre(tester, row + 2, col + 2));
      await tester.pump();
      expect(harness.state.walls[row + 2][col + 2], isTrue);

      final gesture = await tester.startGesture(cellCentre(tester, row, col));
      await tester.pump();
      await gesture.moveTo(cellCentre(tester, row + 2, col + 2));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect((harness.state.startRow, harness.state.startCol), (row + 2, col + 2));
      expect(harness.state.walls[row + 2][col + 2], isFalse);
    });

    testWidgets('a marker is pinned once a run exists, and free again after reset',
        (tester) async {
      final harness = await _pump(tester);
      harness.notifier.togglePlay();
      harness.notifier.stepBackward();
      await tester.pump();

      final (row, col) = (harness.state.startRow, harness.state.startCol);

      final gesture = await tester.startGesture(cellCentre(tester, row, col));
      await tester.pump();
      await gesture.moveTo(cellCentre(tester, row + 3, col));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect((harness.state.startRow, harness.state.startCol), (row, col));
      // Pressing a pinned marker must not fall through to drawing a wall.
      expect(harness.state.walls[row][col], isFalse);

      harness.notifier.reset();
      await tester.pump();

      final again = await tester.startGesture(cellCentre(tester, row, col));
      await tester.pump();
      await again.moveTo(cellCentre(tester, row + 3, col));
      await tester.pump();
      await again.up();
      await tester.pump();

      expect((harness.state.startRow, harness.state.startCol), (row + 3, col));
    });

    testWidgets('no wall is drawn while the search is playing', (tester) async {
      final harness = await _pump(tester);
      harness.notifier.togglePlay();
      await tester.pump();
      expect(harness.notifier.isPlaying, isTrue);

      await tester.tapAt(cellCentre(tester, 2, 2));
      await tester.pump();

      expect(harness.state.walls[2][2], isFalse);

      harness.notifier.reset(); // the playback timer must not outlive the test
    });

    testWidgets('markers sit on their own cell in Arabic, not mirrored across the grid',
        (tester) async {
      final harness = await _pump(tester, textDirection: TextDirection.rtl);
      final cellSize = tester.getSize(_gridCanvas).width / kPFCols;
      final left = tester.getTopLeft(find.byType(PFStartPointWidget).first).dx;

      expect(left - _gridOrigin(tester).dx, closeTo(harness.state.startCol * cellSize, 0.01));
    });
  });

  group('animation rewind N5 (FR-041, FR-015)', () {
    testWidgets('stepping backward drops the stamps of cells no longer in the set', (tester) async {
      final harness = await _pump(tester);

      harness.notifier.togglePlay();
      harness.notifier.stepBackward();
      await tester.pump();

      for (int i = 0; i < 8; i++) {
        harness.notifier.stepForward();
        await tester.pump();
      }

      final painter = _painter(tester);
      final forwardStep = harness.state.currentStep!;
      expect(painter.visitedAnimations.keys, everyElement(isIn(forwardStep.visited)));

      for (int i = 0; i < 5; i++) {
        harness.notifier.stepBackward();
        await tester.pump();
      }

      final rewoundStep = harness.state.currentStep!;
      final rewound = _painter(tester);

      // Nothing may be left stamped that the earlier step does not contain,
      // or the painter keeps animating cells that are no longer there.
      expect(rewound.visitedAnimations.keys, everyElement(isIn(rewoundStep.visited)));
    });

    testWidgets('the searcher is the cell this step expanded, and it is never stamped',
        (tester) async {
      final harness = await _pump(tester);

      harness.notifier.togglePlay();
      harness.notifier.stepBackward();
      await tester.pump();

      int? previous;
      for (int i = 0; i < 6; i++) {
        harness.notifier.stepForward();
        await tester.pump();

        final painter = _painter(tester);
        final searcher = painter.searcherCell;
        expect(searcher, isNotNull);
        expect(searcher, isIn(harness.state.currentStep!.visited));

        // The searcher draws as a static square, so a stamp on it would be a
        // release animation running under a cell the search is still on.
        expect(painter.visitedAnimations.containsKey(searcher), isFalse);
        // ...and the cell it just left has to be the one that starts moving.
        if (previous != null) expect(painter.visitedAnimations, contains(previous));
        previous = searcher;
      }
    });

    testWidgets('resetting clears every stamp', (tester) async {
      final harness = await _pump(tester);

      harness.notifier.togglePlay();
      harness.notifier.stepBackward();
      await tester.pump();
      for (int i = 0; i < 6; i++) {
        harness.notifier.stepForward();
        await tester.pump();
      }

      harness.notifier.reset();
      await tester.pump();

      final painter = _painter(tester);
      expect(painter.visitedAnimations, isEmpty);
      expect(painter.pathAnimations, isEmpty);
    });
  });
}
