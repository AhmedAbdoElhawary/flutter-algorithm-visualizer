import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/language_registry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../engine_support.dart';

Object? _js(String source) {
  final result = runIn(EditorLanguage.javascript, source);
  if (result.failure != null) fail('$source\n→ ${result.failure}');
  return result.value;
}

void main() {
  group('each builtin gives what JavaScript gives', () {
    for (final (expression, value) in [
      (r"Math.abs(-3)", 3),
      (r"Math.floor(2.7)", 2),
      (r"Math.ceil(2.1)", 3),
      (r"Math.round(2.5)", 3),
      (r"Math.trunc(-2.7)", -2),
      (r"Math.sqrt(16)", 4),
      (r"Math.pow(2, 10)", 1024),
      (r"Math.min(3, 7)", 3),
      (r"Math.max(3, 7)", 7),
      (r"Math.sign(-5)", -1),
      (r"Object.keys({a: 1, b: 2})", ['a', 'b']),
      (r"Object.values({a: 1, b: 2})", [1, 2]),
      (r"Object.entries({a: 1})", [['a', 1]]),
      (r"Array.isArray([1])", true),
      (r"Array.isArray(1)", false),
      (r"Array.from({length: 3}, (_, i) => i * 2)", [0, 2, 4]),
      (r"Array.of(7)", [7]),
      (r"[1, 2, 3].slice(1)", [2, 3]),
      (r"[1, 2].concat([3])", [1, 2, 3]),
      (r"[1, 2, 3].join('-')", '1-2-3'),
      (r"[1, 2, 3].map(x => x * 2)", [2, 4, 6]),
      (r"[1, 2, 3].filter(x => x % 2)", [1, 3]),
      (r"[1, 2, 3].reduce((a, b) => a + b, 0)", 6),
      (r"[1, 2, 3].find(x => x > 1)", 2),
      (r"[1, 2, 3].findIndex(x => x > 1)", 1),
      (r"[1, 2, 3].some(x => x > 2)", true),
      (r"[1, 2, 3].every(x => x > 0)", true),
      (r"[[1], [2, 3]].flat()", [1, 2, 3]),
      (r"[1, 2, 1].indexOf(1)", 0),
      (r"[1, 2, 1].lastIndexOf(1)", 2),
      (r"[1, 2].includes(2)", true),
      (r"[1, 2, 3].at(-1)", 3),
      (r"'abc'.charAt(1)", 'b'),
      (r"'A'.charCodeAt(0)", 65),
      (r"'hello'.substring(1, 3)", 'el'),
      (r"'a,b'.split(',')", ['a', 'b']),
      (r"'Ab'.toUpperCase()", 'AB'),
      (r"'Ab'.toLowerCase()", 'ab'),
      (r"'  a '.trim()", 'a'),
      (r"'aXbX'.replace('X', '-')", 'a-bX'),
      (r"'aXbX'.replaceAll('X', '-')", 'a-b-'),
      (r"'hello'.startsWith('he')", true),
      (r"'hello'.endsWith('lo')", true),
      (r"'ab'.repeat(2)", 'abab'),
      (r"'7'.padStart(3, '0')", '007'),
      (r"'7'.padEnd(2, '.')", '7.'),
      (r"(2.345).toFixed(2)", '2.35'),
      (r"(12).toString()", '12'),
    ]) {
      test(expression, () => expect(_js('return $expression;'), value));
    }
  });

  test('arrays change in place: push, pop, shift, unshift, splice, reverse, sort, fill', () {
    expect(
      _js('const xs = [3, 1]; xs.push(2); const last = xs.pop(); xs.unshift(9); const first = xs.shift(); '
          'xs.splice(0, 1, 7, 8); xs.reverse(); xs.sort((a, b) => a - b); return [xs, last, first];'),
      [
        [1, 7, 8],
        2,
        9,
      ],
    );
    expect(_js('return [0, 0, 0].fill(5);'), [5, 5, 5]);
  });

  test('forEach visits every item', () {
    expect(_js('let sum = 0; [1, 2, 3].forEach(x => { sum += x }); return sum;'), 6);
  });

  test('the default sort compares as text, as JavaScript does', () {
    expect(_js('return [10, 9, 1].sort();'), [1, 10, 9]);
  });

  test('Map and Set', () {
    expect(
      _js("const m = new Map(); m.set('a', 1); const s = new Set([1, 1, 2]); s.add(3); s.delete(1); "
          "return [m.get('a'), m.has('b'), m.size, [...m.keys()], [...m.values()], s.size, s.has(3)];"),
      [1, false, 1, ['a'], [1], 2, true],
    );
    expect(_js("const m = new Map([['a', 1]]); m.delete('a'); return m.size;"), 0);
    expect(_js("const m = new Map([['a', 1]]); return [...m.entries()];"), [
      ['a', 1],
    ]);
  });

  test('Object.assign copies fields, Object.freeze hands back the same object', () {
    expect(_js('const a = {x: 1}; Object.assign(a, {y: 2}); return Object.keys(Object.freeze(a));'), ['x', 'y']);
  });

  test('a DP table from Array.from with a length', () {
    expect(_js('return Array.from({length: 3}, () => 0);'), [0, 0, 0]);
    expect(_js('return Array.from({length: 2}).length;'), 2);
  });

  test('console.log prints', () {
    expect(runIn(EditorLanguage.javascript, "console.log('hi'); return 0;").stdout, ['hi']);
  });
}
