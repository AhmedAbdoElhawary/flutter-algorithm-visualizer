import 'dart:convert';
import 'dart:io';

import 'package:algorithm_visualizer/features/challenge/data/mappers/problem_mapper.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/dataset.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

CodingProblem? _findByName(List<CodingProblem> problems, String name) {
  for (final p in problems) {
    if (p.name == name) return p;
  }
  return null;
}

List<CodingProblem> _loadProblems() {
  final raw = json.decode(File('assets/problems.json').readAsStringSync());
  final adaptiveJson = <String, dynamic>{
    ...(raw['dataset'] as Map<String, dynamic>),
    'problems': raw['problems'],
  };
  final dataset = Dataset.fromJson(adaptiveJson);
  return [
    for (final dto in dataset.problems ?? []) ProblemMapper.toDomain(dto, null),
  ];
}

void main() {
  final problems = _loadProblems();
  const grade = GradeCodeUseCase();

  test('decodes the full problems dataset', () {
    expect(problems.length, 100);
    expect(problems.first.problemId, 1);
    expect(problems.first.number, 1);
  });

  test('problems are ordered by source_problem_number with sequential ids', () {
    for (var i = 0; i < problems.length; i++) {
      expect(problems[i].problemId, i + 1);
      expect(problems[i].number, i + 1);
      if (i > 0) {
        expect(
          problems[i - 1].getSourceProblemNumber <= problems[i].getSourceProblemNumber,
          isTrue,
          reason: '${problems[i - 1].name} before ${problems[i].name}',
        );
      }
    }
    expect(problems.first.getSourceProblemNumber, 1);
  });

  test('every problem has default_code (function in Solution class) and custom_objects', () {
    for (final p in problems) {
      final code = p.getDefaultCode;
      final sig = p.functionSignature?.dart ?? '';
      expect(code, isNotEmpty, reason: p.name);
      final classBased = sig.trimLeft().startsWith('class ');
      expect(
        classBased
            ? code.contains('class ${sig.trimLeft().split(RegExp(r'\s'))[1]}')
            : code.contains('class Solution'),
        isTrue,
        reason: p.name,
      );
      for (final o in p.getCustomObjects) {
        expect(o.getCode, isNotEmpty, reason: p.name);
        expect(['linked_list', 'binary_tree', 'plain_fields'], contains(o.getShape),
            reason: '${p.name}: ${o.getShape}');
      }
    }
  });

  test('custom objects appear in a Definition comment in default_code', () {
    final merge = _findByName(problems, 'Merge Two Sorted Lists')!;
    expect(merge.getDefaultCode, contains('Definition for singly-linked list.'));
    expect(merge.getDefaultCode, contains('class ListNode'));

    final tree = _findByName(problems, 'Same Tree')!;
    expect(tree.getCustomObjects.first.getShape, 'binary_tree');
    expect(tree.getDefaultCode, contains('Definition for a binary tree node.'));

    final clone = _findByName(problems, 'Clone Graph')!;
    expect(clone.getCustomObjects.first.getShape, 'plain_fields');
    expect(clone.getDefaultCode, contains('Definition for a Node.'));
  });

  test('class-based problems keep their class in default_code', () {
    final stack = _findByName(problems, 'Min Stack')!;
    expect(stack.getDefaultCode, contains('class MinStack'));
    expect(stack.getDefaultCode, contains('void push(int val)'));
    expect(stack.getDefaultCode, isNot(contains('class Solution')));
  });

  test('loads default_code and custom_objects metadata', () {
    final twoSum = _findByName(problems, 'Two Sum')!;
    expect(twoSum.getDefaultCode, contains('class Solution'));
    expect(twoSum.getCustomObjects, isEmpty);

    final merge = _findByName(problems, 'Merge Two Sorted Lists')!;
    expect(merge.getCustomObjects.length, 1);
    expect(merge.getCustomObjects.first.getShape, 'linked_list');
    expect(merge.getCustomObjects.first.getCode, contains('class ListNode'));
    expect(merge.getDefaultCode, contains('class Solution'));
    expect(merge.getDefaultCode, contains('class ListNode'));
  });

  test('grades a correct Two Sum solution as fully passed', () {
    final twoSum = _findByName(problems, 'Two Sum')!;
    final result = grade.grade(
      problem: twoSum,
      userCode: '''
List<int> twoSum(List<int> nums, int target) {
  for (int i = 0; i < nums.length; i++) {
    for (int j = i + 1; j < nums.length; j++) {
      if (nums[i] + nums[j] == target) {
        return [i, j];
      }
    }
  }
  return [];
}
''',
    );
    expect(result.error, isNull);
    expect(result.totalCount, greaterThan(0));
    expect(result.allPassed, isTrue, reason: '${result.passedCount}/${result.totalCount}');
  });

  test('grades a wrong Two Sum solution as failed', () {
    final twoSum = _findByName(problems, 'Two Sum')!;
    final result = grade.grade(
      problem: twoSum,
      userCode: 'List<int> twoSum(List<int> nums, int target) { return []; }',
    );
    expect(result.allPassed, isFalse);
    expect(result.passedCount, 0);
  });

  test('grades Merge Two Sorted Lists with custom ListNode objects', () {
    final merge = _findByName(problems, 'Merge Two Sorted Lists')!;
    final result = grade.grade(
      problem: merge,
      userCode: '''
ListNode? mergeTwoLists(ListNode? list1, ListNode? list2) {
  ListNode? head = ListNode();
  ListNode? cur = head;
  while (list1 != null && list2 != null) {
    if (list1.val <= list2.val) {
      cur!.next = list1;
      list1 = list1.next;
    } else {
      cur!.next = list2;
      list2 = list2.next;
    }
    cur = cur.next;
  }
  cur!.next = list1 ?? list2;
  return head.next;
}
''',
    );
    expect(result.error, isNull);
    expect(result.allPassed, isTrue, reason: '${result.passedCount}/${result.totalCount}');
  });
}
