import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SortingControlButtons extends ConsumerWidget {
  const SortingControlButtons(this.notifier, {super.key});
  final NotifierProvider<SortingNotifier, SortingNotifierState> notifier;

  @override
  Widget build(BuildContext context, ref) {
    final instance = ref.read(notifier.notifier);
    final backwardValidation = ref.watch(notifier.select((s) => !s.isAtFirstStep));
    final forwardValidation = ref.watch(notifier.select((s) => !s.isAtLastStep));
    final isPlaying = ref.watch(notifier.select((s) => s.isPlaying));
    final getSpeed = ref.watch(notifier.select((s) => s.speed));

    return AlgorithmControls(
      interface: instance,
      isPlaying: isPlaying,
      getSpeed: getSpeed,
      backwardValidation: backwardValidation,
      forwardValidation: forwardValidation,
      expandSpeedEscalator: true,
    );
  }
}
