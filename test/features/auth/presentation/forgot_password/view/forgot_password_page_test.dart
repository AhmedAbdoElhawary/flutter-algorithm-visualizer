import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_back_button.dart';
import 'package:algorithm_visualizer/features/auth/presentation/confirmation_password/view/confirmation_password_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/forgot_password/view/forgot_password_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view/login_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/screen_matrix.dart';
import '../../../../../helpers/test_data.dart';
import '../../auth_page_harness.dart';

/// The resend countdown is a real 60 second timer, so each test lets it run out.
Future<void> _finishCountdown(WidgetTester tester) => tester.pump(const Duration(seconds: 61));

void main() {
  testScreenMatrix('the form and its error fit the screen', (tester, variant) async {
    final harness = await openAuthPage(
      tester,
      Routes.forgotPassword.path,
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    await harness.tap(StringsManager.sendLink);

    expect(find.text(StringsManager.emailRequired), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an invalid email is caught before Firebase', (tester) async {
    final harness = await openAuthPage(tester, Routes.forgotPassword.path);

    await harness.type(StringsManager.registeredEmail, 'ada');
    await harness.tap(StringsManager.sendLink);

    expect(find.text(StringsManager.invalidEmail), findsOneWidget);
    expect(harness.remote.calls, isEmpty);
  });

  testWidgets('a failure says why and stays here', (tester) async {
    final harness = await openAuthPage(tester, Routes.forgotPassword.path);
    harness.remote.failWith = authError('network-request-failed');

    await harness.type(StringsManager.registeredEmail, existingUser.email);
    await harness.tap(StringsManager.sendLink);

    expect(find.text(StringsManager.networkError), findsOneWidget);
    expect(find.byType(ForgotPasswordPage), findsOneWidget);
    await harness.drain();
  });

  // Firebase does not say whether an address has an account, so nobody can probe for one.
  testWidgets('any valid address, known or not, goes on to "check your email"', (tester) async {
    final harness = await openAuthPage(tester, Routes.forgotPassword.path);

    await harness.type(StringsManager.registeredEmail, 'nobody@test.dev');
    await harness.tap(StringsManager.sendLink);
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmationPasswordPage), findsOneWidget);
    expect(find.textContaining('nobody@test.dev', findRichText: true), findsOneWidget);
    await _finishCountdown(tester);
  });

  testWidgets('coming back during the countdown shows it, and the done key cannot resend', (tester) async {
    final harness = await openAuthPage(tester, Routes.forgotPassword.path);
    await harness.type(StringsManager.registeredEmail, existingUser.email);
    await harness.tap(StringsManager.sendLink);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CustomBackButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('${StringsManager.sendLink} ('), findsOneWidget);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(harness.remote.calls, ['forgotPassword']);

    await _finishCountdown(tester);
    expect(find.text(StringsManager.sendLink), findsOneWidget);
  });

  testWidgets('back and "return to sign in" go to the login page', (tester) async {
    final harness = await openAuthPage(tester, Routes.login.path);
    await harness.tap(StringsManager.forgotShort);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CustomBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    await harness.tap(StringsManager.forgotShort);
    await tester.pumpAndSettle();
    await harness.tap(StringsManager.returnToSignIn);
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
