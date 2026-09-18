import 'package:algorithm_visualizer/core/localization/app_localizations.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_status_text.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/helper/pf_status_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/searching_notifier.dart';

class PFStepInfo extends ConsumerWidget {
  const PFStepInfo({required this.instance, super.key});
  final NotifierProvider<SearchingNotifier, SearchingState> instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rule = ref.read(instance.notifier).rule;
    final step = ref.watch(instance.select((s) => s.currentStep));
    final stepIndex = ref.watch(instance.select((s) => s.stepIndex));
    final total = ref.watch(instance.select((s) => s.steps?.length ?? 0));

    final l10n = AppLocalizations.of(context);

    return AlgorithmStatusText(
      /// The template is translated **before** the numbers go in — the
      /// finished `'Step 4 of 61'` is not a key, and could not be.
      progressLabel: total == 0
          ? ""
          : l10n
              .tr(StringsManager.searchStepCounterTemplate)
              .replaceFirst('{current}', '${stepIndex + 1}')
              .replaceFirst('{total}', '$total'),
      progressValue: total > 1 ? stepIndex / (total - 1) : 0,
      statusText: buildPFStatusText(step: step, rule: rule, tr: l10n.tr),
    );
  }
}
