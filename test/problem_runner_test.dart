import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/testcase/custom_object_shape.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/testcase/problem_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const runner = ProblemRunner();

  group('ProblemRunner: missing return', () {
    test('an empty body on a non-void function is a whole-program syntax error', () {
      const problem = ProblemData(
        functionSignature: 'List<int> twoSum(List<int> nums, int target)',
        testCases: [
          ProblemTestCase(input: 'nums=[2,7,11,15], target=9', expectedOutput: '[0,1]'),
        ],
      );
      const emptyBody = 'List<int> twoSum(List<int> nums, int target) {\n\n}';

      final result = runner.runAll(problem: problem, userCode: emptyBody);

      expect(result.allPassed, isFalse);
      expect(result.error, isNotNull);
      expect(result.error, contains('syntax error'));
      expect(result.error, contains("return type of 'List<int>'"));
      expect(result.testCaseResults.single.errorMessage, isNotNull);
    });

    test('a nullable return type with an empty body is not flagged', () {
      const problem = ProblemData(
        functionSignature: 'ListNode? mergeTwoLists(ListNode? list1, ListNode? list2)',
        customObjects: {'ListNode': CustomObjectShape.linkedList},
        testCases: [
          ProblemTestCase(input: 'list1=[], list2=[]', expectedOutput: '[]'),
        ],
      );
      const emptyBody = 'ListNode? mergeTwoLists(ListNode? list1, ListNode? list2) {\n\n}';

      final result = runner.runAll(problem: problem, userCode: emptyBody);

      expect(result.error, isNull);
      expect(result.testCaseResults.single.errorMessage, isNull);
    });

    test('reports the signature line inside a class Solution wrapper', () {
      const problem = ProblemData(
        functionSignature: 'List<int> twoSum(List<int> nums, int target)',
        testCases: [
          ProblemTestCase(input: 'nums=[2,7,11,15], target=9', expectedOutput: '[0,1]'),
        ],
      );
      const wrappedEmpty = 'class Solution {\n'
          '  List<int> twoSum(List<int> nums, int target) {\n'
          '\n'
          '\n'
          '  }\n'
          '}';

      final result = runner.runAll(problem: problem, userCode: wrappedEmpty);

      expect(result.allPassed, isFalse);
      expect(result.error, contains('syntax error'));
      expect(result.error, contains('(line 2)'));
    });

    test('accounts for a leading doc comment when rebasing the line', () {
      const problem = ProblemData(
        functionSignature: 'List<int> twoSum(List<int> nums, int target)',
        testCases: [
          ProblemTestCase(input: 'nums=[2,7,11,15], target=9', expectedOutput: '[0,1]'),
        ],
      );
      const docWrappedEmpty = '/**\n'
          ' * @lc app=leetcode id=1 lang=dart\n'
          ' *\n'
          ' * [1] Two Sum\n'
          ' */\n'
          'class Solution {\n'
          '  List<int> twoSum(List<int> nums, int target) {\n'
          '\n'
          '\n'
          '  }\n'
          '}';

      final result = runner.runAll(problem: problem, userCode: docWrappedEmpty);

      expect(result.allPassed, isFalse);
      expect(result.error, contains('syntax error'));
      expect(result.error, contains('(line 7)'));
    });
  });

  group('ProblemRunner: class Solution wrapper', () {
    test('strips the class even when the method compares against brace literals', () {
      const problem = ProblemData(
        functionSignature: 'bool isValid(String s)',
        testCases: [
          ProblemTestCase(input: "s = '()'", expectedOutput: 'true'),
          ProblemTestCase(input: "s = '(]'", expectedOutput: 'false'),
          ProblemTestCase(input: "s = '()[]{}'", expectedOutput: 'true'),
          ProblemTestCase(input: "s = '([)]'", expectedOutput: 'false'),
        ],
      );
      const solution = 'class Solution {\n'
          '\n'
          '  bool isValid(String s) {\n'
          '    final stack = <String>[];\n'
          '    for (final char in s.split(\'\')) {\n'
          "      if (char == '(' || char == '[' || char == '{') {\n"
          '        stack.add(char);\n'
          '      } else {\n'
          '        if (stack.isEmpty) return false;\n'
          '        final last = stack.removeLast();\n'
          "        if (char == ')' && last != '(') return false;\n"
          "        if (char == ']' && last != '[') return false;\n"
          "        if (char == '}' && last != '{') return false;\n"
          '      }\n'
          '    }\n'
          '    return stack.isEmpty;\n'
          '  }\n'
          '}';

      final result = runner.runAll(problem: problem, userCode: solution);

      expect(result.error, isNull);
      expect(result.allPassed, isTrue);
    });
  });

  group('ProblemRunner: null-aware access (?.)', () {
    test('addTwoNumbers with ?.val, ?? and .next! grades correctly', () {
      const problem = ProblemData(
        functionSignature: 'ListNode? addTwoNumbers(ListNode? l1, ListNode? l2)',
        customObjects: {'ListNode': CustomObjectShape.linkedList},
        customObjectSources: [listNodeSource],
        testCases: [
          ProblemTestCase(
            input: 'l1=[9,9,9,9,9,9,9], l2=[9,9,9,9]',
            expectedOutput: '[8,9,9,9,0,0,0,1]',
          ),
        ],
      );
      const solution = 'ListNode? addTwoNumbers(ListNode? l1, ListNode? l2) {\n'
          '  final dummy = ListNode();\n'
          '  var current = dummy;\n'
          '  var carry = 0;\n'
          '  var first = l1;\n'
          '  var second = l2;\n'
          '  while (first != null || second != null || carry != 0) {\n'
          '    final value1 = first?.val ?? 0;\n'
          '    final value2 = second?.val ?? 0;\n'
          '    final sum = value1 + value2 + carry;\n'
          '    carry = sum ~/ 10;\n'
          '    final digit = sum % 10;\n'
          '    current.next = ListNode(digit);\n'
          '    current = current.next!;\n'
          '    first = first?.next;\n'
          '    second = second?.next;\n'
          '  }\n'
          '  return dummy.next;\n'
          '}';

      final result = runner.runAll(problem: problem, userCode: solution);

      expect(result.error, isNull);
      expect(result.allPassed, isTrue);
    });
  });
}

const String listNodeSource = '''
class ListNode {
  int val;
  ListNode? next;
  ListNode([this.val = 0, this.next]);
}
''';
