// Runs a snippet in any of the three languages the way `ProblemRunner` does, so the stdlib and
// value tests can say what a learner would write instead of hand-building Core IR.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/compile/compiler.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/language_registry.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/budget.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/vm.dart';

import 'frontend/python/python_support.dart' show PyResult, plain, toValue;

/// Runs [source] as a whole program in [language].
PyResult runIn(EditorLanguage language, String source) {
  final frontend = frontendFor(language);
  try {
    final script = Compiler().compileProgram(frontend.parse(source));
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

/// What a Dart snippet returns, failing the test if it fails instead.
Object? dart(String body) {
  final result = runIn(EditorLanguage.dart, body);
  if (result.failure != null) throw StateError('$body\n→ ${result.failure}');
  return result.value;
}

/// The failure code a Dart snippet stops with.
String? dartFailure(String body) => runIn(EditorLanguage.dart, body).failure?.code;

/// Calls [functionName] in [source] with [args] through the language's harness, as a graded test case does.
PyResult callIn(EditorLanguage language, String source, String functionName, List<Object?> args,
    {List<String> prelude = const []}) {
  final frontend = frontendFor(language);
  try {
    final program = frontend.buildHarness(
      userProgram: frontend.parse(source),
      functionName: functionName,
      arguments: [for (final a in args) toValue(a)],
      preludeSources: prelude,
    );
    final vm = Vm(dialect: frontend.dialect, budget: const ExecutionBudget());
    frontend.globals.forEach(vm.defineGlobal);
    final result = vm.run(Compiler().compileProgram(program), timeout: const Duration(seconds: 5));
    return PyResult(
      value: result.returned == null ? null : plain(result.returned!),
      stdout: result.stdout,
      failure: result.failure,
    );
  } on FrontendFailure catch (f) {
    return PyResult(failure: f.toFailure());
  }
}
