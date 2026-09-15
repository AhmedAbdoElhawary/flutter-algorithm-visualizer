// `finally` has to run when control leaves the `try` early, not only when
// the block falls off its end. The compiler emits a `finally` body after the
// guarded code, which a `return` inside that code simply jumped over — so
// every one of these cases silently skipped its `finally`.
//
// Written against the Dart frontend deliberately: the bug was in the shared
// compiler, so it was never Python's, and the fix has to hold for whichever
// language reaches it.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/compile/compiler.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/dart/dart_harness.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/budget.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/vm.dart';
import 'package:flutter_test/flutter_test.dart';

VmResult run(String source) {
  final frontend = DartFrontend();
  final script = Compiler().compileProgram(frontend.parse(source));
  return Vm(dialect: frontend.dialect, budget: const ExecutionBudget())
      .run(script, timeout: const Duration(seconds: 5));
}

void main() {
  test('a return inside try still runs finally', () {
    final r = run('''
String f() {
  try {
    return "returned";
  } finally {
    print("finally");
  }
}
void main() { print(f()); }
''');
    expect(r.failure, isNull, reason: '${r.failure}');
    expect(r.stdout, <String>['finally', 'returned']);
  });

  test('a return inside catch still runs finally', () {
    final r = run('''
String f() {
  try {
    throw "boom";
  } catch (e) {
    return "caught";
  } finally {
    print("finally");
  }
}
void main() { print(f()); }
''');
    expect(r.failure, isNull, reason: '${r.failure}');
    expect(r.stdout, <String>['finally', 'caught']);
  });

  test('falling off the end of try still runs finally exactly once', () {
    final r = run('''
void f() {
  try {
    print("body");
  } finally {
    print("finally");
  }
}
void main() { f(); }
''');
    expect(r.failure, isNull, reason: '${r.failure}');
    expect(r.stdout, <String>['body', 'finally']);
  });

  test('nested try blocks run their finallys innermost first', () {
    final r = run('''
String f() {
  try {
    try {
      return "value";
    } finally {
      print("inner");
    }
  } finally {
    print("outer");
  }
}
void main() { print(f()); }
''');
    expect(r.failure, isNull, reason: '${r.failure}');
    expect(r.stdout, <String>['inner', 'outer', 'value']);
  });

  test('a break out of a try inside a loop runs finally', () {
    final r = run('''
void main() {
  for (var i = 0; i < 3; i++) {
    try {
      if (i == 1) break;
      print("iteration");
    } finally {
      print("finally");
    }
  }
}
''');
    expect(r.failure, isNull, reason: '${r.failure}');
    expect(r.stdout, <String>['iteration', 'finally', 'finally']);
  });

  test('a continue out of a try inside a loop runs finally each time', () {
    final r = run('''
void main() {
  for (var i = 0; i < 2; i++) {
    try {
      continue;
    } finally {
      print("finally");
    }
  }
}
''');
    expect(r.failure, isNull, reason: '${r.failure}');
    expect(r.stdout, <String>['finally', 'finally']);
  });

  test('a loop wholly inside a try does not run finally per iteration', () {
    // The `break` here leaves the loop but not the `try`, so the `finally`
    // belongs to the code after the loop, not to the break.
    final r = run('''
void main() {
  try {
    for (var i = 0; i < 5; i++) {
      if (i == 2) break;
      print("i");
    }
  } finally {
    print("finally");
  }
}
''');
    expect(r.failure, isNull, reason: '${r.failure}');
    expect(r.stdout, <String>['i', 'i', 'finally']);
  });

  test('the returned value is the one computed before finally ran', () {
    final r = run('''
int f() {
  var x = 1;
  try {
    return x;
  } finally {
    x = 99;
  }
}
void main() { print(f()); }
''');
    expect(r.failure, isNull, reason: '${r.failure}');
    expect(r.stdout, <String>['1']);
  });

  test('an uncaught throw still runs finally on its way out', () {
    final r = run('''
void f() {
  try {
    throw "boom";
  } finally {
    print("finally");
  }
}
void main() { f(); }
''');
    expect(r.failure, isNotNull);
    expect(r.failure!.partialOutput, contains('finally'));
  });
}
