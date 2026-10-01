import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/stat_tile.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:algorithm_visualizer/features/profile/presentation/widgets/profile_stats_grid.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_data.dart';
import '../profile_test_data.dart';

void main() {
  List<StatTile> tiles(WidgetTester tester) => tester.widgetList<StatTile>(find.byType(StatTile)).toList();

  testWidgets('no problems shows zeros, and plural "0 problems"', (tester) async {
    await pumpProfileWidget(tester, const ProfileStatsGrid());

    final [solved, streak, accuracy, bookmarks] = tiles(tester);
    expect(solved.value, '0');
    expect(solved.label, startsWith('${StringsManager.problems}\n'));
    expect(solved.sub, '0E · 0M · 0H');
    expect(streak.value, '0');
    expect(accuracy.value, '0%');
    expect(bookmarks.value, '0');
    expect(bookmarks.sub, '0 ${StringsManager.problems}');
  });

  testWidgets('one of each is singular', (tester) async {
    await pumpProfileWidget(
      tester,
      const ProfileStatsGrid(),
      list: [buildTestProblem(problemStatus: ProblemStatus.solved, isBookmarked: true)],
    );

    final [solved, _, _, bookmarks] = tiles(tester);
    expect(solved.label, startsWith('${StringsManager.problem}\n'));
    expect(bookmarks.sub, '1 ${StringsManager.problem}');
  });

  testWidgets('a full profile adds everything up', (tester) async {
    await pumpProfileWidget(tester, const ProfileStatsGrid(), list: fullProfile());

    final [solved, streak, accuracy, bookmarks] = tiles(tester);
    expect(solved.value, '2');
    expect(solved.sub, '1E · 1M · 0H');
    expect(streak.value, '4');
    expect(streak.sub, contains('4'));
    expect(accuracy.value, '40%');
    expect(bookmarks.value, '2');
    expect(bookmarks.sub, '2 ${StringsManager.problems}');
  });

  testWidgets('fits a small screen with large text', (tester) async {
    await pumpProfileWidget(tester, const ProfileStatsGrid(),
        list: fullProfile(), screen: ScreenSize.smallPhone, textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
