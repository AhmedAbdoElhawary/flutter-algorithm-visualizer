/// Web fallback driver — there is no `Isolate.spawn` on web (Risk R4), so
/// this runs the same `Vm` directly on the calling isolate.
///
/// Because there is no isolate boundary, [CancellationToken] works exactly
/// as intended: [Vm] polls `token.isCancelled` directly (no message-passing
/// involved), so cancellation is both immediate and clean — no kill, no
/// worker to replace.
///
/// **Known gap** (tracked for a later pass, not silently assumed away): a
/// single test-case run still executes as one synchronous call on the
/// calling isolate. `Vm`'s own wall-clock check bounds *how long* it can run
/// (`budget.perTestCaseTimeout`), so a hostile program cannot hang the page
/// forever, but the page's main thread — and therefore the UI — is not free
/// to repaint *during* that bounded window the way `contracts/
/// execution-contract.md` G1 describes for the isolate driver. Making this
/// driver truly cooperative (yielding to the event loop between instruction
/// batches, the way research.md decision 4 describes) needs `Vm`'s dispatch
/// loop to become `async`, which is a larger change deferred past this pass.
library;

import 'dart:async';

import '../errors/failure.dart';
import 'engine.dart';
import 'worker.dart';

class SlicedExecutionEngine implements ExecutionEngine {
  @override
  Future<RunOutcome> run(RunRequest request, {CancellationToken? token}) async {
    final stopwatch = Stopwatch()..start();
    final encoded = <String, Object?>{
      'language': request.language.name,
      'source': request.source,
      'functionName': request.functionName,
      'arguments': request.arguments.map(encodeValue).toList(),
      'preludeSources': request.preludeSources,
      'budget': encodeBudget(request.budget),
    };
    final result = executeEncodedRequest(encoded, () => token?.isCancelled ?? false);
    stopwatch.stop();

    final failureMap = result['failure'] as Map<String, Object?>?;
    return RunOutcome(
      returned: result['returned'] == null ? null : decodeValue(result['returned']),
      stdout: (result['stdout']! as List<Object?>).cast<String>(),
      truncated: result['truncated']! as bool,
      failure: failureMap == null
          ? null
          : Failure(
              kind: FailureKind.values.byName(failureMap['kind']! as String),
              code: failureMap['code']! as String,
              data: (failureMap['data']! as Map<String, Object?>),
              line: failureMap['line']! as int,
              partialOutput: (failureMap['partialOutput']! as List<Object?>).cast<String>(),
            ),
      elapsed: stopwatch.elapsed,
    );
  }
}
