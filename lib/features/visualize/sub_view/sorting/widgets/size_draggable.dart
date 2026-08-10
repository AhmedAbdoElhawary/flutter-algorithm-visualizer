part of '../view/sorting_view.dart';

class SizeDraggable extends ConsumerWidget {
  const SizeDraggable({super.key, required this.onChanged, required this.isRunning});

  final ValueChanged<double> onChanged;
  final bool isRunning;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Flexible(
      child: Row(
        children: [
          MediumText(
            StringsManager.size,
            fontSize: 12,
            color: isRunning ? ThemeEnum.whiteD7Color : null,
          ),
          Flexible(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                DraggableProgressBar(
                  isActive: !isRunning,
                  runOnChangedInitially: true,
                  sliderValue: 0.15,
                  onChanged: onChanged,
                ),
                if (isRunning)
                  Container(
                    color: ColorManager.transparent,
                    height: 20.r,
                    width: double.infinity,
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
