import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algo_tab.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/searching/base/view/searching_view.dart';
import 'package:algorithm_visualizer/features/sorting/base/view/sorting_view.dart';
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
  late int tabView = getTabView;

  int get getTabView => widget.sortingCard == null && widget.searchingCard == null
      ? 0
      : widget.searchingCard == null
          ? 0
          : 1;
  (SortingAlgoCards?, SearchingAlgoCards?) getCards() {
    var sortingCard = widget.sortingCard;
    var searchingCard = widget.searchingCard;
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
            // title: AlgorithmTitle(title: title, description: description),
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
                  ? SortingView(card: sortingCard)
                  : searchingCard != null
                      ? SearchingView(card: searchingCard)
                      : UnknownView()),
        ],
      ),
    );
  }
}
