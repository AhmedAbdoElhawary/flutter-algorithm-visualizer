import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';

void main() {
  testScreenMatrix('shows the mark and Skip', (tester, variant) async {
    await pumpApp(
      tester,
      Scaffold(body: OnboardingHeader(onSkip: () {})),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.byType(AlgoDiveMark), findsOneWidget);
    expect(find.text(StringsManager.onboardingSkip), findsOneWidget);
  });

  testWidgets('Skip calls onSkip', (tester) async {
    var skips = 0;
    await pumpApp(tester, Scaffold(body: OnboardingHeader(onSkip: () => skips++)));

    await tester.tap(find.text(StringsManager.onboardingSkip));

    expect(skips, 1);
  });
}
