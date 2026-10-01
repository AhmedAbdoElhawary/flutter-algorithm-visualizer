import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/features/settings/widgets/change_password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';
import '../../../helpers/test_data.dart';
import 'account_dialog_harness.dart';

extension on AccountDialogHarness {
  Future<void> fill({String current = accountPassword, String next = 'secret-2', String? confirm}) async {
    await tester.enterText(find.widgetWithText(AuthTextField, StringsManager.currentPassword), current);
    await tester.enterText(find.widgetWithText(AuthTextField, StringsManager.newPassword), next);
    await tester.enterText(find.widgetWithText(AuthTextField, StringsManager.confirmNewPassword), confirm ?? next);
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
      (onClose) => ChangePasswordDialog(onClose: onClose),
      screen: screen,
      theme: theme,
      textScale: textScale,
    );

void main() {
  testScreenMatrix('fits the screen with all three errors showing', (tester, variant) async {
    final harness =
        await _pumpDialog(tester, screen: variant.screen, theme: variant.theme, textScale: variant.textScale);

    await harness.save();

    expect(find.text(StringsManager.currentPasswordRequired), findsOneWidget);
    expect(find.text(StringsManager.newPasswordRequired), findsOneWidget);
    expect(find.text(StringsManager.confirmPasswordRequired), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('refuses before asking Firebase', () {
    for (final (name, next, confirm, message) in [
      ('a weak new password', '12345', '12345', StringsManager.passwordMinLength),
      ('the same password as now', accountPassword, accountPassword, StringsManager.samePasswordAsCurrent),
      ('a confirmation that does not match', 'secret-2', 'secret-3', StringsManager.passwordsDoNotMatch),
    ]) {
      testWidgets(name, (tester) async {
        final harness = await _pumpDialog(tester);

        await harness.fill(next: next, confirm: confirm);
        await harness.save();

        expect(find.text(message), findsOneWidget);
        expect(harness.remote.calls, isEmpty);
        expect(harness.closed, 0);
      });
    }
  });

  testWidgets('a wrong current password is refused and the dialog stays open', (tester) async {
    final harness = await _pumpDialog(tester);

    await harness.fill(current: 'wrong');
    await harness.save();

    expect(find.text(StringsManager.invalidCredentials), findsOneWidget);
    expect(harness.remote.password, accountPassword);
    expect(harness.closed, 0);
    await harness.drain();
  });

  testWidgets('a sign-in that is too old asks to log in again', (tester) async {
    final harness = await _pumpDialog(tester);
    harness.remote.failWith = authError('requires-recent-login');

    await harness.fill();
    await harness.save();

    expect(find.text(StringsManager.reauthenticateRequired), findsOneWidget);
    expect(harness.closed, 0);
    await harness.drain();
  });

  testWidgets('a good change is saved, closes, and says so', (tester) async {
    final harness = await _pumpDialog(tester);

    await harness.fill();
    await harness.save();

    expect(harness.remote.password, 'secret-2');
    expect(harness.closed, 1);
    expect(find.text(StringsManager.passwordUpdated), findsOneWidget);
    await harness.drain();
  });

  testWidgets('a double tap on save changes it once', (tester) async {
    final harness = await _pumpDialog(tester);
    harness.remote.delay = const Duration(seconds: 1);
    await harness.fill();

    await tester.tap(find.text(StringsManager.saveChanges));
    await tester.tap(find.text(StringsManager.saveChanges));
    await tester.pump(const Duration(seconds: 2));

    expect(harness.remote.calls, ['updatePassword']);
    expect(harness.closed, 1);
    await harness.drain();
  });
}
