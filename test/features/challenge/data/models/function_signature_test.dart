import 'package:algorithm_visualizer/features/challenge/data/models/function_signature.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads every field and writes the same JSON back', () {
    final json = <String, dynamic>{'generic': 'f(x)', 'dart': 'int f(int x)'};

    final model = FunctionSignature.fromJson(json);

    expect(model, const FunctionSignature(generic: 'f(x)', dart: 'int f(int x)'));
    expect(model.toJson(), json);
  });

  test('every field is optional', () {
    expect(FunctionSignature.fromJson(<String, dynamic>{}), const FunctionSignature(generic: null, dart: null));
  });

  test('equal fields mean equal and the same hash', () {
    const a = FunctionSignature(generic: 'f(x)', dart: 'int f(int x)');
    const b = FunctionSignature(generic: 'f(x)', dart: 'int f(int x)');

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const FunctionSignature(generic: null, dart: null)));
  });

  test('a field of the wrong type is a clear error, not a silent wrong value', () {
    final json = <String, dynamic>{'generic': 'f(x)', 'dart': 'int f(int x)'};
    json[json.keys.first] = <Object>[];

    expect(() => FunctionSignature.fromJson(json), throwsA(isA<TypeError>()));
  });
}
