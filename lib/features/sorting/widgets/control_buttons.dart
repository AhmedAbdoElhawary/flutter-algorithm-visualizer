part of '../view/sorting_page.dart';

class _ControlButtons extends ConsumerWidget {
  const _ControlButtons();

  @override
  Widget build(BuildContext context, ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomRoundedElevatedButton(
          roundedRadius: 3,
          backgroundColor: ThemeEnum.blackOp10,
          child: const RegularText(
            StringsManager.play,
            fontSize: 14,
          ),
          onPressed: () {
            ref.read(_notifierProvider.notifier).playSorting();
          },
        ),
        CustomRoundedElevatedButton(
          roundedRadius: 3,
          backgroundColor: ThemeEnum.blackOp10,
          child: const RegularText(
            StringsManager.stop,
            fontSize: 14,
          ),
          onPressed: () {
            ref.read(_notifierProvider.notifier).stopSorting();
          },
        ),
        CustomRoundedElevatedButton(
          roundedRadius: 3,
          backgroundColor: ThemeEnum.redColor,
          child: const RegularText(
            StringsManager.reset,
            color: ThemeEnum.whiteColor,
            fontSize: 14,
          ),
          onPressed: () {
            ref.read(_notifierProvider.notifier).generateAgain();
          },
        ),
      ],
    );
  }
}
