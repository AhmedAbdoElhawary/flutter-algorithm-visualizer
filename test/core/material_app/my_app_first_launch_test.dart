import 'package:algorithm_visualizer/core/material_app/my_app.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:algorithm_visualizer/features/onboarding/view/onboarding_page.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_launch.dart';

void main() {
  setUpLaunch(onboardingSeen: false);

  testWidgets('the first launch opens on onboarding', (tester) async {
    await pumpLaunch(tester, const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });
}
