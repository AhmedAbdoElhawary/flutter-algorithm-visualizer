import '../execution/object_instance.dart';
import 'custom_object_shape.dart';

/// Produces a canonical, whitespace-free string form of a raw interpreted
/// value (an [ObjectInstance], list, map, number, bool, string or `null`).
///
/// The same function is applied to both the actual result and the expected
/// output (via [testValueToRaw]), so grading is an exact string comparison.
String canonicalString(dynamic value, {CustomObjectShape? shape}) {
  if (value == null) return 'null';
  if (value is ObjectInstance) return _instanceToString(value, shape);
  if (value is List) return '[${value.map((e) => canonicalString(e)).join(',')}]';
  if (value is Map) {
    final parts = value.entries.map((e) => '${canonicalString(e.key)}:${canonicalString(e.value)}').join(',');
    return '{$parts}';
  }
  return '$value';
}

String _instanceToString(ObjectInstance instance, CustomObjectShape? shape) {
  final s = shape;
  if (s == null) return instance.toString();
  switch (s) {
    case CustomObjectShape.linkedList:
      final values = <String>[];
      ObjectInstance? current = instance;
      final seen = <ObjectInstance>{};
      while (current != null) {
        if (seen.contains(current)) break; // cycle guard
        seen.add(current);
        values.add(canonicalString(current.fields[s.valueField]));
        final next = current.fields[s.nextField];
        current = next is ObjectInstance ? next : null;
      }
      return '[${values.join(',')}]';
    case CustomObjectShape.binaryTree:
      // Level-order BFS that includes nulls for missing children and
      // strips trailing nulls, matching LeetCode's tree serialization.
      final values = <String>[];
      var queue = <ObjectInstance?>[instance];
      while (queue.any((n) => n != null)) {
        final next = <ObjectInstance?>[];
        for (final node in queue) {
          if (node == null) {
            values.add('null');
            next.add(null);
            next.add(null);
          } else {
            values.add(canonicalString(node.fields[s.valueField]));
            final left = node.fields[s.leftField];
            final right = node.fields[s.rightField];
            next.add(left is ObjectInstance ? left : null);
            next.add(right is ObjectInstance ? right : null);
          }
        }
        queue = next;
      }
      while (values.isNotEmpty && values.last == 'null') {
        values.removeLast();
      }
      return '[${values.join(',')}]';
    case CustomObjectShape.plainFields:
      final fields = instance.fields.entries.map((e) => '${e.key}:${canonicalString(e.value)}').join(',');
      return '${instance.type}{$fields}';
  }
}
