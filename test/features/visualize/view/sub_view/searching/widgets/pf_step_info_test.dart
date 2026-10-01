import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/widgets/pf_step_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  late NotifierProvider<SearchingNotifier, SearchingState> provider;

  setUp(() => provider = NotifierProvider<SearchingNotifier, SearchingState>(BFSSearchingNotifier.new));

  String counter(int current, int total) => StringsManager.searchStepCounterTemplate
      .replaceFirst('{current}', '$current')
      .replaceFirst('{total}', '$total');

  testWidgets('before a run shows the hint and no counter', (tester) async {
    await pumpApp(tester, Scaffold(body: PFStepInfo(instance: provider)));

    expect(find.text(StringsManager.searchPreRunHint), findsOneWidget);
    expect(find.textContaining('{total}'), findsNothing);
  });

  testWidgets('during a run shows the rule and which step of how many', (tester) async {
    final container = await pumpApp(tester, Scaffold(body: PFStepInfo(instance: provider)));
    container.listen(provider, (previous, next) {});
    final notifier = container.read(provider.notifier);

    await notifier.togglePlay();
    notifier.stepForward();
    await tester.pump();

    final total = container.read(provider).steps!.length;
    expect(find.text(counter(2, total)), findsOneWidget);
    expect(find.textContaining(StringsManager.searchRuleOldestFirst), findsOneWidget);
  });
}
