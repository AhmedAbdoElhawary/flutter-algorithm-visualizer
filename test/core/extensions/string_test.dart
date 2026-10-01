import 'package:algorithm_visualizer/core/extensions/string.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toSnakeCase', () {
    for (final (input, expected) in [
      ('twoSum', 'two_sum'),
      ('ListNode', 'list_node'),
      ('level2Tree', 'level2_tree'),
      ('already_snake', 'already_snake'),
      ('', ''),
    ]) {
      test('"$input" → "$expected"', () => expect(input.toSnakeCase, expected));
    }
  });

  group('toFileName', () {
    test('uses the extension it is given', () {
      expect('Two Sum'.toFileName('dart'), 'two_sum.dart');
      expect('Two Sum'.toFileName('py'), 'two_sum.py');
      expect('Two Sum'.toFileName('js'), 'two_sum.js');
    });

    test('drops words from the end until the name is short', () {
      expect('Longest Substring Without Repeating Characters'.toFileName('py'), 'longest_substring.py');
    });

    test('a single long word is kept whole', () {
      expect('Supercalifragilisticexpialidocious'.toFileName('js'), 'supercalifragilisticexpialidocious.js');
    });

    test('runs of spaces become one underscore', () {
      expect('Two   Sum'.toFileName('py'), 'two_sum.py');
    });
  });
}
