import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/pf_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  late NotifierProvider<SearchingNotifier, SearchingState> provider;

  setUp(() => provider = NotifierProvider<SearchingNotifier, SearchingState>(BFSSearchingNotifier.new));

  Future<ProviderContainer> pumpControls(WidgetTester tester) async {
    final container = await pumpApp(tester, Scaffold(body: SearchingAlgorithmControls(instance: provider)));
    container.listen(provider, (previous, next) {});
    return container;
  }

  bool enabled(WidgetTester tester, Key key) => tester.widget<CtrlButton>(find.byKey(key)).onTap != null;

  testWidgets('before a run neither step button works', (tester) async {
    await pumpControls(tester);

    expect(enabled(tester, AlgorithmControls.backKey), isFalse);
    expect(enabled(tester, AlgorithmControls.forwardKey), isFalse);
  });

  testWidgets('a paused run can step forward, and back once it has moved', (tester) async {
    final container = await pumpControls(tester);
    await tester.tap(find.byKey(AlgorithmControls.playKey));
    await tester.tap(find.byKey(AlgorithmControls.playKey));
    await tester.pump();

    expect(enabled(tester, AlgorithmControls.backKey), isFalse);
    expect(enabled(tester, AlgorithmControls.forwardKey), isTrue);

    await tester.tap(find.byKey(AlgorithmControls.forwardKey));
    await tester.pump();

    expect(container.read(provider).stepIndex, 1);
    expect(enabled(tester, AlgorithmControls.backKey), isTrue);
  });

  testWidgets('the wall buttons clear and randomize the walls', (tester) async {
    final container = await pumpControls(tester);
    bool anyWall() => container.read(provider).walls.any((row) => row.contains(true));

    await tester.tap(find.byTooltip(StringsManager.randomWalls));
    await tester.pump();
    expect(anyWall(), isTrue);

    await tester.tap(find.byTooltip(StringsManager.clearWalls));
    await tester.pump();
    expect(anyWall(), isFalse);
  });

  testWidgets('the speed button moves to the next speed', (tester) async {
    final container = await pumpControls(tester);

    await tester.tap(find.text('2×'));
    await tester.pump();

    expect(find.text('3×'), findsOneWidget);
    expect(container.read(provider).speed.level, 3);
  });
}
