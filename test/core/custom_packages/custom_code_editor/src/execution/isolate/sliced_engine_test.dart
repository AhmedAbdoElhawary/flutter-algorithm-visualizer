import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/frontend.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/engine.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/sliced_engine.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/values/value.dart';
import 'package:flutter_test/flutter_test.dart';

import 'engine_run_support.dart';

void main() {
  final engine = SlicedExecutionEngine();

  test('runs a solution on this thread and hands back its answer and its prints', () async {
    final outcome = await engine.run(addRequest(2, 3));

    expect(outcome.failure, isNull);
    expect((outcome.returned! as IntValue).value, 5);
    expect(outcome.stdout, ['2']);
    expect(outcome.truncated, isFalse);
  });

  test('a failure keeps its kind, code and line', () async {
    final outcome = await engine.run(
      const RunRequest(
        language: EditorLanguage.dart,
        source: 'int boom() {\n  return [1][5];\n}',
        functionName: 'boom',
      ),
    );

    expect(outcome.failure?.kind, FailureKind.runtime);
    expect(outcome.failure?.code, 'indexOutOfRange');
    expect(outcome.failure?.line, 2);
  });
}
