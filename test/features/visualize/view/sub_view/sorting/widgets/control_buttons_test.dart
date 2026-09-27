import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sub_sorting/bubble_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/widgets/control_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  late NotifierProvider<SortingNotifier, SortingNotifierState> provider;

  setUp(() {
    provider = NotifierProvider<SortingNotifier, SortingNotifierState>(BubbleSortNotifier.new);
    SortingNotifier.debugInitialListOverride = [
      for (var i = 0; i < 3; i++) SortableItem(id: i, value: 3 - i),
    ];
  });
  tearDown(() => SortingNotifier.debugInitialListOverride = null);

  Future<ProviderContainer> pumpButtons(WidgetTester tester) async {
    final container = await pumpApp(tester, Scaffold(body: SortingControlButtons(provider)));
    // Keeps the auto-disposing provider alive while the test reads it.
    container.listen(provider, (previous, next) {});
    return container;
  }

  bool enabled(WidgetTester tester, Key key) => tester.widget<CtrlButton>(find.byKey(key)).onTap != null;

  Future<void> tap(WidgetTester tester, Key key) async {
    await tester.tap(find.byKey(key));
    await tester.pump();
  }

  testWidgets('at the start only back is disabled', (tester) async {
    await pumpButtons(tester);

    expect(enabled(tester, AlgorithmControls.backKey), isFalse);
    expect(enabled(tester, AlgorithmControls.forwardKey), isTrue);
    expect(enabled(tester, AlgorithmControls.resetKey), isTrue);
  });

  testWidgets('after a step both directions work', (tester) async {
    await pumpButtons(tester);

    await tap(tester, AlgorithmControls.forwardKey);

    expect(enabled(tester, AlgorithmControls.backKey), isTrue);
    expect(enabled(tester, AlgorithmControls.forwardKey), isTrue);
  });

  testWidgets('at the last step forward is disabled', (tester) async {
    final container = await pumpButtons(tester);

    while (!container.read(provider).isAtLastStep) {
      await tap(tester, AlgorithmControls.forwardKey);
    }

    expect(enabled(tester, AlgorithmControls.forwardKey), isFalse);
    expect(enabled(tester, AlgorithmControls.backKey), isTrue);
    // Let the finish sweep run out.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('the play button shows pause while playing', (tester) async {
    final container = await pumpButtons(tester);

    await tap(tester, AlgorithmControls.playKey);
    expect(container.read(provider).isPlaying, isTrue);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await tap(tester, AlgorithmControls.playKey);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('sorting offers the slow, normal and 3x speeds', (tester) async {
    await pumpButtons(tester);

    expect(find.text('1×'), findsOneWidget);
    expect(find.text('2×'), findsOneWidget);
    expect(find.text('3×'), findsOneWidget);
  });
}
