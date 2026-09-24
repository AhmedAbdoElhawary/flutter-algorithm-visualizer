// Shared plumbing for the Python frontend tests: parse, compile and run a
// snippet of Python the same way `ProblemRunner` does, and hand the result
// back as ordinary Dart values so assertions read as plain literals.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/compile/compiler.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/python/python_harness.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/value.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/budget.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/vm.dart';

class PyResult {
  const PyResult({this.value, this.stdout = const <String>[], this.failure});
  final Object? value;
  final List<String> stdout;
  final Failure? failure;

  @override
  String toString() => 'PyResult(value: $value, stdout: $stdout, failure: $failure)';
}

/// Runs [source] as a whole program and reports what it returned, printed, or
/// failed with. A parse failure comes back as a [Failure] too, so a test can
/// assert on classification without catching anything.
PyResult runPython(String source, {Duration timeout = const Duration(seconds: 5)}) {
  final frontend = PythonFrontend();
  try {
    final program = frontend.parse(source);
    final script = Compiler().compileProgram(program);
    final vm = Vm(dialect: frontend.dialect, budget: const ExecutionBudget());
    frontend.globals.forEach(vm.defineGlobal);
    final result = vm.run(script, timeout: timeout);
    return PyResult(
      value: result.returned == null ? null : plain(result.returned!),
      stdout: result.stdout,
      failure: result.failure,
    );
  } on FrontendFailure catch (f) {
    return PyResult(failure: f.toFailure());
  }
}

/// Runs [source] and then calls [functionName] with [args], the way a graded
/// test case does — through `buildHarness`, so harness lines are synthetic.
PyResult callPython(String source, String functionName, List<Object?> args) {
  final frontend = PythonFrontend();
  try {
    final program = frontend.buildHarness(
      userProgram: frontend.parse(source),
      functionName: functionName,
      arguments: <Value>[for (final a in args) toValue(a)],
      preludeSources: const <String>[],
    );
    final script = Compiler().compileProgram(program);
    final vm = Vm(dialect: frontend.dialect, budget: const ExecutionBudget());
    frontend.globals.forEach(vm.defineGlobal);
    final result = vm.run(script, timeout: const Duration(seconds: 5));
    return PyResult(
      value: result.returned == null ? null : plain(result.returned!),
      stdout: result.stdout,
      failure: result.failure,
    );
  } on FrontendFailure catch (f) {
    return PyResult(failure: f.toFailure());
  }
}

Value toValue(Object? v) => switch (v) {
      null => NullValue.instance,
      final int i => IntValue(i),
      final double d => NumValue(d),
      final bool b => BoolValue(b),
      final String s => StrValue(s),
      final List<Object?> l => ListValue(<Value>[for (final e in l) toValue(e)]),
      final Map<Object?, Object?> m => MapValue()
        ..entries.addAll(<Value, Value>{for (final e in m.entries) toValue(e.key): toValue(e.value)}),
      _ => throw ArgumentError('no Value for $v'),
    };

Object? plain(Value v) => switch (v) {
      IntValue(:final value) => value,
      NumValue(:final value) => value,
      BoolValue(:final value) => value,
      StrValue(:final value) => value,
      NullValue() => null,
      UndefinedValue() => 'undefined',
      ListValue(:final items) => <Object?>[for (final i in items) plain(i)],
      TupleValue(:final items) => <Object?>[for (final i in items) plain(i)],
      SetValue(:final items) => <Object?>{for (final i in items) plain(i)},
      MapValue(:final entries) => <Object?, Object?>{
          for (final e in entries.entries) plain(e.key): plain(e.value),
        },
      _ => v,
    };
