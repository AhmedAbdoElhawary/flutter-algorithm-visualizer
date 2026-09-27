import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/features/settings/widgets/change_email_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';
import '../../../helpers/test_data.dart';
import 'account_dialog_harness.dart';

extension on AccountDialogHarness {
  Future<void> fill({String email = 'grace@test.dev', String password = accountPassword}) async {
    await tester.enterText(find.widgetWithText(AuthTextField, StringsManager.newEmail), email);
    await tester.enterText(find.widgetWithText(AuthTextField, StringsManager.currentPassword), password);
    await tester.pump();
  }

  Future<void> save() => tap(StringsManager.saveChanges);
}

Future<AccountDialogHarness> _pumpDialog(
  WidgetTester tester, {
  ScreenSize screen = ScreenSize.phone,
  ThemeMode theme = ThemeMode.light,
  double textScale = 1.0,
}) =>
    pumpAccountDialog(
      tester,
      (onClose) => ChangeEmailDialog(onClose: onClose),
      screen: screen,
      theme: theme,
      textScale: textScale,
    );

void main() {
  testScreenMatrix('fits the screen with both errors showing', (tester, variant) async {
    final harness =
        await _pumpDialog(tester, screen: variant.screen, theme: variant.theme, textScale: variant.textScale);

    await harness.save();

    expect(find.text(StringsManager.newEmailRequired), findsOneWidget);
    expect(find.text(StringsManager.currentPasswordRequired), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('refuses before asking Firebase', () {
    for (final (email, message) in [
      ('not-an-email', StringsManager.invalidEmail),
      (buildTestUser().email!, StringsManager.sameEmailAsCurrent),
      (buildTestUser().email!.toUpperCase(), StringsManager.sameEmailAsCurrent),
    ]) {
      testWidgets(email, (tester) async {
        final harness = await _pumpDialog(tester);

        await harness.fill(email: email);
        await harness.save();

        expect(find.text(message), findsOneWidget);
        expect(harness.remote.calls, isEmpty);
        expect(harness.closed, 0);
      });
    }
  });

  group('a refused change shows why and keeps the dialog open', () {
    for (final (name, error, message) in [
      ('email already in use', authError('email-already-in-use'), StringsManager.userAlreadyExists),
      ('sign-in too old', authError('requires-recent-login'), StringsManager.reauthenticateRequired),
      ('network down', authError('network-request-failed'), StringsManager.networkError),
    ]) {
      testWidgets(name, (tester) async {
        final harness = await _pumpDialog(tester);
        harness.remote.failWith = error;

        await harness.fill();
        await harness.save();

        expect(find.text(message), findsOneWidget);
        expect(harness.closed, 0);
        await harness.drain();
      });
    }

    testWidgets('wrong password', (tester) async {
      final harness = await _pumpDialog(tester);

      await harness.fill(password: 'wrong');
      await harness.save();

      expect(find.text(StringsManager.invalidCredentials), findsOneWidget);
      expect(harness.closed, 0);
      await harness.drain();
    });
  });

  testWidgets('a good request sends the link, closes, and says so', (tester) async {
    final harness = await _pumpDialog(tester);

    await harness.fill();
    await harness.save();

    expect(harness.remote.calls, ['updateEmail']);
    expect(harness.closed, 1);
    expect(find.text(StringsManager.changeEmailLinkSent), findsOneWidget);
    await harness.drain();
  });

  testWidgets('cancel sends nothing', (tester) async {
    final harness = await _pumpDialog(tester);
    await harness.fill();

    await harness.tap(StringsManager.cancel);

    expect(harness.closed, 1);
    expect(harness.remote.calls, isEmpty);
  });

  testWidgets('a double tap on save sends once', (tester) async {
    final harness = await _pumpDialog(tester);
    harness.remote.delay = const Duration(seconds: 1);
    await harness.fill();

    await tester.tap(find.text(StringsManager.saveChanges));
    await tester.tap(find.text(StringsManager.saveChanges));
    await tester.pump(const Duration(seconds: 2));

    expect(harness.remote.calls, ['updateEmail']);
    expect(harness.closed, 1);
    await harness.drain();
  });
}
