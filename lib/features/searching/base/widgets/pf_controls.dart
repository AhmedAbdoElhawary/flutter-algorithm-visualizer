import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/searching_notifier.dart';

class SearchingAlgorithmControls extends ConsumerWidget {
  const SearchingAlgorithmControls({required this.instance, super.key});
  final StateNotifierProvider<SearchingNotifier, SearchingState> instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(instance.notifier);
    final backwardValidation = ref.watch(instance.select((s) => s.isAtStart));
    final forwardValidation = ref.watch(instance.select((s) => s.isAtEnd));
    final isPlaying = ref.watch(instance.select((s) => s.playing));
    final getSpeed = ref.watch(instance.select((s) => s.speed));

    return AlgorithmControls(
      interface: notifier,
      isPlaying: isPlaying,
      getSpeed: getSpeed,
      backwardValidation: backwardValidation,
      forwardValidation: forwardValidation,
      endOptionButtons: [
        CtrlButton(icon: Icons.grid_off_rounded, onTap: notifier.clearWalls, messageTip: 'Clear walls'),
        CtrlButton(icon: Icons.shuffle_rounded, onTap: notifier.randomizeWalls, messageTip: 'Random walls'),
      ],
    );
  }
}
