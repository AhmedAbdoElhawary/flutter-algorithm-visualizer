import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_constants.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view/searching_view.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/pf_controls.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/pf_grid_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/pump_app.dart';
import '../../../../../../helpers/screen_matrix.dart';

class _Harness {
  _Harness(this.tester, this.container);

  final WidgetTester tester;
  final ProviderContainer container;

  NotifierProvider<SearchingNotifier, SearchingState> get _provider =>
      tester.widget<SearchingAlgorithmControls>(find.byType(SearchingAlgorithmControls)).instance;

  SearchingNotifier get notifier => container.read(_provider.notifier);
  SearchingState get state => container.read(_provider);

  Future<void> tap(Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
  }

  /// Matching on the painter is the only way to reach the grid: the markers are custom paints too.
  final _grid = find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is PFGridPainter);

  Offset cell(int row, int col) {
    final cellSize = tester.getSize(_grid).width / kPFCols;
    return tester.getTopLeft(_grid) + Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize);
  }

  void wallOffTheEnd() {
    final (row, col) = (state.endRow, state.endCol);
    for (final (r, c) in [(row - 1, col), (row + 1, col), (row, col - 1), (row, col + 1)]) {
      notifier.setWall(r, c, isGestureStart: true);
    }
  }
}

Future<_Harness> _pumpView(
  WidgetTester tester, {
  SearchingAlgoCards card = SearchingAlgoCards.bfs,
  void Function(String title, String description, AlgorithmComplexity complexity)? onAlgoChanged,
  ScreenSize screen = ScreenSize.phone,
  ThemeMode theme = ThemeMode.light,
  double textScale = 1.0,
}) async {
  final container = await pumpApp(
    tester,
    Scaffold(
      body: SearchingView(
        card: card,
        onAlgoChanged: onAlgoChanged ?? (title, description, complexity) {},
      ),
    ),
    screen: screen,
    theme: theme,
    textScale: textScale,
  );
  // The view wires itself up after the first frame.
  await tester.pump();
  return _Harness(tester, container);
}

/// Leaving the view queues a pause and the grid animates, so both have to run out.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
}

void main() {
  const endOfRun = Duration(minutes: 10);

  testScreenMatrix('idle, running, found and no path fit the screen', (tester, variant) async {
    final harness = await _pumpView(
      tester,
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );
    expect(find.text(StringsManager.searchPreRunHint), findsOneWidget);

    await harness.tap(find.byKey(AlgorithmControls.playKey));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining(StringsManager.searchRuleOldestFirst), findsOneWidget);

    await tester.pump(endOfRun);
    expect(find.textContaining(StringsManager.searchPathFound), findsOneWidget);

    await harness.tap(find.byKey(AlgorithmControls.resetKey));
    harness.wallOffTheEnd();
    await harness.tap(find.byKey(AlgorithmControls.playKey));
    await tester.pump(endOfRun);
    expect(find.text(StringsManager.searchNoPath), findsOneWidget);

    expect(tester.takeException(), isNull);
    await _unmount(tester);
  });

  testWidgets('tells the page which algorithm is showing', (tester) async {
    final shown = <String>[];
    await _pumpView(
      tester,
      card: SearchingAlgoCards.aStar,
      onAlgoChanged: (title, description, complexity) => shown.addAll([title, description, complexity.name]),
    );

    expect(shown, [
      StringsManager.aStarSearch,
      StringsManager.aStarDescription,
      StringsManager.aStarSearch,
    ]);
    await _unmount(tester);
  });

  testWidgets('tapping a cell adds a wall, and tapping it again removes it', (tester) async {
    final harness = await _pumpView(tester);

    await tester.tapAt(harness.cell(3, 4));
    await tester.pump();
    expect(harness.state.walls[3][4], isTrue);

    await tester.tapAt(harness.cell(3, 4));
    await tester.pump();
    expect(harness.state.walls[3][4], isFalse);
    await _unmount(tester);
  });

  testWidgets('dragging the start and end moves them', (tester) async {
    final harness = await _pumpView(tester);

    Future<void> drag((int, int) from, (int, int) to) async {
      final gesture = await tester.startGesture(harness.cell(from.$1, from.$2));
      await tester.pump();
      await gesture.moveTo(harness.cell(to.$1, to.$2));
      await tester.pump();
      await gesture.up();
      await tester.pump();
    }

    await drag((harness.state.startRow, harness.state.startCol), (2, 2));
    await drag((harness.state.endRow, harness.state.endCol), (20, 27));

    expect((harness.state.startRow, harness.state.startCol), (2, 2));
    expect((harness.state.endRow, harness.state.endCol), (20, 27));
    await _unmount(tester);
  });

  testWidgets('random walls, clear walls, run and reset', (tester) async {
    final harness = await _pumpView(tester);
    bool anyWall() => harness.state.walls.any((row) => row.contains(true));

    await harness.tap(find.byTooltip(StringsManager.randomWalls));
    expect(anyWall(), isTrue);

    await harness.tap(find.byTooltip(StringsManager.clearWalls));
    expect(anyWall(), isFalse);

    await harness.tap(find.byKey(AlgorithmControls.playKey));
    expect(harness.state.hasSteps, isTrue);
    expect(harness.state.playing, isTrue);

    await harness.tap(find.byKey(AlgorithmControls.resetKey));
    expect(harness.state.hasSteps, isFalse);
    expect(harness.state.playing, isFalse);
    await _unmount(tester);
  });
}
