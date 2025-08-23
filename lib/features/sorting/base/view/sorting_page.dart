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

class SortingPage extends StatelessWidget {
  const SortingPage({required this.instance, required this.title, super.key});
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Align(alignment: AlignmentDirectional.topCenter, child: _BuildList(instance)),
            // _ControlButtons(),
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 0),
              child: Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 10,
                  children: [
                    _ControlButtons(instance),
                    SymmetricPadding(
                      horizontal: 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SpeedDraggable(instance: instance),
                          SizeDraggable(instance: instance),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 1,
      title: Consumer(
        builder: (context, ref, _) {
          return InkWell(child: RegularText(title));
        },
      ),
    );
  }
}

class SpeedDraggable extends ConsumerWidget {
  const SpeedDraggable({super.key, required this.instance});

  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Flexible(
      child: Row(
        children: [
          const MediumText(StringsManager.speed, fontSize: 12),
          Flexible(
            child: DraggableProgressBar(
              runOnChangedInitially: true,
              onChanged: (persent) {
                ref.read(instance.notifier).changeSpeed(persent);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SizeDraggable extends ConsumerWidget {
  const SizeDraggable({super.key, required this.instance});

  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operationStatus = ref.watch(instance.select((state) => state.operationStatus));
    final isRunning = operationStatus == SortingEnum.played || operationStatus == SortingEnum.stopped;
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
                  onChanged: (persent) {
                    ref.read(instance.notifier).changeSize(persent);
                  },
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

class Item extends StatelessWidget {
  final String text;

  const Item({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: context.getColor(ThemeEnum.whiteD7Color),
      child: RegularText(text, color: ThemeEnum.primaryColor),
    );
  }
}

class _BuildList extends ConsumerWidget {
  const _BuildList(this.instance);
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;

  @override
  Widget build(BuildContext context, ref) {
    final items = ref.watch(instance.select((state) => state.list));
    final speedDuration = ref.watch(instance.select((state) => state.swipeDuration));

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: RSizedBox(
        height: SortingNotifier.maxListItemHeight * 1.05,
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
                    item: item, index: index, speedDuration: speedDuration * 0.5, instance: instance),
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
  });

  final int index;
  final SortableItem item;
  final Duration speedDuration;
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;

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
        height: SortingNotifier.calculateItemHeight(item.value, size),
        width: itemWidth,
        decoration: BoxDecoration(
          color: context.getColor(currentItem?.getColor ?? SortingNotifier.itemColor),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(1)),
        ),
      ),
    );
  }
}
