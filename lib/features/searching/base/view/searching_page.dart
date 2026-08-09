import 'package:algorithm_visualizer/core/helpers/app_bar/back_button.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_title.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/complexity_details.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algo_tab.dart';
import 'package:algorithm_visualizer/features/home/view_model/home_page_view_model.dart';
import 'package:algorithm_visualizer/features/searching/base/view_model/searching_notifier.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/pf_controls.dart';
import '../widgets/pf_grid.dart';
import '../widgets/pf_legend.dart';
import '../widgets/pf_step_info.dart';

class VisualizerScreen extends ConsumerStatefulWidget {
  const VisualizerScreen({required this.title, required this.instance, super.key});
  final StateNotifierProvider<SearchingNotifier, SearchingState> instance;
  final String title;
  @override
  ConsumerState<VisualizerScreen> createState() => _VisualizerScreenState();
}

class _VisualizerScreenState extends ConsumerState<VisualizerScreen> {
  late StateNotifierProvider<SearchingNotifier, SearchingState> instance = widget.instance;
  final searchingCardValues = HomePageViewModel.searchingCards.values.toList();
  late String title = widget.title;

  void deleteInstance(StateNotifierProvider<SearchingNotifier, SearchingState> instance) {
    ref.read(instance.notifier).reset();
    ref.invalidate(instance);
  }

  @override
  Widget build(BuildContext context) {
    final description = ref.read(instance.notifier).algorithmDescription;
    final complexity = ref.read(instance.notifier).algoComplexity;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) deleteInstance(instance);
      },
      child: Scaffold(
        backgroundColor: context.bg,
        body: SafeArea(
          child: CustomScrollView(
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
              SliverToBoxAdapter(child: ComplexityDetails(complexity: complexity)),
              SliverPadding(
                padding: REdgeInsets.symmetric(vertical: 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: List.generate(
                      HomePageViewModel.searchingCards.length,
                      (index) {
                        return Expanded(
                          child: Padding(
                            padding: REdgeInsetsDirectional.only(
                                start: index == 0 ? 16 : 8,
                                end: index < HomePageViewModel.searchingCards.length - 1 ? 0 : 16),
                            child: InkWell(
                              onTap: () async {
                                if (title == searchingCardValues[index].title) return;
                                final inst = instance;

                                setState(() {
                                  instance = searchingCardValues[index].instance;
                                  title = searchingCardValues[index].title;
                                });

                                deleteInstance(inst);
                              },
                              child: AlgoTab(
                                isSelected: searchingCardValues[index].title == title,
                                addEndPadding: false,
                                label: searchingCardValues[index].card.algoComplexity.name,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
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
          ),
        ),
      ),
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
