import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/features/auth/data/models/auth_user_dto.dart';
import 'package:algorithm_visualizer/features/auth/presentation/common/view_model/auth_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/problems_providers.dart';
import 'package:algorithm_visualizer/features/settings/widgets/delete_account_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fakes/fake_auth_remote_data_source.dart';
import '../../../helpers/fakes/fake_problem_remote_data_source.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';
import '../../../helpers/test_data.dart';

const _password = 'secret-1';

class _Harness {
  _Harness(this.tester, this.container);

  final WidgetTester tester;
  final ProviderContainer container;

  FakeAuthRemoteDataSource get auth => container.read(authRemoteDataSourceProvider) as FakeAuthRemoteDataSource;

  FakeProblemRemoteDataSource get problems =>
      container.read(problemRemoteDataSourceProvider) as FakeProblemRemoteDataSource;

  String get location =>
      GoRouter.of(tester.element(find.byType(Navigator).first)).routerDelegate.currentConfiguration.uri.path;

  Future<void> tap(String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> type(String password) async {
    await tester.enterText(find.widgetWithText(AuthTextField, StringsManager.password), password);
    await tester.pump();
  }
}

/// Opens Settings as a signed-in user and walks to the password step, the way a user gets there.
Future<_Harness> _openPasswordStep(
  WidgetTester tester, {
  ScreenSize screen = ScreenSize.phone,
  ThemeMode theme = ThemeMode.light,
  double textScale = 1.0,
}) async {
  final user = buildTestUser();
  final container = await pumpApp(
    tester,
    const SizedBox(),
    signedInAs: user,
    initialRoute: '${Routes.profile.path}/${Routes.settings.path}',
    screen: screen,
    theme: theme,
    textScale: textScale,
  );
  await tester.pumpAndSettle();
  final harness = _Harness(tester, container);

  final dto = AuthUserDTO(id: user.id, name: user.name!, email: user.email!);
  harness.auth
    ..accounts[dto.email] = (user: dto, password: _password)
    ..signedIn = dto;

  await harness.tap(StringsManager.deleteAccount);
  expect(find.text(StringsManager.deleteAccountConfirmTitle), findsOneWidget);
  await harness.tap(StringsManager.deleteAccountContinue);
  expect(find.byType(DeleteAccountDialog), findsOneWidget);
  return harness;
}

/// The result message stays up for 3 seconds.
Future<void> _drain(WidgetTester tester) => tester.pump(const Duration(seconds: 5));

void main() {
  testScreenMatrix('the password step fits the screen', (tester, variant) async {
    await _openPasswordStep(tester, screen: variant.screen, theme: variant.theme, textScale: variant.textScale);

    expect(find.text(StringsManager.deleteAccountPasswordTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelling the warning deletes nothing', (tester) async {
    final user = buildTestUser();
    final container = await pumpApp(
      tester,
      const SizedBox(),
      signedInAs: user,
      initialRoute: '${Routes.profile.path}/${Routes.settings.path}',
    );
    await tester.pumpAndSettle();
    final harness = _Harness(tester, container);

    await harness.tap(StringsManager.deleteAccount);
    await harness.tap(StringsManager.cancel);

    expect(find.byType(DeleteAccountDialog), findsNothing);
    expect(harness.auth.calls, isEmpty);
  });

  testWidgets('an empty password is refused before asking Firebase', (tester) async {
    final harness = await _openPasswordStep(tester);

    await harness.tap(StringsManager.deleteAccountConfirmButton);

    expect(find.text(StringsManager.passwordRequired), findsOneWidget);
    expect(harness.auth.calls, isEmpty);
  });

  testWidgets('a wrong password keeps the account and the dialog', (tester) async {
    final harness = await _openPasswordStep(tester);

    await harness.type('wrong');
    await harness.tap(StringsManager.deleteAccountConfirmButton);

    expect(find.text(StringsManager.invalidCredentials), findsOneWidget);
    expect(find.byType(DeleteAccountDialog), findsOneWidget);
    expect(harness.auth.accounts, contains(buildTestUser().email));
    expect(harness.problems.calls, isNot(contains('deleteAllProblems')), reason: 'nothing is wiped before the password is proven');
    await _drain(tester);
  });

  testWidgets('the right password deletes the account and its data, then goes to login', (tester) async {
    final harness = await _openPasswordStep(tester);

    await harness.type(_password);
    await harness.tap(StringsManager.deleteAccountConfirmButton);

    expect(harness.auth.accounts, isEmpty);
    expect(harness.auth.signedIn, isNull);
    expect(harness.problems.calls, contains('deleteAllProblems'));
    expect(harness.location, Routes.login.path);
    expect(find.text(StringsManager.deleteAccountSuccess), findsOneWidget);
    await _drain(tester);
  });

  testWidgets('while deleting, the buttons are disabled and a second tap does nothing', (tester) async {
    final harness = await _openPasswordStep(tester);
    harness.auth.delay = const Duration(seconds: 2);
    await harness.type(_password);

    await tester.tap(find.text(StringsManager.deleteAccountConfirmButton));
    await tester.tap(find.text(StringsManager.deleteAccountConfirmButton));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text(StringsManager.cancel));
    await tester.pump();
    expect(find.byType(DeleteAccountDialog), findsOneWidget, reason: 'cancel is disabled while deleting');

    await tester.pumpAndSettle();
    expect(harness.auth.calls, ['deleteAccount']);
    expect(harness.location, Routes.login.path);
    await _drain(tester);
  });
}
