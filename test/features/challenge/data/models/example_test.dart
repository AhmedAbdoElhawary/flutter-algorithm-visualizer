import 'package:algorithm_visualizer/features/challenge/data/models/example.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads every field and writes the same JSON back', () {
    final json = <String, dynamic>{'input': 'nums = [1]', 'output': '1', 'explanation': 'Only one.'};

    final model = Example.fromJson(json);

    expect(model, const Example(input: 'nums = [1]', output: '1', explanation: 'Only one.'));
    expect(model.toJson(), json);
  });

  test('every field is optional', () {
    expect(Example.fromJson(<String, dynamic>{}), const Example(input: null, output: null, explanation: null));
  });

  test('equal fields mean equal and the same hash', () {
    const a = Example(input: 'nums = [1]', output: '1', explanation: 'Only one.');
    const b = Example(input: 'nums = [1]', output: '1', explanation: 'Only one.');

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const Example(input: null, output: null, explanation: null)));
  });

  test('a field of the wrong type is a clear error, not a silent wrong value', () {
    final json = <String, dynamic>{'input': 'nums = [1]', 'output': '1', 'explanation': 'Only one.'};
    json[json.keys.first] = <Object>[];

    expect(() => Example.fromJson(json), throwsA(isA<TypeError>()));
  });
}
