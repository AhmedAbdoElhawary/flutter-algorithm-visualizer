part of '../view/sorting_page.dart';

const double verticalPadding = 7;
const double roundedCircle = 12;

class _SortingControlButtons extends ConsumerWidget {
  const _SortingControlButtons(this.instance);
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;

  @override
  Widget build(BuildContext context, ref) {
    return SortingControlButtons(
      playSorting: () => ref.read(instance.notifier).playSorting(context),
      stopSorting: () => ref.read(instance.notifier).stopSorting(),
      generateAgain: () => ref.read(instance.notifier).generateAgain(),
      speedSorting: ref.read(instance.notifier).changeSpeed,
    );
  }
}

class SortingControlButtons extends ConsumerWidget {
  const SortingControlButtons({
    required this.playSorting,
    required this.stopSorting,
    required this.generateAgain,
    required this.speedSorting,
    super.key,
  });
  final VoidCallback playSorting;
  final VoidCallback stopSorting;
  final VoidCallback generateAgain;
  final void Function(SpeedStatus) speedSorting;
  @override
  Widget build(BuildContext context, ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CtrlButton(
          icon: Icons.refresh_rounded,
          onTap: generateAgain,
        ),
        _CtrlButton(
          icon: Icons.skip_previous_rounded,
          onTap: () {},
        ),
        _PlayPauseButton(onTap: playSorting),
        _CtrlButton(
          icon: Icons.skip_next_rounded,
          onTap: () {},
        ),
        _SpeedPicker(speedSorting),
      ],
    );
  }
}

class _SpeedPicker extends StatefulWidget {
  const _SpeedPicker(this.speedSorting);
  final void Function(SpeedStatus) speedSorting;

  @override
  State<_SpeedPicker> createState() => _SpeedPickerState();
}

class _SpeedPickerState extends State<_SpeedPicker> {
  int _speedMultiplier = 2;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: verticalPadding),
      borderRadius: roundedCircle,
      withAboveShadow: false,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [1, 2, 3].map((s) {
          final sel = _speedMultiplier == s;
          return GestureDetector(
            onTap: () {
              setState(() => _speedMultiplier = s);
              widget.speedSorting(_speedMultiplier == 1
                  ? SpeedStatus.normal
                  : (_speedMultiplier == 2 ? SpeedStatus.average : SpeedStatus.fast));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: sel ? context.getColor(ThemeEnum.cardGlassColor) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: sel
                  ? BoldText('${s}x', fontSize: 13)
                  : RegularText('${s}x', fontSize: 13, color: ThemeEnum.greyColor),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: REdgeInsets.all(verticalPadding + 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(roundedCircle),
          gradient: const LinearGradient(
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
            colors: [
              ColorManager.mainDarkColor,
              ColorManager.main2DarkColor,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: ColorManager.mainDarkColor.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Icon(
          // _isPlaying ? Icons.pause_rounded :
          Icons.play_arrow_rounded,
          color: Colors.white, size: 30,
        ),
      ),
    );
  }
}

class _CtrlButton extends StatelessWidget {
  const _CtrlButton({
    required this.onTap,
    required this.icon,
  });

  final VoidCallback onTap;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: GlassContainer(
        withAboveShadow: false,
        borderRadius: roundedCircle,
        padding: REdgeInsets.all(verticalPadding),
        child: CustomIcon(icon, size: 28, color: ThemeEnum.white2DarkColor),
      ),
    );
  }
}
