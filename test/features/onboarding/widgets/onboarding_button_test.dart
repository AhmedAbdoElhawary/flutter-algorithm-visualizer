import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_button.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';

void main() {
  for (final style in OnboardingButtonStyle.values) {
    testScreenMatrix('the ${style.name} button renders its label', (tester, variant) async {
      await pumpApp(
        tester,
        OnboardingButton(label: StringsManager.onboardingGetStarted, style: style, onPressed: () {}),
        screen: variant.screen,
        theme: variant.theme,
        textScale: variant.textScale,
      );

      expect(find.text(StringsManager.onboardingGetStarted), findsOneWidget);
    });
  }

  testWidgets('a tap calls onPressed once', (tester) async {
    var taps = 0;
    await pumpApp(tester, OnboardingButton(label: StringsManager.onboardingNext, onPressed: () => taps++));

    await tester.tap(find.text(StringsManager.onboardingNext));

    expect(taps, 1);
  });

  testWidgets('holding and then cancelling the press does not call onPressed', (tester) async {
    var taps = 0;
    await pumpApp(
      tester,
      OnboardingButton(
        label: StringsManager.onboardingNext,
        style: OnboardingButtonStyle.filled,
        onPressed: () => taps++,
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.text(StringsManager.onboardingNext)));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 300));
    await gesture.up();
    await tester.pump();

    expect(taps, 0);
  });
}
