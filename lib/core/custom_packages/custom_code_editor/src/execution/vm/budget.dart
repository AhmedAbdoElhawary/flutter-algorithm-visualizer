/// Resource limits enforced inside the VM dispatch loop (FR-018 through
/// FR-021). See `specs/007-multi-language-interpreter/data-model.md` §7.
library;

class ExecutionBudget {
  const ExecutionBudget({
    this.perTestCaseTimeout = const Duration(seconds: 2),
    this.perRunTimeout = const Duration(seconds: 10),
    this.maxFrameDepth = 10000,
    this.maxHeapValues = 2000000,
    this.maxCollectionLength = 500000,
    this.maxOutputEntries = 10000,
    this.maxOutputChars = 200000,
    this.instructionsPerBudgetCheck = 1000,
  });

  final Duration perTestCaseTimeout;
  final Duration perRunTimeout;
  final int maxFrameDepth;
  final int maxHeapValues;
  final int maxCollectionLength;
  final int maxOutputEntries;
  final int maxOutputChars;

  /// How many bytecode instructions the dispatch loop executes between
  /// budget/cancellation checks. Tuned against the low-end reference device
  /// in T106 (research.md open item 1); this default is a conservative
  /// starting point that favors cancellation latency over raw speed.
  final int instructionsPerBudgetCheck;
}
