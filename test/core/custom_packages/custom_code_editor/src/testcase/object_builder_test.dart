import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String build(String input, CustomObjectShape shape, [String className = 'Node']) =>
      buildObjectSource(value: parseValue(input), className: className, shape: shape);

  group('values as Dart source', () {
    for (final (input, source) in [
      ('null', 'null'),
      ('3', '3'),
      ('2.5', '2.5'),
      ('true', 'true'),
      ('"it\'s"', r"'it\'s'"),
      ('[1, "a"]', "[1, 'a']"),
    ]) {
      test(input, () => expect(testValueToSource(parseValue(input)), source));
    }
  });

  test('a linked list chains from the front', () {
    expect(build('[1, 2]', CustomObjectShape.linkedList, 'ListNode'), 'ListNode(1, ListNode(2, null))');
    expect(build('[]', CustomObjectShape.linkedList), 'null');
  });

  group('a binary tree, LeetCode level order', () {
    test('a full tree', () {
      expect(
        build('[1, 2, 3]', CustomObjectShape.binaryTree),
        'Node(1, Node(2, null, null), Node(3, null, null))',
      );
    });

    test('a null claims no children of its own', () {
      expect(
        build('[1, null, 2, 3]', CustomObjectShape.binaryTree),
        'Node(1, null, Node(2, Node(3, null, null), null))',
      );
    });

    test('an empty list, or a null root, is no tree', () {
      expect(build('[]', CustomObjectShape.binaryTree), 'null');
      expect(build('[null]', CustomObjectShape.binaryTree), 'null');
    });
  });

  test('plain fields go in order', () {
    expect(build('[1, [2, 3]]', CustomObjectShape.plainFields), 'Node(1, [2, 3])');
  });

  test('an input that is not a list is refused, never guessed', () {
    expect(() => build('5', CustomObjectShape.linkedList), throwsFormatException);
  });
}
