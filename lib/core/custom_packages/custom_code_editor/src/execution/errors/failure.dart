/// Codes, not sentences (research decision 7). The engine never produces
/// English prose; presentation resolves `code` via `StringsManager`.
/// See `specs/007-multi-language-interpreter/data-model.md` §8 and
/// `contracts/execution-contract.md`.
library;

enum FailureKind {
  /// Malformed source. "I typed it wrong."
  syntax,

  /// Bad index, missing key, wrong type, divide by zero, uncaught throw.
  /// "My logic is wrong."
  runtime,

  /// Valid code, outside the supported subset. "The app can't do this" —
  /// never the learner's fault. Never conflated with [syntax] (SC-009).
  unsupported,

  /// A test case or run exceeded its time budget. "Probably an infinite
  /// loop."
  timeLimit,

  /// An allocation or output cap was exceeded. "I'm allocating too much."
  memoryLimit,

  /// The explicit frame stack exceeded `ExecutionBudget.maxFrameDepth`.
  /// "My recursion doesn't stop."
  recursionLimit,

  /// The learner pressed stop. Not an error.
  cancelled,
}

/// A classified execution failure. Carries a stable [code] and structured
/// [data] — never a pre-rendered message (FR-014, FR-015).
class Failure {
  const Failure({
    required this.kind,
    required this.code,
    this.data = const <String, Object?>{},
    required this.line,
    this.partialOutput = const <String>[],
  });

  final FailureKind kind;

  /// Stable identifier, e.g. `undefinedVariable`, `indexOutOfRange`,
  /// `unsupportedConstruct`. Never English prose.
  final String code;

  /// The actual values involved, e.g. `{index: 5, length: 3}` (FR-015).
  final Map<String, Object?> data;

  /// 1-indexed, in the learner's own source (FR-013, FR-017).
  final int line;

  /// Whatever was printed before the failure (FR-016, G7).
  final List<String> partialOutput;

  @override
  String toString() => 'Failure(kind: $kind, code: $code, line: $line, data: $data)';
}

/// Internal VM control-flow signal for a runtime fault (bad index, wrong
/// type, missing key, ...). Caught only at the VM's outermost `run()` call
/// and converted to a [Failure] — never leaks past the engine boundary.
/// Distinct from a learner-level `throw`/`raise`, which unwinds through the
/// bytecode's own exception table instead (see `vm/vm.dart`).
class VmRuntimeError implements Exception {
  const VmRuntimeError(this.code, [this.data = const <String, Object?>{}]);
  final String code;
  final Map<String, Object?> data;

  @override
  String toString() => 'VmRuntimeError($code, $data)';
}

/// Thrown by `LanguageFrontend.parse` — never a raw Dart error (O3).
class FrontendFailure implements Exception {
  const FrontendFailure({required this.kind, required this.code, this.data = const <String, Object?>{}, required this.line})
      : assert(kind == FailureKind.syntax || kind == FailureKind.unsupported, 'a frontend can only report syntax or unsupported');

  final FailureKind kind;
  final String code;
  final Map<String, Object?> data;
  final int line;

  Failure toFailure({List<String> partialOutput = const <String>[]}) =>
      Failure(kind: kind, code: code, data: data, line: line, partialOutput: partialOutput);

  @override
  String toString() => 'FrontendFailure(kind: $kind, code: $code, line: $line, data: $data)';
}
