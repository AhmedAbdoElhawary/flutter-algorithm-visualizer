// Cancellation is observed between instructions and takes effect within 1
// second, at every phase (SC-005) — asserted here at the ExecutionEngine
// level (both drivers), since that's the layer the "Cancel" button talks to.

import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/frontend/frontend.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/engine.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/isolate_engine.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/sliced_engine.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/isolate/worker.dart';
import 'package:algorithm_visualizer/core/custom_packages/custom_code_editor/src/execution/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final driver in <String, ExecutionEngine Function()>{
    'isolate driver': () => IsolateExecutionEngine(),
    'sliced (web) driver': () => SlicedExecutionEngine(),
  }.entries) {
    group(driver.key, () {
      test('cancelling before the run starts reports cancelled within 1s', () async {
        final engine = driver.value();
        final token = CancellationToken()..cancel();
        final stopwatch = Stopwatch()..start();
        final outcome = await engine.run(
          const RunRequest(
              language: EditorLanguage.dart, source: stubInfiniteLoopSource, functionName: 'main'),
          token: token,
        );
        stopwatch.stop();
        expect(outcome.failure?.kind, FailureKind.cancelled);
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 1)));
      });

      if (driver.key == 'isolate driver') {
        // The sliced (web) driver runs the VM as one synchronous call with
        // no `await` before it, so — as documented on `SlicedExecutionEngine`
        // — nothing else on this isolate (including a `token.cancel()` call
        // racing against it) gets a chance to run until that call returns.
        // Mid-run cancellation is therefore only genuinely testable for the
        // isolate driver until the VM's dispatch loop itself yields
        // periodically (a documented follow-up, not silently assumed away).
        test('cancelling mid-run (an infinite loop) reports cancelled within 1s', () async {
          final engine = driver.value();
          final token = CancellationToken();
          final future = engine.run(
            const RunRequest(
                language: EditorLanguage.dart, source: stubInfiniteLoopSource, functionName: 'main'),
            token: token,
          );
          // Give the run a moment to actually start before cancelling.
          await Future<void>.delayed(const Duration(milliseconds: 20));
          final stopwatch = Stopwatch()..start();
          token.cancel();
          final outcome = await future;
          stopwatch.stop();
          expect(outcome.failure?.kind, FailureKind.cancelled);
          expect(stopwatch.elapsed, lessThan(const Duration(seconds: 1)));
        });
      }

      test('the engine is immediately usable for a normal run after a cancel', () async {
        final engine = driver.value();
        final cancelled = await engine.run(
          const RunRequest(
              language: EditorLanguage.dart, source: stubInfiniteLoopSource, functionName: 'main'),
          token: CancellationToken()..cancel(),
        );
        expect(cancelled.failure?.kind, FailureKind.cancelled);

        final outcome = await engine.run(
          const RunRequest(
              language: EditorLanguage.dart, source: stubReturnConstantSource, functionName: 'main'),
        );
        expect(outcome.failure, isNull);
      });
    });
  }
}
