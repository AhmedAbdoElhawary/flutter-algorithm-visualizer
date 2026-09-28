import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each key reads back to its shape', () {
    for (final shape in CustomObjectShape.values) {
      expect(CustomObjectShape.fromKey(shape.key), shape);
    }
  });

  test('no key, or an unknown one, has no shape', () {
    expect(CustomObjectShape.fromKey(null), isNull);
    expect(CustomObjectShape.fromKey('graph'), isNull);
  });

  test('the field names match the LeetCode classes', () {
    const list = CustomObjectShape.linkedList;
    const tree = CustomObjectShape.binaryTree;

    expect((list.valueField, list.nextField), ('val', 'next'));
    expect((tree.valueField, tree.leftField, tree.rightField), ('val', 'left', 'right'));
  });
}
