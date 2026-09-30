import 'dart:convert';

import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/reset.dart';
import '../support/steps.dart';

const _newPassword = 'second-pass-456';

void accountJourney() {
  group('account', () {
    testWidgets('sign up, log out and in, rename, change password, then delete the account', (tester) async {
      await launchApp(tester);
      await signUp(tester);
      await openTab(tester, StringsManager.profile);
      await openSettings(tester);
      await logOut(tester);
      await logIn(tester, testPassword);

      await openTab(tester, StringsManager.profile);
      await openSettings(tester);
      await tapOn(tester, find.text(StringsManager.displayName));
      await typeInto(tester, StringsManager.newDisplayNameHint, 'Ada');
      await tapOn(tester, find.text(StringsManager.saveChanges));
      await pumpUntil(tester, find.text(StringsManager.displayNameUpdated));

      await tapOn(tester, find.text(StringsManager.changePassword));
      await typeInto(tester, StringsManager.currentPasswordHint, testPassword);
      await typeInto(tester, StringsManager.newPasswordHint, _newPassword);
      await typeInto(tester, StringsManager.confirmNewPasswordHint, _newPassword);
      await tapOn(tester, find.text(StringsManager.saveChanges));
      await pumpUntil(tester, find.text(StringsManager.passwordUpdated));

      await logOut(tester);
      await logIn(tester, _newPassword);
      expect(FirebaseAuth.instance.currentUser?.displayName, 'Ada');

      await openTab(tester, StringsManager.profile);
      await openSettings(tester);
      await tapOn(tester, find.text(StringsManager.deleteAccount));
      await tapOn(tester, find.text(StringsManager.deleteAccountContinue));
      await typeInto(tester, StringsManager.passwordHint, _newPassword);
      await tapOn(tester, find.text(StringsManager.deleteAccountConfirmButton));
      await pumpUntil(tester, find.text(StringsManager.deleteAccountSuccess));

      expect(FirebaseAuth.instance.currentUser, isNull);
      final accounts = await emulatorRequest(
        'GET',
        9099,
        '/identitytoolkit.googleapis.com/v1/projects/$projectId/accounts:batchGet',
      );
      expect((jsonDecode(accounts) as Map<String, dynamic>)['users'] ?? const [], isEmpty);
    });
  });
}
