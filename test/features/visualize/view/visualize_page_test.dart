import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view/searching_view.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view/sorting_view.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/widgets/control_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';

String _route([String? instance]) => instance == null
    ? Routes.visualize.path
    : '${Routes.visualize.path}?${Routes.visualize.queryParamsName}=$instance';

Future<void> _open(
  WidgetTester tester,
  String route, {
  ScreenSize screen = ScreenSize.phone,
  ThemeMode theme = ThemeMode.light,
  double textScale = 1.0,
}) async {
  await pumpApp(tester, const SizedBox(), initialRoute: route, screen: screen, theme: theme, textScale: textScale);
  // The page and both views apply their state after the frame.
  await tester.pump();
  await tester.pump();
}

/// The page defers its setState a frame, then the new view reports its title a frame after it builds.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  for (var frame = 0; frame < 4; frame++) {
    await tester.pump();
  }
}

/// Opening searching scrolls the grid into view on purpose, which hides the tab row under the title.
/// Pulls down from the title like a person would, since a drag on the grid draws walls instead.
Future<void> _showTabs(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.dragFrom(tester.getTopLeft(find.byType(NestedScrollView)) + const Offset(20, 20), const Offset(0, 300));
  await tester.pump(const Duration(seconds: 1));
}

/// Leaving the page queues a pause and the play loop sleeps between steps, so both have to run out.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 30));
}

void main() {
  testScreenMatrix('the sorting and searching tabs fit the screen', (tester, variant) async {
    for (final instance in ['bubble', 'bfs']) {
      await _open(
        tester,
        _route(instance),
        screen: variant.screen,
        theme: variant.theme,
        textScale: variant.textScale,
      );
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull, reason: instance);
      await _unmount(tester);
    }
  });

  testWidgets('opens on bubble sort when no algorithm is given', (tester) async {
    await _open(tester, _route());

    expect(find.byType(SortingView), findsOneWidget);
    expect(find.text(StringsManager.bubbleSortDescription), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('opens on the algorithm in the link', (tester) async {
    await _open(tester, _route('merge'));
    expect(find.text(StringsManager.mergeSortDescription), findsOneWidget);
    await _unmount(tester);

    await _open(tester, _route('aStar'));
    expect(find.byType(SearchingView), findsOneWidget);
    expect(find.text(StringsManager.aStarDescription), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('an unknown algorithm in the link shows the unknown page', (tester) async {
    await _open(tester, _route('bogo'));

    expect(find.text(StringsManager.unknownPage), findsOneWidget);
  });

  testWidgets('switching between the sorting and searching tabs', (tester) async {
    await _open(tester, _route());

    await _tap(tester, find.text(StringsManager.searching));
    expect(find.byType(SearchingView), findsOneWidget);
    expect(find.text(StringsManager.breadthFirstSearchDescription), findsOneWidget);

    await _showTabs(tester);
    await _tap(tester, find.text(StringsManager.sorting));
    expect(find.byType(SortingView), findsOneWidget);
    expect(find.text(StringsManager.bubbleSortDescription), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('picking another algorithm shows its description', (tester) async {
    await _open(tester, _route());

    await _tap(tester, find.text(StringsManager.insertionSort));
    expect(find.text(StringsManager.insertionSortDescription), findsOneWidget);

    await _tap(tester, find.text(StringsManager.searching));
    await _showTabs(tester);
    await _tap(tester, find.text(StringsManager.dFS));
    expect(find.text(StringsManager.depthFirstSearchDescription), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('leaving mid-run pauses it, and coming back keeps the algorithm', (tester) async {
    final container = await pumpApp(tester, const SizedBox(), initialRoute: _route('merge'));
    await tester.pump();
    await tester.pump();
    final provider = tester.widget<SortingControlButtons>(find.byType(SortingControlButtons)).notifier;

    await _tap(tester, find.byKey(AlgorithmControls.playKey));
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(provider).isPlaying, isTrue);

    await _tap(tester, find.text(StringsManager.home));
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(provider).isPlaying, isFalse);
    // Nothing keeps drawing once the run is paused, so the frames settle.
    await tester.pumpAndSettle();

    await _tap(tester, find.text(StringsManager.visual));
    expect(find.text(StringsManager.mergeSortDescription), findsOneWidget);
    await _unmount(tester);
  });
}
