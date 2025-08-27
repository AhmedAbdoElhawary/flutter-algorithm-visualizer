part of '../view/sorting_page.dart';

class _SpeedDraggable extends ConsumerWidget {
  const _SpeedDraggable({required this.instance});

  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SpeedDraggable(
      onChanged: (persent) {
        ref.read(instance.notifier).changeSpeed(persent);
      },
    );
  }
}

class SpeedDraggable extends ConsumerWidget {
  const SpeedDraggable({super.key, required this.onChanged});

  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Flexible(
      child: Row(
        children: [
          const MediumText(StringsManager.speed, fontSize: 12),
          Flexible(
            child: DraggableProgressBar(
              runOnChangedInitially: true,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
