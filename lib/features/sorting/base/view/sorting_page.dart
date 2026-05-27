import 'package:algorithm_visualizer/core/draggable_progress.dart' show DraggableProgressBar;
import 'package:algorithm_visualizer/core/helpers/app_bar/back_button.dart';
import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/custom_icon.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/base/widgets/linear_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
part '../widgets/sorting_app_bar.dart';
part '../widgets/control_buttons.dart';
part '../widgets/size_draggable.dart';

class SortingPage extends ConsumerWidget {
  const SortingPage({required this.instance, required this.title, super.key});
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final description = ref.read(instance.notifier).description;
    final complexity = ref.read(instance.notifier).algoComplexity;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await ref.read(instance.notifier).cancelSorting();
          ref.invalidate(instance); // deletes current instance and resets
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              centerTitle: false,
              titleSpacing: 0,
              leading: CustomBackButtonIcon(),
              title: _AlgorithmTitle(title: title, description: description),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RSizedBox(width: 16),
                    _TimeComplexityData(complexity: complexity),
                    RSizedBox(width: 10),
                    _SpaceComplexityData(complexity: complexity),
                    RSizedBox(width: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
                padding: REdgeInsetsDirectional.only(top: 20, bottom: 10),
                sliver: SliverToBoxAdapter(child: ShowUpSortingList(instance))),
            SliverToBoxAdapter(child: _StatusLiveText(instance)),
            SliverPadding(
              padding: REdgeInsetsDirectional.only(top: 10, bottom: 10),
              sliver: SliverToBoxAdapter(child: _ProgressBar(instance)),
            ),   SliverPadding(
              padding: REdgeInsetsDirectional.only(top: 10, bottom: 10),
              sliver: SliverToBoxAdapter(child: _SortingControlButtons(instance)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeComplexityData extends StatelessWidget {
  const _TimeComplexityData({required this.complexity});

  final AlgorithmComplexity complexity;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      withAboveShadow: false,
      borderRadius: 8,
      padding: REdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIcon(Icons.access_time_rounded, size: 14, color: ThemeEnum.hoverColor),
          RSizedBox(width: 4),
          RegularText(StringsManager.time, color: ThemeEnum.hoverColor, fontSize: 14),
          RSizedBox(width: 2),
          RegularText(StringsManager.best, color: ThemeEnum.white2DarkColor, fontSize: 12),
          RSizedBox(width: 2),
          SemiBoldText(complexity.bestTimeComplexity.getText, color: ThemeEnum.greenColor, fontSize: 14),
          RSizedBox(width: 4),
          RegularText(StringsManager.worst, color: ThemeEnum.white2DarkColor, fontSize: 12),
          RSizedBox(width: 2),
          SemiBoldText(complexity.worstTimeComplexity.getText, color: ThemeEnum.mainDarkColor, fontSize: 14),
        ],
      ),
    );
  }
}

class _StatusLiveText extends StatelessWidget {
  const _StatusLiveText(this.instance);

  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        withAboveShadow: false,
        borderRadius: 8,
        padding: REdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: MediumText("Array is fully sorted! 🎉", fontSize: 14, color: ThemeEnum.white2DarkColor),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar(this.instance);

  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: GradientLinearProgressIndicator(value: 0.8),
            ),
          ),
          RSizedBox(width: 10),
          MediumText("Step 15 of 37",fontSize: 12,color: ThemeEnum.hoverColor)
        ],
      ),
    );
  }
}

class _SpaceComplexityData extends StatelessWidget {
  const _SpaceComplexityData({required this.complexity});

  final AlgorithmComplexity complexity;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      withAboveShadow: false,
      borderRadius: 8,
      padding: REdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIcon(Icons.storage_rounded, size: 14, color: ThemeEnum.hoverColor),
          RSizedBox(width: 4),
          RegularText(StringsManager.space, color: ThemeEnum.hoverColor, fontSize: 14),
          RSizedBox(width: 2),
          SemiBoldText(complexity.spaceComplexity.getText, color: ThemeEnum.mainDarkColor, fontSize: 14),
        ],
      ),
    );
  }
}

class _AlgorithmTitle extends StatelessWidget {
  const _AlgorithmTitle({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldText(title, fontSize: 20),
        RegularText(
          description,
          fontSize: 11,
          color: ThemeEnum.hoverColor,
        )
      ],
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

class ShowUpSortingList extends ConsumerWidget {
  const ShowUpSortingList(this.instance, {this.selectedAlgorithmLength = 1, super.key});
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
  final int selectedAlgorithmLength;
  @override
  Widget build(BuildContext context, ref) {
    final items = ref.watch(instance.select((state) => state.list));
    final speedDuration = ref.watch(instance.select((state) => state.swipeDuration));
    final maxHeight = SortingNotifier.calculateMaxListItemHeight(context);
    final size = ref.watch(instance.select((state) => state.size));
    final itemWidth = SortingNotifier.calculateItemWidth(context, size);

    return Padding(
      padding: REdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color:context.getColor(ThemeEnum.backgroundForSortingColor) ,

          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.getColor(ThemeEnum.shadowColor)),
        ),
        padding: REdgeInsets.only(bottom: SortingNotifier.bottomInsidePadding),
        child: SizedBox(
          height: selectedAlgorithmLength == 1 ? maxHeight : null,
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
                  width: itemWidth +
                      SortingNotifier.horizontalInsidePadding -
                      SortingNotifier.horizontalOutSidePadding,
                  duration: speedDuration,
                  child: _BuildItem(
                      item: item,
                      index: index,
                      size: size,
                      itemWidth: itemWidth,
                      instance: instance,
                      speedDuration: speedDuration * 0.5,
                      selectedAlgorithmLength: selectedAlgorithmLength,
                      isLastItem: index == items.length - 1),
                );
              },
            ),
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
    required this.isLastItem,
    required this.itemWidth,
    required this.size,
  });
  final double itemWidth;
  final int size;
  final int index;
  final SortableItem item;
  final Duration speedDuration;
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
  final int selectedAlgorithmLength;
  final bool isLastItem;
  @override
  Widget build(BuildContext context, ref) {
    final currentItem =
        ref.watch(instance.select((state) => index < state.list.length ? state.list[index] : null));
    return Center(
      child: AnimatedContainer(
        duration: speedDuration,
        width: itemWidth,
        height: SortingNotifier.calculateItemHeight(context, item.value, size, selectedAlgorithmLength),
        decoration: BoxDecoration(
          color: context.getColor(currentItem?.getColor ?? SortingNotifier.itemColor),
          borderRadius: BorderRadius.vertical(top: Radius.circular(3.r), bottom: Radius.circular(3.r)),
        ),
      ),
    );
  }
}

//
// static Widget playButton() {
// return Container(
// width: 90,
// height: 90,
// decoration: BoxDecoration(
// gradient: const LinearGradient(
// colors: [
// Color(0xFF7C7BFF),
// Color(0xFFC17CFF),
// ],
// ),
// borderRadius: BorderRadius.circular(30),
// boxShadow: [
// BoxShadow(
// color: const Color(0xFF9B7CFF).withOpacity(0.5),
// blurRadius: 24,
// spreadRadius: 2,
// ),
// ],
// ),
// child: const Icon(
// Icons.play_arrow_rounded,
// size: 50,
// color: Colors.white,
// ),
// );
// }
