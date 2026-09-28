import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/problem_row.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/secondary_problem_card.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/status_box.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  SecondaryProblemCard card({
    VoidCallback? onTap,
    VoidCallback? onLongTap,
    bool decorated = true,
    List<Widget> bottom = const [],
  }) =>
      SecondaryProblemCard(
        subTitle: const Text('3 submissions'),
        leading: const Icon(Icons.bookmark_rounded),
        onTap: onTap ?? () {},
        onLongTap: onLongTap,
        isSolved: true,
        problemName: 'Two Sum',
        problemId: 1,
        difficulty: ProblemDifficulty.medium,
        bottomWidgets: bottom,
        addCardDecoration: decorated,
      );

  testWidgets('shows the name, the subtitle, the difficulty and whether it is solved', (tester) async {
    await pumpApp(tester, card(bottom: const [Text('extra row')]));

    expect(find.text('Two Sum'), findsOneWidget);
    expect(find.text('3 submissions'), findsOneWidget);
    expect(find.text(StringsManager.medium), findsOneWidget);
    expect(find.text('extra row'), findsOneWidget);
    expect(tester.widget<StatusBox>(find.byType(StatusBox)).isCorrect, isTrue);
  });

  for (final decorated in [true, false]) {
    testWidgets('taps and long presses reach it ${decorated ? 'as a card' : 'as a row'}', (tester) async {
      var taps = 0;
      var longPresses = 0;
      await pumpApp(
        tester,
        Material(child: card(decorated: decorated, onTap: () => taps++, onLongTap: () => longPresses++)),
      );

      await tester.tap(find.text('Two Sum'));
      await tester.longPress(find.text('Two Sum'));

      expect(taps, 1);
      expect(longPresses, 1);
      expect(find.byType(ProblemRow), decorated ? findsOneWidget : findsNothing);
    });
  }

  testWidgets('a long name fits a small screen with large text', (tester) async {
    final longCard = SecondaryProblemCard(
      subTitle: const Text('3 submissions'),
      leading: const Icon(Icons.bookmark_rounded),
      onTap: () {},
      isSolved: false,
      problemName: 'Find the Minimum Number of Operations to Make Every Element Equal',
      problemId: 1,
      difficulty: ProblemDifficulty.hard,
    );
    // In a list, as on the bookmarks and history pages.
    await pumpApp(
      tester,
      ListView(children: [longCard]),
      screen: ScreenSize.smallPhone,
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
