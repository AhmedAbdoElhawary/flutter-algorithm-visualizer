import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/onboarding/widgets/onboarding_dots.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';

const _accents = [ThemeEnum.inkPrimary, ThemeEnum.inkPrimary, ThemeEnum.inkPrimary, ThemeEnum.dataMedium];

void main() {
  double widthOf(WidgetTester tester, int index) =>
      tester.getSize(find.byKey(OnboardingDots.dotKey(index))).width;

  testScreenMatrix('renders one dot per page', (tester, variant) async {
    await pumpApp(
      tester,
      const OnboardingDots(offset: 0, accents: _accents),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    for (var index = 0; index < _accents.length; index++) {
      expect(find.byKey(OnboardingDots.dotKey(index)), findsOneWidget);
    }
  });

  for (final active in [0, 1, _accents.length - 1]) {
    testWidgets('dot $active is the wide one when the offset is $active', (tester) async {
      await pumpApp(tester, OnboardingDots(offset: active.toDouble(), accents: _accents));

      for (var index = 0; index < _accents.length; index++) {
        if (index == active) continue;
        expect(widthOf(tester, active), greaterThan(widthOf(tester, index)), reason: 'dot $index');
      }
    });
  }

  testWidgets('halfway through a swipe both dots are the same width', (tester) async {
    await pumpApp(tester, const OnboardingDots(offset: 1.5, accents: _accents));

    expect(widthOf(tester, 1), moreOrLessEquals(widthOf(tester, 2)));
    expect(widthOf(tester, 1), greaterThan(widthOf(tester, 0)));
  });
}
