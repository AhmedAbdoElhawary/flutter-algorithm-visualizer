import 'dart:convert';

import 'package:algorithm_visualizer/features/challenge/data/models/problem_dto.dart';
import 'package:algorithm_visualizer/features/challenge/domain/enums/problem.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../challenge_test_json.dart';

void main() {
  test('reads every dataset field', () {
    final dto = ProblemDTO.fromJson(fullProblemJson());

    expect(dto.problemId, 7);
    expect(dto.difficulty, ProblemDifficulty.easy);
    expect(dto.functionSignature?.dart, 'ListNode? reverseList(ListNode? head)');
    expect(dto.defaultCode?['python'], startsWith('def'));
    expect(dto.customObjects?['dart']?.map((object) => object.getShape), ['linked_list', '']);
    expect(dto.examples?.single.explanation, 'Each link flips.');
    expect(dto.testCases?.single.expectedOutput, '[3,2,1]');
    expect(dto.hiddenTestCases?.single.input, '[]');
    expect(dto.solutionApproach?.whyItWorks, 'Every link is visited exactly once.');
    expect(dto.similarQuestions?.single.problemId, 8);
    expect(dto.comparison, 'unordered');
  });

  test('writes the same JSON back', () {
    final dto = ProblemDTO.fromJson(fullProblemJson());

    final again = ProblemDTO.fromJson(jsonDecode(jsonEncode(dto.toJson())) as Map<String, dynamic>);

    expect(jsonEncode(again.toJson()), jsonEncode(dto.toJson()));
    expect(again, dto);
    expect(again.hashCode, dto.hashCode);
  });

  test('only the id is needed, every other field may be missing', () {
    final dto = ProblemDTO.fromJson(<String, dynamic>{'problem_id': 1});

    expect(dto.problemId, 1);
    expect(dto.difficulty, isNull);
    expect(dto.functionSignature, isNull);
    expect(dto.defaultCode, isNull);
    expect(dto.testCases, isNull);
  });

  test('a difficulty this version does not know reads as none', () {
    final dto = ProblemDTO.fromJson({...fullProblemJson(), 'difficulty': 'expert'});

    expect(dto.difficulty, isNull);
    expect(dto.name, 'Reverse Linked List');
  });
}
