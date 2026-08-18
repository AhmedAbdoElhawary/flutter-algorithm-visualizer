import 'dart:convert';
import 'dart:io';

import 'package:algorithm_visualizer/features/challange/data/mappers/problem_mapper.dart';
import 'package:algorithm_visualizer/features/challange/data/models/dataset.dart';
import 'package:algorithm_visualizer/features/challange/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challange/domain/usecases/grade_code_usecase.dart';
import 'package:flutter/foundation.dart' show debugPrint;
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

void main() {
  final problems = _load();
  const grade = GradeCodeUseCase();

  test('Merge Two Sorted Lists seeded default code (filled in) grades correctly', () {
    final p = _byName(problems, 'Merge Two Sorted Lists');
    final seeded = p.getDefaultCode;
    final filled = seeded.replaceAll(
      '  ListNode? mergeTwoLists(ListNode? list1, ListNode? list2) {\n\n\n  }',
      '  ListNode? mergeTwoLists(ListNode? list1, ListNode? list2) {\n'
      '    if (list1 == null) return list2;\n'
      '    if (list2 == null) return list1;\n'
      '    if (list1.val <= list2.val) {\n'
      '      list1.next = mergeTwoLists(list1.next, list2);\n'
      '      return list1;\n'
      '    } else {\n'
      '      list2.next = mergeTwoLists(list1, list2.next);\n'
      '      return list2;\n'
      '    }\n'
      '  }',
    );
    final result = grade.grade(problem: p, userCode: filled);
    debugPrint('filled-seeded result: error=${result.error} passed=${result.passedCount}/${result.totalCount}');
    expect(result.allPassed, isTrue,
        reason: 'error=${result.error} ${result.passedCount}/${result.totalCount}');
  });

  test('Two Sum seeded default code (filled in) grades correctly', () {
    final p = _byName(problems, 'Two Sum');
    final seeded = p.getDefaultCode;
    final filled = seeded.replaceAll(
      'class Solution {\n  List<int> twoSum(List<int> nums, int target) {\n\n\n  }\n}',
      'class Solution {\n  List<int> twoSum(List<int> nums, int target) {\n'
      '    for (int i = 0; i < nums.length; i++) {\n'
      '      for (int j = i + 1; j < nums.length; j++) {\n'
      '        if (nums[i] + nums[j] == target) return [i, j];\n'
      '      }\n'
      '    }\n'
      '    return [];\n'
      '  }\n}',
    );
    final result = grade.grade(problem: p, userCode: filled);
    debugPrint('filled-seeded problem1: error=${result.error} passed=${result.passedCount}/${result.totalCount}');
    expect(result.allPassed, isTrue,
        reason: 'error=${result.error} ${result.passedCount}/${result.totalCount}');
  });
}
