part of '../view_model/sorting_notifier.dart';

/// The shared role catalogue every sorting algorithm paints from (FR-017).
/// [idle] is the absence of a mark — it never appears in a [RoleMark] and is
/// never shown in a legend (VR-3).
enum SortRole {
  idle,
  compare,
  swap,
  write,
  sorted,
  minimum,
  heldValue,
  pivot,
  rightRun,
  target,
  boundary,
  leftRun,
}

/// C1: total, single-valued, exhaustive — no `default`, no fallback.
ThemeEnum sortingRoleColor(SortRole role) {
  switch (role) {
    case SortRole.idle:
      return ThemeEnum.track;
    case SortRole.compare:
      return ThemeEnum.dataActive;
    case SortRole.swap:
    case SortRole.write:
      return ThemeEnum.dataHard;
    case SortRole.sorted:
      return ThemeEnum.dataEasy;
    case SortRole.minimum:
    case SortRole.heldValue:
    case SortRole.pivot:
    case SortRole.rightRun:
      return ThemeEnum.dataMedium;
    case SortRole.target:
    case SortRole.boundary:
    case SortRole.leftRun:
      return ThemeEnum.dataTarget;
  }
}

/// C2: total, centralized — every string is a [StringsManager] constant.
/// Never called for [SortRole.idle] (C2.3).
String roleLabel(SortRole role) {
  switch (role) {
    case SortRole.idle:
      return StringsManager.base;
    case SortRole.compare:
      return StringsManager.roleCompare;
    case SortRole.swap:
      return StringsManager.roleSwap;
    case SortRole.write:
      return StringsManager.roleWrite;
    case SortRole.sorted:
      return StringsManager.roleSorted;
    case SortRole.minimum:
      return StringsManager.roleMinimum;
    case SortRole.heldValue:
      return StringsManager.roleHeldValue;
    case SortRole.pivot:
      return StringsManager.rolePivot;
    case SortRole.rightRun:
      return StringsManager.roleRightRun;
    case SortRole.target:
      return StringsManager.roleTarget;
    case SortRole.boundary:
      return StringsManager.roleBoundary;
    case SortRole.leftRun:
      return StringsManager.roleLeftRun;
  }
}

/// FR-018: fixed collision order, identical for every algorithm.
/// Swap/Write → Held anchor → Compare → Boundary/Target → Region → Sorted → Idle.
/// Held anchors (minimum/heldValue/pivot) outrank compare — a bar holding
/// one of these keeps announcing what it's holding even while it is also
/// being scanned past.
const List<SortRole> kRolePriority = [
  SortRole.swap,
  SortRole.write,
  SortRole.minimum,
  SortRole.heldValue,
  SortRole.pivot,
  SortRole.compare,
  SortRole.boundary,
  SortRole.target,
  SortRole.leftRun,
  SortRole.rightRun,
  SortRole.sorted,
  SortRole.idle,
];

/// C3: pure — the first entry of [kRolePriority] present in [marks], or
/// [SortRole.idle] when [marks] is empty.
SortRole resolve(Set<SortRole> marks) {
  for (final role in kRolePriority) {
    if (marks.contains(role)) return role;
  }
  return SortRole.idle;
}
