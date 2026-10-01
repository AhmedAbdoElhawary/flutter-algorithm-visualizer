import 'package:algorithm_visualizer/core/widgets/custom_widgets/loading_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final breathing =
      find.descendant(of: find.byType(ProblemTileShimmer), matching: find.byType(FadeTransition));

  testWidgets('fills the screen with placeholder rows that breathe', (tester) async {
    await pumpApp(tester, const ChallengesLoadingState());

    expect(find.byType(ProblemTileShimmer), findsWidgets);
    final fade = tester.widget<FadeTransition>(breathing.first);
    final start = fade.opacity.value;
    await tester.pump(const Duration(milliseconds: 500));
    expect(fade.opacity.value, isNot(start));
  });

  testWidgets('with reduced motion, the rows stay still', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pumpApp(tester, const ChallengesLoadingState());

    expect(find.byType(ProblemTileShimmer), findsWidgets);
    expect(breathing, findsNothing);
  });
}
