import 'package:algorithm_visualizer/core/resources/styles_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/adaptive/text/adaptive_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algo_tab.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_control.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_status_text.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/complexity_details.dart';
import 'package:algorithm_visualizer/features/base/view_model/algorithm_description_interface.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/widgets/grid_squares_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part '../widgets/control_buttons.dart';

class SortingView extends ConsumerStatefulWidget {
  const SortingView({this.card = SortingAlgoCards.bubble, required this.onAlgoChanged, super.key});
  final SortingAlgoCards card;
  final void Function(String title, String description) onAlgoChanged;
  @override
  ConsumerState<SortingView> createState() => _SortingPageState();
}

class _SortingPageState extends ConsumerState<SortingView> {
  late NotifierProvider<SortingNotifier, SortingNotifierState> instance =
      BaseViewModel.sortingCards(widget.card).instance;

  late SortingAlgoCards card = widget.card;

  Future<void> deleteInstance(NotifierProvider<SortingNotifier, SortingNotifierState> instance) async {
    await ref.read(instance.notifier).cancelSorting();
    ref.invalidate(instance);
  }

  @override
  void setState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      super.setState(fn);
    });
  }

  @override
  void initState() {
    _jump(card: widget.card);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant SortingView oldWidget) {
    if (widget.card != card) _jump(card: widget.card);

    super.didUpdateWidget(oldWidget);
  }

  Future<void> _jump({required SortingAlgoCards card, bool cleanInstance = false}) async {
    if (cleanInstance) {
      final prevInstance = instance;
      await deleteInstance(prevInstance);
    }

    final cardValue = BaseViewModel.sortingCards(card);
    this.card = card;
    instance = cardValue.instance;

    final description = ref.read(cardValue.instance.notifier).algorithmDescription;
    widget.onAlgoChanged(cardValue.title, description);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final complexity = ref.read(instance.notifier).algoComplexity;
    final codeSnippet = ref.read(instance.notifier).code;

    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: REdgeInsetsDirectional.only(bottom: 10),
          sliver: SliverToBoxAdapter(
            child: _SortingSelectionList(
                card: card,
                onChangedTab: (SortingAlgoCards cardValue) async {
                  if (card == cardValue) return;

                  _jump(card: cardValue, cleanInstance: true);
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
        // SliverToBoxAdapter(child: Consumer(builder: (context, ref, child) {
        //   final currentStep = ref.watch(instance.select((s) => s.currentStep));
        //   final currentLine =
        //       currentStep == null ? -1 : ref.read(instance.notifier).codeLineForStep(currentStep);
        //   final title = ref.read(instance.notifier).algoComplexity.name.getNameWithLanguageName;
        //
        //   return LiveCodeSnippet(code: codeSnippet, currentLine: currentLine, title: title);
        // })),
        SliverToBoxAdapter(child: SizedBox(height: 50)),
      ],
    );
  }
}

class _SortingSelectionList extends StatefulWidget {
  const _SortingSelectionList({required this.card, required this.onChangedTab});
  final SortingAlgoCards card;
  final Future<void> Function(SortingAlgoCards cardValue) onChangedTab;
  @override
  State<_SortingSelectionList> createState() => _SortingSelectionListState();
}

class _SortingSelectionListState extends State<_SortingSelectionList> {
  final cardValues = SortingAlgoCards.values;
  final controller = ScrollController();

  @override
  void initState() {
    _jump();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _SortingSelectionList oldWidget) {
    if (widget.card != oldWidget.card) _jump();

    super.didUpdateWidget(oldWidget);
  }

  void _jump() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = cardValues.indexWhere((element) => element == widget.card);
      if (index != -1) {
        controller.animateTo(
          index * 100,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: controller,
      child: Row(
        children: List.generate(
          cardValues.length,
          (index) {
            final cardValue = BaseViewModel.sortingCards(cardValues[index]);
            return Padding(
              padding: REdgeInsetsDirectional.only(
                  start: index == 0 ? 16 : 8, end: index < cardValues.length - 1 ? 0 : 16),
              child: InkWell(
                onTap: () => widget.onChangedTab(cardValues[index]),
                child: AlgoTab(
                  isSelected: cardValues[index] == widget.card,
                  addEndPadding: false,
                  label: cardValue.card.algoComplexity.name,
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

  final NotifierProvider<SortingNotifier, SortingNotifierState> instance;

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
      statusText: inst.statusText(
          previousStep: ref.read(instance).previousStep, currentStep: currentStep, list: list),
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
  final NotifierProvider<SortingNotifier, SortingNotifierState> instance;
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
      child: GridSquaresView(
        squareSize: 14,
        makeThemPerfectGrids: true,
        estimatedHeight: widget.selectedAlgorithmLength == 1 ? maxHeight : ScreenUtil().screenHeight,
        child: Container(
          padding: REdgeInsets.only(bottom: SortingNotifier.bottomInsidePadding),
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
                  width:
                      itemWidth + SortingNotifier.horizontalInsidePadding - SortingNotifier.handleCentralBars,
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
  final NotifierProvider<SortingNotifier, SortingNotifierState> instance;
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
