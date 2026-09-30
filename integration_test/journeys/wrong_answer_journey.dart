import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/reset.dart';
import '../support/steps.dart';

/// Right for the first example only, so some cases pass and the rest fail.
const _wrongTwoSum = 'def twoSum(nums, target):\n    return [0, 1]\n';

void wrongAnswerJourney() {
  group('wrong answer', () {
    testWidgets('failing cases are shown, and the problem is not marked solved', (tester) async {
      await launchApp(tester);
      await skipOnboarding(tester);

      await openTwoSumIn(tester, EditorLanguage.python);
      await runCode(tester, _wrongTwoSum);
      await pumpUntil(
        tester,
        find.textContaining(StringsManager.gotPrefix),
        timeout: const Duration(seconds: 30),
      );
      expect(find.text(StringsManager.solvedMoment), findsNothing);

      await openTab(tester, StringsManager.profile);
      await pumpUntil(tester, find.text('${StringsManager.problems}\n${StringsManager.solved}'));
    });
  });
}
