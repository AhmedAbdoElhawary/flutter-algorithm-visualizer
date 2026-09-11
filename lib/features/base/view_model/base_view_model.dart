import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/searching/view_model/searching_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/bubble_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/bucket_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/counting_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/heap_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/insertion_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/merge_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/quick_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/radix_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/selection_sort_notifier.dart';
import 'package:algorithm_visualizer/features/visualize/sub_view/sorting/view_model/sub_sorting/shell_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

enum SortingAlgoCards { bubble, selection, insertion, merge, quick, radix, heap, shell, counting, bucket }

enum SearchingAlgoCards { bfs, dfs, aStar }

class AlgoSortingCard {
  final AlgorithmGlassCard card;
  final NotifierProvider<SortingNotifier, SortingNotifierState> instance;
  final SortingAlgoCards page;
  final String title;
  AlgoSortingCard({required this.page, required this.title, required this.card, required this.instance});
}

class AlgoSearchingCard {
  final AlgorithmGlassCard card;
  final NotifierProvider<SearchingNotifier, SearchingState> instance;
  final SearchingAlgoCards page;
  final String title;
  AlgoSearchingCard({required this.page, required this.title, required this.card, required this.instance});
}

class BaseCategory {
  final SortingAlgoCards sortingCards;
  final Map<String, AlgoSearchingCard> searchingCards;
  BaseCategory({required this.sortingCards, required this.searchingCards});
}

class BaseViewModel {
  static AlgoSortingCard sortingCards(SortingAlgoCards card) {
    switch (card) {
      case SortingAlgoCards.bubble:
        return AlgoSortingCard(
          page: SortingAlgoCards.bubble,
          title: StringsManager.bubbleSort,
          instance: NotifierProvider<SortingNotifier, SortingNotifierState>(
            () => BubbleSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: BubbleSortNotifier.algorithmComplexity,
            icon: Icons.auto_graph,
          ),
        );
      case SortingAlgoCards.selection:
        return AlgoSortingCard(
          page: SortingAlgoCards.selection,
          title: StringsManager.selectionSort,
          instance: NotifierProvider<SortingNotifier, SortingNotifierState>(
            () => SelectionSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: SelectionSortNotifier.algorithmComplexity,
            icon: Icons.select_all,
          ),
        );
      case SortingAlgoCards.insertion:
        return AlgoSortingCard(
          page: SortingAlgoCards.insertion,
          title: StringsManager.insertionSort,
          instance: NotifierProvider<SortingNotifier, SortingNotifierState>(
            () => InsertionSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: InsertionSortNotifier.algorithmComplexity,
            icon: Icons.insert_drive_file,
          ),
        );
      case SortingAlgoCards.merge:
        return AlgoSortingCard(
          page: SortingAlgoCards.merge,
          title: StringsManager.mergeSort,
          instance: NotifierProvider<SortingNotifier, SortingNotifierState>(
            () => MergeSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: MergeSortNotifier.algorithmComplexity,
            icon: Icons.merge_type,
          ),
        );
      case SortingAlgoCards.quick:
        return AlgoSortingCard(
          page: SortingAlgoCards.quick,
          title: StringsManager.quickSort,
          instance: NotifierProvider<SortingNotifier, SortingNotifierState>(
            () => QuickSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: QuickSortNotifier.algorithmComplexity,
            icon: Icons.waves,
          ),
        );
      case SortingAlgoCards.heap:
        return AlgoSortingCard(
          page: SortingAlgoCards.heap,
          title: StringsManager.heapSort,
          instance: NotifierProvider<SortingNotifier, SortingNotifierState>(
            () => HeapSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: HeapSortNotifier.algorithmComplexity,
            icon: Icons.wifi_tethering,
          ),
        );
      case SortingAlgoCards.shell:
        return AlgoSortingCard(
          page: SortingAlgoCards.shell,
          title: StringsManager.shellSort,
          instance: NotifierProvider<SortingNotifier, SortingNotifierState>(
            () => ShellSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: ShellSortNotifier.algorithmComplexity,
            icon: Icons.blur_linear,
          ),
        );
      case SortingAlgoCards.radix:
        return AlgoSortingCard(
          page: SortingAlgoCards.radix,
          title: StringsManager.radixSort,
          instance: NotifierProvider<SortingNotifier, SortingNotifierState>(
            () => RadixSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: RadixSortNotifier.algorithmComplexity,
            icon: Icons.pin,
          ),
        );
      case SortingAlgoCards.counting:
        return AlgoSortingCard(
          page: SortingAlgoCards.counting,
          title: StringsManager.countingSort,
          instance: NotifierProvider<SortingNotifier, SortingNotifierState>(
            () => CountingSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: CountingSortNotifier.algorithmComplexity,
            icon: Icons.format_list_numbered,
          ),
        );
      case SortingAlgoCards.bucket:
        return AlgoSortingCard(
          page: SortingAlgoCards.bucket,
          title: StringsManager.bucketSort,
          instance: NotifierProvider<SortingNotifier, SortingNotifierState>(
            () => BucketSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: BucketSortNotifier.algorithmComplexity,
            icon: Icons.inventory_2,
          ),
        );
    }
  }

  static AlgoSearchingCard searchingCards(SearchingAlgoCards cards) {
    return switch (cards) {
      SearchingAlgoCards.bfs => AlgoSearchingCard(
          page: SearchingAlgoCards.bfs,
          instance: NotifierProvider<SearchingNotifier, SearchingState>(() => BFSSearchingNotifier()),
          title: StringsManager.bFS,
          card: AlgorithmGlassCard(
            algoComplexity: BFSSearchingNotifier.algorithmComplexity,
            icon: Icons.location_searching_rounded,
          ),
        ),
      SearchingAlgoCards.dfs => AlgoSearchingCard(
          page: SearchingAlgoCards.dfs,
          instance: NotifierProvider<SearchingNotifier, SearchingState>(() => DFSSearchingNotifier()),
          title: StringsManager.dFS,
          card: AlgorithmGlassCard(
            algoComplexity: DFSSearchingNotifier.algorithmComplexity,
            icon: Icons.search_off_rounded,
          ),
        ),
      SearchingAlgoCards.aStar => AlgoSearchingCard(
          page: SearchingAlgoCards.aStar,
          title: StringsManager.aStarSearch,
          instance: NotifierProvider<SearchingNotifier, SearchingState>(() => AStarSearchingNotifier()),
          card: AlgorithmGlassCard(
            algoComplexity: AStarSearchingNotifier.algorithmComplexity,
            icon: Icons.find_replace_rounded,
          ),
        )
    };
  }
}
