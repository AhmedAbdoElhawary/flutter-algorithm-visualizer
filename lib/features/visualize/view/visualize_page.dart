import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/color_manager.dart';
import 'package:algorithm_visualizer/core/resources/dimensions_manager.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/resources/theme_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algo_tab.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_title.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/complexity_details.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view/searching_view.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/grid_scroll_lock.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/sorting/view/sorting_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisualizePage extends ConsumerStatefulWidget {
  const VisualizePage({this.sortingCard, this.searchingCard, super.key});
  final SortingAlgoCards? sortingCard;
  final SearchingAlgoCards? searchingCard;

  @override
  ConsumerState<VisualizePage> createState() => _VisualizePageState();
}

class _VisualizePageState extends ConsumerState<VisualizePage> {
  late var sortingCard = widget.sortingCard;
  late var searchingCard = widget.searchingCard;

  final ScrollController controller = ScrollController();

  final ValueNotifier<String> title = ValueNotifier("");
  final ValueNotifier<String> description = ValueNotifier("");
  final ValueNotifier<AlgorithmComplexity?> complexity = ValueNotifier(null);

  late int tabView = getTabView;

  int get getTabView => widget.sortingCard == null && widget.searchingCard == null
      ? 0
      : widget.searchingCard == null
          ? 0
          : 1;

  (SortingAlgoCards?, SearchingAlgoCards?) getCards() {
    var sortingCard = this.sortingCard;
    var searchingCard = this.searchingCard;
    sortingCard ??= SortingAlgoCards.bubble;
    searchingCard ??= SearchingAlgoCards.bfs;

    return tabView == 0 ? (sortingCard, null) : (null, searchingCard);
  }

  @override
  void setState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      super.setState(fn);
    });
  }

  @override
  void initState() {
    _scrollSearchingToWatchableView();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VisualizePage oldWidget) {
    if (oldWidget.sortingCard != widget.sortingCard || oldWidget.searchingCard != widget.searchingCard) {
      tabView = getTabView;
      sortingCard = widget.sortingCard;
      searchingCard = widget.searchingCard;
      _scrollSearchingToWatchableView();
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  void _scrollSearchingToWatchableView() {
    if (searchingCard != null && tabView == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.animateTo(50.r, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      });
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    complexity.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (sortingCard, searchingCard) = getCards();

    final gridLocked = tabView == 1 && ref.watch(gridScrollLockProvider);

    return NestedScrollView(
      physics: gridLocked ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      controller: controller,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          pinned: true,
          centerTitle: false,
          titleSpacing: 0,
          leadingWidth: 16.r,
          shadowColor: ColorManager.transparent,
          leading: const SizedBox(),
          title: ValueListenableBuilder(
            valueListenable: title,
            builder: (context, titleValue, child) => ValueListenableBuilder(
              valueListenable: description,
              builder: (context, descriptionValue, child) =>
                  AlgorithmTitle(title: titleValue, description: descriptionValue),
            ),
          ),
        ),
        SliverAppBar(
          snap: true,
          floating: true,
          toolbarHeight: 48.r,
          title: Padding(
            padding: REdgeInsets.only(left: 11, right: 11),
            child: Container(
              decoration: BoxDecoration(
                color: context.getColor(ThemeEnum.surface),
                borderRadius: BorderRadius.circular(CdRadius.md.r),
              ),
              child: Padding(
                padding: REdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            tabView = 0;
                            this.sortingCard = SortingAlgoCards.bubble;
                            this.searchingCard = null;
                          });
                        },
                        child: MainAlgoTab(
                          isSelected: tabView == 0,
                          addEndPadding: false,
                          label: StringsManager.sorting,
                          constrainLabelWidth: true,
                        ),
                      ),
                    ),
                    const RSizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            tabView = 1;
                            this.sortingCard = null;
                            this.searchingCard = SearchingAlgoCards.bfs;
                            _scrollSearchingToWatchableView();
                          });
                        },
                        child: MainAlgoTab(
                          isSelected: tabView == 1,
                          addEndPadding: false,
                          label: StringsManager.searching,
                          constrainLabelWidth: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(95.r),
              child: Container(
                color: context.getColor(ThemeEnum.ground),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tabView == 0 && sortingCard != null) ...[
                      Padding(
                        padding: REdgeInsetsDirectional.only(bottom: 8),
                        child: SortingSelectionList(
                            card: sortingCard,
                            onChangedTab: (SortingAlgoCards cardValue) async {
                              if (sortingCard == cardValue) return;

                              this.sortingCard = cardValue;
                              setState(() {});
                            }),
                      ),
                    ] else if (searchingCard != null) ...[
                      Padding(
                        padding: REdgeInsets.only(bottom: 8),
                        child: Row(
                          children: List.generate(
                            SearchingAlgoCards.values.length,
                            (index) {
                              final cardValue = SearchingAlgoCards.values[index];
                              final searchingCardValues =
                                  BaseViewModel.searchingCards(SearchingAlgoCards.values[index]);

                              return Expanded(
                                child: Padding(
                                  padding: REdgeInsetsDirectional.only(
                                      start: index == 0 ? 16 : 8,
                                      end: index < SearchingAlgoCards.values.length - 1 ? 0 : 16),
                                  child: InkWell(
                                    onTap: () async {
                                      if (searchingCard == cardValue) return;

                                      this.searchingCard = cardValue;
                                      setState(() {});
                                    },
                                    child: AlgoTab(
                                      isSelected: cardValue == searchingCard,
                                      addEndPadding: false,
                                      label: searchingCardValues.card.algoComplexity.name,
                                      constrainLabelWidth: true,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    Padding(
                      padding: REdgeInsets.only(bottom: 10),
                      child: ValueListenableBuilder(
                        valueListenable: complexity,
                        builder: (context, value, child) =>
                            value == null ? const SizedBox.shrink() : ComplexityDetails(complexity: value),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ],
      body: tabView == 0 && sortingCard != null
          ? SortingView(
              card: sortingCard,
              onAlgoChanged: (title, description, complexity) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  this.title.value = title;
                  this.description.value = description;
                  this.complexity.value = complexity;
                });
              },
            )
          : searchingCard != null
              ? SearchingView(
                  card: searchingCard,
                  onAlgoChanged: (title, description, complexity) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      this.title.value = title;
                      this.description.value = description;
                      this.complexity.value = complexity;
                    });
                  },
                )
              : const UnknownView(),
    );
  }
}
