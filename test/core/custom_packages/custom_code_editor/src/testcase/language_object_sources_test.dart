import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/testcase/language_object_sources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dart needs none, the problem ships its own class', () {
    expect(customObjectSource(EditorLanguage.dart, 'ListNode', CustomObjectShape.linkedList), isNull);
  });

  test('a Python class with defaults for every field', () {
    expect(
      customObjectSource(EditorLanguage.python, 'TreeNode', CustomObjectShape.binaryTree),
      'class TreeNode:\n'
      '    def __init__(self, val=0, left=None, right=None):\n'
      '        self.val = val\n'
      '        self.left = left\n'
      '        self.right = right\n',
    );
  });

  test('a JavaScript class with defaults for every field', () {
    expect(
      customObjectSource(EditorLanguage.javascript, 'ListNode', CustomObjectShape.linkedList),
      'class ListNode {\n'
      '  constructor(val = 0, next = null) {\n'
      '    this.val = val\n'
      '    this.next = next\n'
      '  }\n'
      '}\n',
    );
  });

  test('a graph node starts with no neighbours', () {
    const graph = CustomObjectShape.plainFields;

    expect(customObjectSource(EditorLanguage.python, 'Node', graph), contains('neighbors=None'));
    expect(customObjectSource(EditorLanguage.javascript, 'Node', graph), contains('neighbors = []'));
  });

  test('the classes run on the engine, a list built from one reads back', () {
    for (final language in [EditorLanguage.python, EditorLanguage.javascript]) {
      final result = const ProblemRunner().runAll(
        problem: ProblemData(
          functionSignature: 'ListNode? same(ListNode? head)',
          language: language,
          customObjects: const {'ListNode': CustomObjectShape.linkedList},
          testCases: const [ProblemTestCase(input: 'head=[1,2,3]', expectedOutput: '[1,2,3]')],
        ),
        userCode: language == EditorLanguage.python
            ? 'def same(head):\n    return head\n'
            : 'function same(head) {\n  return head\n}\n',
      );

      expect(result.allPassed, isTrue, reason: '${language.name}: ${result.error}');
    }
  });
}
