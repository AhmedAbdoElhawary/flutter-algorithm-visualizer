import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prints its type and fields, nested objects by type only', () {
    final inner = ObjectInstance('ListNode', {'val': 2, 'next': null});
    final outer = ObjectInstance('ListNode', {'val': 1, 'next': inner, 'tags': ['a', 'b'], 'meta': {'k': 1}});

    expect(outer.toString(), 'ListNode(val: 1, next: ListNode(...), tags: [a, b], meta: {k: 1})');
  });

  test('very deep lists stop printing instead of running on', () {
    dynamic deep = 0;
    for (var i = 0; i < 10; i++) {
      deep = [deep];
    }

    expect(ObjectInstance('Box', {'v': deep}).toString(), contains('...'));
  });
}
