import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view/sorting_view.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/widgets/control_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/pump_app.dart';
import '../../../../../../helpers/screen_matrix.dart';

class _Harness {
  _Harness(this.tester, this.container);

  final WidgetTester tester;
  final ProviderContainer container;

  NotifierProvider<SortingNotifier, SortingNotifierState> get _provider =>
      tester.widget<SortingControlButtons>(find.byType(SortingControlButtons)).notifier;

  SortingNotifierState get state => container.read(_provider);

  Future<void> tap(Key key) async {
    await tester.tap(find.byKey(key));
    await tester.pump();
  }
}

Future<_Harness> _pumpView(
  WidgetTester tester, {
  SortingAlgoCards card = SortingAlgoCards.bubble,
  void Function(String title, String description, AlgorithmComplexity complexity)? onAlgoChanged,
  ScreenSize screen = ScreenSize.phone,
  ThemeMode theme = ThemeMode.light,
  double textScale = 1.0,
}) async {
  final container = await pumpApp(
    tester,
    Scaffold(
      body: SortingView(
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

/// The play loop sleeps between steps, and leaving the view queues a pause, so both have to run out.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 30));
}

void main() {
  const endOfRun = Duration(seconds: 60);

  testScreenMatrix('idle, playing and finished fit the screen', (tester, variant) async {
    final harness = await _pumpView(
      tester,
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );
    expect(find.text(StringsManager.initialArrayReadyToSort), findsOneWidget);

    await harness.tap(AlgorithmControls.playKey);
    await tester.pump(const Duration(seconds: 1));
    expect(harness.state.isPlaying, isTrue);

    await tester.pump(endOfRun);
    expect(find.text(StringsManager.arrayFullySorted), findsOneWidget);

    expect(tester.takeException(), isNull);
    await _unmount(tester);
  });

  testWidgets('tells the page which algorithm is showing', (tester) async {
    final shown = <String>[];
    await _pumpView(
      tester,
      card: SortingAlgoCards.merge,
      onAlgoChanged: (title, description, complexity) => shown.addAll([title, description, complexity.name]),
    );

    expect(shown, [StringsManager.mergeSort, StringsManager.mergeSortDescription, StringsManager.mergeSort]);
    await _unmount(tester);
  });

  testWidgets('play and pause', (tester) async {
    final harness = await _pumpView(tester);

    await harness.tap(AlgorithmControls.playKey);
    expect(harness.state.isPlaying, isTrue);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await harness.tap(AlgorithmControls.playKey);
    expect(harness.state.isPlaying, isFalse);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('step forward and back move one step each', (tester) async {
    final harness = await _pumpView(tester);

    await harness.tap(AlgorithmControls.forwardKey);
    await harness.tap(AlgorithmControls.forwardKey);
    expect(harness.state.currentStepIndex, 2);

    await harness.tap(AlgorithmControls.backKey);
    expect(harness.state.currentStepIndex, 1);
    await _unmount(tester);
  });

  testWidgets('reset goes back to the start', (tester) async {
    final harness = await _pumpView(tester);
    await harness.tap(AlgorithmControls.playKey);
    await tester.pump(const Duration(seconds: 2));

    await harness.tap(AlgorithmControls.resetKey);

    expect(harness.state.currentStepIndex, 0);
    expect(harness.state.isPlaying, isFalse);
    expect(find.text(StringsManager.initialArrayReadyToSort), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('the speed buttons change the speed', (tester) async {
    final harness = await _pumpView(tester);

    for (final speed in [PlaybackSpeed.slow, PlaybackSpeed.fast3, PlaybackSpeed.normal]) {
      await tester.tap(find.text('${speed.level}×'));
      await tester.pump();
      expect(harness.state.speed, speed);
    }
    await _unmount(tester);
  });
}
