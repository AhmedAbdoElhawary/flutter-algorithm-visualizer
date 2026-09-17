import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_step.dart';

/// How an algorithm picks the next cell to expand. This — not the algorithm's
/// name — is what the explanation line teaches.
enum PFRule { oldestFirst, newestFirst, cheapestFirst }

/// Builds the one-line explanation shown under the grid.
///
/// Pure: no `BuildContext`, no provider reads, every literal a
/// [StringsManager] constant, and never naming an algorithm or a coordinate.
///
/// [tr] is how it localises without giving that up. Each fragment is
/// translated **before** it is glued to a number, because the finished
/// sentence — `'Oldest first · 12 waiting'` — is not a key in any table and
/// never could be: the number changes every step.
String buildPFStatusText({
  required PFStep? step,
  required PFRule rule,
  Translator tr = noTranslation,
}) {
  if (step == null) return tr(StringsManager.searchPreRunHint);

  switch (step.phase) {
    case PFPhase.found:
      final length = step.path?.length ?? 0;
      final found = '${tr(StringsManager.searchPathFound)}${StringsManager.searchRuleSeparator}'
          '$length ${tr(StringsManager.searchStepsSuffix)}';
      return rule == PFRule.newestFirst ? '$found ${tr(StringsManager.searchNotShortest)}' : found;

    case PFPhase.exhausted:
      return tr(StringsManager.searchNoPath);

    case PFPhase.exploring:
      return '${tr(_ruleLabel(rule))}${StringsManager.searchRuleSeparator}'
          '${_ruleDetail(step, rule, tr)}';
  }
}

String _ruleLabel(PFRule rule) {
  switch (rule) {
    case PFRule.oldestFirst:
      return StringsManager.searchRuleOldestFirst;
    case PFRule.newestFirst:
      return StringsManager.searchRuleNewestFirst;
    case PFRule.cheapestFirst:
      return StringsManager.searchRuleCheapestFirst;
  }
}

String _ruleDetail(PFStep step, PFRule rule, Translator tr) {
  switch (rule) {
    case PFRule.oldestFirst:
      return '${step.metricA} ${tr(StringsManager.searchWaiting)}';
    case PFRule.newestFirst:
      return '${tr(StringsManager.searchDepth)} ${step.metricA}';
    case PFRule.cheapestFirst:
      return '${tr(StringsManager.searchCost)} ${step.metricA} + ${step.metricB ?? 0} '
          '${tr(StringsManager.searchToGo)}';
  }
}
