import 'dart:collection';

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/worker.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/value.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/budget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../frontend/python/python_support.dart' show plain;

void main() {
  group('values cross the isolate boundary unchanged', () {
    for (final value in <Value>[
      const IntValue(3),
      const NumValue(2.5),
      const BoolValue(true),
      const StrValue('a'),
      NullValue.instance,
      UndefinedValue.instance,
      ListValue([const IntValue(1), const StrValue('b')]),
      const TupleValue([IntValue(1)]),
      SetValue(LinkedHashSet<Value>.of([const IntValue(1)])),
      MapValue()..entries[const StrValue('k')] = const IntValue(1),
    ]) {
      test(value.runtimeType.toString(), () {
        expect(plain(decodeValue(encodeValue(value))), plain(value));
      });
    }

    test('an instance keeps its class name and fields', () {
      final node = InstanceValue(ClassValue(name: 'ListNode'), <String, Value>{'val': const IntValue(1)});

      final back = decodeValue(encodeValue(node)) as InstanceValue;

      expect(back.klass.name, 'ListNode');
      expect(back.fields, <String, Value>{'val': const IntValue(1)});
    });

    test('no value at all reads back as null', () {
      expect(decodeValue(null), NullValue.instance);
    });

    test('something that cannot be sent is refused, never guessed', () {
      expect(() => decodeValue(<String, Object?>{'k': 'closure'}), throwsArgumentError);
    });
  });

  test('a budget survives the trip, every limit', () {
    const budget = ExecutionBudget(
      perTestCaseTimeout: Duration(seconds: 3),
      maxFrameDepth: 77,
      instructionsPerBudgetCheck: 500,
    );

    final encoded = encodeBudget(budget);

    expect(encoded['perTestCaseTimeoutUs'], 3000000);
    expect(encoded['maxFrameDepth'], 77);
    expect(encoded['instructionsPerBudgetCheck'], 500);
  });

  group('a request run straight through the worker code', () {
    Map<String, Object?> request(String source, {String functionName = 'main', String language = 'dart'}) =>
        <String, Object?>{
          'language': language,
          'source': source,
          'functionName': functionName,
          'arguments': <Object?>[],
          'preludeSources': <Object?>[],
          'budget': encodeBudget(const ExecutionBudget()),
        };

    test('the built-in stub returns its constant', () {
      final result = executeEncodedRequest(request(stubReturnConstantSource), () => false);

      expect(decodeValue(result['returned']), isA<IntValue>());
      expect(result['failure'], isNull);
    });

    test('a real Dart function runs through its frontend', () {
      final result = executeEncodedRequest(request('int f() => 7;', functionName: 'f'), () => false);

      expect(plain(decodeValue(result['returned'])), 7);
    });

    test('python and javascript run too, with their own builtins', () {
      final python = request('def f():\n    return len([1, 2])\n', functionName: 'f', language: 'python');
      const source = 'function f() { return Math.max(1, 5) }';
      final javascript = request(source, functionName: 'f', language: 'javascript');

      expect(plain(decodeValue(executeEncodedRequest(python, () => false)['returned'])), 2);
      expect(plain(decodeValue(executeEncodedRequest(javascript, () => false)['returned'])), 5);
    });

    test('a syntax error is reported, not thrown', () {
      final result = executeEncodedRequest(request('int f() { return 1 }', functionName: 'f'), () => false);

      expect((result['failure']! as Map)['kind'], 'syntax');
    });

    test('cancelled before it starts, the stub loop stops at once', () {
      final result = executeEncodedRequest(request(stubInfiniteLoopSource), () => true);

      expect((result['failure']! as Map)['kind'], 'cancelled');
    });
  });
}
