import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/features/profile/presentation/view_model/user_provider.dart';
import 'package:algorithm_visualizer/features/settings/widgets/change_display_name_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';
import '../../../helpers/test_data.dart';
import 'account_dialog_harness.dart';

extension on AccountDialogHarness {
  String get name => container.read(currentUserNameProvider);

  Future<void> type(String name) async {
    await tester.enterText(find.widgetWithText(AuthTextField, StringsManager.newDisplayName), name);
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
      (onClose) => ChangeDisplayNameDialog(onClose: onClose),
      screen: screen,
      theme: theme,
      textScale: textScale,
    );

void main() {
  testScreenMatrix('fits the screen with a too-long name and its error', (tester, variant) async {
    final harness = await _pumpDialog(
      tester,
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );
    await harness.type('A' * 120);
    await harness.save();

    expect(find.text(StringsManager.nameMaxLength), findsOneWidget);
    expect(tester.takeException(), isNull);
    await harness.drain();
  });

  testWidgets('starts with the current name filled in', (tester) async {
    await _pumpDialog(tester);

    expect(find.text(buildTestUser().name!), findsOneWidget);
  });

  group('refuses and says why', () {
    for (final (input, message) in [
      ('', StringsManager.newDisplayNameRequired),
      ('    ', StringsManager.newDisplayNameRequired),
      ('A', StringsManager.nameMinLength),
      ('A' * 51, StringsManager.nameMaxLength),
      (buildTestUser().name!, StringsManager.sameDisplayNameAsCurrent),
    ]) {
      testWidgets('"$input"', (tester) async {
        final harness = await _pumpDialog(tester);

        await harness.type(input);
        await harness.save();

        expect(find.text(message), findsOneWidget);
        expect(harness.remote.calls, isEmpty);
        expect(harness.closed, 0);
      });
    }
  });

  testWidgets('the error clears as soon as the name is edited', (tester) async {
    final harness = await _pumpDialog(tester);
    await harness.type('');
    await harness.save();

    await harness.type('G');

    expect(find.text(StringsManager.newDisplayNameRequired), findsNothing);
  });

  testWidgets('a valid name is saved, then the dialog closes and says so', (tester) async {
    final harness = await _pumpDialog(tester);

    await harness.type('  Grace Hopper  ');
    await harness.save();
    await tester.pump();

    expect(harness.remote.calls, ['updateDisplayName']);
    expect(harness.name, 'Grace Hopper');
    expect(harness.closed, 1);
    expect(find.text(StringsManager.displayNameUpdated), findsOneWidget);
    await harness.drain();
  });

  testWidgets('a name of exactly 50 characters is saved', (tester) async {
    final harness = await _pumpDialog(tester);

    await harness.type('A' * 50);
    await harness.save();

    expect(harness.name, 'A' * 50);
    await harness.drain();
  });

  testWidgets('a failed save shows the real reason and keeps the dialog open', (tester) async {
    final harness = await _pumpDialog(tester);
    harness.remote.failWith = authError('network-request-failed');

    await harness.type('Grace Hopper');
    await harness.save();
    await tester.pump();

    expect(harness.closed, 0);
    expect(harness.name, buildTestUser().name);
    expect(find.text(StringsManager.networkError), findsOneWidget);
  });

  testWidgets('cancel changes nothing', (tester) async {
    final harness = await _pumpDialog(tester);
    await harness.type('Grace Hopper');

    await harness.tap(StringsManager.cancel);

    expect(harness.closed, 1);
    expect(harness.remote.calls, isEmpty);
    expect(harness.name, buildTestUser().name);
  });

  testWidgets('a double tap on save saves once', (tester) async {
    final harness = await _pumpDialog(tester);
    harness.remote.delay = const Duration(seconds: 1);
    await harness.type('Grace Hopper');

    await tester.tap(find.text(StringsManager.saveChanges));
    await tester.tap(find.text(StringsManager.saveChanges));
    await tester.pump(const Duration(seconds: 2));

    expect(harness.remote.calls, ['updateDisplayName']);
    expect(harness.closed, 1);
    await harness.drain();
  });
}
