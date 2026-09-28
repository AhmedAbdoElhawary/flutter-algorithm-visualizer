import 'dart:collection';

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/canonical.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/value.dart';
import 'package:flutter_test/flutter_test.dart';

MapEntry<CanonicalValue, CanonicalValue> _entry(String key, int value) => MapEntry(CStr(key), CInt(value));

void main() {
  group('canonical values', () {
    final pairs = <String, (CanonicalValue, CanonicalValue, CanonicalValue)>{
      'int': (const CInt(1), const CInt(1), const CInt(2)),
      'num': (const CNum(1.5), const CNum(1.5), const CNum(2.5)),
      'bool': (const CBool(true), const CBool(true), const CBool(false)),
      'str': (const CStr('a'), const CStr('a'), const CStr('b')),
      'null': (CNull.instance, CNull.instance, const CInt(0)),
      'list': (
        const CList([CInt(1), CInt(2)]),
        const CList([CInt(1), CInt(2)]),
        const CList([CInt(2), CInt(1)]),
      ),
      'map': (
        CMap([_entry('a', 1), _entry('b', 2)]),
        CMap([_entry('b', 2), _entry('a', 1)]),
        CMap([_entry('a', 1), _entry('b', 3)]),
      ),
      'set': (const CSet([CInt(1), CInt(2)]), const CSet([CInt(2), CInt(1)]), const CSet([CInt(1), CInt(3)])),
      'node': (
        const CNode('ListNode', {'val': CInt(1), 'next': CNull.instance}),
        const CNode('ListNode', {'next': CNull.instance, 'val': CInt(1)}),
        const CNode('ListNode', {'val': CInt(2), 'next': CNull.instance}),
      ),
    };
    for (final MapEntry(key: name, value: (a, same, other)) in pairs.entries) {
      test('$name compares by content and hashes the same', () {
        expect(a, same);
        expect(a.hashCode, same.hashCode);
        expect(a, isNot(other));
      });
    }

    test('a map, set or node of a different size or kind differs', () {
      expect(CMap([_entry('a', 1)]), isNot(CMap([_entry('a', 1), _entry('b', 2)])));
      expect(CMap([_entry('a', 1)]), isNot(CMap([_entry('b', 1)])));
      expect(CMap([_entry('a', 1)]), isNot(const CInt(1)));
      expect(const CSet([CInt(1)]), isNot(const CSet([CInt(1), CInt(2)])));
      expect(const CSet([CInt(1)]), isNot(const CList([CInt(1)])));
      expect(const CNode('A', {'x': CInt(1)}), isNot(const CNode('B', {'x': CInt(1)})));
      expect(const CNode('A', {'x': CInt(1)}), isNot(const CNode('A', {'x': CInt(1), 'y': CInt(2)})));
      expect(const CNode('A', {'x': CInt(1)}), isNot(const CNode('A', {'y': CInt(1)})));
      expect(const CNode('A', {}), isNot(const CInt(1)));
    });

    test('toString names the kind and the content', () {
      expect(const CInt(1).toString(), 'CInt(1)');
      expect(const CNum(1.5).toString(), 'CNum(1.5)');
      expect(const CBool(true).toString(), 'CBool(true)');
      expect(const CStr('a').toString(), 'CStr(a)');
      expect(CNull.instance.toString(), 'CNull');
      expect(const CList([CInt(1)]).toString(), 'CList([CInt(1)])');
      expect(CMap([_entry('a', 1)]).toString(), 'CMap([MapEntry(CStr(a): CInt(1))])');
      expect(const CSet([CInt(1)]).toString(), 'CSet([CInt(1)])');
      expect(const CNode('A', {'x': CInt(1)}).toString(), 'CNode(A, {x: CInt(1)})');
    });
  });

  group('normalize', () {
    test('a set keeps its items in any order', () {
      final a = SetValue(LinkedHashSet<Value>.of(<Value>[const IntValue(1), const IntValue(2)]));
      final b = SetValue(LinkedHashSet<Value>.of(<Value>[const IntValue(2), const IntValue(1)]));
      expect(normalize(a), normalize(b));
      expect(normalize(a), isA<CSet>());
    });

    test('an instance becomes a node named after its class', () {
      final node = InstanceValue(ClassValue(name: 'TreeNode'), <String, Value>{'val': const NumValue(3)});
      expect(normalize(node), const CNode('TreeNode', {'val': CInt(3)}));
    });

    test('a function has no answer form, so grading it throws', () {
      final fn = FunctionValue(name: 'f', arity: 0, chunk: Object());
      expect(() => normalize(fn), throwsArgumentError);
    });
  });
}
