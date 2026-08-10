import 'package:algorithm_visualizer/core/widgets/custom_widgets/complexity_details.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algo_tab.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/searching/base/view_model/searching_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/pf_controls.dart';
import '../widgets/pf_grid.dart';
import '../widgets/pf_legend.dart';
import '../widgets/pf_step_info.dart';

class SearchingView extends ConsumerStatefulWidget {
  const SearchingView({this.card = SearchingAlgoCards.bfs, super.key});
  final SearchingAlgoCards card;
  @override
  ConsumerState<SearchingView> createState() => _VisualizerScreenState();
}

class _VisualizerScreenState extends ConsumerState<SearchingView> {
  late StateNotifierProvider<SearchingNotifier, SearchingState> instance =
      StateNotifierProvider<SearchingNotifier, SearchingState>((ref) => BFSSearchingNotifier());

  // final searchingCardValues = SortingAlgoCards;
  late SearchingAlgoCards card = widget.card;

  void deleteInstance(StateNotifierProvider<SearchingNotifier, SearchingState> instance) {
    ref.read(instance.notifier).reset();
    ref.invalidate(instance);
  }

  @override
  Widget build(BuildContext context) {
    final description = ref.read(instance.notifier).algorithmDescription;
    final complexity = ref.read(instance.notifier).algoComplexity;

    final searchingValues = SearchingAlgoCards.values;
    return CustomScrollView(
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: REdgeInsets.symmetric(vertical: 10),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: List.generate(
                searchingValues.length,
                (index) {
                  final cardValue = searchingValues[index];
                  final searchingCardValues = BaseViewModel.searchingCards(searchingValues[index]);

                  return Expanded(
                    child: Padding(
                      padding: REdgeInsetsDirectional.only(
                          start: index == 0 ? 16 : 8, end: index < searchingValues.length - 1 ? 0 : 16),
                      child: InkWell(
                        onTap: () async {
                          if (card == cardValue) return;
                          final inst = instance;

                          setState(() {
                            instance = searchingCardValues.instance;
                            card = cardValue;
                          });

                          deleteInstance(inst);
                        },
                        child: AlgoTab(
                          isSelected: cardValue == card,
                          addEndPadding: false,
                          label: searchingCardValues.card.algoComplexity.name,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SliverPadding(
            padding: REdgeInsetsDirectional.only(bottom: 10),
            sliver: SliverToBoxAdapter(child: ComplexityDetails(complexity: complexity))),

        SliverToBoxAdapter(child: PFGrid(instance: instance)),
        SliverToBoxAdapter(child: PFLegend()),
        SliverPadding(
          padding: REdgeInsets.only(top: 10),
          sliver: SliverToBoxAdapter(child: PFStepInfo(instance: instance)),
        ),
        SliverToBoxAdapter(child: SearchingAlgorithmControls(instance: instance)),
        // SliverPadding(
        //   padding: REdgeInsetsDirectional.only(top: 10, bottom: 10),
        //   sliver: SliverToBoxAdapter(child: _LiveCodeSnippet(instance)),
        // ),
      ],
    );
  }
}
//
// class _LiveCodeSnippet extends ConsumerWidget {
//   const _LiveCodeSnippet(this.instance);
//
//   final StateNotifierProvider<SearchingNotifier, SearchingState> instance;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final currentLine = ref.watch(instance.select((s) => s.currentCodeLine));
//     final codeLines = ref.read(instance.notifier).codeSnippet;
//     return LiveCodeSnippet(currentLine: currentLine, codeLines: codeLines);
//   }
// }
