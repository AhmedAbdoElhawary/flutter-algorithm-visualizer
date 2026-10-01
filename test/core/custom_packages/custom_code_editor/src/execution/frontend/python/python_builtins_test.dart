import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/language_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../engine_support.dart';

Object? _py(String source) {
  final result = runIn(EditorLanguage.python, source);
  if (result.failure != null) fail('$source\n→ ${result.failure}');
  return result.value;
}

void main() {
  group('each builtin gives what Python gives', () {
    for (final (expression, value) in [
      (r"len([1, 2, 3])", 3),
      (r"len('abc')", 3),
      (r"list(range(3))", [0, 1, 2]),
      (r"list(range(1, 7, 2))", [1, 3, 5]),
      (r"sorted([3, 1, 2])", [1, 2, 3]),
      (r"sorted([3, 1, 2], reverse=True)", [3, 2, 1]),
      (r"list(enumerate(['a', 'b']))", [[0, 'a'], [1, 'b']]),
      (r"list(zip([1, 2], ['a', 'b']))", [[1, 'a'], [2, 'b']]),
      (r"sum([1, 2, 3])", 6),
      (r"min([3, 1, 2])", 1),
      (r"max(3, 7)", 7),
      (r"abs(-4)", 4),
      (r"int('12')", 12),
      (r"str(12)", '12'),
      (r"float('1.5')", 1.5),
      (r"list(reversed([1, 2, 3]))", [3, 2, 1]),
      (r"'Ab'.upper()", 'AB'),
      (r"'Ab'.lower()", 'ab'),
      (r"'  a '.strip()", 'a'),
      (r"'  a '.lstrip()", 'a '),
      (r"' a  '.rstrip()", ' a'),
      (r"'hello'.startswith('he')", true),
      (r"'hello'.endswith('lo')", true),
      (r"'aXbX'.replace('X', '-')", 'a-b-'),
      (r"'hello'.find('l')", 2),
      (r"'a,b'.split(',')", ['a', 'b']),
      (r"'-'.join(['a', 'b'])", 'a-b'),
      (r"'7'.rjust(3, '0')", '007'),
      (r"'7'.ljust(2, '.')", '7.'),
      (r"'123'.isdigit()", true),
      (r"'abc'.isalpha()", true),
      (r"' '.isspace()", true),
      (r"[1, 2, 1].index(2)", 1),
      (r"[1, 2, 1].count(1)", 2),
      (r"{'a': 1}.get('b', 0)", 0),
      (r"list({'a': 1}.items())", [['a', 1]]),
      (r"{1, 2}.union({3})", {1, 2, 3}),
      (r"{1, 2}.intersection({2, 3})", {2}),
      (r"{1, 2}.difference({2})", {1}),
    ]) {
      test(expression, () => expect(_py('return $expression'), value));
    }
  });

  test('lists change in place: append, extend, insert, pop, remove, sort, reverse, copy, clear', () {
    expect(
      _py('xs = [3]\nxs.append(1)\nxs.extend([2])\nxs.insert(0, 9)\nlast = xs.pop()\nxs.remove(9)\n'
          'xs.sort()\nys = xs.copy()\nxs.reverse()\nys.clear()\nreturn [xs, last, ys]'),
      [
        [3, 1],
        2,
        <Object?>[],
      ],
    );
  });

  test('dicts: update and setdefault', () {
    expect(_py("d = {'a': 1}\nd.update({'b': 2})\nd.setdefault('a', 9)\nd.setdefault('c', 3)\nreturn d"),
        {'a': 1, 'b': 2, 'c': 3});
  });

  test('sets: add and discard', () {
    expect(_py('s = {1}\ns.add(2)\ns.discard(1)\ns.discard(5)\nreturn s'), {2});
  });

  test('print writes a line', () {
    expect(runIn(EditorLanguage.python, "print('hi', 2)\nreturn 0").stdout, ['hi 2']);
  });
}
