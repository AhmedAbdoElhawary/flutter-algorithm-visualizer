import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a run result holds each case and the totals', () {
    const testCase = ProblemTestCase(input: 'a=1', expectedOutput: '1');
    const failure =
        ExecutionFailureInfo(kind: 'runtime', code: 'index_out_of_range', data: {'index': 3}, line: 4);
    const result = ProblemRunResult(
      testCaseResults: [
        SingleTestCaseResult(testCase: testCase, passed: false, actualOutput: '', failure: failure),
      ],
      allPassed: false,
      passedCount: 0,
      totalCount: 1,
      failure: failure,
    );

    expect(result.testCaseResults.single.testCase.expectedOutput, '1');
    expect(result.testCaseResults.single.failure!.line, 4);
    expect(result.failure!.data, {'index': 3});
    expect(result.error, isNull);
  });
}
