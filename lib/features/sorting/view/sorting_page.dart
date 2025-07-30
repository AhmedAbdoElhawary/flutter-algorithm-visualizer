import 'package:algorithm_visualizer/core/draggable_progress.dart' show DraggableProgressBar;
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_rounded_elevated_button.dart';
import 'package:algorithm_visualizer/features/sorting/view_model/sorting_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
part '../widgets/sorting_app_bar.dart';
part '../widgets/control_buttons.dart';

final _notifierProvider = StateNotifierProvider<SortingNotifier, SortingNotifierState>(
  (ref) => SortingNotifier(),
);

class SortingPage extends ConsumerStatefulWidget {
  const SortingPage({super.key});

  @override
  ConsumerState<SortingPage> createState() => _SortingPageState();
}

class _SortingPageState extends ConsumerState<SortingPage> {
  @override
  void deactivate() {
    ref.invalidate(_notifierProvider); // deletes current instance and resets
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            const Align(alignment: AlignmentDirectional.topCenter, child: _BuildList()),
            // _ControlButtons(),
            Padding(
              padding: REdgeInsets.symmetric(horizontal: 0),
              child: Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 10,
                  children: [
                    Wrap(
                      spacing: 10,
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        SortingNotifier.sortingAlgorithms.length,
                        (index) => _SelectedOperation(index),
                      ),
                    ),
                    const _ControlButtons(),
                    Row(
                      children: [
                        DraggableProgressBar(
                          onChanged: (persent) {
                            ref.read(_notifierProvider.notifier).changeSpeed(persent);
                          },
                        ),
                        DraggableProgressBar(
                          onChanged: (persent) {
                            ref.read(_notifierProvider.notifier).changeSize(persent);
                          },
                        ),
                      ],
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
          return const InkWell(child: RegularText(StringsManager.sort));
        },
      ),
    );
  }
}

class _SelectedOperation extends ConsumerWidget {
  const _SelectedOperation(this.index);
  final int index;
  @override
  Widget build(BuildContext context, ref) {
    final algo = SortingNotifier.sortingAlgorithms[index];
    final isChanged = ref.watch(_notifierProvider).selectedAlgorithms.contains(algo);

    return CustomRoundedElevatedButton(
      roundedRadius: 3,
      backgroundColor: isChanged ? ThemeEnum.blueColor : ThemeEnum.whiteD7Color,
      child: RegularText(algo.name, fontSize: 14),
      onPressed: () {
        ref.read(_notifierProvider.notifier).selectAlgorithm(index);
      },
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
  const _BuildList();

  @override
  Widget build(BuildContext context, ref) {
    final items = ref.watch(_notifierProvider.select((state) => state.list));
    final speedDuration = ref.watch(_notifierProvider.select((state) => state.swipeDuration));

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: SizedBox(
        height: SortingNotifier.maxListItemHeight * 1.3,
        width: double.infinity,
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: List.generate(
            items.length,
            (index) {
              final item = items[index];
              final position = ref.watch(_notifierProvider.select((state) => state.positions[item.id]!));
              return AnimatedPositioned(
                key: ValueKey(item.id),
                left: position.dx,
                bottom: position.dy,
                duration: speedDuration,
                child: _BuildItem(
                    item: item,
                    index: index,
                    speedDuration:speedDuration),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BuildItem extends ConsumerWidget {
  const _BuildItem({required this.item, required this.index, required this.speedDuration});

  final SortableItem item;
  final int index;
  final Duration speedDuration;
  @override
  Widget build(BuildContext context, ref) {
    final size = ref.watch(_notifierProvider.select((state) => state.size));
    final itemWidth = SortingNotifier.calculateItemWidth(context, size);
    final currentItem = ref.watch(_notifierProvider.select((state) => state.list[index]));

    final color = currentItem.sortedStatus == SortingStatus.sorted
        ? SortingNotifier.doneSortingColor
        : (currentItem.sortedStatus == SortingStatus.swapped
            ? SortingNotifier.swipedColor
            : currentItem.sortedStatus == SortingStatus.compared
                ? SortingNotifier.comparedColor
                : SortingNotifier.itemColor);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SortingNotifier.itemsPadding / 2),
      child: AnimatedContainer(
        duration: speedDuration,
        height: SortingNotifier.calculateItemHeight(item.value, size),
        width: itemWidth,
        decoration: BoxDecoration(
          color: context.getColor(color),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(1)),
        ),
      ),
    );
  }
}
