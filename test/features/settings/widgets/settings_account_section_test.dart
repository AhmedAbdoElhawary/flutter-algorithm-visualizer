import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_account_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';
import '../../../helpers/test_data.dart';

void main() {
  testScreenMatrix('a long name and address fit the screen', (tester, variant) async {
    await pumpApp(
      tester,
      const Scaffold(body: SingleChildScrollView(child: SettingsAccountSection())),
      signedInAs: buildTestUser(name: 'Augusta Ada King, Countess of Lovelace', email: '${'a' * 60}@example.com'),
      screen: variant.screen,
      theme: variant.theme,
      textScale: variant.textScale,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('a guest only has the display name', (tester) async {
    await pumpApp(tester, const Scaffold(body: SettingsAccountSection()));

    expect(find.text(StringsManager.displayName), findsOneWidget);
    expect(find.text(StringsManager.anonymous), findsOneWidget);
    expect(find.text(StringsManager.changeEmail), findsNothing);
    expect(find.text(StringsManager.deleteAccount), findsNothing);
  });

  testWidgets('a signed-in user sees their address, name and every account action', (tester) async {
    final user = buildTestUser();
    await pumpApp(tester, const Scaffold(body: SettingsAccountSection()), signedInAs: user);

    expect(find.text(user.email!), findsOneWidget);
    expect(find.text(user.name!), findsOneWidget);
    for (final row in [StringsManager.changeEmail, StringsManager.changePassword, StringsManager.deleteAccount]) {
      expect(find.text(row), findsOneWidget, reason: row);
    }
  });
}
