import 'package:flutter_test/flutter_test.dart';

import '../engine_support.dart';

void main() {
  test('length and emptiness', () {
    expect(dart("return ['abc'.length, ''.isEmpty, 'a'.isNotEmpty];"), [3, true, true]);
  });

  group('string methods', () {
    for (final (expression, value) in [
      ("'a,b'.split(',')", ['a', 'b']),
      ("'hello'.substring(1, 3)", 'el'),
      ("'hello'.substring(2)", 'llo'),
      ("'hello'.indexOf('l')", 2),
      ("'hello'.lastIndexOf('l')", 3),
      ("'aXbX'.replaceAll('X', '-')", 'a-b-'),
      ("'aXbX'.replaceFirst('X', '-')", 'a-bX'),
      ("'  a  '.trim()", 'a'),
      ("'  a '.trimLeft()", 'a '),
      ("' a  '.trimRight()", ' a'),
      ("'Ab'.toUpperCase()", 'AB'),
      ("'Ab'.toLowerCase()", 'ab'),
      ("'7'.padLeft(3, '0')", '007'),
      ("'7'.padRight(3)", '7  '),
      ("'A'.codeUnitAt(0)", 65),
      ("'a'.compareTo('b')", -1),
      ("'hello'.contains('ell')", true),
      ("'hello'.startsWith('he')", true),
      ("'hello'.endsWith('lo')", true),
      ("'x'.toString()", 'x'),
    ]) {
      test(expression, () => expect(dart('return $expression;'), value));
    }
  });

  group('out of range is an error, never a wrong answer', () {
    test('substring', () {
      expect(dartFailure("return 'abc'.substring(2, 9);"), 'indexOutOfRange');
      expect(dartFailure("return 'abc'.substring(-1);"), 'indexOutOfRange');
    });

    test('codeUnitAt', () {
      expect(dartFailure("return 'abc'.codeUnitAt(3);"), 'indexOutOfRange');
    });

    test('an unknown method', () {
      expect(dartFailure("return 'abc'.shout();"), 'undefinedFunction');
    });
  });
}
