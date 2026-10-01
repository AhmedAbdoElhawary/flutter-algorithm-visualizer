import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/segmented_control_quiet.dart';
import 'package:algorithm_visualizer/features/base/view_model/algorithm_control_interface.dart';
import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';

class _RecordingControls implements AlgorithmControlInterface {
  final calls = <String>[];

  @override
  void reset() => calls.add('reset');

  @override
  void stepBackward() => calls.add('back');

  @override
  void stepForward() => calls.add('forward');

  @override
  Future<void> togglePlay() async => calls.add('play');

  @override
  void changeSpeed(PlaybackSpeed speed) => calls.add('speed ${speed.name}');

  @override
  bool get backwardValidation => true;

  @override
  bool get forwardValidation => true;

  @override
  bool get isPlaying => false;

  @override
  PlaybackSpeed get getSpeed => PlaybackSpeed.normal;
}

void main() {
  late _RecordingControls controls;

  setUp(() => controls = _RecordingControls());

  AlgorithmControls bar({
    bool canGoBack = true,
    bool canGoForward = true,
    bool playing = false,
    bool expandSpeeds = true,
    List<CtrlButton> extra = const [],
  }) =>
      AlgorithmControls(
        interface: controls,
        backwardValidation: canGoBack,
        forwardValidation: canGoForward,
        isPlaying: playing,
        getSpeed: PlaybackSpeed.normal,
        expandSpeedEscalator: expandSpeeds,
        endOptionButtons: extra,
      );

  testWidgets('each button does its own job', (tester) async {
    await pumpApp(tester, bar());

    for (final key in [
      AlgorithmControls.resetKey,
      AlgorithmControls.backKey,
      AlgorithmControls.playKey,
      AlgorithmControls.forwardKey,
    ]) {
      await tester.tap(find.byKey(key));
    }

    expect(controls.calls, ['reset', 'back', 'play', 'forward']);
  });

  testWidgets('stepping is off at either end', (tester) async {
    await pumpApp(tester, bar(canGoBack: false, canGoForward: false));

    await tester.tap(find.byKey(AlgorithmControls.backKey));
    await tester.tap(find.byKey(AlgorithmControls.forwardKey));

    expect(controls.calls, isEmpty);
  });

  testWidgets('play turns into pause while playing', (tester) async {
    await pumpApp(tester, bar());
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await pumpApp(tester, bar(playing: true));
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
  });

  testWidgets('the sorting speeds can be picked from three', (tester) async {
    await pumpApp(tester, bar());
    final speeds = tester.widget<SegmentedControlQuiet>(find.byType(SegmentedControlQuiet));

    expect(speeds.labels, hasLength(3));
    expect(speeds.selectedIndex, 1);

    await tester.tap(find.text(speeds.labels.last));
    expect(controls.calls, ['speed fast3']);
  });

  testWidgets('collapsed, the speed shows only the current one', (tester) async {
    await pumpApp(tester, bar(expandSpeeds: false));

    expect(tester.widget<SegmentedControlQuiet>(find.byType(SegmentedControlQuiet)).labels, hasLength(1));
  });

  testWidgets('extra buttons sit before the speed, with their tooltips', (tester) async {
    var taps = 0;
    await pumpApp(
      tester,
      bar(extra: [CtrlButton(icon: Icons.shuffle_rounded, onTap: () => taps++, messageTip: 'Shuffle')]),
    );

    await tester.tap(find.byIcon(Icons.shuffle_rounded));

    expect(taps, 1);
    expect(find.byTooltip('Shuffle'), findsOneWidget);
  });

  testScreenMatrix('fits the screen', (tester, variant) async {
    await pumpApp(
      tester,
      bar(extra: [CtrlButton(icon: Icons.shuffle_rounded, onTap: () {})]),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(tester.takeException(), isNull);
  });
}
