// Indentation is the part of Python a hand-written frontend is most likely to
// get wrong, and the part a learner is most likely to trip over (Risk R3).
// Every case here is one a real learner produces by accident.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

import 'python_support.dart';

void main() {
  group('blocks that should work', () {
    test('a blank line inside a block does not close it', () {
      final r = runPython('''
def f():
    a = 1

    b = 2

    return a + b

print(f())
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3']);
    });

    test('a comment-only line at the wrong indentation does not close a block', () {
      final r = runPython('''
def f():
    a = 1
# a comment flush against the left margin
    return a

print(f())
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['1']);
    });

    test('trailing whitespace on a blank line is still a blank line', () {
      final r = runPython('def f():\n    a = 1\n    \n    return a\n\nprint(f())\n');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['1']);
    });

    test('tabs indent just as spaces do', () {
      final r = runPython('def f():\n\tif True:\n\t\treturn 7\n\treturn 0\n\nprint(f())\n');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['7']);
    });

    test('a deeply nested block dedents all the way back out', () {
      final r = runPython('''
def f():
    total = 0
    for i in range(3):
        for j in range(3):
            if i == j:
                total += 1
    return total

print(f())
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3']);
    });

    test('a bracketed expression may span lines at any indentation', () {
      final r = runPython('''
xs = [
        1,
    2,
            3,
]
print(sum(xs))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['6']);
    });

    test('a call may span lines inside its parentheses', () {
      final r = runPython('''
def add(a, b):
    return a + b

print(add(
    1,
    2,
))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3']);
    });

    test('a trailing backslash joins two lines explicitly', () {
      final r = runPython('''
total = 1 + \\
        2
print(total)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3']);
    });

    test('a one-line body after the colon is a block', () {
      final r = runPython('''
def f(n):
    if n > 0: return "positive"
    return "other"

print(f(3))
print(f(-3))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['positive', 'other']);
    });

    test('an indentation of any consistent width works', () {
      final r = runPython('''
def f():
  if True:
      return 5
  return 0

print(f())
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['5']);
    });

    test('a file ending without a trailing newline still closes its blocks', () {
      final r = runPython('def f():\n    return 4\nprint(f())');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['4']);
    });
  });

  group('indentation mistakes name indentation', () {
    test('a dedent that lands between two levels is an indentation error', () {
      final r = runPython('''
def f():
    if True:
        a = 1
      return a
''');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.syntax);
      expect(r.failure!.code, 'indentationError');
      expect(r.failure!.line, 4, reason: 'should point at the offending line');
    });

    test('a tab after spaces is rejected rather than guessed at', () {
      final r = runPython('def f():\n    a = 1\n    \tb = 2\n    return a\n');
      expect(r.failure, isNotNull);
      expect(r.failure!.code, 'indentationError');
    });

    test('a block header with no indented body is reported clearly', () {
      final r = runPython('''
def f():
return 1
''');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.syntax);
      expect(r.failure!.code, 'expectedIndentedBlock');
    });

    test('an indented first line is an indentation error, not a crash', () {
      final r = runPython('    x = 1\n');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.syntax);
    });
  });

  group('hostile input is classified, never a crash', () {
    test('empty source', () {
      final r = runPython('');
      expect(r.failure, isNull);
    });

    test('whitespace only', () {
      final r = runPython('   \n\t\n   \n');
      expect(r.failure, isNull);
    });

    test('comments only', () {
      final r = runPython('# just a comment\n# and another\n');
      expect(r.failure, isNull);
    });

    test('a very long line', () {
      final r = runPython('x = ${List<int>.filled(2000, 1).join(' + ')}\nprint(x)\n');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['2000']);
    });

    test('a deeply nested expression', () {
      final source = 'print(${'(' * 200}1${')' * 200})\n';
      final r = runPython(source);
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['1']);
    });

    test('an unterminated string is a syntax failure', () {
      final r = runPython('x = "unterminated\n');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.syntax);
    });

    test('an unclosed bracket is a syntax failure, not a hang', () {
      final r = runPython('xs = [1, 2\n');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.syntax);
    });
  });
}
