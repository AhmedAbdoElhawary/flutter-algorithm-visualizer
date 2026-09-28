import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/frontend.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/engine.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/isolate_engine.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/value.dart';
import 'package:flutter_test/flutter_test.dart';

import 'engine_run_support.dart';

void main() {
  late IsolateExecutionEngine engine;

  setUp(() => engine = IsolateExecutionEngine());
  tearDown(() => engine.dispose());

  test('runs a solution in the background and hands back its answer and its prints', () async {
    final outcome = await engine.run(addRequest(2, 3));

    expect(outcome.failure, isNull);
    expect((outcome.returned! as IntValue).value, 5);
    expect(outcome.stdout, ['2']);
  });

  test('one worker serves run after run', () async {
    final results = [for (var i = 0; i < 3; i++) await engine.run(addRequest(i, 1))];

    expect(results.map((r) => (r.returned! as IntValue).value), [1, 2, 3]);
  });

  test('two runs asked for at once both finish', () async {
    final both = await Future.wait([engine.run(addRequest(1, 1)), engine.run(addRequest(2, 2))]);

    expect(both.map((r) => (r.returned! as IntValue).value), [2, 4]);
  });

  test('a syntax error comes back as a failure with its line', () async {
    final outcome = await engine.run(
      const RunRequest(language: EditorLanguage.dart, source: 'int add(int a) {', functionName: 'add'),
    );

    expect(outcome.failure?.kind, FailureKind.syntax);
    expect(outcome.returned, isNull);
  });

  test('a run that throws comes back as a runtime failure', () async {
    final outcome = await engine.run(
      const RunRequest(
        language: EditorLanguage.dart,
        source: 'int boom() {\n  return [1][5];\n}',
        functionName: 'boom',
      ),
    );

    expect(outcome.failure?.kind, FailureKind.runtime);
    expect(outcome.failure?.line, 2);
  });
}
