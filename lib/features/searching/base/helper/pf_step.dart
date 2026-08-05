class PFStep {
  final Set<int> visited;
  final Set<int> frontier;
  final Set<int>? path;
  final String statusText;

  const PFStep({
    required this.visited,
    required this.frontier,
    this.path,
    required this.statusText,
  });
}
