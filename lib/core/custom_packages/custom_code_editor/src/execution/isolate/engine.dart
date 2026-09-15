/// Request/response shape and cancellation token for running code
/// off the UI thread. See `contracts/execution-contract.md`.
library;

import '../errors/failure.dart';
import '../frontend/frontend.dart';
import '../values/value.dart';
import '../vm/budget.dart';

class RunRequest {
  const RunRequest({
    required this.language,
    required this.source,
    required this.functionName,
    this.arguments = const <Value>[],
    this.preludeSources = const <String>[],
    this.budget = const ExecutionBudget(),
  });

  final EditorLanguage language;

  /// The learner's code, verbatim.
  final String source;

  /// The entry point the problem expects.
  final String functionName;

  /// Already-parsed [Value]s for one test case.
  final List<Value> arguments;

  /// Structured-type definitions (`ListNode`, `TreeNode`) prepended only if
  /// the learner did not define them.
  final List<String> preludeSources;

  final ExecutionBudget budget;
}

class RunOutcome {
  const RunOutcome(
      {this.returned,
      this.stdout = const <String>[],
      this.truncated = false,
      this.failure,
      required this.elapsed});

  /// The function's value, or null.
  final Value? returned;

  /// Everything printed, in order.
  final List<String> stdout;

  /// Whether output hit the cap.
  final bool truncated;

  /// Null on success.
  final Failure? failure;

  final Duration elapsed;
}

/// Cooperative cancellation handle: the learner-facing "Cancel" button holds
/// one of these and calls [cancel]; [ExecutionEngine] implementations watch
/// it (or poll [isCancelled]) to stop promptly (FR-024, G3).
class CancellationToken {
  bool _cancelled = false;
  final List<void Function()> _listeners = <void Function()>[];

  bool get isCancelled => _cancelled;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
  }

  /// Internal — engines use this to react immediately to [cancel] rather
  /// than only discovering it on the next poll.
  void addListener(void Function() listener) {
    if (_cancelled) {
      listener();
      return;
    }
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) => _listeners.remove(listener);
}

abstract class ExecutionEngine {
  Future<RunOutcome> run(RunRequest request, {CancellationToken? token});
}
