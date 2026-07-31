import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/helpers/o_notation.dart';
import 'package:algorithm_visualizer/core/resources/strings_manager.dart';
import 'package:algorithm_visualizer/core/widgets/custom_widgets/glass_card.dart';
import 'package:algorithm_visualizer/features/searching/helper/searching_state.dart';
import 'package:algorithm_visualizer/features/searching/view_model/searching_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/base/view_model/sorting_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/bubble/view_model/bubble_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/bucket/view_model/bucket_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/counting/view_model/counting_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/heap/view_model/heap_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/insertion/view_model/insertion_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/merge/view_model/merge_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/quick/view_model/quick_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/radix/view_model/radix_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/selection/view_model/selection_sort_notifier.dart';
import 'package:algorithm_visualizer/features/sorting/shell/view_model/shell_sort_notifier.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';


abstract class AlgorithmNotifier {
  AlgorithmComplexity get algoComplexity;

  String get description;

  List<String> get codeSnippet;

  int codeLineForStep(SortingStep step);
}

class AlgoSortingCard {
  final GlassCard card;
  final StateNotifierProvider<SortingNotifier, SortingNotifierState> instance;
  final RouteConfig route;
  final String title;
  AlgoSortingCard({required this.route, required this.title, required this.card, required this.instance});
}

class AlgoSearchingCard {
  final GlassCard card;
  final StateNotifierProvider<SearchingNotifier, SearchingState> instance;
  final RouteConfig route;
  final String title;
  AlgoSearchingCard({required this.route, required this.title, required this.card, required this.instance});
}

class BasePageViewModel {
  static final Map<String, AlgoSortingCard> sortingCards = {
    StringsManager.bubbleSort: AlgoSortingCard(
      route: Routes.bubbleSort,
      title: StringsManager.bubbleSort,
      instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => BubbleSortNotifier(),
      ),
      card: GlassCard(
        algoComplexity: BubbleSortNotifier.algorithmComplexity,
        color: Color(0xFF5B9CF6),
        icon: Icons.auto_graph,
      ),
    ),
    StringsManager.selectionSort: AlgoSortingCard(
      route: Routes.selectionSort,
      title: StringsManager.selectionSort,
      instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => SelectionSortNotifier(),
      ),
      card: GlassCard(
        algoComplexity: SelectionSortNotifier.algorithmComplexity,
        color: Color(0xFFFFA726),
        icon: Icons.my_location,
      ),
    ),
    StringsManager.insertionSort: AlgoSortingCard(
      route: Routes.insertionSort,
      title: StringsManager.insertionSort,
      instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => InsertionSortNotifier(),
      ),
      card: GlassCard(
        algoComplexity: InsertionSortNotifier.algorithmComplexity,
        color: Color(0xFF66BB6A),
        icon: Icons.input,
      ),
    ),
    StringsManager.mergeSort: AlgoSortingCard(
      route: Routes.mergeSort,
      title: StringsManager.mergeSort,
      instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => MergeSortNotifier(),
      ),
      card: GlassCard(
        algoComplexity: MergeSortNotifier.algorithmComplexity,
        color: Color(0xFFA78BFA),
        icon: Icons.merge_type,
      ),
    ),
    StringsManager.quickSort: AlgoSortingCard(
      route: Routes.quickSort,
      title: StringsManager.quickSort,
      instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => QuickSortNotifier(),
      ),
      card: GlassCard(
        algoComplexity: QuickSortNotifier.algorithmComplexity,
        color: Color(0xFFFB7185),
        icon: Icons.electric_bolt_rounded,
      ),
    ),
    StringsManager.heapSort: AlgoSortingCard(
      route: Routes.heapSort,
      title: StringsManager.heapSort,
      instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => HeapSortNotifier(),
      ),
      card: GlassCard(
        algoComplexity: HeapSortNotifier.algorithmComplexity,
        color: Color(0xFF8D6E63),
        icon: Icons.account_tree,
      ),
    ),
    StringsManager.shellSort: AlgoSortingCard(
      route: Routes.shellSort,
      title: StringsManager.shellSort,
      instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => ShellSortNotifier(),
      ),
      card: GlassCard(
        algoComplexity: ShellSortNotifier.algorithmComplexity,
        color: Color(0xFF26A69A),
        icon: Icons.blur_linear,
      ),
    ),
    StringsManager.radixSort: AlgoSortingCard(
      route: Routes.radixSort,
      title: StringsManager.radixSort,
      instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => RadixSortNotifier(),
      ),
      card: GlassCard(
        algoComplexity: RadixSortNotifier.algorithmComplexity,
        color: Color(0xFF5C6BC0),
        icon: Icons.pin,
      ),
    ),
    StringsManager.countingSort: AlgoSortingCard(
      route: Routes.countingSort,
      title: StringsManager.countingSort,
      instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => CountingSortNotifier(),
      ),
      card: GlassCard(
        algoComplexity: CountingSortNotifier.algorithmComplexity,
        color: Color(0xFF26C6DA),
        icon: Icons.format_list_numbered,
      ),
    ),
    StringsManager.bucketSort: AlgoSortingCard(
      route: Routes.bucketSort,
      title: StringsManager.bucketSort,
      instance: StateNotifierProvider<SortingNotifier, SortingNotifierState>(
        (ref) => BucketSortNotifier(),
      ),
      card: GlassCard(
        algoComplexity: BucketSortNotifier.algorithmComplexity,
        color: Color(0xFFFF7043),
        icon: Icons.inventory_2,
      ),
    ),
  };

  static final Map<String, AlgoSearchingCard> searchingCards = {
    StringsManager.bFS: AlgoSearchingCard(
      route: Routes.bfsSearching,
      instance: StateNotifierProvider<SearchingNotifier, SearchingState>((ref) => BFSSearchingNotifier()),
      title: StringsManager.bFS,
      card: GlassCard(
        algoComplexity: BFSSearchingNotifier.algorithmComplexity,
        color: Color(0xFF5B9CF6),
        icon: Icons.location_searching_rounded,
      ),
    ),
    StringsManager.dFS: AlgoSearchingCard(
      route: Routes.dfsSearching,
      instance: StateNotifierProvider<SearchingNotifier, SearchingState>((ref) => DFSSearchingNotifier()),
      title: StringsManager.dFS,
      card: GlassCard(
        algoComplexity: DFSSearchingNotifier.algorithmComplexity,
        color: Color(0xFFFFA726),
        icon: Icons.search_off_rounded,
      ),
    ),
    StringsManager.aStarSearch: AlgoSearchingCard(
      route: Routes.aStarSearching,
      title: StringsManager.aStarSearch,
      instance: StateNotifierProvider<SearchingNotifier, SearchingState>((ref) => AStarSearchingNotifier()),
      card: GlassCard(
        algoComplexity: AStarSearchingNotifier.algorithmComplexity,
        color: Color(0xFF66BB6A),
        icon: Icons.find_replace_rounded,
      ),
    ),
  };
}
