import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';

void main() {
  testScreenMatrix('renders the mono texts and the headline copy', (tester, variant) async {
    await pumpApp(
      tester,
      const Column(
        children: [
          MonoText(StringsManager.onboardingEditorFile, translate: false),
          MonoBoldText(StringsManager.onboardingPassedWord, color: ThemeEnum.dataEasy),
          OnboardingCopy(
            headline: StringsManager.onboardingTrackHeadline,
            body: StringsManager.onboardingTrackBody,
          ),
        ],
      ),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.text(StringsManager.onboardingEditorFile), findsOneWidget);
    expect(find.text(StringsManager.onboardingPassedWord), findsOneWidget);
    expect(find.text(StringsManager.onboardingTrackHeadline), findsOneWidget);
    expect(find.text(StringsManager.onboardingTrackBody), findsOneWidget);
  });
}
