import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/settings/widgets/settings_session_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/screen_matrix.dart';
import '../../../helpers/test_data.dart';

void main() {
  testScreenMatrix('both cards fit the screen', (tester, variant) async {
    for (final signedIn in [false, true]) {
      await pumpApp(
        tester,
        const Scaffold(body: SettingsSessionCard()),
        signedInAs: signedIn ? buildTestUser() : null,
        screen: variant.screen,
        theme: variant.theme,
        textScale: variant.textScale,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('a guest is offered a way in', (tester) async {
    await pumpApp(tester, const Scaffold(body: SettingsSessionCard()));
    await tester.pumpAndSettle();

    expect(find.text(StringsManager.guestAccountTitle), findsOneWidget);
    expect(find.text(StringsManager.guestAccountDesc), findsOneWidget);
    expect(find.text(StringsManager.logout), findsNothing);
  });

  testWidgets('a signed-in user is offered log out, and it asks first', (tester) async {
    await pumpApp(tester, const Scaffold(body: SettingsSessionCard()), signedInAs: buildTestUser());

    await tester.tap(find.text(StringsManager.logout));
    await tester.pumpAndSettle();

    expect(find.text(StringsManager.logoutConfirmTitle), findsOneWidget);
    expect(find.text(StringsManager.guestAccountTitle), findsNothing);
  });
}
