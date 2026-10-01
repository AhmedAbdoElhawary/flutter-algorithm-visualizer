import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/avatar_quiet.dart';
import 'package:algorithm_visualizer/features/auth/domain/entities/auth_user.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../profile_test_data.dart';

void main() {
  String initial(WidgetTester tester) => tester.widget<AvatarQuiet>(find.byType(AvatarQuiet)).initial;

  testWidgets('a guest is anonymous, with no sync button', (tester) async {
    await pumpProfileWidget(tester, const ProfileHeader());

    expect(find.text(StringsManager.anonymous), findsOneWidget);
    expect(initial(tester), 'A');
    expect(find.byIcon(Icons.sync_rounded), findsNothing);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('a signed-in user sees their name, initial and the sync button', (tester) async {
    await pumpProfileWidget(
      tester,
      const ProfileHeader(),
      signedInAs: const AuthUser(id: 'uid-1', name: 'grace', email: 'grace@test.dev'),
    );

    expect(find.text('grace'), findsOneWidget);
    expect(initial(tester), 'G');
    expect(find.byIcon(Icons.sync_rounded), findsOneWidget);
  });

  testWidgets('a long name stays on one line on a small screen', (tester) async {
    const name = 'Augusta Ada King, Countess of Lovelace and Baroness Wentworth';
    await pumpProfileWidget(
      tester,
      const ProfileHeader(),
      signedInAs: const AuthUser(id: 'uid-1', name: name, email: null),
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    expect(find.text(name), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
