import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/home/view/widgets/home_header.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/screen_matrix.dart';
import '../../../../helpers/test_data.dart';
import 'home_test_problems.dart';

void main() {
  testScreenMatrix('guest sees the sign-in link', (tester, variant) async {
    await pumpApp(
      tester,
      const HomeHeader(),
      overrides: [problemsOverride([])],
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.text(StringsManager.signIn), findsOneWidget);
    expect(find.textContaining(StringsManager.anonymous), findsOneWidget);
  });

  testScreenMatrix('a signed-in user with a very long name sees it without overflow',
      (tester, variant) async {
    await pumpApp(
      tester,
      const HomeHeader(),
      overrides: [problemsOverride([])],
      signedInAs: buildTestUser(name: longName),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(find.textContaining(longName), findsOneWidget);
    expect(find.text(StringsManager.signIn), findsNothing);
  });

  testWidgets('tapping sign in opens the login page', (tester) async {
    await pumpApp(tester, const SizedBox(),
        overrides: [problemsOverride([])], initialRoute: Routes.home.path);
    await tester.pump();

    await tester.tap(find.text(StringsManager.signIn));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
