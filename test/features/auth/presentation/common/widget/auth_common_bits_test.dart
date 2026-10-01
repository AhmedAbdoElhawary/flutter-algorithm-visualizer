import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/widget/auth_common_bits.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';
import '../../../../../helpers/screen_matrix.dart';

void main() {
  // The eyebrow row needs the router for its back button; it is checked on the recovery pages instead.
  testScreenMatrix('every piece fits the screen', (tester, variant) async {
    await pumpApp(
      tester,
      Scaffold(
        body: ListView(
          children: [
            const AuthTitle(StringsManager.createAccount, large: true),
            const AuthTitle(StringsManager.forgotPasswordTitle),
            const AuthSubtitle(StringsManager.signUpSubtitle),
            const AuthCombineSubtitle(text: 'We sent it to', highlightedText: 'ada@test.dev', secondText: 'Open it.'),
            AuthFooterPrompt(prompt: StringsManager.noAccountYet, action: StringsManager.signUp, onTap: () {}),
            const AuthReturnLink(StringsManager.returnToSignIn),
          ],
        ),
      ),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('the combined subtitle reads as one sentence around the address', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: AuthCombineSubtitle(text: 'We sent it to', highlightedText: 'ada@test.dev', secondText: 'Open it.'),
      ),
    );

    expect(find.textContaining('We sent it to ada@test.dev', findRichText: true), findsOneWidget);
  });

  testWidgets('tapping either part of the footer prompt calls back', (tester) async {
    var taps = 0;
    await pumpApp(
      tester,
      Scaffold(
        body: AuthFooterPrompt(prompt: StringsManager.noAccountYet, action: StringsManager.signUp, onTap: () => taps++),
      ),
    );

    await tester.tap(find.text(StringsManager.noAccountYet));
    await tester.tap(find.text(StringsManager.signUp));

    expect(taps, 2);
  });

  testWidgets('the return link goes to the login page', (tester) async {
    await pumpApp(tester, const SizedBox(), initialRoute: Routes.forgotPassword.path);
    await tester.pumpAndSettle();

    await tester.tap(find.text(StringsManager.returnToSignIn));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
