import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/view_model/searching_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/pf_controls.dart';
import '../widgets/pf_grid.dart';
import '../widgets/pf_legend.dart';
import '../widgets/pf_step_info.dart';

class SearchingView extends ConsumerStatefulWidget {
  const SearchingView({this.card = SearchingAlgoCards.bfs, required this.onAlgoChanged, super.key});
  final SearchingAlgoCards card;
  final void Function(String title, String description, AlgorithmComplexity complexity) onAlgoChanged;

  @override
  ConsumerState<SearchingView> createState() => _VisualizerScreenState();
}

class _VisualizerScreenState extends ConsumerState<SearchingView> {
  late NotifierProvider<SearchingNotifier, SearchingState> instance =
      BaseViewModel.searchingCards(widget.card).instance;

  late SearchingAlgoCards card = widget.card;

  void deleteInstance(NotifierProvider<SearchingNotifier, SearchingState> instance) {
    ref.read(instance.notifier).reset();
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
  void didUpdateWidget(covariant SearchingView oldWidget) {
    if (widget.card != card) _jump(card: widget.card);

    super.didUpdateWidget(oldWidget);
  }

  Future<void> _jump({required SearchingAlgoCards card, bool cleanInstance = false}) async {
    if (cleanInstance) {
      final prevInstance = instance;
      deleteInstance(prevInstance);
    }

    setState(() {
      instance = BaseViewModel.searchingCards(card).instance;
      this.card = card;
    });

    final description = ref.read(instance.notifier).algorithmDescription;
    final complexity = ref.read(instance.notifier).algoComplexity;
    final cardValue = BaseViewModel.searchingCards(card);

    widget.onAlgoChanged(cardValue.title, description, complexity);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: PFGrid(instance: instance)),
        const SliverToBoxAdapter(child: PFLegend()),
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
