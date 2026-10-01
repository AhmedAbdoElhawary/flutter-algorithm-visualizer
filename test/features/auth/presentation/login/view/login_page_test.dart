import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_back_button.dart';
import 'package:algorithm_visualizer/features/auth/presentation/forgot_password/view/forgot_password_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view/login_page.dart';
import 'package:algorithm_visualizer/features/auth/presentation/signup/view/sign_up_page.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/screen_matrix.dart';
import '../../../../../helpers/test_data.dart';
import '../../auth_page_harness.dart';

extension on AuthPageHarness {
  Future<void> signIn(String email, String password) async {
    await type(StringsManager.emailAddress, email);
    await type(StringsManager.password, password);
    await tap(StringsManager.signIn);
  }
}

void main() {
  testScreenMatrix('idle, loading and error fit the screen', (tester, variant) async {
    final harness = await openAuthPage(
      tester,
      Routes.login.path,
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );
    expect(tester.takeException(), isNull, reason: 'idle');

    await harness.tap(StringsManager.signIn);
    expect(find.text(StringsManager.emailRequired), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'errors');

    harness.remote.delay = const Duration(seconds: 1);
    await harness.signIn(existingUser.email, 'wrong-1');
    expect(tester.takeException(), isNull, reason: 'loading');

    await tester.pump(const Duration(seconds: 1));
    expect(find.text(StringsManager.invalidCredentials), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'error message');
    await harness.drain();
  });

  testWidgets('the page opens with its own title', (tester) async {
    await openAuthPage(tester, Routes.login.path);

    expect(find.text(StringsManager.welcome), findsOneWidget);
  });

  testWidgets('empty fields say what is missing', (tester) async {
    final harness = await openAuthPage(tester, Routes.login.path);

    await harness.tap(StringsManager.signIn);

    expect(find.text(StringsManager.emailRequired), findsOneWidget);
    expect(find.text(StringsManager.passwordRequired), findsOneWidget);
    expect(harness.remote.calls, isEmpty);
  });

  testWidgets('an invalid email is caught before Firebase', (tester) async {
    final harness = await openAuthPage(tester, Routes.login.path);

    await harness.signIn('ada', existingPassword);

    expect(find.text(StringsManager.invalidEmail), findsOneWidget);
    expect(harness.remote.calls, isEmpty);
  });

  group('a refused sign-in shows why and stays here', () {
    for (final (name, error, message) in [
      ('wrong password', null, StringsManager.invalidCredentials),
      ('too many attempts', authError('too-many-requests'), StringsManager.tooManyAttempts),
      ('network down', authError('network-request-failed'), StringsManager.networkError),
    ]) {
      testWidgets(name, (tester) async {
        final harness = await openAuthPage(tester, Routes.login.path);
        harness.remote.failWith = error;

        await harness.signIn(existingUser.email, error == null ? 'wrong-1' : existingPassword);

        expect(find.text(message), findsOneWidget);
        expect(find.byType(LoginPage), findsOneWidget);
        await harness.drain();
      });
    }
  });

  testWidgets('the same failure twice shows its message twice', (tester) async {
    final harness = await openAuthPage(tester, Routes.login.path);
    await harness.signIn(existingUser.email, 'wrong-1');
    await harness.drain();

    await harness.tap(StringsManager.signIn);

    expect(find.text(StringsManager.invalidCredentials), findsOneWidget);
    await harness.drain();
  });

  testWidgets('success goes home, signed in', (tester) async {
    final harness = await openAuthPage(tester, Routes.login.path);

    await harness.signIn(existingUser.email, existingPassword);
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(harness.remote.signedIn?.id, existingUser.id);
  });

  testWidgets('a guest with progress is warned first, and can back out', (tester) async {
    final harness = await openAuthPage(tester, Routes.login.path);
    await harness.container.read(profileLocalDataSourceProvider).saveDisplayName('Visitor');

    await harness.signIn(existingUser.email, existingPassword);
    await tester.pumpAndSettle();
    expect(find.text(StringsManager.guestProgressWarningTitle), findsOneWidget);
    expect(harness.remote.calls, isEmpty);

    await harness.tap(StringsManager.cancel);
    await tester.pumpAndSettle();
    expect(harness.remote.calls, isEmpty);

    await harness.tap(StringsManager.signIn);
    await tester.pumpAndSettle();
    await harness.tap(StringsManager.continueToLogin);
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('the links go to forgot password, sign up, and skip goes home', (tester) async {
    final harness = await openAuthPage(tester, Routes.login.path);

    await harness.tap(StringsManager.forgotShort);
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordPage), findsOneWidget);

    await tester.tap(find.byType(CustomBackButton));
    await tester.pumpAndSettle();
    await harness.tap(StringsManager.signUp);
    await tester.pumpAndSettle();
    expect(find.byType(SignUpPage), findsOneWidget);

    await tester.tap(find.byType(CustomBackButton));
    await tester.pumpAndSettle();
    await harness.tap(StringsManager.onboardingSkip);
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(harness.container.read(isSignedInProvider), isFalse);
  });
}
