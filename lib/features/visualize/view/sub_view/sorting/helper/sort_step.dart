part of '../view_model/sorting_notifier.dart';

/// A role applied to a span of positions. [end] is inclusive and equals
/// [start] for a single bar (VR-6, VR-7). Never [SortRole.idle] (VR-8).
class RoleMark {
  final SortRole role;
  final int start;
  final int end;

  const RoleMark({required this.role, required this.start, required this.end});

  RoleMark.single(SortRole role, int index) : this(role: role, start: index, end: index);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleMark && role == other.role && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(role, start, end);
}

/// The step vocabulary (VR-9) — nothing else, no no-op, no role-only step.
enum StepKind { compare, swap, write }

/// One comparison or one movement (FR-026). Self-describing: [marks] carries
/// every role in force at this moment, including ones established earlier
/// (VR-10).
class SortStep {
  final StepKind kind;
  final int a;
  final int b;

  /// For `write` only: the position the placed value is moving from. Merge
  /// sort is the only emitter of `write`, and it always knows this at
  /// generation time — carrying it here means the replay layer never has to
  /// reverse-engineer it from `leftRun`/`rightRun` marks. Null for
  /// `compare`/`swap`.
  final int? source;
  final List<RoleMark> marks;

  const SortStep({required this.kind, required this.a, required this.b, this.source, required this.marks});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SortStep ||
        kind != other.kind ||
        a != other.a ||
        b != other.b ||
        source != other.source ||
        marks.length != other.marks.length) {
      return false;
    }
    // `marks` is always built in the same deterministic order for equal
    // steps (RoleContext.emit's live-values order + its own operation
    // mark(s)), so a positional comparison is equivalent to — and cheaper
    // than — building a Set on both sides.
    for (int i = 0; i < marks.length; i++) {
      if (marks[i] != other.marks[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(kind, a, b, source, Object.hashAll(marks));
}

/// The generation-time role holder (data-model §4b). Lives only while
/// `buildSorting` runs — not part of persisted state.
class RoleContext {
  final Map<SortRole, RoleMark> _live = {};

  final List<SortStep> _steps = [];
  final Set<SortRole> _declaredRoles;
  SortStep? _previous;

  RoleContext(this._declaredRoles);

  /// Sets/replaces this role's span. Two simultaneous marks for the same
  /// role are structurally unrepresentable (VR-15a).
  void hold(SortRole role, int start, [int? end]) {
    _live[role] = RoleMark(role: role, start: start, end: end ?? start);
  }

  /// This role is no longer live.
  void release(SortRole role) => _live.remove(role);

  /// Snapshots the live marks into a new [SortStep]. Later `hold`/`release`
  /// calls never mutate an already-emitted step (VR-15b).
  ///
  /// The operation itself is a mark too: `compare`/`swap`/`write` have no
  /// `hold` lifecycle (they are never "still in force" on a later step), so
  /// unlike the anchor roles they are attached here, at the one position
  /// (`write`) or two positions (`compare`/`swap`) this step touches —
  /// otherwise a bar being compared or swapped never carries any role for
  /// it and paints as whatever anchor (or nothing) happened to be live.
  ///
  /// [source] is only meaningful for `write`: the position the placed value
  /// is moving from. The caller (merge sort) always knows this already, so
  /// it's carried on the step rather than reconstructed later.
  void emit(StepKind kind, int a, [int b = -1, int? source]) {
    final operationRole = switch (kind) {
      StepKind.compare => SortRole.compare,
      StepKind.swap => SortRole.swap,
      StepKind.write => SortRole.write,
    };

    final marks = List<RoleMark>.unmodifiable([
      ..._live.values,
      RoleMark.single(operationRole, a),
      if (b != -1) RoleMark.single(operationRole, b),
    ]);
    final step = SortStep(kind: kind, a: a, b: b, source: source, marks: marks);

    if (!(marks.every((m) => _declaredRoles.contains(m.role)))) return;
    if (step == _previous) return;

    _steps.add(step);
    _previous = step;
  }

  List<SortStep> get steps => List.unmodifiable(_steps);
}
