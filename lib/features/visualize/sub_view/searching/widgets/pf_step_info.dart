import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_status_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/searching_notifier.dart';

class PFStepInfo extends ConsumerWidget {
  const PFStepInfo({required this.instance, super.key});
  final NotifierProvider<SearchingNotifier, SearchingState> instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(instance);
    final step = state.currentStep;
    final description = step?.statusText ?? 'Drag cells to draw walls, then press ▶ Run';
    final total = state.steps?.length ?? 0;
    return AlgorithmStatusText(
      progressLabel: total < 0 ? "" : 'Step ${state.stepIndex + 1} of $total',
      progressValue: total > 1 ? state.stepIndex / (total - 1) : 0,
      statusText: description,
    );
  }
}
