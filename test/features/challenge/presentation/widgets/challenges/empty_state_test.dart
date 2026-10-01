import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('says nothing matched, with the icon', (tester) async {
    await pumpApp(tester, const Scaffold(body: ChallengesEmptyState()));

    expect(find.text('🔍'), findsOneWidget);
    expect(find.text(StringsManager.noProblemsFound), findsOneWidget);
    expect(find.text(StringsManager.tryADifferentSearchOrFilter), findsOneWidget);
  });

  testWidgets('takes its own words, and can drop the icon', (tester) async {
    await pumpApp(tester, const Scaffold(body: ChallengesEmptyState(showIcon: false, title: 'Title', subTitle: 'Sub')));

    expect(find.text('🔍'), findsNothing);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Sub'), findsOneWidget);
  });

  testWidgets('scrolls in a short space with large text instead of overflowing', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(body: SizedBox(height: 120, child: ChallengesEmptyState())),
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
