import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('addTwoNumbers with null-aware access and custom main', () {
    const userCode = r'''
class ListNode {
  int val;
  ListNode? next;
  ListNode([this.val = 0, this.next]);
}

ListNode? addTwoNumbers(ListNode? l1, ListNode? l2) {
  final dummy = ListNode();
  var current = dummy;
  var carry = 0;
  var first = l1;
  var second = l2;
  while (first != null || second != null || carry != 0) {
    final value1 = first?.val ?? 0;
    final value2 = second?.val ?? 0;
    final sum = value1 + value2 + carry;
    carry = sum ~/ 10;
    final digit = sum % 10;
    current.next = ListNode(digit);
    current = current.next!;
    first = first?.next;
    second = second?.next;
  }
  return dummy.next;
}

void main() {
  final l1 = ListNode(9, ListNode(9, ListNode(9, ListNode(9, ListNode(9, ListNode(9, ListNode(9, null)))))));
  final l2 = ListNode(9, ListNode(9, ListNode(9, ListNode(9, null))));
  final result = addTwoNumbers(l1, l2);
  print(result);
}
''';
    final result = const DartInterpreterRunner().run(userCode);
    expect(result.error, isNull, reason: result.error?.toString());
    expect(result.stdout, hasLength(1));
    expect(result.stdout.single, 'ListNode(val: 8, next: ListNode(...))');
  });
}
