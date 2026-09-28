import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/history_row.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_practice_history.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_data.dart';
import '../profile_test_data.dart';

void main() {
  testWidgets('no practice hides the card', (tester) async {
    await pumpProfileWidget(tester, const ProfilePracticeHistory(), list: [buildTestProblem()]);

    expect(find.text(StringsManager.practiceHistory), findsNothing);
  });

  testWidgets('shows a preview of at most three problems, without the attempt bars', (tester) async {
    await pumpProfileWidget(
      tester,
      const ProfilePracticeHistory(),
      list: [
        for (var i = 1; i <= 5; i++) buildTestProblem(problemId: i, name: 'Problem $i', solutions: [attempt(passed: true, daysAgo: i)]),
      ],
    );

    final rows = tester.widgetList<HistoryRow>(find.byType(HistoryRow));
    expect(rows.map((row) => row.entry.problemName), ['Problem 1', 'Problem 2', 'Problem 3']);
    expect(rows.every((row) => !row.addAttemptsCharts && !row.addCardDecoration), isTrue);
    expect(find.text(StringsManager.viewAll), findsOneWidget);
  });

  testWidgets('fits a small screen with large text and a long name', (tester) async {
    await pumpProfileWidget(tester, const ProfilePracticeHistory(),
        list: fullProfile(), screen: ScreenSize.smallPhone, textScale: 2);

    expect(find.text(longProblemName), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
