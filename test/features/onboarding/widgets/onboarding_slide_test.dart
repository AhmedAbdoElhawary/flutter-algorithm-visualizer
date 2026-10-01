import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_slide.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';

void main() {
  testScreenMatrix('shows the visual, headline and body', (tester, variant) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: OnboardingSlide(
          visual: MonoText(StringsManager.onboardingEditorFile),
          headline: StringsManager.onboardingSeeItHeadline,
          body: StringsManager.onboardingSeeItBody,
        ),
      ),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.text(StringsManager.onboardingEditorFile), findsOneWidget);
    expect(find.text(StringsManager.onboardingSeeItHeadline), findsOneWidget);
    expect(find.text(StringsManager.onboardingSeeItBody), findsOneWidget);
  });

  testWidgets('a visual taller than the screen scrolls instead of overflowing', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: OnboardingSlide(
          visual: SizedBox(height: 2000),
          headline: StringsManager.onboardingSeeItHeadline,
          body: StringsManager.onboardingSeeItBody,
        ),
      ),
      screen: ScreenSize.smallPhone,
    );

    expect(find.text(StringsManager.onboardingSeeItHeadline).hitTestable(), findsNothing);

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
    await tester.pump();

    expect(find.text(StringsManager.onboardingSeeItHeadline).hitTestable(), findsOneWidget);
  });
}
