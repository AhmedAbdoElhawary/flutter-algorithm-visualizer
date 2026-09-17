import 'package:algorithm_visualizer/features/base/view_model/base_view_model.dart';
import 'package:algorithm_visualizer/features/visualize/helper/o_notation.dart';
import 'package:algorithm_visualizer/features/visualize/view/sub_view/searching/view_model/searching_notifier.dart';
import 'package:flutter/foundation.dart';
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

  ValueListenable<TickerModeData>? _tickerModeNotifier;

  /// Held directly rather than read through `ref`, so pausing still works from
  /// `dispose()`, where touching `ref` throws.
  SearchingNotifier? _notifier;

  void deleteInstance(NotifierProvider<SearchingNotifier, SearchingState> instance) {
    ref.read(instance.notifier).reset();
    ref.invalidate(instance);
  }

  /// Both callers run inside a widget life-cycle, where Riverpod forbids
  /// writing to a provider, so the pause is queued for after the frame.
  void _pauseIfPlaying() {
    final notifier = _notifier;
    if (notifier == null || notifier.isDisposed) return;

    Future(() {
      /// Re-checked inside the callback: the provider auto-disposes, and the
      /// `dispose()` caller is exactly the moment that teardown happens, so the
      /// notifier can die between scheduling this and running it.
      if (notifier.isDisposed) return;
      if (notifier.isPlaying) notifier.togglePlay();
    });
  }

  void _handleTickerModeChange() {
    if (_tickerModeNotifier?.value.enabled == false) _pauseIfPlaying();
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
  void didChangeDependencies() {
    final tickerModeNotifier = TickerMode.getValuesNotifier(context);
    if (!identical(tickerModeNotifier, _tickerModeNotifier)) {
      _tickerModeNotifier?.removeListener(_handleTickerModeChange);
      _tickerModeNotifier = tickerModeNotifier..addListener(_handleTickerModeChange);
    }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant SearchingView oldWidget) {
    if (widget.card != card) _jump(card: widget.card);

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _tickerModeNotifier?.removeListener(_handleTickerModeChange);
    _pauseIfPlaying();

    super.dispose();
  }

  Future<void> _jump({required SearchingAlgoCards card, bool cleanInstance = false}) async {
    if (cleanInstance) {
      final prevInstance = instance;
      deleteInstance(prevInstance);
    }

    final cardValue = BaseViewModel.searchingCards(card);

    /// Assigned straight away rather than inside `setState` — which this State
    /// defers to after the frame. The provider auto-disposes, so a provider the
    /// widget tree is not watching yet is dropped at the end of the frame and
    /// rebuilt with a *new* notifier on the next one. Deferring this left the
    /// first `build()` watching the `late` initializer's provider while
    /// [_notifier] held a notifier that had already been thrown away, so
    /// pausing on a tab switch pointed at the wrong object and did nothing.
    instance = cardValue.instance;
    this.card = card;

    final notifier = ref.read(cardValue.instance.notifier);
    _notifier = notifier;

    widget.onAlgoChanged(cardValue.title, notifier.algorithmDescription, notifier.algoComplexity);

    setState(() {});
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
