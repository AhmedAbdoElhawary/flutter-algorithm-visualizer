import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('one value', () {
    for (final (input, raw) in [
      ('null', null),
      ('true', true),
      ('false', false),
      ('42', 42),
      ('-7', -7),
      ('2.5', 2.5),
      ('"hi"', 'hi'),
      ("'hi'", 'hi'),
      (r'"say \"hi\""', 'say "hi"'),
      ('  7  ', 7),
      ('[]', <Object?>[]),
      ('[1, [2, 3], "a,b", null]', [1, [2, 3], 'a,b', null]),
      ('bare', 'bare'),
    ]) {
      test(input, () => expect(testValueToRaw(parseValue(input)), raw));
    }

    test('an int stays an int and a double a double', () {
      expect(parseValue('3'), isA<IntTestValue>());
      expect(parseValue('3.0'), isA<DoubleTestValue>());
    });
  });

  group('a test case input', () {
    test('named values, commas inside lists and strings included', () {
      final input = parseTestCaseInput('nums=[2, 7, 11], target=9, s="a, b"');

      expect(input.keys, ['nums', 'target', 's']);
      expect(testValueToRaw(input['nums']!), [2, 7, 11]);
      expect(testValueToRaw(input['target']!), 9);
      expect(testValueToRaw(input['s']!), 'a, b');
    });

    test('a segment with no name or no value is skipped, never guessed', () {
      final input = parseTestCaseInput('=1, x=, y=2, junk');

      expect(input.keys, ['y']);
    });

    test('an empty input has no values', () {
      expect(parseTestCaseInput(''), isEmpty);
    });
  });
}
