import 'package:flutter_test/flutter_test.dart';

import '../engine_support.dart';

void main() {
  group('number properties', () {
    test('even, odd and negative', () {
      final result = dart('return [4.isEven, 4.isOdd, (-2).isNegative, 1.5.isNegative];');
      expect(result, [true, false, true, false]);
    });
  });

  group('number methods', () {
    for (final (expression, value) in [
      ('(-3).abs()', 3),
      ('(-2.5).abs()', 2.5),
      ('2.7.floor()', 2),
      ('2.1.ceil()', 3),
      ('2.5.round()', 3),
      ('3.toDouble()', 3.0),
      ('3.9.toInt()', 3),
      ('42.toString()', '42'),
      ('2.5.toString()', '2.5'),
      ('3.compareTo(5)', -1),
      ('9.clamp(0, 5)', 5),
    ]) {
      test(expression, () => expect(dart('return $expression;'), value));
    }

    test('clamp and pow on ints stay ints, as in dart', () {
      expect(dart('return 9.clamp(0, 5);'), isA<int>());
      expect(dart('return 2.pow(10);'), allOf(isA<int>(), 1024));
      expect(dart('return 2.5.clamp(0, 2);'), allOf(isA<double>(), 2.0));
      expect(dart('return 2.pow(-1);'), 0.5);
    });

    test('an unknown method stops the run instead of guessing', () {
      expect(dartFailure('return 3.frobnicate();'), 'undefinedFunction');
    });
  });

  group('the globals every language gets', () {
    test('min and max keep ints as ints', () {
      expect(dart('return [min(3, 7), max(3, 7), min(1.5, 2)];'), [3, 7, 1.5]);
    });

    test('sqrt', () {
      expect(dart('return sqrt(16);'), 4.0);
    });

    test('int and double parsing, with and without a fallback', () {
      expect(dart("return [int.parse('12'), int.tryParse('x'), double.parse('1.5'), double.tryParse('y')];"),
          [12, null, 1.5, null]);
    });

    test('a bad number string is a clear error', () {
      expect(dartFailure("return int.parse('abc');"), 'typeMismatch');
      expect(dartFailure("return double.parse('abc');"), 'typeMismatch');
    });

    test('building lists', () {
      expect(dart('return List.generate(3, (i) => i * i);'), [0, 1, 4]);
      expect(dart('return List.filled(2, 0);'), [0, 0]);
      expect(dart('return List.from([1, 2]);'), [1, 2]);
      expect(dart('return List.from({3});'), [3]);
    });

    test('a filled list can still grow', () {
      expect(dart('var xs = List.filled(1, 0); xs.add(5); return xs;'), [0, 5]);
    });
  });
}
