part of '../view/sorting_page.dart';

const double verticalPadding = 7;
const double roundedCircle = 12;

class _SortingControlButtons extends ConsumerWidget {
  const _SortingControlButtons(this.notifier);
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> notifier;

  @override
  Widget build(BuildContext context, ref) {
    final instance = ref.read(notifier.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CtrlButton(
          icon: Icons.refresh_rounded,
          onTap: instance.generateAgain,
        ),
        _CtrlButton(
          icon: Icons.skip_previous_rounded,
          onTap: () => instance.isAtFirstStep ? null : instance.stepBackward(),
        ),
        _PlayPauseButton(notifier: notifier),
        _CtrlButton(
          icon: Icons.skip_next_rounded,
          onTap: () => instance.isAtLastStep ? null : instance.stepForward(),
        ),
        _SpeedPicker(instance.changeSpeed),
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

class _PlayPauseButton extends ConsumerWidget {
  const _PlayPauseButton({required this.notifier});
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> notifier;

  @override
  Widget build(BuildContext context, ref) {
    final isPlaying = ref.watch(notifier.select((state) => state.isPlaying));
    final instance = ref.read(notifier.notifier);

    return GestureDetector(
      onTap: () {
        isPlaying ? instance.stopSorting() : instance.playSorting(context);
      },
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
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 30,
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
