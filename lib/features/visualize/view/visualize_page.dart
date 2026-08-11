import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algo_tab.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_title.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/view/searching_view.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view/sorting_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisualizePage extends StatefulWidget {
  const VisualizePage({this.sortingCard, this.searchingCard, super.key});
  final SortingAlgoCards? sortingCard;
  final SearchingAlgoCards? searchingCard;

  @override
  State<VisualizePage> createState() => _VisualizePageState();
}

class _VisualizePageState extends State<VisualizePage> {
  late var sortingCard = widget.sortingCard;
  late var searchingCard = widget.searchingCard;

  final ValueNotifier<String> title = ValueNotifier("");
  final ValueNotifier<String> description = ValueNotifier("");

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
  void didUpdateWidget(covariant VisualizePage oldWidget) {
    if (oldWidget.sortingCard != widget.sortingCard || oldWidget.searchingCard != widget.searchingCard) {
      tabView = getTabView;
      sortingCard = widget.sortingCard;
      searchingCard = widget.searchingCard;
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final (sortingCard, searchingCard) = getCards();

    return Scaffold(
      body: CustomScrollView(
        physics: NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: false,
            titleSpacing: 0,
            leadingWidth: 16.r,
            leading: SizedBox(),
            title: ValueListenableBuilder(
              valueListenable: title,
              builder: (context, titleValue, child) => ValueListenableBuilder(
                valueListenable: description,
                builder: (context, descriptionValue, child) =>
                    AlgorithmTitle(title: titleValue, description: descriptionValue),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: REdgeInsets.symmetric(horizontal: 16),
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
                      child: AlgoTab(
                        isSelected: tabView == 0,
                        addEndPadding: false,
                        label: StringsManager.sorting,
                        verticalPadding: 3,
                        icon: Icons.filter_list_rounded,
                      ),
                    ),
                  ),
                  RSizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          tabView = 1;
                          this.sortingCard = null;
                          this.searchingCard = SearchingAlgoCards.bfs;
                        });
                      },
                      child: AlgoTab(
                        isSelected: tabView == 1,
                        addEndPadding: false,
                        label: StringsManager.searching,
                        verticalPadding: 3,
                        icon: Icons.map_rounded,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
              child: tabView == 0 && sortingCard != null
                  ? SortingView(
                      card: sortingCard,
                      onAlgoChanged: (title, description) {
                        this.title.value = title;
                        this.description.value = description;
                      },
                    )
                  : searchingCard != null
                      ? SearchingView(
                          card: searchingCard,
                          onAlgoChanged: (title, description) {
                            this.title.value = title;
                            this.description.value = description;
                          },
                        )
                      : UnknownView()),
        ],
      ),
    );
  }
}
