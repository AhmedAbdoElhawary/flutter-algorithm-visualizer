import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/core/custom_packages/custom_code_editor/src/testcase/pilot_solutions.dart';
import '../support/reset.dart';
import '../support/steps.dart';

void solveProblemJourney() {
  group('solve a problem', () {
    testWidgets('a correct solution is saved as solved, on the profile and in Firestore', (tester) async {
      await launchApp(tester);
      await signUp(tester);

      await openTwoSumIn(tester, EditorLanguage.python);
      await runCode(tester, pilotSolutions[twoSumId]![EditorLanguage.python]!);
      await pumpUntil(tester, find.text(StringsManager.solvedMoment), timeout: const Duration(seconds: 30));

      await tapOn(tester, find.text(StringsManager.nextProblem));
      await openTab(tester, StringsManager.profile);
      await pumpUntil(tester, find.text('${StringsManager.problem}\n${StringsManager.solved}'));

      // Progress is saved on the device first, and only reaches Firestore through the sync button.
      await tapOn(tester, find.byIcon(Icons.sync_rounded));
      await pumpUntil(tester, find.text(StringsManager.syncSuccess));

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final saved = await FirebaseFirestore.instance
          .doc('users/$uid/problems/$twoSumId')
          .get(const GetOptions(source: Source.server));
      expect(saved.data()?['problem_status'], 'solved');
    });
  });
}
