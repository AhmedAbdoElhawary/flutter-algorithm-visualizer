import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/searching/base/view_model/searching_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sub_sorting/bubble_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sub_sorting/bucket_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sub_sorting/counting_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sub_sorting/heap_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sub_sorting/insertion_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sub_sorting/merge_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sub_sorting/quick_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sub_sorting/radix_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sub_sorting/selection_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sub_sorting/shell_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

enum SortingAlgoCards { bubble, selection, insertion, merge, quick, radix, heap, shell, counting, bucket }

enum SearchingAlgoCards { bfs, dfs, aStar }

class AlgoSortingCard {
  final AlgorithmGlassCard card;
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
  final SortingAlgoCards page;
  final String title;
  AlgoSortingCard({required this.page, required this.title, required this.card, required this.instance});
}

class AlgoSearchingCard {
  final AlgorithmGlassCard card;
  final StateNotifierProvider<SearchingNotifier, SearchingState> instance;
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
          instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
            (ref) => BubbleSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: BubbleSortNotifier.algorithmComplexity,
            color: Color(0xFF5B9CF6),
            icon: Icons.auto_graph,
          ),
        );
      case SortingAlgoCards.selection:
        return AlgoSortingCard(
          page: SortingAlgoCards.selection,
          title: StringsManager.selectionSort,
          instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
            (ref) => SelectionSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: SelectionSortNotifier.algorithmComplexity,
            color: Color(0xFF26A69A),
            icon: Icons.select_all,
          ),
        );
      case SortingAlgoCards.insertion:
        return AlgoSortingCard(
          page: SortingAlgoCards.insertion,
          title: StringsManager.insertionSort,
          instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
            (ref) => InsertionSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: InsertionSortNotifier.algorithmComplexity,
            color: Color(0xFF5C6BC0),
            icon: Icons.insert_drive_file,
          ),
        );
      case SortingAlgoCards.merge:
        return AlgoSortingCard(
          page: SortingAlgoCards.merge,
          title: StringsManager.mergeSort,
          instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
            (ref) => MergeSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: MergeSortNotifier.algorithmComplexity,
            color: Color(0xFF9CCC65),
            icon: Icons.merge_type,
          ),
        );
      case SortingAlgoCards.quick:
        return AlgoSortingCard(
          page: SortingAlgoCards.quick,
          title: StringsManager.quickSort,
          instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
            (ref) => QuickSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: QuickSortNotifier.algorithmComplexity,
            color: Color(0xFFF7C246),
            icon: Icons.waves,
          ),
        );
      case SortingAlgoCards.heap:
        return AlgoSortingCard(
          page: SortingAlgoCards.heap,
          title: StringsManager.heapSort,
          instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
            (ref) => HeapSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: HeapSortNotifier.algorithmComplexity,
            color: Color(0xFFE67E22),
            icon: Icons.wifi_tethering,
          ),
        );
      case SortingAlgoCards.shell:
        return AlgoSortingCard(
          page: SortingAlgoCards.shell,
          title: StringsManager.shellSort,
          instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
            (ref) => ShellSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: ShellSortNotifier.algorithmComplexity,
            color: Color(0xFF26A69A),
            icon: Icons.blur_linear,
          ),
        );
      case SortingAlgoCards.radix:
        return AlgoSortingCard(
          page: SortingAlgoCards.radix,
          title: StringsManager.radixSort,
          instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
            (ref) => RadixSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: RadixSortNotifier.algorithmComplexity,
            color: Color(0xFF5C6BC0),
            icon: Icons.pin,
          ),
        );
      case SortingAlgoCards.counting:
        return AlgoSortingCard(
          page: SortingAlgoCards.counting,
          title: StringsManager.countingSort,
          instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
            (ref) => CountingSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: CountingSortNotifier.algorithmComplexity,
            color: Color(0xFF26C6DA),
            icon: Icons.format_list_numbered,
          ),
        );
      case SortingAlgoCards.bucket:
        return AlgoSortingCard(
          page: SortingAlgoCards.bucket,
          title: StringsManager.bucketSort,
          instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
            (ref) => BucketSortNotifier(),
          ),
          card: AlgorithmGlassCard(
            algoComplexity: BucketSortNotifier.algorithmComplexity,
            color: Color(0xFFFF7043),
            icon: Icons.inventory_2,
          ),
        );
    }
  }

  static AlgoSearchingCard searchingCards(SearchingAlgoCards cards) {
    return switch (cards) {
      SearchingAlgoCards.bfs => AlgoSearchingCard(
          page: SearchingAlgoCards.bfs,
          instance: StateNotifierProvider<SearchingNotifier, SearchingState>((ref) => BFSSearchingNotifier()),
          title: StringsManager.bFS,
          card: AlgorithmGlassCard(
            algoComplexity: BFSSearchingNotifier.algorithmComplexity,
            color: Color(0xFF5B9CF6),
            icon: Icons.location_searching_rounded,
          ),
        ),
      SearchingAlgoCards.dfs => AlgoSearchingCard(
          page: SearchingAlgoCards.dfs,
          instance: StateNotifierProvider<SearchingNotifier, SearchingState>((ref) => DFSSearchingNotifier()),
          title: StringsManager.dFS,
          card: AlgorithmGlassCard(
            algoComplexity: DFSSearchingNotifier.algorithmComplexity,
            color: Color(0xFFFFA726),
            icon: Icons.search_off_rounded,
          ),
        ),
      SearchingAlgoCards.aStar => AlgoSearchingCard(
          page: SearchingAlgoCards.aStar,
          title: StringsManager.aStarSearch,
          instance:
              StateNotifierProvider<SearchingNotifier, SearchingState>((ref) => AStarSearchingNotifier()),
          card: AlgorithmGlassCard(
            algoComplexity: AStarSearchingNotifier.algorithmComplexity,
            color: Color(0xFF66BB6A),
            icon: Icons.find_replace_rounded,
          ),
        )
    };
  }
}
