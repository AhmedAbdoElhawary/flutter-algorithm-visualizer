// Every construct in the Dart section of contracts/frontend-contract.md,
// headlined by quickstart.md Step 1's six snippets — the single clearest
// signal that the rewrite delivered on the original complaint.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/compile/compiler.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/dart/dart_harness.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/budget.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/vm.dart';
import 'package:flutter_test/flutter_test.dart';

final _frontend = DartFrontend();

/// Wraps [source] in a synthetic `void main() { return <expr>; }`-shaped
/// script by relying on the frontend's own "auto-invoke main if present"
/// rule, then runs it and returns the result. Mirrors what
/// `testcase/problem_runner.dart` does (T037): build a full Dart program,
/// let the engine run it, read back the returned/printed value.
VmResult run(String source) {
  final program = _frontend.parse(source);
  final script = Compiler().compileProgram(program);
  final vm = Vm(dialect: _frontend.dialect, budget: const ExecutionBudget());
  return vm.run(script, timeout: const Duration(seconds: 5));
}

void main() {
  group('quickstart Step 1 — the original complaint, stated as a test', () {
    test('.map', () {
      final r = run('''
void main() {
  final nums = [1, 2, 3];
  print(nums.map((x) => x * 2).toList());
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['[2, 4, 6]']);
    });

    test('.where', () {
      final r = run('''
void main() {
  final nums = [1, 2, 3, 4];
  print(nums.where((x) => x > 2).toList());
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['[3, 4]']);
    });

    test('list.sort()', () {
      final r = run('''
void main() {
  final nums = [3, 1, 2];
  nums.sort();
  print(nums);
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['[1, 2, 3]']);
    });

    test('list.sort(cmp)', () {
      final r = run('''
void main() {
  final nums = [3, 1, 2];
  nums.sort((a, b) => b - a);
  print(nums);
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['[3, 2, 1]']);
    });

    test('nums.reduce((a, b) => a + b)', () {
      final r = run('''
void main() {
  final nums = [1, 2, 3, 4];
  print(nums.reduce((a, b) => a + b));
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['10']);
    });

    test('a function-typed variable: int Function(int) f = (x) => x + 1;', () {
      final r = run('''
void main() {
  int Function(int) f = (x) => x + 1;
  print(f(4));
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['5']);
    });
  });

  group('common to all three — variables, control flow, functions', () {
    test('var/final/const declarations', () {
      final r = run('''
void main() {
  var a = 1;
  final b = 2;
  const c = 3;
  print(a + b + c);
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['6']);
    });

    test('arithmetic, comparison, and logical operators', () {
      final r = run('''
void main() {
  print(2 + 3 * 4 - 1);
  print(7 ~/ 2);
  print(7 % 2);
  print(1 < 2 && 3 >= 3);
  print(1 == 2 || !false);
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['13', '3', '1', 'true', 'true']);
    });

    test('string interpolation', () {
      final r = run('''
void main() {
  final name = 'world';
  final n = 2;
  print('hello \$name, \${n + 1}');
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['hello world, 3']);
    });

    test('if/else, while, for, break, continue', () {
      final r = run('''
void main() {
  var total = 0;
  for (var i = 0; i < 10; i++) {
    if (i == 5) break;
    if (i % 2 == 0) continue;
    total += i;
  }
  var i = 0;
  while (i < 3) {
    total += i;
    i++;
  }
  print(total);
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['7']);
    });

    test('for-in over a list', () {
      final r = run('''
void main() {
  var total = 0;
  for (final x in [1, 2, 3]) {
    total += x;
  }
  print(total);
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['6']);
    });

    test('functions with parameters, return, and recursion', () {
      final r = run('''
int fib(int n) {
  if (n <= 1) return n;
  return fib(n - 1) + fib(n - 2);
}
void main() {
  print(fib(10));
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['55']);
    });

    test('closures over an outer local variable', () {
      final r = run('''
void main() {
  int threshold = 2;
  final nums = [1, 2, 3, 4];
  print(nums.where((x) => x > threshold).toList());
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['[3, 4]']);
    });

    test('lists with indexing and mutation', () {
      final r = run('''
void main() {
  final nums = [1, 2, 3];
  nums[1] = 20;
  print(nums[1]);
  print(nums.length);
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['20', '3']);
    });

    test('maps', () {
      final r = run('''
void main() {
  final m = {'a': 1, 'b': 2};
  m['c'] = 3;
  print(m['a']);
  print(m.length);
  print(m.containsKey('c'));
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['1', '3', 'true']);
    });

    test('sets', () {
      final r = run('''
void main() {
  final s = <int>{1, 2, 2, 3};
  s.add(4);
  print(s.length);
  print(s.contains(2));
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['4', 'true']);
    });

    test('classes with methods and single inheritance', () {
      final r = run('''
class Animal {
  String speak() => 'generic sound';
}
class Dog extends Animal {
  String speak() => '\${super.speak()} -> woof';
}
void main() {
  final d = Dog();
  print(d.speak());
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['generic sound -> woof']);
    });

    test('exceptions: try/catch/finally', () {
      final r = run('''
void main() {
  var log = '';
  try {
    throw Exception('boom');
  } catch (e) {
    log += 'caught;';
  } finally {
    log += 'finally;';
  }
  print(log);
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['caught;finally;']);
    });

    test('comments are ignored', () {
      final r = run('''
// a leading comment
void main() {
  /* a block
     comment */
  print(1); // trailing comment
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['1']);
    });
  });

  group('Dart additionally', () {
    test('typed declarations and List<T>/Map<K,V> literals', () {
      final r = run('''
void main() {
  List<int> nums = [1, 2, 3];
  Map<String, int> ages = {'a': 1};
  print(nums.length);
  print(ages['a']);
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['3', '1']);
    });

    test('?. and ?? are honored', () {
      final r = run('''
class Node {
  Node? next;
  int val;
}
void main() {
  Node? n;
  print(n?.val);
  print(n?.val ?? -1);
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['null', '-1']);
    });

    test('generics are parsed and ignored, never a syntax error', () {
      // Explicit call-site type arguments (`identity<int>(5)`) are a known,
      // documented gap — `<`/`>` are ambiguous with comparison operators
      // without full type information, so only declaration-site generics
      // (the actual FR-002a-adjacent requirement: never a syntax error) are
      // supported. Real Dart solutions almost always rely on inference.
      final r = run('''
T identity<T>(T x) => x;
void main() {
  print(identity(5));
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['5']);
    });

    test('a constructor using this.field shorthand, including optional bracket params', () {
      final r = run('''
class ListNode {
  int val;
  ListNode? next;
  ListNode([this.val = 0, this.next]);
}
void main() {
  final a = ListNode(5);
  final b = ListNode();
  print(a.val);
  print(b.val);
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, ['5', '0']);
    });
  });

  group('unsupported classification (SC-009) — never confused with syntax', () {
    test('async/await is unsupported, not a syntax error', () {
      expect(
        () => run('Future<int> main() async { return await Future.value(1); }'),
        throwsA(isA<FrontendFailure>().having((f) => f.kind, 'kind', FailureKind.unsupported)),
      );
    });
  });
}
