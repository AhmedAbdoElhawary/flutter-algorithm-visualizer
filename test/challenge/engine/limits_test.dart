// The 2s per-test-case cap fires and is reported as timeLimit (FR-018,
// SC-015). The "whole run" side of FR-018a — completed cases keep their
// verdicts, remaining cases report not-run rather than failed — is a
// property of whatever drives multiple ExecutionEngine.run() calls for one
// problem (ProblemRunner, wired in Phase 3/T037); this file is scoped to
// what the engine itself is responsible for: enforcing the per-case budget
// and staying usable afterward. The orchestration property is demonstrated
// here at the level this layer *can* prove it — a caller looping over test
// cases sees exactly one timed-out case and the engine still works for the
// next one.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/frontend.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/engine.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/isolate_engine.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/sliced_engine.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/worker.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/vm/budget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final driver in <String, ExecutionEngine Function()>{
    'isolate driver': () => IsolateExecutionEngine(),
    'sliced (web) driver': () => SlicedExecutionEngine(),
  }.entries) {
    group(driver.key, () {
      test('an infinite loop is stopped by the per-test-case timeout, not left to hang', () async {
        final engine = driver.value();
        final stopwatch = Stopwatch()..start();
        final outcome = await engine.run(
          const RunRequest(
            language: EditorLanguage.dart,
            source: stubInfiniteLoopSource,
            functionName: 'main',
            budget: ExecutionBudget(perTestCaseTimeout: Duration(milliseconds: 200), instructionsPerBudgetCheck: 10),
          ),
        );
        stopwatch.stop();
        expect(outcome.failure?.kind, FailureKind.timeLimit);
        // Comfortably above the 200ms budget but well short of hanging.
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
      });

      test('a run that completes well within budget is not penalized', () async {
        final engine = driver.value();
        final outcome = await engine.run(
          const RunRequest(language: EditorLanguage.dart, source: stubReturnConstantSource, functionName: 'main'),
        );
        expect(outcome.failure, isNull);
      });

      test('one timed-out case does not stop the caller from running the next one, and its result is a clean timeLimit — not a wrong-answer-looking crash', () async {
        final engine = driver.value();
        const fastBudget = ExecutionBudget();
        const tightBudget = ExecutionBudget(perTestCaseTimeout: Duration(milliseconds: 100), instructionsPerBudgetCheck: 10);

        final case1 = await engine.run(
          const RunRequest(language: EditorLanguage.dart, source: stubReturnConstantSource, functionName: 'main', budget: fastBudget),
        );
        final case2 = await engine.run(
          const RunRequest(language: EditorLanguage.dart, source: stubInfiniteLoopSource, functionName: 'main', budget: tightBudget),
        );
        final case3 = await engine.run(
          const RunRequest(language: EditorLanguage.dart, source: stubReturnConstantSource, functionName: 'main', budget: fastBudget),
        );

        expect(case1.failure, isNull, reason: 'case1 completed before the timed-out case ever ran');
        expect(case2.failure?.kind, FailureKind.timeLimit, reason: 'case2 is a runner limitation, not a wrong answer');
        expect(case3.failure, isNull, reason: 'the engine is still healthy for case3 after case2 timed out');
      });
    });
  }
}
