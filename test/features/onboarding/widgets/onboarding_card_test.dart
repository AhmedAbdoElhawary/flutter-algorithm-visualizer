import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_card.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';

void main() {
  for (final clip in [false, true]) {
    testScreenMatrix('the card renders its child, clip: $clip', (tester, variant) async {
      await pumpApp(
        tester,
        OnboardingCard(clip: clip, child: const MonoText(StringsManager.onboardingEditorFile)),
        screen: variant.screen,
        theme: variant.theme,
        textScale: variant.textScale,
      );

      expect(find.text(StringsManager.onboardingEditorFile), findsOneWidget);
      expect(find.byType(ClipRRect), clip ? findsOneWidget : findsNothing);
    });
  }

  testScreenMatrix('the legend shows every item and wraps instead of overflowing', (tester, variant) async {
    await pumpApp(
      tester,
      const Center(
        child: OnboardingCaptionBar(
          child: OnboardingLegend(
            items: [
              LegendItem(color: ThemeEnum.dataEasy, label: StringsManager.onboardingLegendCompare),
              LegendItem(color: ThemeEnum.dataMedium, label: StringsManager.onboardingLegendSwap),
              LegendItem(color: ThemeEnum.dataTarget, label: StringsManager.onboardingLegendSorted),
            ],
          ),
        ),
      ),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.text(StringsManager.onboardingLegendCompare), findsOneWidget);
    expect(find.text(StringsManager.onboardingLegendSwap), findsOneWidget);
    expect(find.text(StringsManager.onboardingLegendSorted), findsOneWidget);
  });
}
