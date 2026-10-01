import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/tag_chip.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_category_chart.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_data.dart';
import '../profile_test_data.dart';

void main() {
  testWidgets('nothing solved hides the card', (tester) async {
    await pumpProfileWidget(tester, const ProfileSolvedTopics(), list: [buildTestProblem()]);

    expect(find.text(StringsManager.solvedTopics), findsNothing);
  });

  testWidgets('one chip per solved topic, the most solved first', (tester) async {
    await pumpProfileWidget(
      tester,
      const ProfileSolvedTopics(),
      list: [
        buildTestProblem(problemId: 1, category: 'Graphs', problemStatus: ProblemStatus.solved),
        buildTestProblem(problemId: 2, category: 'Arrays', problemStatus: ProblemStatus.solved),
        buildTestProblem(problemId: 3, category: 'Arrays', problemStatus: ProblemStatus.solved),
        buildTestProblem(problemId: 4, category: 'Heaps', problemStatus: ProblemStatus.attempted),
      ],
    );

    expect(tester.widgetList<TagChip>(find.byType(TagChip)).map((chip) => chip.label), ['Arrays  2', 'Graphs  1']);
  });

  testWidgets('many long topics wrap onto new lines on a small screen', (tester) async {
    await pumpProfileWidget(
      tester,
      const ProfileSolvedTopics(),
      list: [
        for (var i = 0; i < 12; i++)
          buildTestProblem(problemId: i, category: 'Dynamic Programming $i', problemStatus: ProblemStatus.solved),
      ],
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    expect(find.byType(TagChip), findsNWidgets(12));
    expect(tester.takeException(), isNull);
  });
}
