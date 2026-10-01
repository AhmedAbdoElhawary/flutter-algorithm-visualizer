import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/auth_text_field.dart';
import 'package:algorithm_visualizer/features/home/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'reset.dart';

const testEmail = 'learner@example.com';
const testPassword = 'first-pass-123';

/// Scrolls [finder] to the middle first: at the edge a pinned header or the bottom bar can cover it.
/// Then waits out short animations, since a button still sliding into place moves away from the tap.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await pumpUntil(tester, finder);
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(finder);
  await tester.pump();
}

/// The last match is on the top page: the page underneath still shows while a new one slides in.
Future<void> typeInto(WidgetTester tester, String hint, String text) async {
  final fields = find.widgetWithText(TextField, hint);
  await pumpUntil(tester, fields);
  final field = fields.last;
  await tapOn(tester, field);
  await tester.enterText(field, text);
  await tester.pump();
}

/// The bottom bar tabs sit on every top-level page.
Future<void> openTab(WidgetTester tester, String tab) => tapOn(tester, find.text(tab).last);

Future<void> skipOnboarding(WidgetTester tester) async {
  await tapOn(tester, find.text(StringsManager.onboardingSkip));
  await pumpUntil(tester, find.byType(HomePage));
}

/// From a fresh launch: the home header's "Sign in" leads to login, which links to sign up.
Future<void> signUp(WidgetTester tester, {String password = testPassword}) async {
  await skipOnboarding(tester);
  await tapOn(tester, find.text(StringsManager.signIn));
  await tapOn(tester, find.text(StringsManager.signUp));
  // The field starts with the guest name, which sign up rejects. Found by label: filled in, it shows no hint.
  final name = find.descendant(
    of: find.widgetWithText(AuthTextField, StringsManager.fullName),
    matching: find.byType(TextField),
  );
  await tapOn(tester, name);
  await tester.enterText(name, 'Sam Learner');
  await typeInto(tester, StringsManager.emailHint, testEmail);
  await typeInto(tester, StringsManager.createStrongPasswordHint, password);
  await typeInto(tester, StringsManager.reEnterPasswordHint, password);
  await tapOn(tester, find.text(StringsManager.createAccount).last);
  await pumpUntil(tester, find.byType(HomePage), timeout: networkTimeout);
}

Future<void> logIn(WidgetTester tester, String password) async {
  await typeInto(tester, StringsManager.emailHint, testEmail);
  await typeInto(tester, StringsManager.passwordHint, password);
  await tapOn(tester, find.text(StringsManager.signIn).last);
  await tester.pump(const Duration(seconds: 1));
  // Only asked when there is guest progress to replace.
  if (find.text(StringsManager.continueToLogin).evaluate().isNotEmpty) {
    await tapOn(tester, find.text(StringsManager.continueToLogin));
  }
  await pumpUntil(tester, find.byType(HomePage), timeout: networkTimeout);
}

Future<void> openSettings(WidgetTester tester) async {
  await tapOn(tester, find.byIcon(Icons.settings_outlined));
  await pumpUntil(tester, find.text(StringsManager.settings));
}

/// From Settings. Logging out lands on the login page.
Future<void> logOut(WidgetTester tester) async {
  await tapOn(tester, find.text(StringsManager.logout).first);
  // The popup's button has the same text, so wait for the popup before taking the last one.
  await pumpUntil(tester, find.text(StringsManager.logoutConfirmTitle));
  await tapOn(tester, find.text(StringsManager.yesLogout).last);
  await pumpUntil(tester, find.text(StringsManager.welcome), timeout: networkTimeout);
}

/// Two Sum is problem 1 in the bundled problem bank.
const twoSumId = 1;
const twoSumName = 'Two Sum';

Future<void> openTwoSumIn(WidgetTester tester, EditorLanguage language) async {
  await openTab(tester, StringsManager.practice);
  await typeInto(tester, StringsManager.searchProblem, twoSumName);
  await hideKeyboard(tester);
  // Scoped to the tile: the search box holds the same text.
  final tile = find.byKey(const ValueKey(twoSumId));
  await tapOn(tester, find.descendant(of: tile, matching: find.text(twoSumName)));
  await tapOn(tester, find.text(StringsManager.solveWithArrow));
  await tapOn(tester, find.text(StringsManager.solveInEditor));
  // The menu opens from the current language's name; every journey starts on Dart.
  await tapOn(tester, find.text(EditorLanguage.dart.displayName));
  await tapOn(tester, find.text(language.displayName).last);
  await tester.pump(const Duration(milliseconds: 500));
}

/// Hides the keyboard first: while it's up, its toolbar replaces the run button.
Future<void> runCode(WidgetTester tester, String code) async {
  await tester.enterText(find.byType(EditableText), code);
  await hideKeyboard(tester);
  await tapOn(tester, find.text(StringsManager.runAndSubmit));
}

Future<void> hideKeyboard(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump(const Duration(milliseconds: 500));
}
