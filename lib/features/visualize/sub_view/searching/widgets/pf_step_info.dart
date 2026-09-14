import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_status_text.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/helper/pf_status_text.dart';
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

    return AlgorithmStatusText(
      progressLabel: total == 0
          ? ""
          : StringsManager.searchStepCounterTemplate
              .replaceFirst('{current}', '${stepIndex + 1}')
              .replaceFirst('{total}', '$total'),
      progressValue: total > 1 ? stepIndex / (total - 1) : 0,
      statusText: buildPFStatusText(step: step, rule: rule),
    );
  }
}
