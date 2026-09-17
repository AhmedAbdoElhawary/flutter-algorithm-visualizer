part of '../view_model/sorting_notifier.dart';

const Map<SortRole, String> _anchorPrefixLabels = {
  SortRole.minimum: StringsManager.minPrefix,
  SortRole.heldValue: StringsManager.heldPrefix,
  SortRole.pivot: StringsManager.pivotPrefix,
};

/// [tr] translates each word before it is glued to an index or a value; the
/// finished line (`'Compare arr[3]=17 ↔ arr[4]=9'`) never appears in a
/// translation table because the numbers change every step. Left at its
/// default the builder stays pure English, which is what the unit tests want.
String buildStatusText({
  required SortStep? step,
  required List<SortableItem> list,
  required bool isDone,
  Translator tr = noTranslation,
}) {
  if (isDone) return tr(StringsManager.arrayFullySorted);
  if (step == null) return tr(StringsManager.initialArrayReadyToSort);

  final sentence = switch (step.kind) {
    StepKind.compare => _compareSentence(step, list, tr),
    StepKind.swap => _swapSentence(step, list, tr),
    StepKind.write => _writeSentence(step, list, tr),
  };

  final prefix = _anchorPrefix(step, list, tr);
  return prefix == null ? sentence : '$prefix\n$sentence';
}

String? _anchorPrefix(SortStep step, List<SortableItem> list, Translator tr) {
  for (final mark in step.marks) {
    final label = _anchorPrefixLabels[mark.role];
    if (label == null) continue;
    return '${tr(label)}: ${list[mark.start].value}';
  }
  return null;
}

String _compareSentence(SortStep step, List<SortableItem> list, Translator tr) {
  final value1 = list[step.a].value;
  final value2 = list[step.b].value;
  return '${tr(StringsManager.compare)} arr[${step.a}]=$value1 ↔ arr[${step.b}]=$value2';
}

String _swapSentence(SortStep step, List<SortableItem> list, Translator tr) {
  final value1 = list[step.a].value;
  final value2 = list[step.b].value;
  return '$value2 > $value1: ${tr(StringsManager.swapPositions)} ${step.a} ↔ ${step.b}';
}

String _writeSentence(SortStep step, List<SortableItem> list, Translator tr) {
  final isLeftRun = step.marks.any((m) => m.role == SortRole.leftRun);
  final runLabel = isLeftRun ? StringsManager.roleLeftRun : StringsManager.roleRightRun;
  final value = list[step.a].value;
  return '${tr(StringsManager.roleWrite)} $value ${tr(StringsManager.fromRun)} ${tr(runLabel)} '
      '${tr(StringsManager.intoPosition)} ${step.a}';
}
