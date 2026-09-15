// Every construct the frontend contract requires of the JavaScript frontend,
// the JavaScript-specific semantics the dialect promises, and the constructs
// that must come back as `unsupported` rather than `syntax` (SC-009).

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

import 'javascript_support.dart';

/// Evaluates one JavaScript expression and returns how it prints.
String value(String expression) {
  final r = runJs('console.log($expression);\n');
  expect(r.failure, isNull, reason: 'evaluating `$expression`: ${r.failure}');
  return r.stdout.single;
}

void main() {
  group('automatic semicolon insertion', () {
    test('statements without semicolons parse', () {
      final r = runJs('''
let a = 1
let b = 2
console.log(a + b)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3']);
    });

    test('semicolons are still allowed', () {
      final r = runJs('let a = 1; let b = 2; console.log(a + b);');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3']);
    });

    test('an expression may span lines when it cannot have ended', () {
      final r = runJs('''
let total = 1 +
    2 +
    3
console.log(total)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['6']);
    });

    test('return followed by a line break returns nothing, as the standard says', () {
      final r = runJs('''
function f() {
  return
  5
}
console.log(f())
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['null']);
    });

    test('a block comment spanning lines separates statements', () {
      final r = runJs('''
let a = 1 /* a
comment */
let b = 2
console.log(a + b)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3']);
    });
  });

  group('the dialect divergences, each asserted on its own', () {
    test('== coerces across types while === does not', () {
      expect(value('1 == "1"'), 'true');
      expect(value('1 === "1"'), 'false');
      expect(value('0 == false'), 'true');
      expect(value('0 === false'), 'false');
      expect(value('1 != "1"'), 'false');
      expect(value('1 !== "1"'), 'true');
    });

    test('null and undefined are loosely equal but strictly distinct', () {
      expect(value('null == undefined'), 'true');
      expect(value('null === undefined'), 'false');
      expect(value('typeof undefined'), 'undefined');
    });

    test('the default sort is lexicographic, not numeric', () {
      expect(value('[10, 9, 1].sort()'), '[1, 10, 9]');
      expect(value('[10, 9, 1].sort((a, b) => a - b)'), '[1, 9, 10]');
    });

    test('there is one number type, so a whole result prints whole', () {
      expect(value('4 / 2'), '2');
      expect(value('5 / 2'), '2.5');
      expect(value('1 + 1'), '2');
    });

    test('empty collections are truthy, unlike in Python', () {
      final r = runJs('''
if ([]) { console.log("array truthy") }
if ({}) { console.log("object truthy") }
if (!0) { console.log("zero falsy") }
if (!"") { console.log("empty string falsy") }
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout,
          <String>['array truthy', 'object truthy', 'zero falsy', 'empty string falsy']);
    });

    test('NaN is falsy', () {
      final r = runJs('if (!NaN) { console.log("nan falsy") }');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['nan falsy']);
    });

    test('a negative index is undefined rather than counting from the end', () {
      expect(value('[1, 2, 3][-1]'), 'undefined');
      expect(value('[1, 2, 3].at(-1)'), '3');
    });

    test('booleans and null print in JavaScript spelling', () {
      expect(value('true'), 'true');
      expect(value('null'), 'null');
    });
  });

  group('declarations and scope', () {
    test('let, const and var', () {
      final r = runJs('''
let a = 1
const b = 2
var c = 3
console.log(a + b + c)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['6']);
    });

    test('several declarators in one statement', () {
      final r = runJs('let a = 1, b = 2\nconsole.log(a + b)');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3']);
    });

    test('array destructuring', () {
      final r = runJs('''
const [a, b] = [1, 2]
console.log(a + b)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3']);
    });

    test('object destructuring', () {
      final r = runJs('''
const { x, y } = { x: 4, y: 5 }
console.log(x + y)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['9']);
    });
  });

  group('functions', () {
    test('declarations, expressions and arrows', () {
      final r = runJs('''
function add(a, b) { return a + b }
const sub = function (a, b) { return a - b }
const mul = (a, b) => a * b
const negate = x => -x
console.log(add(2, 3))
console.log(sub(5, 2))
console.log(mul(2, 3))
console.log(negate(4))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['5', '3', '6', '-4']);
    });

    test('an arrow with a block body needs an explicit return', () {
      expect(value('((x) => { return x * 2 })(3)'), '6');
    });

    test('default parameters', () {
      final r = runJs('''
function greet(name, greeting = "hi") { return greeting + " " + name }
console.log(greet("a"))
console.log(greet("a", "yo"))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['hi a', 'yo a']);
    });

    test('closures capture enclosing variables', () {
      final r = runJs('''
function counter() {
  let n = 0
  return () => { n = n + 1; return n }
}
const c = counter()
c()
console.log(c())
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['2']);
    });

    test('spread arguments', () {
      final r = runJs('''
const xs = [3, 7, 2]
console.log(Math.max(...xs))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['7']);
    });

    test('recursion', () {
      final r = callJs('''
function fib(n) {
  if (n < 2) return n
  return fib(n - 1) + fib(n - 2)
}
''', 'fib', <Object?>[15]);
      expect(r.failure, isNull, reason: '$r');
      expect(r.value, 610);
    });
  });

  group('increment and decrement', () {
    test('a for-loop increment works', () {
      final r = runJs('''
let total = 0
for (let i = 0; i < 4; i++) { total += i }
console.log(total)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['6']);
    });

    test('postfix as a statement steps by one', () {
      final r = runJs('let i = 5\ni++\nconsole.log(i)');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['6']);
    });

    test('postfix used as a value yields the number from before the step', () {
      final r = runJs('''
let i = 5
const seen = i++
console.log(seen)
console.log(i)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['5', '6']);
    });

    test('prefix used as a value yields the number after the step', () {
      final r = runJs('''
let i = 5
const seen = ++i
console.log(seen)
console.log(i)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['6', '6']);
    });

    test('postfix on an array element reads the old value', () {
      final r = runJs('''
const xs = [0, 0, 0]
let i = 0
xs[i++] = 9
console.log(xs)
console.log(i)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[9, 0, 0]', '1']);
    });

    test('decrement', () {
      final r = runJs('let i = 5\ni--\nconsole.log(i)');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['4']);
    });
  });

  group('control flow', () {
    test('if/else if/else', () {
      final r = runJs('''
function classify(n) {
  if (n > 10) return "big"
  else if (n > 5) return "medium"
  else return "small"
}
console.log(classify(20))
console.log(classify(7))
console.log(classify(1))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['big', 'medium', 'small']);
    });

    test('while with break and continue', () {
      final r = runJs('''
let i = 0
const out = []
while (true) {
  i++
  if (i % 2 === 0) continue
  if (i > 7) break
  out.push(i)
}
console.log(out)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[1, 3, 5, 7]']);
    });

    test('do/while runs its body before testing', () {
      final r = runJs('''
let n = 100
let runs = 0
do { runs++ } while (n < 10)
console.log(runs)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['1']);
    });

    test('for...of walks the elements', () {
      final r = runJs('''
let total = 0
for (const x of [1, 2, 3]) { total += x }
console.log(total)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['6']);
    });

    test('for...in walks the keys of an object', () {
      final r = runJs('''
const o = { a: 1, b: 2 }
const keys = []
for (const k in o) { keys.push(k) }
console.log(keys)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[a, b]']);
    });

    test('for...of over destructured pairs', () {
      final r = runJs('''
for (const [k, v] of [[1, 2], [3, 4]]) { console.log(k + v) }
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3', '7']);
    });
  });

  group('objects and arrays', () {
    test('an object literal reads back by dot and by bracket', () {
      final r = runJs('''
const o = { name: "a", count: 2 }
console.log(o.name)
console.log(o["count"])
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['a', '2']);
    });

    test('property shorthand and assignment', () {
      final r = runJs('''
const name = "x"
const o = { name }
o.extra = 7
console.log(o.name)
console.log(o.extra)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['x', '7']);
    });

    test('a computed key', () {
      final r = runJs('''
const k = "dynamic"
const o = { [k]: 1 }
console.log(o.dynamic)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['1']);
    });

    test('Object.keys, values and entries', () {
      final r = runJs('''
const o = { a: 1, b: 2 }
console.log(Object.keys(o))
console.log(Object.values(o))
console.log(Object.entries(o))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[a, b]', '[1, 2]', '[[a, 1], [b, 2]]']);
    });

    test('array spread copies rather than aliases', () {
      final r = runJs('''
const a = [1, 2]
const b = [...a, 3]
b[0] = 9
console.log(a)
console.log(b)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[1, 2]', '[9, 2, 3]']);
    });

    test('push, pop, shift and unshift', () {
      final r = runJs('''
const xs = [2]
xs.push(3)
xs.unshift(1)
console.log(xs)
console.log(xs.pop())
console.log(xs.shift())
console.log(xs)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[1, 2, 3]', '3', '1', '[2]']);
    });

    test('slice clamps and accepts negatives; splice mutates', () {
      final r = runJs('''
console.log([1, 2, 3, 4].slice(1, 3))
console.log([1, 2, 3, 4].slice(-2))
const xs = [1, 2, 3, 4]
console.log(xs.splice(1, 2))
console.log(xs)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['[2, 3]', '[3, 4]', '[2, 3]', '[1, 4]']);
    });

    test('map, filter and reduce', () {
      expect(value('[1, 2, 3].map(x => x * 2)'), '[2, 4, 6]');
      expect(value('[1, 2, 3].filter(x => x > 1)'), '[2, 3]');
      expect(value('[1, 2, 3].reduce((a, b) => a + b, 0)'), '6');
      expect(value('[1, 2, 3].reduce((a, b) => a + b)'), '6');
    });

    test('a callback may declare fewer parameters than JavaScript passes', () {
      // JavaScript calls the callback with (element, index, array); declaring
      // one parameter is the overwhelmingly common case and must not be an
      // argument-count error.
      expect(value('[1, 2].map(x => x + 1)'), '[2, 3]');
      expect(value('[1, 2].map((x, i) => x + i)'), '[1, 3]');
    });

    test('find, findIndex, some, every and includes', () {
      expect(value('[1, 2, 3].find(x => x > 1)'), '2');
      expect(value('[1, 2, 3].findIndex(x => x > 1)'), '1');
      expect(value('[1, 2].some(x => x > 1)'), 'true');
      expect(value('[1, 2].every(x => x > 1)'), 'false');
      expect(value('[1, 2].includes(2)'), 'true');
    });

    test('join defaults to a comma', () {
      expect(value('[1, 2].join()'), '1,2');
      expect(value('[1, 2].join("-")'), '1-2');
    });

    test('concat, reverse, flat and fill', () {
      expect(value('[1].concat([2, 3])'), '[1, 2, 3]');
      expect(value('[1, 2].reverse()'), '[2, 1]');
      expect(value('[1, [2, [3]]].flat()'), '[1, 2, [3]]');
      expect(value('new Array(3).fill(0)'), '[0, 0, 0]');
    });

    test('forEach runs for its effect', () {
      final r = runJs('[1, 2].forEach(x => console.log(x))');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['1', '2']);
    });
  });

  group('strings', () {
    test('indexing, length and at', () {
      expect(value('"abc"[1]'), 'b');
      expect(value('"abc".length'), '3');
      expect(value('"abc".at(-1)'), 'c');
    });

    test('a template literal interpolates', () {
      final r = runJs('''
const name = "world"
console.log(`hello \${name}, \${1 + 1}`)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['hello world, 2']);
    });

    test('case, trim, split and join round-trip', () {
      expect(value('"  Ab  ".trim().toLowerCase()'), 'ab');
      expect(value('"a,b".split(",")'), '[a, b]');
      expect(value('"abc".split("")'), '[a, b, c]');
    });

    test('replace changes the first, replaceAll every one', () {
      expect(value('"aXbXc".replace("X", "-")'), 'a-bXc');
      expect(value('"aXbXc".replaceAll("X", "-")'), 'a-b-c');
    });

    test('substring swaps reversed bounds; slice does not', () {
      expect(value('"hello".substring(3, 1)'), 'el');
      expect(value('"hello".slice(1, 3)'), 'el');
      expect(value('"hello".slice(-3)'), 'llo');
    });

    test('indexOf, includes, startsWith and endsWith', () {
      expect(value('"hello".indexOf("l")'), '2');
      expect(value('"hello".includes("ell")'), 'true');
      expect(value('"hello".startsWith("he")'), 'true');
      expect(value('"hello".endsWith("lo")'), 'true');
    });

    test('charCodeAt, fromCharCode, repeat and padStart', () {
      expect(value('String.fromCharCode("a".charCodeAt(0) + 1)'), 'b');
      expect(value('"ab".repeat(2)'), 'abab');
      expect(value('"5".padStart(3, "0")'), '005');
    });
  });

  group('Map and Set', () {
    test('a Map holds and reports its entries', () {
      final r = runJs('''
const m = new Map()
m.set("a", 1)
m.set("b", 2)
console.log(m.get("a"))
console.log(m.has("b"))
console.log(m.size)
m.delete("a")
console.log(m.size)
console.log(m.get("gone"))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['1', 'true', '2', '1', 'undefined']);
    });

    test('a Set dedupes', () {
      final r = runJs('''
const s = new Set([1, 2, 2, 3])
console.log(s.size)
console.log(s.has(2))
s.add(4)
s.delete(1)
console.log([...s])
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['3', 'true', '[2, 3, 4]']);
    });

    test('a Map built from pairs', () {
      final r = runJs('''
const m = new Map([["a", 1]])
console.log(m.get("a"))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['1']);
    });
  });

  group('classes', () {
    test('a class with a constructor and methods', () {
      final r = runJs('''
class Stack {
  constructor() { this.items = [] }
  push(x) { this.items.push(x) }
  pop() { return this.items.pop() }
  get size() { return this.items.length }
}
const s = new Stack()
s.push(1)
s.push(2)
console.log(s.pop())
console.log(s.items.length)
''');
      // `get size()` is an accessor, which is out of scope — the point of the
      // test is that it says so rather than misbehaving.
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.unsupported);
    });

    test('a class without accessors works end to end', () {
      final r = runJs('''
class Stack {
  constructor() { this.items = [] }
  push(x) { this.items.push(x) }
  pop() { return this.items.pop() }
  size() { return this.items.length }
}
const s = new Stack()
s.push(1)
s.push(2)
console.log(s.pop())
console.log(s.size())
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['2', '1']);
    });

    test('extends and super', () {
      final r = runJs('''
class Animal {
  constructor(name) { this.name = name }
  speak() { return "..." }
  describe() { return this.name + " says " + this.speak() }
}
class Dog extends Animal {
  constructor(name) { super(name) }
  speak() { return "woof" }
}
console.log(new Dog("rex").describe())
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['rex says woof']);
    });

    test('a learner method keeps its name against a builtin of the same name', () {
      final r = runJs('''
class Bag {
  constructor() { this.data = [] }
  push(x) { this.data.push(x); return "mine" }
  map(f) { return "also mine" }
}
const b = new Bag()
console.log(b.push(1))
console.log(b.map(x => x))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['mine', 'also mine']);
    });
  });

  group('exceptions', () {
    test('throw and catch', () {
      final r = runJs('''
function risky(n) {
  try {
    if (n < 0) throw new Error("negative")
    return "ok"
  } catch (e) {
    return "caught"
  } finally {
    console.log("done")
  }
}
console.log(risky(-1))
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['done', 'caught']);
    });

    test('an uncaught throw is a runtime failure on its own line', () {
      final r = runJs('''
function f() {
  throw new Error("bad")
}
f()
''');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.runtime);
      expect(r.failure!.line, 2);
    });
  });

  group('optional chaining and nullish coalescing', () {
    test('?. on a null receiver is null rather than an error', () {
      final r = runJs('''
const o = null
console.log(o?.name)
''');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['null']);
    });

    test('?? falls back only for null', () {
      expect(value('null ?? "fallback"'), 'fallback');
      expect(value('0 ?? "fallback"'), '0');
    });
  });

  group('builtins', () {
    test('Math', () {
      expect(value('Math.max(1, 5, 3)'), '5');
      expect(value('Math.min(1, 5, 3)'), '1');
      expect(value('Math.abs(-3)'), '3');
      expect(value('Math.floor(2.7)'), '2');
      expect(value('Math.ceil(2.1)'), '3');
      expect(value('Math.round(2.5)'), '3');
      expect(value('Math.sqrt(9)'), '3');
      expect(value('Math.pow(2, 10)'), '1024');
    });

    test('exponent operator', () {
      expect(value('2 ** 10'), '1024');
    });

    test('parseInt and parseFloat read a prefix', () {
      expect(value('parseInt("42px")'), '42');
      expect(value('parseFloat("3.5rem")'), '3.5');
      expect(value('Number.isInteger(4)'), 'true');
    });

    test('Array.isArray and Array.from', () {
      expect(value('Array.isArray([])'), 'true');
      expect(value('Array.isArray("no")'), 'false');
      expect(value('Array.from("abc")'), '[a, b, c]');
    });

    test('typeof', () {
      expect(value('typeof 1'), 'number');
      expect(value('typeof "a"'), 'string');
      expect(value('typeof true'), 'boolean');
      expect(value('typeof []'), 'object');
      expect(value('typeof (x => x)'), 'function');
    });
  });

  group('unsupported constructs are named as unsupported, never as syntax', () {
    final cases = <String, String>{
      'async function': 'async function f() { return 1 }\n',
      'await': 'function f() { await g() }\n',
      'generator': 'function* f() { yield 1 }\n',
      'yield': 'function f() { yield 1 }\n',
      'switch': 'switch (1) { case 1: break }\n',
      'import': 'import x from "y"\n',
      'export': 'export const x = 1\n',
      'bitwise and': 'console.log(6 & 3)\n',
      'bitwise xor': 'console.log(6 ^ 3)\n',
      'left shift': 'console.log(1 << 3)\n',
      'bitwise not': 'console.log(~5)\n',
      'instanceof': 'console.log([] instanceof Array)\n',
      'delete': 'const o = {}\ndelete o.x\n',
      'rest parameter': 'function f(...rest) { return rest }\n',
      'object spread': 'const a = {}\nconst b = { ...a }\n',
      'class field': 'class A { count = 0 }\n',
      'getter': 'class A { get x() { return 1 } }\n',
      'static member': 'class A { static make() { return 1 } }\n',
      'logical assignment': 'let a = null\na ??= 1\n',
      'labelled optional call': 'const f = null\nf?.()\n',
    };

    for (final entry in cases.entries) {
      test(entry.key, () {
        final r = runJs(entry.value);
        expect(r.failure, isNotNull, reason: '${entry.key} should not have parsed');
        expect(r.failure!.kind, FailureKind.unsupported,
            reason: '${entry.key} reported as ${r.failure!.kind}/${r.failure!.code}');
      });
    }
  });

  group('hostile input is classified, never a crash', () {
    test('empty source', () {
      expect(runJs('').failure, isNull);
    });

    test('whitespace and comments only', () {
      expect(runJs('  \n// a comment\n/* another */\n').failure, isNull);
    });

    test('an unterminated string', () {
      final r = runJs('const s = "oops\n');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.syntax);
    });

    test('an unclosed brace', () {
      final r = runJs('function f() {\n');
      expect(r.failure, isNotNull);
      expect(r.failure!.kind, FailureKind.syntax);
    });

    test('a very long line', () {
      final r = runJs('console.log(${List<int>.filled(2000, 1).join(' + ')})\n');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['2000']);
    });

    test('a deeply nested expression', () {
      final r = runJs('console.log(${'(' * 200}1${')' * 200})\n');
      expect(r.failure, isNull, reason: '$r');
      expect(r.stdout, <String>['1']);
    });
  });

  group('line fidelity', () {
    test('a runtime failure reports the learner line, not a harness line', () {
      final r = callJs('''
function solve(xs) {
  let total = 0
  return xs[0].missing.deep
}
''', 'solve', <Object?>[
        <Object?>[1, 2],
      ]);
      expect(r.failure, isNotNull);
      expect(r.failure!.line, 3);
    });
  });
}
