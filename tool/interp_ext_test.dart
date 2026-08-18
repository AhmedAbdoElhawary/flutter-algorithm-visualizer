import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/interpreter.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/lexer.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/parser.dart';
import 'package:flutter/foundation.dart' show debugPrint;

void main() {
  run(
      'ListNode with class + ctor',
      '''
class ListNode {
  int val;
  ListNode? next;
  ListNode([this.val = 0, this.next]);
}
void main() {
  final head = ListNode(1, ListNode(2, ListNode(4)));
  final out = <int>[];
  var cur = head;
  while (cur != null) {
    out.add(cur.val);
    cur = cur.next;
  }
  print(out);
}
''',
      expected: '[1, 2, 4]');

  run(
      'Node reassign next + map',
      '''
class Node {
  int val;
  Node? next;
  Node([this.val = 0, this.next]);
}
void main() {
  final a = Node(1);
  final b = Node(2);
  a.next = b;
  print(a.next!.val);
  final m = {'a': 1, 'b': 2};
  print(m.containsKey('a'));
  print(m['b']);
  m['c'] = 3;
  print(m.length);
}
''',
      expected: '2\ntrue\n2\n3');

  run(
      'empty ctor defaults',
      '''
class Point {
  int x;
  int y;
  Point([this.x = 3, this.y = 4]);
}
void main() {
  final p = Point();
  print(p.x);
  print(p.y);
}
''',
      expected: '3\n4');

  run(
      'list field',
      '''
class Box {
  List<int> items;
  Box(this.items);
}
void main() {
  final b = Box([1,2,3]);
  b.items.add(4);
  print(b.items);
}
''',
      expected: '[1, 2, 3, 4]');

  run(
      'nullable param type parse',
      '''
class TNode {
  int val;
  TNode? left;
  TNode? right;
  TNode([this.val = 0, this.left, this.right]);
}
TNode? build() {
  return TNode(1, TNode(2), null);
}
void main() {
  final t = build();
  print(t!.val);
}
''',
      expected: '1');
}

void run(String name, String source, {required String expected}) {
  try {
    final tokens = Lexer(source).tokenize();
    final program = Parser(tokens).parseProgram();
    final interpreter = Interpreter();
    interpreter.run(program);
    final actual = interpreter.output.join('\n');
    if (actual == expected) {
      debugPrint('PASS: $name');
    } else {
      debugPrint('FAIL: $name\nexpected:\n$expected\nactual:\n$actual');
    }
  } catch (e) {
    debugPrint('ERROR: $name -> $e');
  }
}
