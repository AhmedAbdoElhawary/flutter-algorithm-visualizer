import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

ObjectInstance _list(List<int> values) {
  ObjectInstance? next;
  for (final value in values.reversed) {
    next = ObjectInstance('ListNode', {'val': value, 'next': next});
  }
  return next!;
}

ObjectInstance _tree(int val, [ObjectInstance? left, ObjectInstance? right]) =>
    ObjectInstance('TreeNode', {'val': val, 'left': left, 'right': right});

void main() {
  group('plain values', () {
    for (final (value, canonical) in [
      (null, 'null'),
      (3, '3'),
      (2.0, '2'),
      (2.5, '2.5'),
      (true, 'true'),
      ('a', '"a"'),
      ([1, [2, null]], '[1,[2,null]]'),
      ({'a': 1}, '{"a":1}'),
      (double.infinity, 'Infinity'),
    ]) {
      test('$value', () => expect(canonicalString(value), canonical));
    }
  });

  test('text never reads the same as the number, bool or null it spells', () {
    expect(canonicalString('1'), isNot(canonicalString(1)));
    expect(canonicalString('true'), isNot(canonicalString(true)));
    expect(canonicalString('null'), isNot(canonicalString(null)));
    expect(canonicalString(['1']), isNot(canonicalString([1])));
  });

  test('a whole double reads the same in every language, a fraction does not round', () {
    expect(canonicalString(4.0), canonicalString(4));
    expect(canonicalString(4.5), isNot(canonicalString(4)));
  });

  group('a linked list', () {
    test('lists its values from the head', () {
      expect(canonicalString(_list([1, 2, 3]), shape: CustomObjectShape.linkedList), '[1,2,3]');
    });

    test('a cycle stops instead of running forever', () {
      final head = _list([1, 2]);
      (head.fields['next']! as ObjectInstance).fields['next'] = head;

      expect(canonicalString(head, shape: CustomObjectShape.linkedList), '[1,2]');
    });
  });

  group('a binary tree, LeetCode level order', () {
    test('trailing nulls are dropped, inner ones kept', () {
      final tree = _tree(1, null, _tree(2, _tree(3)));

      expect(canonicalString(tree, shape: CustomObjectShape.binaryTree), '[1,null,2,3]');
    });

    test('it is the exact inverse of the builder', () {
      // Built by hand from the same level order the builder reads.
      final tree = _tree(1, _tree(2, _tree(4)), _tree(3, null, _tree(5)));

      expect(canonicalString(tree, shape: CustomObjectShape.binaryTree), '[1,2,3,4,null,null,5]');
    });

    test('a node reached twice is visited once', () {
      final shared = _tree(2);
      final tree = _tree(1, shared, shared);

      expect(canonicalString(tree, shape: CustomObjectShape.binaryTree), '[1,2]');
    });
  });

  test('plain fields list each field by name', () {
    final node = ObjectInstance('Node', {'val': 1, 'neighbors': [2, 3]});

    expect(canonicalString(node, shape: CustomObjectShape.plainFields), 'Node{val:1,neighbors:[2,3]}');
  });

  test('with no shape, an object prints its fields', () {
    expect(canonicalString(ObjectInstance('Point', {'x': 1})), 'Point(x: 1)');
  });
}
