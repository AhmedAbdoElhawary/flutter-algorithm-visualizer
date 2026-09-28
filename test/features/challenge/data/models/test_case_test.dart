import 'package:algorithm_visualizer/features/challenge/data/models/test_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TestCase', () {
    test('reads and writes the dataset keys', () {
      final json = <String, dynamic>{'input': '[1,2]', 'expected_output': '3'};

      final testCase = TestCase.fromJson(json);

      expect(testCase, const TestCase(input: '[1,2]', expectedOutput: '3'));
      expect(testCase.toJson(), json);
      expect(testCase.hashCode, const TestCase(input: '[1,2]', expectedOutput: '3').hashCode);
    });

    test('both fields are optional', () {
      expect(TestCase.fromJson(<String, dynamic>{}), const TestCase(input: null, expectedOutput: null));
    });
  });

  group('TestCaseResult', () {
    const passed = TestCaseResult(input: '[1,2]', expectedOutput: '3', actualOutput: '3', passed: true);

    test('round trips, with no error by default', () {
      final json = passed.toJson();

      expect(json['error_message'], isNull);
      expect(TestCaseResult.fromJson(json), passed);
      expect(TestCaseResult.fromJson(json).hashCode, passed.hashCode);
    });

    test('keeps the error of a failed case', () {
      const failed = TestCaseResult(
        input: '[1,2]',
        expectedOutput: '3',
        actualOutput: '',
        passed: false,
        errorMessage: 'RangeError',
      );

      expect(TestCaseResult.fromJson(failed.toJson()), failed);
      expect(failed, isNot(passed));
    });
  });
}
