import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart' show EditorLanguage;
import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:algorithm_visualizer/features/challenge/domain/entities/coding_problem.dart';
import 'package:algorithm_visualizer/features/challenge/domain/usecases/grade_code_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_data.dart';
import '../../dataset_problem.dart';

const _twoSum = '''
List<int> twoSum(List<int> nums, int target) {
  for (var i = 0; i < nums.length; i++) {
    for (var j = i + 1; j < nums.length; j++) {
      if (nums[i] + nums[j] == target) return [i, j];
    }
  }
  return [];
}
''';

const _mergeTwoLists = '''
ListNode? mergeTwoLists(ListNode? list1, ListNode? list2) {
  final dummy = ListNode(0);
  var tail = dummy;
  var a = list1;
  var b = list2;
  while (a != null && b != null) {
    if (a.val <= b.val) {
      tail.next = a;
      a = a.next;
    } else {
      tail.next = b;
      b = b.next;
    }
    tail = tail.next!;
  }
  tail.next = a ?? b;
  return dummy.next;
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const grader = GradeCodeUseCase();
  late CodingProblem twoSum;

  setUpAll(() async => twoSum = await datasetProblem(1));

  test('a correct answer passes every visible and hidden case', () {
    final result = grader.grade(problem: twoSum, userCode: _twoSum);

    expect(result.totalCount, twoSum.getTestCases.length + twoSum.getHiddenTestCases.length);
    expect(result.passedCount, result.totalCount);
    expect(result.failedCount, 0);
    expect(result.error, isNull);
    expect(result.allPassed, isTrue);
    expect(result.code, _twoSum);
    expect(result.language, EditorLanguage.dart);
    expect(result.firstThreeTestCaseResults, hasLength(3));
  });

  test('a wrong answer fails, and the short list shows the failures first', () {
    const oneRight = '''
List<int> twoSum(List<int> nums, int target) {
  return nums.length == 2 ? [0, 1] : [];
}
''';

    final result = grader.grade(problem: twoSum, userCode: oneRight);

    expect(result.allPassed, isFalse);
    expect(result.failedCount, greaterThan(0));
    final shown = result.firstThreeTestCaseResults;
    expect(shown, hasLength(3));
    final firstPass = shown.indexWhere((r) => r.passed);
    expect(firstPass == -1 || shown.skip(firstPass).every((r) => r.passed), isTrue, reason: 'failures come first');
  });

  test('code that does not compile fails every case with one error', () {
    final result = grader.grade(problem: twoSum, userCode: 'List<int> twoSum(');

    expect(result.error, isNotNull);
    expect(result.allPassed, isFalse);
  });

  test('empty code does not pass', () {
    final result = grader.grade(problem: twoSum, userCode: '');

    expect(result.allPassed, isFalse);
  });

  test('custom objects from the dataset are built for the answer', () async {
    final merge = await datasetProblem(10);

    final result = grader.grade(problem: merge, userCode: _mergeTwoLists);

    expect(result.allPassed, isTrue, reason: '${result.error ?? result.firstThreeTestCaseResults}');
  });

  test('the language is passed through to the result', () {
    const python = '''
def twoSum(nums, target):
    for i in range(len(nums)):
        for j in range(i + 1, len(nums)):
            if nums[i] + nums[j] == target:
                return [i, j]
    return []
''';

    final result = grader.grade(problem: twoSum, userCode: python, language: EditorLanguage.python);

    expect(result.language, EditorLanguage.python);
    expect(result.allPassed, isTrue, reason: '${result.error ?? result.firstThreeTestCaseResults}');
  });

  test('a problem with no test cases grades as nothing passed', () {
    final result = grader.grade(problem: buildTestProblem(), userCode: _twoSum);

    expect(result.totalCount, 0);
    expect(result.allTestCaseResults, isEmpty);
    expect(result.allPassed, isFalse);
  });

  group('CodeGradeResult', () {
    TestCaseResult caseResult(bool passed) =>
        TestCaseResult(input: '', expectedOutput: '', actualOutput: '', passed: passed);

    test('a failure with fewer than three failures fills up with passes', () {
      final result = CodeGradeResult(
        allTestCaseResults: [caseResult(true), caseResult(false), caseResult(true), caseResult(true)],
        totalCount: 4,
        code: '',
      );

      expect(result.firstThreeTestCaseResults.map((r) => r.passed), [false, true, true]);
    });

    test('an error fails the run even if every case passed', () {
      final result = CodeGradeResult(allTestCaseResults: [caseResult(true)], totalCount: 1, code: '', error: 'boom');

      expect(result.allPassed, isFalse);
    });
  });
}
