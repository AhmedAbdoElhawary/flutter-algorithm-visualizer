import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/editor/editor_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  late List<String> taps;

  Future<void> pumpBar(WidgetTester tester, {required bool running, double textScale = 1}) async {
    taps = [];
    await pumpApp(
      tester,
      Scaffold(
        bottomNavigationBar: EditorActionBar(
          onReset: () => taps.add('reset'),
          onRun: () => taps.add('run'),
          running: running,
        ),
      ),
      screen: textScale > 1 ? ScreenSize.smallPhone : ScreenSize.phone,
      textScale: textScale,
    );
  }

  testWidgets('reset and run each do their job', (tester) async {
    await pumpBar(tester, running: false);

    await tester.tap(find.text(StringsManager.reset));
    await tester.tap(find.text(StringsManager.runAndSubmit));

    expect(taps, ['reset', 'run']);
  });

  testWidgets('while running, run says so and cannot be pressed again', (tester) async {
    await pumpBar(tester, running: true);

    expect(find.text(StringsManager.runAndSubmit), findsNothing);
    await tester.tap(find.text(StringsManager.running));

    expect(taps, isEmpty);
  });

  testWidgets('fits a small screen with large text', (tester) async {
    await pumpBar(tester, running: false, textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
