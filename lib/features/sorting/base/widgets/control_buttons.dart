part of '../view/sorting_page.dart';

class _SortingControlButtons extends ConsumerWidget {
  const _SortingControlButtons(this.instance);
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;

  @override
  Widget build(BuildContext context, ref) {
    return SortingControlButtons(
      playSorting: () => ref.read(instance.notifier).playSorting(context),
      stopSorting: () => ref.read(instance.notifier).stopSorting(),
      generateAgain: () => ref.read(instance.notifier).generateAgain(),
    );
  }
}

class SortingControlButtons extends ConsumerWidget {
  const SortingControlButtons({
    required this.playSorting,
    required this.stopSorting,
    required this.generateAgain,
    super.key,
  });
  final VoidCallback playSorting;
  final VoidCallback stopSorting;
  final VoidCallback generateAgain;
  @override
  Widget build(BuildContext context, ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomRoundedElevatedButton(
          roundedRadius: 3,
          backgroundColor: ThemeEnum.blackOp10,
          onPressed: playSorting,
          child: const RegularText(
            StringsManager.play,
            fontSize: 14,
          ),
        ),
        CustomRoundedElevatedButton(
          roundedRadius: 3,
          backgroundColor: ThemeEnum.blackOp10,
          onPressed: stopSorting,
          child: const RegularText(
            StringsManager.stop,
            fontSize: 14,
          ),
        ),
        CustomRoundedElevatedButton(
          roundedRadius: 3,
          backgroundColor: ThemeEnum.redColor,
          onPressed: generateAgain,
          child: const RegularText(
            StringsManager.reset,
            color: ThemeEnum.whiteColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
