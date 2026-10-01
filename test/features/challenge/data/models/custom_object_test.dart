import 'package:algorithm_visualizer/features/challenge/data/models/custom_object.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the object form keeps its code and shape, and round trips', () {
    final object = CustomObject.fromJson(<String, dynamic>{'code': 'class ListNode {}', 'shape': 'linked_list'});

    expect(object.getCode, 'class ListNode {}');
    expect(object.getShape, 'linked_list');
    expect(object.toJson(), {'code': 'class ListNode {}', 'shape': 'linked_list'});
  });

  test('the older plain-string form is just the code', () {
    final object = CustomObject.fromJson('class TreeNode {}');

    expect(object.getCode, 'class TreeNode {}');
    expect(object.getShape, '');
    expect(object.toJson(), {'code': 'class TreeNode {}'});
  });

  for (final (label, json) in [('a number', 42), ('null', null), ('a list', <Object>[])]) {
    test('$label reads as an empty object instead of crashing', () {
      final object = CustomObject.fromJson(json);

      expect(object.getCode, '');
      expect(object.getShape, '');
      expect(object.toJson(), isEmpty);
    });
  }
}
