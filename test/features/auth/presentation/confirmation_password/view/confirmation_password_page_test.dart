import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';
import '../../../../../helpers/screen_matrix.dart';
import '../../../../../helpers/test_data.dart';
import '../../auth_page_harness.dart';

/// Sends the link from the forgot password page, the only way to get here.
Future<AuthPageHarness> _sendLink(
  WidgetTester tester, {
  ScreenSize screen = ScreenSize.phone,
  ThemeMode theme = ThemeMode.light,
  double textScale = 1.0,
}) async {
  final harness = await openAuthPage(
    tester,
    Routes.forgotPassword.path,
    screen: screen,
    theme: theme,
    textScale: textScale,
  );
  await harness.type(StringsManager.registeredEmail, existingUser.email);
  await harness.tap(StringsManager.sendLink);
  await tester.pumpAndSettle();
  return harness;
}

void main() {
  testScreenMatrix('fits the screen', (tester, variant) async {
    await _sendLink(tester, screen: variant.screen, theme: variant.theme, textScale: variant.textScale);

    expect(find.text(StringsManager.checkEmail), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 61));
  });

  testWidgets('names the address and counts down before a resend is allowed', (tester) async {
    final harness = await _sendLink(tester);

    expect(find.textContaining(existingUser.email, findRichText: true), findsOneWidget);
    expect(find.textContaining('60s', findRichText: true), findsOneWidget);

    await harness.tap(StringsManager.resendEmailLink);
    expect(harness.remote.calls, ['forgotPassword'], reason: 'resend is off during the countdown');

    await tester.pump(const Duration(seconds: 61));
    await harness.tap(StringsManager.resendEmailLink);
    expect(harness.remote.calls, ['forgotPassword', 'forgotPassword']);
    await tester.pump(const Duration(seconds: 61));
  });

  testWidgets('a failed resend says why', (tester) async {
    final harness = await _sendLink(tester);
    await tester.pump(const Duration(seconds: 61));
    harness.remote.failWith = authError('too-many-requests');

    await harness.tap(StringsManager.resendEmailLink);

    expect(find.text(StringsManager.tooManyAttempts), findsOneWidget);
    await harness.drain();
  });

  testWidgets('"return to sign in" goes to the login page', (tester) async {
    final harness = await _sendLink(tester);

    await harness.tap(StringsManager.returnToSignIn);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    await tester.pump(const Duration(seconds: 61));
  });
}
