part of '../view/sorting_view.dart';

class _SortingControlButtons extends ConsumerWidget {
  const _SortingControlButtons(this.notifier);
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
