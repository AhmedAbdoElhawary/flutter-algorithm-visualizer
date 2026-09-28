import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('says the problems could not load, and to try later', (tester) async {
    await pumpApp(tester, const Scaffold(body: ChallengesErrorState()));

    expect(find.text(StringsManager.notAbleToLoadAnyChallenge), findsOneWidget);
    expect(find.text(StringsManager.tryInDifferentTime), findsOneWidget);
  });

  testWidgets('scrolls in a short space with large text instead of overflowing', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(body: SizedBox(height: 80, child: ChallengesErrorState())),
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
