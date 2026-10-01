import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/difficulty_chip.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Color? labelColor(WidgetTester tester, String label) => tester.widget<Text>(find.text(label)).style!.color;
  Color colorOf(WidgetTester tester, ThemeEnum role) => tester.element(find.byType(Text)).getColor(role);

  for (final (difficulty, role) in [
    (ProblemDifficulty.easy, ThemeEnum.dataEasy),
    (ProblemDifficulty.medium, ThemeEnum.dataMedium),
    (ProblemDifficulty.hard, ThemeEnum.dataHard),
  ]) {
    testWidgets('${difficulty.name} reads in its own colour, chip and badge alike', (tester) async {
      await pumpApp(tester, DifficultyChip(difficulty: difficulty, label: difficulty.name));
      expect(labelColor(tester, difficulty.name), colorOf(tester, role));

      await pumpApp(tester, DifficultySquareBadge(difficulty: difficulty, label: 'X'));
      expect(labelColor(tester, 'X'), colorOf(tester, role));
    });
  }

  testWidgets('a badge with no difficulty is neutral', (tester) async {
    await pumpApp(tester, const Center(child: DifficultySquareBadge(difficulty: null, label: '?', size: 30)));

    expect(labelColor(tester, '?'), colorOf(tester, ThemeEnum.inkSecondaryTitle));
    expect(tester.getSize(find.byType(DifficultySquareBadge)), const Size(30, 30));
  });

  testWidgets('a problem with no difficulty blends into the page', (tester) async {
    await pumpApp(tester, const DifficultyChip(difficulty: ProblemDifficulty.none, label: '-'));

    expect(labelColor(tester, '-'), colorOf(tester, ThemeEnum.ground));
  });
}
