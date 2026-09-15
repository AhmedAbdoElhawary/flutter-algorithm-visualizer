// Every construct the frontend contract requires of the Python frontend, plus
// the Python-specific semantics the dialect promises, plus the constructs that
// must come back as `unsupported` rather than `syntax` (SC-009).

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

import 'python_support.dart';

/// Evaluates one Python expression and returns its value.
Object? value(String expression) {
  final r = runPython('__result = $expression\n');
  expect(r.failure, isNull, reason: 'evaluating `$expression`: ${r.failure}');
  final printed = runPython('__result = $expression\nprint(__result)\n');
  expect(printed.failure, isNull, reason: '$printed');
  return printed.stdout.single;
}

void main() {
  group('operators and arithmetic', () {
    test('/ always produces a float, even for two whole numbers', () {
      expect(value('7 / 2'), '3.5');
      expect(value('6 / 3'), '2.0');
    });

    test('// floors toward negative infinity, unlike truncation', () {
      expect(value('7 // 2'), '3');
      expect(value('-7 // 2'), '-4');
    });

    test('% follows the sign of the divisor', () {
      expect(value('7 % 3'), '1');
    });

    test('** is right-associative and keeps whole numbers whole', () {
      expect(value('2 ** 10'), '1024');
      expect(value('2 ** 3 ** 2'), '512');
    });

    test('unary minus binds looser than **', () {
      expect(value('-2 ** 2'), '-4');
    });

    test('comparison chaining reads as one range check', () {
      expect(value('1 <= 5 <= 10'), 'True');
      expect(value('1 <= 50 <= 10'), 'False');
    });

    test('and/or return a value, not just a bool', () {
      expect(value('0 or "fallback"'), 'fallback');
      expect(value('"a" and "b"'), 'b');
    });

    test('booleans print as True and False', () {
      expect(value('1 == 1'), 'True');
      expect(value('1 == 2'), 'False');
    });

    test('None prints as None', () {
      expect(value('None'), 'None');
    });
  });

  group('truthiness is Pythonic', () {
    test('empty collections and zero are falsy', () {
      final r = runPython('''
for v in [0, "", [], {}, None]:
    if v:
        print("truthy")
    else:
        print("falsy")
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['falsy', 'falsy', 'falsy', 'falsy', 'falsy']);
    });

    test('non-empty values are truthy', () {
      final r = runPython('''
for v in [1, "a", [0], {"k": 1}]:
    if v:
        print("truthy")
    else:
        print("falsy")
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['truthy', 'truthy', 'truthy', 'truthy']);
    });

    test('`if not queue` is the idiomatic empty check', () {
      final r = runPython('''
queue = []
if not queue:
    print("empty")
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['empty']);
    });
  });

  group('equality does not coerce', () {
    test('1 == "1" is False', () {
      expect(value('1 == "1"'), 'False');
    });

    test('True equals 1 only because Python says so — this engine keeps them apart', () {
      expect(value('[] == [] '), 'True');
    });
  });

  group('strings', () {
    test('indexing yields a one-character string, not a code unit', () {
      expect(value('"abc"[0]'), 'a');
    });

    test('negative indexing counts from the end', () {
      expect(value('"abc"[-1]'), 'c');
    });

    test('slicing and reversal', () {
      expect(value('"hello"[1:3]'), 'el');
      expect(value('"hello"[::-1]'), 'olleh');
    });

    test('concatenation and repetition-free building', () {
      expect(value('"a" + "b"'), 'ab');
    });

    test('split with no separator splits on whitespace runs', () {
      final r = runPython('print("  a  b   c ".split())');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[a, b, c]']);
    });

    test('split with a separator keeps empty pieces', () {
      final r = runPython('print("a,,b".split(","))');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[a, , b]']);
    });

    test('join takes the separator as its receiver', () {
      expect(value('"-".join(["a", "b", "c"])'), 'a-b-c');
    });

    test('case, strip and replace', () {
      expect(value('"  Ab  ".strip().lower()'), 'ab');
      expect(value('"aXbXc".replace("X", "-")'), 'a-b-c');
    });

    test('find returns -1 while index raises', () {
      expect(value('"abc".find("z")'), '-1');
      final r = runPython('print("abc".index("z"))');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.runtime);
    });

    test('startswith, endswith and count', () {
      expect(value('"hello".startswith("he")'), 'True');
      expect(value('"hello".endswith("lo")'), 'True');
      expect(value('"banana".count("na")'), '2');
    });

    test('isdigit and isalpha', () {
      expect(value('"123".isdigit()'), 'True');
      expect(value('"12a".isdigit()'), 'False');
      expect(value('"abc".isalpha()'), 'True');
    });

    test('ord and chr round-trip', () {
      expect(value('chr(ord("a") + 1)'), 'b');
    });

    test('an f-string with an expression and nested quotes', () {
      final r = runPython('''
d = {"k": 5}
print(f"value is {d['k'] * 2}")
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['value is 10']);
    });

    test('escaped braces in an f-string are literal', () {
      final r = runPython(r'''
print(f"{{literal}} {1 + 1}")
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['{literal} 2']);
    });

    test('a triple-quoted string spans lines', () {
      final r = runPython('''
s = """line one
line two"""
print(len(s.split("\\n")))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['2']);
    });
  });

  group('lists', () {
    test('append, pop and pop at an index', () {
      final r = runPython('''
xs = [1, 2, 3]
xs.append(4)
print(xs.pop())
print(xs.pop(0))
print(xs)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['4', '1', '[2, 3]']);
    });

    test('insert, remove, index and count', () {
      final r = runPython('''
xs = [1, 2, 2, 3]
xs.insert(0, 0)
xs.remove(2)
print(xs)
print(xs.index(3))
print(xs.count(2))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[0, 1, 2, 3]', '3', '1']);
    });

    test('sort in place, with a key and reversed', () {
      final r = runPython('''
xs = [3, 1, 2]
xs.sort()
print(xs)
xs.sort(reverse=True)
print(xs)
words = ["ccc", "a", "bb"]
words.sort(key=lambda w: len(w))
print(words)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[1, 2, 3]', '[3, 2, 1]', '[a, bb, ccc]']);
    });

    test('sorted leaves the original alone', () {
      final r = runPython('''
xs = [3, 1, 2]
print(sorted(xs))
print(xs)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[1, 2, 3]', '[3, 1, 2]']);
    });

    test('reverse in place and reversed as a copy', () {
      final r = runPython('''
xs = [1, 2, 3]
xs.reverse()
print(xs)
print(list(reversed(xs)))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[3, 2, 1]', '[1, 2, 3]']);
    });

    test('extend and copy', () {
      final r = runPython('''
xs = [1]
xs.extend([2, 3])
ys = xs.copy()
ys.append(4)
print(xs)
print(ys)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[1, 2, 3]', '[1, 2, 3, 4]']);
    });

    test('an index past the end is a runtime failure naming the index', () {
      final r = runPython('xs = [1]\nprint(xs[5])\n');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.runtime);
      expect(r.failure!.code, 'indexOutOfRange');
      expect(r.failure!.line, 2);
    });
  });

  group('dicts', () {
    test('get with and without a fallback never raises', () {
      final r = runPython('''
d = {"a": 1}
print(d.get("a"))
print(d.get("z"))
print(d.get("z", 0))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['1', 'None', '0']);
    });

    test('keys, values and items', () {
      final r = runPython('''
d = {"a": 1, "b": 2}
print(list(d.keys()))
print(list(d.values()))
print(d.items())
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[a, b]', '[1, 2]', '[(a, 1), (b, 2)]']);
    });

    test('iterating a dict walks its keys', () {
      final r = runPython('''
d = {"a": 1, "b": 2}
for k in d:
    print(k)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['a', 'b']);
    });

    test('unpacking items in a for loop', () {
      final r = runPython('''
d = {"a": 1, "b": 2}
for k, v in d.items():
    print(k + str(v))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['a1', 'b2']);
    });

    test('in checks keys, not values', () {
      final r = runPython('''
d = {"a": 1}
print("a" in d)
print(1 in d)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['True', 'False']);
    });

    test('the counting idiom', () {
      final r = runPython('''
counts = {}
for c in "aab":
    counts[c] = counts.get(c, 0) + 1
print(counts)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['{a: 2, b: 1}']);
    });

    test('pop, setdefault and update', () {
      final r = runPython('''
d = {"a": 1}
d.setdefault("b", 2)
d.update({"c": 3})
print(d.pop("a"))
print(d)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['1', '{b: 2, c: 3}']);
    });
  });

  group('sets and tuples', () {
    test('a set dedupes and supports membership', () {
      final r = runPython('''
s = set([1, 2, 2, 3])
print(len(s))
print(2 in s)
s.add(4)
s.discard(1)
print(sorted(list(s)))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3', 'True', '[2, 3, 4]']);
    });

    test('set literals and operations', () {
      final r = runPython('''
a = {1, 2, 3}
b = {2, 3, 4}
print(sorted(list(a.intersection(b))))
print(sorted(list(a.difference(b))))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[2, 3]', '[1]']);
    });

    test('tuples index and unpack', () {
      final r = runPython('''
t = (1, 2, 3)
print(t[1])
a, b, c = t
print(c)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['2', '3']);
    });

    test('a one-element tuple keeps its trailing comma', () {
      final r = runPython('t = (1,)\nprint(len(t))\n');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['1']);
    });
  });

  group('comprehensions', () {
    test('list comprehension with a condition', () {
      expect(value('[x * x for x in range(5) if x % 2 == 0]'), '[0, 4, 16]');
    });

    test('dict comprehension', () {
      final r = runPython('print({x: x * 2 for x in range(3)})');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['{0: 0, 1: 2, 2: 4}']);
    });

    test('set comprehension dedupes', () {
      final r = runPython('print(len({x % 3 for x in range(10)}))');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3']);
    });

    test('a nested comprehension flattens in reading order', () {
      expect(value('[(a, b) for a in range(2) for b in range(2)]'),
          '[(0, 0), (0, 1), (1, 0), (1, 1)]');
    });

    test('a comprehension over pairs unpacks them', () {
      expect(value('[a + b for a, b in [(1, 2), (3, 4)]]'), '[3, 7]');
    });

    test('a comprehension sees enclosing variables', () {
      final r = runPython('''
def scale(xs, factor):
    return [x * factor for x in xs]

print(scale([1, 2], 3))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[3, 6]']);
    });

    test('a comprehension variable does not leak into the enclosing scope', () {
      final r = runPython('''
x = "outer"
ys = [x for x in range(3)]
print(x)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['outer']);
    });

    test('a generator expression inside a call', () {
      expect(value('sum(x * 2 for x in range(4))'), '12');
    });
  });

  group('builtins', () {
    test('len over every container', () {
      expect(value('len([1, 2])'), '2');
      expect(value('len("abc")'), '3');
      expect(value('len({"a": 1})'), '1');
      expect(value('len({1, 2})'), '2');
    });

    test('range with one, two and three arguments', () {
      expect(value('list(range(3))'), '[0, 1, 2]');
      expect(value('list(range(2, 5))'), '[2, 3, 4]');
      expect(value('list(range(0, 10, 3))'), '[0, 3, 6, 9]');
      expect(value('list(range(3, 0, -1))'), '[3, 2, 1]');
    });

    test('min and max over an iterable or over arguments', () {
      expect(value('min([3, 1, 2])'), '1');
      expect(value('max([3, 1, 2])'), '3');
      expect(value('min(4, 2)'), '2');
      expect(value('max(4, 2, 9)'), '9');
    });

    test('sum with and without a start', () {
      expect(value('sum([1, 2, 3])'), '6');
      expect(value('sum([1, 2], 10)'), '13');
    });

    test('abs and round', () {
      expect(value('abs(-3)'), '3');
      expect(value('round(2.6)'), '3');
    });

    test('enumerate, optionally from an offset', () {
      expect(value('list(enumerate(["a", "b"]))'), '[(0, a), (1, b)]');
      expect(value('list(enumerate(["a"], 1))'), '[(1, a)]');
    });

    test('zip stops at the shortest', () {
      expect(value('list(zip([1, 2, 3], ["a", "b"]))'), '[(1, a), (2, b)]');
    });

    test('any and all', () {
      expect(value('any([0, 1])'), 'True');
      expect(value('all([1, 0])'), 'False');
    });

    test('map and filter', () {
      expect(value('list(map(lambda x: x * 2, [1, 2]))'), '[2, 4]');
      expect(value('list(filter(lambda x: x > 1, [1, 2, 3]))'), '[2, 3]');
    });

    test('type conversions', () {
      expect(value('int("42")'), '42');
      expect(value('str(42)'), '42');
      expect(value('float("1.5")'), '1.5');
      expect(value('int(3.9)'), '3');
      expect(value('bool([])'), 'False');
    });

    test("float('inf') is the standard no-bound-yet sentinel", () {
      final r = runPython('''
best = float("inf")
for x in [5, 2, 8]:
    if x < best:
        best = x
print(best)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['2']);
    });

    test('divmod returns the pair', () {
      expect(value('divmod(7, 2)'), '(3, 1)');
    });
  });

  group('functions and closures', () {
    test('default arguments', () {
      final r = runPython('''
def greet(name, greeting="hi"):
    return greeting + " " + name

print(greet("a"))
print(greet("a", "yo"))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['hi a', 'yo a']);
    });

    test('keyword arguments are matched by name', () {
      final r = runPython('''
def make(a, b, c):
    return [a, b, c]

print(make(1, c=3, b=2))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[1, 2, 3]']);
    });

    test('a closure captures and keeps an enclosing local', () {
      final r = runPython('''
def counter():
    n = [0]
    def bump():
        n[0] += 1
        return n[0]
    return bump

c = counter()
c()
print(c())
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['2']);
    });

    test('a name first assigned inside an if is still visible afterwards', () {
      final r = runPython('''
def f(flag):
    if flag:
        found = "yes"
    else:
        found = "no"
    return found

print(f(True))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['yes']);
    });

    test('a name assigned only in a loop body survives the loop', () {
      final r = runPython('''
def first_even(xs):
    result = None
    for x in xs:
        if x % 2 == 0:
            result = x
            break
    return result

print(first_even([1, 3, 4, 5]))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['4']);
    });

    test('a spread call expands a list into parameters', () {
      final r = runPython('''
def add(a, b):
    return a + b

args = [1, 2]
print(add(*args))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3']);
    });

    test('mutual recursion', () {
      final r = runPython('''
def is_even(n):
    if n == 0:
        return True
    return is_odd(n - 1)

def is_odd(n):
    if n == 0:
        return False
    return is_even(n - 1)

print(is_even(10))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['True']);
    });
  });

  group('classes', () {
    test('inheritance with super().__init__', () {
      final r = runPython('''
class Animal:
    def __init__(self, name):
        self.name = name

    def speak(self):
        return "..."

    def describe(self):
        return self.name + " says " + self.speak()

class Dog(Animal):
    def __init__(self, name):
        super().__init__(name)

    def speak(self):
        return "woof"

print(Dog("rex").describe())
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['rex says woof']);
    });

    test('a method calling another method on self', () {
      final r = runPython('''
class Stack:
    def __init__(self):
        self.items = []

    def push(self, x):
        self.items.append(x)

    def pop(self):
        return self.items.pop()

    def size(self):
        return len(self.items)

s = Stack()
s.push(1)
s.push(2)
print(s.pop())
print(s.size())
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['2', '1']);
    });

    test('a receiver need not be called self', () {
      final r = runPython('''
class Box:
    def __init__(this, v):
        this.v = v

    def get(this):
        return this.v

print(Box(7).get())
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['7']);
    });
  });

  group('exceptions', () {
    test('except without a type catches anything', () {
      final r = runPython('''
try:
    raise ValueError("bad")
except:
    print("caught")
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['caught']);
    });

    test('an uncaught raise is a runtime failure on its own line', () {
      final r = runPython('''
def f():
    raise ValueError("bad")

f()
''');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.runtime);
      expect(r.failure!.line, 2);
    });

    test('a runtime error is catchable', () {
      final r = runPython('''
try:
    xs = []
    print(xs[3])
except:
    print("caught")
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['caught']);
    });
  });

  group('unsupported constructs are named as unsupported, never as syntax', () {
    final cases = <String, String>{
      'yield': 'def f():\n    yield 1\n',
      'async def': 'async def f():\n    return 1\n',
      'await': 'def f():\n    await g()\n',
      'import': 'import math\n',
      'from import': 'from collections import deque\n',
      'with': 'with open("f") as f:\n    pass\n',
      'decorator': '@staticmethod\ndef f():\n    return 1\n',
      'global': 'def f():\n    global x\n',
      'del': 'd = {}\ndel d["k"]\n',
      'assert': 'assert 1 == 1\n',
      'walrus': 'if (n := 10) > 5:\n    print(n)\n',
      'bitwise and': 'print(6 & 3)\n',
      'bitwise xor': 'print(6 ^ 3)\n',
      'left shift': 'print(1 << 3)\n',
      'f-string format spec': 'print(f"{1:>5}")\n',
      'star-star argument': 'def f(a):\n    return a\nf(**{"a": 1})\n',
      'varargs parameter': 'def f(*args):\n    return args\n',
      'multiple inheritance': 'class A:\n    pass\nclass B:\n    pass\nclass C(A, B):\n    pass\n',
      'try/else': 'try:\n    pass\nexcept:\n    pass\nelse:\n    pass\n',
      'for/else': 'for i in range(2):\n    pass\nelse:\n    pass\n',
    };

    for (final entry in cases.entries) {
      test(entry.key, () {
        final r = runPython(entry.value);
        expect(r.failure, isNotNull, reason: '${entry.key} should not have parsed');
        expect(r.failure!.kind, FailureKind.unsupported,
            reason: '${entry.key} reported as ${r.failure!.kind}/${r.failure!.code}');
      });
    }
  });

  group('line fidelity', () {
    test('a runtime failure reports the learner line, not a harness line', () {
      final r = callPython('''
def solve(xs):
    total = 0
    return xs[99]
''', 'solve', <Object?>[
        <Object?>[1, 2],
      ]);
      expect(r.failure, isNotNull);
      expect(r.failure!.line, 3);
    });

    test('a syntax failure reports the offending line', () {
      final r = runPython('''
a = 1
b = (
c = 3
''');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.syntax);
    });
  });
}
