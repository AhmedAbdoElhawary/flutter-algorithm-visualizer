import 'custom_object_shape.dart';
import 'test_value.dart';

/// Renders a [TestValue] as a Dart source expression the interpreter can
/// evaluate (used for plain-typed arguments like `[2,7,11,15]`).
String testValueToSource(TestValue value) {
  switch (value) {
    case NullTestValue():
      return 'null';
    case IntTestValue(:final value):
      return '$value';
    case DoubleTestValue(:final value):
      return '$value';
    case BoolTestValue(:final value):
      return '$value';
    case StringTestValue(:final value):
      return "'${value.replaceAll("'", r"\'")}'";
    case ListTestValue(:final items):
      return '[${items.map(testValueToSource).join(', ')}]';
  }
}

/// Renders a custom-object argument as a constructor-call source expression.
///
/// For a `linked_list` `ListNode` argument `[1, 2, 4]` this produces
/// `ListNode(1, ListNode(2, ListNode(4)))`, which the interpreter evaluates
/// into a real chain of [ObjectInstance]s at run time.
String buildObjectSource({
  required TestValue value,
  required String className,
  required CustomObjectShape shape,
}) {
  if (value is! ListTestValue) {
    throw FormatException('Custom object input for $className must be a list, got: $value');
  }
  switch (shape) {
    case CustomObjectShape.linkedList:
      return _buildLinkedList(value.items, className, shape);
    case CustomObjectShape.binaryTree:
      return _buildBinaryTree(value.items, className, shape);
    case CustomObjectShape.plainFields:
      return '$className(${value.items.map(testValueToSource).join(', ')})';
  }
}

String _buildLinkedList(
  List<TestValue> items,
  String className,
  CustomObjectShape shape,
) {
  String inner = 'null';
  for (int i = items.length - 1; i >= 0; i--) {
    inner = '$className(${testValueToSource(items[i])}, $inner)';
  }
  return inner;
}

String _buildBinaryTree(
  List<TestValue> items,
  String className,
  CustomObjectShape shape,
) {
  String build(int i) {
    if (i >= items.length) return 'null';
    final value = items[i];
    if (value is NullTestValue) return 'null';
    return '$className(${testValueToSource(value)}, ${build(2 * i + 1)}, ${build(2 * i + 2)})';
  }

  return build(0);
}
