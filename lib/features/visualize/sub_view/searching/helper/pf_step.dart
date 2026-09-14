/// Where a search stands at one step.
enum PFPhase {
  /// A cell was expanded and the search continues.
  exploring,

  /// The goal was reached — the last step, and the only one carrying a path.
  found,

  /// The frontier emptied with no path — the last step, [PFStep.path] is null.
  exhausted,
}

/// One snapshot, produced by expanding exactly one cell.
///
/// [visited] and [frontier] are always disjoint: a cell is in [frontier] once
/// it has been discovered, and moves to [visited] only once it is expanded.
class PFStep {
  /// Cells already expanded.
  final Set<int> visited;

  /// Cells discovered but not yet expanded.
  final Set<int> frontier;

  /// Ordered start → end; non-null exactly when [phase] is [PFPhase.found].
  final List<int>? path;

  final PFPhase phase;

  /// BFS queue size · DFS stack depth · A* `g` of the expanded cell.
  final int metricA;

  /// A* `h` of the expanded cell; null for BFS and DFS.
  final int? metricB;

  const PFStep({
    required this.visited,
    required this.frontier,
    this.path,
    required this.phase,
    required this.metricA,
    this.metricB,
  });
}
