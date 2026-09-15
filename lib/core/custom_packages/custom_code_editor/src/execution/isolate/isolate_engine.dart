/// The reused long-lived worker isolate driver (mobile/desktop). One
/// isolate is spawned lazily and reused across runs (G8, SC-006) — never
/// spawned per run, since ~20 spawns per test run is real cost on a weak
/// device (research decision 4).
///
/// **Cancellation**: the isolate boundary means a message sent to a worker
/// mid-run only gets processed once the worker's synchronous VM loop yields
/// — which it does not do (see `vm/vm.dart`'s single-threaded dispatch
/// loop). So unlike the idealized "graceful unwind first, kill as backstop"
/// design in contracts/execution-contract.md, this implementation makes
/// [Isolate.kill] the actual cancel mechanism: on [CancellationToken.cancel],
/// the pending call resolves immediately with a `cancelled` outcome and the
/// worker is killed and replaced in the background. The learner-visible
/// contract (cancel takes effect within ~1s, the app is immediately usable
/// again, G3/SC-005) is met; the only cost is that a *cancelled* run doesn't
/// reuse its worker (an uncancelled run always does, so G8's steady-state
/// memory-stability path is unaffected). A follow-up could make the VM yield
/// periodically so graceful cancellation works without a kill at all.
library;

import 'dart:async';
import 'dart:isolate';

import '../errors/failure.dart';
import 'engine.dart';
import 'worker.dart';

class IsolateExecutionEngine implements ExecutionEngine {
  Isolate? _worker;
  SendPort? _commandPort;
  Future<void>? _spawning;

  Future<void> _ensureWorker() {
    if (_commandPort != null) return Future<void>.value();
    return _spawning ??= _spawn().whenComplete(() => _spawning = null);
  }

  Future<void> _spawn() async {
    final readyPort = ReceivePort();
    _worker = await Isolate.spawn(_isolateMain, readyPort.sendPort, debugName: 'code-execution-worker');
    _commandPort = await readyPort.first as SendPort;
  }

  Future<void> _respawn() async {
    _worker?.kill(priority: Isolate.immediate);
    _worker = null;
    _commandPort = null;
    await _ensureWorker();
  }

  @override
  Future<RunOutcome> run(RunRequest request, {CancellationToken? token}) async {
    await _ensureWorker();
    final stopwatch = Stopwatch()..start();
    final replyPort = ReceivePort();
    final cancelCompleter = Completer<Map<String, Object?>>();

    void onCancel() {
      if (!cancelCompleter.isCompleted) cancelCompleter.complete(<String, Object?>{'cancelled': true});
    }

    token?.addListener(onCancel);
    _commandPort!.send(<String, Object?>{
      'replyPort': replyPort.sendPort,
      ..._encodeRequest(request),
    });

    final response = await Future.any<Map<String, Object?>>(<Future<Map<String, Object?>>>[
      replyPort.first.then((v) => v as Map<String, Object?>),
      cancelCompleter.future,
    ]);
    replyPort.close();
    token?.removeListener(onCancel);
    stopwatch.stop();

    if (response['cancelled'] == true) {
      unawaited(_respawn());
      return RunOutcome(
        stdout: const <String>[],
        failure: const Failure(kind: FailureKind.cancelled, code: 'cancelled', line: 0),
        elapsed: stopwatch.elapsed,
      );
    }
    return _decodeOutcome(response);
  }

  /// Releases the worker isolate. Call when the engine is no longer needed
  /// (e.g. the editor screen is disposed) — not required between runs.
  Future<void> dispose() async {
    _worker?.kill(priority: Isolate.immediate);
    _worker = null;
    _commandPort = null;
  }
}

void _isolateMain(SendPort readyPort) {
  final commandPort = ReceivePort();
  readyPort.send(commandPort.sendPort);
  commandPort.listen((dynamic message) {
    final map = message as Map<String, Object?>;
    final replyPort = map['replyPort']! as SendPort;
    // Cancellation for this driver is handled entirely by the main isolate
    // killing and replacing the worker (see the class doc comment) — the
    // worker itself never receives a separate cancel message, so `Vm` here
    // always gets a constant `false` rather than a special-cased null.
    final result = executeEncodedRequest(map, () => false);
    replyPort.send(result);
  });
}

Map<String, Object?> _encodeRequest(RunRequest r) => <String, Object?>{
      'language': r.language.name,
      'source': r.source,
      'functionName': r.functionName,
      'arguments': r.arguments.map(encodeValue).toList(),
      'preludeSources': r.preludeSources,
      'budget': encodeBudget(r.budget),
    };

RunOutcome _decodeOutcome(Map<String, Object?> m) {
  final failureMap = m['failure'] as Map<Object?, Object?>?;
  return RunOutcome(
    returned: m['returned'] == null ? null : decodeValue(m['returned']),
    stdout: (m['stdout']! as List<Object?>).cast<String>(),
    truncated: m['truncated']! as bool,
    failure: failureMap == null
        ? null
        : Failure(
            kind: FailureKind.values.byName(failureMap['kind']! as String),
            code: failureMap['code']! as String,
            data: (failureMap['data']! as Map<Object?, Object?>).cast<String, Object?>(),
            line: failureMap['line']! as int,
            partialOutput: (failureMap['partialOutput']! as List<Object?>).cast<String>(),
          ),
    elapsed: Duration(microseconds: m['elapsedUs']! as int),
  );
}
