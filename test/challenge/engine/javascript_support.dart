// Shared plumbing for the JavaScript frontend tests: parse, compile and run a
// snippet the same way `ProblemRunner` does.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/compile/compiler.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/javascript/javascript_harness.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/value.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/budget.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/vm.dart';

import 'python_support.dart' show plain, toValue;

class JsResult {
  const JsResult({this.value, this.stdout = const <String>[], this.failure});
  final Object? value;
  final List<String> stdout;
  final Failure? failure;

  @override
  String toString() => 'JsResult(value: $value, stdout: $stdout, failure: $failure)';
}

JsResult runJs(String source) {
  final frontend = JavascriptFrontend();
  try {
    final script = Compiler().compileProgram(frontend.parse(source));
    final vm = Vm(dialect: frontend.dialect, budget: const ExecutionBudget());
    frontend.globals.forEach(vm.defineGlobal);
    final result = vm.run(script, timeout: const Duration(seconds: 5));
    return JsResult(
      value: result.returned == null ? null : plain(result.returned!),
      stdout: result.stdout,
      failure: result.failure,
    );
  } on FrontendFailure catch (f) {
    return JsResult(failure: f.toFailure());
  }
}

/// Runs [source] and then calls [functionName] with [args], the way a graded
/// test case does.
JsResult callJs(String source, String functionName, List<Object?> args) {
  final frontend = JavascriptFrontend();
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
    return JsResult(
      value: result.returned == null ? null : plain(result.returned!),
      stdout: result.stdout,
      failure: result.failure,
    );
  } on FrontendFailure catch (f) {
    return JsResult(failure: f.toFailure());
  }
}
