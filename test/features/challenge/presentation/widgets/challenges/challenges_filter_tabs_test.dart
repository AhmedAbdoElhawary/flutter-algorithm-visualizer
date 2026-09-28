import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/view_model/challenges/challenges_providers.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/challenges/challenges_filter_tabs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/pump_app.dart';
import '../../../../../helpers/test_data.dart';
import 'challenge_list_harness.dart';

void main() {
  final problems = [
    buildTestProblem(problemId: 1),
    buildTestProblem(problemId: 2, difficulty: ProblemDifficulty.hard),
    buildTestProblem(problemId: 3, difficulty: ProblemDifficulty.hard),
  ];

  testWidgets('every tab shows its count', (tester) async {
    await pumpListPiece(tester, const ChallengesFilterTabs(), problems: problems);

    for (final (label, count) in [
      (StringsManager.all, '3'),
      (StringsManager.easy, '1'),
      (StringsManager.medium, '0'),
      (StringsManager.hard, '2'),
    ]) {
      expect(find.text(label), findsOneWidget);
      expect(find.text(count), findsWidgets);
    }
  });

  testWidgets('tapping a tab filters by it', (tester) async {
    final piece = await pumpListPiece(tester, const ChallengesFilterTabs(), problems: problems);

    await tester.tap(find.text(StringsManager.hard));
    await tester.pump();

    expect(piece.container.read(challengesProvider).filter, ProblemDifficulty.hard);
  });

  testWidgets('scrolls sideways instead of overflowing on a small screen', (tester) async {
    await pumpListPiece(
      tester,
      const ChallengesFilterTabs(),
      problems: problems,
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
