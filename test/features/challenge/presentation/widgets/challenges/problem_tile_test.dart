import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/problem_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';
import '../../../../../helpers/test_data.dart';
import 'challenge_list_harness.dart';

void main() {
  final problem = buildTestProblem(
    problemId: 1,
    name: 'Two Sum',
    problemStatus: ProblemStatus.attempted,
    tags: const ['Array', 'Hash Map'],
  );

  testWidgets('closed, it shows the name but not the details', (tester) async {
    var toggled = 0;
    await pumpListPiece(
      tester,
      ProblemTile(problemId: 1, expanded: false, onToggle: () => toggled++, onSolveTap: () {}),
      problems: [problem],
    );

    expect(find.text('Two Sum'), findsOneWidget);
    expect(find.text(StringsManager.solveWithArrow), findsNothing);

    await tester.tap(find.text('Two Sum'));
    expect(toggled, 1);
  });

  testWidgets('open, it shows tags, status, bookmark and the solve button', (tester) async {
    var solved = 0;
    await pumpListPiece(
      tester,
      ProblemTile(problemId: 1, expanded: true, onToggle: () {}, onSolveTap: () => solved++),
      problems: [problem],
    );

    expect(find.text('Hash Map'), findsOneWidget);
    expect(find.text(StringsManager.attempted), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);

    await tester.tap(find.text(StringsManager.solveWithArrow));
    expect(solved, 1);
  });

  testWidgets('a problem that is not loaded shows nothing', (tester) async {
    await pumpListPiece(tester, ProblemTile(problemId: 9, expanded: true, onToggle: () {}, onSolveTap: () {}));

    expect(find.text(StringsManager.solveWithArrow), findsNothing);
  });

  testWidgets('open with a long name fits a small screen with large text', (tester) async {
    await pumpListPiece(
      tester,
      ProblemTile(problemId: 1, expanded: true, onToggle: () {}, onSolveTap: () {}),
      problems: [
        buildTestProblem(
          problemId: 1,
          name: 'Find the Minimum Number of Operations to Make Every Element of the Array Equal',
          tags: const ['Array', 'Math', 'Greedy', 'Sorting', 'Prefix Sum'],
        ),
      ],
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
