import 'package:flutter_test/flutter_test.dart';

import '../engine_support.dart';

void main() {
  test('size, ends and reversed', () {
    expect(dart('var xs = [1, 2, 3]; return [xs.length, xs.isEmpty, xs.isNotEmpty, xs.first, xs.last];'),
        [3, false, true, 1, 3]);
    expect(dart('return [1, 2, 3].reversed.toList();'), [3, 2, 1]);
  });

  test('first and last of an empty list is an error, never a guess', () {
    expect(dartFailure('return <int>[].first;'), isNotNull);
    expect(dartFailure('return <int>[].last;'), isNotNull);
  });

  group('the functional methods', () {
    for (final (expression, value) in [
      ('[1, 2, 3].map((x) => x * 2).toList()', [2, 4, 6]),
      ('[1, 2, 3].where((x) => x.isOdd).toList()', [1, 3]),
      ('[[1], [2, 3]].expand((x) => x).toList()', [1, 2, 3]),
      ('[1, 2, 3].reduce((a, b) => a + b)', 6),
      ('[1, 2, 3].fold(10, (a, b) => a + b)', 16),
      ('[1, 2, 3].any((x) => x > 2)', true),
      ('[1, 2, 3].every((x) => x > 2)', false),
      ('[1, 2, 3].firstWhere((x) => x > 1)', 2),
      ('[1, 2, 3].firstWhere((x) => x > 5, orElse: () => -1)', -1),
      ('[1, 2, 3].indexWhere((x) => x == 3)', 2),
      ('[1, 2, 3].contains(2)', true),
      ('[1, 2, 3].indexOf(9)', -1),
      ("[1, 2, 3].join('-')", '1-2-3'),
      ('[1, 2, 3].take(2).toList()', [1, 2]),
      ('[1, 2, 3].skip(2).toList()', [3]),
      ('[1, 2, 3].sublist(1)', [2, 3]),
      ('[1, 2, 3].sublist(0, 1)', [1]),
      ('[1, 1, 2].toSet().length', 2),
      ('[5, 6].asMap()', {0: 5, 1: 6}),
    ]) {
      test(expression, () => expect(dart('return $expression;'), value));
    }
  });

  test('sort, naturally and with a comparator', () {
    expect(dart('var xs = [3, 1, 2]; xs.sort(); return xs;'), [1, 2, 3]);
    expect(dart('var xs = [3, 1, 2]; xs.sort((a, b) => b - a); return xs;'), [3, 2, 1]);
  });

  test('reduce on an empty list is an error', () {
    expect(dartFailure('return <int>[].reduce((a, b) => a + b);'), isNotNull);
  });

  test('changing a list', () {
    expect(
      dart('var xs = [1]; xs.add(2); xs.addAll([3, 4]); xs.remove(1); xs.removeAt(0); xs.insert(0, 9); '
          'var last = xs.removeLast(); return [xs, last];'),
      [
        [9, 3],
        4,
      ],
    );
    expect(dart('var xs = [1, 2]; xs.clear(); return xs;'), <Object?>[]);
  });

  test('an index out of range is an error, never a wrong answer', () {
    expect(dartFailure('return [1, 2].sublist(1, 5);'), 'indexOutOfRange');
    expect(dartFailure('var xs = [1]; xs.removeAt(3); return xs;'), 'indexOutOfRange');
    expect(dartFailure('return [1, 2][5];'), 'indexOutOfRange');
  });
}
