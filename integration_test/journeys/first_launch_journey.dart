import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/reset.dart';
import '../support/steps.dart';

void firstLaunchJourney() {
  group('first launch', () {
    testWidgets('onboarding shows once, then the app opens on home', (tester) async {
      await launchApp(tester);
      await pumpUntil(tester, find.text(StringsManager.onboardingSeeItHeadline));

      for (var page = 0; page < 3; page++) {
        await tapOn(tester, find.text(StringsManager.onboardingNext));
        // Onboarding loops an animation, so it never settles; the page slide takes 360 ms.
        await tester.pump(const Duration(milliseconds: 800));
      }
      await tapOn(tester, find.text(StringsManager.onboardingContinueAsGuest));
      await pumpUntil(tester, find.byType(HomePage));

      await launchApp(tester);
      await pumpUntil(tester, find.byType(HomePage));
      expect(find.text(StringsManager.onboardingSeeItHeadline), findsNothing);
    });
  });
}
