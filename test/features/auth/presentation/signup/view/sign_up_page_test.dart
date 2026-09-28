import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/auth/presentation/login/view/login_page.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/screen_matrix.dart';
import '../../auth_page_harness.dart';

extension on AuthPageHarness {
  Future<void> fill({
    String name = 'Grace Hopper',
    String email = 'grace@test.dev',
    String password = 'Secret-12345',
    String? confirm,
  }) async {
    await type(StringsManager.fullName, name);
    await type(StringsManager.emailAddress, email);
    await type(StringsManager.password, password);
    await type(StringsManager.confirmPassword, confirm ?? password);
  }
}

void main() {
  testScreenMatrix('the empty form and its errors fit the screen', (tester, variant) async {
    final harness = await openAuthPage(
      tester,
      Routes.signUp.path,
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );
    expect(tester.takeException(), isNull, reason: 'empty');

    await harness.tap(StringsManager.createAccount);
    expect(find.text(StringsManager.nameRequired), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'errors');
  });

  testWidgets('an invalid email is caught before Firebase', (tester) async {
    final harness = await openAuthPage(tester, Routes.signUp.path);

    await harness.fill(email: 'grace');
    await harness.tap(StringsManager.createAccount);

    expect(find.text(StringsManager.invalidEmail), findsOneWidget);
    expect(harness.remote.calls, isEmpty);
  });

  testWidgets('the strength meter follows the password, and a weak one is refused', (tester) async {
    final harness = await openAuthPage(tester, Routes.signUp.path);

    await harness.type(StringsManager.password, 'abc');
    expect(find.textContaining(StringsManager.pwStrengthWeak), findsOneWidget);

    await harness.type(StringsManager.password, 'Secret-12345!');
    expect(find.textContaining(StringsManager.pwStrengthStrong), findsOneWidget);

    await harness.fill(password: '12345');
    await harness.tap(StringsManager.createAccount);
    expect(find.text(StringsManager.passwordMinLength), findsOneWidget);
    expect(find.textContaining(StringsManager.pwStrengthWeak), findsNothing, reason: 'the error replaces the meter');
  });

  testWidgets('an address already in use says so and stays here', (tester) async {
    final harness = await openAuthPage(tester, Routes.signUp.path);

    await harness.fill(email: existingUser.email);
    await harness.tap(StringsManager.createAccount);

    expect(find.text(StringsManager.userAlreadyExists), findsOneWidget);
    expect(harness.remote.accounts, hasLength(1));
    await harness.drain();
  });

  testWidgets('success creates the account and goes home', (tester) async {
    final harness = await openAuthPage(tester, Routes.signUp.path);

    await harness.fill();
    await harness.tap(StringsManager.createAccount);
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(harness.remote.accounts, contains('grace@test.dev'));
  });

  testWidgets('the name a guest picked is filled in', (tester) async {
    final harness = await openAuthPage(tester, Routes.login.path);
    await harness.container.read(profileLocalDataSourceProvider).saveDisplayName('Visitor');

    await harness.tap(StringsManager.signUp);
    await tester.pumpAndSettle();

    expect(find.text('Visitor'), findsOneWidget);
  });

  testWidgets('"sign in" goes back to the login page', (tester) async {
    final harness = await openAuthPage(tester, Routes.signUp.path);

    await harness.tap(StringsManager.signIn);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
