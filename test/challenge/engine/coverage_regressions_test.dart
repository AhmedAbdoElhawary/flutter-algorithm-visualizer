// The bugs found by writing a verified Python and JavaScript solution for
// every gradable problem (`test/challenge/grading/language_coverage_test.dart`).
//
// Each one is here rather than in a language's own suite because each was a
// *shared* defect: `continue` in a `for…in` loop spun forever in all three
// languages, and the number-typing gaps are the VM's, not one frontend's.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/compile/compiler.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/dart/dart_harness.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/budget.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/vm.dart';
import 'package:flutter_test/flutter_test.dart';

import 'javascript_support.dart';
import 'python_support.dart';

VmResult runDart(String source) {
  final frontend = DartFrontend();
  final script = Compiler().compileProgram(frontend.parse(source));
  return Vm(dialect: frontend.dialect, budget: const ExecutionBudget())
      .run(script, timeout: const Duration(seconds: 5));
}

void main() {
  group('continue inside a for-in loop advances the cursor', () {
    // The loop desugars to a hidden cursor over the iterable. `continue` used
    // to jump to the condition check *before* the increment, so the cursor
    // never moved and the loop ran until the time budget killed it — which
    // surfaces to the learner as "this ran for too long", blaming their
    // algorithm for an engine bug.
    test('Python', () {
      final r = runPython('''
out = []
for i in range(5):
    if i == 2:
        continue
    out.append(i)
return out
''');
      expect(r.failure, isNull);
      expect(r.value, <int>[0, 1, 3, 4]);
    });

    test('JavaScript', () {
      final r = runJs('''
const out = []
for (const i of [0, 1, 2, 3, 4]) {
  if (i === 2) continue
  out.push(i)
}
return out
''');
      expect(r.failure, isNull);
      expect(r.value, <int>[0, 1, 3, 4]);
    });

    test('Dart', () {
      final r = runDart('''
void main() {
  final out = <int>[];
  for (final i in [0, 1, 2, 3, 4]) {
    if (i == 2) continue;
    out.add(i);
  }
  print(out);
}
''');
      expect(r.failure, isNull);
      expect(r.stdout, <String>['[0, 1, 3, 4]']);
    });

    test('continue in a nested for-in leaves the outer loop alone', () {
      final r = runPython('''
pairs = []
for a in [1, 2]:
    for b in [1, 2, 3]:
        if b == 2:
            continue
        pairs.append([a, b])
return pairs
''');
      expect(r.failure, isNull);
      expect(r.value, <List<int>>[
        <int>[1, 1],
        <int>[1, 3],
        <int>[2, 1],
        <int>[2, 3],
      ]);
    });
  });

  group('Python unpacking assigns to subscripts, not just names', () {
    test('the in-place swap every sort writes', () {
      final r = runPython('''
nums = [3, 1, 2]
nums[0], nums[2] = nums[2], nums[0]
return nums
''');
      expect(r.failure, isNull);
      expect(r.value, <int>[2, 1, 3]);
    });

    test('the right-hand side is built before any target is written', () {
      // If the targets were assigned as the values were read, this would
      // produce [1, 1] rather than a real swap.
      final r = runPython('''
a = [1, 2]
i = 0
j = 1
a[i], a[j] = a[j], a[i]
return a
''');
      expect(r.failure, isNull);
      expect(r.value, <int>[2, 1]);
    });

    test('a plain-name swap still works', () {
      final r = runPython('''
a = 1
b = 2
a, b = b, a
return [a, b]
''');
      expect(r.failure, isNull);
      expect(r.value, <int>[2, 1]);
    });

    test('attribute targets unpack too', () {
      final r = runPython('''
class Point:
    def __init__(self):
        self.x = 1
        self.y = 2

p = Point()
p.x, p.y = p.y, p.x
return [p.x, p.y]
''');
      expect(r.failure, isNull);
      expect(r.value, <int>[2, 1]);
    });
  });

  group('JavaScript has one number type', () {
    test('a whole quotient indexes like an integer', () {
      final r = runJs('''
const xs = [10, 20, 30, 40]
return xs[4 / 2]
''');
      expect(r.failure, isNull);
      expect(r.value, 30);
    });

    test('a whole quotient sizes an Array', () {
      final r = runJs('''
const total = 10
return new Array(total / 2).fill(0).length
''');
      expect(r.failure, isNull);
      expect(r.value, 5);
    });

    test('a fractional index is still an error', () {
      final r = runJs('''
const xs = [1, 2, 3]
xs[1.5] = 9
return xs
''');
      expect(r.failure?.kind, FailureKind.runtime);
    });

    test('Python rejects a float index, since Python does', () {
      final r = runPython('''
xs = [1, 2, 3]
return xs[4 / 2]
''');
      expect(r.failure?.kind, FailureKind.runtime);
    });
  });

  test('JavaScript destructuring assignment is reported as unsupported, not a typo', () {
    // `[a, b] = [b, a]` is valid JavaScript the engine does not lower. Calling
    // it a syntax error would send the learner hunting for a mistake they did
    // not make (SC-009).
    final r = runJs('''
let a = 1
let b = 2
;[a, b] = [b, a]
return [a, b]
''');
    expect(r.failure?.kind, FailureKind.unsupported);
  });
}
