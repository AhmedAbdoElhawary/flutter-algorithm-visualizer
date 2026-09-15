// A first pass over the Python frontend, smallest constructs first, so that
// when something breaks the failing test names it precisely.

import 'package:flutter_test/flutter_test.dart';

import 'python_support.dart';

void main() {
  test('an expression statement and a return', () {
    final r = runPython('''
def f():
    return 1 + 2

print(f())
''');
    expect(r.failure, isNull, reason: '$r');
    expect(r.stdout, <String>['3']);
  });

  test('variables, reassignment and an if/else', () {
    final r = runPython('''
def classify(n):
    label = "small"
    if n > 10:
        label = "big"
    else:
        label = "medium"
    return label

print(classify(50))
print(classify(5))
''');
    expect(r.failure, isNull, reason: '$r');
    expect(r.stdout, <String>['big', 'medium']);
  });

  test('a for loop over range with an accumulator', () {
    final r = runPython('''
def total(n):
    acc = 0
    for i in range(n):
        acc += i
    return acc

print(total(5))
''');
    expect(r.failure, isNull, reason: '$r');
    expect(r.stdout, <String>['10']);
  });

  test('a list comprehension', () {
    final r = runPython('''
xs = [1, 2, 3, 4]
print([x * 2 for x in xs if x % 2 == 0])
''');
    expect(r.failure, isNull, reason: '$r');
    expect(r.stdout, <String>['[4, 8]']);
  });

  test('a dict, a loop over it, and membership', () {
    final r = runPython('''
counts = {}
for c in "hello":
    if c in counts:
        counts[c] += 1
    else:
        counts[c] = 1
print(counts["l"])
''');
    expect(r.failure, isNull, reason: '$r');
    expect(r.stdout, <String>['2']);
  });

  test('a class with a method and self', () {
    final r = runPython('''
class Counter:
    def __init__(self, start):
        self.n = start

    def bump(self):
        self.n += 1
        return self.n

c = Counter(5)
print(c.bump())
''');
    expect(r.failure, isNull, reason: '$r');
    expect(r.stdout, <String>['6']);
  });

  test('slicing and negative indexing', () {
    final r = runPython('''
xs = [0, 1, 2, 3, 4]
print(xs[1:3])
print(xs[-1])
print(xs[::-1])
''');
    expect(r.failure, isNull, reason: '$r');
    expect(r.stdout, <String>['[1, 2]', '4', '[4, 3, 2, 1, 0]']);
  });

  test('an f-string', () {
    final r = runPython('''
name = "world"
print(f"hello {name}, {1 + 1}")
''');
    expect(r.failure, isNull, reason: '$r');
    expect(r.stdout, <String>['hello world, 2']);
  });

  test('tuple unpacking and swapping', () {
    final r = runPython('''
a, b = 1, 2
a, b = b, a
print(a)
print(b)
''');
    expect(r.failure, isNull, reason: '$r');
    expect(r.stdout, <String>['2', '1']);
  });

  test('a lambda passed to sorted with a key', () {
    final r = runPython('''
pairs = [(1, "b"), (2, "a")]
print(sorted(pairs, key=lambda p: p[1]))
''');
    expect(r.failure, isNull, reason: '$r');
    expect(r.stdout, <String>['[(2, a), (1, b)]']);
  });

  test('the harness calls a named function with arguments', () {
    final r = callPython('''
def add(a, b):
    return a + b
''', 'add', <Object?>[2, 3]);
    expect(r.failure, isNull, reason: '$r');
    expect(r.value, 5);
  });

  test('recursion', () {
    final r = callPython('''
def fib(n):
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)
''', 'fib', <Object?>[15]);
    expect(r.failure, isNull, reason: '$r');
    expect(r.value, 610);
  });

  test('try/except catches a raise', () {
    final r = runPython('''
def risky(n):
    try:
        if n < 0:
            raise ValueError("negative")
        return "ok"
    except ValueError as e:
        return "caught"
    finally:
        print("done")

print(risky(-1))
''');
    expect(r.failure, isNull, reason: '$r');
    expect(r.stdout, <String>['done', 'caught']);
  });

  test('while with break and continue', () {
    final r = runPython('''
i = 0
out = []
while True:
    i += 1
    if i % 2 == 0:
        continue
    if i > 7:
        break
    out.append(i)
print(out)
''');
    expect(r.failure, isNull, reason: '$r');
    expect(r.stdout, <String>['[1, 3, 5, 7]']);
  });
}
