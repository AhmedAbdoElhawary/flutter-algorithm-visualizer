import 'package:algorithm_visualizer/bootstrap.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/core/flavor/flavor_config.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/core/custom_packages/custom_code_editor/src/testcase/pilot_solutions.dart';
import 'support/reset.dart';
import 'support/steps.dart';

/// Run through `tool/integration_test.sh`, with the device in airplane mode.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => prepareApp(FlavorConfig.fromEnvironment()));
  setUp(resetDevice);

  testWidgets('offline, the visualizers and local grading work, and login fails with a message', (
    tester,
  ) async {
    await launchApp(tester);
    await skipOnboarding(tester);

    await openTab(tester, StringsManager.visual);
    await tapOn(tester, find.text('3×'));
    await tapOn(tester, find.byKey(AlgorithmControls.playKey));
    await pumpUntil(tester, find.text(StringsManager.arrayFullySorted), timeout: const Duration(minutes: 1));

    await openTwoSumIn(tester, EditorLanguage.python);
    await runCode(tester, pilotSolutions[twoSumId]![EditorLanguage.python]!);
    await pumpUntil(tester, find.text(StringsManager.solvedMoment), timeout: const Duration(seconds: 30));

    await tapOn(tester, find.text(StringsManager.nextProblem));
    await openTab(tester, StringsManager.home);
    await tapOn(tester, find.text(StringsManager.signIn));
    await typeInto(tester, StringsManager.emailHint, testEmail);
    await typeInto(tester, StringsManager.passwordHint, testPassword);
    await tapOn(tester, find.text(StringsManager.signIn).last);
    await tester.pump(const Duration(seconds: 1));
    if (find.text(StringsManager.continueToLogin).evaluate().isNotEmpty) {
      await tapOn(tester, find.text(StringsManager.continueToLogin));
    }
    // The Auth emulator reports "can't connect" as an internal error, not the network error real Firebase
    // gives, so the exact message is checked in login_page_test.dart instead. Here: it fails, and says so.
    await pumpUntil(tester, find.byType(SnackBar), timeout: const Duration(seconds: 30));
    expect(find.text(StringsManager.welcome), findsOneWidget);
    expect(FirebaseAuth.instance.currentUser, isNull);
  });
}
