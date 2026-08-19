import 'dart:convert';
import 'dart:io';

import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/features/challenge/data/mappers/problem_mapper.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/dataset.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/presentation/widgets/code_editor/code_problem_description_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

List<CodingProblem> _load() {
  final raw = json.decode(File('assets/problems.json').readAsStringSync());
  final adaptive = <String, dynamic>{
    ...(raw['dataset'] as Map<String, dynamic>),
    'problems': raw['problems'],
  };
  final ds = Dataset.fromJson(adaptive);
  return [for (final d in ds.problems ?? []) ProblemMapper.toDomain(d, null)];
}

CodingProblem _byName(List<CodingProblem> problems, String name) =>
    problems.firstWhere((e) => e.name == name);

Future<void> _pumpCard(WidgetTester tester, CodingProblem problem) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [CodeProblemDescriptionCard(problem: problem)],
            ),
          ),
        );
      },
    ),
  );
}

void main() {
  final problems = _load();

  testWidgets('renders title, difficulty, description, example, constraints and tags', (tester) async {
    final twoSum = _byName(problems, 'Two Sum');
    await _pumpCard(tester, twoSum);

    expect(find.text('Two Sum'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('DESCRIPTION'), findsOneWidget);
    expect(find.textContaining('array of integers'), findsOneWidget);
    expect(find.text('Example 1'.toUpperCase()), findsOneWidget);
    expect(find.text('Input:'), findsNWidgets(3));
    expect(find.text('nums = [2,7,11,15], target = 9'), findsOneWidget);
    expect(find.text('Output:'), findsNWidgets(3));
    expect(find.text('[0,1]'), findsWidgets);
    expect(find.textContaining('nums[0] + nums[1]'), findsOneWidget);
    expect(find.text('CONSTRAINTS'), findsOneWidget);
    expect(find.text('2 <= nums.length <= 10^4'), findsOneWidget);
    expect(find.text('TAGS'), findsOneWidget);
    expect(find.text('Array'), findsOneWidget);
    expect(find.text('Hash Map'), findsOneWidget);
  });

  testWidgets('shows difficulty-specific badge colors', (tester) async {
    final problems = _load();
    final easy = _byName(problems, 'Two Sum');
    final medium = _byName(problems, 'Group Anagrams');
    final hard = _byName(problems, 'Merge k Sorted Lists');

    for (final (p, label, color) in [
      (easy, 'Easy', ThemeEnum.accentGreen),
      (medium, 'Medium', ThemeEnum.accentYellow),
      (hard, 'Hard', ThemeEnum.accentRed),
    ]) {
      await _pumpCard(tester, p);
      expect(find.text(label), findsOneWidget);
      final text = tester.widget<Text>(find.text(label));
      final ctx = tester.element(find.byType(CodeProblemDescriptionCard));
      expect(text.style?.color, ctx.getColor(color));
    }
  });

  testWidgets('renders multiple examples with Explanation blocks', (tester) async {
    final hard = _byName(problems, 'Merge k Sorted Lists');
    await _pumpCard(tester, hard);

    expect(find.text('DESCRIPTION'), findsOneWidget);
    expect(find.textContaining('sorted linked'), findsWidgets);
    final examples = hard.getExamples;
    expect(examples.length, greaterThanOrEqualTo(2));
    for (var i = 0; i < examples.length; i++) {
      expect(find.text('Example ${i + 1}'.toUpperCase()), findsOneWidget);
    }
  });
}
