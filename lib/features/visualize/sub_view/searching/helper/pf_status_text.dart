import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/helper/pf_step.dart';

/// How an algorithm picks the next cell to expand. This — not the algorithm's
/// name — is what the explanation line teaches.
enum PFRule { oldestFirst, newestFirst, cheapestFirst }

/// Builds the one-line explanation shown under the grid.
///
/// Pure: no `BuildContext`, no provider reads, every literal a
/// [StringsManager] constant, and never naming an algorithm or a coordinate.
String buildPFStatusText({required PFStep? step, required PFRule rule}) {
  if (step == null) return StringsManager.searchPreRunHint;

  switch (step.phase) {
    case PFPhase.found:
      final length = step.path?.length ?? 0;
      final found = '${StringsManager.searchPathFound}${StringsManager.searchRuleSeparator}'
          '$length ${StringsManager.searchStepsSuffix}';
      return rule == PFRule.newestFirst ? '$found ${StringsManager.searchNotShortest}' : found;

    case PFPhase.exhausted:
      return StringsManager.searchNoPath;

    case PFPhase.exploring:
      return '${_ruleLabel(rule)}${StringsManager.searchRuleSeparator}${_ruleDetail(step, rule)}';
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

String _ruleDetail(PFStep step, PFRule rule) {
  switch (rule) {
    case PFRule.oldestFirst:
      return '${step.metricA} ${StringsManager.searchWaiting}';
    case PFRule.newestFirst:
      return '${StringsManager.searchDepth} ${step.metricA}';
    case PFRule.cheapestFirst:
      return '${StringsManager.searchCost} ${step.metricA} + ${step.metricB ?? 0} '
          '${StringsManager.searchToGo}';
  }
}
