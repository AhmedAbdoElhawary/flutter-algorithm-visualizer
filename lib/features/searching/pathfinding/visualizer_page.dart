import 'package:algorithm_visualizer/core/helpers/app_bar/back_button.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algorithm_title.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/complexity_details.dart';
import 'package:algorithm_visualizer/features/base/view_model/base_page_view_model.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/algo_tab.dart';
import 'package:algorithm_visualizer/features/searching/pathfinding/models/searching_state.dart';
import 'package:algorithm_visualizer/features/searching/pathfinding/providers/searching_notifier.dart';
import 'package:algorithm_visualizer/lib-temp/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/pf_controls.dart';
import 'widgets/pf_grid.dart';
import 'widgets/pf_legend.dart';
import 'widgets/pf_step_info.dart';

class VisualizerScreen extends ConsumerStatefulWidget {
  const VisualizerScreen({required this.title, required this.instance, super.key});
  final StateNotifierProvider<SearchingNotifier, SearchingState> instance;
  final String title;
  @override
  ConsumerState<VisualizerScreen> createState() => _VisualizerScreenState();
}

class _VisualizerScreenState extends ConsumerState<VisualizerScreen> {
  late StateNotifierProvider<SearchingNotifier, SearchingState> instance = widget.instance;
  final searchingCardValues = BasePageViewModel.searchingCards.values.toList();
  late String title = widget.title;

  void deleteInstance(StateNotifierProvider<SearchingNotifier, SearchingState> instance) {
    ref.read(instance.notifier).reset();
    ref.invalidate(instance);
  }

  @override
  Widget build(BuildContext context) {
    final description = ref.read(instance.notifier).description;
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
                leading: CustomBackButtonIcon(),
                title: AlgorithmTitle(title: title, description: description),
              ),
              SliverToBoxAdapter(child: ComplexityDetails(complexity: complexity)),
              // ComplexityBadges(),
              SliverPadding(
                padding: REdgeInsets.symmetric(vertical: 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: List.generate(
                      BasePageViewModel.searchingCards.length,
                      (index) {
                        return Expanded(
                          child: Padding(
                            padding: REdgeInsetsDirectional.only(
                                start: index == 0 ? 16 : 8,
                                end: index < BasePageViewModel.searchingCards.length - 1 ? 0 : 16),
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
              SliverToBoxAdapter(child: PFStepInfo(instance: instance)),
              SliverToBoxAdapter(child: PFControls(instance: instance)),
            ],
          ),
        ),
      ),
    );
  }
}
