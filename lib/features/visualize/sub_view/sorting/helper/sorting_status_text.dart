part of '../view_model/sorting_notifier.dart';

const Map<SortRole, String> _anchorPrefixLabels = {
  SortRole.minimum: StringsManager.minPrefix,
  SortRole.heldValue: StringsManager.heldPrefix,
  SortRole.pivot: StringsManager.pivotPrefix,
};

String buildStatusText({
  required SortStep? step,
  required List<SortableItem> list,
  required bool isDone,
}) {
  if (isDone) return StringsManager.arrayFullySorted;
  if (step == null) return StringsManager.initialArrayReadyToSort;

  final sentence = switch (step.kind) {
    StepKind.compare => _compareSentence(step, list),
    StepKind.swap => _swapSentence(step, list),
    StepKind.write => _writeSentence(step, list),
  };

  final prefix = _anchorPrefix(step, list);
  return prefix == null ? sentence : '$prefix\n$sentence';
}

String? _anchorPrefix(SortStep step, List<SortableItem> list) {
  for (final mark in step.marks) {
    final label = _anchorPrefixLabels[mark.role];
    if (label == null) continue;
    return '$label: ${list[mark.start].value}';
  }
  return null;
}

String _compareSentence(SortStep step, List<SortableItem> list) {
  final value1 = list[step.a].value;
  final value2 = list[step.b].value;
  return '${StringsManager.compare} arr[${step.a}]=$value1 ↔ arr[${step.b}]=$value2';
}

String _swapSentence(SortStep step, List<SortableItem> list) {
  final value1 = list[step.a].value;
  final value2 = list[step.b].value;
  return '$value2 > $value1: ${StringsManager.swapPositions} ${step.a} ↔ ${step.b}';
}

String _writeSentence(SortStep step, List<SortableItem> list) {
  final isLeftRun = step.marks.any((m) => m.role == SortRole.leftRun);
  final runLabel = isLeftRun ? StringsManager.roleLeftRun : StringsManager.roleRightRun;
  final value = list[step.a].value;
  return '${StringsManager.roleWrite} $value ${StringsManager.fromRun} $runLabel '
      '${StringsManager.intoPosition} ${step.a}';
}
