import 'dart:collection';

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/canonical.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('R3 — presentation differences never fail a correct answer', () {
    test('Python True == Dart true (boolean spelling)', () {
      expect(normalize(const BoolValue(true)), equals(normalize(const BoolValue(true))));
    });

    test('[0, 1] == [0,1] (spacing has no bearing on the value model)', () {
      final a = ListValue(<Value>[const IntValue(0), const IntValue(1)]);
      final b = ListValue(<Value>[const IntValue(0), const IntValue(1)]);
      expect(normalize(a), equals(normalize(b)));
    });

    test('JS 2 (float internally) == Dart 2 (int) — whole-number collapse', () {
      expect(normalize(const NumValue(2.0)), equals(normalize(const IntValue(2))));
    });

    test('Python (0, 1) == [0, 1] — tuple collapses to list', () {
      const tuple = TupleValue(<Value>[IntValue(0), IntValue(1)]);
      final list = ListValue(<Value>[const IntValue(0), const IntValue(1)]);
      expect(normalize(tuple), equals(normalize(list)));
    });

    test('Python None, JS undefined == null — absent value collapses', () {
      expect(normalize(NullValue.instance), equals(CNull.instance));
      expect(normalize(UndefinedValue.instance), equals(CNull.instance));
      expect(normalize(NullValue.instance), equals(normalize(UndefinedValue.instance)));
    });
  });

  group('R4 — real differences always fail', () {
    test('[1,0] != [0,1] — order matters', () {
      final a = ListValue(<Value>[const IntValue(1), const IntValue(0)]);
      final b = ListValue(<Value>[const IntValue(0), const IntValue(1)]);
      expect(normalize(a), isNot(equals(normalize(b))));
    });

    test('[0,1,2] != [0,1] — length matters', () {
      final a = ListValue(<Value>[const IntValue(0), const IntValue(1), const IntValue(2)]);
      final b = ListValue(<Value>[const IntValue(0), const IntValue(1)]);
      expect(normalize(a), isNot(equals(normalize(b))));
    });

    test('"1" != 1 — type matters', () {
      expect(normalize(const StrValue('1')), isNot(equals(normalize(const IntValue(1)))));
    });

    test('2.5 != 2 — not a whole number', () {
      expect(normalize(const NumValue(2.5)), isNot(equals(normalize(const IntValue(2)))));
    });

    test('[[0,1]] != [0,1] — nesting matters', () {
      final nested = ListValue(<Value>[
        ListValue(<Value>[const IntValue(0), const IntValue(1)]),
      ]);
      final flat = ListValue(<Value>[const IntValue(0), const IntValue(1)]);
      expect(normalize(nested), isNot(equals(normalize(flat))));
    });

    test('{a:1} != [1] — structure matters', () {
      final map =
          MapValue(LinkedHashMap<Value, Value>.of(<Value, Value>{const StrValue('a'): const IntValue(1)}));
      final list = ListValue(<Value>[const IntValue(1)]);
      expect(normalize(map), isNot(equals(normalize(list))));
    });
  });
}
