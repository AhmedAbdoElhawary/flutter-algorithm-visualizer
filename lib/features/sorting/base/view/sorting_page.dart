import 'package:algorithm_visualizer/core/draggable_progress.dart' show DraggableProgressBar;
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/padding/adaptive_padding.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_rounded_elevated_button.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
part '../widgets/sorting_app_bar.dart';
part '../widgets/control_buttons.dart';
part '../widgets/size_draggable.dart';
part '../widgets/speed_draggable.dart';

class SortingPage extends StatelessWidget {
  const SortingPage({required this.instance, required this.title, super.key});
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: _BuildBody(instance: instance),
    );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 1,
      title: SortingAppBar(title: title),
    );
  }
}

class SortingAppBar extends StatelessWidget {
  const SortingAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return InkWell(child: RegularText(title));
      },
    );
  }
}

class _BuildBody extends StatelessWidget {
  const _BuildBody({required this.instance});

  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Align(alignment: AlignmentDirectional.topCenter, child: ShowUpSortingList(instance)),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 10,
              children: [
                _SortingControlButtons(instance),
                SymmetricPadding(
                  horizontal: 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SpeedDraggable(instance: instance),
                      _SizeDraggable(instance: instance),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShowUpSortingList extends ConsumerWidget {
  const ShowUpSortingList(this.instance, {this.selectedAlgorithmLength = 1, super.key});
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
  final int selectedAlgorithmLength;
  @override
  Widget build(BuildContext context, ref) {
    final items = ref.watch(instance.select((state) => state.list));
    final speedDuration = ref.watch(instance.select((state) => state.swipeDuration));

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: RSizedBox(
        height: selectedAlgorithmLength == 1 ? SortingNotifier.maxListItemHeight * 1.05 : null,
        width: double.infinity,
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: List.generate(
            items.length,
            (index) {
              final item = items[index];
              final position = ref.watch(instance.select((state) => state.positions[item.id]));
              return AnimatedPositioned(
                key: ValueKey(item.id),
                left: position?.dx,
                bottom: position?.dy,
                duration: speedDuration,
                child: _BuildItem(
                  item: item,
                  index: index,
                  instance: instance,
                  speedDuration: speedDuration * 0.5,
                  selectedAlgorithmLength: selectedAlgorithmLength,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BuildItem extends ConsumerWidget {
  const _BuildItem({
    required this.item,
    required this.index,
    required this.speedDuration,
    required this.instance,
    required this.selectedAlgorithmLength,
  });

  final int index;
  final SortableItem item;
  final Duration speedDuration;
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
  final int selectedAlgorithmLength;

  @override
  Widget build(BuildContext context, ref) {
    final size = ref.watch(instance.select((state) => state.size));
    final itemWidth = SortingNotifier.calculateItemWidth(context, size);
    final currentItem =
        ref.watch(instance.select((state) => index < state.list.length ? state.list[index] : null));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SortingNotifier.itemsPadding / 2),
      child: AnimatedContainer(
        duration: speedDuration,
        height: SortingNotifier.calculateItemHeight(item.value, size) / selectedAlgorithmLength,
        width: itemWidth,
        decoration: BoxDecoration(
          color: context.getColor(currentItem?.getColor ?? SortingNotifier.itemColor),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(1)),
        ),
      ),
    );
  }
}
