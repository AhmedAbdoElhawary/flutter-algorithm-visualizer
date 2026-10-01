import 'package:flutter_test/flutter_test.dart';

import '../engine_support.dart';

void main() {
  test('size, keys, values and entries', () {
    expect(
      dart("var m = {'a': 1, 'b': 2}; "
          'return [m.length, m.isEmpty, m.isNotEmpty, m.keys.toList(), m.values.toList()];'),
      [2, false, true, ['a', 'b'], [1, 2]],
    );
    expect(
      dart("var m = {'a': 1}; return m.entries.map((e) => e.key + e.value.toString()).toList();"),
      ['a1'],
    );
  });

  test('an entry reads its key and value, as in a most-frequent loop', () {
    expect(
      dart("var counts = {'a': 2, 'b': 5}; var best = ''; var most = 0; "
          'for (final e in counts.entries) { if (e.value > most) { most = e.value; best = e.key; } } '
          'return [best, most, counts.entries.first.value.toString()];'),
      ['b', 5, '2'],
    );
  });

  test('lookups', () {
    expect(
      dart("var m = {'a': 1}; return [m.containsKey('a'), m.containsKey('z'), m.containsValue(1), m['z']];"),
      [true, false, true, null],
    );
  });

  test('putIfAbsent keeps an existing value', () {
    expect(
      dart("var m = {'a': 1}; m.putIfAbsent('a', () => 9); m.putIfAbsent('b', () => 2); return m;"),
      {'a': 1, 'b': 2},
    );
  });

  test('update, with and without a fallback for a missing key', () {
    expect(dart("var m = {'a': 1}; m.update('a', (v) => v + 1); return m;"), {'a': 2});
    expect(
      dart("var m = <String, int>{}; m.update('a', (v) => v + 1, ifAbsent: () => 7); return m;"),
      {'a': 7},
    );
    expect(dartFailure("var m = <String, int>{}; m.update('a', (v) => v + 1); return m;"), 'keyNotFound');
  });

  test('remove, clear and forEach', () {
    expect(dart("var m = {'a': 1, 'b': 2}; m.remove('a'); return m;"), {'b': 2});
    expect(dart("var m = {'a': 1}; m.clear(); return m.isEmpty;"), true);
    expect(dart("var sum = 0; var m = {'a': 1, 'b': 2}; m.forEach((k, v) { sum += v; }); return sum;"), 3);
  });

  group('sets', () {
    test('add, remove, contains and size', () {
      expect(
        dart('var s = {1}; s.add(2); s.add(2); s.remove(1); return [s.length, s.contains(2), s.isEmpty];'),
        [1, true, false],
      );
    });

    test('union, intersection and difference', () {
      expect(
        dart('var a = {1, 2}; var b = {2, 3}; return [a.union(b), a.intersection(b), a.difference(b)];'),
        [
          {1, 2, 3},
          {2},
          {1},
        ],
      );
    });

    test('to a list, and cleared', () {
      expect(
        dart('var s = {3, 1}; var l = s.toList(); s.clear(); return [l.length, s.isNotEmpty];'),
        [2, false],
      );
    });
  });
}
