import 'dart:collection';

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/dart/dart_dialect.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/javascript/javascript_dialect.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/python/python_dialect.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/value.dart';
import 'package:flutter_test/flutter_test.dart';

ListValue _list(List<int> items) => ListValue(<Value>[for (final i in items) IntValue(i)]);

TupleValue _tuple(List<int> items) => TupleValue(<Value>[for (final i in items) IntValue(i)]);

MapValue _map(Map<String, int> items) => MapValue(LinkedHashMap<Value, Value>.of(
    <Value, Value>{for (final e in items.entries) StrValue(e.key): IntValue(e.value)}));

SetValue _set(List<int> items) =>
    SetValue(LinkedHashSet<Value>.of(<Value>[for (final i in items) IntValue(i)]));

FunctionValue _fn(String name) => FunctionValue(name: name, arity: 0, chunk: Object());

void main() {
  group('structural values', () {
    final pairs = <String, (Value, Value, Value)>{
      'int': (const IntValue(1), const IntValue(1), const IntValue(2)),
      'num': (const NumValue(1.5), const NumValue(1.5), const NumValue(2.5)),
      'bool': (const BoolValue(true), BoolValue.trueValue, BoolValue.falseValue),
      'str': (const StrValue('a'), const StrValue('a'), const StrValue('b')),
      'null': (NullValue.instance, NullValue.instance, UndefinedValue.instance),
      'undefined': (UndefinedValue.instance, UndefinedValue.instance, NullValue.instance),
      'list': (_list([1, 2]), _list([1, 2]), _list([2, 1])),
      'tuple': (_tuple([1, 2]), _tuple([1, 2]), _tuple([1])),
      'map': (_map({'a': 1, 'b': 2}), _map({'b': 2, 'a': 1}), _map({'a': 2, 'b': 2})),
      'set': (_set([1, 2]), _set([2, 1]), _set([1, 3])),
    };
    for (final MapEntry(key: name, value: (a, same, other)) in pairs.entries) {
      test('$name compares by content and hashes the same', () {
        expect(a, same);
        expect(a.hashCode, same.hashCode);
        expect(a, isNot(other));
      });
    }

    test('a list never equals a tuple with the same items', () {
      expect(_list([1]), isNot(_tuple([1])));
    });

    test('maps and sets of different sizes differ', () {
      expect(_map({'a': 1}), isNot(_map({'a': 1, 'b': 2})));
      expect(_map({'a': 1}), isNot(_map({'b': 1})));
      expect(_set([1]), isNot(_set([1, 2])));
    });

    test('toString names the kind and the content', () {
      expect(const IntValue(3).toString(), 'IntValue(3)');
      expect(const NumValue(1.5).toString(), 'NumValue(1.5)');
      expect(BoolValue.trueValue.toString(), 'BoolValue(true)');
      expect(const StrValue('hi').toString(), 'StrValue(hi)');
      expect(NullValue.instance.toString(), 'NullValue');
      expect(UndefinedValue.instance.toString(), 'UndefinedValue');
      expect(_list([1]).toString(), 'ListValue([IntValue(1)])');
      expect(_tuple([1]).toString(), 'TupleValue([IntValue(1)])');
      expect(_map({'a': 1}).toString(), 'MapValue({StrValue(a): IntValue(1)})');
      expect(_set([1]).toString(), 'SetValue({IntValue(1)})');
    });

    test('a long string is cut in toString so logs stay readable', () {
      expect(StrValue('x' * 50).toString(), 'StrValue(${'x' * 40}...)');
    });
  });

  group('identity values', () {
    final klass = ClassValue(name: 'Node');
    final values = <Value>[
      _fn('f'),
      klass,
      InstanceValue(klass),
      NativeFunctionValue('min', -1, (args, invoke) => NullValue.instance),
      IntrinsicMethod(_list([]), 'map'),
      const NamespaceValue('Math', <String, Value>{}),
    ];

    test('each one equals only itself', () {
      for (final value in values) {
        expect(value, value);
        expect(value.hashCode, value.hashCode);
      }
      expect(_fn('f'), isNot(_fn('f')));
      expect(InstanceValue(klass), isNot(InstanceValue(klass)));
    });

    test('toString names the kind', () {
      expect(values.map((v) => v.toString()), [
        'FunctionValue(f/0)',
        'ClassValue(Node)',
        'InstanceValue(Node, {})',
        'NativeFunctionValue(min)',
        'IntrinsicMethod(map on ListValue([]))',
        'NamespaceValue(Math)',
      ]);
    });
  });

  test('errors with the same code are equal whatever their data', () {
    const a = ErrorValue(code: 'indexOutOfRange', data: <String, Object?>{'index': 1});
    const b = ErrorValue(code: 'indexOutOfRange');
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const ErrorValue(code: 'divisionByZero')));
    expect(a.toString(), 'ErrorValue(indexOutOfRange, {index: 1})');
  });

  test('a default map inserts the missing key it was asked for', () {
    final counts = DefaultMapValue(() => const IntValue(0));
    expect(counts.readOrCreate(const StrValue('a')), const IntValue(0));
    expect(counts.entries.length, 1);
    counts.entries[const StrValue('a')] = const IntValue(5);
    expect(counts.readOrCreate(const StrValue('a')), const IntValue(5));
  });

  test('a method is found on the superclass and a bound method keeps its class', () {
    final speak = _fn('speak');
    final animal = ClassValue(name: 'Animal', methods: <String, FunctionValue>{'speak': speak});
    final dog = ClassValue(name: 'Dog', superclass: animal);
    speak.homeClass = animal;
    expect(dog.findMethod('speak'), same(speak));
    expect(dog.findMethod('fly'), isNull);

    final rex = InstanceValue(dog);
    final bound = speak.bindTo(rex);
    expect(bound.boundThis, same(rex));
    expect(bound.homeClass, same(animal));
  });

  group('isTruthy', () {
    test('dart only accepts a real bool', () {
      expect(isTruthy(BoolValue.trueValue, dartDialect), isTrue);
      expect(isTruthy(const IntValue(1), dartDialect), isFalse);
    });

    test('python treats zero and empty things as false', () {
      final falsy = <Value>[
        BoolValue.falseValue, NullValue.instance, const IntValue(0), const NumValue(0),
        const StrValue(''), _list([]), _tuple([]), _map({}), _set([]),
      ];
      for (final value in falsy) {
        expect(isTruthy(value, pythonDialect), isFalse, reason: '$value');
      }
      final truthy = <Value>[
        const NumValue(0.5), const StrValue('a'), _tuple([0]), _map({'a': 0}), _set([0]),
      ];
      for (final value in truthy) {
        expect(isTruthy(value, pythonDialect), isTrue, reason: '$value');
      }
      expect(isTruthy(_fn('f'), pythonDialect), isTrue);
    });

    test('javascript treats empty arrays as true and NaN as false', () {
      expect(isTruthy(_list([]), javascriptDialect), isTrue);
      expect(isTruthy(const NumValue(double.nan), javascriptDialect), isFalse);
      expect(isTruthy(UndefinedValue.instance, javascriptDialect), isFalse);
      expect(isTruthy(const StrValue(''), javascriptDialect), isFalse);
      expect(isTruthy(const IntValue(0), javascriptDialect), isFalse);
    });
  });

  group('compareValues', () {
    test('numbers of either kind and bools compare by value', () {
      expect(compareValues(const IntValue(2), const NumValue(1.5), dartDialect), 1);
      expect(compareValues(BoolValue.falseValue, BoolValue.trueValue, dartDialect), -1);
    });

    test('python orders tuples item by item, a prefix first', () {
      expect(compareValues(_tuple([1, 5]), _tuple([2, 0]), pythonDialect), -1);
      expect(compareValues(_tuple([1, 2]), _tuple([1, 2, 0]), pythonDialect), -1);
      expect(compareValues(_list([3]), _list([3]), pythonDialect), 0);
    });

    test('javascript falls back to comparing the printed text', () {
      expect(compareValues(_list([10]), _list([9]), javascriptDialect), isNegative);
      expect(compareValues(NullValue.instance, const StrValue('a'), javascriptDialect), isPositive);
    });

    test('values that cannot be ordered throw a type mismatch', () {
      expect(
        () => compareValues(const StrValue('a'), const IntValue(1), dartDialect),
        throwsA(isA<VmRuntimeError>().having((e) => e.code, 'code', 'typeMismatch')),
      );
    });
  });

  group('displayString', () {
    test('each language spells bools and null its own way', () {
      expect(displayString(BoolValue.trueValue, pythonDialect), 'True');
      expect(displayString(BoolValue.falseValue, pythonDialect), 'False');
      expect(displayString(NullValue.instance, pythonDialect), 'None');
      expect(displayString(UndefinedValue.instance, javascriptDialect), 'undefined');
    });

    test('a whole float prints whole only in javascript', () {
      expect(displayString(const NumValue(2), javascriptDialect), '2');
      expect(displayString(const NumValue(2), dartDialect), '2.0');
      expect(displayString(const NumValue(2.5), javascriptDialect), '2.5');
    });

    test('collections and instances print like the language does', () {
      expect(displayString(_tuple([1, 2]), pythonDialect), '(1, 2)');
      expect(displayString(_set([1, 2]), dartDialect), '{1, 2}');
      expect(displayString(_map({'a': 1}), dartDialect), '{a: 1}');
      expect(displayString(InstanceValue(ClassValue(name: 'Node')), dartDialect), "Instance of 'Node'");
      expect(displayString(_fn('f'), dartDialect), 'FunctionValue(f/0)');
    });
  });
}
