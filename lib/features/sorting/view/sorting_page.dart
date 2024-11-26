import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_rounded_elevated_button.dart';
import 'package:algorithm_visualizer/features/sorting/view_model/sorting_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
part '../widgets/sorting_app_bar.dart';
part '../widgets/control_buttons.dart';

final _notifierProvider = StateNotifierProvider<SortingNotifier, SortingNotifierState>(
  (ref) => SortingNotifier(),
);

class SortingPage extends StatelessWidget {
  const SortingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Consumer(
          builder: (context, ref, _) {
            return InkWell(
              onTap: () {
                ref.read(_notifierProvider.notifier).bubbleSort();
              },
              child: const Text("Sort"),
            );
          },
        ),
      ),
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          const Align(alignment: AlignmentDirectional.topCenter, child: _BuildList()),
          // _ControlButtons(),
          const Align(alignment: AlignmentDirectional.bottomCenter, child: _InteractionButton()),
          ...List.generate(
            SortingNotifier.sortingAlgorithms.length,
            (index) => _SelectedOperation(index),
          ),
        ],
      ),
    );
  }
}

class _InteractionButton extends ConsumerWidget {
  const _InteractionButton();

  @override
  Widget build(BuildContext context, ref) {
    return const _ControlButtons();
  }
}

class _SelectedOperation extends ConsumerWidget {
  const _SelectedOperation(this.index);
  final int index;
  @override
  Widget build(BuildContext context, ref) {
    final algo = SortingNotifier.sortingAlgorithms[index];
    final isChanged = ref.watch(_notifierProvider).selectedAlgorithms.contains(algo);
    final width = SortingNotifier.calculateButtonWidth(index);

    return AnimatedPositionedDirectional(
      duration: const Duration(milliseconds: 300),
      start: width,
      bottom: isChanged ? 100 : 0,
      // width: width,
      child: CustomRoundedElevatedButton(
        roundedRadius: 3,
        backgroundColor: ThemeEnum.whiteD7Color,
        child: RegularText(algo.name, fontSize: 14),
        onPressed: () {
          ref.read(_notifierProvider.notifier).selectAlgorithm(index);
        },
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
  const _BuildList();

  @override
  Widget build(BuildContext context, ref) {
    final items = ref.watch(_notifierProvider.select((state) => state.list));

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: SizedBox(
        height: SortingNotifier.maxListItemHeight * 1.2,
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
                duration: SortingNotifier.swipeDuration,
                child: _BuildItem(item: item),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BuildItem extends ConsumerWidget {
  const _BuildItem({required this.item});

  final SortableItem item;

  @override
  Widget build(BuildContext context, ref) {
    final itemWidth = SortingNotifier.calculateItemWidth(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SortingNotifier.itemsPadding / 2),
      child: Container(
        height: SortingNotifier.calculateItemHeight(item.value),
        width: itemWidth,
        decoration: BoxDecoration(
          color: SortingNotifier.getColor(item.value),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(1),
          ),
        ),
      ),
    );
  }
}
