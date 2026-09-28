import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('splitTopLevel', () {
    test('splits only on commas outside brackets and quotes', () {
      expect(splitTopLevel('a, [1, 2], (3, 4), {5, 6}, "x, y", \'p, q\''), [
        'a',
        '[1, 2]',
        '(3, 4)',
        '{5, 6}',
        '"x, y"',
        "'p, q'",
      ]);
    });

    test('a different delimiter', () {
      expect(splitTopLevel('a -> [b -> c] -> d', '->'), ['a', '[b -> c]', 'd']);
    });

    test('empty input gives nothing, one value gives one part', () {
      expect(splitTopLevel(''), isEmpty);
      expect(splitTopLevel('  x  '), ['x']);
    });
  });

  group('parentheses', () {
    test('the first opening one', () {
      expect(topLevelOpenParen('int f(int a)'), 5);
      expect(topLevelOpenParen('int f(int a)', 6), -1);
      expect(topLevelOpenParen('no parens'), -1);
    });

    test('its match skips nested ones and any inside quotes', () {
      const s = 'f(a, g(b), ")", \'(\')';
      expect(matchingParen(s, 1), s.length - 1);
    });

    test('an unclosed one has no match', () {
      expect(matchingParen('f(a, (b)', 1), -1);
    });
  });
}
