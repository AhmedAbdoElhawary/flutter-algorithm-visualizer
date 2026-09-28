import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/challenges_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';
import '../../../../../helpers/test_data.dart';
import 'challenge_list_harness.dart';

void main() {
  final problems = [
    buildTestProblem(problemId: 1, problemStatus: ProblemStatus.solved),
    buildTestProblem(problemId: 2),
    buildTestProblem(problemId: 3),
    buildTestProblem(problemId: 4),
  ];

  double progress(WidgetTester tester) =>
      tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value!;

  testWidgets('shows solved out of total, with a matching bar', (tester) async {
    await pumpListPiece(tester, const ChallengesHeader(), problems: problems);

    expect(find.text(StringsManager.challenges), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(progress(tester), 0.25);
  });

  testWidgets('no problems means an empty bar, not a division by zero', (tester) async {
    await pumpListPiece(tester, const ChallengesHeader());

    expect(find.text('0'), findsNWidgets(2));
    expect(progress(tester), 0);
  });

  testWidgets('the count shrinks beside the title on a small screen with large text', (tester) async {
    await pumpListPiece(tester, const ChallengesHeader(), problems: problems, screen: ScreenSize.smallPhone, textScale: 2);

    expect(find.byType(FittedBox), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
