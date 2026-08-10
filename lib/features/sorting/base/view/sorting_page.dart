import 'package:algorithm_visualizer/core/draggable_progress.dart' show DraggableProgressBar;
import 'package:algorithm_visualizer/core/helpers/playback_speed.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_status_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_title.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/complexity_details.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_page_view_model.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algo_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
part '../widgets/sorting_app_bar.dart';
part '../widgets/control_buttons.dart';
part '../widgets/size_draggable.dart';

class SortingPage extends ConsumerStatefulWidget {
  const SortingPage({required this.instance, required this.title, super.key});
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
  final String title;

  @override
  ConsumerState<SortingPage> createState() => _SortingPageState();
}

class _SortingPageState extends ConsumerState<SortingPage> {
  late StateNotifierProvider<SortingNotifier, SortingNotifierState> instance = widget.instance;
  late String title = widget.title;

  Future<void> deleteInstance(StateNotifierProvider<SortingNotifier, SortingNotifierState> instance) async {
    await ref.read(instance.notifier).cancelSorting();
    ref.invalidate(instance);
  }

  @override
  Widget build(BuildContext context) {
    final description = ref.read(instance.notifier).algorithmDescription;
    final complexity = ref.read(instance.notifier).algoComplexity;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) await deleteInstance(instance);
      },
      child: Scaffold(
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              centerTitle: false,
              titleSpacing: 0,
              leadingWidth: 16.r,
              leading: SizedBox(),
              title: AlgorithmTitle(title: title, description: description),
            ),
            SliverPadding(
              padding: REdgeInsetsDirectional.only(top: 10, bottom: 10),
              sliver: SliverToBoxAdapter(
                child: _SortingSelectionList(
                    title: title,
                    onChangedTab: (AlgoSortingCard cardValue) async {
                      if (title == cardValue.title) return;
                      final inst = instance;

                      setState(() {
                        instance = cardValue.instance;
                        title = cardValue.title;
                      });

                      await deleteInstance(inst);
                    }),
              ),
            ),
            SliverPadding(
              padding: REdgeInsetsDirectional.only(bottom: 10),
              sliver: SliverToBoxAdapter(child: ComplexityDetails(complexity: complexity)),
            ),
            SliverToBoxAdapter(child: ShowUpSortingList(instance)),
            SliverPadding(
              padding: REdgeInsetsDirectional.only(top: 10),
              sliver: SliverToBoxAdapter(child: _StatusText(instance)),
            ),
            SliverToBoxAdapter(child: _SortingControlButtons(instance)),
          ],
        ),
      ),
    );
  }
}

class _SortingSelectionList extends StatefulWidget {
  const _SortingSelectionList({required this.title, required this.onChangedTab});
  final String title;
  final Future<void> Function(AlgoSortingCard cardValue) onChangedTab;
  @override
  State<_SortingSelectionList> createState() => _SortingSelectionListState();
}

class _SortingSelectionListState extends State<_SortingSelectionList> {
  final cardValues = HomePageViewModel.sortingCards.values.toList();
  final controller = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = cardValues.indexWhere((element) => element.title == widget.title);
      if (index != -1) {
        controller.animateTo(
          index * 100,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: controller,
      child: Row(
        children: List.generate(
          HomePageViewModel.sortingCards.length,
          (index) {
            return Padding(
              padding: REdgeInsetsDirectional.only(
                  start: index == 0 ? 16 : 8,
                  end: index < HomePageViewModel.sortingCards.length - 1 ? 0 : 16),
              child: InkWell(
                onTap: () => widget.onChangedTab(cardValues[index]),
                child: AlgoTab(
                  isSelected: cardValues[index].title == widget.title,
                  addEndPadding: false,
                  label: cardValues[index].card.algoComplexity.name,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusText extends ConsumerWidget {
  const _StatusText(this.instance);

  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(instance.select((s) => s.progressValue));
    final label = ref.watch(instance.select((s) => s.progressLabel));
    final currentStep = ref.watch(instance.select((s) => s.currentStep));
    final list = ref.watch(instance.select((s) => s.list));
    final inst = ref.read(instance.notifier);

    return AlgorithmStatusText(
      progressLabel: label,
      progressValue: progress,
      statusText: inst.statusText(currentStep: currentStep, list: list),
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

class ShowUpSortingList extends ConsumerStatefulWidget {
  const ShowUpSortingList(this.instance, {this.selectedAlgorithmLength = 1, super.key});
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
  final int selectedAlgorithmLength;

  @override
  ConsumerState<ShowUpSortingList> createState() => _ShowUpSortingListState();
}

class _ShowUpSortingListState extends ConsumerState<ShowUpSortingList> {
  @override
  void initState() {
    ref.read(widget.instance.notifier).selectedAlgorithmLength = widget.selectedAlgorithmLength;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(widget.instance.select((state) => state.list));
    final speed = ref.watch(widget.instance.select((state) => state.speed));
    final maxHeight = SortingNotifier.calculateMaxListItemHeight;
    final size = ref.watch(widget.instance.select((state) => state.size));
    final itemWidth = SortingNotifier.calculateItemWidth(size);

    return Padding(
      padding: REdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          // size: Size(double.infinity, 200.r),
          painter: _GridBgPainter(
            backgroundColor: context.getColor(ThemeEnum.backgroundForSortingColor),
            borderColor: context.getColor(ThemeEnum.shadowColor),
          ),
          child: Container(
            padding: REdgeInsets.only(bottom: SortingNotifier.bottomInsidePadding),
            child: SizedBox(
              height: widget.selectedAlgorithmLength == 1 ? maxHeight : null,
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: List.generate(
                  items.length,
                  (index) {
                    final item = items[index];
                    final position = ref.watch(widget.instance.select((state) => state.positions[item.id]));
                    return AnimatedPositionedDirectional(
                      key: ValueKey(item.id),
                      start: position?.dx,
                      bottom: position?.dy,
                      width: itemWidth +
                          SortingNotifier.horizontalInsidePadding -
                          SortingNotifier.handleCentralBars,
                      duration: speed.stepSortingDuration,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _BuildItem(
                              item: item,
                              index: index,
                              size: size,
                              itemWidth: itemWidth,
                              instance: widget.instance,
                              speedDuration: speed.stepSortingDuration * 0.5,
                              selectedAlgorithmLength: widget.selectedAlgorithmLength,
                              isLastItem: index == items.length - 1),
                          RSizedBox(height: 4),
                          MediumText('$index', fontSize: 10, color: ThemeEnum.columnColor),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridBgPainter extends CustomPainter {
  const _GridBgPainter({
    required this.backgroundColor,
    required this.borderColor,
  });

  final Color backgroundColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = Radius.circular(20);

    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(rect, radius);

    // Background
    canvas.drawRRect(
      rRect,
      Paint()..color = backgroundColor,
    );

    // Clip so grid doesn't draw outside rounded corners
    canvas.save();
    canvas.clipRRect(rRect);

    final gridPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.015)
      ..strokeWidth = 1;

    const spacing = 24.0;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    canvas.restore();

    // Border
    canvas.drawRRect(
      rRect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _GridBgPainter oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor || borderColor != oldDelegate.borderColor;
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
    final (actualHeight, writtenHeight) =
        SortingNotifier.calculateItemHeight(item.value, size, selectedAlgorithmLength);
    final color = context.getColor(currentItem?.getColor ?? SortingNotifier.itemColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedDefaultTextStyle(
          duration: speedDuration,
          style: GetMediumStyle(fontSize: 10, color: color),
          child: Text(writtenHeight),
        ),
        RSizedBox(height: 4),
        AnimatedContainer(
          duration: speedDuration,
          width: itemWidth,
          height: actualHeight,
          decoration: BoxDecoration(
            color: color,
            boxShadow: currentItem == null || currentItem.getColor == SortingNotifier.itemColor
                ? null
                : [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10)],
            borderRadius: BorderRadius.vertical(top: Radius.circular(3.r), bottom: Radius.circular(3.r)),
          ),
        ),
      ],
    );
  }
}
